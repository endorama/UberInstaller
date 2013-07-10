# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'
require 'uberinstaller/exception'

module Uberinstaller

  # Execute user defined command before and after installation
  class Commander
    include Loggable

    # @!attribute [String] pkg_name
    #   The name of the package being processed
    # @!attribute [Hash] pkg
    #   an Hash rapresenting a package to be installed
    attr_reader :pkg_name, :pkg
    
    def initialize(pkg_name, pkg)
      @pkg_name = pkg_name
      @pkg = pkg
    end

    # Execute after installation command
    def after
      if @pkg.has_key? :cmd and @pkg[:cmd].has_key? :after
        logger.info "Executing after commands..."
        run :after
      end
    end

    # Execute after installation command
    def before
      if @pkg.has_key? :cmd and @pkg[:cmd].has_key? :before
        logger.info "Executing before commands..."
        run :before
      end
    end

    private

      def exec(command)
        logger.debug "Executing command: #{command}"

        # Open3.popen3(command) { |stdin, stdout, stderr, wait_thr|
        #   pid = wait_thr.pid # pid of the started process.
        #   logger.debug "Running pid: #{pid}"

        #   logger.debug stdout.readlines

        #   exit_status = wait_thr.value.to_i # Process::Status object returned.
        #   logger.debug "Exit status: #{exit_status}"
        #   unless exit_status == 0
        #     logger.error 'Some error happended during execution:' 
        #     logger.error stderr.readlines
        #   end
        # }
      end

      def exec_file(file)
        exec "bash #{file}"
      end

      def run(type)
        logger.debug @pkg[:cmd][type]
        logger.debug 'is array    : ' + (@pkg[:cmd][type].kind_of? Array).to_s
        logger.debug 'is string   : ' + (@pkg[:cmd][type].kind_of? String).to_s
        logger.debug 'file exists : ' + (@pkg[:cmd][type].kind_of? String).to_s

        if @pkg[:cmd][type].kind_of? Array
          @pkg[:cmd][type].each do |cmd|
            exec cmd
          end
        elsif @pkg[:cmd][type].kind_of? String
          if File.exists? @pkg[:cmd][type]
            exec_file @pkg[:cmd][type]
          else
            exec @pkg[:cmd][type]
          end
        else
          raise Exception::CommandNotProcessable, @pkg_name, type
        end
      end
  end
end