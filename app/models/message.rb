class Message < ActiveRecord::Base
  TO_ALL = 0
  TO_ALLIES = 2
  
  belongs_to :replay
  
  def to_all?
    self.target == TO_ALL
  end
  
  def to_allies?
    self.target == TO_ALLIES
  end
end