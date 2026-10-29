# Histórias de usuário do projeto (#7). Toda história nasce no product backlog:
# backlog_id nunca vem do formulário — o modelo associa ao product backlog, e a
# movimentação entre backlogs é #8.
class UserStoriesController < ApplicationController
  include ProjectScoped

  before_action :set_user_story, only: %i[ show edit update destroy ]

  def show
  end

  def new
    @user_story = @project.user_stories.new
  end

  def create
    @user_story = @project.user_stories.new(user_story_params)

    if @user_story.save
      redirect_to project_user_story_path(@project, @user_story), notice: "História criada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user_story.update(user_story_params)
      redirect_to project_user_story_path(@project, @user_story), notice: "História atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user_story.destroy!
    redirect_to @project, notice: "História excluída.", status: :see_other
  end

  private
    def set_user_story
      @user_story = @project.user_stories.find(params[:id])
    end

    def user_story_params
      params.expect(user_story: [ :role, :action, :benefit, :epic_id, :story_points ])
    end
end
