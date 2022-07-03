#lang sicp

(define x 2)
; local x = 2

; local function f(x)
;   return x + 2
; end
(define (f x)
  (+ x 2))

(f 2)
