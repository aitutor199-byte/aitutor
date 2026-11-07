import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { subject, education_level, chapter, difficulty, question_count, question_type } = await req.json()

    const geminiApiKey = Deno.env.get('GEMINI_API_KEY')
    if (!geminiApiKey) {
      throw new Error('GEMINI_API_KEY is not configured')
    }

    const prompt = buildPrompt(subject, education_level, chapter, difficulty, question_count, question_type)

    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${geminiApiKey}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [
            {
              role: 'user',
              parts: [{ text: prompt }]
            }
          ],
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 4096,
          },
        }),
      }
    )

    if (!geminiResponse.ok) {
      const errorText = await geminiResponse.text()
      throw new Error(`Gemini API error: ${geminiResponse.status} - ${errorText}`)
    }

    const geminiData = await geminiResponse.json()
    const generatedText = geminiData.candidates[0]?.content?.parts[0]?.text || ''

    // Parse the generated questions
    const questions = parseQuestions(generatedText, question_type)

    return new Response(
      JSON.stringify({ questions }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error in ai-question-generator function:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

function buildPrompt(subject: string, educationLevel: string, chapter: string, difficulty: string, questionCount: number, questionType: string): string {
  return `Generate ${questionCount} ${difficulty} ${questionType.replace('_', ' ')} questions for ${subject} - ${chapter} at ${educationLevel} level.

Requirements:
1. Each question must be clear and age-appropriate for ${educationLevel} students
2. Difficulty level: ${difficulty}
3. Question type: ${questionType.replace('_', ' ')}
4. For multiple choice: provide 4 options (A, B, C, D) with one correct answer
5. For true/false: provide statements that can be evaluated
6. For fill in the blank: provide sentences with one blank
7. For short answer: provide questions that can be answered in 1-2 sentences

Format each question as a JSON object with this structure:
{
  "question_text": "The question text",
  "options": {"A": "Option A", "B": "Option B", "C": "Option C", "D": "Option D"},
  "correct_answer": "A",
  "explanation": "Brief explanation of why this is correct",
  "marks": 1
}

Return the response as a JSON array of question objects. Do not include any additional text outside the JSON array.`
}

function parseQuestions(text: string, questionType: string): any[] {
  try {
    // Try to extract JSON array from the response
    const jsonMatch = text.match(/\[[\s\S]*\]/)
    if (jsonMatch) {
      const questions = JSON.parse(jsonMatch[0])
      return questions.map((q: any) => ({
        question_text: q.question_text,
        question_type: questionType,
        options: q.options || null,
        correct_answer: q.correct_answer.toString(),
        explanation: q.explanation || '',
        marks: q.marks || 1,
        order_index: 0,
      }))
    }
    return []
  } catch (e) {
    console.error('Error parsing questions:', e)
    return []
  }
}
