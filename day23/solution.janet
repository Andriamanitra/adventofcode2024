(defn parse-input [s]
    (peg/match
        ~{
            :main (sequence :connection (any (sequence "\n" :connection)))
            :connection (/ (sequence :computer "-" :computer) ,tuple)
            :computer (<- (repeat 2 (range "az")))
        }
        s
    )
)

(def input-file (or (get (dyn *args*) 1) "input.txt"))
(def input (parse-input (slurp input-file)))

(def connections @{})
(each [a b] input
    (put-in connections [a b] true)
    (put-in connections [b a] true))

(def ks (keys connections))
(def n (length ks))
(var trio-count 0)

(loop [i :range [0 n]
       j :range [(inc i) n]
       k :range [(inc j) n]]
    (def ix (i ks))
    (def jx (j ks))
    (def kx (k ks))
    (when (and
            (find |(string/has-prefix? "t" $) [ix jx kx])
            (get-in connections [ix jx])
            (get-in connections [ix kx])
            (get-in connections [jx kx]))
        (++ trio-count)))

(print "Part 1: " trio-count)
