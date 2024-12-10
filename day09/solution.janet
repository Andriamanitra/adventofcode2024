(defn read-input [str] (peg/match ~(some (number :d)) str))
(def input (read-input (slurp "input.txt")))

(defn part-1 [s]
    (def q
        (seq [i :range [0 (length s) 2] :let [file-id (div i 2)] _ :range [0 (i s)]]
            file-id
        )
    )
    (var result 0)
    (var pos 0)
    (var is-file true)
    (var left 0)
    (var right (dec (length q)))
    (loop [len :in s]
        (loop [i :range [0 len] :while (<= left right)]
            (if is-file
                (let [file-id (left q)]
                    (+= result (* file-id pos))
                    (++ left)
                )
                (let [file-id (right q)]
                    (+= result (* file-id pos))
                    (-- right)
                )
            )
            (++ pos)
        )
        (set is-file (not is-file))
    )
    result
)

(defn part-2 [s]
    (var pos 0)
    (var is-file true)
    (def files
        (seq [[i len] :pairs s :after (+= pos len) :after (set is-file (not is-file)) :when is-file]
            [(div i 2) pos len]
        )
    )
    (def reversed-files (reverse files))
    (def shifted-files @{})

    (defn not-shifted? [file-id]
        (not (has-key? shifted-files file-id))
    )

    (defn find-shifted [files min-pos max-len]
        (->> files
            (take-while (fn [[file-id pos len]] (<= min-pos pos)))
            (find (fn [[file-id pos len]] (and (not-shifted? file-id) (<= len max-len))))
        )
    )

    (defn file-sum [file-id start-pos end-pos]
        (* file-id (+ ;(range start-pos end-pos)))
    )

    (var result 0)
    (var pos 0)
    (var is-file true)
    (var file-id 0)
    (loop [len :in s]
        (if is-file
            (do
                (when (not-shifted? file-id)
                    (+= result (file-sum file-id pos (+ pos len)))
                )
                (++ file-id)
            ) # else
            (do
                (var rem len)
                (var tmp-pos pos)
                (while (def found (find-shifted reversed-files tmp-pos rem))
                    (def [file-id _ file-len] found)
                    (+= result (file-sum file-id tmp-pos (+ tmp-pos file-len)))
                    (put shifted-files file-id true)
                    (-= rem file-len)
                    (+= tmp-pos file-len)
                )
            )
        )
        (+= pos len)
        (set is-file (not is-file))
    )
    result
)

#(use judge)
#(test (read-input "123") @[1 2 3])
#(test (part-1 (read-input "2333133121414131402")) 1928)
#(test (part-2 (read-input "2333133121414131402")) 2858)

(print "Part 1: " (part-1 input))
(print "Part 2: " (part-2 input))
