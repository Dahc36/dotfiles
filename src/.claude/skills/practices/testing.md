---
name: testing
---

# Testing

Tests should document what code is supposed to do, not how.
Tests should be easy to read and understand on their own.

## Tests should not be a liability

Tests should not assert for implementations.
Tests should only need modification when behavior has changed.
Thus, maintaining code should only require changing tests when making intentional changes to how the code is supposed to work.

## Tests should be aware of their limitations

Testing environments are never entirely true reflections of production environments.
Tests should avoid creating false sense of confidence around behavior they can't truly test.
