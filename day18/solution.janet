(var input-file "input.txt")
(each arg (drop 1 (dyn *args*))
    (case arg
        "--help" (do
            (print "Usage: janet " (first (dyn *args*)) " [FILE]")
            (os/exit 0)
        )
        (set input-file arg)
    )
)

(def input
    (peg/match
        ~{
            :main (sequence :falling-byte (any (sequence "\n" :falling-byte)))
            :falling-byte (/ (sequence (number :d+) "," (number :d+)) ,tuple)
        }
        (slurp input-file)
    )
)

(defn make-grid [obstacles]
    (def grid @{})
    (each obstacle obstacles
        (put-in grid obstacle true)
    )
    grid
)

(defn shortest-path [origin target grid]
    (defn inbounds [[x y]]
        (def [target-x target-y] target)
        (and (<= 0 x target-x) (<= 0 y target-y))
    )

    (def q @[[origin 0]])
    (def visited (table/clone grid))
    (label result
        (each [[x y] number-of-steps] q
            (when (= [x y] target) (return result number-of-steps))
            (each neighbor [ [(inc x) y] [(dec x) y] [x (inc y)] [x (dec y)] ]
                (when (and (inbounds neighbor) (nil? (get-in visited neighbor)))
                    (put-in visited neighbor true)
                    (array/push q [neighbor (inc number-of-steps)])
                )
            )
        )
    )
)

(defn solve-part1 [falling-bytes from to]
    (->> falling-bytes
        (take 1024)
        (make-grid)
        (shortest-path from to)
    )
)

(print "Part 1: " (solve-part1 input [0 0] [70 70]))
