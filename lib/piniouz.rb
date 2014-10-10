require 'rubygems'
require 'optparse'
require 'toml'

require 'piniouz/command'
require 'piniouz/mailchimp'
require 'piniouz/pin'
require 'piniouz/pinboard'
require 'piniouz/template'
require 'piniouz/version'

module Piniouz

  # default path where conf file is located
  DEFAULT_CONF_PATH = "/etc/piniouz"

  # default directory (relative to current user's home) where user's conf file is located
  DEFAULT_USER_CONF_DIR = ".piniouz"

  # conf file
  CONF_FILE = "piniouz.toml"

  class << self
    def default_conf_file
      @default_conf_file ||= File.join(DEFAULT_CONF_PATH, CONF_FILE)
    end

    def default_user_conf_file
      @default_user_conf_file ||= File.join(Piniouz.find_home, DEFAULT_USER_CONF_DIR, CONF_FILE)
    end

    # Finds the user's home directory
    #
    # @note Borrowed from rubygems
    # @api private
    #
    # @return [String] Directory path
    def find_home
      ['HOME', 'USERPROFILE'].each do |homekey|
        return ENV[homekey] if ENV[homekey]
      end

      if ENV['HOMEDRIVE'] && ENV['HOMEPATH'] then
        return "#{ENV['HOMEDRIVE']}:#{ENV['HOMEPATH']}"
      end

      begin
        File.expand_path("~")
      rescue
        if File::ALT_SEPARATOR then
            "C:/"
        else
            "/"
        end
      end
    end

    def parse_args!(argv)
      args = {
        :command    => 'create',
        :newsletter => 'default',
        :conf_file  => nil,
      }

      # define parser
      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: piniouz [-nch] <command>"

        opts.define_head "Creating weekly newsletters with pinboard and mailchimp."

        opts.on("-n", "--newsletter", "Newsletter id (default: #{args[:newsletter]})") do |value|
          args[:newsletter] = argv[1]
        end

        opts.on("-c", "--conf", "Conf file path (default: #{self.default_user_conf_file} or #{self.default_conf_file})") do |value|
          args[:newsletter] = argv[1]
        end

        opts.on("-?", "-h", "--help", "Show this help message") do
          puts opts
          exit
        end

        opts.on_tail("--version", "Show version") do
          puts Piniouz::VERSION
          exit
        end

      end

      # parse what we have on the command line
      opt_parser.parse!(argv)

      args[:command] = argv[0] unless argv[0].nil? || argv[0].empty?

      args
    end

    def log(msg)
      puts "[piniouz] #{msg}"
    end

    # run command
    def run(command, args)
      Piniouz::Command.new(command, args).run
    end

  end # class << self

end # module Piniouz
