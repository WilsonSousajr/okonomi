# Página inicial pública da aplicação.
#
# Pública para que um visitante não autenticado encontre o caminho até a tela de
# entrada ou de cadastro — o acesso aos serviços continua exigindo autenticação (#3).
#
# O projeto de interface de verdade é tratado em #1 e #30.
class HomeController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    # Quem já entrou vai direto para os seus projetos (#3).
    redirect_to projects_path if authenticated?
  end
end
