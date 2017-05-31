require "telegram/bot"
require "typhoeus"
require "typhoeus/adapters/faraday"

Telegram::Bot.configure do |config|
  config.adapter = :typhoeus
end

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  CURRENCY_BOT_TOKEN = "308381021:AAF4N8eQ3EwDtQUgWS8_IKyHp6wtVrMr3_k"

  def callback
    if callback_command?
      set_webhook_attributes

      # case @data
      # when /arrange/
      #   Washers::WasherArrangement.new(@chat_id, @message_id, @data).respond
      # when /notify/
      #   Washers::ArrangementNotify.new.respond(@chat_id, @message_id, @data)
      # when /package-info/
      #   Washers::PackageInfo.new(@chat_id, @message_id, @data).respond
      # when /package-state/
      #   Washers::PackageState.new(@chat_id, @message_id, @data).respond
      # when /get-package/
      #   Washers::GetPackage.new(@chat_id, @message_id, @data).respond
      # when /leave/
      #   Washers::WasherLeave.new(@chat_id, @message_id, @data).respond
      # else
      #   Bots::EditMessage.new(@chat_id, @message_id, @data).call
      # end
    else
      render_bot_commmands
    end
    head :ok
  end

  private

    def set_webhook_attributes
      callback_query = params[:webhook][:callback_query]
      @chat_id       = callback_query[:from][:id]
      @message_id    = callback_query[:message][:message_id]
      @data          = callback_query[:data]
    end

    def callback_command?
      params[:webhook][:callback_query].present?
    end

    def render_bot_commmands
      input_data = params[:webhook][:message]
      return unless input_data

      message = input_data
      BotCommandDispatcher.new(message, message[:chat][:id]).dispatch
    end
end
