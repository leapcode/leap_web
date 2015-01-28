#
# Model for certificates
#
# This file must be loaded after Config has been loaded.
#
require 'base64'
require 'digest/md5'
require 'openssl'
require 'certificate_authority'
require 'date'

class ClientCertificate

  attr_accessor :key                          # the client private RSA key
  attr_accessor :cert                         # the client x509 certificate, signed by the CA

  #
  # generate the private key and client certificate
  #
  def initialize(options = {})
    cert = CertificateAuthority::Certificate.new

    # set subject
    cert.subject.common_name = common_name(options[:prefix])

    # set expiration
    cert.not_before = last_month
    cert.not_after = expiry

    # generate key
    cert.serial_number.number = cert_serial_number
    cert.key_material.generate_key(APP_CONFIG[:client_cert_bit_size])

    # sign
    cert.parent = ClientCertificate.root_ca
    cert.sign! client_signing_profile

    self.key = cert.key_material.private_key
    self.cert = cert
  end

  def to_s
    self.key.to_pem + self.cert.to_pem
  end

  def fingerprint
    OpenSSL::Digest::SHA1.hexdigest(openssl_cert.to_der).scan(/../).join(':')
  end

  def expiry
    @expiry ||= lifespan
  end

  private

  def openssl_cert
    cert.openssl_body
  end

  def self.root_ca
    @root_ca ||= begin
                   crt = File.read(APP_CONFIG[:client_ca_cert])
                   key = File.read(APP_CONFIG[:client_ca_key])
                   openssl_cert = OpenSSL::X509::Certificate.new(crt)
                   cert = CertificateAuthority::Certificate.from_openssl(openssl_cert)
                   cert.key_material.private_key = OpenSSL::PKey::RSA.new(key, APP_CONFIG[:ca_key_password])
                   cert
                 end
  end

  #
  # For cert serial numbers, we need a non-colliding number less than 160 bits.
  # md5 will do nicely, since there is no need for a secure hash, just a short one.
  # (md5 is 128 bits)
  #
  def cert_serial_number
    Digest::MD5.hexdigest("#{rand(10**10)} -- #{Time.now}").to_i(16)
  end

  def common_name(prefix = nil)
    [prefix, random_common_name].join
  end

  #
  # for the random common name, we need a text string that will be unique across all certs.
  # ruby 1.8 doesn't have a built-in uuid generator, or we would use SecureRandom.uuid
  #
  def random_common_name
    cert_serial_number.to_s(36)
  end

  def client_signing_profile
    {
      "digest" => APP_CONFIG[:client_cert_hash],
      "extensions" => {
        "keyUsage" => {
          "usage" => ["digitalSignature"]
        },
        "extendedKeyUsage" => {
          "usage" => ["clientAuth"]
        }
      }
    }
  end

  #
  # TIME HELPERS
  #
  # We normalize timestamps at utc and midnight
  # to reduce the fingerprinting possibilities.
  #
  def last_month
    1.month.ago.utc.at_midnight
  end

  def lifespan
    number, unit = APP_CONFIG[:client_cert_lifespan].split(' ')
    unit ||= :months
    Time.now.utc.at_midnight.advance(unit.to_sym => number.to_i)
  end

end
