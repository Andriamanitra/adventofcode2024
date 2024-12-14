(def input (slurp (or (get (dyn *args*) 1) "input.txt")))
(def grid-size [101 103])
(def robots
    (->> input
        (peg/match
            ~{
                :main (sequence :robot (any (sequence "\n" :robot)))
                :robot (replace (group (sequence "p=" :int "," :int " v=" :int "," :int)) ,|(tuple ;$))
                :int (number (sequence (opt "-") :d+))
            }
        )
    )
)

(defn which-quadrant [[x y] [width height]]
    (def x-mid (div width 2))
    (def y-mid (div height 2))
    (cond
        (or (= x x-mid) (= y y-mid)) :none
        (and (< x x-mid) (< y y-mid)) :top-left
        (and (> x x-mid) (< y y-mid)) :top-right
        (and (< x x-mid) (> y y-mid)) :bottom-left
        (and (> x x-mid) (> y y-mid)) :bottom-right
    )
)

(defn calculate-safety-factor [robots [w h]]
    (->> robots
        (map (fn [[x y _ _]] (which-quadrant [x y] [w h])))
        (filter |(not= :none $))
        (group-by identity)
        (values)
        (map length)
        (product)
    )
)

(defn make-grid [robots]
    (def grid @{})
    (loop [[x y _ _] :in robots]
        (put grid [x y] true)
    )
    grid
)

(defn visualization [grid [width height]]
    (string/join
        (seq [y :range [0 (div height 2)]]
            (string
                ;(seq [x :range [0 width]]
                    (let [ top-filled (get grid [x (* y 2)])
                           bottom-filled (get grid [x (+ 1 (* y 2))])
                         ]
                        (cond
                            (and top-filled bottom-filled) "█"
                            top-filled "▀"
                            bottom-filled "▄"
                            :else " "
                        )
                    )
                )
            )
        )
        "\n"
    )
)

(defn might-be-tree? [grid]
    # a good xmas tree should have at least one horizontal line in it
    (any?
        (seq [[x y] :keys grid]
            (all identity (seq [nx :range [x (+ 7 x)]] (has-key? grid [nx y])))
        )
    )
)

(defn move-robot [num-steps [x y Δx Δy] [width height]]
    (def x (mod (+ x (* num-steps Δx)) width))
    (def y (mod (+ y (* num-steps Δy)) height))
    [x y Δx Δy]
)

(defn solve-part-1 [robots grid-size]
    (-> (map |(move-robot 100 $ grid-size) robots)
        (calculate-safety-factor grid-size)
    )
)

(defn prompt-temporary [prompt]
    (print prompt)
    (def answer (getline))
    (printf "\u001b[%dF\u001b[0J\u001b[1A" (+ 1 (length (string/split "\n" prompt))))
    answer
)

(defn find-easter-egg [robots [width height]]
    (print "Moving robots in search of a christmas tree...")
    (var robots robots)
    (var found nil)
    # all of the robots MUST be back to their starting positions
    # after WIDTH * HEIGHT steps because:
    # 1. (x + Δx * w * h) % w = x
    # 2. (y + Δy * w * h) % h = y
    (loop [step :range [1 (* width height)] :until found]
        (print "Step #" step)
        (set robots (map |(move-robot 1 $ [width height]) robots))
        (def grid (make-grid robots))
        (when (might-be-tree? grid)
            (def answer
                (prompt-temporary
                    (string
                        (visualization grid [width height])
                        "\nDoes this look like a christmas tree to you?"
                    )
                )
            )
            (when (string/has-prefix? "y" (string/ascii-lower answer))
                (set found step)
            )
        )
        (printf "\u001b[1F\u001b[0K\u001b[1A")
    )
    found
)

(print "Part 1: " (solve-part-1 robots grid-size))
(def part-2 (find-easter-egg robots grid-size))
(print "Part 2: " part-2)
