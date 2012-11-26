class Session < SRP::Session
  include ActiveModel::Validations

  attr_accessor :login

  validates :login,
    :presence => true,
    :format => { :with => /\A[A-Za-z\d_]+\z/,
      :message => "Only letters, digits and _ allowed" }

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
