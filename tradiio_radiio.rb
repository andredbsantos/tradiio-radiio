#!/usr/bin/env ruby
# encoding: UTF-8

require 'slack-ruby-client'
require 'json'
require 'colorize'
require 'net/http'
require 'uri'

Slack.configure do |config|
    config.token = ARGV[0]
end

client = Slack::RealTime::Client.new

client.on :hello do
    puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com.".green
end

client.on :message do |data|
    case data.text
    when 'hit me!' then
        uri = URI.parse("http://51.255.33.53/tradiio-random/")
        response = Net::HTTP.get_response(uri)
        parsed = JSON.parse(response.body)
        songs = parsed['data']['songs']
        song = songs.sample
        puts "#{song['title']} by #{song['artist']['name']} - https://tradiio.com/#{song['artist']['slug']}/#{song['slug']}".yellow
        client.web_client.chat_postMessage(
            channel: data.channel,
            text: ' ',
            as_user: true,
            attachments: [
                {
                    title: "#{song['title']} by #{song['artist']['name']}",
                    title_link: "https://tradiio.com/#{song['artist']['slug']}/#{song['slug']}",
                    text: "Listen to more songs by <https://tradiio.com/#{song['artist']['slug']}|#{song['artist']['name']}!>",
                    thumb_url: "#{parsed['data']['images'][0]['normal']}",
                    fields: [
                        {
                            title: "Genre",
                            value: "<https://tradiio.com/home/top/#{song['genre']['id']}/all|#{song['genre']['title']}>",
                            short: true
                        },
                        {
                            title: "Playlist",
                            value: "<https://tradiio.com/playlist/#{parsed['data']['id']}/#{parsed['data']['slug']}|#{parsed['data']['name']}>",
                            short: true
                        }
                        ],
                    color: "good"
                }
                        ].to_json)
    end
end

client.on :close do |_data|
    puts "Client is about to disconnect".red
end

client.on :closed do |_data|
    puts "Client has disconnected successfully!".green
end

client.start!