import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { attempt_id } = await req.json()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Get all answers for this attempt
    const { data: answers, error: answersError } = await supabase
      .from('quiz_answers')
      .select(`
        *,
        quiz_questions (
          correct_answer,
          marks
        )
      `)
      .eq('attempt_id', attempt_id)

    if (answersError) throw answersError

    // Calculate score
    let obtainedMarks = 0
    let correctCount = 0
    let incorrectCount = 0

    for (const answer of answers) {
      const question = answer.quiz_questions
      const isCorrect = answer.user_answer?.trim().toLowerCase() === question.correct_answer.trim().toLowerCase()

      if (isCorrect) {
        obtainedMarks += question.marks
        correctCount++
      } else {
        incorrectCount++
      }

      // Update the answer record with correct is_correct and marks_obtained
      await supabase
        .from('quiz_answers')
        .update({
          is_correct: isCorrect,
          marks_obtained: isCorrect ? question.marks : 0,
        })
        .eq('id', answer.id)
    }

    // Get total marks from quiz attempt
    const { data: attempt } = await supabase
      .from('quiz_attempts')
      .select('total_marks')
      .eq('id', attempt_id)
      .single()

    const totalMarks = attempt.total_marks
    const percentage = (obtainedMarks / totalMarks) * 100
    const isPassed = percentage >= 60

    // Update the attempt with final score
    await supabase
      .from('quiz_attempts')
      .update({
        obtained_marks: obtainedMarks,
        percentage: percentage,
        is_passed: isPassed,
        submitted_at: new Date().toISOString(),
      })
      .eq('id', attempt_id)

    return new Response(
      JSON.stringify({
        obtained_marks: obtainedMarks,
        total_marks: totalMarks,
        percentage: percentage,
        is_passed: isPassed,
        correct_count: correctCount,
        incorrect_count: incorrectCount,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error in quiz-scoring function:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
