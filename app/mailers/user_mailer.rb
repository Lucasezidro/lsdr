class UserMailer < ApplicationMailer
  def invitation(user, organization)
    @user = user
    @organization = organization
    @invitation_url = accept_invitation_url(token: @user.invitation_token)
    mail(to: @user.email, subject: "Você foi convidado(a) para a #{@organization.company_name}")
  end
end