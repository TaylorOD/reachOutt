class Reachout < ApplicationRecord
  FREQUENCIES = {
    '1d' => 'Daily', '7d' => 'Weekly', '14d' => 'Biweekly',
    '30d' => 'Monthly', '60d' => 'Bimonthly', '90d' => 'Quarterly',
    '182.5d' => 'Semiannually', '365d' => 'Annually'
  }.freeze

  belongs_to :user
  belongs_to :contact
  validates :frequency, inclusion: { in: FREQUENCIES.keys }
  validates :topic, inclusion: { in: %w[Jokes News Sports] }, allow_blank: true
  validate :valid_start_date
  validate :contact_belongs_to_user
  before_save :reset_schedule, if: -> { new_record? || will_save_change_to_start_date? || will_save_change_to_frequency? }

  def interval
    frequency.to_f.days
  end

  def friendly_frequency(value)
    FREQUENCIES.fetch(value, value)
  end

  def get_topic_data
    return unless topic.present?

    if topic == 'Jokes'
      data = HTTP.timeout(5).get('https://v2.jokeapi.dev/joke/Any', params: { 'safe-mode' => '', type: 'single' }).parse
      "Try this one: #{data['joke']}" if data['joke'].present?
    elsif ENV['NEWS_API_KEY'].present?
      source = topic == 'Sports' ? 'espn' : 'bbc-news'
      data = HTTP.timeout(5).get('https://newsapi.org/v2/top-headlines', params: { sources: source, apiKey: ENV['NEWS_API_KEY'] }).parse
      article = data.fetch('articles', []).first
      "Have they seen this? #{article['title']} #{article['url']}" if article
    end
  rescue HTTP::Error, JSON::ParserError, KeyError, TypeError, NoMethodError
    nil
  end

  private

  def valid_start_date
    Date.iso8601(start_date.to_s)
  rescue ArgumentError
    errors.add(:start_date, 'must be a valid date')
  end

  def contact_belongs_to_user
    errors.add(:contact, 'must belong to you') if contact && contact.user_id != user_id
  end

  def reset_schedule
    self.next_send_at = [Date.iso8601(start_date).in_time_zone, Time.current].max
  end
end
