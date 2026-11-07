import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { imageUrl, userId, conversationId } = await req.json()

    if (!imageUrl) {
      throw new Error('Image URL is required')
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Get Gemini API key
    const geminiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiKey) {
      throw new Error('Gemini API key not configured')
    }

    // Call Gemini Vision API
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=${geminiKey}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [{
            parts: [
              {
                text: 'Analyze this educational image. Extract any text, identify mathematical equations, diagrams, or educational content. Provide a clear, step-by-step explanation suitable for a student.',
              },
              {
                inline_data: {
                  mime_type: 'image/jpeg',
                  data: imageUrl.split(',')[1] || imageUrl,
                },
              },
            ],
          }],
        }),
      }
    )

    const geminiData = await geminiResponse.json()

    if (geminiData.error) {
      throw new Error(geminiData.error.message)
    }

    const extractedText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || 'No text extracted'
    const aiResponse = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || ''

    // Save to database
    const { data, error } = await supabase
      .from('image_questions')
      .insert({
        user_id: userId,
        conversation_id: conversationId,
        image_url: imageUrl,
        extracted_text: extractedText,
        question_text: extractedText,
        answer_text: aiResponse,
      })
      .select()
      .single()

    if (error) throw error

    return new Response(
      JSON.stringify({
        success: true,
        extractedText,
        aiResponse,
        record: data,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
