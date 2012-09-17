require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

require 'rivendell/import'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

require "logger"
Rivendell::Import.logger = Logger.new("log/test.log")

RSpec.configure do |config|
end
