module ApplicationHelper
  def clippy(id, bgcolor='#FFFFFF')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="14"
              height="14"
              id="clippy" >
      <param name="movie" value="/flash/clippy5.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="id=#{id}&copied=&copyTo=">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/flash/clippy5.swf"
             width="14"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="id=#{id}&copied=&copyTo="
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end
  
  def title(page_title)
    content_for(:title, page_title)
  end
  
  def description(s)
    content_for(:description, s)
  end
  
  def get_uploads_data
    return "" unless user_signed_in?
    s = ""
    for upload in current_user.uploads.includes(:uploadable).order("uploads.created_at DESC").limit(8).reverse
      s += "{"
      s += "id: '" + upload.uploadable_id.to_s + "', "
      s += "type: '" + upload.uploadable_type.to_s + "', "
      s += "name: '" + get_uploadable_name(upload.uploadable) + "',"
      s += "created_at: " + upload.created_at.to_i.to_s + ","
      s += "is_public: " + upload.uploadable.is_public.to_s + ","
      s += "pass: '" + (upload.uploadable.pass.nil? ? "" : upload.uploadable.pass) + "'"
      s += "},"
    end
    s.chop
  end

  def get_uploadable_name(uploadable)
    s = ""
    if uploadable.kind_of?(Replay)
      if uploadable.success?
        s = uploadable.map_name
      else
        s = uploadable.original_filename
      end
    else
      s = "Pack#{uploadable.id}"      
    end
    escape_javascript(s)
  end
  
  def time_ago(time)
    s = time_ago_in_words(time)
    s.gsub("about ", "") + " ago"
  end
  
  def days_ago(time)
    distance_in_days = (((Time.now - time.to_time).abs)/(60*60*24)).floor
    return 'Today' if distance_in_days <= 0
    return 'Yesterday' if distance_in_days == 1
    distance_in_days.to_s + " days ago"
  end
  
  # 01:01
  # 00:56
  def format_timestamp(seconds_passed)
    minutes = seconds_passed/60
    seconds = seconds_passed%60
    minutes_string = minutes.to_s
    seconds_string = seconds.to_s
    minutes_string.insert(0, "0") if (minutes_string.length == 1)
    seconds_string.insert(0, "0") if (seconds_string.length == 1)
    return minutes_string + ":" + seconds_string
  end
  
  # Make some Blizzard colors darker as they are too bright against white background
  def dampen_color(color)
    return "#CC9933" if color == "#EBE129" # Yellow
    return "#CD32AA" if color == "#CCA6FC" # Pinkish
    color
  end
end