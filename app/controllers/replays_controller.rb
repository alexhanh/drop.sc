class ReplaysController < ApplicationController
  before_filter :authenticate_user!, :only => [:destroy, :set_event]
  before_filter :authorize_admin, :only => [:destroy, :set_event]
  
  def set_event
    event = nil
    replay = Replay.find(params[:id])
    if !params[:event_id].nil? && !params[:event_id].empty?
      event = Event.find(params[:event_id])
      replay.update_attribute(:event_id, event.id)
    else
      replay.update_attribute(:event_id, nil)
    end

    redirect_to replay, :notice => "Event updated succesfully."
  end
  
  def search
    @replays = generate_search_query(10)
  end
  
  def embed
    @replays = generate_search_query(5)
    
    render 'embed', :layout => false
  end
  
  def popular
    ago = 10.years.ago
    
    @today = false
    @week = false
    @month = false
    @year = false
    @all = false
    
    if params[:time] == "today"
      @today = true
    elsif params[:time] == "week"
      @week = true
    elsif params[:time] == "month"
      @month = true
    elsif params[:time] == "year"
      @year = true
    elsif params[:time] == "all"
      @all = true
    else
      @week = true
    end
    
    ago = 1.day.ago   if @today
    ago = 1.week.ago  if @week
    ago = 1.month.ago if @month
    ago = 1.year.ago  if @year

    @replays = Replay.public.processed.ago(ago).includes(:event).by_popular.includes(:plays => [:player]).paginate(:per_page => 10, :page => params[:page])
    # @replays = Replay.public.processed.ago(ago).includes(:event).by_popular.includes(:plays, :players).paginate(:per_page => 10, :page => params[:page])
  end
  
  def show
    @replay = Replay.includes(:comments => :user).includes(:event, :players).find(params[:id])
    
    if !@replay.pass?(params[:pass])
      flash[:error] = "You are not authorized to access this replay."
      redirect_to :root
    end
    
    # TODO: APM data was removed when sc2reader was switched to sc2gears
    # @apm_data = ""
    # @replay.plays.each do |play|
      # @apm_data += "{ name: '#{play.player.name}', data: " + play.apm.split(',').map{|e| e.to_i}.inspect + "},"
    # end
    # @apm_data = @apm_data.chop
  end
  
  def destroy
    Replay.find(params[:id]).destroy
    redirect_to :root
  end
  
  def upload
    extension = File.extname(params[:original_filename]).downcase
    extensiond = extension.downcase
    is_pack = (extensiond == ".zip" || extensiond == ".7z" || extensiond == ".tar")
    is_replay = (extensiond == ".sc2replay")
    unless is_replay || is_pack
      render :json => {:error => "Only SC2Replay files and ZIP, RAR, 7z and TAR archives are allowed."}, :content_type => 'text/html'      
      return
    end
    
    raw_data = nil
    if params[:qqfile].respond_to?(:read)
      raw_data = params[:qqfile].read
    else
      raw_data = env['rack.input'].read
    end

    if raw_data.size > 35000000
      render :json => {:error => "Replay file or pack is too big."}, :content_type => 'text/html'      
      return
    end
    
    is_public = (params[:is_public] == "true")? true : false

    uploadable = nil
    if is_pack
      uploadable = Pack.upload(is_public, params[:original_filename], extension, raw_data, current_user, "drop.sc")
    else
      md5 = Digest::MD5.hexdigest(raw_data)
      uploadable = Replay.upload(is_public, params[:original_filename], raw_data, md5, current_user, "", "drop.sc")
    end
    
    render :json => {:success => true, :type => uploadable.class.to_s, :id => uploadable.id, :is_public => uploadable.is_public, :pass => uploadable.pass, :created_at => uploadable.created_at.to_i}, :content_type => 'text/html'
  end
  
  # http://api.rubyonrails.org/classes/ActionController/Streaming.html
  def d
    replay = Replay.find(params[:id], :select => [:id, :pass, :is_public, :file])

    if replay.pass?(params[:pass])
      # replay.increment!(:downloads)
      Replay.connection.execute("UPDATE replays SET downloads = downloads + 1 WHERE id = #{replay.id}")

      send_file(replay.absolute_file_path)

      # if File.exists?(Rails.root.join('files', 'replays', replay.id.to_s, replay.file))
      #         send_file(Rails.root.join('files', 'replays', replay.id.to_s, replay.file))
      #       elsif File.exists?(Rails.root.join('files', 'replays', replay.id.to_s, replay.id.to_s+".SC2Replay"))
      #         send_file(Rails.root.join('files', 'replays', replay.id.to_s, replay.id.to_s+".SC2Replay"))
      #       else
      #       end
        
    else
      redirect_to :root, :error => "You are not authorized to download this replay."
    end
  end
  
  protected
  # Create replay search query object from queryparameters
  def generate_search_query(per_page)
    q = Replay.select("DISTINCT(replays.*)").public.processed.includes(:event, :plays, :players)
    
    player_id = nil
    if params[:player] =~ /\A#\d+\z/
      player_id = params[:player][1..-1].to_i
    end

    if player_id
      q = q.joins(:plays).where(:plays => {:player_id => player_id})
    elsif !params[:player].blank?
      q = q.joins(:players).where("players.name ILIKE ?", "%#{params[:player]}%")
    else
    end
    
    unless params[:league].blank?
      q = q.joins(:players).where("players.league_1v1 = ?", params[:league])
    end
    
    unless params[:gateway].blank?
      q = q.where("replays.gateway = ?", params[:gateway])
    end
    
    unless params[:map].blank?
      q = q.where("replays.map_name LIKE ?", "%#{params[:map]}%")
    end
    
    unless params[:version].blank?
      q = q.where(:version => params[:version])
    end
    
    unless params[:game_format].blank?
      q = q.where(:game_format => params[:game_format])
    end
    
    mu = params[:mu]
    @any = false
    if mu == "tvp"
      q = q.where(:terrans => 1, :protosses => 1, :zergs => 0)
    elsif mu == "tvz"
      q = q.where(:terrans => 1, :protosses => 0, :zergs => 1)
    elsif mu == "pvz"
      q = q.where(:terrans => 0, :protosses => 1, :zergs => 1)
    elsif mu == "tvt"
      q = q.where(:terrans => 2, :protosses => 0, :zergs => 0)
    elsif mu == "pvp"
      q = q.where(:terrans => 0, :protosses => 2, :zergs => 0)
    elsif mu == "zvz"
      q = q.where(:terrans => 0, :protosses => 0, :zergs => 2)
    else
      @any = true
    end
    
    if params[:order] == "date_posted"
      q = q.order("replays.created_at DESC")
    elsif params[:order] == "date_played"
      q = q.order("replays.saved_at DESC")
    elsif params[:order] == "downloads"
      q = q.order("replays.downloads DESC")
    elsif params[:order] == "comments"
      q = q.order("replays.comments_count DESC")
    else
      q = q.recent
      params[:order] = "date_posted"
    end
    
    # @replays = q.includes(:plays => [:player]).paginate(:per_page => 5, :page => params[:page])
    @replays = q.paginate(:per_page => per_page, :page => params[:page])
  end
end