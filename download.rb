require 'rest-client'
require 'json'

if ARGV.length != 1
  puts "Usage: download.rb <url>"
  exit
end

url = ARGV[0]

puts "Downloading #{url}"

vod_id = url.split("/")[-1]

token = JSON.parse(RestClient.get("https://api.twitch.tv/api/vods/#{vod_id}/access_token?as3=t"))
playlist = RestClient.get("http://usher.justin.tv/vod/#{vod_id}?nauthsig=#{token["sig"]}&nauth=#{token["token"]}")

vid_list_url = playlist.split("\n").select{|l| l.start_with? "http"}[0]
vid_list = RestClient.get(vid_list_url)
dl_url = "http://#{vid_list_url.split("/")[2..-2].join("/")}"

open("#{vod_id}.ts", "wb") do |file|
  vid_list.split("\n").each do |part|
    if part[0] != "#" && part != ""
      url = "#{dl_url}/#{part}"
      puts "Downloading part #{url}"
      resp = RestClient.get(url)

      file.write(resp.body)
    end
  end
end
