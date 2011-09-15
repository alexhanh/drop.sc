require 'active_record'

module Processable  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def act_as_processable
      send :include, InstanceMethods
      include ActiveRecord::Transitions
      
      state_machine do
        state :uploaded
        state :renaming
        state :unprocessed
        state :processing
        state :success
        state :failed
        
        event :begin_renaming do
          transitions :to => :renaming, :from => [:uploaded]
        end
        
        event :end_renaming do
          transitions :to => :unprocessed, :from => [:renaming]
        end
        
        event :begin_processing do
          transitions :to => :processing, :from => [:unprocessed]
        end
        
        event :fail do
          transitions :to => :failed, :from => [:processing]
        end
        
        event :success do
          transitions :to => :success, :from => [:processing]
        end
      end
      
      scope :processed, where(:state => "success")

      before_create :assign_pass
      has_many :uploads, :dependent => :destroy, :as => :uploadable
    end
  end
  
  module InstanceMethods
    def assign_pass
      self.pass = UUIDTools::UUID.random_create.to_s if private?
    end
  
    def pass?(pass)
      (public?)? true : self.pass == pass
    end
  
    def public?
      is_public
    end
  
    def private?
      !is_public
    end
    
    def success?
      state == :success
    end
    
    def failed?
      state == :failed
    end
  
    def anonymous?
      upload.nil?
    end
  end
  
  def self.save_to_file(data, path)
    mkdir!(path)
    File.open(path, "wb") do |file|
      file.write(data)
    end
  end
  
  def self.mkdir!(path)
    FileUtils.mkdir_p(File.dirname(path)) unless File.exists?(File.dirname(path))
  end
end

ActiveRecord::Base.send :include, Processable