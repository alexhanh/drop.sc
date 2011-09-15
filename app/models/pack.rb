class Pack < ActiveRecord::Base
  act_as_processable
  act_as_commentable
  
  scope :public, where('packs.is_public = ?', true)
  scope :private, where('packs.is_public = ?', false)
  
  has_one :upload, :as => :uploadable
  has_many :pack_games, :dependent => :destroy
  has_many :replays, :through => :pack_games
  
  scope :by_popular, order("packs.downloads DESC")
  
  before_create :generate_description
  def generate_description
    self.description = "h3. #{self.original_filename}"
  end
  
  def absolute_file_path
    Rails.root.join('files', 'packs', id.to_s, file)
  end
  
  def self.upload(is_public, original_filename, extension, raw_data, user, source)
    pack = Pack.new(:is_public => is_public, :original_filename => original_filename)
    
    pack.begin_renaming! # sets state to 'renaming' and calls save!
    pack.file = pack.id.to_s + extension
    Processable.save_to_file(raw_data, pack.absolute_file_path)
    pack.end_renaming! # sets state to 'unprocessed' and calls save!
    
    Upload.create!(:user => user, :uploadable => pack, :source => source)
    
    Resque.enqueue(PackProcessor, pack.id, user ? user.id : nil)
    
    return pack
  end
end