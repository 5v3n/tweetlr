module LogAware
    def self.log=(log)
      @@log = log #TODO think of a more elegant way of logging than a static attribute
    end
    def self.log()
      @@log
    end
end