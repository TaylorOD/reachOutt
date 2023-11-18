class Contact < ApplicationRecord
  has_many :reachouts, dependent: :destroy
  belongs_to :user
end
