class PackProcessor
  @queue = :high
  
  # uploader_id is nil on anonymous uploads
  def self.perform(pack_id, uploader_id)
    pack = Pack.find(pack_id)

    pack.begin_processing! # sets state to 'processing' and calls save!

    basepath = Rails.root.join('files', 'packs', pack_id.to_s)
    path = Rails.root.join('files', 'packs', pack_id.to_s, pack.file)
    
    p "executing command 7z x -y -o#{basepath} #{path}"
    for i in 1..5
      break if File.exists?(path)
      sleep(5)
    end
    
    system("7z x -y -o#{basepath} #{path}")
    
    for entry in (Dir[basepath.join("**/*.{SC2Replay,sc2replay}")] + Dir[basepath.join("*.{SC2Replay,sc2replay}")]).uniq
      next unless valid_entry?(entry)  

      # read the replay and calculate md5
      raw_data = ""
      open(entry) { |f| raw_data = f.read }
      md5 = Digest::MD5.hexdigest(raw_data)
      
      replay = nil
      if pack.public?
        replay = Replay.public.where(:file_hash => md5).first
      else
        if uploader_id
          replay = Replay.joins(:uploads => :user).where(:file_hash => md5, :is_public => false).where(:uploads => {:user_id => uploader_id}).first
        end
      end

      if replay.nil?
        replay = Replay.new(:is_public => pack.is_public, :original_filename => File.basename(entry))
        replay.file_hash = md5
        
        replay.begin_renaming! # sets state to 'renaming' and calls save!
        
        replay.file = replay.id.to_s + '.SC2Replay'
        Processable.save_to_file(raw_data, Rails.root.join('files', 'replays', replay.id.to_s, replay.file))      
        
        replay.end_renaming! # sets state to 'unprocessed' and calls save!
      end

      replay.subscribe(uploader_id) if uploader_id
      PackGame.create!(:pack => pack, :replay => replay)
    end

    pack.success! # sets state to 'success' and calls save!
  end
  
  private
  def self.valid_entry?(entry)
    filename = entry.to_s
    !filename.start_with?("__MACOSX") && File.extname(filename).downcase == ".sc2replay"
  end
end