class Api::V1::Accounts::CrmSessionsController < Api::V1::Accounts::BaseController
  before_action :require_dashboard_user

  def create
    token = Crm::SessionTokenIssuer.new(
      user: current_user,
      account: Current.account,
      account_user: Current.account_user
    ).perform

    response.headers['Cache-Control'] = 'no-store'
    response.headers['Pragma'] = 'no-cache'
    render json: { token: token }
  end

  private

  def require_dashboard_user
    head :forbidden if authenticate_by_access_token? || current_user.blank? || Current.account_user.blank?
  end
end
