module RecordAssertions

  def assert_error(record, options)
    options.each do |k, v|
      errors = record.errors[k]
      assert_equal I18n.t("errors.messages.#{v}"), errors.first
    end
  end

end
