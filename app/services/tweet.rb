class Tweet

	def initialize(tweet)
		perform(tweet)
	end

	def twitter_connection
		Twitter::REST::Client.new do |config|
		  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
		  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
		  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
		  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
		end
	end

	def send_tweet(tweet)
		client = twitter_connection
		client.update(tweet)
	end

	def perform(tweet)
		send_tweet(tweet)
	end

end