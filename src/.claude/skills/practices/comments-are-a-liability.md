---
name: comments-are-a-liability
---

# Comments are a liability

Comments have to be maintained, just like code.
But comments have no static checks, tests or working code to test that they remain correct.
Code can change and comments can be left stale, creating confusion and noise.

## Comments are part of the code

Comments should be short, containing only the necessary information to keep reading the code.
Comments should be easy to read along with the code.
Comments should be read as part of the code, not a separate knowledge base.

## Comments should complement code's readability

Comments should explain things that are impossible to reflect in code.
If anything can be expressed through code, it should be expressed only through code.
Only when something cannot reasonably be expressed as code, does a comment justify its existence.

## Comments should not be a crutch for complex code

If the code is not clear enough, refactoring for readability should be preferred over comments.
