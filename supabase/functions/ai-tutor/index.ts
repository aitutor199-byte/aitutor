import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { message, history, education_level, language, subject } = await req.json()

    // Get Gemini API key from environment variables
    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY is not configured')
    }

    // Build the system prompt based on education level and language
    const systemPrompt = buildSystemPrompt(education_level, language, subject)

    // Prepare messages for Gemini
    const messages = [
      { role: 'user', parts: [{ text: systemPrompt }] },
      ...history.map((msg: any) => ({
        role: msg.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: msg.content }],
      })),
      { role: 'user', parts: [{ text: message }] },
    ]

    // Call Gemini API
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: messages,
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
          },
        }),
      }
    )

    if (!geminiResponse.ok) {
      const errorText = await geminiResponse.text()
      throw new Error(`Gemini API error: ${geminiResponse.status} - ${errorText}`)
    }

    const geminiData = await geminiResponse.json()
    const response = geminiData.candidates[0]?.content?.parts[0]?.text || 'I apologize, but I could not generate a response.'

    return new Response(
      JSON.stringify({ response }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error in ai-tutor function:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

function buildSystemPrompt(educationLevel: string, language: string, subject?: string, lessonContext?: string, lessonTitle?: string, systemPrompt?: string): string {
  let prompt = `You are a patient, knowledgeable, and professional AI teacher for ${educationLevel} students. `

  // Language instruction
  if (language === 'Urdu') {
    prompt += `You must respond in Urdu language using Urdu script. `
  } else if (language === 'Pashto') {
    prompt += `You must respond in Pashto language using Pashto script. `
  } else {
    prompt += `You must respond in English language. `
  }

  // Add lesson context if provided
  if (lessonContext || lessonTitle) {
    prompt += `\n\nContext: The student is asking about the lesson "${lessonTitle || lessonContext}". `
  }

  // Add custom system prompt if provided
  if (systemPrompt) {
    prompt += systemPrompt
  }

  // Teaching approach
  prompt += `
Your teaching approach:
- Explain concepts clearly and simply
- Adapt explanations to the student's education level
- Use practical examples relevant to ${educationLevel}
- Break complex topics into smaller steps
- Ask checking questions to ensure understanding
- Correct mistakes politely and encouragingly
- Encourage independent thinking
- Avoid unnecessary complexity

${subject ? `Focus on ${subject} concepts and examples.` : ''}

If the question is mathematical:
- Explain the formula or concept
- Solve step by step
- Show each calculation
- Explain the reasoning
- Provide the final answer clearly
- Give another example when helpful

Always maintain a friendly, supportive, and educational tone. Be thorough but concise.`
  
  return prompt
}
