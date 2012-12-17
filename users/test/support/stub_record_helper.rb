module StubRecordHelper

  # Will expect find_by_param or find_by_id to be called on klass and
  # return the record given.
  # If no record is given but a hash or nil will create a stub based on
  # that instead and returns the stub.
  def find_record(klass, record_or_method_hash = {})
    record = stub_record(klass, record_or_method_hash)
    finder = klass.respond_to?(:find_by_param) ? :find_by_param : :find_by_id
    klass.expects(finder).with(record.to_param).returns(record)
    return record
  end

  # Create a stub that has the usual functions of a database record.
  # It won't fail on rendering a form for example.
  #
  # If the second parameter is a record we return the record itself.
  # This way you can build functions that either take a record or a
  # method hash to stub from. See find_record for an example.
  def stub_record(klass, record_or_method_hash = {}, persisted = true)
    if record_or_method_hash && !record_or_method_hash.is_a?(Hash)
      return record_or_method_hash
    end
    stub record_params_for(klass, record_or_method_hash, persisted)
  end

  def record_params_for(klass, params = {}, persisted = true)
    if klass.respond_to?(:valid_attributes_hash)
      params.reverse_merge!(klass.valid_attributes_hash)
    end
    params[:params] = params.stringify_keys
    params.reverse_merge! :id => "A123",
      :to_param => "A123",
      :class => klass,
      :to_key => ['123'],
      :to_json => %Q({"stub":"#{klass.name}"}),
      :new_record? => !persisted,
      :persisted? => persisted
  end

end

class ActionController::TestCase
  include StubRecordHelper
end
