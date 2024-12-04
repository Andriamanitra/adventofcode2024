from collections.abc import Generator
from dataclasses import dataclass
from pathlib import Path
import sys

# Read input from file when given a file name as a command line argument,
# otherwise read input from STDIN
if len(sys.argv) > 1:
    in_txt = Path(sys.argv[1]).read_text()
else:
    STDIN = 0
    in_txt = open(STDIN).read()


@dataclass
class Token:
    token: str
    value: int = 0

    def __str__(self) -> str:
        return self.token


DO_TOKEN = Token("do()")
DONT_TOKEN = Token("don't()")


def tokenize(s: str, pos: int = 0) -> Generator[Token]:
    def mul(a: int, b: int) -> Token:
        return Token(f"mul({a},{b})", a * b)

    while pos < len(s):
        if s.startswith("mul(", pos):
            pos_num1 = pos + 4
            i = pos_num1
            while s[i].isdecimal():
                i += 1
            if i == pos_num1:
                pos = i
                continue
            num1 = int(s[pos_num1:i])
            if s[i] != ",":
                pos = i
                continue
            pos_num2 = i + 1
            i = pos_num2
            while s[i].isdecimal():
                i += 1
            if i == pos_num2:
                pos = i
                continue
            num2 = int(s[pos_num2:i])
            if s[i] != ")":
                pos = i
                continue
            yield mul(num1, num2)
            pos = i + 1
        else:
            nextpos = pos + 1
            for t in [DO_TOKEN, DONT_TOKEN]:
                if s.startswith(t.token, pos):
                    yield t
                    nextpos = pos + len(t.token)
                    break
            pos = nextpos


part1 = sum(token.value for token in tokenize(in_txt))

part2 = 0
enabled = True
for token in tokenize(in_txt):
    if token == DONT_TOKEN:
        enabled = False
    elif token == DO_TOKEN:
        enabled = True
    elif enabled:
        part2 += token.value

print(
    f"Input: {in_txt!r}\n"
    f"Tokens: {','.join(str(token) for token in tokenize(in_txt))}\n"
    f"Part 1: {part1}\n"
    f"Part 2: {part2}\n"
)
