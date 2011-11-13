require 'log_aware'

module Processors
  #utilities for handling tumblr
  module Tumblr
    GENERATOR = %{tweetlr - http://tweetlr.5v3n.com}
    API_ENDPOINT_TUMBLR = 'http://www.tumblr.com'
    include LogAware
    def self.log
      LogAware.log #TODO why doesn't the include make the log method accessible?
    end
    #post a tumblr photo entry. 
    #
    #required arguments are :email, :password, :type, :date, :source, :caption, :state, :source
    #
    #optional arguments: :api_endpoint_tumblr, :tags
    #
    def self.post(options={})
      tries = 3
      tags = options[:tags]
      begin
        response = Curl::Easy.http_post("#{options[:api_endpoint_tumblr] || API_ENDPOINT_TUMBLR}/api/write", 
        Curl::PostField.content('generator', GENERATOR),
        Curl::PostField.content('email', options[:email]), 
        Curl::PostField.content('password', options[:password]),
        Curl::PostField.content('type', options[:type]),
        Curl::PostField.content('date', options[:date]),
        Curl::PostField.content('source', options[:source]),
        Curl::PostField.content('caption', options[:caption]),
        Curl::PostField.content('state', options[:state]),
        Curl::PostField.content('tags', tags)
        )
      rescue Curl::Err::CurlError => err
        log.error "Failure in Curl call: #{err}"
        tries -= 1
        sleep 3
        if tries > 0
            retry
        else
            response = nil
        end
      end
      response
    end
  end
end