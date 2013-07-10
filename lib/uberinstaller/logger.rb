# -*- encoding: utf-8 -*-

require 'colored'
require 'logger'

module Uberinstaller

  # Handle application log
  module Loggable
    # @!attribute [r] loggers
    #   Hash of available loggers ( one for class in which logger is invoked )
    @loggers = {}
    # @!attribute [rw] log_path
    #   Path in which log files are saved ( default STDOUT )
    @log_path = STDOUT
    # @!attribute [rw] level
    #   Log level. Can be one of Logger::DEBUG, Logger::INFO, Logger::WARN, Logger::ERROR ( default Logger::ERROR )
    @level = Logger::ERROR

    # Global, memoized, lazy initialized instance of a logger
    #
    # This is the magical bit that gets mixed into your classes. Respond to Logger function.
    # 
    # @return [Object] an instance of the logger class
    def logger
      classname = (self.is_a? Module) ? self : self.class.name
      @logger ||= Loggable.logger_for(classname)
    end

    class << self
      # @!attribute [rw] level
      #   Log output level. Can be one of Logger::DEBUG, Logger::INFO, Logger::WARN, Logger::ERROR ( default Logger::ERROR )
      # @!attribute [rw] log_path
      #   Path in which log files are saved ( default STDOUT )
      attr_accessor :level, :log_path
      
      # Return the logger for a specific Class. If the instance is not found, creates it.
      #
      # @param classname [String] the name of the class for which a logger instance must be retrieved
      # @return [Object] the instance of the logger class for the specified Class
      def logger_for(classname)
        @loggers[classname] ||= configure_logger_for(classname)
      end

      # Create and configure a logger for the specified Class
      #
      # @param classname [String] the name of the class for which a logger instance must be retrieved
      # @return [Object] the instance of the logger class for the specified Class
      def configure_logger_for(classname)
        # handle case in which log path does not exists
        begin
          logger = Logger.new(@log_path)
        rescue Errno::ENOENT
          FileUtils.mkdir_p File.dirname @log_path
          retry
        end

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
