# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When package with :type => system has no :pkg specified
    class NoPreprocessorException < Exception
      def initialize(name)
        super "Does not exist a valid preprocessor for #{name} type", false
      end
    end
  end
end
