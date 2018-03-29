module ApplicationHelper
  def yes_or_not_select
    [['SI', true], ['NO', false]]
  end

  def can_export?
    can?(:export, :report)
  end
end
