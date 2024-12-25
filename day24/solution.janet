(defn parse-input [s]
    (peg/match
        ~{
            :main (sequence :initialize "\n" :instructions)
            :initialize
                (replace (some (sequence :reg ": " (number :d) "\n")) ,table)
            :instructions
                (replace
                    (group (sequence :instruction (some (sequence "\n" :instruction))))
                    ,(fn [xs] (tabseq [[a op b c] :in xs] c [op a b]))
                )
            :instruction
                (group (sequence :reg " " :op " " :reg " -> " :reg))
            :op (choice :and :xor :or)
            :and (replace (<- "AND") ,(fn [_] band))
            :xor (replace (<- "XOR") ,(fn [_] bxor))
            :or (replace (<- "OR")   ,(fn [_] bor))
            :reg (<- 3)
        }
        s
    )
)

(def input-file (or (get (dyn *args*) 1) "input.txt"))
(def [init exprs] (parse-input (slurp input-file)))

(defn evaluate [init exprs reg]
    (defn evaluate-expr [[op a b]]
        (op (evaluate init exprs a) (evaluate init exprs b))
    )
    (or (get init reg) (evaluate-expr (get exprs reg)))
)

(var part1 0:u)
(loop [[k v] :pairs exprs :when (string/has-prefix? "z" k)]
    (when (= 1 (evaluate init exprs k))
        (def reg-number (parse (drop 1 k)))
        (+= part1 (blshift 1:u reg-number))
    )
)

(print "Part 1: " part1)
