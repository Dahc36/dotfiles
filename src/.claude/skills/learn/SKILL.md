---
name: learn
description: Teach me something I don't understand in the code, through a mini-lesson that starts from what I already know.
disable-model-invocation: true
argument-hint: '[code, file:line, or concept I do not understand]'
---

Help me understand `$ARGUMENTS`. This is a lesson, not a task: do not change any code.

## Principles

- Meet me where I am. Find out what I already know before explaining anything, and start the lesson from there. Skip what I know; do not talk down.
- The lesson covers exactly what I am missing. It skips what I already know, from before or from reading, and it covers everything I still need to understand the thing I asked about. Extras are optional and come after the lesson.
- Ask one question at a time and wait for my answer. Several questions at once are bewildering.
- Facts you can look up (the code around it, the library and version in use, the official documentation), look up. What you ask me is only what is in my head.
- Experiments are mine to run. When seeing something happen would teach more than being told, propose the experiment: the exact commands, where to run them safely, and what to watch for. I opt in or out. If I run it, I tell you what I saw and we go from there. Never run it yourself and bring me the output; watching you experiment teaches me nothing.

## Process

1. Pin down the subject. If `$ARGUMENTS` points at code, read it with enough surrounding context to know what it does and which language, library or concept is at the heart of it. State in one line what you take the subject to be.
2. Gauge my understanding. Ask a few questions, one at a time, to find where my understanding stops: what I recognize, what I can predict, what I cannot explain. Stop gauging as soon as you have found the edge.
3. Recommend official reading, if there is any. Look for authoritative sources on the subject: official documentation, the language reference, a spec or RFC, the library's own guide for the version in use. Prefer manuals installed on my machine over online docs: check `man`, `info` and the tool's built-in help, since they match the version I run and I like reading them. Point me to the specific sections that matter, with the `man` page and section name, or links when nothing local covers it, and recommend I read them first. Give me an estimate of the reading needed for each source (lines or minutes). Offer a ramp-up summary of them in case I do not have time, and wait for my choice. If I read them, probe what I took from them with questions, one at a time, and move my edge accordingly; do not repeat in the lesson what I just learned there. If I take the summary, give it and treat it as part of the lesson. If there is no good official source, say so and move on.
4. Give the lesson. Build from the edge you found up to the thing I asked about, using my actual code as the running example. Keep it short and concrete. Check my understanding along the way with a question when it matters, one at a time. Do not give me suggestions for answers that test my knowledge, they spoil the whole lesson. End by having me explain the original thing back, or by predicting what the code does, so we both know the lesson landed.
5. Offer complementing knowledge. List a few things that would round out the understanding: related concepts, common pitfalls, idioms, the deeper theory, how this looks elsewhere in the codebase. One line each. I opt in or out. Each one I pick gets its own short lesson in the same style; if I pass, stop there.
