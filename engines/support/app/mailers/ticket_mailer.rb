class TicketMailer < ActionMailer::Base

  helper :ticket_i18n

  def self.send_notice(ticket, comment, url)
    reply_recipients(ticket, comment.user).each do |email, key|
      TicketMailer.notice(ticket, comment, url, email, key).deliver
    end
  end

  #
  # ticket - the ticket in question
  # author - user who created last comment
  # url - url of the ticket
  # email - email to send reply notice to
  # key - public key for email
  #
  # TODO: OpenPGP encrypt email to the public key.
  #
  def notice(ticket, comment, url, email, key)
    @url = url
    @email = email
    @key = key
    mail({
      :reply_to  => reply_to_address,
      :subject   => "Re: [#{ticket.id}] #{ticket.subject}",
      :to        => email,
      :from      => from_address(ticket, comment)
    })
  end

  private

  #
  # I am not sure what makes the most sense here. For now, since we do not
  # include any reply text in the notification email, it makes sense to make
  # the from address be the robot, not the user.
  #
  def from_address(ticket, comment)
    if true
      reply_to_address
    else
      from_name = if comment.user.present?
        comment.user.login
      elsif ticket.created_by.present?
        ticket.created_by_user.login
      else
        I18n.t(:anonymous)
      end
      "%s <%s>" % [from_name, reply_to_address]
    end
  end

  # TODO: change me to support virtual domains
  def reply_to_address
    [APP_CONFIG[:mailer][:from_address], APP_CONFIG[:domain]].join('@')
  end

  #
  # returns a hash of {'email' => 'public key'}, where key might be nil.
  #
  def self.reply_recipients(ticket, author)
    recipients = {}
    ticket.comments.each do |comment|
      user = comment.posted_by_user
      if user && (author.nil? || user.id != author.id)
        if user.email
          recipients[user.identity.address] = (user.identity.keys[:pgp] if user.identity.keys[:pgp].present?)
        end
        if user.contact_email.present?
          recipients[user.contact_email] = (user.contact_email_key if user.contact_email_key.present?)
        end
      end
    end
    if author && author.is_admin? && ticket.email.present?
      recipients[ticket.email] = nil
    end
    logger.info { "emailing reply regarding ticket #{ticket.id} to #{recipients.keys.join(', ')}" }
    recipients
  end

end
