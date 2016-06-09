require 'consumer'
require 'redis'

class TweetStorer
  attr_accessor :consumer, :redis

  def initialize(logfile, redis)
    self.consumer = Consumer.new(logfile) do |event|
      self.process(event)
    end
    self.redis = redis
  end

  def start
    consumer.start
  end

  def process(event)
    if event['type'] == 'tweet'
      tweet_id = event['tweet_id']
      redis.mapped_hmset("tweet:#{tweet_id}", event)
    end
  end
end

redis = Redis.new
tweet_storer = TweetStorer.new('log.txt', redis)
tweet_storer.start
