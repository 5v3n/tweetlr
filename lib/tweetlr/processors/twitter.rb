local_path=File.dirname(__FILE__)
require "#{local_path}/http"
require "#{local_path}/../log_aware"
require 'twitter'

module Tweetlr::Processors
  #utilities for dealing with twitter
  module Twitter
    include Tweetlr::LogAware
    def self.log
      Tweetlr::LogAware.log #TODO why doesn't the include make the log method accessible?
    end
    
    #checks if the message is a retweet
    def self.retweet?(message)
      message.index('RT @') || message.index(%{"@}) || message.index("\u201c@") || message.index('MT @') #detect retweets
    end
  
    #extract the links from a given tweet
    def self.extract_links(tweet)
      if tweet
        text = tweet['text']
        text.gsub(/https?:\/\/[\S]+/).to_a if text
      end
    end

    #fire a new search
    def self.search(config)
      search_call = "#{config['search_term'].gsub('+', ' OR ')} filter:links"
      log.debug "#{self}::search search_call: #{search_call}"
      response = self.call_twitter_api(search_call, config)
      log.debug "#{self}::call_twitter_api response:    #{response.inspect}"
      response
    end

    # lazy update - search for a term or refresh the search if a response is available already
    def self.lazy_search(config)
      log.debug "#{self}::lazy_search called with config #{config}"
      response = nil
      if config
        search_term = config['search_term'] || config[:search_term] || config['terms'] || config[:terms]
        search_call = "#{search_term.gsub('+', ' OR ')} filter:links"
        log.info "lazy search using '#{search_call}, :since_id => #{config['since_id'] || config[:since_id]}, :count => #{config['results_per_page']}, :result_type => #{config['result_type']})'"
        response = self.call_twitter_api(search_call, config, :lazy)
      else
        log.error "#{self}.lazy_search: no config given!"
      end
      response
    end
private
    def self.call_twitter_api(search_call, config, lazy=false)
      apply_twitter_api_configuration config
      max_attempts = 3
      num_attempts = 0
      begin
        num_attempts += 1
        call_twitter_with search_call, config, lazy
      rescue ::Twitter::Error::TooManyRequests => error
        if num_attempts <= max_attempts
          sleep error.rate_limit.reset_in
          retry
        else
          log.error "Twitter API rate limit exceeded - going to sleep for error.rate_limit.reset_in seconds. (#{error})"
        end
      end
    end
    def self.apply_twitter_api_configuration(config)
      ::Twitter.configure do |configuration|
        configuration.consumer_key = config[:twitter_app_consumer_key]
        configuration.consumer_secret = config[:twitter_app_consumer_secret]
        configuration.oauth_token = config[:twitter_oauth_token]
        configuration.oauth_token_secret = config[:twitter_oauth_token_secret]
      end
    end
    def self.call_twitter_with(search_call, config, lazy)
      if lazy
        response = ::Twitter.search(search_call, :since_id => config['since_id'] || config[:since_id], :count => config[:results_per_page], :result_type => config[:result_type])
      else
        response = ::Twitter.search(search_call, :count => config[:results_per_page], :result_type => config[:result_type])
      end
      response
    end
  end
end