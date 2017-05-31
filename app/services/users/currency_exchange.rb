require 'telegram/bot'

module Users
  class CurrencyExchange

    CURRENCY_BOT_TOKEN = "308381021:AAF4N8eQ3EwDtQUgWS8_IKyHp6wtVrMr3_k"

    def initialize(chat_id, message_id)
      @chat_id = chat_id
      @message_id = message_id
    end

    def call
      message = "請選擇幣別"
      Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: default_keyboard,
                                                               resize_keyboard: true)
        bot.api.sendMessage(chat_id: @chat_id, text: message, reply_markup: markup)
      end
    end

    private

      def default_keyboard
        [
          %w(USD EUR),
          %w(JPY CNY)
        ]
      end
  end
end
