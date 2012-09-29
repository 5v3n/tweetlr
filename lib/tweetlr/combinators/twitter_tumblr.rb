local_path=File.dirname(__FILE__)
require "#{local_path}/../processors/twitter"
require "#{local_path}/../processors/tumblr"
require "#{local_path}/../processors/photo_service"
require "#{local_path}/../log_aware"

module Tweetlr::Combinators
  module TwitterTumblr
    include Tweetlr::LogAware
    def self.log
      Tweetlr::LogAware.log #TODO why doesn't the include make the log method accessible?
    end
    #extract a linked image file's url from a tweet. first found image will be used.
    def self.extract_image_url(tweet, embedly_key=nil)
      links = Tweetlr::Processors::Twitter::extract_links tweet
      image_url = nil
      if links
        links.each do |link|
          image_url = Tweetlr::Processors::PhotoService::find_image_url(link, embedly_key)
          return image_url if Tweetlr::Processors::PhotoService::photo? image_url
        end
      end
      image_url
    end
    #generate the data for a tumblr photo entry by parsing a tweet
    def self.generate_photo_post_from_tweet(tweet, options = {})
      log.debug "#{self}.generate_photo_post_from_tweet with options: #{options.inspect}"
      tumblr_post = nil
      message = tweet['text']
      whitelist = options[:whitelist]
      whitelist.each {|entry| entry.downcase!} if (whitelist && whitelist.size != 0)
      if !Tweetlr::Processors::Twitter::retweet? message
        log.debug "tweet: #{tweet}"
        tumblr_post = {}
        tumblr_post[:tumblr_blog_hostname] = options[:tumblr_blog_hostname] || options[:group]
        tumblr_post[:type] = 'photo'
        tumblr_post[:date] = tweet['created_at']
        tumblr_post[:source] = extract_image_url tweet, options[:embedly_key]
        user = tweet['from_user']
        tumblr_post[:tags] = user
        tweet_id = tweet['id']
        if !whitelist || whitelist.size == 0 || whitelist.member?(user.downcase)
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
  end
end