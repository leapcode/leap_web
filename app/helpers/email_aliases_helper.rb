module EmailAliasesHelper

  def email_alias_form(options = {})
    simple_form_for [@user, EmailAlias.new()],
      :html => {:class => "form-horizontal email-alias form"},
      :validate => true do |f|
      yield f
    end
  end

end
