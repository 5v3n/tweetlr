require 'curb'
require 'json'
require 'log_aware'

module Processors
  #utilities for handling http
  module Http
    include LogAware
  
    USER_AGENT = %{Mozilla/5.0 (compatible; tweetlr; +http://tweetlr.5v3n.com)}
    
    def self.log
      LogAware.log #TODO why doesn't the include make the log method accessible?
    end
    #convenience method for curl http get calls
    def self.http_get(request)
      tries = 3
      curl = nil
      begin
        curl = Curl::Easy.new request
        curl.useragent = USER_AGENT
        curl.perform
      rescue Curl::Err::CurlError => err
        log.error "Failure in Curl call: #{err}" if log
        tries -= 1
        sleep 3
        if tries > 0
          retry
        end 
      end
      return curl
    end
    #convenience method for curl http get calls and parsing them to json.
    def self.http_get_json(request)
      curl = self.http_get(request)
      begin
        JSON.parse curl.body_str
      rescue JSON::ParserError => err
        begin
          log.warn "#{err}: Could not parse response for #{request} - this is probably not a json response: #{curl.body_str}"
          return nil
        rescue Encoding::CompatibilityError => err
          log.error "Trying to rescue a JSON::ParserError for '#{request}' we got stuck in a Encoding::CompatibilityError."
          return nil
        end
      end
    end
  end
end