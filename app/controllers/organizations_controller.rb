class OrganizationsController < ApplicationController
  before_action :authenticate_request!, only: [:create, :update, :destroy]

  before_action :authenticate_request!, only: [:create, :update, :destroy, :invite]

  def index 
    organizations = Organization.all
    render json: organizations
  end

  def create
    organization = Organization.new(organization_params)

    if organization.save
      current_user.update(role: 'ADMIN')

      render json: organization, status: :created
    else
      render json: { errors: organization.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show 
    organization = Organization.find_by(id: params[:id])

    if organization
      render json: organization
    else
      render json: { error: "Organization not found" }, status: :not_found
    end
  end

  def update 
    organization = Organization.find_by(id: params[:id])

    if !organization
      render json: { error: "Organization not found" }, status: :not_found
      return
    end

    if organization.update(organization_params)
      render json: organization, status: :ok
    else
      render json: { errors: organization.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    organization = Organization.find_by(id: params[:id])

    if !organization
      render json: { error: "Organization not found" }, status: :not_found
      return
    end

    organization.destroy
    head :no_content
  end

  def invite
    organization = Organization.find_by(id: params[:id])
    user = User.find_by(email: params[:email])

    if !organization || !user
      render json: { error: "Organização ou usuário não encontrado" }, status: :not_found
      return
    end

    return unless authorize_admin_or_manager!(organization)

    unless current_user.role == 'ADMIN' && current_user.organization == organization
      render json: { error: "Apenas administradores podem convidar membros" }, status: :forbidden
      return
    end

    user.organization = organization
    user.role = params[:role] || 'EMPLOYEE'

    if user.save
      render json: { message: "#{user.email} foi convidado(a) com sucesso para a #{organization.company_name}." }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue
    render json: { error: "Não foi possível enviar o convite. Tente novamente mais tarde." }, status: :internal_server_error
  end

  def members
    organization = Organization.find_by(id: params[:id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end

    unless current_user.role == 'ADMIN' && current_user.organization_id == organization.id
      render json: { error: "Você não tem permissão para visualizar os membros desta organização" }, status: :forbidden
      return
    end

    members = organization.users
    render json: members, status: :ok
  end

  private

  def organization_params
    params.require(:organization).permit(
      :company_name, 
      :document_number, 
      :email, 
      :phone, 
      :founding_date, 
      :website_url, 
      :description
    )
  end
end