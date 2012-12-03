module StubRecordHelper

  # Create a stub that has the usual functions of a database record.
  # It won't fail on rendering a form for example.
  def stub_record(klass, params = {}, persisted = true)
    if klass.respond_to?(:valid_attributes_hash)
      params.reverse_merge!(klass.valid_attributes_hash)
    end
    params[:params] = params.stringify_keys
    params.reverse_merge! :id => "A123",
      :class => klass,
      :to_key => ['123'],
      :to_json => %Q({"stub":"#{klass.name}"}),
      :new_record? => !persisted,
      :persisted? => persisted
    stub params
  end

end
