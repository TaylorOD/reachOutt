class Reachout < ApplicationRecord
  belongs_to :user
  belongs_to :contact

  # converts frequency to nicer format for text messages and the front end
  def friendly_frequency(frequency)
    case frequency
    when "1d"
      "Daily"
    when "7d"
      "Weekly"
    when "14d"
      "Bi-Weekly"
    when "30d"
      "Monthly"
    when "60d"
      "Bi-Monthly"
    when "90d"
      "Quarterly"
    when "182.5d"
      "Semi-Annually"
    when "365d"
      "Annually"
    else
      frequency
    end
  end

  def get_topic_data
    if topic == "Jokes"
      response = HTTP.get("https://sv443.net/jokeapi/v2/joke/Any?blacklistFlags=racist,sexist&type=single")
      return "Try this one: #{response.parse["joke"]}"
    elsif topic == "News"
      response = HTTP.get("https://newsapi.org/v1/articles?source=bbc-news&sortBy=top&apiKey=#{Rails.application.credentials.news_api[:api_key]}")
      return "Have they seen this? #{response.parse["articles"][0]["title"]} #{response.parse["articles"][0]["url"]}"
    elsif topic == "Sports"
      response = HTTP.get("https://newsapi.org/v2/top-headlines?sources=espn&sortBy=popularity&apiKey=#{Rails.application.credentials.sports_api[:api_key]}")
      return "Have they seen this? #{response.parse["articles"][0]["title"]} #{response.parse["articles"][0]["url"]}"
    else
      nil
    end
  end

end
