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

    return frequency
  end
end
