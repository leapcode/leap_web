module StubRecordHelper

  # Will expect find_by_param or find_by_id to be called on klass and
  # return the record given.
  # If no record is given but a hash or nil will create a stub based on
  # that instead and returns the stub.
  def find_record(factory)
    record = stub_record factory
    klass = record.class
    finder = klass.respond_to?(:find_by_param) ? :find_by_param : :find_by_id
    klass.expects(finder).with(record.to_param.to_s).returns(record)
    return record
  end

  # Create a stub that has the usual functions of a database record.
  # It won't fail on rendering a form for example.
  #
  # If the second parameter is a record we return the record itself.
  # This way you can build functions that either take a record or a
  # method hash to stub from. See find_record for an example.
  def stub_record(factory, record_or_method_hash = {})
    if record_or_method_hash && !record_or_method_hash.is_a?(Hash)
      return record_or_method_hash
    end
    FactoryGirl.build_stubbed(factory).tap do |record|
      record.stubs(record_or_method_hash) if record_or_method_hash.present?
    end
  end

  # returns deep stringified attributes so they can be compared to
  # what the controller receives as params
  def record_attributes_for(factory, attribs_hash = nil)
    FactoryGirl.attributes_for(factory, attribs_hash).tap do |attribs|
      attribs.keys.each do |key|
        val = attribs.delete(key)
        attribs[key.to_s] = val.is_a?(Hash) ? val.stringify_keys! : val
      end
    end
  end

end

class ActionController::TestCase
  include StubRecordHelper
end
