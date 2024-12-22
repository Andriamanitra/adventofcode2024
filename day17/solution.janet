(var DEBUG? (os/getenv "DEBUG"))
(var input-file "input.txt")
(each arg (drop 1 (dyn *args*))
    (case arg
        "--debug" (set DEBUG? true)
        (set input-file arg)
    )
)

(def input
    (->>
        (slurp input-file)
        (peg/match
            ~{
                :main (sequence :registers "\n\n" :program)
                :registers (/ (sequence :reg "\n" :reg "\n" :reg) ,table)
                :reg (sequence "Register " (/ (<- :a) ,keyword) ": " :int)
                :int (number :d+)
                :program (sequence "Program: " (/ (split "," :int) ,tuple))
            }
        )
    )
)

(defmacro err! [reason & args]
    (def [line-number col] (tuple/sourcemap (dyn *macro-form*)))
    (def file-name (dyn *current-file*))
    ~(:error self ,reason (string/format "%s:%d (column %d)" ,file-name ,line-number ,col))
)

(defn debug/log [& args]
    (when DEBUG? (eprintf ;args))
)

(defn mod8 [val]
    (band val 7)
)

(defn computer/new [regs program]
    (debug/log "Initializing a computer with program=%Q regs=%Q" program regs)
    @{
        :ip 0
        :registers regs
        :program program
        :output @[]

        :read-instruction
            (fn [self]
                (case (get (self :program) (self :ip))
                    0 :adv
                    1 :bxl
                    2 :bst
                    3 :jnz
                    4 :bxc
                    5 :out
                    6 :bdv
                    7 :cdv
                    (err! "invalid instruction")
                )
            )

        :jump-relative
            (fn [self n]
                (+= (self :ip) n)
                (debug/log "-> Jumped %Q steps to ip=%Q" n (self :ip))
            )

        :jump-absolute
            (fn [self target]
                (set (self :ip) target)
                (debug/log "-> Jumped to ip=%Q" (self :ip))
            )

        :read-register
            (fn [self id]
                (def value (get (self :registers) id))
                (debug/log "- Read %Q from register %Q" value id)
                value
            )

        :write-register
            (fn [self id value]
                (debug/log "-> Writing %Q to register %Q" value id)
                (put (self :registers) id value)
            )

        :read-literal-operand
            (fn [self]
                (def operand (get (self :program) (inc (self :ip))))
                (debug/log "- Read literal operand %Q" operand)
                operand
            )

        :read-combo-operand
            (fn [self]
                (def operand (get (self :program) (inc (self :ip))))
                (debug/log "- Read combo operand %Q" operand)
                (case operand
                    0 0
                    1 1
                    2 2
                    3 3
                    4 (:read-register self :A)
                    5 (:read-register self :B)
                    6 (:read-register self :C)
                    7 (err! "combo operand 7 is reserved")
                )
            )

        :write-output
            (fn [self value]
                (debug/log "-> Writing %Q to output" value)
                (array/push (self :output) value)
            )

        :display-state
            (fn [self]
                (string/format
                    "{ A=%Q, B=%Q, C=%Q, ip=%Q, i[%Q %Q] }"
                    (get (self :registers) :A)
                    (get (self :registers) :B)
                    (get (self :registers) :C)
                    (self :ip)
                    (get (self :program) (self :ip))
                    (get (self :program) (inc (self :ip)))
                )
            )

        :error
            (fn [self reason where]
                (eprinf
                    "\u001b[31m[ERROR]\u001b[0m %s \u001b[30;1m@ %s\u001b[0m\n\u001b[30;1m- cpu state:\u001b[0m %s"
                    reason
                    where
                    (:display-state self)
                )
                (os/exit 1)
            )

        :adv
            (fn [self]
                (def numerator (:read-register self :A))
                (def denominator (blshift 1 (:read-combo-operand self)))
                (:write-register self :A (div numerator denominator))
                (:jump-relative self 2)
            )

        :bxl
            (fn [self]
                (def x (:read-register self :B))
                (def y (:read-literal-operand self))
                (:write-register self :B (bxor x y))
                (:jump-relative self 2)
            )

        :bst
            (fn [self]
                (def operand (:read-combo-operand self))
                (:write-register self :B (mod8 operand))
                (:jump-relative self 2)
            )

        :jnz
            (fn [self]
                (if (zero? (:read-register self :A))
                    (:jump-relative self 2)
                    (:jump-absolute self (:read-literal-operand self))
                )
            )

        :bxc
            (fn [self]
                # reads an operand for legacy reasons
                (:read-literal-operand self)
                (def b (:read-register self :B))
                (def c (:read-register self :C))
                (:write-register self :B (bxor b c))
                (:jump-relative self 2)
            )

        :out
            (fn [self]
                (:write-output self (:read-combo-operand self))
                (:jump-relative self 2)
            )

        :bdv
            (fn [self]
                (def numerator (:read-register self :A))
                (def denominator (blshift 1 (:read-combo-operand self)))
                (:write-register self :B (div numerator denominator))
                (:jump-relative self 2)
            )

        :cdv
            (fn [self]
                (def numerator (:read-register self :A))
                (def denominator (blshift 1 (:read-combo-operand self)))
                (:write-register self :C (div numerator denominator))
                (:jump-relative self 2)
            )

        :step
            (fn [self]
                (def instruction (:read-instruction self))
                (when (not (nil? instruction))
                    (debug/log "Running %Q" instruction)
                    (instruction self)
                    (debug/log "\nState: %s\n" (:display-state self))
                )
            )

        :run
            (fn [self]
                (while (< (self :ip) (length (self :program)))
                    (:step self)
                )
                (tuple ;(self :output))
            )
    }
)

(defn solve-part-1 [registers program]
    (def output (:run (computer/new registers program)))
    (string/join (map (comp string mod8) output) ",")
)

(def [registers program] input)
(print "Part 1: " (solve-part-1 registers program))
