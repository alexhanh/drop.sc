class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @notifications = current_user.notifications.order("created_at DESC").paginate(:per_page => 10, :page => params[:page])
  end
  
  def read_all
    current_user.notifications.unread.update_all(:read => true)
    
    redirect_to :inbox
  end
end