require 'test_helper'

class TicketCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

=begin
  setup do
    @sample_ticket = Ticket.create :title => 'test ticket'
    @sample_ticket.save
  end
=end

  test "create" do

    comment2 = TicketComment.new :body => "help my email is broken!"
    assert comment2.valid?
    #assert_not_nil comment2.posted_at #?
    #assert_nil comment2.posted_by #if not logged in #TODO

    #comment.ticket = testticket #Ticket.find_by_title("testing")
    #assert_equal testticket.title, comment.ticket.title

    #tc.ticket = Ticket.find_by_title("test title")
    #tc.ticket.title
  end

=begin
  test "create authenticated comment" do
    User.current = 4
    comment2 = TicketComment.new :body => "help my email is broken!"
    comment2.valid? #save # should not save comment
    assert_not_nil comment2.posted_by
  end
=end

  test "add comments" do
    testticket = Ticket.create :title => "testing"
    assert_equal testticket.comments.count, 0
    comment = TicketComment.new :body => "my email broke"
    #assert comment.valid? #validating or saving necessary for setting posted_at
    #assert_not_nil comment.posted_at

    testticket.comments << comment
    assert_equal testticket.comments.count, 1
    sleep(1) # so first comment has earlier posted_at time
    comment2 = TicketComment.new :body => "my email broke"
    testticket.comments << comment2 #this should validate comment2
    testticket.valid?
    assert_equal testticket.comments.count, 2
    testticket.reload.destroy
    # where should posted_at be set?
    #assert_not_nil comment.posted_at
    #assert_not_nil testticket.comments.last.posted_at
    #assert testticket.comments.first.posted_at < testticket.comments.last.posted_at
  end

end
