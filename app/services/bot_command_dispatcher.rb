class BotCommandDispatcher
  attr_reader :message

  CURRENCY_BOT_TOKEN = "308381021:AAF4N8eQ3EwDtQUgWS8_IKyHp6wtVrMr3_k"

  def initialize(message, chat_id)
    @message = message
    @chat_id = chat_id
  end

  def dispatch
    case @message[:text]
    when "查看匯率"
      set_user_state_in_redis("check_currency")
      return Users::CheckCurrency.new(@chat_id, @message[:message_id]).call
    when "匯率換算"
      set_user_state_in_redis("currency_exchange")
      return Users::CurrencyExchange.new(@chat_id, @message[:message_id]).call
    when "輸入台幣總額"
      set_exchange_type_in_redis("twd")
      return Users::CalculateExchange.new(@chat_id, @message[:message_id]).twd
    when "輸入外幣總額"
      set_exchange_type_in_redis("other")
      return Users::CalculateExchange.new(@chat_id, @message[:message_id]).other
    when /\/start$/i
      message = "請選擇以下功能"
      Telegram::Bot::Client.run(CURRENCY_BOT_TOKEN) do |bot|
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: default_keyboard,
                                                               resize_keyboard: true)
        bot.api.sendMessage(chat_id: @chat_id, text: message, reply_markup: markup)
      end
      Api::GetRate.new.call unless currency_in_redis?
    else
      return Users::CurrencySelect.new(@chat_id, @message[:message_id], @message[:text]).call
    end
  end

  private

    def currency_in_redis?
      Caching.currency.exists "USD"
    end

    def set_user_state_in_redis(status)
      Caching.state.hset @chat_id, "status", status
    end

    def set_exchange_type_in_redis(type)
      Caching.state.hset @chat_id, "type", type
    end

    def default_keyboard
      [
        %w(查看匯率),
        %w(匯率換算)
      ]
    end
end
