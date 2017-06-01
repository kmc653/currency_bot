module Caching
  def self.currency
    Redis::Namespace.new("currency", redis: Redis.new)
  end

  def self.state
    Redis::Namespace.new("user_state", redis: Redis.new)
  end

  def self.currency_notify
    Redis::Namespace.new("currency_notify", redis: Redis.new)
  end

  def self.currency_notify_rate
    Redis::Namespace.new("currency_notify_rate", redis: Redis.new)
  end

  def self.user_list
    Redis::Namespace.new("user", redis: Redis.new)
  end
end
