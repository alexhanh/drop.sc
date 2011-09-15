class CommentsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    commentable = find_commentable  
    
    if (commentable.respond_to?("private?") && commentable.private? && !commentable.pass?(params[:pass]))
      flash[:error] = "You are not authorized to comment this #{commentable.class.to_s.downcase}."
      redirect_to :root
      return
    end
    
    comment = commentable.comments.build(params[:comment])
    comment.user = current_user
    
    if comment.save
      commentable.subscribe(current_user.id) if commentable.respond_to?(:subscribe)
      path = nil
      if params[:pass].blank?
        path = polymorphic_path(commentable, :anchor => :comments)
      else
        path = polymorphic_path(commentable, :pass => params[:pass], :anchor => :comments)
      end
        
      title = "#{current_user.username} commented #{commentable.class.to_s}#{commentable.id}"
      if commentable.respond_to?(:notify)
        Resque.enqueue(CommentNotifier, commentable.class.to_s, commentable.id, current_user.id, path, title, shortify(comment.text))
      end
    else
      flash[:error] = "There was a problem saving the comment." 
    end
    redirect_to polymorphic_path(commentable, :pass => params[:pass])
  end
  
  protected
  def shortify(comment)
    short = comment[0,80]
    if short.length < comment.length
      short += "..."
    end
    short
  end
  
  def find_commentable  
    params.each do |name, value|  
      if name =~ /(.+)_id$/  
        return $1.classify.constantize.find(value)  
      end  
    end  
    nil  
  end
end