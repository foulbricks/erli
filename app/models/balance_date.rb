class BalanceDate < ActiveRecord::Base
  has_many :expenses, :dependent => :nullify
  belongs_to :building
  
  validates :day, :month, :building_id, :presence => true
  
  validates :day, :numericality => {:only_integer => true, :minimum => 1, :maximum => 31}, 
                  :uniqueness => { :scope => [:building_id, :month] }
  validates :month, :numericality => {:only_integer => true, :minimum => 1, :maximum => 12}
  
  def value
    Date.parse("#{Date.today.year}-#{month}-#{day}")
  end
  
  def value_it_locale
    [day, I18n.t("date.month_names")[month].capitalize].join (" di ")
  end
end
