require_relative '../lib/tweetlr.rb'
require 'net/http'

describe Tweetlr do
  before :each do
    @credentials = {:email => 'TESTMAIL', :password => 'TESTPW'}
    @cookie = "tmgioct=as3u4KJr9COyJA9j4nwr6ZAn"
    @searchterm = 'fail'
    @twitter_response = {"from_user_id_str"=>"1915714", "profile_image_url"=>"http://a0.twimg.com/profile_images/386000279/2_normal.jpg", "created_at"=>"Sun, 17 Apr 2011 16:48:42 +0000", "from_user"=>"polarity", "id_str"=>"59659561224765440", "metadata"=>{"result_type"=>"recent"}, "to_user_id"=>nil, "text"=>"Rigaer #wirsounterwegs   @ Augenarzt Dr. Lierow http://instagr.am/p/DQWAj/", "id"=>59659561224765440, "from_user_id"=>1915714, "geo"=>{"type"=>"Point", "coordinates"=>[52.5182, 13.454]}, "iso_language_code"=>"de", "place"=>{"id"=>"3078869807f9dd36", "type"=>"city", "full_name"=>"Berlin, Berlin"}, "to_user_id_str"=>nil, "source"=>"&lt;a href=&quot;http://instagr.am&quot; rel=&quot;nofollow&quot;&gt;instagram&lt;/a&gt;"}
    @links = {
      :instagram => "http://instagr.am/p/DQWAj/",
      :twitpic => "http://twitpic.com/449o2x",
      :yfrog => "http://yfrog.com/h4vlfp",
      :picplz => "http://picplz.com/2hWv"
      }
    @pic_regexp = /(.*?)\.(jpg|jpeg|png|gif)$|(http:\/\/twitpic.com\/show\/full\/449o2x)/i #naive approach - but should do the trick.
  end
  it "should post to tumblr" do
    tweetlr = Tweetlr.new @credentials[:email], @credentials[:password], @cookie
    response = tweetlr.post_to_tumblr({:type => 'regular', :title => "test post", :body => "body of the test post...", :email => @credentials[:email], :password => @credentials[:password]})
    #FIXME replace basic auth with cookie auth!
    p response.response
    response.response.should be_succesful
  end
  it "should search twitter for a given term" do
    tweetlr = Tweetlr.new @credentials[:email], @credentials[:password], @cookie
    response = tweetlr.search_twitter @searchterm
    tweets = response.parsed_response['results']
    tweets.should be
    tweets.should_not be_empty
  end
  describe "image url processing" do
    it "should find a picture's url from the instagram short url" do
      check_pic_url_extraction :instagram
    end
    it "should find a picture's url from the picplz short url" do
      check_pic_url_extraction :picplz
    end
    it "should find a picture's url from the yfrog short url" do
      check_pic_url_extraction :yfrog
    end
    it "should find a picture's url from the twitpic short url" do
      check_pic_url_extraction :twitpic
    end
  end
  describe "tweet api response processing" do
    it "should extract links" do
      tweetlr = Tweetlr.new @credentials[:email], @credentials[:password], @cookie
      link = tweetlr.extract_link @twitter_response
      link.should == @links[:instagram]
      link = tweetlr.extract_link @twitter_response.merge 'text' => @links[:instagram].chop #check if it works w/o the trailing slash
      link.should == @links[:instagram].chop
    end
  end
  
  def check_pic_url_extraction(service)
    tweetlr = Tweetlr.new @credentials[:email], @credentials[:password], @cookie
    image_url = tweetlr.send "image_url_#{service}".to_sym, @links[service]
    puts "#{service}: #{image_url}"
    image_url.should =~ @pic_regexp 
  end
  
end

