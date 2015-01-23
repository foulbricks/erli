class CachedTenant < ActiveRecord::Base
  belongs_to :lease
  
  def summary
    [name, email, codice_fiscale, percentage].join(" ")
  end
  
end
