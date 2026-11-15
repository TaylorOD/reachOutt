class ReminderMailer < ApplicationMailer
  def reminder(reachout)
    user = reachout.user
    contact = reachout.contact
    name = [contact.first_name, contact.last_name].compact_blank.join(' ')
    body = "Hey #{user.first_name}! Time to reach out to #{name}."
    body += "\n\nPhone: #{contact.phone_number}" if contact.phone_number.present?
    suggestion = reachout.get_topic_data
    body += "\n\n#{suggestion}" if suggestion.present?
    body += "\n\nYou can pause or change this reminder on your ReachOutt reminders page."

    mail(
      to: user.email,
      from: ENV.fetch('MAIL_FROM', 'reachoutt@example.test'),
      subject: "Time to reach out to #{name}",
      body: body,
      content_type: 'text/plain'
    )
  end
end
