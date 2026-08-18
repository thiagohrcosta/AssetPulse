class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :companies, dependent: :destroy

  validates :full_name, presence: true
  validates :document_number, presence: true, uniqueness: true
  validates :address_zip_code, presence: true
  validates :address_street, presence: true
  validates :address_number, presence: true
  validates :address_city, presence: true
  validates :address_state, presence: true

  # user: regular member of a company. company_admin: owns/administers one
  # or more companies (a company's `user_id` points at one of these).
  # admin: AssetPulse staff, not tied to any company.
  enum access: {
    user: 0,
    admin: 1,
    company_admin: 2
  }
end
