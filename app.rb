require 'sinatra'
require 'json'
require 'time'
require 'redis'

$redis = Redis.new

def event_log
  @event_log ||= Logger.new(File.join(File.dirname(__FILE__), 'log.txt'))

  @event_log.formatter = proc do |severity, datetime, progname, msg|
    {time: datetime.iso8601}.merge(msg).to_json + "\n"
  end

  @event_log
end

def log(data)
  event_log.info(data)
end

get '/user/:user_id' do
  tweet_ids = $redis.lrange("author_timeline:#{params[:user_id]}", 0, -1)
  @tweets = tweet_ids.map { |tweet_id| $redis.hgetall("tweet:#{tweet_id}") }
  erb :timeline
end

post '/tweet' do
  log(type: 'tweet', body: params[:body], user_id: params[:user_id], tweet_id: SecureRandom.uuid)

  redirect "/user/#{params[:user_id]}"
end
