# All building and apartment expenses are assigned to an apartment
# Lease expenses are assigned to a lease whenever lease is setup, these are shown only if the main expense 
# (Expense object) has a balance date
# Invoice ID is only assigned to asset expenses that are entered on Apartment Expenses Page

module InvoiceExpenseHelper
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def charge_conguaglio_expenses(lease, invoice, invoice_date=Date.today)
      runner = InvoiceRunner.where("lease_id = ?", lease.id).order("generated_date DESC").first
      prev_charge_date = runner.generated_date if runner
      prev_charge_date = invoice_date - lease.payment_frequency.months unless prev_charge_date
      
      lease.asset_expenses.each do |lease_expense|
        amount = lease_expense.amount / 12.0 * lease.payment_frequency
        charge_start = invoice.start_date
        charge_end = invoice.end_date

        if lease_expense.expense && lease_expense.expense.add_to_invoice? && lease_expense.expense.balance_date
          bd = lease_expense.expense.balance_date
          # if balance date and the invoice date are in January and the day of the invoice date is more than
          # the balance date, then they fall on the same year
          if bd.month == 1 && invoice_date.month == 1 && invoice_date.day >= bd.day
            balance_date = Date.parse("#{invoice_date.year}-#{bd.month}-#{bd.day}")
          else
            balance_date = Date.parse("#{invoice_date.prev_month.year}-#{bd.month}-#{bd.day}")
          end
          kind = lease_expense.expense.kind == "Edificio" ? "building_expense" : "apartment_expense"
          
          if balance_date > prev_charge_date && balance_date <= invoice_date
            
            conguaglio_expenses = lease.apartment.asset_expenses.where("balance_date = ? AND expense_id = ? AND " +
             "start_date <= ?::date AND end_date >= ?::date", balance_date, lease_expense.expense.id, lease.end_date, 
             lease.start_date).order("start_date ASC").all
             
            if conguaglio_expenses.size > 0
              expense_calc = expense_total_charge(conguaglio_expenses, lease)
              total =  expense_calc + amount - total_expense_charges(lease_expense, conguaglio_expenses)
              invoice.invoice_charges.build(:kind => kind, :lease_id => lease.id,
                :iva_exempt => lease_expense.expense.iva_exempt, :amount => total, :start_date => charge_start,
                :end_date => charge_end, :asset_expense_id => lease_expense.id, :balanced => true)
            else
              invoice.invoice_charges.build(:kind => kind, :lease_id => lease.id, 
                :iva_exempt => lease_expense.expense.iva_exempt, :amount => amount, :start_date => charge_start,
                :end_date => charge_end, :asset_expense_id => lease_expense.id)
            end
          else
            invoice.invoice_charges.build(:kind => kind, :lease_id => lease.id, 
              :iva_exempt => lease_expense.expense.iva_exempt, :amount => amount, :start_date => charge_start,
              :end_date => charge_end, :asset_expense_id => lease_expense.id)
          end
        end
      end
    end

    def charge_apartment_expenses(lease, invoice)
      apartment_expenses(lease).each do |e|
        if e.expense && e.expense.add_to_invoice?
          invoice.invoice_charges.build(:kind => "apartment_expense", :lease_id => lease.id, :iva_exempt => e.expense.iva_exempt,
            :amount => e.amount, :start_date => invoice.start_date, :end_date => invoice.end_date, :asset_expense_id => e.id)
        end
      end
    end

    # Calculates all expenses that fall between the lease date (used for conguaglio expenses)
    def expense_total_charge(expenses, lease)
      charges_start = lease.start_date
      charges_end = lease.end_date
      
      total = 0.0
      expenses.each do |expense|
        # Complete charge. Expense falls inside lease duration completely
        if charges_start <= expense.start_date && charges_end >= expense.end_date
          total += expense.amount
        else
          # Expense started after lease started, but lease ended before expense ended
          if charges_start <= expense.start_date && charges_end <= expense.end_date
            num_days = (expense.start_date..charges_end).count
          # Expense started before lease started, but expense ended before lease ended
          elsif charges_start >= expense.start_date && charges_end >= expense.end_date 
            num_days = (charges_start..expense.end_date).count
          else
            num_days = 0
          end
          expense_num_days = (expense.start_date..expense.end_date).count
          total += (num_days/expense_num_days.to_f * expense.amount)
        end
      end
      total
    end

    # Adds all the invoice charges related to a lease expense, after a balanced expense
    def total_expense_charges(lease_expense, conguaglio_expenses)
      calculation_starts = conguaglio_expenses.first.start_date
      calculation_ends = conguaglio_expenses.last.end_date
      total = 0.0
      from = calculation_starts
      while from.end_of_month <= calculation_ends.end_of_month
        to = Date.same_month?(from, calculation_ends) ? calculation_ends : from.end_of_month
        if from.mday == 1 and to.end_of_month == from.end_of_month
          total += lease_expense.amount
        else
          total += ( (from..to).count/to.mday.to_f ) * (lease_expense.amount / 12.0)
        end
        from = from.next_month.at_beginning_of_month
      end
      total
    end
    
    def apartment_expenses(lease)
      lease.apartment.asset_expenses.where("invoice_id IS NULL AND lease_id = ? and balance_date IS NULL", lease.id).all
    end
    
  end
  
end