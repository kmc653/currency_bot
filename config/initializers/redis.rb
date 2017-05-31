module Caching
  def self.currency
    Redis::Namespace.new("currency", redis: Redis.new)
  end

  def self.state
    Redis::Namespace.new("user_state", redis: Redis.new)
  end
end
