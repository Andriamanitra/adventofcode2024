(defn read-input [str]
    (defn make-antenna [[x y freq]]
        {:freq freq :x x :y y}
    )
    (defn group-by-frequency [antennas]
        (group-by |($ :freq) antennas)
    )
    (peg/match
        ~{
            :main (sequence (/ :antennas ,group-by-frequency) :end)
            :antennas (group (sequence :row (some (sequence :s+ :row))))
            :row (some (choice :antenna "."))
            :antenna (/ (group (sequence :position (<- :w))) ,make-antenna)
            :position (sequence :line-index :column-index)
            :line-index (/ (line) ,dec)
            :column-index (/ (column) ,dec)
            :end (sequence :line-index (/ :column-index ,dec))
        }
        str
    )
)

(def [antennas-by-freq max-x max-y] (read-input (slurp "input.txt")))

(defn find-antinodes [part]
    (def antinodes @{})
    (loop [antennas :in antennas-by-freq
           a :in antennas
           b :in antennas
           :when (not= a b)
          ]
        (def {:x ax :y ay} a)
        (def {:x bx :y by} b)
        (def [Δx Δy] [(- ax bx) (- ay by)])
        (case part
            1 (let [x (+ ax Δx) y (+ ay Δy)]
                (when (and (<= 0 x max-x) (<= 0 y max-y))
                    (update antinodes [x y] |(inc (or $ 0)))
                )
            )
            2 (do
                (var [x y] [ax ay])
                (while (and (<= 0 x max-x) (<= 0 y max-y))
                    (update antinodes [x y] |(inc (or $ 0)))
                    (+= x Δx)
                    (+= y Δy)
                )
            )
        )
    )
    antinodes
)

(each part [1 2]
    (printf "Part %d: %d" part (length (find-antinodes part)))
)
