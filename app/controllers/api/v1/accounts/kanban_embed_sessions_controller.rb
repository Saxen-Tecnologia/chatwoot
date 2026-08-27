class Api::V1::Accounts::KanbanEmbedSessionsController < Api::V1::Accounts::BaseController
  def create
    render json: Kanban::EmbedTokenService.new(account: Current.account, user: Current.user).generate
  rescue KeyError, ArgumentError, URI::InvalidURIError => e
    Rails.logger.error("Kanban embed configuration error: #{e.class}")
    render json: { error: 'Kanban is not configured for this installation' }, status: :service_unavailable
  end
end
