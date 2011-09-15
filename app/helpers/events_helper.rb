module EventsHelper
  def event_options(selected)
    s = [["None", ""]]
    for r in Event.order(:name)
      s << [r.name, r.id]
    end
    options_for_select(s, selected)
  end
end