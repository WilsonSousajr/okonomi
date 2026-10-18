class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Muitas tentativas. Tente novamente mais tarde." }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "Se existir uma conta com esse e-mail, enviamos as instruções para redefinir a senha."
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Senha redefinida. Entre com a nova senha."
    else
      redirect_to edit_password_path(params[:token]), alert: reset_failure_message
    end
  end

  private
    # Says why the reset failed: a short password is not a mismatch (#80).
    def reset_failure_message
      if @user.errors.of_kind?(:password_confirmation, :confirmation)
        "As senhas não conferem."
      else
        @user.errors.full_messages.to_sentence
      end
    end

    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "O link de redefinição é inválido ou expirou."
    end
end
