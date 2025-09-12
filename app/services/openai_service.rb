require "openai"

class OpenaiService
  def initialize
    @client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
  end

  def chat_with_context(user_message)
    messages = [
      {
        role: "system",
        content: "Você é um assistente financeiro para organizações. Responda a perguntas sobre finanças, metas e saldos de forma clara e útil. Responda apenas sobre finanças. Não responda a perguntas fora deste contexto."
      },
      {
        role: "user",
        content: user_message
      }
    ]

    response = @client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: messages,
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content")
  rescue => e
    "Ocorreu um erro ao conectar com a IA: #{e.message}"
  end
end