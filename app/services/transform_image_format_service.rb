require 'mini_magick'

class TransformImageFormatService
  attr_accessor :image

  def initialize(image)
    @image = image
  end

  def call(new_format)
    minimagick_image = MiniMagick::Image.open(image.path)
    minimagick_image.format new_format
    minimagick_image.tempfile
  end
end
