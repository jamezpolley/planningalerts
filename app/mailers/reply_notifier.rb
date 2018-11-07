# frozen_string_literal: true

class ReplyNotifier < ActionMailer::Base
  include ActionMailerThemer
  helper :comments

  def notify_comment_author(reply)
    @reply = reply
    @comment = @reply.comment

    themed_mail(theme: "default",
                to: reply.comment.email,
                sender: email_from("default"),
                from: email_from("default"),
                subject: "#{reply.councillor.prefixed_name.titleize} replied to your message")
  end
end
