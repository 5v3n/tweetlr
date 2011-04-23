require 'daemons'
require 'eventmachine'
require 'logger'
require 'yaml'
require_relative './tweetlr.rb'

  config_file = File.join(File.dirname(__FILE__), '..',  'config', 'tweetlr.yml')
  CONFIG = YAML.load_file(config_file)
  TERM = CONFIG['search_term']
  USER = CONFIG['tumblr_username']
  PW   = CONFIG['tumblr_password']
  TIMESTAMP = CONFIG['twitter_timestamp']
  UPDATE_PERIOD = CONFIG['update_period']

Daemons.run_proc('tweetlrd') do
  @log = Logger.new('tweetlrd.log')
  @log.info('starting tweetlr daemon...')
  @log.info "createing a new tweetlr instance using this config: #{CONFIG.inspect}"   
  EventMachine::run { 
     tweetlr = Tweetlr.new(USER, PW, nil, TIMESTAMP, TERM)
     EventMachine::add_periodic_timer( UPDATE_PERIOD ) {
       @log.info('starting tweetlr crawl...')
       response = tweetlr.lazy_search_twitter
       tweets = response.parsed_response['results']
       if tweets
         tweets.each do |tweet|
           tumblr_post = tweetlr.generate_tumblr_photo_post tweet
           if tumblr_post.nil? ||  tumblr_post[:source].nil?
              @log.error "could not get image source: #{tumblr_post.inspect}"
           else
             @log.debug tumblr_post
             @log.debug tweetlr.post_to_tumblr tumblr_post
           end
         end
       end
       @log.info('finished tweetlr crawl.')
    }
   }

end

