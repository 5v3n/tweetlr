require 'spec_helper'

describe Tweetlr::Processors::PhotoService do
  before :each do
    @links = {
      :foursquare => 'http://4sq.com/x4p87N',
      :eyeem => 'http://www.eyeem.com/p/326629',
      :path => 'http://path.com/p/KQd57', 
      :instagram => "http://instagr.am/p/DzCWn/",
      :twitpic => "http://twitpic.com/449o2x",
      :tco => 'http://t.co/FmyBGfyY',
      :embedly => 'http://flic.kr/p/973hTv',
      :twitter_pics => 'http://t.co/FmyBGfyY',
      :twimg => 'http://twitter.com/KSilbereisen/status/228035435237097472',
      :imgly => "http://img.ly/3M1o"
      }
  end
  it "finds a picture's url from the supported services" do
    @links.each do |service,link|
      send "stub_#{service}"
      url = Tweetlr::Processors::PhotoService::find_image_url link
      url.should be, "service #{service} not working!"
      check_pic_url_extraction service if [:twimg, :instagram,:yfrog,:imgly,:foursqaure,:not_listed].index service
    end
  end
  it "extracts images from eye em" do
    stub_eyeem
    link = Tweetlr::Processors::PhotoService::find_image_url @links[:eyeem]
    link.should be
    link.should == "http://www.eyeem.com/thumb/h/1024/e35db836c5d3f02498ef60fc3d53837fbe621561-1334126483"
  end
  it "doesnt find images in embedly results that are not explicitly marked as 'Photo' or 'Image' via the response's 'thumbnail_url' attribute" do
    stub_embedly_no_photo
    link = Tweetlr::Processors::PhotoService::find_image_url 'http://makersand.co/'
    link.should be_nil
  end
  describe "for foursqaure" do
    it "does find an image that is not he profile pic" do
      stub_foursquare
      link = Tweetlr::Processors::PhotoService::find_image_url @links[:foursquare]
      link.should be
      link.index('userpix_thumbs').should_not be
    end
    it "does not extract symbols from tweeted links that contain no images" do
      stub_foursquare_no_photo
      link = Tweetlr::Processors::PhotoService::find_image_url @links[:foursquare]
      link.should_not be
    end
  end
  it "finds path images for redirected moments as well" do
    stub_path_redirected
    url = Tweetlr::Processors::PhotoService::find_image_url @links[:path]
    url.should == 'https://s3-us-west-1.amazonaws.com/images.path.com/photos2/f90fd831-43c3-48fd-84cb-5c3bae52957a/2x.jpg'
  end
  it "should not crash if embedly fallback won't find a link" do
    stub_bad_request
    url = Tweetlr::Processors::PhotoService::find_image_url "http://mopskopf"     
  end
  it "should not crash with an encoding error when response is non-us-ascii" do
    stub_utf8_response
    url = Tweetlr::Processors::PhotoService::find_image_url "http://api.instagram.com/oembed?url=http://instagr.am/p/Gx%E2%80%946/"
  end
  it "follows redirects" do
    stub_imgly
    link = Tweetlr::Processors::PhotoService::link_url_redirect 'im mocked anyways'
    link.should == 'http://s3.amazonaws.com/imgly_production/899582/full.jpg'
  end
  it "copes with redirect errors" do
    Curl::Easy.any_instance.stub(:http_get).and_raise(Curl::Err::CurlError)
    Tweetlr::Processors::PhotoService.stub!(:sleep) #releasing the sleep handbrake...
    Tweetlr::Processors::PhotoService.should_receive(:sleep).with(3)
    expect { Tweetlr::Processors::PhotoService::link_url_redirect 'im mocked anyways'}.to_not raise_error(Curl::Err::CurlError)
  end
end