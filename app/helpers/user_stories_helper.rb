module UserStoriesHelper
  RICE_IMPACT_LABELS = { "3" => :massive, "2" => :high, "1" => :medium, "0.5" => :low, "0.25" => :minimal }.freeze
  RICE_CONFIDENCE_LABELS = { 100 => :high, 80 => :medium, 50 => :low }.freeze

  # MoSCoW options with their meaning visible, as RF16 asks (#16).
  def moscow_options
    UserStory::MOSCOW.map { |tag| [ t("user_stories.moscow.#{tag}"), tag ] }
  end

  # Impact and Confidence options show the method's textual label next to the value (#18).
  def rice_impact_options
    UserStory::RICE_IMPACTS.map { |impact| [ "#{format_rice_number(impact)} — #{rice_impact_label(impact)}", rice_impact_value(impact) ] }
  end

  # Impact is a BigDecimal; the form value is its plain form ("2", "0.5", "0.25") so the select can preselect it.
  def rice_impact_value(impact)
    impact&.to_s("F")&.delete_suffix(".0")
  end

  def rice_confidence_options
    UserStory::RICE_CONFIDENCES.map { |confidence| [ "#{confidence}% — #{rice_confidence_label(confidence)}", confidence ] }
  end

  def rice_impact_text(impact)
    impact && "#{format_rice_number(impact)} (#{rice_impact_label(impact)})"
  end

  def rice_confidence_text(confidence)
    confidence && "#{confidence}% (#{rice_confidence_label(confidence)})"
  end

  def rice_score_text(story)
    score = story.rice_score
    score ? number_with_precision(score, precision: 2) : t("user_stories.rice_score_undefined")
  end

  private
    def rice_impact_label(impact)
      t("user_stories.rice_impact.#{RICE_IMPACT_LABELS.fetch(rice_impact_value(impact))}")
    end

    def rice_confidence_label(confidence)
      t("user_stories.rice_confidence.#{RICE_CONFIDENCE_LABELS.fetch(confidence)}")
    end

    def format_rice_number(value)
      number_with_precision(value, precision: 2, strip_insignificant_zeros: true)
    end
end
