class PasswordResetsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user
      user.generate_password_reset_token!
      UserMailer.password_reset_email(user).deliver_now
    end

    render json: { message: "Se o e-mail for válido, você receberá um link para redefinir sua senha." }, status: :ok
  end

  def update
    user = User.find_by(password_reset_token: params[:token])

    if !user || user.password_reset_sent_at < 2.hours.ago
      render json: { error: "Token inválido ou expirado." }, status: :unprocessable_entity
      return
    end

    if user.update(user_params)
      user.update(password_reset_token: nil, password_reset_sent_at: nil)
      render json: { message: "Senha redefinida com sucesso." }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    user = User.find_by(password_reset_token: params[:token])

    if user && user.password_reset_sent_at > 2.hours.ago
      render json: { message: "Token válido." }, status: :ok
    else
      render json: { error: "Token inválido ou expirado." }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end