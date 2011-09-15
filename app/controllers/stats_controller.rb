class StatsController < ApplicationController
  def stats
    r = Comment.find_by_sql(["SELECT COUNT(*) as plays, p.chosen_race as race, p.won as won, r.game_format as game_format FROM plays p, replays r WHERE p.replay_id = r.id AND r.is_public = ? AND r.winner_known = ? GROUP BY r.game_format, p.chosen_race, p.won ORDER BY r.game_format, p.chosen_race", true, true])
    
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
  end
end