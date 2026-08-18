class Company < ApplicationRecord
  belongs_to :user
  has_one :subscription, dependent: :destroy
  has_many :host_units, dependent: :destroy
  has_many :parts, dependent: :destroy
  has_one_attached :logo

  enum :company_type, { fleet_operator: "fleet_operator", repair_shop: "repair_shop" }, default: "fleet_operator"

  validates :name, presence: true
  validates :registration_number, presence: true, uniqueness: true
  validates :address_zip_code, presence: true
  validates :address_street, presence: true
  validates :address_number, presence: true
  validates :address_city, presence: true
  validates :address_state, presence: true
  validate :logo_must_be_a_valid_image

  private

  ACCEPTED_LOGO_TYPES = %w[image/png image/jpeg image/webp].freeze
  MAX_LOGO_SIZE = 5.megabytes

  def logo_must_be_a_valid_image
    return unless logo.attached?

    unless logo.content_type.in?(ACCEPTED_LOGO_TYPES)
      errors.add(:logo, "must be a PNG, JPEG or WEBP image")
    end

    if logo.byte_size > MAX_LOGO_SIZE
      errors.add(:logo, "must be smaller than 5MB")
    end
  end
end
