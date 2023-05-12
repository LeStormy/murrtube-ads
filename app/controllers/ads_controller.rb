class AdsController < ApplicationController
  def index
    if cookies.signed["token"].blank?
      render 'code'
    else
      token = cookies.signed["token"]
      ad_records = 
        if token == Rails.application.credentials.dig(:master_code)
          Ad.order(:title)
        else
          Ad.where(token: cookies.signed["token"]).order(:title)
        end
      @ads = ad_records.map do |ad|
        clicks_per_week = AdClick.where(ad_id: ad.id).group_by_week(:created_at).count
        impressions_per_week = AdImpression.where(ad_id: ad.id).group_by_week(:created_at).count
        
        data_per_week = {}
        impressions_per_week.each do |week, count|
          if data_per_week[week.to_s].blank?
            data_per_week[week.to_s] = {}
          end
          data_per_week[week.to_s][:impressions] = count || 0
        end
        clicks_per_week.each do |week, count|
          if data_per_week[week.to_s].blank?
            data_per_week[week.to_s] = {}
          end
          data_per_week[week.to_s][:clicks] = count || 0
        end

        obj = {}
        concurrent_campaigns =
          AdImpression.group(:ad_id).group_by_week(:created_at).count.map do |pair, count|
            if count > 0
              obj[pair[1].to_s] = (obj[pair[1].to_s] || 0) + 1
            end
          end

        obj.each do |week, count|
          if data_per_week[week.to_s].present?
            data_per_week[week.to_s][:concurrent_campaigns] = count || 0
          end
        end

        {
          id: ad.id,
          image_url: ad.image.url,
          title: ad.title,
          url: ad.url,
          data_per_week: Hash[data_per_week.sort_by{|k, v| k}],
          running: !ad.paused,
          starts_on: ad.start_date,
          ends_on: ad.end_date,
          created_at: ad.created_at,
          total_clicks: AdClick.where(ad_id: ad.id).count,
          total_impressions: AdImpression.where(ad_id: ad.id).count
        }
      end
    end
  end

  def code
    
  end

  def set_code
    if params[:token] == Rails.application.credentials.dig(:master_code) ||
      Ad.find_by(token: params[:token]).present?

      cookies.signed["token"] = {value: params[:token], same_site: :strict, expires: 15.days }
      redirect_to ads_path
    else
      redirect_to ads_path, notice: "This code doesn't exist"
    end
  end
end
