class Crm::SessionTokenIssuer
  TOKEN_LIFETIME = 60.seconds
  ALGORITHM = 'HS256'.freeze

  def initialize(user:, account:, account_user:, now: Time.current)
    @user = user
    @account = account
    @account_user = account_user
    @now = now
  end

  def perform
    JWT.encode(payload, secret, ALGORITHM, { typ: 'JWT' })
  end

  private

  def payload
    {
      iss: ENV.fetch('TS_CRM_BOOTSTRAP_ISSUER', 'ts-products-chatwoot'),
      aud: ENV.fetch('TS_CRM_BOOTSTRAP_AUDIENCE', 'ts-products-crm'),
      sub: @user.id.to_s,
      account_id: @account.id.to_s,
      role: @account_user.role,
      env: ENV.fetch('TS_CRM_ENVIRONMENT'),
      jti: SecureRandom.uuid,
      iat: @now.to_i,
      exp: (@now + TOKEN_LIFETIME).to_i
    }
  end

  def secret
    value = ENV.fetch('TS_CRM_BOOTSTRAP_SECRET')
    raise ArgumentError, 'TS_CRM_BOOTSTRAP_SECRET must contain at least 32 characters' if value.bytesize < 32

    value
  end
end
