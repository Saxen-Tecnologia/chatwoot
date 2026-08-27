require 'rails_helper'

RSpec.describe Kanban::EmbedTokenService do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account, role: :agent) }
  let(:secret) { 's' * 64 }

  it 'generates a short-lived ticket bound to the current account and user' do
    result = with_modified_env(
      'FRONTEND_URL' => 'https://crm.example.com/app',
      'KANBAN_APP_URL' => 'https://kanban.example.com/app',
      'KANBAN_EMBED_SIGNING_SECRET' => secret
    ) do
      described_class.new(account: account, user: user).generate
    end

    payload = JWT.decode(result[:ticket], secret, true, algorithm: 'HS256', aud: described_class::AUDIENCE, verify_aud: true).first

    expect(result.slice(:app_origin, :app_url)).to eq(
      app_origin: 'https://kanban.example.com',
      app_url: 'https://kanban.example.com/app'
    )
    expect(payload.slice('iss', 'sub', 'account_id')).to eq(
      'iss' => 'https://crm.example.com',
      'sub' => user.id.to_s,
      'account_id' => account.id.to_s
    )
    expect(payload['exp'] - payload['iat']).to eq(60)
    expect(payload['jti']).to be_present
  end

  it 'rejects a weak signing secret' do
    expect do
      with_modified_env(
        'FRONTEND_URL' => 'https://crm.example.com',
        'KANBAN_APP_URL' => 'https://kanban.example.com/app',
        'KANBAN_EMBED_SIGNING_SECRET' => 'short'
      ) do
        described_class.new(account: account, user: user).generate
      end
    end.to raise_error(ArgumentError, /at least 64 characters/)
  end
end
