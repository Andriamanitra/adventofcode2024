(defn parse-input [filename]
    (def day-7-peg 
        ~{
            :main (sequence :line (some (sequence "\n" :line)))
            :int (number :d+)
            :line (replace :line-content ,tuple)
            :line-content (sequence :int ":" (group (some (sequence " " :int))))
        }
    )
    (peg/match day-7-peg (slurp filename))
)

(defn can-equal? [[start & nums] ops target]
    (defn recur [i acc]
        (cond
            (> acc target) false
            (= i (length nums)) (= target acc)
            :else (any? (seq [op :in ops] (recur (inc i) (op acc (i nums)))))
        )
    )
    (recur 0 start)
)

(def input (parse-input "input.txt"))

(def ‖ (comp parse string))

(var part-1 0)
(var part-2 0)

(loop [[target nums] :in input]
    (cond
        (can-equal? nums [* +] target) (+= part-1 target)
        (can-equal? nums [* + ‖] target) (+= part-2 target)
    )
)
(+= part-2 part-1)

(print "Part 1: " part-1)
(print "Part 2: " part-2)
