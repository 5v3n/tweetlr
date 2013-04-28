require 'spec_helper'

describe Tweetlr::Core do

  config_file = File.join( Dir.pwd, 'config', 'tweetlr.yml.test')
  config = YAML.load_file(config_file)
  TIMESTAMP = config['twitter_timestamp']
  WHITELIST = config['whitelist']

  let(:tweetlr_config) do
    {
      :since_id => 0,
      :results_per_page => 3,
      :search_term => 'coffeediary',
      :result_type => 'recent',  
      :api_endpoint_twitter => Tweetlr::API_ENDPOINT_TWITTER,
      :loglevel=>1,
      :tumblr_oauth_access_token_key => config['tumblr_oauth_access_token_key'],
      :tumblr_oauth_access_token_secret => config['tumblr_oauth_access_token_secret'],
      :tumblr_oauth_api_secret => config['tumblr_oauth_api_secret'],
      :tumblr_oauth_api_key => config['tumblr_oauth_api_key'],
      :tumblr_blog_hostname => config['tumblr_blog_hostname']
    }
  end
  let(:stubbed_tumblr_post) do
    {:tumblr_blog_hostname=>nil, :type=>"photo", :date=>"Sun, 28 Apr 2013 14:10:43 +0000", :source=>"https://irs0.4sqi.net/img/general/600x600/304170_IfHzPdhxs9mpGlPk8jogxdul8q8KhTBNmeAiP9H5TyY.jpg", :tags=>"sven_kr", :state=>"published", :caption=>"<a href=\"http://twitter.com/sven_kr/statuses/328511599881097216\" alt=\"tweet\">@sven_kr</a>: #coffeediary Wanted to stay at home but had to test the new tweetlr ;-) (@ Mamalicious w/ @snoopsmaus) [pic]: http://t.co/7ilE9BDJxJ"}
  end
  let(:first_link) { "http://url.com" }
  let(:second_link) { "http://instagr.am/p/DzCWn/" }
  let(:third_link) { "https://imageurl.com" }
  let(:twitter_response) { {"from_user_id_str"=>"1915714", "profile_image_url"=>"http://a0.twimg.com/profile_images/386000279/2_normal.jpg", "created_at"=>"Sun, 17 Apr 2011 16:48:42 +0000", "from_user"=>"whitey_Mc_whIteLIst", "id_str"=>"59659561224765440", "metadata"=>{"result_type"=>"recent"}, "to_user_id"=>nil, "text"=>"Rigaer #wirsounterwegs #{first_link}  @ Augenarzt Dr. Lierow #{second_link} #{third_link}", "id"=>59659561224765440, "from_user_id"=>1915714, "geo"=>{"type"=>"Point", "coordinates"=>[52.5182, 13.454]}, "iso_language_code"=>"de", "place"=>{"id"=>"3078869807f9dd36", "type"=>"city", "full_name"=>"Berlin, Berlin"}, "to_user_id_str"=>nil, "source"=>"&lt;a href=&quot;http://instagr.am&quot; rel=&quot;nofollow&quot;&gt;instagram&lt;/a&gt;"} }

  describe ".new" do
    it "initializes a new instance" do
      new_instance = Tweetlr::Core.new tweetlr_config
      new_instance.should be
    end
  end
  describe ".crawl(config)" do
    before(:each) do
      stub_tumblr
      stub_twitter
      stub_oauth
    end
    it "crawls twitter and posts to tumblr" do 
      Tweetlr::Combinators::TwitterTumblr.stub(:generate_photo_post_from_tweet).and_return stubbed_tumblr_post
      since_id_before = tweetlr_config[:since_id]
      result = Tweetlr::Core.crawl(tweetlr_config)
      since_id_before.should_not == result[:since_id]
    end
    it "copes with legacy config that use tumblr v1 api (basic auth)" do
      legacy_config = {
        :id=>16, 
        :search_term=>"booga", 
        :tumblr_email=>"wooga@booga.de", 
        :tumblr_password=>"boogawooga", 
        :since_id=>"246543935663661057", 
        :results_per_page=>3, 
        :result_type=>nil, 
        :api_endpoint_twitter=>nil, 
        :api_endpoint_tumblr=>nil, 
        :update_period=>900, 
        :shouts=>nil, 
        :loglevel=>1, 
        :whitelist=>["user1", "user2"],
        :last_crawl=>"Fri, 14 Sep 2012 09:43:10 UTC +00:00",
        :active=>true,
        :tumblr_oauth_access_token_key=>nil, 
        :tumblr_oauth_access_token_secret=>nil}
      since_id_before = legacy_config[:since_id]
      result = Tweetlr::Core.crawl(legacy_config)
      since_id_before.should_not == result[:since_id]
    end
  end
end
