class GoalsController < ApplicationController
  before_action :authenticate_request!

  def index
    organization = Organization.find_by(id: params[:organization_id])
  
    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end
  
    unless current_user.organization_id == organization.id
      render json: { error: "Você não tem permissão para visualizar as metas desta organização" }, status: :forbidden
      return
    end
  
    company_goals = organization.goals.where(goal_type: 'company_goal')
    my_goals = organization.goals.where(user: current_user, goal_type: 'employee_goal')
  
    goals = company_goals + my_goals
    render json: goals.uniq, status: :ok
  end

  def show 
    goal = Goal.find_by(id: params[:id])

    if goal
      render json: goal
    else
      render json: { error: "Goal not found" }, status: :not_found
    end
  end

  def create
    organization = Organization.find_by(id: params[:organization_id])
  
    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end
  
    if goal_params[:goal_type] == 'company_goal' && current_user.role != 'ADMIN'
      render json: { error: "Apenas administradores podem criar metas de empresa" }, status: :forbidden
      return
    end
  
    goal = organization.goals.new(goal_params)
  
    if goal.save
      render json: goal, status: :created
    else
      render json: { errors: goal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    organization = Organization.find_by(id: params[:organization_id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end

    goal = organization.goals.find_by(id: params[:id])

    if !goal
      render json: { error: "Meta não encontrada" }, status: :not_found
      return
    end

    if goal_params[:goal_type] == 'company_goal'
      unless current_user.role == 'ADMIN' || current_user.role == 'MANAGER'
        render json: { error: "Você não tem permissão para alterar metas da empresa." }, status: :forbidden
        return
      end
    elsif goal_params[:goal_type] == 'employee_goal'
      unless current_user == goal.user
        render json: { error: "Você não pode alterar a meta de outro funcionário." }, status: :forbidden
        return
      end
    end

    if params[:goal][:pinned]
      organization.goals.where(pinned: true).update_all(pinned: false)
    end

    if goal.update(goal_params)
      render json: goal, status: :ok
    else
      render json: { errors: goal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    organization = Organization.find_by(id: params[:organization_id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end

    unless authorize_admin_or_manager!(organization)
      return
    end

    goal = organization.goals.find_by(id: params[:id])

    if !goal
      render json: { error: "Meta não encontrada" }, status: :not_found
      return
    end

    goal.destroy
    head :no_content
  end

  private

  def goal_params
    params.require(:goal).permit(
      :title, 
      :description, 
      :due_date, 
      :status, 
      :target_amount,
      :goal_type,
      :user_id,
      :pinned,
    )
  end
end