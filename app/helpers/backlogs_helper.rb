module BacklogsHelper
  # Stories of a backlog as listed on its page, filtered by the toolbar's MoSCoW tag (#16).
  def backlog_stories(backlog)
    backlog.user_stories.with_moscow(params[:moscow]).order(:id)
  end
end
