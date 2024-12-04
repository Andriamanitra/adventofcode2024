(defn gridify (input)
    (def grid @{})
    (loop ([r line] :pairs (string/split "\n" input)
           [c ch] :pairs line)
        (put grid [r c] ch)
    )
    grid
)

(defn solve-part-1 (grid)
    (def directions [[1 0] [1 1] [0 1] [-1 1] [-1 0] [-1 -1] [0 -1] [1 -1]])
    (var xmas-count 0)
    (loop ([x y] :keys grid
           [dx dy] :in directions
           :when (->> (pairs "XMAS") (all (fn [[i ch]] (= ch (in grid [(+ x (* i dx)) (+ y (* i dy))]))))))
        (++ xmas-count)
    )
    (printf "Part 1: %d" xmas-count)
)

(defn solve-part-2 (grid)
    (var x-mas-count 0)
    (def valid? {(string/bytes "MS") true (string/bytes "SM") true})
    (loop ([x y] :keys grid
           :when (= (0 "A") (in grid [x y]))
           :when (get valid? [(in grid [(dec x) (dec y)]) (in grid [(inc x) (inc y)])])
           :when (get valid? [(in grid [(dec x) (inc y)]) (in grid [(inc x) (dec y)])]))
        (++ x-mas-count)
    )
    (printf "Part 2: %d" x-mas-count)
)

(def input (string/trim (slurp "input.txt")))
((juxt solve-part-1 solve-part-2) (gridify input))
