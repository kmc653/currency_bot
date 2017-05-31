require 'csv'
require 'json'

module Api
  class GetRate
    def call
      api_url = "http://rate.bot.com.tw/xrt/flcsv/0/day"

      response = Typhoeus::Request.new(api_url,
                                       method: :get).run
      return false unless response.code == 200

      File.open("input.csv", "w", col_sep: "$", encoding: "utf-8") do |f|
        f.write response.body.force_encoding("utf-8")
      end

      @result = CSV.parse(response.body).to_json
      @result = Oj.load(@result)
      save_currency_to_redis
      true
    end

    private

      def save_currency_to_redis
        @result.shift
        @result.each_with_index do |value, index|
          Caching.currency.hset value[0], "buy", value[2]
          Caching.currency.hset value[0], "sell", value[12]
          Caching.currency.expire value[0], 1.day.to_i
        end
      end
  end
end
