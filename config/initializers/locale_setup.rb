class String
  def to_delocalized_decimal
    delimiter = I18n::t("number.format.delimiter")
    separator = I18n::t("number.format.separator")
    self.gsub(/[#{delimiter}#{separator}]/, separator => ".", delimiter => "")
  end
end

class ActiveRecord::Base
  def self.attr_localized(*fields)
    fields.each do |field|
      define_method("#{field}=") do |value|
        self[field] = value.is_a?(String) ? value.to_delocalized_decimal : value
      end
    end
  end
end

class Date
  def self.parse(value = nil)
    if value =~ /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/
      ::Date.civil($3.to_i, $2.to_i, $1.to_i)
    else
      ::Date.new(*::Date._parse(value, false).values_at(:year, :mon, :mday))
    end
  end
end