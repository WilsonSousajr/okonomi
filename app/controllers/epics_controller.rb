# Épicos do projeto (#10). Excluir um épico mantém as histórias, só sem épico.
class EpicsController < ApplicationController
  include ProjectScoped

  before_action :set_epic, only: %i[ show edit update destroy ]

  def show
  end

  def new
    @epic = @project.epics.new
  end

  def create
    @epic = @project.epics.new(epic_params)

    if @epic.save
      redirect_to project_epic_path(@project, @epic), notice: "Épico criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @epic.update(epic_params)
      redirect_to project_epic_path(@project, @epic), notice: "Épico atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @epic.destroy!
    redirect_to @project, notice: "Épico excluído.", status: :see_other
  end

  private
    def set_epic
      @epic = @project.epics.find(params[:id])
    end

    def epic_params
      params.expect(epic: [ :title, :description ])
    end
end
