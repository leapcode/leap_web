class Email
  include CouchRest::Model::Embeddable

  property :email, String

  def to_s
    email
  end
end
