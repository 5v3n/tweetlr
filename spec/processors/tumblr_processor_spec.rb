require 'spec_helper'

describe Tweetlr::Processors::Tumblr do
  before :all do
    config_file = File.join( Dir.pwd, 'config', TWEETLR_CONFIG_FILE)
    config = YAML.load_file(config_file)
    @twitter_response = {"from_user_id_str"=>"1915714", "profile_image_url"=>"http://a0.twimg.com/profile_images/386000279/2_normal.jpg", "created_at"=>"Sun, 17 Apr 2011 16:48:42 +0000", "from_user"=>"whitey_Mc_whIteLIst", "id_str"=>"59659561224765440", "metadata"=>{"result_type"=>"recent"}, "to_user_id"=>nil, "text"=>"Rigaer #wirsounterwegs #{@first_link}  @ Augenarzt Dr. Lierow #{@second_link} #{@third_link}", "id"=>59659561224765440, "from_user_id"=>1915714, "geo"=>{"type"=>"Point", "coordinates"=>[52.5182, 13.454]}, "iso_language_code"=>"de", "place"=>{"id"=>"3078869807f9dd36", "type"=>"city", "full_name"=>"Berlin, Berlin"}, "to_user_id_str"=>nil, "source"=>"&lt;a href=&quot;http://instagr.am&quot; rel=&quot;nofollow&quot;&gt;instagram&lt;/a&gt;"}
    @tweetlr_config = config
  end
  it "posts to tumblr" do
    stub_tumblr
    stub_oauth
    tumblr_post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @twitter_response, @tweetlr_config
    tumblr_post[:date] = Time.now.to_s
    tumblr_post[:source] = 'http://distilleryimage6.instagram.com/db72627effde11e1b3f322000a1e8899_7.jpg'
    response = Tweetlr::Processors::Tumblr::post @tweetlr_config.merge(tumblr_post)
    response.should be
    response.code.should == "201"
  end
end
