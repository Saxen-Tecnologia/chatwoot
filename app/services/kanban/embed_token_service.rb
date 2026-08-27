class Kanban::EmbedTokenService
  AUDIENCE = 'ts-products-crm-kanban'.freeze
  TOKEN_TTL = 60.seconds

  pattr_initialize [:account!, :user!]

  def generate
    issued_at = Time.current.to_i
    expires_at = issued_at + TOKEN_TTL.to_i

    {
      app_origin: origin(app_uri),
      app_url: app_uri.to_s,
      expires_at: Time.zone.at(expires_at).iso8601,
      ticket: JWT.encode(payload(issued_at, expires_at), signing_secret, 'HS256')
    }
  end

  private

  def payload(issued_at, expires_at)
    {
      iss: origin(frontend_uri),
      aud: AUDIENCE,
      sub: user.id.to_s,
      account_id: account.id.to_s,
      iat: issued_at,
      nbf: issued_at - 5,
      exp: expires_at,
      jti: SecureRandom.uuid
    }
  end

  def app_uri
    @app_uri ||= begin
      uri = URI.parse(ENV.fetch('KANBAN_APP_URL'))
      raise ArgumentError, 'KANBAN_APP_URL must be an absolute HTTP(S) URL' unless uri.is_a?(URI::HTTP) && uri.host.present?

      uri
    end
  end

  def frontend_uri
    @frontend_uri ||= begin
      uri = URI.parse(ENV.fetch('FRONTEND_URL'))
      raise ArgumentError, 'FRONTEND_URL must be an absolute HTTP(S) URL' unless uri.is_a?(URI::HTTP) && uri.host.present?

      uri
    end
  end

  def signing_secret
    @signing_secret ||= ENV.fetch('KANBAN_EMBED_SIGNING_SECRET').tap do |secret|
      raise ArgumentError, 'KANBAN_EMBED_SIGNING_SECRET must contain at least 64 characters' if secret.length < 64
    end
  end

  def origin(uri)
    default_port = (uri.scheme == 'https' ? 443 : 80)
    port = uri.port == default_port ? nil : ":#{uri.port}"
    "#{uri.scheme}://#{uri.host}#{port}"
  end
end
