(def input-file (or (get (dyn *args*) 1) "input.txt"))

(defn parse-key-or-lock [s]
    (as-> s $
        (string/replace-all "\n" "" $)
        (string/replace-all "#" "1" $)
        (string/replace-all "." "0" $)
        (scan-number $ 2)
        (bor 0:u $)
    )
)

(def keys-n-locks
    (->> (slurp input-file)
        (string/split "\n\n")
        (map parse-key-or-lock)
    )
)


(def seen @{})
(def OPEN (int/u64 "34359738367"))
(var count 0)
(each k keys-n-locks
    (each m keys-n-locks
        (when (and (not= k m) (zero? (band k m)))
            (++ count)
        )
    )
)
(set count (div count 2))

(print "Part 1: " count)
