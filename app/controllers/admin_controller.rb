class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_admin
  
  def index
  end
end