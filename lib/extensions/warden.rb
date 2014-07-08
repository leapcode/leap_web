module Warden
  # Setup Session Serialization
  class SessionSerializer
    def serialize(record)
      [record.class.name, record.id]
    end

    def deserialize(keys)
      klass, id = keys
      klass.constantize.find(id)
    end
  end
end
