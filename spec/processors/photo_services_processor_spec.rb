require 'spec_helper'

describe Processors::PhotoService do
  before :each do
    @links = {
      :eyeem => 'http://www.eyeem.com/p/326629',
      :foursquare => 'http://4sq.com/x4p87N',
      :path => 'http://path.com/p/KQd57', 
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
  end
  it "extracts images from eye em" do
    stub_eyeem
    link = Processors::PhotoService::find_image_url @links[:eyeem]
    link.should be
    link.should == "http://www.eyeem.com/thumb/h/1024/e35db836c5d3f02498ef60fc3d53837fbe621561-1334126483"
  end
  it "doesnt find images in embedly results that are not explicitly marked as 'Photo' via the response's 'thumbnail_url' attribute" do
    stub_embedly_no_photo
    link = Processors::PhotoService::find_image_url 'http://makersand.co/'
    link.should be_nil
  end
  it "does find an image for foursquare that is not he profile pic" do
    stub_foursquare
    link = Processors::PhotoService::find_image_url @links[:foursquare]
    link.index('userpix_thumbs').should_not be
  end
  it "should find a picture's url from the supported services" do
    @links.each do |service,link|
      send "stub_#{service}"
      url = Processors::PhotoService::find_image_url link
      url.should be, "service #{service} not working!"
      check_pic_url_extraction service if [:instagram,:picplz,:yfrog,:imgly,:foursqaure,:not_listed].index service
    end
  end
  it "finds path images for redirected moments as well" do
    stub_path_redirected
    url = Processors::PhotoService::find_image_url @links[:path]
    url.should == 'https://s3-us-west-1.amazonaws.com/images.path.com/photos2/f90fd831-43c3-48fd-84cb-5c3bae52957a/2x.jpg'
  end
  it "should not crash if embedly fallback won't find a link" do
    stub_bad_request
    url = Processors::PhotoService::find_image_url "http://mopskopf"     
  end
  it "should not crash with an encoding error when response is non-us-ascii" do
    stub_utf8_response
    url = Processors::PhotoService::find_image_url "http://api.instagram.com/oembed?url=http://instagr.am/p/Gx%E2%80%946/"
  end
  it "follows redirects" do
    stub_imgly
    link = Processors::PhotoService::link_url_redirect 'im mocked anyways'
    link.should == 'http://s3.amazonaws.com/imgly_production/899582/full.jpg'
  end
end