require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twitter::Connection do
  it 'should contain a Net::HTTP object' do
    connection = Twitter::Connection.new(Twitter::Status::STATUSES_UPDATE)
    connection.http.is_a?(Net::HTTP).should == true
  end

  it 'should use ssl if url is https' do
    connection = Twitter::Connection.new(Twitter::Status::STATUSES_UPDATE)
    connection.http.use_ssl?.should == true
  end

  it 'should use proxy information if present' do
    connection = Twitter::Connection.new(Twitter::Search::SEARCH)
    connection.http.proxy_port.should == 5000
    connection.http.proxy_address.should == "test.com"
    connection.http.proxy_user.should == "proxy_user"
    connection.http.proxy_pass.should == "proxy_pass"
  end

  it 'should create a http get request without params' do
    c = Twitter::Connection.new(Twitter::Search::SEARCH)
    Net::HTTP::Get.should_receive(:new).with(c.url.path, c.http_header)
    c.create_http_get_request
  end

  it 'should create a http get request with params' do
    params = {:a => "a", :b => "b"}
    c = Twitter::Connection.new(Twitter::Search::SEARCH)
    Net::HTTP::Get.should_receive(:new).with(c.url.path + "?#{params.to_query}", c.http_header)
    c.create_http_get_request(params)
  end

  it 'should create a http post request' do
    c = Twitter::Connection.new(Twitter::Search::SEARCH)
    Net::HTTP::Post.should_receive(:new).with(c.url.path, c.http_header)
    c.create_http_post_request
  end

  it 'should create a http delete request' do
    c = Twitter::Connection.new(Twitter::Search::SEARCH)
    Net::HTTP::Delete.should_receive(:new).with(c.url.path, c.http_header)
    c.create_http_delete_request
  end

  it 'should create a http delete request with params' do
    params = {:a => "a", :b => "b"}
    c = Twitter::Connection.new(Twitter::Search::SEARCH)
    Net::HTTP::Delete.should_receive(:new).with(c.url.path + "?#{params.to_query}", c.http_header)
    c.create_http_delete_request(params)
  end

  it 'should create a http header' do
    c = Twitter::Connection.new('http://twitter.com/search')
    c.http_header.should == {"User-Agent"=>"R2Tweet2 [r2_tweet2_plugin_agent]",
                             "X-Twitter-Client"=>"r2_tweet2_development",
                             "X-Twitter-Client-URL"=>"http://github.com/techwhizbang/r2_tweet2"}
  end

  it 'handle response should not raise an error if the response if successful' do
    c = Twitter::Connection.new('http://twitter.com')
    c.handle_response(net_http_response_stub)
  end

  it 'handle response should raise an error if the response is not successful' do
    c = Twitter::Connection.new('http://twitter.com')
    lambda {c.handle_response(net_http_response_stub(:server_error)) }.should raise_error(Twitter::ConnectionException)
  end

  it 'should create a http connect block' do
    c = Twitter::Connection.new('http://twitter.com')
    c.http.should_receive(:start)
    c.http_connect { c.create_http_get_request }
  end

  it "should raise an error if a block isn't given" do
    c = Twitter::Connection.new('http://twitter.com')
    c.http.should_not_receive(:start)
    lambda {c.http_connect}.should raise_error(RuntimeError)
  end

  it 'should set basic auth info if auth is required with application config defaults' do
    c = Twitter::Connection.new('http://twitter.com/search')
    stub_http = net_http_block_stub(net_http_response_stub)
    c.http = stub_http
    
    post_request = c.stub!(:create_http_post_request).and_return(net_http_post_stub)
    
    post_request.should_receive(:basic_auth).with('r2_tweet2_plgin', 'r2_plugin_123')
    post_request.should_receive(:set_form_data)
    c.http_connect({}, true) { post_request }
  end

  it 'should set basic auth info if auth is required with those specified' do
    c = Twitter::Connection.new('http://twitter.com/search')
    stub_http = net_http_block_stub(net_http_response_stub)
    c.http = stub_http

    post_request = c.stub!(:create_http_post_request).and_return(net_http_post_stub)

    post_request.should_receive(:basic_auth).with('user', 'password')
    post_request.should_receive(:set_form_data)
    c.http_connect({}, true, 'user', 'password') { post_request }
  end

  it 'should set form data' do
    c = Twitter::Connection.new('http://twitter.com/search')
    stub_http = net_http_block_stub(net_http_response_stub)
    c.http = stub_http

    post_request = c.stub!(:create_http_post_request).and_return(net_http_post_stub)

    post_request.should_receive(:set_form_data).with({:b=>"2", :a=>"1"})
    c.http_connect({:a => '1', :b => '2'}) { post_request }
  end
end
