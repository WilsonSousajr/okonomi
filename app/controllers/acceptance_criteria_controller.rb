# Critérios de aceitação de uma história (#12). A história é buscada pelo projeto do usuário
# e o critério pela história, então um ID alheio em qualquer nível da rota dá 404.
class AcceptanceCriteriaController < ApplicationController
  include ProjectScoped

  before_action :set_user_story
  before_action :set_acceptance_criterion, only: %i[ edit update destroy ]

  def new
    @acceptance_criterion = @user_story.acceptance_criteria.new
  end

  def create
    @acceptance_criterion = @user_story.acceptance_criteria.new(acceptance_criterion_params)

    if @acceptance_criterion.save
      redirect_to project_user_story_path(@project, @user_story), notice: "Critério criado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @acceptance_criterion.update(acceptance_criterion_params)
      redirect_to project_user_story_path(@project, @user_story), notice: "Critério atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @acceptance_criterion.destroy!
    redirect_to project_user_story_path(@project, @user_story), notice: "Critério excluído.", status: :see_other
  end

  private
    def set_user_story
      @user_story = @project.user_stories.find(params[:user_story_id])
    end

    def set_acceptance_criterion
      @acceptance_criterion = @user_story.acceptance_criteria.find(params[:id])
    end

    def acceptance_criterion_params
      params.expect(acceptance_criterion: [ :context, :action, :outcome ])
    end
end
