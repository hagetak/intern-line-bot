require 'line/bot'

class WebhookController < ApplicationController
  protect_from_forgery except: [:callback] # CSRF対策無効化

  SUSPENSION_THRESHOLD = 37.5

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head 470
    end


    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
              type: 'text',
              text: event.message['text']
          }
          begin
            validate_message!(event.message['text'])
          if event.message['text'].to_f >= SUSPENSION_THRESHOLD
            message['text'] = "出社NG"
          else
            message['text'] = "出社OK"
          end
          SlackNotificationService.info("[勤怠情報]", message['text'])
          rescue => e
            message['text'] = "数字送ってクレメンス"
            Rails.logger.error("Slack通知に失敗しました。#{e.message}")
          end
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }

    head :ok
  end

  private

  def validate_message!(message)
    # raise "invalid" unless input =~ /^[0-9]+$/
  end
end
