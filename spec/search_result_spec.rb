require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twitter::SearchResult do

  before(:each) do
   @response = {"text"=>"learning ruby on rails now - just finished a two hour study session on ruby, knackered!","to_user_id"=> nil,"from_user"=>"joafruit","id"=>1417893416,"from_user_id"=>866900,"iso_language_code"=>"en","source"=>"&lt;a href=&quot;http:\/\/twitter.com\/&quot;&gt;web&lt;\/a&gt;","profile_image_url"=>"http:\/\/s3.amazonaws.com\/twitter_production\/profile_images\/56267406\/n781025272_3165051_9149_normal.jpg","created_at"=>"Mon, 30 Mar 2009 14:12:08 +0000"}
  end

  it 'should create a search result object from a hash' do
    s = Twitter::SearchResult.new(@response)
    s.should_not be_nil
  end

  it 'should respond to keys as methods' do
    s = Twitter::SearchResult.new(@response)
    @response.keys.each do |key|
      s.respond_to?(key.to_sym).should == true
    end
  end
end