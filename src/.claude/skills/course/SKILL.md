---
name: course
description: Create a course on a subject, with a syllabus from an official source, a playground grown one concept at a time, and course.md as its state.
argument-hint: '[the subject, as I phrase it]'
disable-model-invocation: true
---

Create a course on `$ARGUMENTS`; when empty, ask me what the subject is.
This creates the course and stops.
No chapter is taught here: `/course-next` does that.

A course is for competence in an area, not just the argument that raised the question.
It always gets created, however small the gap turns out: the playground is worth having on its own.

## Principles

- Meet me where I am. Find out what I already know before writing anything, and build the syllabus from there.
- Ask one question at a time and wait for my answer. Several questions at once are bewildering.
- Facts you can look up (the code around it, the library and version in use, the official documentation), look up. What you ask me is only what is in my head.
- Decisions are mine: the spine, the playground's target and the course's name are proposed with a recommendation and chosen by me.

## The course folder

A course lives at `~/code/courses/<name>/`.
The folder is the project: `course.md` at its root is the state file, and the playground grows next to it.

### course.md

Read every file printed by `aiprinciples prose` before writing it and follow them.
It holds three parts, in the order a resuming session reads them:

1. The subject and the chain of missing concepts that justified the course, one line each.
2. `## Syllabus`: the chapters in order, each with:
   - its source: the section of the official tutorial, book or exercise set, or `Claude-written`
   - its playground step: what the toy does by the end of the chapter
   - its status: `pending`, `in progress`, `taught back` or `revisit`
3. `## Teach-backs`: one per chapter, written by `/course-next`; empty at creation.

### The playground

A toy project grown one concept per chapter, towards a target that needs every link of the chain.
Setting it up is chapter one when the chain includes the tooling, the build or the project layout.
Otherwise it is scaffolded at creation, so chapter one starts from running code.
When the code that triggered the course is easy to extract, the scaffold is a stripped copy of it.

## Process

1. Gauge my understanding. Ask questions, one at a time, until the chain is found: the concept I asked about, the prerequisite it needs, the prerequisite that one needs, down to what I already know.
2. Pick the spine: the source whose chapters the syllabus follows.
   1. Look for sources covering the chain, in order:
      - manuals on my machine: `man`, `info`, the tool's built-in help
      - the official tutorial or book for the version I run
      - an established exercise set, such as rustlings, exercism or the Go tour
   2. Propose one spine with the chapters it would give and the reading per chapter (lines or minutes), naming the runner-up in one line. I pick.
      NOTE: a mixed spine is allowed when the chain spans sources; each chapter cites exactly one source.
   3. No source covers the chain: say so and write the chapters yourself, each marked `Claude-written`.
3. Propose the playground's target: a small program that needs every link of the chain.
   1. Name the triggering code as one candidate when there is one.
   2. Name a better showcase when you see one. I pick.
4. Propose a directory name that fits what the syllabus teaches. I confirm or rename.
   1. The name already exists under `~/code/courses/`: show that course's subject and next chapter, then ask one question: continue it with `/course-next`, or rename this one.
5. Create the folder and write `course.md`.
6. Scaffold the playground, unless setting it up is chapter one.
7. End by printing the exact commands to run next: `cd ~/code/courses/<name>`, then `/course-next`.
