require 'telegram/bot'

module Users
  class CurrencySelect

    CURRENCY_BOT_TOKEN = "308381021:AAF4N8eQ3EwDtQUgWS8_IKyHp6wtVrMr3_k"

    def initialize(chat_id, message_id, message)
      @chat_id = chat_id
      @message_id = message_id
      @message = message
    end

    def call
      if check_currency?
        show_currency_rate
      else
        count_currency_exchange
      end
    end

    private

      def count_currency_exchange
        message = "請選擇以下換算方式"
        Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
          markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: default_keyboard,
                                                                 resize_keyboard: true)
          bot.api.sendMessage(chat_id: @chat_id, text: message, reply_markup: markup)
        end
      end

      def show_currency_rate
        get_currency_rate
        Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
          bot.api.sendMessage(chat_id: @chat_id, text: currency_rate_message)
        end
      end

      def currency_rate_message
        "#{@message}\n銀行買入：#{@buy_rate}\n銀行賣出：#{@sell_rate}"
      end

      def get_currency_rate
        @buy_rate = Caching.currency.hget @message, "buy"
        @sell_rate = Caching.currency.hget @message, "sell"
      end

      def check_currency?
        state = Caching.state.hget @chat_id, "status"
        state.to_s == "check_currency"
      end

      def default_keyboard
        [
          %w(輸入台幣總額),
          %w(輸入外幣總額)
        ]
      end
  end
end
