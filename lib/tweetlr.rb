require 'httparty'
require 'logger'
require 'yaml'
require 'curb'


class Tweetlr

  GENERATOR = %{tweetlr - http://github.com/5v3n/tweetlr}
  LOCATION_START_INDICATOR = 'Location: '
  LOCATION_STOP_INDICATOR  = "\r\n"
  
  def initialize(email, password, cookie=nil, since_id=nil, term=nil, config_file) #TODO use a hash or sth more elegant here...
    @log = Logger.new(File.join( Dir.pwd, 'tweetlr.log'))
    config = YAML.load_file(config_file)
    @results_per_page = config['results_per_page']
    @result_type = config['result_type']
    @api_endpoint_twitter = config['api_endpoint_twitter']
    @api_endpoint_tumblr = config['api_endpoint_tumblr']
    @whitelist = config['whitelist']
    @shouts = config['shouts']
    @since_id = since_id
    @search_term = term
    @whitelist.each {|entry| entry.downcase!}
    @email = email
    @password = password
    @term = term
    @refresh_url = "#{@api_endpoint_twitter}?q=#{term}&since_id=#{since_id}" if (since_id && term)
    if !cookie
      response = HTTParty.post(
        "#{@api_endpoint_tumblr}/login",
        :body => {
          :email => @email,
          :password => password
        }
      )
      @log.debug("initial login response: #{response}")
      @cookie = response.headers['Set-Cookie']
      @log.debug("--------login cookie via new login: #{@cookie.inspect}")
    else
      @cookie = cookie
      @log.debug("--------login cookie via argument: #{@cookie.inspect}")
    end
    
  end

  def post_to_tumblr(options={})
    options[:generator] = GENERATOR
    options[:email] = @email #TODO get cookie auth working!
    options[:password] = @password
    #options[:headers] = {'Cookie' => @cookie}
    #arguments=options.collect { |key, value| "#{key}=#{value}" }.join('&')
    @log.debug("------------********** post_to_tumblr options: #{options.inspect}")
    @log.debug("------------********** post_to_tumblr options: #{{'Cookie' => @cookie}.inspect}")
    response = HTTParty.post("#{@api_endpoint_tumblr}/api/write", :body => options, :headers => {'Cookie' => @cookie})
    @log.debug("------------********** post_to_tumblr response: #{response.inspect}" )
    response
  end

  #fire a new search
  def search_twitter()
    search_call = "#{@api_endpoint_twitter}?q=#{@search_term}&result_type=#{@result_type}&rpp=#{@results_per_page}"
    @response = HTTParty.get(search_call)
  end
  # lazy update - search for a term or refresh the search if a response is available already
  def lazy_search_twitter()
    @refresh_url = "#{@api_endpoint_twitter}#{@response['refresh_url']}" unless (@response.nil? || @response['refresh_url'].nil? || @response['refresh_url'].empty?)
    if @refresh_url
     #FIXME persist the refresh url - server restart would be a pain elsewise
     @log.info "lazy search using '#{@refresh_url}'"
     @response = HTTParty.get(@refresh_url)
    else
      @log.debug "regular search using '#{term}'"
      @response = search_twitter()
    end
  end
  
  #extract the linked image file's url
  def extract_image_url(tweet)
    link = extract_link tweet
    url = nil
    if link
      url = image_url_instagram link if (link.index('instagr.am') || link.index('instagram.com'))
      url = image_url_picplz link if link.index 'picplz'
      url = image_url_twitpic link if link.index 'twitpic'
      url = image_url_yfrog link if link.index 'yfrog'
      url = image_url_imgly link if link.index 'img.ly'
    end
    url
  end

  #find the image's url for an instagram link
  def image_url_instagram(link_url)
    link_url['instagram.com'] = 'instagr.am' if link_url.index 'instagram.com' #instagram's oembed does not work for .com links
    response = HTTParty.get "http://api.instagram.com/oembed?url=#{link_url}"
    response.parsed_response['url']
  end

  #find the image's url for a picplz short/longlink
  def image_url_picplz(link_url)
    id = extract_id link_url
    #try short url
    response = HTTParty.get "http://picplz.com/api/v2/pic.json?shorturl_ids=#{id}"
    #if short url fails, try long url
    #response = HTTParty.get "http://picplz.com/api/v2/pic.json?longurl_ids=#{id}"
    #extract url
    response['value']['pics'].first['pic_files']['640r']['img_url']
  end
  #find the image's url for a twitpic link
  def image_url_twitpic(link_url)
    image_url_redirect link_url, "http://twitpic.com/show/full/"
  end
  #find the image'S url for a yfrog link
  def image_url_yfrog(link_url)
    response = HTTParty.get("http://www.yfrog.com/api/oembed?url=#{link_url}")
    response.parsed_response['url']
  end
  #find the image's url for a img.ly link
  def image_url_imgly(link_url)
    image_url_redirect link_url, "http://img.ly/show/full/", "\r\n"
  end
  
  # extract image url from services like twitpic & img.ly that do not offer oembed interfaces
  def image_url_redirect(link_url, service_endpoint, stop_indicator = LOCATION_STOP_INDICATOR)
    resp = Curl::Easy.http_get("#{service_endpoint}#{extract_id link_url}") { |res| res.follow_location = true }
    if(resp.header_str.index(LOCATION_START_INDICATOR) && resp.header_str.index(stop_indicator))
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

  def generate_tumblr_photo_post tweet
    tumblr_post = nil
    message = tweet['text']
    if message && !message.index('RT @') #discard retweets
      @log.debug "tweet: #{tweet}"
      tumblr_post = {}
      tumblr_post[:type] = 'photo'
      tumblr_post[:date] = tweet['created_at']
      tumblr_post[:source] = extract_image_url tweet
      user = tweet['from_user']
      if @whitelist.member? user.downcase
        state = 'published'
      else
        state = 'draft'
      end
      tumblr_post[:state] = state
      tumblr_post[:caption] = %?@#{user} #{@shouts}: #{tweet['text']}? #TODO make this a bigger matter of yml configuration
    end
    tumblr_post
  end
  
end




