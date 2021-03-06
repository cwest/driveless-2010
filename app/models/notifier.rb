class Notifier < ActionMailer::Base
  @host = "my.drivelesschallenge.com"
  default_url_options[:host] = @host

  def password_reset_instructions(user)
    subject       "Password Reset for Driveless "
    from          "Driveless Challenge <noreply@#{@host}>"
    recipients    user.email
    sent_on       Time.now
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def friendship_notification(user, friend)
    subject       "#{user.username} added you as a friend"
    from          "Driveless Challange <noreply@#{@host}>"
    recipients    friend.email
    sent_on       Time.now
    body          :friend_username => user.username, :friend_url => user_url( user )
  end

  def join_invitation( user, invitation )
    subject       "You're invited to Drive Less by #{user.username}"
    from          "Driveless Challange <noreply@#{@host}>"
    recipients    invitation[:email]
    sent_on       Time.now
    body          :invited => invitation[:name], :user => user.username, :body => invitation[:invitation]
  end

end
