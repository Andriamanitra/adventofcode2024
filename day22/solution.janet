(defn parse-input [s]
    (peg/match
        ~(sequence (number :d+) (any (sequence "\n" (number :d+))))
        s
    )
)

(defn evolve [n]
    (defn prune [n] (band n 0xFFFFFF))
    (defn mul64 [n] (blshift n 6))
    (defn div32 [n] (brshift n 5))
    (defn mul2048 [n] (blshift n 11))
    (defn mix-with [n func] (bxor n (func n)))
    (-> n
        (mix-with mul64)
        prune
        (mix-with div32)
        prune
        (mix-with mul2048)
        prune
    )
)
(def evolve-2000-times (comp ;(seq [:repeat 2000] evolve)))

(defn calculate-prices [n]
    (var secret-number n)
    (seq [:repeat 2001]
        (def price (% secret-number 10))
        (set secret-number (evolve secret-number))
        price
    )
)
(defn by-diff-sequence [xs]
    (def prices @{})
    (def diffs
        (seq [i :range-to [1 2000]]
            (def this (i xs))
            (def prev ((- i 1) xs))
            (- this prev)
        )
    )
    (for i 4 2001
        (def diff-seq (tuple ;(array/slice diffs (- i 4) i)))
        (when (not (has-key? prices diff-seq))
            (def price (i xs))
            (put prices diff-seq price)
        )
    )
    prices
)

(defn solve-part2 [nums]
    (def totals @{})
    (each num nums
        (loop [[k v] :pairs (-> num calculate-prices by-diff-sequence)]
            (when (not (has-key? totals k))
                (put totals k 0)
            )
            (update totals k |(+ $ v))
        )
    )
    (max ;(values totals))
)

(def input-file (or (get (dyn *args*) 1) "input.txt"))
(def nums (parse-input (slurp input-file)))

(print "Part 1: " (sum (map evolve-2000-times nums)))
(print "Part 2: " (solve-part2 nums))
