# Move uma história entre backlogs (#8). O destino é buscado só entre os backlogs do projeto,
# então um backlog de outro projeto dá 404; o model e a FK composta recusam o resto.
class UserStoryMovesController < ApplicationController
  include ProjectScoped

  def create
    user_story = @project.user_stories.find(params[:user_story_id])
    backlog = @project.backlogs.find(params.expect(:backlog_id))

    user_story.update!(backlog: backlog)
    redirect_to project_user_story_path(@project, user_story), notice: "História movida para #{backlog.name}."
  end
end
