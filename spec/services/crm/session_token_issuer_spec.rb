require 'rails_helper'

RSpec.describe Crm::SessionTokenIssuer do
  subject(:token) do
    described_class.new(user: user, account: account, account_user: account_user, now: now).perform
  end

  let(:account) { create(:account) }
  let(:user) { create(:user, account: account, role: :agent) }
  let(:account_user) { account.account_users.find_by!(user_id: user.id) }
  let(:now) { Time.zone.parse('2026-08-20 20:00:00 UTC') }
  let(:secret) { 'controlled-test-secret-with-at-least-32-characters' }

  around do |example|
    ClimateControl.modify(
      TS_CRM_BOOTSTRAP_SECRET: secret,
      TS_CRM_ENVIRONMENT: 'homologation',
      TS_CRM_BOOTSTRAP_ISSUER: 'ts-products-chatwoot',
      TS_CRM_BOOTSTRAP_AUDIENCE: 'ts-products-crm'
    ) { example.run }
  end

  it 'issues bounded account-scoped HS256 claims' do
    payload, header = JWT.decode(
      token,
      secret,
      true,
      algorithm: 'HS256',
      audience: 'ts-products-crm',
      verify_aud: true
    )

    expect(header).to include('alg' => 'HS256', 'typ' => 'JWT')
    expect(payload).to include(
      'iss' => 'ts-products-chatwoot',
      'aud' => 'ts-products-crm',
      'sub' => user.id.to_s,
      'account_id' => account.id.to_s,
      'role' => 'agent',
      'env' => 'homologation',
      'iat' => now.to_i,
      'exp' => now.to_i + 60
    )
    expect(payload.fetch('jti')).to match(/\A[0-9a-f-]{36}\z/)
  end

  it 'rejects a weak shared secret' do
    ClimateControl.modify(TS_CRM_BOOTSTRAP_SECRET: 'too-short') do
      expect { token }.to raise_error(ArgumentError, /at least 32 characters/)
    end
  end
end
