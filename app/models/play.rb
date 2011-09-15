class Play < ActiveRecord::Base
  belongs_to :replay
  belongs_to :player
  
  def chose_random?
    chosen_race == "R"
  end
  
  def computer?
    player_type == "Computer"
  end
  
  def human?
    player_type == "Human"
  end
end