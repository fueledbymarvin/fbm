class User < ActiveRecord::Base
  authenticates_with_sorcery!

  after_initialize :init
  before_create :gen_key

  validates :password, length: {minimum: 5}, if: lambda { |user| user.password.present? }
  validates :email, presence: true
  validates :password, presence: true, on: :create
  validates :password, confirmation: true, if: lambda { |user| user.password.present? }
  validates :email, uniqueness: true
  validates_format_of :email, with: /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

  def reset_password_attrs
    self.reset_password_token = nil
    self.reset_password_token_expires_at = nil
    self.reset_password_email_sent_at = nil
    self.save
  end

  private
  def init
    self.admin ||= false
  end

  def gen_key
    begin
      self.api_key = SecureRandom.hex
    end while self.class.exists?(api_key: self.api_key)
  end
end
