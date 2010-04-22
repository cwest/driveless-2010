class Message < ActiveRecord::Base

  attr_accessor :recipient

  belongs_to :sender,
             :class_name => "User",
             :foreign_key => "sender_id"

  belongs_to :receiver,
             :class_name => "User",
             :foreign_key => "receiver_id"

  validates_presence_of :recipient,
                        :subject,
                        :body

  validates_length_of :body,
                      :minimum => 1,
                      :message => "is too short.  The mimum length is %d characters. Please don't spam."

  validates_length_of :body,
                      :maximum => 1000,
                      :message => "is too long.  No one wants to read that.  The maximum length is %d characters."

  # Returns user.username for the sender
  def sender_name
    User.find(sender_id).username || ""
  end
  
  # Returns user.username for the receiver
  def receiver_name
    User.find(receiver_id).username || ""
  end
  
  def mark_message_read(user)
    if user.id == self.receiver_id
      self.read_at = Time.now
      self.save false
    end
  end
  
  # Performs a hard delete of a message.  Should only be called from destroy
  def purge
    if self.sender_purged && self.receiver_purged
      self.destroy
    end
  end
  
  # Assigns the recipient to the receiver_id.
  # I'm sure there is a better way.  Please let me know.
  def before_create
    u = User.find_by_username(recipient)
    self.receiver_id = u.id
  end
  
  # Validates that a user has entered a valid user.username name for the message recipient
  def validate_on_create
    u = User.find_by_username(recipient)
    errors.add(:recipient, "is not a valid user.") if u.nil?
  end        
end
