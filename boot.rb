require 'optparse'

require 'bundler'
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

# https://bundler.io/v1.5/bundler_setup.html

require 'debug'
require 'active_support'
require 'active_support/core_ext/hash'
require 'active_support/time'
require 'active_support/json'
require 'logger'
require 'git'
require 'neatjson'


class App
  class << self
    def tmp_dir
      @@tmp_dir ||= begin
        tmp = self.root.join('tmp')
        tmp
      end
    end

    def root
      @@root ||= begin
        Pathname.new(File.expand_path(File.dirname(__FILE__)))
      end
    end

    # def config
    #   @@config ||= begin
    #     YAML.load_file(File.join(App.root, 'config.yml')).with_indifferent_access #.deep_symbolize_keys
    #   end
    # end

    def logger
      @@logger ||= begin
        log_file = File.open(File.join(App.root, 'log', 'application.log'), 'a')
        log_file.sync = true
        logger = Logger.new(log_file)

        logger.level = Logger::DEBUG
        logger.formatter = Logger::Formatter.new
        ActiveSupport::TaggedLogging.new(logger)
      end
    end
  end
end

# Now we can load our code like this:
#   require 'app/aaa/bbb'
$LOAD_PATH.unshift(File.dirname(__FILE__))

FileUtils.mkdir './log' unless Dir.exist? './log'
FileUtils.mkdir './tmp' unless Dir.exist? './log'

Dir["#{App.root}/lib/**/*.{rb}"].each { |f| load(f) }
Dir["#{App.root}/app/**/*.rb"].each { |f| load(f) }

