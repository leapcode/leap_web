require 'test_helper'

class TicketTest < ActiveSupport::TestCase
  #test "the truth" do
  #  assert true
  #end

  setup do
    @sample = Ticket.new
  end

  test "validity" do
    t = Ticket.create :title => 'test title', :email => 'blah@blah.com'
    assert t.valid?
    assert_equal t.title, 'test title'

    #user = LeapWebHelp::User.new(User.valid_attributes_hash)
    #user = LeapWebUsers::User.create

    #t.user = user
    
    #t.email = '' #invalid
    #assert !t.valid?
    #t.email = 'blah@blah.com, bb@jjj.org'
    #assert t.valid?
    t.email = 'bdlfjlkasfjklasjf' #invalid
    #p t.email_address
    #p t.email_address.strip =~ RFC822::EmailAddress
    assert !t.valid?
  end

  test "creation validated" do
    assert !@sample.is_creator_validated?
    #p current_user
    @sample.created_by = 22 #current_user
    assert @sample.is_creator_validated?
  end
  
  test "code if & only if not creator-validated" do
    t1 = Ticket.create :title => 'test title'
    assert_not_nil t1.code
    assert_nil t1.created_by

    t2 = Ticket.create :title => 'test title', :created_by => 4
    assert_nil t2.code
    assert_not_nil t2.created_by
    

  end

end


