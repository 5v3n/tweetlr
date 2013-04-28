require 'spec_helper'

describe Tweetlr::Processors::Http do
  it ".http_get copes with errors by retrying, not raising" do
    Curl::Easy.any_instance.stub(:perform).and_raise(Curl::Err::CurlError)
    Tweetlr::Processors::Http.stub!(:sleep) #releasing the sleep handbrake...
    Tweetlr::Processors::Http.should_receive(:sleep).with(3)
    expect { Tweetlr::Processors::Http.http_get('mocky wocky')}.to_not raise_error(Curl::Err::CurlError)
  end
end