require 'twitter'
class TwitterSource
  def initialize
    stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = "CONSUMER_KEY"
      config.consumer_secret     = "CONSUMER_SECRET"
      config.access_token        = "ACCESS_TOKEN"
      config.access_token_secret = "ACCESS_TOKEN_SECRET"
    end

    stream.user(with: 'user') do |object|
      if (object.is_a? Twitter::Tweet) || (object.is_a? Twitter::DirectMessage)
        Jarvis::Messages::Message.new('Twitter', build_message(object))
      end
    end
  end

  def build_message(object)
    message = object.text.strip
    case object
    when Twitter::Tweet
      screen_name = object.user.screen_name.strip
      name        = Rainbow(object.user.name.strip).color(:white)
      type        = 'Tw'
    when Twitter::DirectMessage
      screen_name = object.sender.screen_name.strip
      name        = Rainbow(object.sender.name.strip).color(:white)
      type        = 'DM'
    end
    "[#{type}][#{name}] @#{screen_name}: #{message}"
  end
end
