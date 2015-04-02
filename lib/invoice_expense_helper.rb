# All building and apartment expenses are assigned to an apartment
# Lease expenses are assigned to a lease whenever lease is setup, these are shown only if the main expense 
# (Expense object) has a balance date
# Invoice ID is only assigned to asset expenses that are entered on Apartment Expenses Page

module InvoiceExpenseHelper
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def charge_conguaglio_expenses(lease, invoice, last_generated, invoice_date=Date.today)
      last_generated = invoice_date.prev_month + 1.day unless last_generated
      
      lease.asset_expenses.each do |lease_expense|
        charge_start = invoice.start_date
        charge_end = invoice.end_date

        if lease_expense.expense && lease_expense.expense.add_to_invoice? && lease_expense.expense.balance_date
          balance_date = lease_expense.expense.balance_date.value
          kind = lease_expense.expense.kind == "Edificio" ? "building_expense" : "apartment_expense"
          
          if(Date.same_month?(balance_date, invoice_date.prev_month) && balance_date > last_generated) || 
            (Date.same_month?(balance_date, invoice_date) && balance_date <= invoice_date)
            
            conguaglio_expenses = lease.apartment.asset_expenses.where("balance_date = ? AND expense_id = ? AND " +
             "start_date <= ?::date AND end_date >= ?::date", balance_date, lease_expense.expense.id, lease.end_date, 
             lease.start_date).all
             
            if conguaglio_expenses.size > 0
              expense_calc = expense_total_charge(conguaglio_expenses, lease)
              total =  expense_calc + lease_expense.amount - total_expense_charges(lease_expense)
              invoice.invoice_charges.build(:kind => kind, :lease_id => lease.id,
                :iva_exempt => lease_expense.expense.iva_exempt, :amount => total, :start_date => charge_start,
                :end_date => charge_end, :asset_expense_id => lease_expense.id, :balanced => true)
            else
              invoice.invoice_charges.build(:kind => kind, :lease_id => lease.id, 
                :iva_exempt => lease_expense.expense.iva_exempt, :amount => lease_expense.amount, :start_date => charge_start,
                :end_date => charge_end, :asset_expense_id => lease_expense.id)
            end
          else
            invoice.invoice_charges.build(:kind => kind, :lease_id => lease.id, 
              :iva_exempt => lease_expense.expense.iva_exempt, :amount => lease_expense.amount, :start_date => charge_start,
              :end_date => charge_end, :asset_expense_id => lease_expense.id)
          end
        end
      end
    end

    def charge_apartment_expenses(lease, invoice, invoice_date=Date.today)
      apartment_expenses(lease).each do |e|
        if e.expense && e.expense.add_to_invoice?
          invoice.invoice_charges.build(:kind => "apartment_expense", :lease_id => lease.id, :iva_exempt => false,
            :amount => e.amount, :start_date => invoice.start_date, :end_date => invoice.end_date, :asset_expense_id => e.id)
        end
      end
    end

    # Calculates all expenses that fall between the lease date (used for conguaglio expenses)
    def expense_total_charge(expenses, lease)
      total = 0.0
      expenses.each do |expense|
        # Complete charge. Expense falls inside lease duration completely
        if lease.start_date <= expense.start_date && lease.end_date >= expense.end_date
          total += expense.amount
        else
          # Expense started after lease started, but lease ended before expense ended
          if lease.start_date <= expense.start_date && lease.end_date <= expense.end_date
            num_days = (expense.start_date..lease.end_date).count
          # Expense started before lease started, but expense ended before lease ended
          elsif lease.start_date >= expense.start_date && lease.end_date >= expense.end_date 
            num_days = (lease.start_date..expense.end_date).count
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
    def total_expense_charges(lease_expense)
      last_balanced = lease_expense.invoice_charges.where(:balanced => true).order("created_at DESC").first
      if last_balanced
        charges = lease_expense.invoice_charges.where("end_date > ?", last_balanced.end_date).all
      else
        charges = lease_expense.invoice_charges.all
      end
      charges.map(&:amount).sum
    end
    
    def apartment_expenses(lease)
      lease.apartment.asset_expenses.where("invoice_id IS NULL AND lease_id = ? and balance_date IS NULL", lease.id).all
    end
    
  end
  
end