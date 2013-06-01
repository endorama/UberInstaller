

module Uberinstaller
  module Utils
    def self.letter?(lookAhead)
      lookAhead =~ /[[:alpha:]]/
    end

    def self.numeric?(lookAhead)
      lookAhead =~ /[[:digit:]]/
    end
  end
end
