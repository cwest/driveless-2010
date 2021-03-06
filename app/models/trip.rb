class Trip < ActiveRecord::Base
  belongs_to :user
  belongs_to :destination
  belongs_to :mode
  belongs_to :unit

  attr_accessible :user_id, :destination_id, :mode_id, :unit_id, :distance, :made_at
  validates_presence_of :destination, :mode, :unit, :distance
  validates_numericality_of :distance, :greater_than_or_equal_to => 0

  after_save :update_green_miles
  after_destroy :update_green_miles

  named_scope :not_green, :joins => :mode, :conditions => {:"modes.green" => false}
  named_scope :only_green, :joins => :mode, :conditions => {:"modes.green" => true}
  named_scope :made_since, lambda { |date| {:conditions => ['trips.made_at >= ?', date.to_date]} }
  named_scope :summed_by_mode_and_date,
    :select => 'modes.name AS mode_name, trips.made_at, sum(trips.distance) AS distance_sum',
    :joins => :mode,
    :group => 'modes.name, trips.made_at'

  def to_tweet
    "I decided to %s for %0.2f %s on %s and saved %0.2f\lbs of co2 for the @driveless challenge! http://xrl.us/mdlc" % [
      mode.name.downcase,
      distance,
      (distance == 1 ? "mile" : "mile".pluralize()),
      made_at.strftime("%B %d"),
      distance * mode.lb_co2_per_mile
    ]
  end

  private

  def update_green_miles
    user.update_green_miles
  end
  
  def self.graphicable_since(date)
    only_green.made_since(date).summed_by_mode_and_date
  end
end
