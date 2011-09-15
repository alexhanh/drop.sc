class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  belongs_to :user
  
  validates_length_of :text, :minimum => 1, :maximum => 2000
end