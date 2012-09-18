# encode: UTF-8
require 'processors/twitter'
require 'processors/http'
require 'processors/photo_service'
require 'processors/tumblr'
require 'combinators/twitter_tumblr'
require 'log_aware'
require 'uri'

class Tweetlr

  VERSION = '0.1.17'
  
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
    @api_endpoint_twitter = args[:api_endpoint_twitter] || API_ENDPOINT_TWITTER
    @api_endpoint_tumblr = args[:api_endpoint_tumblr] || API_ENDPOINT_TUMBLR
    @whitelist = args[:whitelist]
    @shouts = args[:shouts]
    @update_period = args[:update_period] || UPDATE_PERIOD
    @whitelist.each {|entry| entry.downcase!} if @whitelist
    log.info "Tweetlr #{Tweetlr::VERSION} initialized. Ready to roll."
  end
  
  def self.crawl(config)
    log.debug "#{self}.crawl() using config: #{config.inspect}"
    twitter_config = {
      :since_id => config[:since_id] || config[:start_at_tweet_id],
      :search_term => config[:terms] || config[:search_term] ,
      :results_per_page => config[:results_per_page] || TWITTER_RESULTS_PER_PAGE,
      :result_type => config[:result_type] || TWITTER_RESULTS_TYPE,  
      :api_endpoint_twitter => config[:api_endpoint_twitter] || API_ENDPOINT_TWITTER
    }
    tumblr_config = { :tumblr_oauth_access_token_key => config[:tumblr_oauth_access_token_key],
                      :tumblr_oauth_access_token_secret => config[:tumblr_oauth_access_token_secret],
                      :tumblr_oauth_api_key => config[:tumblr_oauth_api_key],
                      :tumblr_oauth_api_secret => config[:tumblr_oauth_api_secret],
                      :tumblr_blog_hostname => config[:tumblr_blog_hostname] || config[:group]
                    }
      
    twitter_config[:search_term] = URI::escape(twitter_config[:search_term]) if twitter_config[:search_term]
    log.info "starting tweetlr crawl..."
    response = {}
    response = Processors::Twitter::lazy_search(twitter_config)
    if response
      tweets = response['results']
      if tweets
      tweets.each do |tweet|
        tumblr_post = Combinators::TwitterTumblr::generate_photo_post_from_tweet(tweet, {:whitelist => config[:whitelist], :embedly_key => config[:embedly_key], :group => config[:group]}) 
        if tumblr_post.nil? ||  tumblr_post[:source].nil?
          log.warn "could not get image source: tweet: #{tweet} --- tumblr post: #{tumblr_post.inspect}"
        else
          log.debug "tumblr post: #{tumblr_post}"
          res = Processors::Tumblr.post tumblr_post.merge(tumblr_config)
          log.debug "tumblr response: #{res}"
          if res.code == "201"
            log.info "tumblr post created (tumblr response: #{res.header} #{res.body}"
          else
            log.warn "tumblr response: #{res.header} #{res.body}"
          end
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