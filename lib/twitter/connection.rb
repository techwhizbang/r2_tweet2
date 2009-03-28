module Twitter
  class ConnectionException < Exception; end

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

    def handle_response(response)
      unless response.is_a?(Net::HTTPSuccess)
        raise ConnectionException.new(response)
      end
    end

    # Returns the response of the HTTP connection.
    def http_connect(form_data = nil, require_auth = false, user = nil, password = nil, &block)
    	raise "block is required" unless block_given?
    	@http.start do |connection|
    		request = yield connection if block_given?
    		request.basic_auth(user, password) if require_auth
        request.set_form_data(form_data)
    		response = connection.request(request)
    		handle_response(response)
    		response
      end
    end

    def create_http_get_request(params = {})
    	path = (params.size > 0) ? "#{@url.path}?#{params.to_query}" : uri
      Net::HTTP::Get.new(path, http_header)
    end

    def create_http_post_request
    	Net::HTTP::Post.new(@url.path, http_header)
    end

    def create_http_delete_request(params = {})
    	path = (params.size > 0) ? "#{@url.path}?#{params.to_query}" : uri
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