# Recursos aninhados em um projeto (#5, #6, #7). O projeto vem sempre de
# Current.user.projects: o de outro usuário não é encontrado (404, #3), e o
# recurso aninhado é buscado a partir dele, nunca pelo id solto.
module ProjectScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_project
  end

  private
    def set_project
      @project = Current.user.projects.find(params[:project_id])
    end
end
