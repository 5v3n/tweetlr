require 'daemons'
require 'eventmachine'
require 'logger'
require_relative './tweetlr.rb'

#Daemons.run('./lib/tweetlr_daemon.rb')

@credentials = {:email => 'MAIL', :password => 'PW'}
TERM = '%23wirsounterwegs'

Daemons.run_proc('tweetlrd') do
  EventMachine::run {
     @log = Logger.new('tweetlrd.log')
     @log.info('starting tweetlr daemon...')
     tweetlr = Tweetlr.new(@credentials[:email], @credentials[:password], nil, '60810195688886272', TERM)
     EventMachine::add_periodic_timer( 5 ) { 
       @log.info('starting tweetlr crawl...')
       response = tweetlr.lazy_search_twitter
       tweets = response.parsed_response['results']
       if tweets
         tweets.each do |tweet|
           tumblr_post = tweetlr.generate_tumblr_photo_post tweet
           if tumblr_post[:source].nil?
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
