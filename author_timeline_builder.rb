require 'consumer'
require 'redis'

class AuthorTimelineBuilder
  attr_accessor :consumer, :redis

  def initialize(logfile, redis)
    self.consumer = Consumer.new(logfile) do |event|
      process(event)
    end
    self.redis = redis
  end

  def start
    consumer.start
  end

  def process(event)
    if event['type'] == 'tweet'
      user_id = event['user_id']
      tweet_id = event['tweet_id']
      redis.rpush("author_timeline:#{user_id}", tweet_id)
    end
  end
end

redis = Redis.new
tweet_storer = AuthorTimelineBuilder.new('log.txt', redis)
tweet_storer.start
