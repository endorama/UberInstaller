# -*- encoding: utf-8 -*-

require 'colored'
require 'logger'

module Uberinstaller
  module Loggable
    @loggers = {}
    @log_path = STDOUT
    @level = Logger::ERROR

    # This is the magical bit that gets mixed into your classes
    # Global, memoized, lazy initialized instance of a logger
    def logger
      classname = (self.is_a? Module) ? self : self.class.name
      @logger ||= Loggable.logger_for(classname)
    end

    class << self
      attr_accessor :level, :log_path
      
      def logger_for(classname)
        @loggers[classname] ||= configure_logger_for(classname)
      end

      def configure_logger_for(classname)
        logger = Logger.new(@log_path)
        logger.progname = classname
        logger.level = @level
        logger.formatter = proc { |severity, datetime, progname, msg|
          case severity
          when 'DEBUG'
            spaciator = "    *"
            after_space = ""
            colored = "white"
            extra = ""
          when 'INFO'
            spaciator = "   **"
            after_space = " "
            colored = ""
            extra = ""
          when 'WARN'
            spaciator = "  ***"
            after_space = " "
            colored = "yellow"
            extra = ""
          when 'ERROR'
            spaciator = " ****"
            after_space = ""
            colored = "red"
            extra = ""
          when 'FATAL'
            spaciator = "*****"
            after_space = ""
            colored = "red"
            extra = "bold"
          else
            spaciator = "     "
            after_space = ""
            colored = ""
            extra = ""
          end

          formatted_output = " #{spaciator} [#{severity}]#{after_space} [#{datetime}] -- #{msg} { #{progname} }\n"
          if @log_path == STDOUT or @log_path == STDERR
            if colored.empty? 
              formatted_output
            else
              if extra.empty?
                formatted_output.send(colored)
              else
                formatted_output.send(colored).send(extra)
              end
            end
          else
            formatted_output
          end
        }
        logger
      end
    end
  end
end
