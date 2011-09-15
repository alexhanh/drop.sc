class ProfileCrawler
  @queue = :low
  
  def self.perform(count)
    for player in Player.where("gateway != 'XX'").order("crawled_at").limit(count)
      p "Updating #{player.name}"
      
      scraper = Starscraper.new(player.bnet_url)

      data = scraper.read

      if (data.nil?) # silently stop if connection wasnt established or something else went wrong
        p ""
      elsif (data['name_changed'])
        player.crawl_status = Player::BNET_STATUS_NAME_CHANGED
      else
        is_ranked = data['1v1_league_type'] != -1
        player.league_1v1 = is_ranked ? data['1v1_league_type'] : ""
        player.rank_1v1 = is_ranked ? data['1v1_rank'] : -1

        player.crawl_status = Player::BNET_STATUS_OK
      end

      player.crawled_at = Time.current

      player.save!
    end
  end
end