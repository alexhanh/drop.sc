class Player < ActiveRecord::Base
  # LEAGUE_TYPES = %w[bronze silver gold platinum diamond master grandmaster]
  
  BNET_STATUS_NOT_UPDATED   = 0
  BNET_STATUS_OK            = 1
  BNET_STATUS_NAME_CHANGED  = 2
  
  has_many :plays
  has_many :replays, :through => :plays
  
  def bnet_url
    return "http://www.battlenet.com.cn/sc2/zh/profile/#{bnet_id}/1/#{name}/" if region == "CN"
    return "http://sea.battle.net/sc2/en/profile/#{bnet_id}/#{sub_region}/#{name}/" if region == "SEA"
    return "http://tw.battle.net/sc2/zh/profile/#{bnet_id}/#{sub_region}/#{name}/" if region == "TW"
    return "http://kr.battle.net/sc2/ko/profile/#{bnet_id}/#{sub_region}/#{name}/" if region == "KR"
    "http://#{gateway.downcase}.battle.net/sc2/en/profile/#{bnet_id}/#{sub_region}/#{name}/"
  end
  
  def sc2ranks_url
    "http://sc2ranks.com/#{region.downcase}/#{bnet_id}/#{name}"
  end
  
  def bnet_updated?
    self.crawl_status != BNET_STATUS_NOT_UPDATED
  end
  
  def bnet_name_changed?
    self.crawl_status == BNET_STATUS_NAME_CHANGED
  end
  
  def ranked_1v1?
    !league_1v1.blank?
  end
  
  def has_aliases?
    aliases.count(",") > 1
  end
  
  def autocomplete_string
    league = "-"
    league = league_1v1 if ranked_1v1?
    "#{name} #{gateway}, #{league}"
  end
end