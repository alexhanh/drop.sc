class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username, :use_colors
  
  validates_uniqueness_of :username
  validates_length_of :username, :in => 3..15
  validates_format_of :username, :with => /[a-z0-9\-_]+$/i, :message => "is invalid. Only letters, numbers, underscores and dashes are allowed."
  
  validates_inclusion_of :use_colors, :in => [true, false]
  
  has_many :uploads#, :include => [ :uploadable ]
  # has_many :uploadables, :through => :uploads
  has_many :comments
  has_many :notifications
  
  # has_one :twitter_account
  # has_one :facebook_account
  
  def admin?
    is_admin
  end
  
  def pro?
    if pro_until
      Time.current < pro_until
    end
  end
  
  def use_colors?
    use_colors
  end
  
  # def tweet(msg)
  #   if self.twitter_account && self.twitter_account.active
  #     self.twitter_account.post(msg)
  #   end
  # end
  # 
  # def post_to_facebook(msg)
  #   if self.facebook_account && self.facebook_account.active
  #     self.facebook_account.post(msg)
  #   end
  # end
end
