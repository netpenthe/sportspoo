filename = "#{Rails.root}/config/betfair.yml"

if FileTest.exists?(filename)
  BETFAIR_CONFIG = YAML.load_file(filename)[Rails.env]
  puts "config/initializers/betfair.rb: loaded #{filename}"
else
  puts "config/initializers/betfair.rb: missing #{filename}"
end
