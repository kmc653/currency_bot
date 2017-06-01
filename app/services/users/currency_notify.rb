require 'telegram/bot'

module Users
  class CurrencyNotify

    CURRENCY_BOT_TOKEN = "308381021:AAF4N8eQ3EwDtQUgWS8_IKyHp6wtVrMr3_k"

    def initialize(chat_id, message_id, message=nil)
      @chat_id = chat_id
      @message_id = message_id
      @message = message
    end

    def call
      message = "請選擇以下幣別"
      Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: default_keyboard,
                                                               resize_keyboard: true)
        bot.api.sendMessage(chat_id: @chat_id, text: message, reply_markup: markup)
      end
    end

    def set
      set_currency_notify_rate_in_redis

      Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
        bot.api.sendMessage(chat_id: @chat_id, text: rate_message)
      end
    end

    private

      def rate_message
        "已設定匯率：#{@message}"
      end

      def set_currency_notify_rate_in_redis
        Caching.currency_notify_rate.rpush @chat_id, @message
      end

      def default_keyboard
        [
          %w(USD EUR),
          %w(JPY CNY),
          %w(SGD KRW)
        ]
      end
  end
end
