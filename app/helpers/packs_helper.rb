module PacksHelper
  def packs_order_link(by_param, by_name)
    path = packs_path(:order => by_param)
    link_to_unless(params[:order] == by_param, by_name, path) do
      # content_tag(:span, by_name, :class => "selected")
      link_to by_name, path, :class=>"youarehere"
    end
  end
end