module UploadableHelper
  def get_link(name, uploadable, user_id)
    if uploadable.private? && (!user_signed_in? || current_user.id != user_id)
      return "Private"
    end

    return link_to name, polymorphic_path(uploadable, :pass => uploadable.pass)
  end
end