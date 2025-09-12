require Rails.root.join('app/services/openai_service')

class ChatController < ApplicationController
  before_action :authenticate_request!

  def chat
    user_message = params[:message]

    if user_message.blank?
      render json: { error: "A mensagem não pode ser vazia." }, status: :unprocessable_entity
      return
    end

    openai_service = OpenaiService.new
    ai_response = openai_service.chat_with_context(user_message)

    render json: { response: ai_response }, status: :ok
  end
end