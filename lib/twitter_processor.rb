require 'http_processor'

module TwitterProcessor

  #checks if the message is a retweet
  def self.retweet?(message)
    message.index('RT @') || message.index(%{"@}) || message.index("\u201c@") #detect retweets
  end

  #fire a new search
  def self.search(config)
    search_call = "#{config[:api_endpoint_twitter]}?ors=#{config[:search_term]}&result_type=#{config[:result_type]}&rpp=#{config[:results_per_page]}"
    HttpProcessor::http_get search_call
  end

  # lazy update - search for a term or refresh the search if a response is available already
  def self.lazy_search(config)
    result = nil
    refresh_url = config[:refresh_url]
    log = config[:logger]
    if refresh_url
     search_url = "#{config[:api_endpoint_twitter]}#{refresh_url}&result_type=#{config[:result_type]}&rpp=#{config[:results_per_page]}"
     log.info "lazy search using '#{search_url}'" if log
     result = HttpProcessor::http_get search_url
    else
      log.debug "regular search using '#{config[:search_term]}'" if log
      result = search(config)
    end
    result
  end
end