module StatsHelper
  def winrate(wins, plays)
    return "0%" if plays == 0
    
    (wins/plays.to_f*100).round.to_s + "%"
  end
end