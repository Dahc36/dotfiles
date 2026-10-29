---
name: contracts-break-loudly
tags: [code]
---

# Contracts break loudly

A caller sees a callee through its contract.
Everything past that is mechanism, and mechanism changes without the caller noticing.

## A contract is what the checker enforces

The contract is the signature: what the checker holds the callee and every caller to.
Breaking it fails every caller's check, so it cannot happen quietly.
A body, its tests and its documentation all change quietly; they describe today's mechanism, however stable it looks.

## A caller relies only on the contract

Reading the callee to learn what it does today does not turn that into a promise.
Code that leans on it is coupled to it, and nothing on either side shows the coupling.

## Only the contract makes code dead

A guard is dead when the signature rules the case out, not when the current body happens never to produce it.
What the signature cannot express stays possible however the body is written.
Removing such a guard trades a line for a failure that appears when the callee changes.

## The same holds for tests

A scenario the signature allows is worth a test even when today's body cannot produce it.
