require 'spec_helper'

describe Tweetlr do

  config_file = File.join( Dir.pwd, 'config', 'tweetlr.yml')
  config = YAML.load_file(config_file)
  USER = config['tumblr_username']
  PW   = config['tumblr_password']
  TIMESTAMP = config['twitter_timestamp']

  before :each do
    @credentials = {:email => USER, :password => PW}
    @cookie = "tmgioct=as3u4KJr9COyJA9j4nwr6ZAn"
    @searchterm = 'fail'
    @twitter_response = {"from_user_id_str"=>"1915714", "profile_image_url"=>"http://a0.twimg.com/profile_images/386000279/2_normal.jpg", "created_at"=>"Sun, 17 Apr 2011 16:48:42 +0000", "from_user"=>"whitey_Mc_whIteLIst", "id_str"=>"59659561224765440", "metadata"=>{"result_type"=>"recent"}, "to_user_id"=>nil, "text"=>"Rigaer #wirsounterwegs   @ Augenarzt Dr. Lierow http://instagr.am/p/DzCWn/", "id"=>59659561224765440, "from_user_id"=>1915714, "geo"=>{"type"=>"Point", "coordinates"=>[52.5182, 13.454]}, "iso_language_code"=>"de", "place"=>{"id"=>"3078869807f9dd36", "type"=>"city", "full_name"=>"Berlin, Berlin"}, "to_user_id_str"=>nil, "source"=>"&lt;a href=&quot;http://instagr.am&quot; rel=&quot;nofollow&quot;&gt;instagram&lt;/a&gt;"}
    @non_whitelist_tweet = @twitter_response.merge 'from_user' => 'nonwhitelist user' 
    @retweet = @twitter_response.merge "text" => "bla bla RT @fgd: tueddelkram"
    @new_style_retweet = @twitter_response.merge "text" => "and it scales! \u201c@moeffju: http://t.co/8gUSPKu #hktbl1 #origami success! :)\u201d"
    @links = {
      :instagram => "http://instagr.am/p/DzCWn/",
      :twitpic => "http://twitpic.com/449o2x",
      :yfrog => "http://yfrog.com/h4vlfp",
      :picplz => "http://picplz.com/2hWv",
      :imgly => "http://img.ly/3M1o",
      :tco => 'http://t.co/MUGNayA',
      :lockerz => 'http://lockerz.com/s/100269159',
      :foursquare => 'http://4sq.com/mLKDdF',
      :embedly => 'http://flic.kr/p/973hTv' #if no service matches, just try embedly
      }
    @pic_regexp = /(.*?)\.(jpg|jpeg|png|gif)$/i 
    @config_file = File.join( Dir.pwd, 'config', 'tweetlr.yml')
    @tweetlr = Tweetlr.new(USER, PW, @config_file, {:since_id => TIMESTAMP, :terms => @searchterm, :loglevel => 4, :cookie => @cookie})
  end
  # it "should post to tumblr" do
  #   tweetlr = Tweetlr.new @credentials[:email], @credentials[:password], @cookie, nil, @searchterm, @config_file
  #   tumblr_post = tweetlr.generate_tumblr_photo_post @twitter_response
  #   tumblr_post[:date] = Time.now.to_s
  #   response = tweetlr.post_to_tumblr tumblr_post
  #   response.should be
  #   response.response_code.should be 201
  # end
  it "should search twitter for a given term" do
    tweetlr = @tweetlr
    response = tweetlr.search_twitter
    tweets = response['results']
    tweets.should be
    tweets.should_not be_empty
  end
  it "should mark whitelist users' tweets as published" do
    post = @tweetlr.generate_tumblr_photo_post @twitter_response
    post[:state].should == 'published' 
  end
  it "should mark non whitelist users' tweets as drafts" do
    post = @tweetlr.generate_tumblr_photo_post @non_whitelist_tweet
    post[:state].should == 'draft' 
  end
  it "should not use retweets which would produce double blog posts" do
    post = @tweetlr.generate_tumblr_photo_post @retweet
    post.should_not be
  end
  it "should not use new style retweets which would produce double blog posts" do
    post = @tweetlr.generate_tumblr_photo_post @new_style_retweet
    post.should_not be
  end
  describe "image url processing" do
    it "should find a picture's url from the supported services" do
      @links.each do |key,value|
        url = @tweetlr.find_image_url value
        url.should be, "service #{key} not working!"
        check_pic_url_extraction key if [:instagram,:picplz,:yfrog,:tco,:foursquare, :not_listed].index key
      end
    end
    it "should not crash if embedly fallback won't find a link" do
      url = @tweetlr.find_image_url "http://mopskopf"     
    end
  end
  describe "tweet api response processing" do
    it "should extract links" do
      tweetlr = @tweetlr
      link = tweetlr.extract_link @twitter_response
      link.should == @links[:instagram]
      link = tweetlr.extract_link @twitter_response.merge 'text' => @links[:instagram].chop #check if it works w/o the trailing slash
      link.should == @links[:instagram].chop
    end
  end
  def check_pic_url_extraction(service)
    tweetlr = @tweetlr
    image_url = tweetlr.send "image_url_#{service}".to_sym, @links[service]
    image_url.should =~ @pic_regexp 
  end
  
end

