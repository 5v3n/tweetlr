require 'spec_helper'

describe Tweetlr::Combinators::TwitterTumblr do
  before :each do
    @first_link = "http://url.com"
    @second_link = "http://instagr.am/p/DzCWn/"
    @third_link = "https://imageurl.com"
    @twitter_response = {"from_user_id_str"=>"1915714", "profile_image_url"=>"http://a0.twimg.com/profile_images/386000279/2_normal.jpg", "created_at"=>"Sun, 17 Apr 2011 16:48:42 +0000", "from_user"=>"whitey_Mc_whIteLIst", "id_str"=>"59659561224765440", "metadata"=>{"result_type"=>"recent"}, "to_user_id"=>nil, "text"=>"Rigaer #wirsounterwegs #{@first_link}  @ Augenarzt Dr. Lierow #{@second_link} #{@third_link}", "id"=>59659561224765440, "from_user_id"=>1915714, "geo"=>{"type"=>"Point", "coordinates"=>[52.5182, 13.454]}, "iso_language_code"=>"de", "place"=>{"id"=>"3078869807f9dd36", "type"=>"city", "full_name"=>"Berlin, Berlin"}, "to_user_id_str"=>nil, "source"=>"&lt;a href=&quot;http://instagr.am&quot; rel=&quot;nofollow&quot;&gt;instagram&lt;/a&gt;"}
    @retweet = @twitter_response.merge "text" => "bla bla RT @fgd: tueddelkram"
    @mt_retweet = @twitter_response.merge "text" => "bla bla MT @fgd: tueddelkram"
    @new_style_retweet = @twitter_response.merge "text" => "and it scales! \u201c@moeffju: http://t.co/8gUSPKu #hktbl1 #origami success! :)\u201d"
    @new_style_retweet_no_addition = @twitter_response.merge "text" => "\u201c@moeffju: http://t.co/8gUSPKu #hktbl1 #origami success! :)\u201d"
    @non_whitelist_tweet = @twitter_response.merge 'from_user' => 'nonwhitelist user' 
    @whitelist = ['whitey_mc_whitelist']
    @tweets = {
      :instagram => {'text' => "jadda jadda http://instagr.am/p/DzCWn/"},
      :twitpic => {'text' => "jadda jadda http://twitpic.com/449o2x"},
      :yfrog => {'text' => "jadda jadda http://yfrog.com/h4vlfp"},
      :imgly => {'text' => "jadda jadda http://img.ly/3M1o"},
      :tco => {'text' => "jadda jadda http://t.co/MUGNayA"},
      :embedly => {'text' => "jadda jadda http://flic.kr/p/973hTv"},
      :twitter_pics => {'text' => "jadda jadda http://t.co/FmyBGfyY"} 
      }
    @links = {
      :instagram => "http://instagr.am/p/DzCWn/",
      :twitpic => "http://twitpic.com/449o2x",
      :yfrog => "http://yfrog.com/h4vlfp",
      :imgly => "http://img.ly/3M1o",
      :tco => 'http://t.co/MUGNayA',
      :embedly => 'http://flic.kr/p/973hTv',
      :twitter_pics => 'http://t.co/FmyBGfyY' 
      }
  end
  context "handles pictures in tweets" do
    it "extracting their corresponding links" do
      @tweets.each do |key,value|
        send "stub_#{key}"
        url = Tweetlr::Combinators::TwitterTumblr.extract_image_url value
        url.should be, "service #{key} not working!"
        check_pic_url_extraction key if [:instagram,:picplz,:yfrog,:imgly,:not_listed].index key
      end
    end
    it "using the first image link found in a tweet with multiple links" do
      stub_instagram
      link = Tweetlr::Combinators::TwitterTumblr.extract_image_url @twitter_response
      link.should == 'http://distillery.s3.amazonaws.com/media/2011/05/02/d25df62b9cec4a138967a3ad027d055b_7.jpg'
    end
    it "not returning links that do not belong to images" do
      stub_no_image_link
      link = Tweetlr::Combinators::TwitterTumblr.extract_image_url @twitter_response
      link.should_not be
    end
  end
  context "given a user whitelist" do
    it "should mark whitelist users' tweets as published" do
      stub_instagram
      post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @twitter_response, :whitelist => @whitelist
      post[:state].should == 'published' 
    end
    it "should mark non whitelist users' tweets as drafts" do
      stub_instagram
      post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @non_whitelist_tweet, :whitelist => @whitelist
      post[:state].should == 'draft' 
    end
  end
  context "without a user whitelist (whitelist nil or empty)" do
    it "should mark every users' posts as published" do
      stub_instagram
      post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @twitter_response, :whitelist => nil
      post[:state].should == 'published'
      stub_instagram
      post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @non_whitelist_tweet, :whitelist => nil
      post[:state].should == 'published'
      post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @twitter_response, :whitelist => ""
      post[:state].should == 'published'
      stub_instagram
      post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @non_whitelist_tweet, :whitelist => ""
      post[:state].should == 'published'
    end
  end
  it "should not use retweets which would produce double blog posts" do
    post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @retweet, :whitelist => @whitelist
    post.should_not be
  end
  it "should not use old school 'MT' retweets which would produce double blog posts" do
    post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @mt_retweet, :whitelist => @whitelist
    post.should_not be
  end
  context "should not use new style retweets which would produce double blog posts" do
    it "for quotes in context" do
      post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @new_style_retweet, :whitelist => @whitelist
      post.should_not be
    end
    it "for quotes without further text addition" do
      post = Tweetlr::Combinators::TwitterTumblr::generate_photo_post_from_tweet @new_style_retweet_no_addition, :whitelist => @whitelist
      post.should_not be
    end
  end
  context "copes with different tumblelogs namely" do
    it "uses a given blog via group option to post to" do
      stub_instagram
      desired_group = 'mygroup.tumblr.com'
      tumblr_post = Tweetlr::Combinators::TwitterTumblr.generate_photo_post_from_tweet @twitter_response, {:whitelist => @whitelist, :group => desired_group}
      tumblr_post[:tumblr_blog_hostname].should eq desired_group
    end
    it "uses a given blog via tumblr_blog_hostname to post to" do
      stub_instagram
      desired_group = 'mygroup.tumblr.com'
      tumblr_post = Tweetlr::Combinators::TwitterTumblr.generate_photo_post_from_tweet @twitter_response, {:whitelist => @whitelist, :tumblr_blog_hostname => desired_group}
      tumblr_post[:tumblr_blog_hostname].should eq desired_group
    end
  end
end