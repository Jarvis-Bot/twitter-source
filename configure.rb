class Configure
  def initialize
    ask_keys
    write_config_file
  end

  def ask_keys
    @keys = {}
    print 'Enter your API key : '
    @keys['api_key'] = $stdin.gets.chomp.strip
    print 'Enter your API secret : '
    @keys['api_secret'] = $stdin.gets.chomp.strip
    print 'Enter your access token : '
    @keys['access_token'] = $stdin.gets.chomp.strip
    print 'Enter your access token secret : '
    @keys['access_token_secret'] = $stdin.gets.chomp.strip
  end

  def write_config_file
    folder = File.join(File.dirname(__FILE__), 'config')
    file   = 'config.yml'

    Dir.mkdir(folder, 0755) unless Dir.exist?(folder)

    File.open(File.join(folder, file), 'w') do |f|
      @length = f.write(@keys.to_yaml)
    end

    puts "#{file} has been successfully created!" if @length > 1
  end
end
