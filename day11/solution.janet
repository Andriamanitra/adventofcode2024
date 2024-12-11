(def stones (peg/match ~(split " " (number :d+)) (slurp "input.txt")))

(def memo @{})
(defmacro defn-memoized [name args & body]
    ~(defn ,name ,args
        (if (has-key? memo ,args)
            (get memo ,args)
            (do
                (def result (do ,;body))
                (put memo ,args result)
                result
            )
        )
    )
)

(defn-memoized blink [stone n]
    (def s (string stone))
    (cond
        (zero? n)
            1
        (zero? stone)
            (blink 1 (dec n))
        (even? (length s)) (do
            (def half (div (length s) 2))
            (+ (blink (parse (take half s)) (dec n))
               (blink (parse (drop half s)) (dec n)))
        ) :else
            (blink (* 2024 stone) (dec n))
    )
)

(each [part n] [[1 25] [2 75]]
    (printf "Part %d: %d" part (sum (map |(blink $ n) stones)))
)
