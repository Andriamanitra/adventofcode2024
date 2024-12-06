(def input-peg ~{
        :main (sequence :edges "\n" :subgraphs)
        :edges (group (some (sequence :edge "\n")))
        :edge (group (sequence :int "|" :int))
        :subgraphs (group (some (sequence :subgraph "\n")))
        :subgraph (group (sequence :int (any (sequence "," :int))))
        :int (number :d+)
    }
)

(def [edges subgraphs] (peg/match input-peg (slurp "input.txt")))
(defn dependency-table [edges subgraph]
    (def E (tabseq [node :in subgraph] node @[]))
    (loop [[a b] :in edges :when (all |(has-value? subgraph $) [a b])]
        (array/push (in E b) a)
    )
    E
)

(def total-of @{:correctly-ordered 0 :incorrectly-ordered 0})
(loop [arr :in subgraphs]
    (def E (dependency-table edges arr))
    (def positions (tabseq [[i node] :pairs arr] node i))
    (var which :correctly-ordered)
    (def mid (div (length arr) 2))
    (for i 0 (inc mid)
        (while (def dep-v (find |(< i (in positions $)) (in E (i arr))))
            (set which :incorrectly-ordered)
            (def dep-i (in positions dep-v))
            (def v (i arr))
            # swap subgraph[i] with its dependency
            (put arr i dep-v)
            (put positions dep-v i)
            (put arr dep-i v)
            (put positions v dep-i)
        )
    )
    (+= (total-of which) (mid arr))
)
(print "Part 1: " (total-of :correctly-ordered))
(print "Part 2: " (total-of :incorrectly-ordered))
