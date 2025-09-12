class UserMailer < ApplicationMailer
  def password_reset_email(user)
    @user = user
    @reset_url = "http://localhost:4000/password_resets?token=#{user.password_reset_token}"
    mail(to: @user.email, subject: "Instruções para redefinir sua senha")
  end

  def invitation(user, organization)
    @user = user
    @organization = organization
    @invitation_url = accept_invitation_url(token: @user.invitation_token)
    mail(to: @user.email, subject: "Você foi convidado(a) para a #{@organization.company_name}")
  end
end