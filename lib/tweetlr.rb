# encode: UTF-8
require 'logger'
require 'yaml'
require 'curb'
require 'json'
require 'processors/twitter'
require 'processors/http'
require 'processors/photo_service'
require 'processors/tumblr'
require 'combinators/twitter_tumblr'
require 'log_aware'

class Tweetlr
  
  attr_accessor :twitter_config, :whitelist #workarounds, goal: make tweetlr stateless. meanwhile: pass in its own state.

  VERSION = '0.1.7pre'
  
  API_ENDPOINT_TWITTER = 'http://search.twitter.com/search.json'
  API_ENDPOINT_TUMBLR = 'http://www.tumblr.com'
  TWITTER_RESULTS_PER_PAGE = 100
  TWITTER_RESULTS_TYPE = 'recent'
  UPDATE_PERIOD = 600 #10 minutes
  
  def initialize(email, password, args={:terms=>nil, :whitelist => nil, :shouts => nil, :since_id=>nil, :results_per_page => nil, :loglevel=>nil, :result_type => nil})
    @log = Logger.new(STDOUT)
    if (Logger::DEBUG..Logger::UNKNOWN).to_a.index(args[:loglevel])
      @log.level = args[:loglevel] 
    else
      @log.level = Logger::INFO
    end
    @log.debug "log level set to #{@log.level}"
    LogAware.log=@log
    @twitter_config = {
      :since_id => args[:since_id],
      :search_term => args[:terms],
      :results_per_page => args[:results_per_page] || TWITTER_RESULTS_PER_PAGE,
      :result_type => args[:result_type] || TWITTER_RESULTS_TYPE,  
      :api_endpoint_twitter => args[:api_endpoint_twitter] || API_ENDPOINT_TWITTER
    }
    @twitter_config[:refresh_url] = "?ors=#{@twitter_config[:search_term]}&since_id=#{@twitter_config[:since_id]}&rpp=#{@twitter_config[:results_per_page]}&result_type=#{@twitter_config[:result_type]}" if (@twitter_config[:since_id] && @twitter_config[:search_term])  
    @email = email
    @password = password
    @cookie = args[:cookie]
    @api_endpoint_twitter = 
    @api_endpoint_tumblr = args[:api_endpoint_tumblr] || API_ENDPOINT_TUMBLR
    @whitelist = args[:whitelist]
    @shouts = args[:shouts]
    @update_period = args[:update_period] || UPDATE_PERIOD
    @whitelist.each {|entry| entry.downcase!} if @whitelist
  end
  
  def generate_tumblr_photo_post(tweet, options={})
    Combinators::TwitterTumblr::generate_photo_post_from_tweet(tweet, options)
  end
  
  def post_to_tumblr(options)
    options.merge!(:email => @email, :password => @password) #TODO move this to the calling executable / method...
    Processors::Tumblr.post(options)
  end
  
  def lazy_search_twitter(refresh_url=nil)
    @twitter_config[:refresh_url] = refresh_url if refresh_url
    Processors::Twitter::lazy_search(@twitter_config)
  end
  

  
end