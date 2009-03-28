require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twitter, 'update' do
  it 'should be over ssl 443 if it is one of the statuses rest calls' do
    connection = Twitter::Connection.new(Twitter::Status::STATUSES_UPDATE)
    connection.http.port.should == 443
  end
end