# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'

require 'open3'

module Uberinstaller
  module PackageManager
    class Base
      include Loggable

      attr_reader :commands

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
      end

      def debug(action, args = [])
        logger.debug 'PackageManager action: ' + action.to_s
        logger.debug 'PackageManager args: ' + args.join(', ') unless args.empty?
      end

      def method_missing(m, *args, &block)
        if @commands.has_key? m
          debug m, args

          logger.info "Running action: #{m}"

          logger.warn "execution disabled"
          # Open3.popen3(@commands[m]) { |stdin, stdout, stderr, wait_thr|
          #   pid = wait_thr.pid # pid of the started process.
          #   logger.debug "Running pid: #{pid}"

          #   logger.debug stdout.readlines

          #   exit_status = wait_thr.value.to_i # Process::Status object returned.
          #   logger.debug "Exit status: #{exit_status}"
          #   logger.error 'Some error happended during execution:' unless exit_status == 0
          #   logger.error stderr.readlines unless exit_status == 0
          # }
        else
          puts "There's no method called #{m} here -- please try again."  
        end
      end  
    end
  end
end


require 'uberinstaller/package_managers/apt'
