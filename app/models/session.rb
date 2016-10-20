require 'login_format_validation'

class Session < SRP::Session
  include ActiveModel::Validations
  include LoginFormatValidation

  attr_accessor :login

  validates :login, :presence => true

  def initialize(user = nil, aa = nil)
    super(user, aa) if user
  end

  def persisted?
    false
  end

  def new_record?
    true
  end

  def to_model
    self
  end

  def to_key
    [object_id]
  end

  def to_param
    nil
  end
end
