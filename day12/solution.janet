(defn find-regions [grid]
    (def visited (map |(map (fn [x] nil) $) grid))
    (def height (length grid))
    (def width (length (0 grid)))

    (defn unvisited? [pos]
        (nil? (get-in visited pos))
    )

    (defn region-at [i j]
        (def color (get-in grid [i j]))
        (defn all-neighbors [[i j]]
            [[(inc i) j] [(dec i) j] [i (inc j)] [i (dec j)]]
        )
        (defn same-color? [[r c]]
            (and
                (<= 0 r (dec height))
                (<= 0 c (dec width))
                (= color (get-in grid [r c]))
            )
        )

        (var area 0)
        (var edges @[])
        (defn add-edge [[r0 c0] [r1 c1]]
            (array/push
                edges
                (cond
                    (= r0 r1)
                        [(if (< c1 c0) :verticalL :verticalR) c0 r0]
                    (= c0 c1)
                        [(if (< r1 r0) :horizontalL :horizontalR) r0 c0]
                )
            )
        )

        (def q @[])
        (defn add-to-q [pos]
            (put-in visited pos true)
            (array/push q pos)
        )
        (add-to-q [i j])
        (while (not (empty? q))
            (def cur-pos (array/pop q))
            (++ area)

            (loop [pos :in (all-neighbors cur-pos)]
                (if (same-color? pos)
                    (when (unvisited? pos) (add-to-q pos))
                # else
                    (add-edge cur-pos pos)
                )
            )
        )
        [area edges]
    )

    (seq [i :range [0 height] j :range [0 width] :when (unvisited? [i j])]
        (region-at i j)
    )
)

(defn count-edges [edges]
    (var count 0)
    (var prev-orientation :none)
    (var [prev-x prev-y] [0 0])
    (loop [[orientation x y] :in (sort edges)]
        (when (or (not= orientation prev-orientation) (not= x prev-x) (not= (dec y) prev-y))
            (++ count)
        )
        (set prev-orientation orientation)
        (set prev-x x)
        (set prev-y y)
    )
    count
)

(def regions
    (->> (slurp "input.txt")
        (string/trim)
        (string/split "\n")
        (find-regions)
    )
)

(defn fence-price [regions &opt discount]
    (defn calculate-price [[area edges]]
        (case discount
            :bulk-discount
                (* area (count-edges edges))
            nil
                (* area (length edges))
        )
    )
    (sum (map calculate-price regions))
)

(print "Part 1: " (fence-price regions))
(print "Part 2: " (fence-price regions :bulk-discount))
