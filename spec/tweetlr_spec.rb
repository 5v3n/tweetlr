require 'spec_helper'

describe Tweetlr do

  config_file = File.join( Dir.pwd, 'config', 'tweetlr.yml')
  config = YAML.load_file(config_file)
  USER = config['tumblr_username']
  PW   = config['tumblr_password']
  TIMESTAMP = config['twitter_timestamp']
  WHITELIST = config['whitelist']

  before :each do
    @first_link = "http://url.com"
    @second_link = "http://instagr.am/p/DzCWn/"
    @third_link = "https://imageurl.com"
    @twitter_response = {"from_user_id_str"=>"1915714", "profile_image_url"=>"http://a0.twimg.com/profile_images/386000279/2_normal.jpg", "created_at"=>"Sun, 17 Apr 2011 16:48:42 +0000", "from_user"=>"whitey_Mc_whIteLIst", "id_str"=>"59659561224765440", "metadata"=>{"result_type"=>"recent"}, "to_user_id"=>nil, "text"=>"Rigaer #wirsounterwegs #{@first_link}  @ Augenarzt Dr. Lierow #{@second_link} #{@third_link}", "id"=>59659561224765440, "from_user_id"=>1915714, "geo"=>{"type"=>"Point", "coordinates"=>[52.5182, 13.454]}, "iso_language_code"=>"de", "place"=>{"id"=>"3078869807f9dd36", "type"=>"city", "full_name"=>"Berlin, Berlin"}, "to_user_id_str"=>nil, "source"=>"&lt;a href=&quot;http://instagr.am&quot; rel=&quot;nofollow&quot;&gt;instagram&lt;/a&gt;"}
    @tweetlr_config =  {
      :tumblr_email => USER,
      :tumblr_pw => PW,
      :whitelist => WHITELIST,
      :since_id => 0,
      :search_term => 'moped',
      :results_per_page => 100,
      :result_type => 'recent',  
      :api_endpoint_twitter => Tweetlr::API_ENDPOINT_TWITTER
    }
  end
  it "should post to tumblr" do
    stub_tumblr
    tumblr_post = Combinators::TwitterTumblr::generate_photo_post_from_tweet @twitter_response
    tumblr_post[:date] = Time.now.to_s
    response = Processors::Tumblr::post tumblr_post.merge({:email => USER, :password => PW})
    response.should be
    response.response_code.should be 201
  end
  it "crawls twitter and posts to tumblr" do 
    stub_tumblr
    stub_twitter
    Tweetlr.crawl(@tweetlr_config)
  end


end
