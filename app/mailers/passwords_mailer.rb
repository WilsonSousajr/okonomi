class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Redefina sua senha do okonomi", to: user.email_address
  end
end
