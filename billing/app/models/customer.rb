class Customer < CouchRest::Model::Base

  FIELDS = [:first_name, :last_name, :phone, :website, :company, :fax, :addresses, :credit_cards, :custom_fields]
  attr_accessor *FIELDS

  use_database "customers"
  belongs_to :user
  belongs_to :braintree_customer

  # Braintree::Customer - stored on braintrees servers - we only have the id.
  def braintree_customer
    @braintree_customer ||= Braintree::Customer.find(braintree_customer_id)
  end

  validates :user, presence: true

  design do
    view :by_user_id
    view :by_braintree_customer_id
  end

  def has_payment_info?
    !!braintree_customer_id
  end

  # from braintree_ruby_examples/rails3_tr_devise and should be tweaked
  def with_braintree_data!
    return self unless has_payment_info?

    FIELDS.each do |field|
      send(:"#{field}=", braintree_customer.send(field))
    end
    self
  end

  def default_credit_card
    return unless has_payment_info?

    credit_cards.find { |cc| cc.default? }
  end

  # based on 2nd parameter, either returns the single active subscription (or nil if there isn't one), or an array of all subsciptions
  def subscriptions(braintree_data=nil, only_active=true)
    self.with_braintree_data!
    return unless has_payment_info?

    subscriptions = []
    self.default_credit_card.subscriptions.each do |sub|
      if only_active and sub.status == 'Active'
        return sub
      else
        subscriptions << sub
      end
    end
    only_active ? nil : subscriptions
  end

end
