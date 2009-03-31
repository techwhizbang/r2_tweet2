require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twitter::Status, 'update' do
  it 'should be over ssl 443 if it is one of the statuses rest calls' do
    connection = Twitter::Connection.new(Twitter::Status::STATUSES_UPDATE)
    connection.http.port.should == 443
  end

  describe 'update API call' do

    before(:each) do
      @connection = Twitter::Connection.new Twitter::Status::STATUSES_UPDATE
      @results = stub('response', :body => {'a' => 'a', 'b' => 'b', 'results' => [{'text' => 'blah'}, {'text' => 'blah'}]}.to_json)
      @connection.stub!(:http_connect).and_return(@results)
    end

    it 'should invoke http connect with basic auth with defaults' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Status.new
      @connection.should_receive(:http_connect).with({"status"=>"status"}, true, "r2_tweet2_plgin", "r2_plugin_123")
      s.update("status", :format => :json)
    end

    it 'should invoke http connect with basic auth with user specififed args' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Status.new("me", "mypass")
      @connection.should_receive(:http_connect).with({"status"=>"status"}, true, "me", "mypass")
      s.update("status", :format => :json)
    end

     it 'should invoke http connect with source' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Status.new
      @connection.should_receive(:http_connect).with({"status"=>"status", "source"=>:me}, true, "r2_tweet2_plgin", "r2_plugin_123")
      s.update("status", :format => :json, :source => :me)
    end

     it 'should invoke http connect with in reply to' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Status.new
      @connection.should_receive(:http_connect).with({"status"=>"status", "in_reply_to_status_id"=> 12345}, true, "r2_tweet2_plgin", "r2_plugin_123")
      s.update("status", :format => :json, :in_reply_to_status_id => 12345)
    end

    it 'should call the response conversion method' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Status.new
      s.should_receive(:response_conversion)
      s.update("status")
    end

    it 'should return a search result info object if the format is json' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Status.new
      s.update("status").is_a?(Twitter::StatusResult).should == true
    end

    it 'should return plain response body if the format isnt json' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Status.new
      s.update("status", :format => :atom).is_a?(Twitter::StatusResult).should == false
    end

    it 'should respond to post as alias for update' do
      s = Twitter::Status.new
      s.respond_to?(:post).should == true
    end

    it 'should response to tweet as alias for update' do
      s = Twitter::Status.new
      s.respond_to?(:tweet).should == true
    end

  end
end