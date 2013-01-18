class RemoteEmail
  include CouchRest::Model::Embeddable
  include Email

  property :email, String

  def username
    email.spilt('@').first
  end

  def domain
    email.split('@').last
  end
end
