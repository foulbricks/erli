class Date
  def self.same_month?(date1, date2)
     date1.at_beginning_of_month == date2.at_beginning_of_month
  end
end