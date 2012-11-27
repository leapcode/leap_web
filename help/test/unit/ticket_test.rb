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

    assert t.is_open
    t.close
    assert !t.is_open
    t.reopen
    assert t.is_open
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

=begin
# TODO: do once have current_user stuff in order
  test "code if & only if not creator-validated" do
    User.current_test = nil
    t1 = Ticket.create :title => 'test title'
    assert_not_nil t1.code
    assert_nil t1.created_by

    User.current_test = 4
    t2 = Ticket.create :title => 'test title'
    assert_nil t2.code
    assert_not_nil t2.created_by
  end
=end

  test "finds open tickets sorted by created_at" do
    tickets = Ticket.by_is_open_and_created_at.
      startkey([true, 0]).
      endkey([true, Time.now])
    assert_equal Ticket.by_is_open.key(true).count, tickets.count
  end

  test "find tickets user commented on" do
    # clear old tickets just in case
    Ticket.by_commented_by.key('123').each {|t| t.destroy}

    testticket = Ticket.create :title => "test retrieving commented tickets"
    comment = TicketComment.new :body => "my email broke", :posted_by => "123"
    assert_equal 0, testticket.comments.count
    assert_equal [], Ticket.by_commented_by.key('123').all;

    testticket.comments << comment
    testticket.save
    assert_equal 1, testticket.reload.comments.count
    assert_equal [testticket], Ticket.by_commented_by.key('123').all;

    testticket.destroy
    assert_equal [], Ticket.by_commented_by.key('123').all;
  end

end
