module InvoiceRentHelper
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

    def charge_rent(lease, invoice, charge_date, company=nil, last_generated=nil)
      last_generated = charge_date - 1.month unless last_generated
      ranges = date_tables(lease.start_date, lease.end_date, lease.payment_frequency)
      period = charge_range(lease, ranges, charge_date, last_generated)
      amount = charge_amount_with_istat(lease, charge_date, ranges, period, company) * lease.ratio

      if amount != 0
        invoice.invoice_charges.build(:kind => "rent", :lease_id => lease.id, 
          :start_date => period.first, :end_date => period.last, :amount => amount, :name => month_description(period))
      end
      return period
    end

    def charge_amount_with_istat(lease, charge_date, ranges, period, company)
      amount = charge_amount_no_istat(lease, charge_date, ranges, period)
      istat_date = lease.start_date + 12.months

      if period && (period.first >= istat_date || period.include?(istat_date)) && lease.contract && lease.contract.istat > 0
        setup_istat = company.try(:istat) || 0
        contract_ratio = lease.contract.istat/100.0
        setup_ratio = setup_istat/100.0

        if period.first >= istat_date
          a = amount + (amount * contract_ratio * setup_ratio)
        else
          num_days = (istat_date..period.last).count
          a = amount + (num_days * lease.daily_charge * contract_ratio * setup_ratio)
        end
        return (a * 100).round / 100.0
      else
        amount
      end
    end

    def charge_amount_no_istat(lease, charge_date, ranges, period)
      months = lease.payment_frequency.months

      if period
        from, to = period.first, period.last

        if lease.payment_frequency == 1 || charge_date.month.in?([1, 4, 7, 10])
          return calculated_amount(lease, period)
        else
          return 0
        end
      else
        return 0
      end
    end

    def calculated_amount(lease, period)
      amount = 0.0
      from = period.first
      while from < period.last
        to = from.end_of_month
        to = period.last if to >= period.last
        
        # if complete month
        if from.mday == 1 && from.end_of_month == to
          amount += lease.monthly_charge
        else
          amount += partial_charge(lease, from, to)
        end
        from = (from + 1.month).at_beginning_of_month
      end
      (amount * 100).round / 100.0
    end

    # returns date ranges per lease dates, always starting on first day of month or start_date
    # and ending on last day of month or lease end date
    def date_tables(start_date, end_date, months)
      ranges = []
      from = start_date
      
      if months == 1
        while from < end_date
          to = from + months.months
          to = (to - 1.month).end_of_month
          to = end_date if to >= end_date
          ranges << (from..to)
          from = (from + months.months).at_beginning_of_month
        end
      else # changing since trimester leases are only charged in specific months
        trimester_months = [1, 4, 7, 10]
        while from < end_date
          current = from
          from = from.next_month
          from = from.next_month until trimester_months.include?(from.month)
          to = (from - 1.month).end_of_month
          to = end_date if to >= end_date
          ranges << (current..to)
          from = from.at_beginning_of_month
        end
      end
      ranges
    end

    # returns range(s) of period that should be charged today
    def charge_range(lease, ranges, charge_date, last_generated)
      return nil if ranges.size < 1

      last_month = charge_date.prev_month

      # if lease is less than a month and between generation dates, return the only range
      #   - check that the lease started last month 
      #   - ended before the charge date and 
      #   - lease started after the last time the invoice was generated (If last invoice was generated on 3rd 
      #     and the lease started on the 1st, the last invoice generator should have picked this charge up )
      if ranges.size == 1 && 
         Date.same_month?(lease.start_date, last_month) && 
         charge_date > lease.end_date &&
         lease.start_date > last_generated
         
        return ranges.first
        
      end
            
      # if there is a range that contains the 1st day of the month of the charge date 
      # ( In case the lease end date is 10th, but the charge date is 12th, it would skip )
      # or the charge date, continue
      if match = (fetch_month_range(ranges, charge_date.at_beginning_of_month) || fetch_month_range(ranges, charge_date))
        
        return match if ranges.size == 1
        
        # NEXT 2 BLOCKS ARE TO COMBINE RANGES. THIS HAPPENS BECAUSE WHEN LEASES START AFTER THE LAST CHARGE DATE,
        # THEY HAVEN'T BEEN CHARGED EVEN IF THE LEASE WAS ALREADY SET TO START IN THE SYSTEM
        
        # combine the ranges if lease started last month and after last_generated
        # - Only happens when the lease is charged monthly (the period could be bigger for multiple month leases)
        if lease.payment_frequency == 1 && 
           Date.same_month?(lease.start_date, last_month) && 
           lease.start_date > last_generated 
        
          return (ranges[0].first..ranges[1].last)
      
        end
      
        # combine ranges if lease started in a non trimester month
        trimester_months = [1, 4, 7, 10]
        if lease.payment_frequency == 3 && charge_date.month.in?(trimester_months)
          
          last_charge_multiple = charge_date - 3.months
          
          if lease.start_date >= last_charge_multiple
            # - check to see if this is the first time that the invoices are built for this apartment
            #   in which case, the invoice has probably been already charged before the website was built
            unless lease.start_date == last_charge_multiple && lease.apartment.leases.count == 1
              # combine ranges if this is the first invoice
              invoice = Invoice.where("lease_id = ?", lease.id).first
              if !invoice || invoice.invoice_charges.where("kind = ?", "rent").first.nil?
                return (ranges[0].first..ranges[1].last)
              end
            end
          end
          
        end

        return match
      end
    end

    def partial_charge(lease, from, to)
      num_days = (from..to).count
      num_days * lease.daily_charge
    end
    
    # Gets a range that includes the date
    def fetch_month_range(ranges, charge_date)
      ranges.find {|r| r.include?(charge_date) }
    end

    def month_description(period)
      start, to = period.first, period.last
      from, names = start, []
      while from < to
        names << [I18n.t("date.month_names")[from.month], from.year]
        from = from.end_of_month + 1.day
      end
      str = names.size > 1 ? "Mesi di " : "Mese di "
      h = names.group_by {|n| n[1] }
      h.each do |year, val|
        str += val.map{|m| m[0].capitalize }.join(", ") + " #{year} "
      end
      str.chop
    end
    
  end
end


    
    # This lease is for less than lease frequency - charge full price
    # This lease started last month and it hasn't been charged last month
    # This lease ends this period
    # Regular price
    # def charge_rent(lease, invoice, invoice_date=Date.today)
    #   if charge_rent?(lease, invoice_date) && (lease.start_date..lease.end_date).include?(invoice_date)
    #     rent = invoice.invoice_charges.build(:kind => "rent", :lease_id => lease.id)
    #     period = charge_period(lease, invoice_date)
    #     rent.start_date, rent.end_date = period.first, period.last
    #     rent.amount = (charge_amount_with_istat(lease, invoice_date) * lease.ratio)
    #   end
    # end
    # 
    # def charge_amount(lease, charge_date)
    #   charges = lease.invoice_charges.where(:kind => "rent").all
    # 
    #   if lease.lease_months <= lease.payment_frequency
    #     a = charges.size == 0 ? lease.amount : 0 
    #   elsif lease.partial_start_date? && Date.same_month?(charge_date.prev_month, lease.start_date) && charges.size < 1
    #     a = (lease.monthly_charge * lease.payment_frequency) + partial_charge(lease)
    #   elsif same_period?(charge_date, lease.end_date, lease.payment_frequency)
    #     total_charges_so_far = charges.map(&:amount).sum
    #     a = lease.amount - total_charges_so_far
    #   else
    #     a = lease.monthly_charge * lease.payment_frequency
    #   end
    #   (a * 100).round / 100.0
    # end
    # 
    # def charge_amount_with_istat(lease, charge_date)
    #   amount = charge_amount(lease, charge_date)
    #   period = charge_period(lease, charge_date)
    #   istat_date = lease.start_date + 12.months
    # 
    #   if lease.lease_months > 12 && lease.contract && lease.contract.istat > 0
    #     setup_istat = Setup.first.try(:istat) || 0
    #     contract_ratio = lease.contract.istat/100.0
    #     setup_ratio = setup_istat > 0 ? setup_istat/100.0 : 1
    # 
    #     if period.first >= istat_date 
    #       a = amount + (amount * contract_ratio * setup_ratio)
    #       (a * 100).round / 100.0
    #     elsif period.include?(istat_date)
    #       num_days = (istat_date..period.last).count
    #       a = amount + (num_days * lease.daily_charge * contract_ratio * setup_ratio)
    #       (a * 100).round / 100.0
    #     else
    #       amount
    #     end
    #   else
    #     amount
    #   end
    # end
    # 
    # def month_description(period)
    #   start, to = period.first, period.last
    #   from, names = start, []
    #   while from < to
    #     names << [I18n.t("date.month_names")[from.month], from.year]
    #     from = from.end_of_month + 1.day
    #   end
    #   str = names.size > 1 ? "Mesi di " : "Mese di "
    #   h = names.group_by {|n| n[1] }
    #   h.each do |year, val|
    #     str += val.map{|m| m[0].capitalize }.join(", ") + " #{year} "
    #   end
    #   str.chop
    # end
    # 
    # def charge_rent?(lease,charge_date)
    #   return true if lease.start_date > charge_date - 1.month && lease.end_date <= charge_date
    #   tables = date_tables(charge_date, lease.start_date, lease.end_date, lease.payment_frequency)
    #   tables.last.first == charge_date.at_beginning_of_month
    # end
    # 
    # def date_tables(stop_date, start_date, end_date, step)
    #   ranges = []
    #   months = step == 1 ? 0 : step
    #   from = start_date
    #   while from < end_date && from <= stop_date
    #     in_end_date = same_period?(from.end_of_month, end_date.end_of_month, step)
    #     to = in_end_date ? end_date : (from.end_of_month + months.months)
    #     ranges << (from..to)
    #     from = from.next_month.at_beginning_of_month + months.months
    #   end
    #   ranges
    # end
    # 
    # def partial_charge(lease)
    #   num_days = (lease.start_date..lease.start_date.end_of_month).count
    #   month_percent = num_days/lease.start_date.end_of_month.mday.to_f
    #   (month_percent * lease.monthly_charge * 100).round / 100.0
    # end
    # 
    # def charge_period(lease, charge_date)
    #   from = charge_date.at_beginning_of_month
    #   to = from + (lease.payment_frequency).months
    #   to = lease.end_date if to > lease.end_date
    #   if (Date.same_month?(charge_date.prev_month, lease.start_date) && charge_date.mday < lease.start_date.mday) || 
    #       Date.same_month?(charge_date, lease.start_date)
    #     from = lease.start_date
    #   end
    #   (from..to)
    # end
    # 
    # def get_month_description(lease, charge_date)
    #   period = charge_period(lease, charge_date)
    #   month_description(period)
    # end
    # 
    # def same_period?(from_date, include_date, months)
    #   (from_date..(from_date + months.months)).include?(include_date)
    # end