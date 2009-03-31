require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twitter::SearchResultsInfo do

  before(:each) do
    @response = {"a" => "b", "c" => "d", "results" => [{:text => "text1"}, {:text => "text2"}, {:text => "text3"}]}
  end
  
  it 'should intialize a new search result info object from a hash' do
    s = Twitter::SearchResultsInfo.new(@response)
    s.should_not be_nil
  end

  it 'should create an array of search result objects' do
    s = Twitter::SearchResultsInfo.new(@response)
    s.results.size.should == 3
    s.results.each do |r|
      r.is_a?(Twitter::SearchResult).should == true
    end
  end

  it 'should respond to hash keys as methods' do
    s = Twitter::SearchResultsInfo.new(@response)
    @response.keys.each do |key|
      s.respond_to?(key.to_sym).should == true
    end
  end
end