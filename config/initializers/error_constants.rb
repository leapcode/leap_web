require 'ruby-srp'

WRONG_PASSWORD = SRP::WrongPassword

# In case we use a different ORM at some point
VALIDATION_FAILED = CouchRest::Model::Errors::Validations
RECORD_NOT_FOUND  = CouchRest::Model::DocumentNotFound
RESOURCE_NOT_FOUDN = CouchRest::NotFound
