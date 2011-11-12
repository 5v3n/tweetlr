# encode: UTF-8
require 'logger'
require 'yaml'
require 'curb'
require 'json'
require 'twitter_processor'
require 'http_processor'
require 'photo_service_processor'
require 'log_aware'

class Tweetlr
  
  attr_accessor :twitter_config

  VERSION = '0.1.7pre'
  GENERATOR = %{tweetlr - http://tweetlr.5v3n.com}
  
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
    @twitter_config[:logger] = @log
    
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
  
  def lazy_search_twitter(refresh_url=nil)
    @twitter_config[:refresh_url] = refresh_url if refresh_url
    TwitterProcessor::lazy_search(@twitter_config)
  end
  
  #post a tumblr photo entry. required arguments are :type, :date, :source, :caption, :state. optional argument: :tags 
  def post_to_tumblr(options={})
    tries = 3
    if options[:type] && options[:date] && options[:source] && options[:caption] && options[:state]
      tags = options[:tags]
      begin
        response = Curl::Easy.http_post("#{@api_endpoint_tumblr}/api/write", 
        Curl::PostField.content('generator', GENERATOR),
        Curl::PostField.content('email', @email), 
        Curl::PostField.content('password', @password),
        Curl::PostField.content('type', options[:type]),
        Curl::PostField.content('date', options[:date]),
        Curl::PostField.content('source', options[:source]),
        Curl::PostField.content('caption', options[:caption]),
        Curl::PostField.content('state', options[:state]),
        Curl::PostField.content('tags', tags)
        )
      rescue Curl::Err::CurlError => err
        @log.error "Failure in Curl call: #{err}"
        tries -= 1
        sleep 3
        if tries > 0
            retry
        else
            response = nil
        end
      end
    end
    response
  end
  
  #generate the data for a tumblr photo entry by parsing a tweet
  def generate_tumblr_photo_post tweet
    tumblr_post = nil
    message = tweet['text']
    if !TwitterProcessor::retweet? message
      @log.debug "tweet: #{tweet}"
      tumblr_post = {}
      tumblr_post[:type] = 'photo'
      tumblr_post[:date] = tweet['created_at']
      tumblr_post[:source] = extract_image_url tweet
      user = tweet['from_user']
      tumblr_post[:tags] = user
      tweet_id = tweet['id']
      if !@whitelist || @whitelist.member?(user.downcase)
        state = 'published'
      else
        state = 'draft'
      end
      tumblr_post[:state] = state
      shouts = " #{@shouts}" if @shouts
      tumblr_post[:caption] = %?<a href="http://twitter.com/#{user}/statuses/#{tweet_id}" alt="tweet">@#{user}</a>#{shouts}: #{tweet['text']}? 
      #TODO make the caption a bigger matter of yml/ general configuration
    end
    tumblr_post
  end
  
  #extract a linked image file's url from a tweet. first found image will be used.
  def extract_image_url(tweet)
    links = TwitterProcessor::extract_links tweet
    image_url = nil
    if links
      links.each do |link|
        image_url = PhotoServiceProcessor::find_image_url(link)
        return image_url if PhotoServiceProcessor::photo? image_url
      end
    end
    image_url
  end
  
end