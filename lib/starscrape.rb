#!/usr/bin/env ruby

require 'open-uri'
require 'rubygems'
require 'nokogiri'

class Starscraper

	def initialize(baseurl)
		@baseurl = baseurl
	end

	def read_page(url)
		open(url, "Cookie" => "int-SC2=1").read
	end

	def read_profile
		data = {}
		begin
      # doc = Nokogiri::HTML(read_page(URI.encode(@baseurl)))
      io = open(URI.encode(@baseurl), "Cookie" => "int-SC2=1")
      doc = Nokogiri::HTML(io)
      io.close!

      # handle HOTS promotion
      return nil if (doc.at_css("#intercept"))
        
      # page doesn't have profile data, stop here
      return nil if (doc.at_css("#profile-wrapper").nil?)

      # not ranked yet
      if (doc.at_css(".snapshot-empty"))
        data["1v1_league_type"] = -1
        data["2v2_league_type"] = -1
        data["3v3_league_type"] = -1
        data["4v4_league_type"] = -1
        return data
      end

      for league in 1..4
        best_team = doc.at_css('#best-team-' + league.to_s)
        current_rank = best_team.at_css('div:eq(2)')
        league_type = -1
        if current_rank
          league_type = best_team.parent.at_css('span:eq(1)')["class"].split(" ")[1].split("-")[1]
        end

        key = "#{league}v#{league}"
        
        data[key + "_league_type"] = -1 # not yet ranked

        next if league_type == -1
        
        data[key + "_league_type"] = league_type.capitalize

        tokens = current_rank.inner_html.split('<br>')
        data[key + "_rank"] = tokens[1].split('</strong>')[1].strip.to_i

      end
    rescue Errno::ETIMEDOUT
      return nil
    rescue Errno::ECONNREFUSED
      return nil
    rescue SocketError
      return nil
    rescue OpenURI::HTTPError => e
      return nil if e.io.status[0].to_s != "404"
      data['name_changed'] = true
    end

		data
	end

	def read
		read_profile
		#data['portraits'] = read_portraits
		#data['decals'] = read_decals
		#data['match_history'] = read_match_history
	end
end

# Kept this here because Starscraper was removed from Github :(

# class Starscraper
# 
#   def initialize(baseurl)
#     @baseurl = baseurl
#   end
# 
#   def read_page(url)
#     open(url, "Cookie" => "int-SC2=1").read
#   end
# 
#   def read_profile
#     data = {}
#     begin
#       doc = Nokogiri::HTML(read_page(URI.encode(@baseurl)))
# 
#       if (doc.at_css(".snapshot-empty"))
#         data["1v1_league_type"] = -1
#         data["2v2_league_type"] = -1
#         data["3v3_league_type"] = -1
#         data["4v4_league_type"] = -1
#         return data
#       end
# 
#       # Total Points
#       # data['points'] = doc.at('#profile-header').at('h3').inner_text.to_i
# 
#       # Snapshot
#       # snapshot = doc.at('#season-snapshot')
#       # 
#       # snapshot.search('tr').each_with_index do |row, i|
#       #   rank_datum = {}
#       #   rank_img_url = row.at('img')['src']
#       #   rank_datum['rank_color'], rank_datum['rank_level'] = rank_img_url.scan(/\/([^\/]+)\.png/)[0][0].split('-')
#       # 
#       #   rank_datum['total_games'] = row.at('.graph-bars.primary span').inner_text.split[0].to_i
#       #   rank_datum['won_games'] = row.at('.graph-bars.secondary span').inner_text.split[0].to_i
#       # 
#       #   data["#{i+1}v#{i+1}"] = rank_datum
#       # end
#       # 
#       # footer = snapshot.at('.module-footer')
#       # data['most_played_race'] = footer.inner_text.split[-1] if footer
# 
#       # Career Stats
#       # career_stats = doc.at_css('#career-stats')
# 
#       # data['league_wins'] = career_stats.at_css('.module-body h2').inner_text.to_i
#       # games = career_stats.at('ul').search('li').map {|li| li.inner_text.to_i}
#       # data['league_games'] = games[0]
#       # data['custom_games'] = games[1]
#       # data['coop_games'] = games[2]
#       # data['ffa_games'] = games[3]
# 
#       for league in 1..4
#         best_team = doc.at_css('#best-team-' + league.to_s)
#         current_rank = best_team.at_css('div:eq(2)')
#         league_type = -1
#         if current_rank
#           league_type = best_team.parent.at_css('span:eq(1)')["class"].split(" ")[1].split("-")[1]
#         end
# 
#         key = "#{league}v#{league}"
#         
#         data[key + "_league_type"] = -1 # not yet ranked
# 
#         next if league_type == -1
#         
#         data[key + "_league_type"] = Player::LEAGUE_TYPES.index(league_type)
# 
#         tokens = current_rank.inner_html.split('<br>')
#         data[key + "_rank"] = tokens[1].split('</strong>')[1].strip.to_i
#         # tokens = tokens[2].split('</strong>')[1].strip.split('-')
#         # data[key + "_wins"] = tokens[0].to_i
#         # data[key + "_losses"] = tokens[1].to_i
#       end
#     rescue Errno::ETIMEDOUT
#       return nil
#     rescue OpenURI::HTTPError
#       data['name_changed'] = true
#     end
# 
#     data
#   end
# 
# 
#   def read_rewards(url)
#     data = {'earned' => [], 'unearned' => []}
#     doc = Hpricot(read_page(url))
# 
#     doc.search('.reward-tile').each do |tile|
#       name = (tile.at('.tooltip-title') || tile.at('.reward-tooltip') || tile.at('.reward-name')).inner_text.strip
# 
#       ['earned', 'unearned'].each do |cl|
#         data[cl] << name if tile.classes.include?(cl)
#       end
#     end
# 
#     data
#   end
# 
#   def portraits_url
#     @baseurl + 'rewards/'
#   end
# 
#   def read_portraits
#     read_rewards(portraits_url)
#   end
# 
#   def decals_url(race)
#     @baseurl + "rewards/#{race}-decals"
#   end
# 
#   def read_decals(race=nil)
#     if race
#       read_rewards(decals_url(race))
#     else
#       data = {}
#       ['terran', 'protoss', 'zerg'].each do |race|
#         data[race] = read_rewards(decals_url(race))
#       end
#       data
#     end
#   end
# 
#   def match_history_url
#     @baseurl + 'matches'
#   end
# 
#   def read_match_history
#     doc = Hpricot(read_page(match_history_url)) 
# 
#     doc.search('tr.match-row').map do |row|
#       match = {}; tds = row.search('td')
#       match['map'] = tds[1].inner_text.strip
#       match['type'] = tds[2].inner_text.strip
#       match['outcome'] = tds[3].inner_text.strip
#       match['date'] = tds[4].inner_text.strip
#       match
#     end
#   end
# 
#   def achievements_url
#     @baseurl + 'achievements/'
#   end
# 
#   def read
#     read_profile
#     #data['portraits'] = read_portraits
#     #data['decals'] = read_decals
#     #data['match_history'] = read_match_history
#   end
# end