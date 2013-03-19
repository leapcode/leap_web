class Customer < CouchRest::Model::Base

  #FIELDS = [:first_name, :last_name, :phone, :website, :company, :fax, :addresses, :credit_cards, :custom_fields]

  use_database "customers"
  belongs_to :user
  property :braintree_customer_id
  
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
    braintree_data = Braintree::Customer.find(braintree_customer_id)

    debugger
    #FIELDS.each do |field|
    #  send(:"#{field}=", braintree_data.send(field))
    #end
    self
  end

  ##??
  def default_credit_card
    return unless has_payment_info?

    credit_cards.find { |cc| cc.default? }
  end


end
