require 'rails_helper'

RSpec.describe 'Api::V1::Accounts::KanbanEmbedSessionsController', type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account, role: :agent) }

  it 'requires an authenticated account user' do
    post "/api/v1/accounts/#{account.id}/kanban_embed_session"

    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns a ticket for an authenticated account user' do
    with_modified_env(
      'FRONTEND_URL' => 'https://crm.example.com',
      'KANBAN_APP_URL' => 'https://kanban.example.com/app',
      'KANBAN_EMBED_SIGNING_SECRET' => 's' * 64
    ) do
      post "/api/v1/accounts/#{account.id}/kanban_embed_session", headers: user.create_new_auth_token
    end

    expect(response).to have_http_status(:success)
    expect(response.parsed_body.slice('app_origin', 'app_url')).to eq(
      'app_origin' => 'https://kanban.example.com',
      'app_url' => 'https://kanban.example.com/app'
    )
    expect(response.parsed_body['ticket']).to be_present
  end
end
