---
name: course-next
description: Teach the next chapter of the course in course.md, one chapter per call, through reading, a playground step I build and a teach-back I write.
disable-model-invocation: true
---

Teach the next chapter of the course whose state is `course.md`, at the root of the opened project.
If there is none, say so and stop.
One chapter per call.

## Principles

- Ask one question at a time and wait for my answer. Several questions at once are bewildering.
- Facts you can look up (the source section, the playground's code, the library and version in use), look up. What you ask me is only what is in my head.
- Do not give me suggestions for answers to questions that test my knowledge, they spoil the whole lesson.
- Experiments are mine to run: watching you experiment teaches me nothing.

## Process

1. Read `course.md` and pick the first chapter marked `revisit`, else the first `pending`.
   1. State it in one line.
   2. Mark it `in progress`.
2. Revisit chapter: reopen with my weak teach-back and ask what I would change, then go straight to the playground step.
   NOTE: no re-reading unless I ask.
3. Reading: point at the chapter's source section with its size (lines or minutes). I read it and come back.
   1. Probe what I took from it with questions, one at a time.
   2. Skip what I have shown.
4. Playground step: I build it, you navigate.
   1. Say what the step should make the toy do.
   2. I write it, run it and report what I saw.
      NOTE: never write the toy's code or run it, I should do that.
5. Drill, when the chapter wants one: write a test, I make it pass, review my code.
   NOTE: the only place you write into the playground.
6. Teach-back: I write the concept in my own words into `course.md`, under `## Teach-backs`.
   1. Ask one follow-up question the explanation should answer.
   2. Mark the chapter `taught back` or `revisit`, with the correction under the teach-back.
7. Stop, printing the next chapter's name, or that the course is done.

## Teach-back

Accepted when all hold:

- In my words, not the source's phrasing.
- Says what the concept does and what I saw in the playground that shows it.
- Survives the follow-up question.

A revisit never overwrites the original teach-back: the correction and the new attempt go under it.
