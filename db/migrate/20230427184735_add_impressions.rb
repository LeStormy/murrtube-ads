class AddImpressions < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :impressions, :integer, default: 0
  end
end
