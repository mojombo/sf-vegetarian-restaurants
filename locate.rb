# encoding: utf-8
require 'rubygems'
require 'oauth'
require 'json'
require 'uri'

# load yelp credentials
load './.yelprc'

consumer = OAuth::Consumer.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'], {:site => "http://api.yelp.com"})
access_token = OAuth::AccessToken.new(consumer, ENV['TOKEN'], ENV['TOKEN_SECRET'])

path = '/v2/search?term=%s&location=San Francisco'

readme = File.read('./README.md')
new_readme = ""
readme.each_line do |line|
  if (name = line[/^*\*([^\(]+)/, 1]) && !line.include?('yelp.com')
    response = access_token.get(URI.encode(path % name.strip)).body
    json = JSON.parse(response)
    businesses = Array(json['businesses'])

    locations = businesses.select do |business|
      # double check what we're looking for
      business['name'].downcase.include?(name.strip.downcase) && business['location']['city'] == 'San Francisco'
    end.map do |business|
      " [#{business['location']['address'].first}](#{business['url']})"
    end

    line = line.chop << locations.join(',') << "\n"
  end
  new_readme << line
end

File.open('./README.md', 'w') {|f| f.write new_readme}

