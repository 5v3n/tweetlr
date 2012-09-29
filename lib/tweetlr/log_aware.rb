#use centralized logging
module Tweetlr
  module LogAware
    def self.log=(log)
      @log = log
    end
    def self.log()
      @log || Logger.new(STDOUT)
    end
  end
end