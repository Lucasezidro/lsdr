class GoalsController < ApplicationController
  before_action :authenticate_request!

  def index
    organization = Organization.find_by(id: params[:organization_id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end

    unless authorize_admin_or_manager!(organization)
      return 
    end

    goals = organization.goals
    render json: goals, status: :ok
  end

  def create
    organization = Organization.find_by(id: params[:organization_id])

    if !organization
      render json: { error: "Organização não encontrada" }, status: :not_found
      return
    end

    unless authorize_admin_or_manager!(organization)
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

    unless authorize_admin_or_manager!(organization)
      return
    end

    goal = organization.goals.find_by(id: params[:id])

    if !goal
      render json: { error: "Meta não encontrada" }, status: :not_found
      return
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
    params.require(:goal).permit(:title, :description, :due_date, :status, :target_amount)
  end
end