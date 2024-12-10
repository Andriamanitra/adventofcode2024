(defn parse-input [str]
    (peg/match ~(some (sequence (group (some (number :d))) "\n")) str)
)

(def input (parse-input (slurp "input.txt")))
(def width (length (0 input)))
(def height (length input))

(defn reachable-nines [r c]
    (var nines @{})
    (def q @[[0 r c]])
    (each [h r c] q
        (when (= h (get-in input [r c]))
            (cond
                (= 9 h) (update nines [r c] |(if $ (inc $) 1))
                :else (do
                    (array/push q [(inc h) (dec r) c])
                    (array/push q [(inc h) (inc r) c])
                    (array/push q [(inc h) r (dec c)])
                    (array/push q [(inc h) r (inc c)])
                )
            )
        )
    )
    nines
)

(var score-part-1 0)
(var score-part-2 0)
(loop [r :range [0 height] c :range [0 width] :when (zero? (get-in input [r c]))]
    (def nines (reachable-nines r c))
    (+= score-part-1 (length nines))
    (+= score-part-2 (sum (values nines)))
)

(print "Part 1: " score-part-1)
(print "Part 2: " score-part-2)
