# -*- encoding: utf-8 -*-

require 'uberinstaller/config'
require 'uberinstaller/logger'

require 'open3'

module Uberinstaller
  module PackageManager
    class Base
      include Loggable

      attr_reader :commands

      # Create the package manager
      def initialize
        @commands = Hash.new
        @commands = {
          :add_repository => nil,
          :info => nil,
          :install => nil,
          :search => nil,
          :update => nil,
          :upgrade => nil
        }

        set_commands
      end

      # This method is a stub, here only for reference
      #
      # In every subclass of PackageManager::Base this method must be redefined
      # specifying the package manager specific command ( see Apt and Dpkg for
      # example )
      def set_commands; end

      # Print to log for debug purposes
      #
      # @param action [String] the action that is being performed
      # @param args [Array] an array of arguments for the specified action
      def debug(action, args = [])
        logger.debug "action : #{action}"
        logger.debug "args   : #{args.join(', ')}" unless args.empty?
        logger.debug "command: #{make_command(action, args)}"
      end

      # Creates a command putting together action and arguments
      #
      # @param action [String] the action that is being performed
      # @param args [Array] an array of arguments for the specified action
      def make_command(action, args = [])
        command = @commands[action.to_sym]
        command += " '" + args.join(' ') + "'" unless args.empty?

        command
      end

      # All execution is handled dinamically via this function
      #
      # If the method called is in the @commands Hash, the specified action is
      # performed, otherwise a NoMethodError exception
      #
      # @raise [NoMethodError] if the method specified is not available
      def method_missing(m, *args, &block)
        if @commands.has_key? m
          debug m, args

          unless Config.dry_run
            Open3.popen3(@commands[m]) { |stdin, stdout, stderr, wait_thr|
              pid = wait_thr.pid # pid of the started process.
              logger.debug "Running pid: #{pid}"

              logger.debug stdout.readlines

              exit_status = wait_thr.value.to_i # Process::Status object returned.
              logger.debug "Exit status: #{exit_status}"
              logger.error 'Some error happended during execution:' unless exit_status == 0
              logger.error stderr.readlines unless exit_status == 0
            }
          end
        else
          raise NoMethodError
        end
      end  
    end
  end
end
