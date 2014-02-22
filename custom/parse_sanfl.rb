require 'date'

file = File.open("sanfl.txt")

str_date = ""

file.each do |line|

  if line.include?("day") || line.include?("Saturday") || line.include?("Sunday") || line.include?("Monday")

  	  str_date = line.chomp + " ,2014 , "

  elsif line.size < 3 || line.include?("ROUND")

  else
  	parts = line.chomp.split(" v ")
  	home_team = parts[0]
  	ground = "" 
  	if parts[1].include?("West") ||  parts[1].include?("North") || parts[1].include?("Central") || parts[1].include?("Port") || parts[1].include?("South")
  		away_team = parts[1].split(" ")[0] + " " + parts[1].split(" ")[1]
  		#parts[1].split(" ")[2..parts[1].split(" ").length-2].collect{|word| ground = ground + " " + word}
  		time = parts[1].split(" ").last

        #cstHoursOffset = 9.5
        #cstOffset = Rational(cstHoursOffset, 24) 
  		dt = (DateTime.parse(str_date+time + " +09:30")) #+ (cstHoursOffset/24.0)).new_offset(cstOffset)
  	else
  		away_team = parts[1].split(" ")[0]  		
  		time = parts[1].split(" ").last
  		dt = (DateTime.parse(str_date+time + " +09:30")) #+ (cstHoursOffset/24.0)).new_offset(cstOffset)
  	end

  	puts "#{home_team},#{away_team},#{dt}" 
  end


end
