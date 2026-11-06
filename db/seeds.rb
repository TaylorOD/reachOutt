# Demo data is opt in and never runs in production.
if Rails.env.development? && ENV['SEED_DEMO'] == 'true'
  user = User.find_or_initialize_by(email: 'alex@example.test')
  if user.new_record?
    user.update!(first_name: 'Alex', last_name: 'Example', password: 'local demo password', phone_number: '+15005550006')
  end
  user.contacts.find_or_create_by!(first_name: 'Sam', last_name: 'Example') do |contact|
    contact.phone_number = '+15005550006'
  end
end
