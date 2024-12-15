(use dbg)

(def input (slurp (or (get (dyn :args) 1) "input.txt")))

(def [grid directions]
    (peg/match
        ~{
            :main (sequence :grid "\n\n" :directions)
            :grid (group (sequence :row (any (sequence "\n" :row))))
            :directions (group (some (choice :up :down :left :right "\n")))
            :row (group (some (choice :wall :robot :box :empty)))
            :wall (/ "#" :wall)
            :robot (/ "@" :robot)
            :box (/ "O" :box)
            :empty (/ "." :empty)
            :up (/ "^" [-1 0])
            :down (/ "v" [1 0])
            :left (/ "<" [0 -1])
            :right (/ ">" [0 1])
        }
        input
    )
)

(defn widen [grid]
    (seq [row :in grid]
        (catseq [thing :in row]
            (cond thing
                :empty [:empty :empty]
                :wall [:wall :wall]
                :robot [:robot :empty]
                :box [:boxL :boxR]
            )
        )
    )
)


(defn find-next-empty [grid [r c] [dr dc]]
    (var r r)
    (var c c)
    (while (= :box (get-in grid [r c]))
        (+= r dr)
        (+= c dc)
    )
    (when (= :empty (get-in grid [r c]))
        [r c]
    )
)

(defn solve-part-1 [grid [robot-r robot-c]]
    (var r robot-r)
    (var c robot-c)
    (each [dr dc] directions
        (def npos [(+ r dr) (+ c dc)])
        (case (get-in grid npos)
            :empty (do
                (+= r dr)
                (+= c dc)
            )
            :box (do
                (def next-empty (find-next-empty grid npos [dr dc]))
                (when next-empty
                    (put-in grid npos :empty)
                    (put-in grid next-empty :box)
                    (+= r dr)
                    (+= c dc)
                )
            )
            :wall ()
            (error "ran into unknown object in the grid")
        )
    )
    
    (def box-gps-coords
        (seq [[r row] :pairs grid
              [c thing] :pairs row
              :when (= thing :box)
             ]
            (+ (* 100 r) c)
        )
    )
    
    (sum box-gps-coords)
    
)

(defn solve-part-2 [grid [robot-r robot-c]]
    (var r robot-r)
    (var c robot-c)
    :TODO
)

(def [robot-r robot-c]
    (first
        (seq [[r row] :pairs grid
              [c thing] :pairs row
              :when (= thing :robot)
             ]
            [r c]
        )
    )
)

(put-in grid [robot-r robot-c] :empty)
(def grid2 (widen grid))

(print "Part 1: " (solve-part-1 grid [robot-r robot-c]))
(print "Part 2: " (solve-part-2 grid2 [(* 2 robot-r) (* 2 robot-c)]))
