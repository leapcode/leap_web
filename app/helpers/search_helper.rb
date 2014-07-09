module SearchHelper

  def search(target)
    render 'common/search', path: url_for(target),
      id: target.to_s.singularize,
      submit_label: t('.search', cascade: true)
  end

end
