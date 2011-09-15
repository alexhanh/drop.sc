module PlayersHelper
  # def league_type_string(league)
  #   return "Not yet ranked." if league.nil? || league == -1
  #   Player::LEAGUE_TYPES[league].capitalize
  # end
  def league_string(league)
    return "Not yet ranked." if league.blank?
    league
  end
  
  def gateway_options(selected)
    s = [["All gateways", ""], ["US", "US"], ["CN", "CN"], ["KR", "KR"], ["EU", "EU"], ["SG", "SG"], ["Public Test", "XX"]]
    options_for_select(s, selected)    
  end
  
  def region_options(selected)
    s = [["All regions", ""], ["US", "us"], ["LA", "la"], ["SEA", "sea"], ["CN", "cn"], ["KR", "kr"], ["TW", "tw"], ["EU", "eu"], ["RU", "ru"], ["Public Test", "xx"]]
    options_for_select(s, selected)
  end
  
  def league_options(selected)

    # for r in Player.select("DISTINCT(players.bnet_1v1_league_type)").order("players.bnet_1v1_league_type DESC")
    #   s << [league_type_string(r.bnet_1v1_league_type), r.bnet_1v1_league_type] if r.ranked_1v1?
    # end
    # Player::LEAGUE_TYPES.each_with_index do |league, index|
    #   s.insert(1, [league.capitalize, index])
    # end
    s = [["All leagues", ""], ["Grandmaster", "Grandmaster"], ["Master", "Master"], ["Diamond", "Diamond"], ["Platinum", "Platinum"], ["Gold", "Gold"], ["Silver", "Silver"], ["Bronze", "Bronze"]]
    options_for_select(s, selected)
  end
  
  def player_description(player)
    s = ""
    s = league_string(player.league_1v1) + " " if player.ranked_1v1?
    s += "#{player.name}'s replays, statistics and resources."
  end
  
  def player_link(player)
    link_to player.name, show_player_slug_path(:bnet_id => player.bnet_id, :region => player.region, :name => player.name)
  end
end