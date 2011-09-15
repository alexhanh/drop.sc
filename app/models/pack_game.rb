class PackGame < ActiveRecord::Base  
  belongs_to :pack
  belongs_to :replay
end