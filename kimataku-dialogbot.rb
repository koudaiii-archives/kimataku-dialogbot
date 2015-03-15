#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'logger'
require 'tweetstream'
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

log = Logger.new(STDOUT)
STDOUT.sync = true

# REST API
rest = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

# Streaming API
TweetStream.configure do |config|
  config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  config.auth_method        = :oauth
end
stream = TweetStream::Client.new

log.info('Working up to save the world... %s' % ["#{Time.now}"])
log.info('Listening... %s' % ["#{Time.now}"])

stream.on_error do |message|
  log.info('Error: %s' % ["#{Time.now}"])
  raise message
end

stream.on_timeline_status do |status|
  next if status.retweet?
  if status.reply? && status.user.screen_name != "koudaiii" && status.user.screen_name != "kimataku_bot"
    log.info('reply to @%s said : %s' % [status.user.screen_name, status.text])
    dialog = '@%s ' % status.user.screen_name
    dialog += reply_text(status.text)
    log.info('dialog to @%s : %s' % [status.user.screen_name, dialog])
    begin
      tweet = rest.update("#{dialog}", in_reply_to_status_id: status.id)
      if tweet
        log.info('tweeted: %s' % tweet.text)
      end
    rescue => e
      log.error(e)
    end
  end
end

def reply_text(text="")
  apikey = ENV['DOCOMO_API_KEY']
  uri = URI.parse("https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{apikey}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  body = {}
  body['utt'] = text
  body['t'] = 20

  request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/json'})
  request.body = body.to_json

  response = nil
  resp = http.request(request)
  response = JSON.parse(resp.body)

  return response['utt']
end

stream.userstream
