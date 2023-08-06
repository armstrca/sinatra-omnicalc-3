require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

@gmaps_key = ENV.fetch("GMAPS_KEY")
@weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
get("/") do
erb(:home)
end


get("/umbrella") do
erb(:umbrella)
end

get("/process_umbrella") do
  @loc = params.fetch("user_loc")
  gmaps_key = ENV.fetch("GMAPS_KEY")
  google_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@loc}&key=#{gmaps_key}"
  @loc = @loc.gsub("_"," ")
  gmaps_data = HTTP.get(google_url)
  parsed_gmaps_data = JSON.parse(gmaps_data)
  results = parsed_gmaps_data.fetch("results")
  results2 = results.fetch(0)
  geometry = results2.fetch("geometry")
  location = geometry.fetch("location")
  @lat = location.fetch("lat")
  @lng = location.fetch("lng")

  weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
  weather_url = "https://api.pirateweather.net/forecast/#{weather_key}/#{lat},#{lng}"

  weather_data = HTTP.get(weather_url)
  parsed_weather_data = JSON.parse(weather_data)
  @currently = parsed_weather_data.fetch("currently")
  @current_temperature = currently.fetch("temperature")
  hourly = parsed_weather_data.fetch("hourly")
  next_hour_summary = hourly.fetch("summary")
  hourly_data_array = hourly.fetch("data")
  hourly_data_hash = hourly_data_array.at(0)
  first_hourly_precip = hourly_data_hash.fetch("precipProbability")

  twelvehour_data_hash = hourly_data_array[1..12]


  #pp "The current temperature in #{@loc} is #{current_temperature} degrees Fahrenheit."
  #pp "The forecast for the next hour in #{@loc} is #{next_hour_summary}."
  #pp "The precipitation probability for the next hour in #{@loc} is #{(first_hourly_precip*100).round}%."

  yesrainy = false
  precipprob_array = []  
  preciptime_array = []

  def umbrella_or_no
    twelvehour_data_hash.each do |hourly|
      precipprob = hourly.fetch("precipProbability")
      precipprob_array << precipprob  

      if precipprob > 0.1
        yesrainy = true
        precip_time = Time.at(hourly.fetch("time"))
        seconds_from_now = precip_time - Time.now
        hours_from_now = seconds_from_now / 60 / 60
    #    pp "In #{hours_from_now.round} hours, there is a #{(precipprob*100).round}% chance of precipitation."
      else
        precip_time = Time.at(hourly.fetch("time"))
        seconds_from_now = precip_time - Time.now
        preciptime_array << hours_from_now = (seconds_from_now / 60 / 60).round
      end
    end


    if yesrainy
      pp "You might want an umbrella today!"
    else
      pp "You probably won't need an umbrella today."
    end
  end

  erb(:process_umbrella)
end

=begin

@loc = gets.chomp.gsub(" ","_")
gmaps_key = ENV.fetch("GMAPS_KEY")
google_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@loc}&key=#{gmaps_key}"
@loc = @loc.gsub("_"," ")
gmaps_data = HTTP.get(google_url)
parsed_gmaps_data = JSON.parse(gmaps_data)
results = parsed_gmaps_data.fetch("results")
results2 = results.fetch(0)
geometry = results2.fetch("geometry")
location = geometry.fetch("location")
lat = location.fetch("lat")
lng = location.fetch("lng")

weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
weather_url = "https://api.pirateweather.net/forecast/#{weather_key}/#{lat},#{lng}"

weather_data = HTTP.get(weather_url)
parsed_weather_data = JSON.parse(weather_data)
currently = parsed_weather_data.fetch("currently")
current_temperature = currently.fetch("temperature")
hourly = parsed_weather_data.fetch("hourly")
next_hour_summary = hourly.fetch("summary")
hourly_data_array = hourly.fetch("data")
hourly_data_hash = hourly_data_array.at(0)
first_hourly_precip = hourly_data_hash.fetch("precipProbability")

twelvehour_data_hash = hourly_data_array[1..12]


pp "The current temperature in #{@loc} is #{current_temperature} degrees Fahrenheit."
pp "The forecast for the next hour in #{@loc} is #{next_hour_summary}."
pp "The precipitation probability for the next hour in #{@loc} is #{(first_hourly_precip*100).round}%."

yesrainy = false
precipprob_array = []  
preciptime_array = []

twelvehour_data_hash.each do |hourly|
  precipprob = hourly.fetch("precipProbability")
  precipprob_array << precipprob  

  if precipprob > 0.1
    yesrainy = true
    precip_time = Time.at(hourly.fetch("time"))
    seconds_from_now = precip_time - Time.now
    hours_from_now = seconds_from_now / 60 / 60
    pp "In #{hours_from_now.round} hours, there is a #{(precipprob*100).round}% chance of precipitation."
  else
    precip_time = Time.at(hourly.fetch("time"))
    seconds_from_now = precip_time - Time.now
    preciptime_array << hours_from_now = (seconds_from_now / 60 / 60).round
  end
end


if yesrainy
  pp "You might want an umbrella today!"
else
  pp "You probably won't need an umbrella today."
end




=end
