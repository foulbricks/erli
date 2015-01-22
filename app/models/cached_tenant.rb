class CachedTenant < ActiveRecord::Base
  belongs_to :lease
  
end
