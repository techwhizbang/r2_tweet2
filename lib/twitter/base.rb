module Twitter
  class Base
    def response_conversion(body, format)
    	format == :json ? ActiveSupport::JSON.decode(body) : body
    end
  end
end
