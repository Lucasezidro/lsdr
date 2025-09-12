class AddressesController < ApplicationController
  def index
    addresses = Address.all
    render json: addresses
  end

  def show
    address = Address.find_by(id: params[:id])
    if address
      render json: address
    else  
      render json: { error: 'Address not found' }, status: :not_found
    end
  end

  def create
    address = Address.new(address_params)
    if address.save
      render json: address, status: :created
    else
      render json: { errors: address.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    address = Address.find_by(id: params[:id])
    if !address
      render json: { error: 'Address not found' }, status: :not_found
      return
    end

    if address.update(address_params)
      render json: address
    else
      render json: { errors: address.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    address = Address.find_by(id: params[:id])
    if !address
      render json: { error: 'Address not found' }, status: :not_found
      return
    end

    address.destroy
    head :no_content
  end

  private

  def address_params
    params.require(:address).permit(:street, :number, :complement, :neighborhood, :city, :state, :zip_code)
  end
end