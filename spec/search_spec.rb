require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twitter, "search" do
  before(:each) do
    
  end

  it 'should have the correct search path' do
    connection = Twitter::Connection.new(Twitter::Search::SEARCH)
    connection.url.path.should == "/search.json"
  end

  it 'should be over port 80 if it is one of the search api calls' do
    connection = Twitter::Connection.new(Twitter::Search::SEARCH)
    connection.http.port.should == 80
  end

  describe "combine search operators" do
    it 'should return just keywords' do

    end

    it 'should return from and keywords' do
     
    end

    it 'should return to and keywords' do
     
    end

    it 'should return referencing and keywords' do
    
    end

    it 'should return hashtag and keywords' do
    
    end

    it 'should return hashtag, and from' do
    
    end
    
  end

end