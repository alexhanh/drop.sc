class NewsPostsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :authorize_admin, :except => [:index, :show]

  def index
    @news_posts = NewsPost.order("created_at DESC").paginate(:per_page => 8, :page => params[:page])
  end

  def show
    @news_post = NewsPost.find(params[:id])
  end

  def new
    @news_post = NewsPost.new
  end

  def create
    @news_post = NewsPost.new(params[:news_post])
    if @news_post.save
      redirect_to @news_post, :notice => "Successfully created news post."
    else
      render :action => 'new'
    end
  end

  def edit
    @news_post = NewsPost.find(params[:id])
  end

  def update
    @news_post = NewsPost.find(params[:id])
    if @news_post.update_attributes(params[:news_post])
      redirect_to @news_post, :notice  => "Successfully updated news post."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @news_post = NewsPost.find(params[:id])
    @news_post.destroy
    redirect_to news_posts_url, :notice => "Successfully destroyed news post."
  end
end
