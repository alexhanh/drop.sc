class PacksController < ApplicationController
  before_filter :authenticate_user!, :only => [:set_event, :destroy]
  before_filter :authorize_admin, :only => [:set_event, :destroy]
  
  def set_event
    pack = Pack.includes(:replays).find(params[:id])
    if !params[:event_id].nil? && !params[:event_id].empty?
      event = Event.find(params[:event_id])
      Replay.update_all({:event_id => event.id}, {:id => pack.replays})
    else
      Replay.update_all({:event_id => nil}, {:id => pack.replays})
    end

    redirect_to pack, :notice => "Event has been updated succesfully for all pack's replays."
  end
  
  def edit
    @pack = Pack.find(params[:id])
    can_edit = check_permission(@pack)
    if !can_edit
      flash[:error] = "You are not authorized to edit this replay pack."
      redirect_to :root
    end
    
    @pack.description = params[:description]
    if @pack.save
      flash[:notice] = "Replay pack description updated."
    else
      flash[:notice] = "Problem occurred while updating replay pack."
    end
    
    redirect_to pack_path(@pack, :pass => @pack.pass)
  end
  
  def index
    q = Pack.public.processed
    if params[:order] == "date_posted"
      q = q.order("packs.created_at DESC")
    elsif params[:order] == "downloads"
      q = q.order("packs.downloads DESC")
    else
      q = q.by_popular
      params[:order] = "downloads"
    end
    
    @packs = q.paginate(:per_page => 5, :page => params[:page])
  end
  
  def show
    @replays_per_page = 25
    @pack = Pack.find(params[:id])
    
    if !@pack.pass?(params[:pass])
      flash[:error] = "You are not authorized to access this replay."
      redirect_to :root
    end
    
    @can_edit = check_permission(@pack)
    @replays = @pack.replays.order("replays.state DESC, replays.saved_at DESC").includes(:plays => :player).paginate(:per_page => @replays_per_page, :page => params[:page])
    @replays_count = @pack.replays.count
  end
  
  # http://api.rubyonrails.org/classes/ActionController/Streaming.html
  def d
    pack = Pack.find(params[:id], :select => [:id, :pass, :is_public, :file])

    if pack.pass?(params[:pass])
      # pack.increment!(:downloads)
      Pack.connection.execute("UPDATE packs SET downloads = downloads + 1 WHERE id = #{pack.id}")
      
      send_file(pack.absolute_file_path)
    else
      redirect_to :root, :error => "You are not authorized to download this replay pack."
    end
  end
  
  def destroy
    @pack = Pack.find(params[:id])
    can_edit = check_permission(@pack)
    if !can_edit
      flash[:error] = "You are not authorized to delete this replay pack."
      redirect_to :root
    end
    @pack.destroy
    flash[:notice] = "Replay pack succesfully removed."
    redirect_to [:packs]
  end
  
  def check_permission(pack)
    return false unless user_signed_in?
    return current_user.admin? if pack.anonymous?
    pack.upload.user_id == current_user.id || current_user.admin?
  end
end