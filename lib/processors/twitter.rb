require 'processors/http'
require 'log_aware'

module Processors
  #utilities for dealing with twitter
  module Twitter
    include LogAware
    def self.log
      LogAware.log #TODO why doesn't the include make the log method accessible?
    end
    
    #checks if the message is a retweet
    def self.retweet?(message)
      message.index('RT @') || message.index(%{"@}) || message.index("\u201c@") #detect retweets
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
      search_call = "#{config[:api_endpoint_twitter]}?ors=#{config[:search_term]}&result_type=#{config[:result_type]}&rpp=#{config[:results_per_page]}"
      Processors::Http::http_get_json search_call
    end

    # lazy update - search for a term or refresh the search if a response is available already
    def self.lazy_search(config)
      response = nil
      if config
        search_url = "#{config[:api_endpoint_twitter]}?since_id=#{config[:since_id]}&ors=#{config[:search_term]}&result_type=#{config[:result_type]}&rpp=#{config[:results_per_page]}"
        log.info "lazy search using '#{search_url}'"
        response = Processors::Http::http_get_json search_url
      else
        log.error "#{self}.lazy_search: no config given!"
      end
      response
    end
  end
end