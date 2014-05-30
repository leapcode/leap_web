class PgpKey
  include ActiveModel::Validations

  KEYBLOCK_IDENTIFIERS = [
    '-----BEGIN PGP PUBLIC KEY BLOCK-----',
    '-----END PGP PUBLIC KEY BLOCK-----',
  ]

  # mostly for testing.
  attr_accessor :keyblock

  validate :validate_keyblock_format

  def initialize(keyblock = nil)
    @keyblock = keyblock
  end

  def to_s
    @keyblock
  end

  def present?
    @keyblock.present?
  end

  # allow comparison with plain keyblock strings.
  def ==(other)
    return false if (self.present? != other.present?)
    self.equal?(other) or
    # relax the comparison on line ends.
    self.to_s.tr_s("\n\r", '') == other.tr_s("\n\r", '')
  end

  protected

  def validate_keyblock_format
    if keyblock_identifier_missing?
      errors.add :public_key_block,
        "does not look like an armored pgp public key block"
    end
  end

  def keyblock_identifier_missing?
    KEYBLOCK_IDENTIFIERS.find do |identify|
      !@keyblock.include?(identify)
    end
  end

end
