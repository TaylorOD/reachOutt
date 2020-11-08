class Contact < ApplicationRecord
  has_many :reachouts
  belongs_to :user
end
