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
    (def q @[origin])
    (def visited (thaw grid))

    (defn inbounds [[x y]]
        (def [target-x target-y] target)
        (and (<= 0 x target-x) (<= 0 y target-y))
    )

    (defn backtrack-from [pos]
        (var curr pos)
        (def path @[])
        (while (not= origin curr)
            (array/push path curr)
            (set curr (get-in visited curr))
        )
        path
    )

    (label result
        (each [x y] q
            (when (= [x y] target)
                (return result (backtrack-from target))
            )
            (each neighbor [ [(inc x) y] [(dec x) y] [x (inc y)] [x (dec y)] ]
                (when (and (inbounds neighbor) (nil? (get-in visited neighbor)))
                    (put-in visited neighbor [x y])
                    (array/push q neighbor)
                )
            )
        )
        (return result nil)
    )
)

(defn solve-part1 [falling-bytes from to]
    (->> falling-bytes
        (take 1024)
        (make-grid)
        (shortest-path from to)
        (length)
    )
)

(defn solve-part2 [falling-bytes from to]
    (def grid @{})
    (var i 0)
    (var path (shortest-path from to grid))
    (label result
        (loop [obstacle :in falling-bytes]
            (put-in grid obstacle true)
            (when (has-value? path obstacle)
                (set path (shortest-path from to grid))
                (when (nil? path)
                    (return result (string/join (map string obstacle) ","))
                )
            )
            (++ i)
        )
    )
)

(print "Part 1: " (solve-part1 input [0 0] [70 70]))
(print "Part 2: " (solve-part2 input [0 0] [70 70]))
