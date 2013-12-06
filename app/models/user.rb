class User < ActiveRecord::Base
  attr_accessible :email, :username, :password, :password_confirmation
  attr_accessor :password
  before_save :encrypt_password

  validates :username, presence: true, length: { maximum:50 }
  validates :email, presence: true,
              format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i },
              uniqueness: { case_sensitive: false }
  validates :password, confirmation: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

  def authenticate(email, password)
    user = User.find_by(email: email.downcase)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def User.new_remember_token
      SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
      Digest::SHA1.hexdigest(token.to_s)
  end

  private
    def create_remember_token
        self.remember_token = User.encrypt(User.new_remember_token)
    end
end
