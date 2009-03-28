module Twitter
  module Config
    mattr_accessor(:read)

    if File.exists?( RAILS_ROOT + '/config/r2_tweet2.yml' )
      self.read = YAML::load_file( RAILS_ROOT + '/config/r2_tweet2.yml' )[RAILS_ENV]

    else
      self.read = YAML::load_file( File.expand_path(File.join(File.dirname(__FILE__), '/../r2_tweet2.yml' )) )[RAILS_ENV]
    end

    @@user_agent = self.read['user_agent']
    @@client_app = self.read['client_app']
    @@client_url = self.read['client_url']
    @@user = self.read['user']
    @@password = self.read['password']
    @@proxy_host = self.read['proxy_host']
    @@proxy_port = self.read['proxy_port']
    @@proxy_pass = self.read['proxy_pass']
    @@proxy_user = self.read['proxy_user']
    
    mattr_reader(:user_agent,
                 :client_app, :client_url,
                 :user, :password, :proxy_host,
                 :proxy_port, :proxy_pass, :proxy_user)
  end 
end