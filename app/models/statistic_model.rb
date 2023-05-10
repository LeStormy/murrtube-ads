class StatisticModel < ActiveRecord::Base
  self.abstract_class = true
  
  connects_to database: { writing: :statistics, reading: :statistics }
end
