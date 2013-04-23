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
=begin
  def with_braintree_data!
    return self unless has_payment_info?
    braintree_data = Braintree::Customer.find(braintree_customer_id)

    #FIELDS.each do |field|
    #  send(:"#{field}=", braintree_data.send(field))
    #end
    self
  end
=end

  #slow to get Braintree Customer data, so pass it if have already retrieved it
  # won't really have multiple credit cards on file
  def default_credit_card(braintree_data = nil)
    return unless has_payment_info?
    braintree_data = braintree_data || Braintree::Customer.find(braintree_customer_id)
    braintree_data.credit_cards.find { |cc| cc.default? }
  end

  #todo will this be plural?
  def active_subscriptions(braintree_data=nil)
    subscriptions = Array.new
    braintree_data = braintree_data || Braintree::Customer.find(braintree_customer_id)
    braintree_data.credit_cards.each do |cc|
      cc.subscriptions.each do |sub|
        subscriptions << sub if sub.status == 'Active'
      end
    end
    subscriptions
  end

  def single_subscription(braintree_data=nil)
    self.active_subscriptions(braintree_data).first
  end



end
