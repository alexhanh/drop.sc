require 'active_record'

module Commentable
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def act_as_commentable
      send :include, InstanceMethods
      
      has_many :comments, :as => :commentable, :dependent => :destroy
    end
  end
  
  module InstanceMethods
  end
end

ActiveRecord::Base.send :include, Commentable