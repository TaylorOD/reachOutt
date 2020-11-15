class Reachout < ApplicationRecord
  belongs_to :user
  belongs_to :contact

  # converts frequency to nicer format for text messages and the front end
  def friendly_frequency(frequency)

    if frequency == "1d"
      frequency = "Daily"
    elsif frequency == "7d"
      frequency = "Weekly"
    elsif frequency == "14d"
      frequency = "Bi-Weekly"
    elsif frequency == "30d"
      frequency = "Monthly"
    elsif frequency == "60d"
      frequency = "Bi-Monthly"
    elsif frequency == "90d"
      frequency = "Quarterly"
    elsif frequency == "182.5d"
      frequency = "Semi-Annually"
    elsif frequency == "365d"
      frequency = "Annually"
    end
    p frequency
    return frequency
  end

  def get_topic_data
    if topic == "jokes"
      response = HTTP.get("https://sv443.net/jokeapi/v2/joke/Any?blacklistFlags=racist,sexist&type=single")
      return "Try this one: #{response.parse["joke"]}"
    elsif topic == "news"
      response = HTTP.get("https://newsapi.org/v1/articles?source=bbc-news&sortBy=top&apiKey=#{Rails.application.credentials.news_api[:api_key]}")
      return "Have they seen this? #{response.parse["articles"][0]["title"]} #{response.parse["articles"][0]["url"]}"
    elsif topic == "sports"
      # make api call then return data
    else
      nil
    end
  end

end
