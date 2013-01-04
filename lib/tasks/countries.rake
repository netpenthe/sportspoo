
namespace :countries do

  task :load => :environment do

    File.open("data/countries.txt", "r") do |file_handle|

    file_handle.each_line do |line|
     parts = line.split ";"
     break if parts[0].blank? || parts[1].blank?
     c = Country.new
     c.name = parts[0].chomp
     c.code = parts[1].chomp
     c.save unless c.name=="Country Name" || c.name.blank?
     puts "adding #{c.name}"
     end
    end

  end
end
