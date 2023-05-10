class Ad < ApplicationRecord
  has_one_attached :image

  has_many :ad_impressions
  has_many :ad_clicks
end