filename = "#{Rails.root}/config/betfair.yml"

if FileTest.exists?(filename)
  BF_CONFIG = YAML.load_file(filename)[Rails.env]
  puts "config/initializers/betfair.rb: loaded #{filename}"
else
  puts "config/initializers/betfair.rb: missing #{filename}"
end
