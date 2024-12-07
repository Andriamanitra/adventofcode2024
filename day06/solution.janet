(def OBSTACLE (chr "#"))
(def EMPTY (chr "."))
(def GUARD (chr "^"))

(def input
    (->> (slurp "input.txt")
        (string/trim)
        (string/split "\n")
        (map |(array ;(string/bytes $)))
    )
)

(defn find-start [input]
    (first
        (seq [[i row] :pairs input
              [j byte] :pairs row
              :when (= byte GUARD)]
            [i j]
        )
    )
)

(def guard (find-start input))
(def G @{
    :position guard
    :direction [-1 0]
    :walk
        (fn [self grid]
            (var [i j] (self :position))
            (var [Δi Δj] (self :direction))
            (var found-loop? false)
            (def visits @{})
            (def max-i (dec (length grid)))
            (def max-j (dec (length (0 grid))))

            (while (and (<= 0 i max-i) (<= 0 j max-j) (not found-loop?))
                (if (= OBSTACLE (j (i grid)))
                    (do
                        (-= i Δi)
                        (-= j Δj)
                        (let [old-Δi Δi old-Δj Δj]
                            (set Δi old-Δj)
                            (set Δj (- old-Δi))
                        )
                    )
                    (do
                        (when (not (has-key? visits [i j]))
                            (put visits [i j] 0)
                        )
                        (update visits [i j] inc)
                        (when (> (get visits [i j]) 4)
                            (set found-loop? true)
                        )
                        (+= i Δi)
                        (+= j Δj)
                    )
                )
            )

            [found-loop? visits]
        )
})

(def [_ path] (:walk G input))
(def count-of-obstacles-that-cause-loop
    (count
        (fn [[i j]]
            (put (i input) j OBSTACLE)
            (def [loop? _] (:walk G input))
            (put (i input) j EMPTY)
            loop?
        )
        (keys path)
    )
)

(print "Part 1: " (length path))
(print "Part 2: " count-of-obstacles-that-cause-loop)
