require 'active_record'

module Subscribable
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods
    def act_as_subscribable
      send :include, InstanceMethods
      
      has_many :subscriptions, :dependent => :destroy, :as => :subscribable
      has_many :anon_users, :through => :subscriptions
      has_many :subscribers, :through => :subscriptions, :source => :user
    end
  end
  
  module InstanceMethods
    def subscribe(user_id)
      unless Subscription.where(:subscribable_type => self.class.to_s, :subscribable_id => self.id, :user_id => user_id).exists?
        Subscription.create(:user_id => user_id, :subscribable => self)
      end
    end
    
    def notify(sender_id, url, title, msg)
      for subscriber in self.subscribers
        next if subscriber.id == sender_id
        Notification.create(:user => subscriber, :url => url, :title => title, :body => msg)
      end
    end
  end
end

ActiveRecord::Base.send :include, Subscribable