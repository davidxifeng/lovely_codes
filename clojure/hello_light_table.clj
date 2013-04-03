(print 'hello')

(+ 2 3)
(* 2 (+ 2 3))

(= 2 2)

(defn add5 [a]
  (+ a 5))

(add5 2) 

(* 2 (add5 5))
(+ 2 3 )

(dec 2)
(inc 2)

(defn test-cond
  [x]
  (cond (= x 0) 0
        (< x 0) 'love'
        (> x 0) 'david'))
(test-cond 2)
(test-cond 0)
(test-cond -2)

(defn ack
  [x y]
  (cond (= y 0) 0 
        (= x 0) (* 2 y)
        (= y 1) 2
        :else (ack (- x 1 ) (ack x (- y 1)))))

(ack 3 3)
(print (ack 3 3))
