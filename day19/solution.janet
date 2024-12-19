(def input-file (or (get (dyn *args*) 1) "input.txt"))

(defn parse-input [s]
    (peg/match
        ~{
            :main (sequence :patterns "\n\n" :designs)
            :patterns (group (sequence :towel (any (sequence ", " :towel))))
            :designs (group (sequence :towel (any (sequence "\n" :towel))))
            :towel (<- (some (set "wubrg")))
        }
        s
    )
)

(defn count-ways [patterns design]
    (def end (length design))
    (def ways-up-to (array/new-filled (+ end 1) 0))
    (put ways-up-to 0 1)
    (for i 0 end
        (def ways-here (i ways-up-to))
        (when (pos? ways-here)
            (def tail (string/slice design i))
            (loop [patt :in patterns :when (string/has-prefix? patt tail)]
                (update ways-up-to (+ i (length patt)) |(+ $ ways-here))
            )
        )
    )
    (get ways-up-to end)
)

(def [patterns designs]
    (->> input-file
        (slurp)
        (parse-input)
    )
)
(def numbers-of-ways (map (partial count-ways patterns) designs))
    
(print "Part 1: " (count pos? numbers-of-ways))
(print "Part 2: " (sum numbers-of-ways))
