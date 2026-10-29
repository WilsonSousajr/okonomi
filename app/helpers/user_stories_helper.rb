module UserStoriesHelper
  # MoSCoW options with their meaning visible, as RF16 asks (#16).
  def moscow_options
    UserStory::MOSCOW.map { |tag| [ t("user_stories.moscow.#{tag}"), tag ] }
  end
end
