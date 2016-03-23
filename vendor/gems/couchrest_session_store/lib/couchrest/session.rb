module CouchRest

  class StorageMissing < Exception
    attr_reader :db
    def initialize(request, db)
      super(request)
      @db = db.name
      @message = "The database '#{db}' does not exist."
    end
  end

  module Session
  end
end

