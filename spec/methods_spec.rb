require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :fake_tweet_records do |t|
      t.column :title, :string
      t.column :message, :string
    end
  end
end

class FakeTweetRecord < ActiveRecord::Base
  r2_tweet2 :attributes => [:message, :title],
            :callbacks => [:after_save, :after_destroy],
            :include => [:tweet]
end

class SomeTweetRecord < ActiveRecord::Base
  r2_tweet2 :attributes => ['message', 'title'],
            :include => [:tweet]
end

class PlainOldClass
  include Twitter::R2Tweet2
  attr_accessor :author, :brief
  r2_tweet2(:attributes => ['author', 'brief'])

  def author_and_brief
    author + " " + brief
  end
end

class PlainOldClassWithMethod
  include Twitter::R2Tweet2
  attr_accessor :author, :brief
  r2_tweet2(:attributes => ['author_and_brief'])

  def author_and_brief
    author + " " + brief
  end
end

describe Twitter::R2Tweet2 do
  before(:all) do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")
    setup_db
  end

  after(:all) do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  it 'should assign tweet attributes by symbol' do
    FakeTweetRecord.r2_tweet2_attributes.should == [:message, :title]
  end

  it 'should assign tweet attribute by string' do
    SomeTweetRecord.r2_tweet2_attributes.should == ['message', 'title']
  end

  it 'should assign inclusions only if callbacks are specified' do
    FakeTweetRecord.r2_tweet2_inclusions.should == [:tweet]
  end

  it 'should not assign inclusions if callbacks are missing' do
    SomeTweetRecord.r2_tweet2_inclusions.should be_nil
  end

  it 'should return a formatted status messsage' do
    fake_tweet = FakeTweetRecord.new(:title => 'test', :message => 'Twitter rocks')
    fake_tweet.send(:status_update).should == "Twitter rocks test"
  end

  it 'should assign optional callback methods' do
    FakeTweetRecord.r2_tweet2_callbacks.should == [:after_save, :after_destroy]
  end

  it 'should send a tweet on save' do
    fake_tweet = FakeTweetRecord.new(:title => 'test')
    fake_tweet.should_receive(:tweet).once
    fake_tweet.save!
  end

  it 'should send a tweet on destroy' do
    fake_tweet = FakeTweetRecord.new(:title => 'test')
    fake_tweet.should_receive(:tweet).twice
    fake_tweet.save!
    fake_tweet.destroy
  end

  it 'should allow a regular class to tweet' do
    p = PlainOldClass.new
    p.respond_to?(:tweet).should == true
  end

  it 'should return a formatted status message on a regular class' do
    p = PlainOldClass.new
    p.author = "Nick Z"
    p.brief = "twitter bot"
    p.send(:status_update).should == "Nick Z twitter bot"
  end
  
  it 'should return a formmated status message with a method' do
    p = PlainOldClassWithMethod.new
    p.author = "Nick Z"
    p.brief = "twitter bot"
    p.send(:status_update).should == "Nick Z twitter bot"
  end

  it 'should use the configured user for the status update' do
    Twitter::Config.read['user'].should == "r2_tweet2_plgin"
  end

  it 'should user the configured password for the status update' do
    Twitter::Config.read['password'].should == 'r2_plugin_123'
  end

  it 'should call the Twitter update api when tweeting' do
    status = Twitter::Status.new
    Twitter::Status.should_receive(:new).and_return status
    status.should_receive(:update).with("Nick Z twitter bot", :format => :json)
    p = PlainOldClass.new
    p.author = "Nick Z"
    p.brief = "twitter bot"
    p.tweet
  end

end
