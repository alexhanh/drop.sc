class ApplicationController < ActionController::Base
  # protect_from_forgery
  
  before_filter :check_notifications
  
  before_filter :set_locale

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  # overwrite devise default to handle return urls
  def after_sign_in_path_for(resource)    
    if params[:return_url]
      return params[:return_url]
    end
    
    stored_location_for(resource) || root_path
  end
  
  def authorize_admin
    redirect_to :root unless user_signed_in? && current_user.admin?
  end
  
  def api?
    params[:controller] == "api"
  end
  
  def player_name_search?
    params[:action] == "autocomplete_player_name"
  end
  
  def download?
    params[:action] == 'd'
  end
  
  def check_notifications
    return if api? || player_name_search? || download?
    return unless user_signed_in?

    notification = Notification.where(:id => params[:not_id]).first
    if notification && notification.user_id == current_user.id
      notification.update_attribute(:read, true)
    end
  end
end
