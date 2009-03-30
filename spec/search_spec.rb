require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twitter, "search" do

  it 'should point to the Twitter search API' do
    Twitter::Search::SEARCH.should == "http://search.twitter.com/search"
  end

  it 'should initialize a new search object' do
    Twitter::Search.new.should_not be_nil
  end

  it 'should initialize a new object with search keywords' do
    Twitter::Search.new("ruby on rails").query.should == {:q=>["ruby on rails"]}
  end

  it 'should include Enumerable' do
    Twitter::Search.include?(Enumerable).should == true
  end

  describe "search operators" do
   
    it 'should return from and keywords' do
      s = Twitter::Search.new
      s.containing("ruby on rails").from('techwhizbang')
      s.query.should == {:q=>["ruby on rails", "from:techwhizbang"]}
    end

    it 'should return to and keywords' do
      s = Twitter::Search.new
      s.containing("ruby on rails").to('techwhizbang')
      s.query.should == {:q=>["ruby on rails", "to:techwhizbang"]}
    end

    it 'should return referencing and keywords' do
      s = Twitter::Search.new
      s.containing("ruby on rails").ref('techwhizbang')
      s.query.should == {:q=>["ruby on rails", "@techwhizbang"]}
    end

    it 'should return hashtag and keywords' do
      s = Twitter::Search.new
      s.containing("ruby on rails").hashed('techwhizbang')
      s.query.should == {:q=>["ruby on rails", "#techwhizbang"]}
    end

    it 'should return hashtag, to, from, ref, and keywords' do
      s = Twitter::Search.new
      s.containing("ruby on rails").hashed('techwhizbang').to('techwhizbang').from('techwhizbang')
      s.query.should == {:q=>["ruby on rails", "#techwhizbang", "to:techwhizbang", "from:techwhizbang"]}
    end

    it 'should contain per page' do
      s = Twitter::Search.new
      s.per_page(200)
      s.query.should == {:q=>[], :rpp => 200}
    end

    it 'should contain page' do
      s = Twitter::Search.new
      s.page(200)
      s.query.should == {:q=>[], :page => 200}
    end

    it 'should contain lang' do
      s = Twitter::Search.new
      s.lang('en')
      s.query.should == {:q=>[], :lang => 'en'}
    end

    it 'should contain since' do
      s = Twitter::Search.new
      s.since(12345)
      s.query.should == {:q=>[], :since_id => 12345}
    end

    it 'should contain geocode' do
      s = Twitter::Search.new
      s.geocode(12.23245, 224.234, 50)
      s.query.should == {:q=>[], :geocode=>"12.23245,224.234,50"}
    end

    it 'should clear the query out' do
      s = Twitter::Search.new
      s.containing("ruby on rails").hashed('techwhizbang').to('techwhizbang').from('techwhizbang')
      s.clear.query.should == {:q => []}
    end
    
  end

  describe 'search API call' do

    before(:each) do
      @connection = Twitter::Connection.new Twitter::Search::SEARCH
      @results = stub('response', :body => {'a' => 'a', 'b' => 'b', 'results' => [{'text' => 'blah'}, {'text' => 'blah'}]}.to_json)
      @connection.stub!(:http_connect).and_return(@results)
    end

    it 'should join query search terms if they are an array' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Search.new
      s.containing("blah blah blah")
      s.query[:q].should_receive(:join)
      s.fetch
    end

    it 'should call the response conversion method' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Search.new
      s.containing("blah blah blah")
      s.should_receive(:response_conversion)
      s.fetch
    end

    it 'should return a search result info object if the format is json' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Search.new
      s.containing("blah blah blah")
      s.fetch.is_a?(Twitter::SearchResultsInfo).should == true
    end

    it 'should return plain response body if the format isnt json' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Search.new
      s.containing("blah blah blah")
      s.fetch(:atom).is_a?(Twitter::SearchResultsInfo).should == false
    end
    
    it 'should iterate through the search results' do
      Twitter::Connection.should_receive(:new).and_return(@connection)
      s = Twitter::Search.new
      s.containing("blah blah blah")
      s.each {|r| r.text.should == "blah"}
    end

  end

end