require 'rails_helper'

RSpec.describe 'CRM session bootstrap', type: :request do
  let(:account) { create(:account) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:path) { "/api/v1/accounts/#{account.id}/crm_session" }

  around do |example|
    ClimateControl.modify(
      TS_CRM_BOOTSTRAP_SECRET: 'controlled-test-secret-with-at-least-32-characters',
      TS_CRM_ENVIRONMENT: 'homologation'
    ) { example.run }
  end

  it 'requires an authenticated dashboard user' do
    post path, as: :json

    expect(response).to have_http_status(:unauthorized)
  end

  it 'issues a no-store token for the current user and account' do
    post path, headers: agent.create_new_auth_token, as: :json

    expect(response).to have_http_status(:success)
    expect(response.headers['Cache-Control']).to include('no-store')
    payload, = JWT.decode(
      response.parsed_body.fetch('token'),
      ENV.fetch('TS_CRM_BOOTSTRAP_SECRET'),
      true,
      algorithm: 'HS256'
    )
    expect(payload).to include('sub' => agent.id.to_s, 'account_id' => account.id.to_s)
  end

  it 'rejects a user who does not belong to the requested account' do
    other_account = create(:account)

    post "/api/v1/accounts/#{other_account.id}/crm_session",
         headers: agent.create_new_auth_token,
         as: :json

    expect(response).to have_http_status(:unauthorized)
  end
end
