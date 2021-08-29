# frozen_string_literal: true

require 'bundler/setup'
require 'rspec' # Use the RSpec framework
require_relative '../lib/skeem'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    # Disable the `should` synta
    c.syntax = :expect
  end

  # Display stack trace in case of failure
  config.full_backtrace = true
end


module InterpreterSpec
  def expect_expr(aSkeemExpr)
    result = subject.run(aSkeemExpr)
    expect(result)
  end

  # rubocop: disable Lint/RescueException

  # This method assumes that 'subject' is a Skeem::Interpreter instance.
  def compare_to_predicted(arrActualsPredictions)
    arrActualsPredictions.each_with_index do |(source, predicted), index|
      result = subject.run(source)
      if block_given?
        yield result, predicted
      else
        expect(result).to eq(predicted)
      end

    rescue Exception => e
      $stderr.puts "Row #{index + 1} failed."
      throw e
    end
  end
  # rubocop: enable Lint/RescueException
end
