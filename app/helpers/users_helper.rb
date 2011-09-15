module UsersHelper
  def username(user)
    return user.username unless user.pro?
    '<span class="pro-username" title="Pro user">' + user.username + '</span>'
  end
end