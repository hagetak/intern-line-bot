class SlackNotificationService
  DEFAULT_TIMEOUT = 3

  class << self
    def info(title, message, option = {})
      notify(:info, title, message, option)
    end

    def warn(title, message, option = {})
      notify(:warn, title, message, option)
    end

    private

    def notify(type, title, message, option)
      return if Rails.env.test?

      params = {
          color: 'good',
          channel: 'system_notification',
      }
      notifier = Slack::Notifier.new(ENV.fetch("SLACK_WEBHOOK_URL"), http_options: {open_timeout: DEFAULT_TIMEOUT})
      begin
        notifier.post(attachments: {title: title, text: message, color: param[:color]}, channel: param[:channel])
      rescue => e
        Rails.logger.error("Slack通知に失敗しました。title:#{title}, message:#{message}")
        Rails.logger.error(e)
      end
    end
  end
end
