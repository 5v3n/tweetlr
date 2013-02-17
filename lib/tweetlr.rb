require 'tweetlr/log_aware'
require 'tweetlr/core'

module Tweetlr
  VERSION = '0.1.20'
    
  API_ENDPOINT_TWITTER = 'http://search.twitter.com/search.json'
  API_ENDPOINT_TUMBLR = 'http://www.tumblr.com'
  TWITTER_RESULTS_PER_PAGE = 100
  TWITTER_RESULTS_TYPE = 'recent'
  UPDATE_PERIOD = 600 #10 minutes
end