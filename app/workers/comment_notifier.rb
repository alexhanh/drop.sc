class CommentNotifier
  @queue = :low
  
  def self.perform(commentable_type, commentable_id, user_id, path, title, msg)
    commentable = commentable_type.classify.constantize.find(commentable_id)
    commentable.notify(user_id, path, title, msg) 
  end
end