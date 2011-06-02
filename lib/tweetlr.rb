require 'logger'
require 'yaml'
require 'curb'
require 'json'

class Tweetlr

  GENERATOR = %{tweetlr - http://github.com/5v3n/tweetlr}
  LOCATION_START_INDICATOR = 'Location: '
  LOCATION_STOP_INDICATOR  = "\r\n"
  
  def initialize(email, password, config_file, args={:cookie => nil, :since_id=>nil, :terms=>nil, :loglevel=>Logger::INFO})
    @log = Logger.new(STDOUT)
    @log.level = args[:loglevel] if (Logger::DEBUG..Logger::UNKNOWN).to_a.index(args[:loglevel])
    @log.debug "log level set to #{@log.level}"
    config = YAML.load_file(config_file)
    @email = email
    @password = password
    @since_id = args[:since_id]
    @search_term = args[:terms]
    @cookie = args[:cookie]
    @results_per_page = config['results_per_page']
    @result_type = config['result_type']
    @api_endpoint_twitter = config['api_endpoint_twitter']
    @api_endpoint_tumblr = config['api_endpoint_tumblr']
    @whitelist = config['whitelist']
    @shouts = config['shouts']
    @whitelist.each {|entry| entry.downcase!}
    @refresh_url = "#{@api_endpoint_twitter}?ors=#{@search_term}&since_id=#{@since_id}&rpp=#{@results_per_page}&result_type=#{@result_type}" if (@since_id && @search_term)
    if !@cookie
      response = Curl::Easy.http_post(
        "#{@api_endpoint_tumblr}/login",
        :body => {
          :email => @email,
          :password => @password
        }
      )
      @log.debug("initial login response header: #{response.header_str}") if response
      @cookie = response.headers['Set-Cookie']
      @log.debug("login cookie via new login: #{@cookie.inspect}")
    else
      @cookie = args[:cookie]
      @log.debug("login cookie via argument: #{@cookie.inspect}")
    end
    
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
      rescue Curl::Err => err
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
    if !retweet? message
      @log.debug "tweet: #{tweet}"
      tumblr_post = {}
      tumblr_post[:type] = 'photo'
      tumblr_post[:date] = tweet['created_at']
      tumblr_post[:source] = extract_image_url tweet
      user = tweet['from_user']
      tumblr_post[:tags] = user
      tweet_id = tweet['id']
      if @whitelist.member? user.downcase
        state = 'published'
      else
        state = 'draft'
      end
      tumblr_post[:state] = state
      shouts = " #{@shouts}" if @shouts
      tumblr_post[:caption] = %?<a href="http://twitter.com/#{user}/statuses/#{tweet_id}" alt="tweet">@#{user}</a>#{shouts}: #{tweet['text']}? #TODO make this a bigger matter of yml configuration
    end
    tumblr_post
  end
  
  #checks if the message is a retweet
  def retweet?(message)
    message.index('RT @') || message.index(%{ "@}) || message.index(" \u201c@") #detect retweets
  end

  #fire a new search
  def search_twitter()
    search_call = "#{@api_endpoint_twitter}?ors=#{@search_term}&result_type=#{@result_type}&rpp=#{@results_per_page}"
    @response = http_get search_call
  end
  # lazy update - search for a term or refresh the search if a response is available already
  def lazy_search_twitter()
    @refresh_url = "#{@api_endpoint_twitter}#{@response['refresh_url']}" unless (@response.nil? || @response['refresh_url'].nil? || @response['refresh_url'].empty?)
    if @refresh_url
     #FIXME persist the refresh url - server restart would be a pain elsewise
     search_url = "#{@refresh_url}&result_type=#{@result_type}&rpp=#{@results_per_page}"
     @log.info "lazy search using '#{search_url}'" #workaround to get refresh url logged w/ the Daemons gem
     @response = http_get search_url
    else
      @log.debug "regular search using '#{@search_term}'"
      @response = search_twitter()
    end
  end
  
  #extract the linked image file's url from a tweet
  def extract_image_url(tweet)
    link = extract_link tweet
    find_image_url link
  end
  
  #extract the linked image file's url from a tweet
  def find_image_url(link)
    url = nil
    if !link.nil?
      url = image_url_instagram link if (link.index('instagr.am') || link.index('instagram.com'))
      url = image_url_picplz link if link.index 'picplz'
      url = image_url_twitpic link if link.index 'twitpic'
      url = image_url_yfrog link if link.index 'yfrog'
      url = image_url_imgly link if link.index 'img.ly'
      url = image_url_tco link if link.index 't.co'
      url = image_url_lockerz link if link.index 'lockerz.com'
    end
    url
  end
  #find the image's url for a lockerz link
  def image_url_lockerz(link_url)
    response = http_get "http://api.plixi.com/api/tpapi.svc/json/metadatafromurl?details=false&url=#{link_url}"
    response["BigImageUrl"] if response
  end
  #find the image's url for an twitter shortened link
  def image_url_tco(link_url)
    service_url = link_url_redirect link_url
    find_image_url service_url
  end
  #find the image's url for an instagram link
  def image_url_instagram(link_url)
    link_url['instagram.com'] = 'instagr.am' if link_url.index 'instagram.com' #instagram's oembed does not work for .com links
    response = http_get "http://api.instagram.com/oembed?url=#{link_url}"
    response['url'] if response
  end

  #find the image's url for a picplz short/longlink
  def image_url_picplz(link_url)
    id = extract_id link_url
    #try short url
    response = http_get "http://picplz.com/api/v2/pic.json?shorturl_ids=#{id}"
    #if short url fails, try long url
    #response = HTTParty.get "http://picplz.com/api/v2/pic.json?longurl_ids=#{id}"
    #extract url
    if response && response['value'] && response['value']['pics'] && response['value']['pics'].first && response['value']['pics'].first['pic_files'] && response['value']['pics'].first['pic_files']['640r']
      response['value']['pics'].first['pic_files']['640r']['img_url'] 
    else
      nil
    end
  end
  #find the image's url for a twitpic link
  def image_url_twitpic(link_url)
    image_url_redirect link_url, "http://twitpic.com/show/full/"
  end
  #find the image'S url for a yfrog link
  def image_url_yfrog(link_url)
    response = http_get("http://www.yfrog.com/api/oembed?url=#{link_url}")
    response['url'] if response
  end
  #find the image's url for a img.ly link
  def image_url_imgly(link_url)
    image_url_redirect link_url, "http://img.ly/show/full/", "\r\n"
  end
  
  # extract image url from services like twitpic & img.ly that do not offer oembed interfaces
  def image_url_redirect(link_url, service_endpoint, stop_indicator = LOCATION_STOP_INDICATOR)
    link_url_redirect "#{service_endpoint}#{extract_id link_url}", stop_indicator
  end
  
  def link_url_redirect(short_url, stop_indicator = LOCATION_STOP_INDICATOR)
    resp = Curl::Easy.http_get(short_url) { |res| res.follow_location = true }
    if(resp && resp.header_str.index(LOCATION_START_INDICATOR) && resp.header_str.index(stop_indicator))
      start = resp.header_str.index(LOCATION_START_INDICATOR) + LOCATION_START_INDICATOR.size
      stop  = resp.header_str.index(stop_indicator, start)
      resp.header_str[start...stop]
    else
      nil
    end
  end

  #extract the pic id from a given <code>link</code>
  def extract_id(link)
    link.split('/').last if link.split('/')
  end

  #extract the link from a given tweet
  def extract_link(tweet)
    if tweet
      text = tweet['text']
      start = text.index('http') if text
      if start
        stop = text.index(' ', start) || 0
        text[start..stop-1]
      end
    end
  end
  
  private
  
  #convenience method for curl http get calls
  def http_get(request)
    tries = 3
    begin
      res = Curl::Easy.http_get(request)
      JSON.parse res.body_str
    rescue Curl::Err::ConnectionFailedError => err
      @log.error "Connection failed: #{err}"
      tries -= 1
      sleep 3
      if tries > 0
          retry
      else
          nil
      end
    rescue Curl::Err::RecvError => err
      @log.error "Failure when receiving data from the peer: #{err}"
      tries -= 1
      sleep 3
      if tries > 0
          retry
      else
          nil
      end
    rescue Curl::Err => err
      @log.error "Failure in Curl call: #{err}"
      tries -= 1
      sleep 3
      if tries > 0
          retry
      else
          nil
      end
    end
  end  
end