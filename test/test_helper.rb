ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :users, :groups, :training_schemas, :training_sessions, :attendances # <-- New minimal set

    # Add more helper methods to be used by all tests here...
  end
end
