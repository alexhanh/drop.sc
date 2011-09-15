class PlayersController < ApplicationController
  autocomplete :player, :name, :full => true, :extra_data => [:league_1v1, :gateway], :display_value => :autocomplete_string
  
  def index
    q = Player.where("name ILIKE ?", "%#{params[:player_name]}%")
    q = q.where("gateway = ?", params[:gateway]) unless params[:gateway].blank?
    q = q.where("league_1v1 = ?", params[:league]) unless params[:league].blank?
    
    @players = q.order(:name).paginate(:per_page => 10, :page => params[:page])
  end
  
  def show
    player = Player.find(params[:id])
    redirect_to show_player_slug_url(:bnet_id => player.bnet_id, :region => player.region, :name => player.name), :status => 301
  end
  
  def show_slug
    @player = Player.where(:bnet_id => params[:bnet_id], :region => params[:region]).first
    # TODO: if player is nil?

    r = Comment.find_by_sql(["SELECT COUNT(*) as plays, p.chosen_race as race FROM plays p, replays r WHERE p.player_id = ? AND p.replay_id = r.id AND r.is_public = ? GROUP BY p.chosen_race", @player.id, true])
    @plays = { 'Z' => 0, 'T' => 0, 'P' => 0, 'R' => 0 }
    for result in r do
      @plays[result.race] += result.plays.to_i
    end
    
    @total_plays = @plays.inject(0) {|sum, race| sum + race[1]}
    @avg_apm = Comment.find_by_sql(["SELECT AVG(p.avg_apm) AS avg FROM plays p, replays r WHERE p.player_id = ? AND p.replay_id = r.id AND r.is_public = ?", @player.id, true])[0].avg#Play.where(:player_id => params[:id]).average("avg_apm")
    @avg_apm_1v1 = Comment.find_by_sql(["SELECT AVG(p.avg_apm) AS avg FROM plays p, replays r WHERE p.player_id = ? AND p.replay_id = r.id AND r.is_public = ? AND r.game_format = '1v1'", @player.id, true])[0].avg
    
    @most_played_race = @plays.key(@plays.values.max)
    
    r = Comment.find_by_sql(["SELECT COUNT(*) as plays, r.map_name as map, p.won as won, r.game_format as game_format FROM plays p, replays r WHERE p.player_id = ? AND p.replay_id = r.id AND r.is_public = ? AND r.winner_known = ? GROUP BY r.game_format, r.map_name, p.won ORDER BY r.game_format, r.map_name", @player.id, true, true])
    
    @maps = {}
    for result in r do
      format = @maps[result.game_format]
      if format.blank?
        @maps[result.game_format] = {}
        format = @maps[result.game_format]
      end
      
      m = format[result.map]
      if m.blank?
        format[result.map] = { :wins => 0, :losses => 0, :total => 0 }
        m = format[result.map]
      end
      
      plays = result.plays.to_i
      if result.won == "t"
        m[:wins] += plays
      else
        m[:losses] += plays
      end
      
      m[:total] += plays
    end
    
    r = Comment.find_by_sql(["SELECT COUNT(*) as plays, p.chosen_race as race, p.won as won, r.game_format as game_format FROM plays p, replays r WHERE p.player_id = ? AND p.replay_id = r.id AND r.is_public = ? AND r.winner_known = ? GROUP BY r.game_format, p.chosen_race, p.won ORDER BY p.chosen_race", @player.id, true, true])
    

    @races = {}
    for result in r do
      format = @races[result.game_format]
      if format.blank?
        @races[result.game_format] = {}
        format = @races[result.game_format]
      end
      
      race = format[result.race]
      if race.blank?
        format[result.race] = { :wins => 0, :losses => 0, :total => 0}
        race = format[result.race]
      end
      
      plays = result.plays.to_i
      if result.won == "t"
        race[:wins] += plays
      else
        race[:losses] += plays
      end
      
      race[:total] += plays
    end
    
    render "show"
  end
end
