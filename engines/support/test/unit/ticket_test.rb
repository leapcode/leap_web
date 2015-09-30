require 'test_helper'

class TicketTest < ActiveSupport::TestCase

  setup do
    InviteCodeValidator.any_instance.stubs(:validate)
  end

  test "ticket with default attribs is valid" do
    t = FactoryGirl.build :ticket
    assert t.valid?
  end

  test "ticket without email is valid" do
    t = FactoryGirl.build :ticket, email: ""
    assert t.valid?
  end

  test "ticket validates email format" do
    t = FactoryGirl.build :ticket, email: "invalid email"
    assert !t.valid?
  end

  test "ticket open states" do
    t = FactoryGirl.build :ticket
    assert t.is_open
    t.close
    assert !t.is_open
    t.reopen
    assert t.is_open
  end

  test "creation validated" do
    user = FactoryGirl.create :user
    @sample = Ticket.new
    assert !@sample.is_creator_validated?
    @sample.created_by = user.id
    assert @sample.is_creator_validated?
  end

  test "destroy all tickets from a user" do
    t = FactoryGirl.create :ticket_with_creator
    u = t.created_by_user
    Ticket.destroy_all_from(u)
    assert_equal nil, Ticket.find(t.id)
  end
=begin
# TODO: do once have current_user stuff in order
  test "code if & only if not creator-validated" do
    User.current_test = nil
    t1 = Ticket.create :subject => 'test title'
    assert_not_nil t1.code
    assert_nil t1.created_by

    User.current_test = 4
    t2 = Ticket.create :subject => 'test title'
    assert_nil t2.code
    assert_not_nil t2.created_by
  end
=end


  test "find tickets user commented on" do

    # clear old tickets just in case
    # this will cause RestClient::ResourceNotFound errors if there are multiple copies of the same ticket returned
    Ticket.by_includes_post_by.key('123').each {|t| t.destroy}
    # TODO: the by_includes_post_by view is only used for tests. Maybe we should get rid of it and change the test to including ordering?


    testticket = Ticket.create :subject => "test retrieving commented tickets"
    comment = TicketComment.new :body => "my email broke", :posted_by => "123"
    assert_equal 0, testticket.comments.count
    assert_equal [], Ticket.by_includes_post_by.key('123').all

    testticket.comments << comment
    testticket.save
    assert_equal 1, testticket.reload.comments.count
    assert_equal [testticket], Ticket.by_includes_post_by.key('123').all

    comment = TicketComment.new :body => "another comment", :posted_by => "123"
    testticket.comments << comment
    testticket.save

    # this will ensure that the ticket is only included once, even though the user has commented on the ticket twice:
    assert_equal [testticket], Ticket.by_includes_post_by.key('123').all

    testticket.destroy
    assert_equal [], Ticket.by_includes_post_by.key('123').all;
  end

end
