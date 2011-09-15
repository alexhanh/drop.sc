module ReplaysHelper
  def teams(replay)
    teams = Hash.new
    replay.plays.each do |play|
      if teams.has_key?(play.team)
        teams[play.team] << play
      else
        teams[play.team] = [play]
      end
    end
    teams
  end
  
  def ladder_info(player)
    s = ""
    if player.bnet_name_changed?
      s = "Player has changed name."
    elsif player.bnet_updated?
      s += "1v1: " + league_string(player.league_1v1)
      s += " ##{player.rank_1v1}" if player.ranked_1v1?
    else
      s = "Not yet updated."
    end
    s
  end
  
  def play_html(play, show_apm = false)
    apm = ""
    klass = "player-tip"
    if show_apm && play.human?
      klass = "player-tip-apm"
      apm = "<br>Match APM: <span class='apm-string'>#{play.avg_apm}</span><br>Avg APM: <span class='apm-string'>#{Play.where(:player_id => play.player_id).average("avg_apm").to_i}</span>"
    end
    if play.human?
      return "<a href=\"#{show_player_slug_url(:bnet_id => play.player.bnet_id, :region => play.player.region, :name => play.player.name)}\" title=\"#{play.player.name} - #{ladder_info(play.player)}#{apm}\" class=\"#{klass}\">" + pretty_player_name(play) + "</a> " + race_string(play)
    end
    "Computer (#{play.difficulty})"
  end
  
  def versus_html(replay)
    s = ""
    teams(replay).each do |team, plays|
      plays.each do |play|
        s += play_html(play) + " "
      end
      s = s[0..s.length-1] + ' <span class="vs">vs</span> '
    end
    s[0..s.length-28]
  end
  
  def versus_plain(replay)
    s = ""
    teams(replay).each do |team, plays|
      plays.each do |play|
        s += (play.human? ? play.player.name : "Computer" ) + " "
      end
      s = s[0..s.length-2] + ' vs '
    end
    s[0..s.length-5]
  end
  
  def player_list(replay, separator=", ")
    s = ""
    for player in replay.players
      s += player.name + separator
    end
    s = s[0..s.length-separator.length-1] if s.length > 0
    s
  end
  
  def versus_embed(replay)
    s = ""
    teams(replay).each do |team, plays|
      plays.each do |play|
        s += "<a href=\"#{player_url([play.player])}\">" + pretty_player_name(play) + "</a> " + race_string(play) + " "
      end
      s = s[0..s.length-2] + ' <span class="vs">vs</span> '
    end
    s[0..s.length-28]
  end
  
  def chat_msg_string(msg)
    s = format_timestamp(msg.time/1000) + " "
    if msg.to_all?
      s += "[All]"
    elsif msg.to_allies?
      s += "[Allies]"
    else
    end
    
    s += " " + msg.sender + ": " + msg.msg
  end
  
  # Uses in-game colors to highlight player names
  def chat_msg_string_pretty(msg, plays)
    s = format_timestamp(msg.time/1000) + " "
    if msg.to_all?
      s += "[All]"
    elsif msg.to_allies?
      s += "[Allies]"
    else
    end
    
    # color = '4F4F4F'
    color = dampen_color(msg.sender_color)
    s += ' <span style="color: ' + color + ';">' + msg.sender + "</span>: " + msg.msg
  end
  
  def pretty_player_name(play)
    color = dampen_color(play.color)
    color = "#06C" if user_signed_in? && !current_user.use_colors
    
    '<span style="color: ' + color + ';">' + play.player.name + "</span>"
  end
  
  def race_string(play)
    play.chose_random? ? play.chosen_race + play.race : play.race;
  end
  
  def winner?(team_plays)
    team_plays.any? { |play| play.won == true }
  end
  
  def chart_colors(plays)
    @colors = ""
    for play in plays
      @colors += "'##{dampen_color(play.color)}',"
    end
    @colors.chop
  end
  
  def version_live(replay)
    if replay.live?
      replay.version + ' <span class="live-version">LIVE</span>'
    else
      replay.version
    end
  end
  
  def get_version_options(selected)
    s = [["All versions", ""]]
    # TODO: add state column to make Transitions happy, should remove in future or make raw sql query instead
    # for r in Replay.public.select("DISTINCT(replays.release_string), state").order("replays.release_string DESC")
    #   #s += "<option>#{r.release_string}</option>"
    #   s << [r.release_string, r.release_string] unless r.release_string.blank?
    # end
    Replay::VERSIONS.each do |version|
      s << [version, version]
    end
    
    options_for_select(s, selected)
  end
  
  def map_options(selected)
    s = [["All maps", ""]]
    for r in Replay.public.processed.select("DISTINCT(replays.map_name)").order("replays.map_name")
      s << [r.map_name, r.map_name] unless r.map_name.blank?
    end
    options_for_select(s, selected)
  end
  
  def game_format_options(selected)
    s = [["All format", ""]]
    s << ["1v1", "1v1"]
    s << ["2v2", "2v2"]
    s << ["3v3", "3v3"]
    s << ["4v4", "4v4"]
    s << ["FFA", "FFA"]
    options_for_select(s, selected)
  end
  
  def long_race(r)
    dr = r.downcase
    return "Terran"   if dr == "t"
    return "Zerg"     if dr == "z"
    return "Protoss"  if dr == "p"
    return "Random"   if dr == "r"
    return ""
  end
  
  # def replays_order_link(by_param, by_name)
  #   path = search_replays_path(:order => by_param, :map => params[:map], :mu => params[:mu], :version => params[:version], :region => params[:region], :game_type => params[:game_type])
  #   link_to_unless(params[:order] == by_param, by_name, path) do
  #     content_tag(:span, by_name, :class => "selected")
  #   end
  # end
  
  def replays_order_link(by_param, by_name)
    path = search_replays_path(:order => by_param, :map => params[:map], :mu => params[:mu], :version => params[:version], :gateway => params[:gateway], :game_format => params[:game_format], :player => params[:player], :league => params[:league])
    link_to_unless(params[:order] == by_param, by_name, path, :title => "Order by #{by_name}") do
      link_to by_name, path, :class=>"youarehere", :title => "Order by #{by_name}"
    end
  end
  
  def popular_link(param, name, set)
    path = popular_path(set)
    link_to_unless(param, name, path) do
      link_to name, path, :class=>"youarehere"
    end
  end
  
  def matchup(replay)
    return "PvP" if replay.protosses == 2
    return "TvT" if replay.terrans == 2
    return "ZvZ" if replay.zergs == 2
    return "PvT" if replay.protosses == 1 && replay.terrans == 1
    return "PvZ" if replay.protosses == 1 && replay.zergs == 1
    return "TvZ" if replay.terrans == 1 && replay.zergs == 1
    
    return ""
  end
  
  def replay_title(replay)
    if replay.success?
      mu = ""
      mu = " " + matchup(replay) if replay.is_1v1?
      
      replay.game_format + " " + versus_plain(replay) + mu
    else
      "Replay " + replay.id.to_s
    end
  end
  
  def replay_description(replay)
    if replay.success?
      # matchup
      # when played
      # realm

      "Format: #{replay.game_format}, Players: #{player_list(replay, " ")}, Map: #{replay.map_name}, Gateway: #{replay.gateway}, Played at: #{l(replay.saved_at)}"
    else
      return "Download replay #{replay.id.to_s} here. It's still being analyzed."
    end
  end
  
  def popular_title(today, week, month, year, all_time)
    s = "Most popular replays "
    return s + "today" if today
    return s + "this week" if week
    return s + "this month" if month
    return s + "this year" if year
    return s + "all time" if all_time
  end
  
  def replay_cut_description(text)
    return "" if text.blank?
    return '"' + text[0..100] + '"...' if text.length > 100
    '"' + text + '"'
  end
  
  def source_link(replay)
    return "" if replay.description.blank?
    return " via " + link_to("Sc2gears", "http://sites.google.com/site/sc2gears/", :target => "_blank")
  end
end
