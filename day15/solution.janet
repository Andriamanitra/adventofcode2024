(defn widen [grid]
    (seq [row :in grid]
        (catseq [thing :in row]
            (case thing
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

(defn solve-part-1 [grid directions [robot-r robot-c]]
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

(defn solve-part-2 [grid directions [robot-r robot-c]]
    (var r robot-r)
    (var c robot-c)

    (defn boxes-to-push [boxes [dr dc]]
        (var can-push? true)
        (loop [[br bc] :in boxes :while can-push?]
            (def [nr nc] [(+ br dr) (+ bc dc)])
            (case (get-in grid [nr nc])
                :wall (set can-push? false)
                :empty ()
                :boxL (do
                    (array/push boxes [nr nc])
                    (when (= dc 0)
                        (array/push boxes [nr (inc nc)])
                    )
                )
                :boxR (do
                    (array/push boxes [nr nc])
                    (when (= dc 0)
                        (array/push boxes [nr (dec nc)])
                    )
                )
                (error "unknown object in the grid")
            )
        )
        (when can-push?
            boxes
        )
    )

    (defn push-boxes [boxes [dr dc]]
        (def new-boxes
            (seq [[br bc] :in boxes]
                [[(+ br dr) (+ bc dc)] (get-in grid [br bc])]
            )
        )
        (each box-pos boxes
            (put-in grid box-pos :empty)
        )
        (each [box-pos box-type] new-boxes
            (put-in grid box-pos box-type)
        )
    )

    (each [dr dc] directions
        (def npos [(+ r dr) (+ c dc)])
        (case (get-in grid npos)
            :empty (do
                (+= r dr)
                (+= c dc)
            )
            :boxR (do
                (def boxes (boxes-to-push @[[r c]] [dr dc]))
                (when boxes
                    (push-boxes boxes [dr dc])
                    (+= r dr)
                    (+= c dc)
                )
            )
            :boxL (do
                (def boxes (boxes-to-push @[[r c]] [dr dc]))
                (when boxes
                    (push-boxes boxes [dr dc])
                    (+= r dr)
                    (+= c dc)
                )
            )
            :wall (do)
            (error "ran into unknown object in the grid")
        )        
    )

    (def box-gps-coords
        (seq [[r row] :pairs grid
              [c thing] :pairs row
              :when (= thing :boxL)
             ]
            (+ (* 100 r) c)
        )
    )
    
    (sum box-gps-coords)
)


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

(print "Part 1: " (solve-part-1 grid directions [robot-r robot-c]))
(print "Part 2: " (solve-part-2 grid2 directions [robot-r (* 2 robot-c)]))
