class User < ActiveRecord::Base
  @@SMS_CODE_LENGTH = 6

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :generate_sms_code
  after_save :send_sms_confirmation
  before_save :update_sms_code

  phony_normalize :phone, :default_country_code => 'US'

  validates :phone, phony_plausible: true, uniqueness: true, presence: true

  def self.sms_code_length
    return @@SMS_CODE_LENGTH
  end

  def generate_sms_code
    self.sms_code = User.confirmation_code()
    self.sms_confirmed = false

    # Callback must return true
    return true
  end

  def send_sms_confirmation
    SendSmsConfirmationJob.perform_later(self)
  end

  def update_sms_code

    # Reverify when phone number is changed
    if self.changes()[:phone]
      self.generate_sms_code()
    end
  end

  private

  # Generate an n-digit string of 0-9
  def self.confirmation_code
    return @@SMS_CODE_LENGTH.times.map {
      Random.rand(10)
    }.join()
  end
end