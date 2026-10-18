# Criação de conta (#2). Ao criar a conta o usuário já sai autenticado.
class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Muitas tentativas. Tente novamente mais tarde." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Conta criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def registration_params
      params.expect(user: [ :email_address, :password, :password_confirmation ])
    end
end
