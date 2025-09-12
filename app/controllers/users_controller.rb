class UsersController < ApplicationController
  before_action :authenticate_request!, only: [:show, :update, :destroy, :me, :accept_invitation, :invitation_status]

  def create
    user = User.new(user_params)

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    user = User.find_by(id: params[:id])

    if user
      render json: user
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def update
    user = User.find_by(id: params[:id])

    if !user
      render json: { error: "User not found" }, status: :not_found
      return
    end

    if user.update(user_params)
      render json: user, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find_by(id: params[:id])

    if !user
      render json: { error: "User not found" }, status: :not_found
      return
    end

    user.destroy
    head :no_content
  end

  def accept_invitation
    user = current_user

    unless user.organization.present? && user.invitation_status == "pending_invitation"
      render json: { error: "Nenhum convite pendente para este usuário." }, status: :unprocessable_entity
      return
    end

    if user.update(invitation_status: "accepted")
      render json: { message: "Convite para a #{user.organization.company_name} aceito com sucesso." }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue
    render json: { error: "Não foi possível aceitar o convite. Tente novamente mais tarde." }, status: :internal_server_error
  end

  def invitation_status
    unless current_user
      render json: { error: "Não autorizado" }, status: :unauthorized
      return
    end

    if current_user.organization.present?
      render json: { has_invitation: true, organization_name: current_user.organization.company_name }, status: :ok
    else
      render json: { has_invitation: false }, status: :ok
    end
  end

  def me
    render json: current_user, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :role,
      :organization_id,
      address_attributes: [:street, :number, :complement, :neighborhood, :city, :state, :zip_code]
    )
  end
end