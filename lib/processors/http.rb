require 'curb'
require 'log_aware'

module Processors
  #utilities for handling http
  module Http
    include LogAware
  
    USER_AGENT = %{Mozilla/5.0 (compatible; tweetlr; +http://tweetlr.5v3n.com)}

    #convenience method for curl http get calls and parsing them to json.
    def self.http_get(request, log=nil)
      tries = 3
      begin
        curl = Curl::Easy.new request
        curl.useragent = USER_AGENT
        curl.perform
        begin
          JSON.parse curl.body_str
        rescue JSON::ParserError => err
          begin
            if log
              log.warn "#{err}: Could not parse response for #{request} - this is probably not a json response: #{curl.body_str}"
            end
            return nil
          rescue Encoding::CompatibilityError => err
            if log
              log.error "Trying to rescue a JSON::ParserError for '#{request}' we got stuck in a Encoding::CompatibilityError."
            end
            return nil
          end
        end
      rescue Curl::Err::CurlError => err
        log.error "Failure in Curl call: #{err}" if log
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
end