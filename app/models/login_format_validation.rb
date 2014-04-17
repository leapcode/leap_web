module LoginFormatValidation
  extend ActiveSupport::Concern

  #TODO: Probably will replace this. Playing with using it for aliases too, but won't want it connected to login field.

  included do
    # Have multiple regular expression validations so we can get specific error messages:
    validates :login,
      :format => { :with => /\A.{2,}\z/,
        :message => "Must have at least two characters"}
    validates :login,
      :format => { :with => /\A[a-z\d_\.-]+\z/,
        :message => "Only lowercase letters, digits, . - and _ allowed."}
    validates :login,
      :format => { :with => /\A[a-z].*\z/,
        :message => "Must begin with a lowercase letter"}
    validates :login,
      :format => { :with => /\A.*[a-z\d]\z/,
        :message => "Must end with a letter or digit"}
  end
end
