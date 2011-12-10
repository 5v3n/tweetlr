require 'spec_helper'

describe Processors::PhotoService do
  before :each do
    @links = {
      :path => 'https://path.com/p/1OKhLx', 
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
  it "should find a picture's url from the supported services" do
    @links.each do |service,link|
      send "stub_#{service}"
      url = Processors::PhotoService::find_image_url link
      url.should be, "service #{service} not working!"
      check_pic_url_extraction service if [:instagram,:picplz,:yfrog,:imgly,:not_listed].index service
    end
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