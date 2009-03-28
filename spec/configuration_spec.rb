require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twitter::Config do

  it 'should initalize the user' do
    Twitter::Config.user.should == "r2_tweet2_plgin"
  end

  it 'should initialize the password' do
    Twitter::Config.password.should == "r2_plugin_123"
  end

  it 'should initialize the user agent' do
    Twitter::Config.user_agent.should == "r2_tweet2_plugin_agent"
  end

  it 'should initialize the proxy host' do
    Twitter::Config.proxy_host.should == "test.com"
  end

  it 'should initialiaze the proxy port' do
    Twitter::Config.proxy_port.should == 5000
  end

  it 'should initalize the proxy pass' do
    Twitter::Config.proxy_pass.should == "proxy_pass"
  end

  it 'should initalize the proxy user' do
    Twitter::Config.proxy_user.should == "proxy_user"
  end

  it 'should initialize the client app' do
    Twitter::Config.client_app.should == "r2_tweet2_development"
  end

  it 'should initialize the client url' do
    Twitter::Config.client_url.should == "http://github.com/techwhizbang/r2_tweet2"
  end
end
