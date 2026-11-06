require 'test_helper'
require 'minitest/mock'

class ReminderDeliveryTest < ActiveSupport::TestCase
  test 'SMS is opt in and configured delivery sends one message' do
    keys = %w[SMS_ENABLED SMS_ALLOWED_RECIPIENTS TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN TWILIO_FROM_NUMBER]
    previous = keys.to_h { |key| [key, ENV[key]] }
    ENV['SMS_ENABLED'] = 'false'
    assert_equal false, ReminderDelivery.call(nil)
    ENV['SMS_ENABLED'] = 'true'
    ENV['TWILIO_ACCOUNT_SID'] = 'ACtest'
    ENV['TWILIO_AUTH_TOKEN'] = 'test token'
    ENV['TWILIO_FROM_NUMBER'] = '+15005550006'
    user = create_user
    ENV['SMS_ALLOWED_RECIPIENTS'] = user.phone_number
    contact = user.contacts.create!(first_name: 'Sam', phone_number: '+15005550006')
    reminder = user.reachouts.create!(contact: contact, frequency: '1d', start_date: Date.current.iso8601)
    messages = Minitest::Mock.new
    messages.expect(:create, true) do |**options|
      options[:from] == '+15005550006' && options[:to] == user.phone_number && options[:body].include?('Sam')
    end
    client = Struct.new(:messages).new(messages)
    factory = ->(*args) do
      assert_instance_of Twilio::HTTP::Client, args[4]
      assert_equal 10, args[4].timeout
      client
    end
    Twilio::REST::Client.stub(:new, factory) do
      assert ReminderDelivery.call(reminder)
    end
    messages.verify
  ensure
    previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  test 'unapproved recipients never reach Twilio' do
    previous = ENV.to_h.slice('SMS_ENABLED', 'SMS_ALLOWED_RECIPIENTS')
    ENV['SMS_ENABLED'] = 'true'
    ENV['SMS_ALLOWED_RECIPIENTS'] = '+15005550007'
    user = create_user
    contact = user.contacts.create!(first_name: 'Sam')
    reminder = user.reachouts.create!(contact: contact, frequency: '1d', start_date: Date.current.iso8601)
    Twilio::REST::Client.stub(:new, ->(*) { flunk 'unapproved text reached Twilio' }) do
      assert_raises(ArgumentError) { ReminderDelivery.call(reminder) }
      ENV.delete('SMS_ALLOWED_RECIPIENTS')
      assert_raises(ArgumentError) { ReminderDelivery.call(reminder) }
    end
  ensure
    %w[SMS_ENABLED SMS_ALLOWED_RECIPIENTS].each { |key| ENV[key] = previous[key] }
  end
end
