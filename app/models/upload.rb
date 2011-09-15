class Upload < ActiveRecord::Base  
  belongs_to :user
  
  belongs_to :uploadable, :polymorphic => true
  
  def anonymous?
    user.nil?
  end
end