(defn array/swap [arr i j]
    (def tmp (get arr i))
    (put arr i (get arr j))
    (put arr j tmp)
)

(defn heapify [arr]
    (def higher-priority? compare<)
    (def n (length arr))
    (defn heapify-index [i]
        (def left (+ (* 2 i) 1))
        (def right (inc left))
        (var highest i)
        (var highest-val (get arr i))
        (when (< left n)
            (def left-val (get arr left))
            (when (higher-priority? left-val highest-val)
                (set highest left)
                (set highest-val left-val)
            )
        )
        (when (< right n)
            (def right-val (get arr right))
            (when (higher-priority? right-val highest-val)
                (set highest right)
                (set highest-val right-val)
            )
        )
        (when (not= highest i)
            (put arr highest (get arr i))
            (put arr i highest-val)
            (heapify-index highest)
        )
    )
    (loop [i :down-to [(div (dec n) 2) 0]]
        (heapify-index i)
    )
    arr
)

(defn heappush [arr el]
    (def higher-priority? compare<)
    (var i (length arr))
    (var p (div i 2))
    (array/push arr el)
    (while (higher-priority? (get arr i) (get arr p))
        (array/swap arr i p)
        (set i p)
        (set p (div i 2))
    )
)

(defn heappop [arr]
    (def ret (get arr 0))
    (def popped (array/pop arr))
    (when (not (empty? arr))
        (put arr 0 popped)
        (heapify arr)
    )
    ret
)

(defn parse-maze [str]
    (def START   (0 "S"))
    (def END     (0 "E"))
    (def WALL    (0 "#"))
    (def EMPTY   (0 "."))
    (def NEWLINE (0 "\n"))
    (var start nil)
    (var end nil)
    (var r 0)
    (var c 0)
    (def walls @{})
    (each char str
        (case char
            EMPTY (++ c)
            START (do
                (set start [r c])
                (++ c)
            )
            END (do
                (set end [r c])
                (++ c)
            )
            WALL (do
                (put walls [r c] true)
                (++ c)
            )
            NEWLINE (do
                (++ r)
                (set c 0)
            )
        )
    )
    [start end walls]
)

(defn turn [direction facing]
    (case [direction facing]
        [:left :north] :west
        [:left :south] :east
        [:left :east] :north
        [:left :west] :south
        [:right :north] :east
        [:right :south] :west
        [:right :east] :south
        [:right :west] :north
        facing
    )
)

(defn step [[i j] facing]
    (case facing
        :north [(dec i) j]
        :south [(inc i) j]
        :east  [i (inc j)]
        :west  [i (dec j)]
    )
)

(defn solve-part-1 [input]
    (def [start end walls] (parse-maze input))
    (defn wall? [pos] (has-key? walls pos))
    (def q @[[0 start :east]])
    (def visited @{})
    (var min-score math/inf)
    (label result
        (while (not (empty? q))
            (def [score pos facing] (heappop q))
            (cond
                (= pos end) (return result score)
                :else (do
                    (let [
                            next-score (+ score 1)
                            next-pos (step pos facing)
                        ]
                        (when (not (or (wall? next-pos) (has-key? visited [next-pos facing])))
                            (heappush q [next-score (step pos facing) facing])
                            (put visited [next-pos facing] next-score)
                        )
                    )
                    (each direction [:left :right]
                        (let [
                                next-score (+ score 1001)
                                fc (turn direction facing)
                                next-pos (step pos fc)
                            ]
                            (when (not (or (wall? next-pos) (has-key? visited [next-pos fc])))
                                (put visited [next-pos facing] next-score)
                                (heappush q [next-score (step pos fc) fc])
                            )
                        )
                    )
                )
            )
        )
    )
)

(def input (slurp "input.txt"))
(print "Part 1: " (solve-part-1 input))
