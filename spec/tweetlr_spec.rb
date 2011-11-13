require 'spec_helper'

describe Tweetlr do

  config_file = File.join( Dir.pwd, 'config', 'tweetlr.yml')
  config = YAML.load_file(config_file)
  USER = config['tumblr_username']
  PW   = config['tumblr_password']
  TIMESTAMP = config['twitter_timestamp']
  WHITELIST = config['whitelist']

  before :each do
    @credentials = {:email => USER, :password => PW}
    @searchterm = 'fail'
    @tweets = {
      :instagram => {'text' => "jadda jadda http://instagr.am/p/DzCWn/"},
      :twitpic => {'text' => "jadda jadda http://twitpic.com/449o2x"},
      :yfrog => {'text' => "jadda jadda http://yfrog.com/h4vlfp"},
      :picplz => {'text' => "jadda jadda http://picplz.com/2hWv"},
      :imgly => {'text' => "jadda jadda http://img.ly/3M1o"},
      :tco => {'text' => "jadda jadda http://t.co/MUGNayA"},
      :lockerz => {'text' => "jadda jadda http://lockerz.com/s/100269159"},
      :embedly => {'text' => "jadda jadda http://flic.kr/p/973hTv"},
      :twitter_pics => {'text' => "jadda jadda http://t.co/FmyBGfyY"} 
      }
      @links = {
        :instagram => "http://instagr.am/p/DzCWn/",
        :twitpic => "http://twitpic.com/449o2x",
        :yfrog => "http://yfrog.com/h4vlfp",
        :picplz => "http://picplz.com/2hWv",
        :imgly => "http://img.ly/3M1o",
        :tco => 'http://t.co/MUGNayA',
        :lockerz => 'http://lockerz.com/s/100269159',
        :embedly => 'http://flic.kr/p/973hTv',
        :twitter_pics => 'http://t.co/FmyBGfyY' 
        }
    @first_link = "http://url.com"
    @second_link = "http://instagr.am/p/DzCWn/"
    @third_link = "https://imageurl.com"
    @twitter_response = {"from_user_id_str"=>"1915714", "profile_image_url"=>"http://a0.twimg.com/profile_images/386000279/2_normal.jpg", "created_at"=>"Sun, 17 Apr 2011 16:48:42 +0000", "from_user"=>"whitey_Mc_whIteLIst", "id_str"=>"59659561224765440", "metadata"=>{"result_type"=>"recent"}, "to_user_id"=>nil, "text"=>"Rigaer #wirsounterwegs #{@first_link}  @ Augenarzt Dr. Lierow #{@second_link} #{@third_link}", "id"=>59659561224765440, "from_user_id"=>1915714, "geo"=>{"type"=>"Point", "coordinates"=>[52.5182, 13.454]}, "iso_language_code"=>"de", "place"=>{"id"=>"3078869807f9dd36", "type"=>"city", "full_name"=>"Berlin, Berlin"}, "to_user_id_str"=>nil, "source"=>"&lt;a href=&quot;http://instagr.am&quot; rel=&quot;nofollow&quot;&gt;instagram&lt;/a&gt;"}
    @non_whitelist_tweet = @twitter_response.merge 'from_user' => 'nonwhitelist user' 
    @retweet = @twitter_response.merge "text" => "bla bla RT @fgd: tueddelkram"
    @new_style_retweet = @twitter_response.merge "text" => "and it scales! \u201c@moeffju: http://t.co/8gUSPKu #hktbl1 #origami success! :)\u201d"
    @new_style_retweet_no_addition = @twitter_response.merge "text" => "\u201c@moeffju: http://t.co/8gUSPKu #hktbl1 #origami success! :)\u201d"
    @config_file = File.join( Dir.pwd, 'config', 'tweetlr.yml')
    @tweetlr = Tweetlr.new(USER, PW, {:whitelist => WHITELIST, :results_per_page => 5, :since_id => TIMESTAMP, :terms => @searchterm, :loglevel => 4})
  end
  it "should post to tumblr" do
    stub_tumblr
    tumblr_post = @tweetlr.generate_tumblr_photo_post @twitter_response
    tumblr_post[:date] = Time.now.to_s
    response = @tweetlr.post_to_tumblr tumblr_post
    response.should be
    response.response_code.should be 201
  end
  it "should search twitter for a given term" do
    stub_twitter
    tweetlr = @tweetlr
    response = tweetlr.lazy_search_twitter
    tweets = response['results']
    tweets.should be
    tweets.should_not be_empty
  end
  context "given a user whitelist" do
    it "should mark whitelist users' tweets as published" do
      stub_instagram
      post = @tweetlr.generate_tumblr_photo_post @twitter_response
      post[:state].should == 'published' 
    end
    it "should mark non whitelist users' tweets as drafts" do
      stub_instagram
      post = @tweetlr.generate_tumblr_photo_post @non_whitelist_tweet
      post[:state].should == 'draft' 
    end
  end
  context "without a user whitelist" do
    before :each do
      @tweetlr = Tweetlr.new(USER, PW, {
        :whitelist => nil, 
        :results_per_page => 5, 
        :since_id => TIMESTAMP, 
        :terms => @searchterm, 
        :loglevel => 4})
    end
    it "should mark every users' posts as published" do
      stub_instagram
      post = @tweetlr.generate_tumblr_photo_post @twitter_response
      post[:state].should == 'published'
      stub_instagram
      post = @tweetlr.generate_tumblr_photo_post @non_whitelist_tweet
      post[:state].should == 'published'
    end
  end
  it "should not use retweets which would produce double blog posts" do
    post = @tweetlr.generate_tumblr_photo_post @retweet
    post.should_not be
  end
  context "should not use new style retweets which would produce double blog posts" do
    it "for quotes in context" do
      post = @tweetlr.generate_tumblr_photo_post @new_style_retweet
      post.should_not be
    end
    it "for quotes without further text addition" do
      post = @tweetlr.generate_tumblr_photo_post @new_style_retweet_no_addition
      post.should_not be
    end
  end
  context "handles pictures in tweets" do
    it "extracting their corresponding links" do
      @tweets.each do |key,value|
        send "stub_#{key}"
        url = @tweetlr.extract_image_url value
        url.should be, "service #{key} not working!"
        check_pic_url_extraction key if [:instagram,:picplz,:yfrog,:imgly,:not_listed].index key
      end
    end
    it "using the first image link found in a tweet with multiple links" do
      stub_instagram
      link = @tweetlr.extract_image_url @twitter_response
      link.should == 'http://distillery.s3.amazonaws.com/media/2011/05/02/d25df62b9cec4a138967a3ad027d055b_7.jpg'
    end
    it "not returning links that do not belong to images" do
      stub_no_image_link
      link = @tweetlr.extract_image_url @twitter_response
      link.should_not be
    end
  end
end
