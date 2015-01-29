class BackgroundUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  
  process :resize_to_fit => [700, 700]
  
  version :opaque do
    process :convert_to_opaque
  end
  
  storage :file
  
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  def convert_to_opaque
    manipulate! do |img|
      img.format("png")
      img.combine_options do |cmd|
        cmd.alpha "on"
        cmd.channel "a"
        cmd.evaluate "set", "25%"
      end
      img = yield(img) if block_given?
      img
    end
  end
  
  def convert_to_grayscale
    manipulate! do |img|
      img.colorspace("Gray")
      img.brightness_contrast("-30x0")
      img = yield(img) if block_given?
      img
    end
  end
  
  def merge
    manipulate! do |img|
      img.combine_options do |cmd|
        cmd.gravity "north"
        cmd.extent "50x100"
      end

      img = img.composite(::MiniMagick::Image.open(model.background.gray.current_path, "jpg")) do |c|
        c.gravity "south"
      end
      img = yield(img) if block_given?
      img
    end
  end
  
end