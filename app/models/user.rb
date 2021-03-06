class User < ActiveRecord::Base
	has_many :hosted_events, class_name: "Event", foreign_key: "host_id", dependent: :destroy
	has_many :attended_events, through: :rosters, foreign_key: "attended_event_id"
	has_many :rosters, foreign_key: "attendee_id"

	has_many :recieved_invitations, through: :invitations, foreign_key: "recipient_id"
	has_many :invitations, foreign_key: "host_id"


	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :name, presence: true, allow_blank: false
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validates :password, presence: true, allow_blank: false, length: { minimum: 6 }

	has_secure_password

	def User.digest(plaintext)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(plaintext, cost: cost)
	end

	def upcoming_events
		attended_events.where(['start_time > ?', DateTime.now]).order(start_time: :asc)
	end

	def previous_events
		attended_events.where(['start_time < ?', DateTime.now]).order(start_time: :desc)
	end


end