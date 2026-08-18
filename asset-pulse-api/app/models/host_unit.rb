# A vehicle or piece of equipment that parts get installed on. Belongs to a
# fleet-operator company (repair shops don't own host units — they receive
# parts, not vehicles).
class HostUnit < ApplicationRecord
  belongs_to :company
  has_many :parts, dependent: :nullify

  validates :vin, presence: true, uniqueness: true, length: { is: 17 }
  validates :description, presence: true
end
