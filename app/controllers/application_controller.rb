class ApplicationController < ActionController::API
  def current_user
    @current_user ||= authenticate_user_from_token
  end

  def authenticate_user_from_token
    auth_header = request.headers['Authorization']

    token = auth_header.split(' ').last if auth_header && auth_header.match(/^Bearer /)

    return nil unless token

    payload = JwtService.decode(token)
    
    User.find(payload['user_id']) if payload
  rescue JWT::ExpiredSignature, JWT::VerificationError
    nil
  end

  def authenticate_request!
    render json: { error: 'Não Autorizado' }, status: :unauthorized unless current_user
  end

  private

  def authorize_admin_or_manager!(organization)
    unless current_user.role.in?(['ADMIN', 'MANAGER']) && current_user.organization_id == organization.id
      render json: { error: "Você não tem permissão para gerenciar esta organização." }, status: :forbidden
      return false
    end
    true
  end
end
