# -*- encoding: utf-8 -*-

require 'logger'
require 'thor'

module Uberinstaller
  class Cli < Thor
    default_task :help

    desc "install FILE", "Install packages from the specified JSON FILE"
    method_option :verbose,
                  :type => :boolean,
                  :default => false, 
                  :aliases => "-v", 
                  :desc => "Enable verbose output"
    method_option :debug, 
                  :type => :boolean, 
                  :default => false, 
                  :aliases => "-d", 
                  :desc => "Enable debug output, include verbose option"
    method_option :dry_run,
                  :type => :boolean,
                  :default => false, 
                  :desc => "Enable dry run, no modification to the system will be made during this execution"
    def install(file)
      Uberinstaller::Loggable.level = Logger::WARN
      Uberinstaller::Loggable.level = Logger::INFO  if options[:verbose]
      Uberinstaller::Loggable.level = Logger::DEBUG if options[:debug]

      Uberinstaller::Loggable.log_path = File.join(File.dirname(file), 'log', "#{Time.now}.log") unless options[:debug]

      Uberinstaller::Config.uberdirectory = File.dirname file
      Uberinstaller::Config.dry_run = options[:dry_run]
      
      begin
        runner = Uberinstaller.new file
        runner.preprocess
        runner.install
      rescue Uberinstaller::Exception::WrongVersion, Uberinstaller::Exception::WrongArchitecture => e
        exit(127)
      end
    end
  end
end
