require "base64"

class ApiController < ApplicationController
  def replay
    replay = Replay.includes(:plays, :players).find(params[:id])
    
    if replay.pass?(params[:pass])
      json = jsonify(replay)
    else
      json = { :error => "You are not authorized to view this replay." }
    end
    
    respond_to do |format|
      format.json { render :json => json }
      format.xml { render :xml => json }
    end
  end
  
  def upload
    # credentials sent, try to login or fail
    username = params[:userName] || params[:username]
    password = params[:password]
    user = nil
    if !username.blank? || !password.blank?
      user = User.find_by_username(username)
      if user.nil? || !user.valid_password?(password)
        render :xml => sc2gears_xml(1, "Wrong username or password.", "")
        return
      end
    end
    
    if !(File.extname(params[:fileName]).downcase == ".sc2replay")
      render :xml => sc2gears_xml(2, "Only SC2Replay files are allowed.", "")      
      return
    end

    raw_data = Base64.decode64(params['fileContent'])

    if raw_data.size != params["fileSize"].to_i
      render :xml => sc2gears_xml(3, "Problem with the file upload. Size doesn't match. Please try again.", "")
      return
    end

    if raw_data.size > 25000000
      render :xml => sc2gears_xml(4, "The replay file is too big. Maximum is 25Mb.", "")
      return
    end

    is_public = (params[:is_public] ? params[:is_public] == "true" : true)
    
    md5 = Digest::MD5.hexdigest(raw_data)
    if md5 != params['fileMd5']
      render :xml => sc2gears_xml(5, "Uploading failed, the MD5 hash doesn't match. Please try again.", "")
      return
    end
    
    description = params[:description] || ""
    if description.length > 300
      render :xml => sc2gears_xml(7, "Uploading failed, description is too long (#{description.length} chars). Maximum is 300 chars. Please try again.", "")
      return
    end
    
    replay = Replay.upload(is_public, params[:fileName], raw_data, md5, user, description, params[:source])
    
    render :xml => sc2gears_xml(0, "", replay_url(replay, :pass => replay.pass))
  end
  
  private
  def jsonify(replay)
    races = { "Z" => "Zerg", "T" => "Terran", "P" => "Protoss" }

    if replay.success?    
      players = []
      for play in replay.plays
        if play.human?
          player = play.player
          players << {
            :name => player.name,
            :bnet_id => player.bnet_id.to_s,
            :region => player.region,
            :team => play.team.to_s,
            :race => races[play.race],
            :bnet_url => player.bnet_url,
            :color => play.color
          }
        end
      end
      json = {
        :parsed => true.to_s,
        :players => players,
        :map => replay.map_name,
        :map_file => replay.map_file_name,
        :url => url_for(replay),
        :build_version => replay.version[-5,5],
        :game_time => replay.game_length.to_s,
        :game_speed => replay.game_speed,
        :gameplay_type => replay.game_format,
        :upload_date => replay.saved_at,
      }
    else
      json = { :parsed => false.to_s }
    end
    json
  end
  
  def sc2gears_xml(error_code, message, replay_url)
    s = '<?xml version="1.0" encoding="UTF-8"?>'
    s += '<uploadResult docVersion="1.0">'
    s += '<errorCode>' + error_code.to_s + '</errorCode>'
    s += '<message>' + message + '</message>'
    s += '<replayUrl>' + replay_url + '</replayUrl>'
    s += '</uploadResult>'
  end
end