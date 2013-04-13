require 'rubygems'
require 'fastercsv'
namespace :citiestz do

  task :load => :environment do

    CSV.foreach("data/citiestz.txt", :encoding => 'u') do |row|
      c=Citytimezones.find(:first,:conditions=>["city=? and country =?",row[0],row[2]])
      if (c.nil?)
        c= Citytimezones.new
        c.city = row[0]
        c.country = row[2]
      end
      c.tz_detail = row[1]
      c.tz = row[5]
      foo = row[1]

  # need to extract from: (GMT-08:00) Pacific Time (US & Canada); Tijuana
  #             and also: (GMT+08:00) Beijing, Chongqing, Hong Kong, Urumqi
      x=foo.to_s.gsub(/;.*/,"").gsub(/.*\) /,"").split(",")
      x.map!{|f| f.strip}
      puts "city is: "+c.city+", row is: "+row[1]
      puts "  "+x.to_s

      if (x.include?(c.city)) 
        puts "  -- CITY "+c.city
        c.tz_dropdown = c.city
      else
        puts " -- "+x[0]
        c.tz_dropdown = x[0]
  
      end
      c.latitude = row[3]
      c.longitude = row[4]
      c.save! 
    end

  end
end
