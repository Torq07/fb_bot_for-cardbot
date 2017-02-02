require 'facebook/messenger'
require "#{Rails.root}/app/bots/cardbot.rb"

if Rails.env.production?
  Dir["#{Rails.root}/app/bots/**/*.rb"].each { |file| require file }
end

class ExampleProvider < Facebook::Messenger::Configuration::Providers::Base
  def valid_verify_token?(verify_token)
    # bot.exists?(verify_token: verify_token)
    true
  end

  def app_secret_for(page_id)
    # bot.find_by(page_id: page_id).app_secret
    ENV['APP_SECRET']
  end

  def access_token_for(page_id)
    ENV['ACCESS_TOKEN']
    # bot.find_by(page_id: page_id).access_token
  end

  private

end

Facebook::Messenger.configure do |config|
	config.provider = ExampleProvider.new
end

access_token = ENV['ACCESS_TOKEN']

Facebook::Messenger::Subscriptions.subscribe(access_token: access_token)
