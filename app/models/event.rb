class Event < ActiveRecord::Base  
  has_many :replays
  
  validates_length_of :name, :in => 3..50
  validates_uniqueness_of :name
end