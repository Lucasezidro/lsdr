class OrganizationsController < ApplicationController
  before_action :authenticate_request!, only: [:create, :update, :destroy]

  before_action :authenticate_request!, only: [:create, :update, :destroy, :invite]

  def index 
    organizations = Organization.all
    render json: organizations
  end

  def create
    organization = Organization.new(organization_params)
    organization.owner = current_user
    if organization.save
      current_user.update(organization_id: organization.id, role: 'ADMIN')
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
    unless current_user.management_organization.present?
      render json: { error: 'Você não tem permissão para convidar membros para esta organização.' }, status: :forbidden
      return
    end
  
    user = User.find_by(email: params[:email])

    
    if user.nil?
      render json: { error: 'Usuário não encontrado' }, status: :not_found
      return
    end
    
    if user.organization.present?
      render json: { error: 'Usuário já pertence a uma organização' }, status: :unprocessable_entity
      return
    end
    
    user.update(
      invitation_status: 'pending_invitation',
      organization_id: current_user.management_organization.id,
      invited_organization_id: current_user.management_organization.id,
      role: params[:role] || 'EMPLOYEE',
      )
    user.generate_invitation_token 
    
    # UserMailer.invitation(user, organization).deliver_now
  
    render json: { message: "Convite enviado com sucesso para #{user.email}" }, status: :ok
  end
  

  def members
    organization = Organization.find_by(id: params[:id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end

    unless current_user.organization_id == organization.id
      render json: { error: "Você não tem permissão para visualizar os membros desta organização" }, status: :forbidden
      return
    end

    members = organization.users
    render json: members, status: :ok
  end

  def update_member_role
    organization = Organization.find_by(id: params[:id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end

    return unless authorize_admin_or_manager!(organization)

    member_to_update = organization.users.find_by(id: params[:member_id])

    if !member_to_update
      render json: { error: "Membro não encontrado" }, status: :not_found
      return
    end

    if member_to_update.update(role: params[:role])
      render json: member_to_update, status: :ok
    else
      render json: { errors: member_to_update.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def remove_member
    organization = Organization.find_by(id: params[:id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end

    return unless authorize_admin_or_manager!(organization)

    member_to_remove = organization.users.find_by(id: params[:member_id])

    if !member_to_remove
      render json: { error: "Membro não encontrado" }, status: :not_found
      return
    end

    member_to_remove.organization_id = nil
    
    if member_to_remove.save
      head :no_content
    else
      render json: { errors: member_to_remove.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def dashboard
    organization = Organization.find_by(id: params[:id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end
    
    unless current_user.organization_id == organization.id
      render json: { error: "Você não tem permissão para acessar o dashboard desta organização" }, status: :forbidden
      return
    end

    total_balance = organization.total_balance
    is_balance_positive = total_balance >= 0
    
    goals_with_progress = organization.goals.map do |goal|
      goal.as_json.merge(
        progress_amount: goal.progress_amount,
        progress_percentage: goal.progress_percentage.round(2),
        progress_status_message: goal.progress_status_message
      )
    end

    render json: {
      organization: organization.as_json(only: [:id, :company_name]),
      total_balance: total_balance,
      total_income: organization.total_income,
      total_expenses: organization.total_expenses,
      is_balance_positive: is_balance_positive,
      goals: goals_with_progress 
    }, status: :ok
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