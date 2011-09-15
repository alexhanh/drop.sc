class NewsPost < ActiveRecord::Base
  act_as_commentable
  
  validates_length_of :title, :in => 1..500
  validates_length_of :author, :in => 1..20
  validates_length_of :body, :in => 1..2000
end