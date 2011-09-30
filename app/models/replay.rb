class Replay < ActiveRecord::Base
  VERSIONS = %w[1.4.1.19776 1.4.0.19679 1.4.0.19595 1.4.0.19458 1.3.6.19269 1.3.5.19132 1.3.4.18701 1.3.3.18574 1.3.3.18552 1.3.2.18317 1.3.1.18221 1.3.0.18092 1.2.2.17811 1.2.1.17682 1.2.0.17326 1.1.3.16939 1.1.2.16755 1.1.1.16605 1.1.0.16561 1.0.3.16291 1.0.2.16223 1.0.1.16195 1.0.0.16117]

  act_as_processable
  act_as_subscribable
  act_as_commentable

  scope :recent, order("replays.created_at DESC")
  scope :ago, lambda {|time| where("replays.created_at > ?", time)}
  scope :by_popular, order("replays.downloads DESC")
  
  scope :public, where('replays.is_public = ?', true)
  scope :private, where('replays.is_public = ?', false)
  
  belongs_to :event
  
  has_many :plays, :dependent => :destroy
  has_many :players, :through => :plays
  has_many :messages, :order => "time", :dependent => :destroy

  has_many :pack_games, :dependent => :destroy
  
  # TODO: fix to use state machine
  def make_unprocessed
    self.plays.destroy_all
    self.messages.destroy_all
    self.update_attribute(:processing_state, Processable::NOT_PROCESSED)
  end
  
  def absolute_file_path
    Rails.root.join('files', 'replays', file)
  end
  
  def is_1v1?
    game_format == "1v1"
  end
  
  def live?
    version == VERSIONS[0]
  end
  
  def self.upload(is_public, original_filename, raw_data, md5, user, description, source)
    replay = nil
    if is_public
      replay = Replay.public.where(:file_hash => md5).first
    else
      if user
        replay = Replay.joins(:uploads => :user).where(:file_hash => md5, :is_public => false).where(:uploads => {:user_id => user.id}).first
      end
    end

    if replay.nil?
      replay = Replay.new(:is_public => is_public, :original_filename => original_filename, :description => description, :file_hash => md5)

      replay.begin_renaming! # sets state to 'renaming' and calls save!
      replay.file = "#{replay.id}.SC2Replay"
      Processable.save_to_file(raw_data, replay.absolute_file_path)      
      replay.end_renaming! # sets state to 'unprocessed' and calls save!
    end

    if user
      replay.subscribe(user.id)
    end
    
    Upload.create!(:user => user, :uploadable => replay, :source => source)
  
    return replay
  end
end