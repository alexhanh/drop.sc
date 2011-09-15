module NotificationHelper
  def notification_url(notification)
    url = notification.url
    if url.include?("?")
      return url.insert(url.index('#')||url.length, "&not_id=" + notification.id.to_s)
    else
      return url.insert(url.index('#')||url.length, "?not_id=" + notification.id.to_s)
    end
  end
end