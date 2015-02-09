class DocumentUploader < CarrierWave::Uploader::Base
  storage :file
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  # def filename
  #   "#{Time.now.strftime('%Y%m%d%H%M%S')}.pdf" if original_filename.present? && model.class.to_s == "Invoice"
  # end
  
end