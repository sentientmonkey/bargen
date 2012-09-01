require 'barby/barcode/code_128'
require 'barby/barcode/qr_code'
require 'barby/barcode/data_matrix'
require 'barby/outputter/html_outputter'
require 'barby/outputter/rmagick_outputter'

class BargenApp < Sinatra::Base
  set :cache, Dalli::Client.new
  set :ttl, 60 #1 minute

  helpers do
    def render_barcode(barcode, format)
      case format
      when "png"
        [200, {"Content-Type" => "image/png"}, barcode.to_png]
      when "jpg"
        [200, {"Content-Type" => "image/jpeg"}, barcode.to_jpg]
      when "gif"
        [200, {"Content-Type" => "image/gif"}, barcode.to_gif]
      else
        barcode.to_html
      end
    end

    def cache(key, &block)
      value = settings.cache.get(key)
      unless value
        value = yield
        settings.cache.set(key, value)
      end
      value
    end

  end

  get "/" do
    "I generate barcodes."
  end

  get "/bc/:text.?:format?" do
    cache "bc-#{params[:text]}-#{params[:format] || 'html'}" do
      render_barcode Barby::Code128B.new(params[:text]), params[:format]
    end
  end

  get "/qr/:text.?:format?" do
    cache "qr-#{params[:text]}-#{params[:format] || 'html'}" do
      render_barcode Barby::QrCode.new(params[:text]), params[:format]
    end
  end

  get "/dm/:text.?:format?" do
    cache "dm-#{params[:text]}-#{params[:format] || 'html'}" do
      render_barcode Barby::DataMatrix.new(params[:text]), params[:format]
    end
  end

end
