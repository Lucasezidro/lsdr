class TransactionsController < ApplicationController
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

    transactions = organization.transactions

    if params[:transaction_type].present? && ['income', 'expense'].include?(params[:transaction_type])
      transactions = transactions.where(transaction_type: params[:transaction_type])
    end

    per_page = params[:per_page] || 10
    page = params[:page] || 1
    paginated_transactions = transactions.order(date: :desc).page(page).per(per_page)

    render json: paginated_transactions, status: :ok
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

    transaction = organization.transactions.new(transaction_params)

    if transaction.save
      render json: transaction, status: :created
    else
      render json: { errors: transaction.errors.full_messages }, status: :unprocessable_entity
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

    transaction = organization.transactions.find_by(id: params[:id])

    if !transaction
      render json: { error: "Transação não encontrada" }, status: :not_found
      return
    end

    if transaction.update(transaction_params)
      render json: transaction, status: :ok
    else
      render json: { errors: transaction.errors.full_messages }, status: :unprocessable_entity
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

    transaction = organization.transactions.find_by(id: params[:id])

    if !transaction
      render json: { error: "Transação não encontrada" }, status: :not_found
      return
    end

    transaction.destroy
    head :no_content
  end

  private

  def transaction_params
    params.require(:transaction).permit(:description, :amount, :transaction_type, :date, :goal_id)
  end
end