(defn parse-input [input]
    (peg/match
        ~{
            :main (sequence (group :paths) :eot)
            :paths (sequence :row (any (sequence "\n" :row)))
            :row (some (choice :track :start :end :wall))
            :track (sequence :pos ".")
            :start (sequence (only-tags :pos) "S" (-> :pos :start-pos))
            :end (sequence (only-tags :pos) "E" (-> :pos :end-pos))
            :wall "#"
            :pos (/ (sequence (line) (column)) ,tuple :pos)
            :eot (sequence (backref :start-pos) (backref :end-pos))
        }
        input
    )
)

(defn part1-cheats [i j]
    [
        [ [(+ i 2) j]  2 ]
        [ [(- i 2) j]  2 ]
        [ [i (+ j 2)]  2 ]
        [ [i (- j 2)]  2 ]
    ]
)

(defn part2-cheats [i j]
    (seq [
        Δi :range-to [-20 20]
        Δj :range-to [(+ -20 (math/abs Δi)) (- 20 (math/abs Δi))]
    ]
        [[(+ i Δi) (+ j Δj)] (+ (math/abs Δi) (math/abs Δj))]
    )
)

(defn solve [input cheats good-cheat?]
    (def [tracks start end] (parse-input input))
    (def tracks (tabseq [t :in tracks] t true))
    (defn find-distances [tracks from]
        (def distances @{})
        (put distances from 0)
        (def q @[[from 0]])
        (each [[i j] dist] q
            (each neighbor [[(inc i) j] [(dec i) j] [i (inc j)] [i (dec j)]]
                (when (and (has-key? tracks neighbor) (nil? (get distances neighbor)))
                    (put distances neighbor (inc dist))
                    (array/push q [neighbor (inc dist)])
                )
            )
        )
        distances
    )

    (def distance-from-end (find-distances tracks end))
    (def distance-from-start (find-distances tracks start))

    (def dist-without-cheating (get distance-from-end start))

    (count
        good-cheat?
        (seq [ [[i j] dist-start] :pairs distance-from-start
               [after-cheat cheat-cost] :in (cheats i j)
               :let [cheat-dist-end (get distance-from-end after-cheat)]
               :unless (nil? cheat-dist-end)
               :let [cheat-dist (+ dist-start cheat-cost cheat-dist-end)]
               ]
            (- dist-without-cheating cheat-dist)
        )
    )
)

(def input-file (or (get (dyn *args*) 1) "input.txt"))
(def input (slurp input-file))

(print "Part 1: " (solve input part1-cheats |(>= $ 100)))
(print "Part 2: " (solve input part2-cheats |(>= $ 100)))
