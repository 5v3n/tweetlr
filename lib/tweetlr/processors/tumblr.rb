require "#{File.dirname(__FILE__)}/../log_aware"
require 'oauth'

module Tweetlr::Processors
  #utilities for handling tumblr
  module Tumblr
    GENERATOR = %{tweetlr - http://tweetlr.5v3n.com}
    API_ENDPOINT_TUMBLR = 'http://www.tumblr.com'
    include Tweetlr::LogAware
    def self.log
      Tweetlr::LogAware.log #TODO why doesn't the include make the log method accessible?
    end
    #post a tumblr photo entry. 
    #
    #required arguments are :tumblr_blog_hostname, :tumblr_blog_hostname, :tumblr_oauth_api_secret, :tumblr_oauth_access_token_secret, :source, :caption, :state
    #
    #optional arguments: :tags, :type (default: 'photo') 
    #
    def self.post(options={})
      log.info "posting to #{options[:tumblr_blog_hostname] || options[:group]}..."
      base_hostname       = options[:tumblr_blog_hostname] || options[:group]
      tumblr_oauth_api_key= options[:tumblr_oauth_api_key] 
      tumblr_oauth_api_secret= options[:tumblr_oauth_api_secret] 
      access_token_key    = options[:tumblr_oauth_access_token_key]
      access_token_secret = options[:tumblr_oauth_access_token_secret]
      type                = options[:type] || 'photo'
      tags                = options[:tags] || ''
      post_response = nil

      if base_hostname && access_token_key && access_token_secret

        consumer = OAuth::Consumer.new(tumblr_oauth_api_key, tumblr_oauth_api_secret,
                                       { :site => 'http://www.tumblr.com',
                                         :request_token_path => '/oauth/request_token',
                                         :authorize_path => '/oauth/authorize',
                                         :access_token_path => '/oauth/access_token',
                                         :http_method => :post } )

        access_token = OAuth::AccessToken.new(consumer, access_token_key, access_token_secret)

        post_response = access_token.post(
          "http://api.tumblr.com/v2/blog/#{base_hostname}/post", { 
            :type => type, 
            :source => options[:source], 
            :caption => options[:caption],
            :date => options[:date],
            :tags => tags,
            :state => options[:state],
            :generator => GENERATOR
             }
            )
      end
      post_response
    end
  end
end