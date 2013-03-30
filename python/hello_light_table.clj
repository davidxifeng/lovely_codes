(print 'hello')

(+ 2 3)
(* 2 (+ 2 3))


(= 2 2)

(def test 
  (fn [a]
    (+ a 3)))
(test 3)

(defn add5 [a]
  (+ a 5))

(add5 2) 
(add5 (test 3))

(add5 (test 4))

(* 2 (add5 5))
(+ 2 3 )
