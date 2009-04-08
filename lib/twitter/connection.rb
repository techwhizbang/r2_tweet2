module Twitter

  class ConnectionException < Net::HTTPError; end

  class Connection
    attr_accessor :http, :url

    def initialize(url, format = :json)
      url +=  ".#{format.to_s}"
      @url = URI.parse(url)
      proxy_port = Twitter::Config.proxy_port
      proxy_host = Twitter::Config.proxy_host
      proxy_user = Twitter::Config.proxy_user
      proxy_pass = Twitter::Config.proxy_pass
      @http = Net::HTTP.new(@url.host, @url.port, proxy_host, proxy_port, proxy_user, proxy_pass)
      @http.read_timeout = 4
      @http.open_timeout = 4

      if @http.port == 443
        @http.use_ssl = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    #consult the Twitter API for an explanation on the response error code that are used
    def handle_response(response)
      if response.is_a?(Net::HTTPSuccess)
        return
      elsif response.is_a?(Net::HTTPNotModified)
        raise ConnectionException.new("#{response.code} Twitter has no new data to return", response)
      elsif response.is_a?(Net::HTTPBadRequest)
        raise ConnectionException.new("#{response.code} you've exceeded your Twitter rate limit", response)
      elsif response.is_a?(Net::HTTPUnauthorized)
        raise ConnectionException.new("#{response.code} Twitter wants authentication credentials, or the credentials provided aren't valid", response)
      elsif response.is_a?(Net::HTTPForbidden)
        raise ConnectionException.new("#{response.code} Twitter understands your request, but is refusing to fulfill it", response)
      elsif response.is_a?(Net::HTTPNotFound)
        raise ConnectionException.new("#{response.code} either you're requesting an invalid Twitter URI or the resource", response)
      elsif response.is_a?(Net::HTTPInternalServerError)
        raise ConnectionException.new("#{response.code} Twitter did something horribly wrong", response)
      elsif response.is_a?(Net::HTTPBadGateway)
        raise ConnectionException.new("#{response.code} Twitter is down or is being upgraded", response)
      elsif response.is_a?(Net::HTTPServiceUnavailable)
        raise ConnectionException.new("#{response.code} Twitter is up, but servers are overloaded", response)
      else
        raise ConnectionException.new("#{response.code} Twitter is throwing a response error code that isn't accounted for", response)
      end
    end

    # Returns the response of the HTTP connection.
    def http_connect(form_data = nil, require_auth = false, 
        user = Twitter::Config.user,
        password = Twitter::Config.password, &block)
    	raise "block is required" unless block_given?
    	@http.start do |connection|
    		request = yield connection if block_given?
    		request.basic_auth(user, password) if require_auth
        request.set_form_data(form_data) if form_data
    		response = connection.request(request)
    		handle_response(response)
    		response
      end
    end

    def create_http_get_request(params = {})
    	path = (params.size > 0) ? "#{@url.path}?#{params.to_query}" : @url.path
      Net::HTTP::Get.new(path, http_header)
    end

    def create_http_post_request
    	Net::HTTP::Post.new(@url.path, http_header)
    end

    def create_http_delete_request(params = {})
    	path = (params.size > 0) ? "#{@url.path}?#{params.to_query}" : @url.path
    	Net::HTTP::Delete.new(path, http_header)
    end

    def http_header
      @@http_header ||= {
        'User-Agent' => "R2Tweet2 [#{Twitter::Config.user_agent}]",
        'X-Twitter-Client' => Twitter::Config.client_app,
        'X-Twitter-Client-URL' => Twitter::Config.client_url,
      }
      @@http_header
    end
  end

end