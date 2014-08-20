require 'spec_helper'

describe Tweetlr::Processors::Twitter do
  before :all do
    config_file = File.join( Dir.pwd, 'config', TWEETLR_CONFIG_FILE)
    @twitter_config = YAML.load_file(config_file)
  end
  before :each do
    @first_link = "http://url.com"
    @second_link = "http://instagr.am/p/DzCWn/"
    @third_link = "https://imageurl.com"
    @twitter_response = {"from_user_id_str"=>"1915714", "profile_image_url"=>"http://a0.twimg.com/profile_images/386000279/2_normal.jpg", "created_at"=>"Sun, 17 Apr 2011 16:48:42 +0000", "from_user"=>"whitey_Mc_whIteLIst", "id_str"=>"59659561224765440", "metadata"=>{"result_type"=>"recent"}, "to_user_id"=>nil, "text"=>"Rigaer #wirsounterwegs #{@first_link}  @ Augenarzt Dr. Lierow #{@second_link} #{@third_link}", "id"=>59659561224765440, "from_user_id"=>1915714, "geo"=>{"type"=>"Point", "coordinates"=>[52.5182, 13.454]}, "iso_language_code"=>"de", "place"=>{"id"=>"3078869807f9dd36", "type"=>"city", "full_name"=>"Berlin, Berlin"}, "to_user_id_str"=>nil, "source"=>"&lt;a href=&quot;http://instagr.am&quot; rel=&quot;nofollow&quot;&gt;instagram&lt;/a&gt;"}
  end
  describe "#search(config)" do
    it "searches twitter for a given term" do
      response = Tweetlr::Processors::Twitter::search @twitter_config
      tweets = response.statuses
      tweets.should be
      tweets.should_not be_empty
    end
    it "copes with errors by retrying, not raising" do
      ::Twitter.stub(:search).and_raise(::Twitter::Error::TooManyRequests)
      Tweetlr::Processors::Twitter.stub!(:sleep) #releasing the sleep handbrake...
      expect { Tweetlr::Processors::Twitter.call_twitter_api('mocky wocky',{})}.to_not raise_error(::Twitter::Error::TooManyRequests)
    end
    it "copes with client errors" do
      ::Twitter.stub(:search).and_raise(::Twitter::Error::ClientError)
      expect { Tweetlr::Processors::Twitter.call_twitter_api('mocky wocky',{})}.to_not raise_error(::Twitter::Error::TooManyRequests)
    end
  end
  describe "#lazy_search(config)" do
    it "searches twitter for a given term" do
      response = Tweetlr::Processors::Twitter::lazy_search @twitter_config
      tweets = response['results']
      tweets.should be
      tweets.should_not be_empty
    end
    it "copes with nil as input" do
      Tweetlr::Processors::Twitter::lazy_search(nil).should be_nil
    end
  end
  describe "#extract_links()" do
    it "extracts links" do
      links = Tweetlr::Processors::Twitter::extract_links ''
      links.should be_nil
      links = Tweetlr::Processors::Twitter::extract_links @twitter_response
      links[0].should == @first_link
      links[1].should == @second_link
      links[2].should == @third_link
    end
  end
end