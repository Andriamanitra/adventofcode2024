(def input 
    (->> (slurp "input.txt")
        (peg/match
            ~{
                :main (sequence :slot-machine (any (sequence "\n" :slot-machine)))
                :slot-machine (group (sequence :button :button :prize))
                :button (sequence "Button " :a ": X+" :int ", Y+" :int "\n")
                :prize (sequence "Prize: X=" :int ", Y=" :int "\n")
                :int (number :d+)
            }
        )
    )
)

(defn do-the-stupid-math-thing [ax ay bx by x y]
    # not sure why but it seems there's always only one answer
    # anyways here is the math
    # A*ax + B*bx = x    | * by
    # => A*ax*by + B*bx*by = x*by
    # A*ay + B*by = y    | * bx
    # => A*ay*bx + B*by*bx = y*bx
    # subtract the second equation from the first one
    # => A*ax*by + B*bx*by - A*ay*bx - B*by*bx = x*by - y*bx
    # => A*ax*by - A*ay*bx = x*by - y*bx
    # => A * (ax*by - ay*bx) = x*by - y*bx
    # => A = (x*by - y*bx) / (ax*by - ay*bx)
    (def A
        (div
            (- (* x by) (* y bx))
            (- (* ax by) (* ay bx))
        )
    )
    (def B (div (- x (* A ax)) bx))
    (when (and (zero? (- x (* A ax) (* B bx))) (zero? (- y (* A ay) (* B by))))
        (+ (* 3 A) B)
    )
)

(var presses @{:part1 0 :part2 0})
(each [ax ay bx by x y] input
    (each [k extra] [[:part1 0] [:part2 10_000_000_000_000]]
        (if-let [n (do-the-stupid-math-thing ax ay bx by (+ x extra) (+ y extra))]
            (update presses k |(+ $ n))
        )
    )
)

(printf "Part 1: %d" (presses :part1))
(printf "Part 2: %d" (presses :part2))
