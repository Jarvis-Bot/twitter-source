require 'twitter'
require 'yaml'
class TwitterSource
  def initialize
    keys = keys_file
    stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = keys['api_key']
      config.consumer_secret     = keys['api_secret']
      config.access_token        = keys['access_token']
      config.access_token_secret = keys['access_token_secret']
    end

    stream.user(with: 'user') do |object|
      @object = object
      @white_list = object if object.is_a? Twitter::Streaming::FriendList
      Jarvis::Messages::Message.new('Twitter', built_message, object) if accepted?
    end
  end

  def keys_file
    YAML.load_file(File.join(File.dirname(__FILE__), 'config', 'config.yml'))
  rescue Errno::ENOENT
    Jarvis::Utility::Logger.error("config.yml not found in #{__dir__}. Please, configure TwitterSource with 'jarvis configure'")
  end

  def built_message
    message = @object.text.strip
    case @object
    when Twitter::Tweet
      screen_name = Rainbow("@#{@object.user.screen_name.strip}").color(:white)
      type        = 'Tw'
    when Twitter::DirectMessage
      screen_name = Rainbow("@#{@object.sender.screen_name.strip}").color(:white)
      type        = 'DM'
    end
    "[#{type}][#{screen_name}]: #{message}"
  end

  def accepted?
    ((@object.is_a? Twitter::Tweet) || (@object.is_a? Twitter::DirectMessage)) && white_listed?
  end

  def white_listed?
    case @object
    when Twitter::Tweet
      @white_list.include? @object.user.id
    when Twitter::DirectMessage
      @white_list.include? @object.sender.id
    end
  end
end
