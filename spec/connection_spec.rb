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
end
