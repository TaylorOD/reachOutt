# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
  :password, :token, :email, :phone, :first_name, :last_name,
  :authorization, :Body, :From, :To
]
