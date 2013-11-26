class PgpKey
  include ActiveModel::Validations

  # mostly for testing.
  attr_accessor :key_block

  def initialize(key_block = nil)
    @key_block = key_block
  end

  def to_s
    @key_block
  end

  def present?
    @key_block.present?
  end

  # let's allow comparison with plain key_block strings.
  def ==(other)
    self.equal?(other) or
    self.to_s == other
  end

end
