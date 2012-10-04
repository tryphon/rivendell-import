require 'database_cleaner'

RSpec.configure do |config|

  config.before(:suite) do
    # DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
  
end
