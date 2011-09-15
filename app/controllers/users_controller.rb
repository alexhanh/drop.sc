class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:make_pro, :profile, :update_settings]
  before_filter :authorize_admin, :only => [:make_pro]
  
  def make_pro
    redirect_to :root, :notice => "Only admin can do this" unless current_user.admin?
    
    user = User.find((params[:id] || "").strip)
    if user
      # check if user already is pro and has pro time left, extent time in that case
      user.pro_until = user.pro_until||Time.current > Time.current ? user.pro_until + 3.months : Time.current + 3.months
      if user.save
        redirect_to :root, :notice => "Succesfully made user pro!"
      else
        redirect_to :root, :notice => "Problem saving user"
      end
    else
      redirect_to :root, :notice => "Unknown user"
    end
  end
  
  def uploads
    if User.where(:id => params[:id]).exists?
      q = Upload.order('uploads.created_at DESC').select("DISTINCT(uploads.*)")
      @uploads = q.where(:user_id => params[:id]).paginate(:per_page => 10, :page => params[:page], :include => :uploadable)
    else
      redirect_to :root, :notice => "User not found"
    end
  end
  
  def profile
  end
  
  def update_settings
    if current_user.update_attributes(:use_colors => params[:use_colors] || false)
      redirect_to :profile, :notice => "Settings updated succesfully!"
    else
      redirect_to :profile, :notice => "Settings were not updated :("
    end
  end
  
  def toggle_twitter_settings
    if params[:post_to_twitter] && params[:post_to_twitter] == "1"
      flash[:notice] = "drop.sc will now Tweet for you when you upload replays!"
      current_user.twitter_account.update_attribute(:active, true)
    else
      flash[:notice] = "drop.sc will no longer Tweet for you when you upload replays."
      current_user.twitter_account.update_attribute(:active, false)
    end
    
    redirect_to :profile
  end
  
  def toggle_facebook_settings
    if params[:post_to_facebook] && params[:post_to_facebook] == "1"
      flash[:notice] = "drop.sc will now post to Facebook for you when you upload replays!"
      current_user.facebook_account.update_attribute(:active, true)
    else
      flash[:notice] = "drop.sc will no longer post to Facebook for you when you upload replays."
      current_user.facebook_account.update_attribute(:active, false)
    end
    
    redirect_to :profile
  end
end