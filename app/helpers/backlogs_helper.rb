module BacklogsHelper
  SORT_OPTIONS = { "Ordem de criação" => "", "Maior RICE primeiro" => "rice" }.freeze

  # Stories of a backlog as listed on its page: filtered by MoSCoW tag (#16) and,
  # when asked, ordered by RICE score with undefined scores last (#19).
  def backlog_stories(backlog)
    stories = backlog.user_stories.with_moscow(params[:moscow])
    params[:sort] == "rice" ? stories.by_rice : stories.order(:id)
  end
end
