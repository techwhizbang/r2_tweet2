module Twitter
  class Status < Base
    STATUSES_UPDATE = "https://twitter.com/statuses/update"
    STATUSES_REPLIES = "https://twitter.com/statuses/replies"
    STATUSES_USER_TIMELINE = "https://twitter.com/statuses/user_timeline"
    STATUSES_FRIENDS_TIMELINE = "https://twitter.com/statuses/friends_timeline"
    STATUSES_PUBLIC_TIMELINE = "http://twitter.com/statuses/public_timeline"
    STATUSES_DESTROY  = "https://twitter.com/statuses/destroy"
    STATUSES_FRIENDS = "https://twitter.com/statuses/friends"
    STATUSES_FOLLOWERS = "http://twitter.com/statuses/followers"

    def initialize(user = nil, password = nil)
      @user = user ||= Twitter::Config.user
      @password = password ||= Twitter::Config.password
    end

    def update(status, options={:format => :json})
      form_data = {'status' => status}
      form_data.merge!({'source' => options[:source]}) if options[:source]
      form_data.merge!({'in_reply_to_status_id' => options[:in_reply_to_status_id]}) if options[:in_reply_to_status_id]
      connection = Connection.new STATUSES_UPDATE, options[:format]
      response = connection.http_connect(form_data, true, @user, @password) { connection.create_http_post_request }
      response_conversion(response.body, options[:format])
    end
    alias :post :update
    alias :tweet :update

    def response_conversion(body, format)
      response = super(body, format)
    	StatusResult.new(response)
    end
  end
end
