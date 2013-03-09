filename = "#{Rails.root}/config/twitter.yml"

if FileTest.exists?(filename)
  TWITTER_CONFIG = YAML.load_file(filename)[Rails.env]
  puts "config/initializers/afacebook.rb: loaded #{filename}"
else
  puts "config/initializers/twitter.rb: missing #{filename}"
end

