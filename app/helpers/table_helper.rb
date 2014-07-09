module TableHelper

  # we do the translation here so the .key lookup is relative
  # to the partial the helper was called from.
  def table(content, columns)
    render 'common/table',
      content: content,
      columns: columns,
      headers: columns.map {|h| t(".#{h}", cascading: true) },
      none: t('.none', cascading: true)
  end

end
