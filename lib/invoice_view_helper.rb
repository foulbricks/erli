module InvoiceViewHelper
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def renderer
      av = ActionView::Base.new()
      av.view_paths = ActionController::Base.view_paths
      av.class_eval do
        include Rails.application.routes.url_helpers
        include ApplicationHelper
        def protect_against_forgery?
          false
        end
      end
      av
    end
  
    def tempfile(pdf_string)
      name = Time.now.to_i.to_s
      tempfile = Tempfile.new([name, ".pdf"], Rails.root.join('tmp'))
      tempfile.binmode
      tempfile.write pdf_string
      tempfile.close
      tempfile
    end
  
    def render_pdf(lease, invoice, invoice_date)
      building_id = lease.apartment.building.id
      setup = Setup.where(:building_id => building_id).first || Setup.new
      company = Company.first || Company.new
      
      if setup && setup.invoice_delivery.present?
        deliver_date = invoice_date.change(:day => setup.invoice_delivery)
      else
        deliver_date = invoice_date.end_of_month
      end
      deliver_date = deliver_date.next_month if deliver_date <= invoice_date
      
      pdf_html = renderer.render :template => "layouts/invoice.html.erb", :layout => nil, encoding: 'utf8',
                                 :locals => {:company => company, :lease => lease, :invoice => invoice, 
                                             :invoice_date => invoice_date, :setup => setup, :deliver_date => deliver_date }
                                             
      WickedPdf.new.pdf_from_string(pdf_html, :page_size => "Letter")
    end
  end
  
end