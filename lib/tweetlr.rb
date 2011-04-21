require 'httparty'
require 'logger'


class Tweetlr
  RESULTS_PER_PAGE = 100
  RESULT_TYPE = 'recent'
  API_ENDPOINT_TWITTER = 'http://search.twitter.com/search.json';
  API_ENDPOINT_TUMBLR = 'http://www.tumblr.com';
  GENERATOR = %{tweetlr beta - http://github.com/5v3n/tweetlr}
  WHITELIST = %w[davidaguirre T210 Lueti HendricRuesch sven_kr _jrg cfischler meyola S_TIMMung filtercake michaelhein talinee 
    mettyK berlinporr tielefeld newsanalyse carsten_schulz marsti CarolinN yasminlechte tedory crieger menschmithut 
    mojomatic choanzie malte martinweigert jayzon277 magnusvoss kuemmel_hh]

  def initialize(email, password, cookie=nil, since_id=nil, term=nil)
    WHITELIST.each {|entry| entry.downcase!}
    @log = Logger.new('tweetlr.log')
    #@log.debug('log file created.')
    @email = email
    @password = password
    @term = term
    @refresh_url = "#{API_ENDPOINT_TWITTER}?q=#{term}&since_id=#{since_id}" if (since_id && term)
    if !cookie
      response = HTTParty.post(
        "#{API_ENDPOINT_TUMBLR}/login",
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
    response = HTTParty.post("#{API_ENDPOINT_TUMBLR}/api/write", :body => options, :headers => {'Cookie' => @cookie})
    @log.debug("------------********** post_to_tumblr response: #{response.inspect}" )
    response
  end

  #fire a new search
  def search_twitter()
    search_call = "#{API_ENDPOINT_TWITTER}?q=#{@term}&result_type=#{RESULT_TYPE}&rpp=#{RESULTS_PER_PAGE}"
    @response = HTTParty.get(search_call)
  end
  # lazy update - search for a term or refresh the search if a response is available already
  def lazy_search_twitter()
    @refresh_url = "#{API_ENDPOINT_TWITTER}#{@response['refresh_url']}" unless (@response.nil? || @response['refresh_url'].nil? || @response['refresh_url'].empty?)
    if @refresh_url
     #FIXME persist the refresh url - server restart would be a pain elsewise
     @log.debug "lazy search using '#{@refresh_url}'"
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
    "http://twitpic.com/show/full/#{extract_id link_url}"
  end
  #find the image'S url for a yfrog link
  def image_url_yfrog(link_url)
    response = HTTParty.get("http://www.yfrog.com/api/oembed?url=#{link_url}")
    response.parsed_response['url']
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
      if WHITELIST.member? user.downcase
        state = 'published'
      else
        state = 'draft'
      end
      tumblr_post[:state] = state
      tumblr_post[:caption] = %?@#{user} so: #{tweet['text']}?
    end
    tumblr_post
  end
  
end




