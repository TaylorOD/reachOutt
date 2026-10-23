require 'minitest/autorun'
require 'timeout'
class String
  def present?; !strip.empty?; end
end
class NilClass
  def present?; false; end
end
module ActionController
  class Base
    def self.protect_from_forgery(**); end
    def self.before_action(*); end
    def self.helper_method(*); end
    attr_accessor :request
  end
end
module JWT
  class ExpiredSignature < StandardError; end
  def self.decode(token, secret, verify, options)
    raise 'wrong verification' unless verify && options == {algorithm: 'HS256'} && secret == 'test-only-secret'
    raise ExpiredSignature if token == 'expired'
    $decoded_token = token
    [{'user_id' => 7}]
  end
end
module Rails
  def self.application; self; end
  def self.credentials; {secret_key_base: 'test-only-secret'}; end
end
class User
  def self.find_by(id:); raise 'wrong id' unless id == 7; :valid_user; end
end
load File.join(ARGV.fetch(0), 'app/controllers/application_controller.rb')
class BearerTokenTest < Minitest::Test
  def controller(header)
    value = ApplicationController.new
    value.request = Struct.new(:headers).new({'Authorization' => header})
    value
  end
  def test_acceptance_matches_old_parser
    headers = [nil, '', ' ', 'Bearer ', 'Bearer a.b.c', 'bearer abc', ' Bearer abc', 'Bearer  abc', "Bearer abc\n", "Bearer abc\r", "Bearer abc\t", "Bearer a b", 'Bearer ü', 'Bearer !', 'Basic abc', 'Bearer expired']
    headers.each do |header|
      $decoded_token=nil
      old = header && header[/(?<=\A(Bearer ))\S+\z/]
      result=controller(header).current_user
      if old && old != 'expired'
        assert_equal :valid_user,result
        assert_equal old,$decoded_token
      else
        assert_nil result
        assert_nil $decoded_token
      end
    end
  end
  def test_long_adversarial_headers_finish
    Timeout.timeout(2) do
      assert_nil controller(('!' * 1_000_000) + ' ').current_user
      assert_nil controller('Bearer ' + ('!' * 1_000_000) + ' ').current_user
    end
  end
end
