require 'telegram/bot'

module Users
  class CalculateExchange

    CURRENCY_BOT_TOKEN = "308381021:AAF4N8eQ3EwDtQUgWS8_IKyHp6wtVrMr3_k"

    def initialize(chat_id, message_id, message=nil)
      @chat_id = chat_id
      @message_id = message_id
      @message = message
    end

    def twd
      message = "請輸入欲換台幣總額"
      Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
        bot.api.sendMessage(chat_id: @chat_id, text: message)
      end
    end

    def other
      message = "請輸入欲換外幣總額"
      Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
        bot.api.sendMessage(chat_id: @chat_id, text: message)
      end
    end

    def calculate
      user_state = get_user_state_in_redis
      return unless user_state.eql?("currency_exchange")

      exchange_type = get_exchange_type_in_redis
      currency = get_exchange_currency_in_redis
      calculate_result(exchange_type, currency)
    end

    private

      def calculate_result(type, currency)
        return unless type

        case type
        when "twd"
          rate = Caching.currency.hget currency, "sell"
          amount = @message.to_f / rate.to_f

          Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
            bot.api.sendMessage(chat_id: @chat_id, text: show_amount(amount, currency))
          end
        when "other"
          rate = Caching.currency.hget currency, "sell"
          amount = rate.to_f * @message.to_f

          Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
            bot.api.sendMessage(chat_id: @chat_id, text: show_amount(amount, "TWD"))
          end
        end
      end

      def show_amount(amount, currency)
        case currency
        when "TWD"
          "需準備 #{amount.round} TWD"
        else
          "可換得 #{amount.round} #{currency}"
        end
      end

      def get_user_state_in_redis
        Caching.state.hget @chat_id, "status"
      end

      def get_exchange_type_in_redis
        Caching.state.hget @chat_id, "type"
      end

      def get_exchange_currency_in_redis
        Caching.state.hget @chat_id, "currency"
      end
  end
end
