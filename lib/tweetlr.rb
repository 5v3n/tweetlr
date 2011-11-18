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

  VERSION = '0.1.7pre3'
  
  API_ENDPOINT_TWITTER = 'http://search.twitter.com/search.json'
  API_ENDPOINT_TUMBLR = 'http://www.tumblr.com'
  TWITTER_RESULTS_PER_PAGE = 100
  TWITTER_RESULTS_TYPE = 'recent'
  UPDATE_PERIOD = 600 #10 minutes
  
  include LogAware
  def self.log
    LogAware.log #TODO why doesn't the include make the log method accessible?
  end
  
  def initialize(args)
    log = Logger.new(STDOUT)
    if (Logger::DEBUG..Logger::UNKNOWN).to_a.index(args[:loglevel])
      log.level = args[:loglevel] 
    else
      log.level = Logger::INFO
    end
    log.debug "log level set to #{log.level}"
    LogAware.log=log
    
    @email = args[:tumblr_email]
    @password = args[:tumblr_password]
    @cookie = args[:cookie]
    @api_endpoint_twitter = 
    @api_endpoint_tumblr = args[:api_endpoint_tumblr] || API_ENDPOINT_TUMBLR
    @whitelist = args[:whitelist]
    @shouts = args[:shouts]
    @update_period = args[:update_period] || UPDATE_PERIOD
    @whitelist.each {|entry| entry.downcase!} if @whitelist
  end
  
  def self.crawl(config)
    twitter_config = {
      :since_id => config[:since_id] || config[:start_at_tweet_id],
      :search_term => config[:terms] || config[:search_term] ,
      :results_per_page => config[:results_per_page] || TWITTER_RESULTS_PER_PAGE,
      :result_type => config[:result_type] || TWITTER_RESULTS_TYPE,  
      :api_endpoint_twitter => config[:api_endpoint_twitter] || API_ENDPOINT_TWITTER
    }    
    log.info "starting tweetlr crawl..."
    response = {}
    response = Processors::Twitter::lazy_search(twitter_config) #looks awkward, but the refresh url will come from the db soon and make sense then...
    if response
      tweets = response['results']
      if tweets
      tweets.each do |tweet|
        tumblr_post = Combinators::TwitterTumblr::generate_photo_post_from_tweet(tweet, {:whitelist => config[:whitelist]}) 
        if tumblr_post.nil? ||  tumblr_post[:source].nil?
           log.warn "could not get image source: tweet: #{tweet} --- tumblr post: #{tumblr_post.inspect}"
        else
          log.debug "tumblr post: #{tumblr_post}"
          res = Processors::Tumblr.post tumblr_post.merge({:password => config[:tumblr_password], :email => config[:tumblr_email]})
          log.warn "tumblr response: #{res.header_str} #{res.body_str}" unless res.response_code == 201
        end
       end
        # store the highest tweet id
        config[:since_id] = response['max_id']
      end
    else
      log.error "twitter search returned no response. hail the failwhale!"
    end
    log.info "finished tweetlr crawl."
    return config
  end  
end