module InvoiceExpenseHelper
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def charge_lease_expenses(lease, invoice, invoice_date=Date.today)
      lease.asset_expenses.each do |lease_expense|
        charge_start = invoice.start_date
        charge_end = invoice.end_date

        if lease_expense.expense
          balance_date = lease_expense.expense.balance_date.value
          if Date.same_month?(balance_date, invoice_date.prev_month) || (Date.same_month?(balance_date, invoice_date) && balance_date <= invoice_date)
            aexpenses = lease.apartment.asset_expenses.where("balance_date IS NOT NULL AND expense_id = ? AND " +
             "start_date <= ?::date AND end_date >= ?::date", lease_expense.expense.id, lease.end_date, lease.start_date).all
            if aexpenses.size > 0
              expense_calc = expense_total_charge(aexpenses, lease)
              amount = lease.end_date > invoice_date ? lease_expense.amount : 0
              total =  expense_calc + amount - total_expense_charges(lease, lease_expense)
              invoice.invoice_charges.build(:kind => "building_expense", :lease_id => lease.id,
                :iva_exempt => lease_expense.expense.iva_exempt, :amount => total, :start_date => charge_start,
                :end_date => charge_end, :asset_expense_id => lease_expense.id)
            else
              invoice.invoice_charges.build(:kind => "building_expense", :lease_id => lease.id, 
                :iva_exempt => lease_expense.expense.iva_exempt, :amount => lease_expense.amount, :start_date => charge_start,
                :end_date => charge_end, :asset_expense_id => lease_expense.id)
            end
          else
            invoice.invoice_charges.build(:kind => "building_expense", :lease_id => lease.id, 
              :iva_exempt => lease_expense.expense.iva_exempt, :amount => lease_expense.amount, :start_date => charge_start,
              :end_date => charge_end, :asset_expense_id => lease_expense.id)
          end
        end
      end
    end

    def charge_apartment_expenses(lease, invoice, invoice_date=Date.today)
      apartment_expenses(lease).each do |e|
        invoice.invoice_charges.build(:kind => "apartment_expense", :lease_id => lease.id, :iva_exempt => false,
          :amount => e.amount, :start_date => invoice.start_date, :end_date => invoice.end_date, :asset_expense_id => e.id)
      end
    end

    def expense_total_charge(expenses, lease)
      total = 0
      expenses.each do |expense|
        if lease.start_date >= expense.start_date && lease.end_date >= expense.end_date
          total += expense.amount
        else
          if lease.start_date >= expense.start_date && lease.end_date <= expense.end_date
            num_days = (lease.start_date..lease.end_date).count
          elsif lease.start_date >= expense.start_date && lease.end_date >= expense.end_date
            num_days = (lease.start_date..expense.end_date).count
          else
            num_days = (expense.start_date..lease.end_date).count
          end
          expense_num_days = (expense.start_date..expense.end_date).count
          total += num_days/expense_num_days.to_f * expense.amount
        end
      end
      total
    end

    def total_expense_charges(lease, expense)
      lease.invoice_charges.where(:kind => "building_expense", :asset_expense_id => expense.id).all.map(&:amount).sum
    end
    
    def apartment_expenses(lease)
      lease.apartment.asset_expenses.where("invoice_id IS NULL AND lease_id = ? and balance_date IS NULL", lease.id).all
    end
    
  end
  
end