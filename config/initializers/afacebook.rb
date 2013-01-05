filename = "#{Rails.root}/config/facebook.yml"

if FileTest.exists?(filename)
  FB_CONFIG = YAML.load_file(filename)[Rails.env]
  puts "config/initializers/afacebook.rb: loaded #{filename}"
  #puts FB_CONFIG["facebook"]["APP_ID"]
else
  puts "config/initializers/afacebook.rb: missing #{filename}"
end
