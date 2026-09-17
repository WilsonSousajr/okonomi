# Página inicial pública da aplicação.
#
# Esqueleto mínimo (#21): existe porque o concern Authentication redireciona para
# `root_url` após a autenticação, então a rota raiz precisa existir. É pública para
# que um visitante não autenticado encontre o caminho até a tela de entrada — o
# acesso aos serviços continua exigindo autenticação (#3).
#
# O projeto de interface de verdade é tratado em #1 e #30.
class HomeController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
  end
end
