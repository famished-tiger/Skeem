;; File: base_tests.scm 
;; Version: 0.0.2

;; Section 6.2.6 Numerical operations
;; Numerical type predicates - R7RS cases
(test-assert (complex? 3))
(test-assert (real? 3))
(test-assert (rational? 6/10))
(test-assert (rational? 6/3))
(test-assert (integer? 3.0))
(test-assert (integer? 8/4))

;; Numerical type predicates - additional cases
(test-assert (integer? 1901))
(test-assert (rational? 1901))
(test-assert (real? 1901))
(test-assert (complex? 1901))
(test-assert (number? 1901))
(test-assert (integer? -3.0))
(test-assert (rational? -3.0))
(test-assert (real? -3.0))
(test-assert (complex? -3.0))
(test-assert (number? -3.0))
;; TODO
(test-assert (not (integer? -2/3)))
(test-assert (rational? -2/3))
(test-assert (real? -2/3))
(test-assert (complex? -2/3))
(test-assert (number? -2/3))
(test-assert (not (integer? -2.345)))
(test-assert (real? -2.345))
(test-assert (complex? -2.345))
(test-assert (number? -2.345))
(test-assert (number? 42))
(test-assert (not (number? #t)))
(test-assert (real? 3.1416))
(test-assert (real? 22/7))
(test-assert (real? 42))
(test-assert (rational? 22/7))
(test-assert (not (integer? 22/7)))
(test-assert (integer? 42))
(test-assert (not (integer? 'a)))
(test-assert (not (rational? '(a b c))))
(test-assert (not (real? "3")))
(test-assert (not (complex? '#(1 2))))

(test-assert (exact? 3.0)) ; Incompatibility with R7RS!
(test-assert (inexact? 3.))
(test-assert (exact? 1))
(test-assert (exact? -15/16))
(test-assert (not (exact? 2.01)))
(test-assert (not (inexact? -123)))
(test-assert (exact-integer? 32))
(test-assert (exact-integer? 32.0)) ; Incompatibility with R7RS!
(test-assert (not (exact-integer? 32/5)))

;; Comparison operators
(test-assert (= 3 3))
(test-assert (= 3 3.0))
(test-assert (not (= 3 5)))
(test-assert (= 0.0 0))
(test-assert (= 0 0.0))
(test-assert (= 0.0 0.0))
(test-assert (= -1 (- 0 1)))
(test-assert (= 1.0 1))
(test-assert (= 3 3 3 3))
(test-assert (not (= 3 2 3)))
(test-assert (not (= 3 3 5 3)))

(test-assert (< 3 5))
(test-assert (not (< 8 6)))
(test-assert (not (< 3 -5)))
(test-assert (not (< 3 3)))
(test-assert (not (< 3 3.0)))
(test-assert (< 0 3 4 6 7))
(test-assert (< -5 -4 -2 0 4 5))
(test-assert (not (< 0 3 4 4 6)))
(test-assert (< 0 1 2 3 4 5 6 7 8 9 10.0))
(test-assert (not (< 2 18/9)))

(test-assert (not (> 12 133)))
(test-assert (> 120 11))
(test-assert (> 2 1 0))
(test-assert (> 2 1.9))
(test-assert (> 8 7 6 5 4))
(test-assert (> 2 1 0.5 0.3 0.2 0.1 0))

(test-assert (<= 3 5))
(test-assert (<= 3 3))
(test-assert (<= 3.0 3))
(test-assert (<= 3 3.0))
(test-assert (not (<= 3 -5)))
(test-assert (<= 0 3 4 6 7))
(test-assert (<= 0 3 4 4 7))
(test-assert (not (<= 1 3 3 2 5)))

(test-assert (>= 2 1))
(test-assert (>= 2 2))
(test-assert (>= 2 2.0))
(test-assert (>= 4 3 2 1 0))
(test-assert (>= 4 3 3 2 0))
(test-assert (not (>= 4 3 1 2 0)))
(test-assert (>= 2 1.9 1.8 1.8 1.8 1 0))
(test-assert (not (>= -5 -4 -2 0 4 5)))

;; More numerical predicates
(test-assert (zero? 0))
(test-assert (zero? 0.0))
(test-assert (zero? (- 3.0 3.0)))
(test-assert (zero? (- 1/2 3/6)))
(test-assert (not (zero? 1)))
(test-assert (not (zero? -1)))

(test-assert (not (positive? 0)))
(test-assert (not (positive? 0.0)))
(test-assert (positive? 1))
(test-assert (positive? 1.0))
(test-assert (not (positive? -1)))
(test-assert (not (positive? -1.0)))
(test-assert (positive? 1.8e-15))
(test-assert (not (positive? -2/3)))

(test-assert (not (negative? 0)))
(test-assert (not (negative? 0.0)))
(test-assert (not (negative? 1)))
(test-assert (not (negative? 1.0)))
(test-assert (negative? -1))
(test-assert (negative? -1.0))
(test-assert (negative? -0.0121))
(test-assert (not (negative? 15/16)))

(test-assert (not (odd? 0)))
(test-assert (odd? 1))
(test-assert (odd? -1))
(test-assert (not(odd? 2.0)))
(test-assert (odd? -120762398465))
(test-assert (not (odd? 42)))

(test-assert (even? 0))
(test-assert (not (even? 1)))
(test-assert (even? -2))
(test-assert (even? 2.0))
(test-assert (not (even? -120762398465)))
(test-assert (even? 42))

;; max - min procedures
(test-assert (= 3 (max 1 2 3)))
(test-assert (= 4 (max 4 2 3)))
(test-assert (= 4.2 (max 4.2 2 3)))
(test-assert (= 4.2 (max 4.2 2.3 3)))
(test-assert (= 4.2 (max 4.2)))
(test-assert (= 4 (max 4 -7 2 0 -6)))
(test-assert (= 6/7 (max 1/2 3/4 4/5 5/6 6/7)))
(test-assert (= 2.0 (max 1.5 1.3 -0.3 0.4 2.0 1.8)))
(test-assert (= 5.0 (max 5 2.0)))
(test-assert (= -2.0 (max -5 -2.0)))
(test-assert (= 9 (let (
  (ls '(7 3 5 2 9 8)))
  (apply max ls))))

(test-assert (= 1 (min 1 2 3)))
(test-assert (= 2 (min 4 2 3)))
(test-assert (= 2 (min 4.2 2 3)))
(test-assert (= 2.3 (min 4.2 2.3 3)))
(test-assert (= 4.2 (min 4.2)))
(test-assert (= -7 (min 4 -7 2 0 -6)))
(test-assert (= 1/2 (min 1/2 3/4 4/5 5/6 6/7)))
(test-assert (= -0.3 (min 1.5 1.3 -0.3 0.4 2.0 1.8)))
(test-assert (= 2.0 (min 5 2.0)))
(test-assert (= -5.0 (min -5 -2.0)))
(test-assert (= 2 (let (
  (ls '(7 3 5 2 9 8)))
  (apply min ls))))

;; Arithmetic operations
(test-assert (= 0 (+)))
(test-assert (= 3 (+ 1 2)))
(test-assert (= 7/6 (+ 1/2 2/3)))
(test-assert (= 12 (+ 3 4 5)))
(test-assert (= 12.7 (+ 2.7 10)))
(test-assert (= 486 (+ 137 349)))
(test-assert (= 75 (+ 21 35 12 7)))
(test-assert (= 15 (apply + '(1 2 3 4 5))))

(test-assert (= -3  (- 3)))
(test-assert (= 2/3  (- -2/3)))
(test-assert (= -1/10 (- 7/5 3/2)))
(test-assert (= 1.0 (- 4 3.0)))
(test-assert (= -2  (- 4 3 2 1)))
(test-assert (= 666 (- 1000 334)))

(test-assert (= 1  (*)))
(test-assert (= 7/2 (* 7/2)))
(test-assert (= 495  (* 5 99)))
(test-assert (= 1200 (* 25 4 12)))

(test-assert (= 2 (/ 1/2)))
(test-assert (= -1/17 (/ -17)))
(test-assert (= 2 (/ 10 5)))
(test-assert (= 3/4 (/ 3 4)))
(test-assert (= 0.75 (/ 3.0 4)))
(test-assert (= 3/20 (/ 3 4 5)))
(test-assert (= 1/2 (/ 60 5 4 3 2)))

(test-assert (= 19 (+ (* 3 5) (- 10 6))))
(test-assert (= 57 (+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))))

(test-assert (= 7 (abs -7)))
(test-assert (= 2.1 (abs -2.1)))
(test-assert (= 3/2 (abs (- 3/2))))
(test-assert (= 1 (abs -1)))
(test-assert (= 0.1 (abs -0.1)))
(test-assert (= 0 (abs 0)))
(test-assert (= 1/100 (abs 1/100)))
(test-assert (= 1 (abs 1)))

(test-equal (cons 2 1) (floor/ 5 2))
(test-equal (cons -3 1) (floor/ -5 2))
(test-equal (cons -3 -1) (floor/ 5 -2))
(test-equal (cons 2 -1) (floor/ -5 -2))
