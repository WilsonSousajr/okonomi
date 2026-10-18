# CRUD de projetos (#4). Toda consulta passa por Current.user.projects, então o
# projeto de outro usuário simplesmente não é encontrado (404, #3).
class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  def index
    @projects = Current.user.projects.order(:name)
  end

  def show
  end

  def new
    @project = Current.user.projects.new
  end

  def create
    @project = Current.user.projects.new(project_params)

    if @project.save
      redirect_to @project, notice: "Projeto criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Projeto atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy!
    redirect_to projects_path, notice: "Projeto excluído.", status: :see_other
  end

  private
    def set_project
      @project = Current.user.projects.find(params[:id])
    end

    def project_params
      params.expect(project: [ :name, :description ])
    end
end
