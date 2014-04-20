require 'twitter'
class TwitterSource
  def initialize
    keys = YAML.load_file(File.join(File.dirname(__FILE__), 'config', 'config.yml'))
    stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = keys['api_key']
      config.consumer_secret     = keys['api_secret']
      config.access_token        = keys['access_token']
      config.access_token_secret = keys['access_token_secret']
    end

    stream.user(with: 'user') do |object|
      Jarvis::Messages::Message.new('Twitter', build_message(object)) if accepted? object
    end
  end

  def build_message(object)
    message = object.text.strip
    case object
    when Twitter::Tweet
      screen_name = Rainbow("@#{object.user.screen_name.strip}").color(:white)
      type        = 'Tw'
    when Twitter::DirectMessage
      screen_name = Rainbow("@#{object.sender.screen_name.strip}").color(:white)
      type        = 'DM'
    end
    "[#{type}][#{screen_name}]: #{message}"
  end

  def accepted?(object)
    (object.is_a? Twitter::Tweet) || (object.is_a? Twitter::DirectMessage)
  end
end
