module LoginFormatValidation
  extend ActiveSupport::Concern

  included do
    # Have multiple regular expression validations so we can get specific error messages:
    validates :login,
      :format => { :with => /\A.{2,}\z/,
        :message => "Login must have at least two characters"}
    validates :login,
      :format => { :with => /\A[a-z\d_\.-]+\z/,
        :message => "Only lowercase letters, digits, . - and _ allowed."}
    validates :login,
      :format => { :with => /\A[a-z].*\z/,
        :message => "Login must begin with a lowercase letter"}
    validates :login,
      :format => { :with => /\A.*[a-z\d]\z/,
        :message => "Login must end with a letter or digit"}
  end
end
