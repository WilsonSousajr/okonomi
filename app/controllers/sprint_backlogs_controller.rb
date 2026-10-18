# Sprint backlogs do projeto (#6): quantos forem necessários.
class SprintBacklogsController < ApplicationController
  include ProjectScoped

  before_action :set_sprint_backlog, only: %i[ show edit update destroy ]

  def show
  end

  def new
    @backlog = @project.sprint_backlogs.new
  end

  def create
    @backlog = @project.sprint_backlogs.new(backlog_params)

    if @backlog.save
      redirect_to project_sprint_backlog_path(@project, @backlog), notice: "Sprint criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @backlog.update(backlog_params)
      redirect_to project_sprint_backlog_path(@project, @backlog), notice: "Sprint atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @backlog.destroy
      redirect_to @project, notice: "Sprint excluída.", status: :see_other
    else
      redirect_to project_sprint_backlog_path(@project, @backlog), alert: @backlog.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_sprint_backlog
      @backlog = @project.sprint_backlogs.find(params[:id])
    end

    # kind is never taken from the form: this controller only handles sprints.
    def backlog_params
      params.expect(backlog: [ :name, :goal, :starts_on, :ends_on ])
    end
end
