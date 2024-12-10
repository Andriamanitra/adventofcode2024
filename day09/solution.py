from heapq import heappop, heappush


def part1(nums: list[int]) -> int:
    is_file = True
    blocks = []
    i = 0
    file_id = 0
    for length in nums:
        if is_file:
            blocks.extend(file_id for _ in range(length))
            file_id += 1
        else:
            blocks.extend(None for _ in range(length))
        is_file = not is_file

    left = 0
    right = len(blocks) - 1
    while left < right:
        while left < right and blocks[left] is not None:
            left += 1
        while left < right and blocks[right] is None:
            right -= 1
        if left < right:
            blocks[left], blocks[right] = blocks[right], blocks[left]

    return sum(idx * file_id for idx, file_id in enumerate(blocks) if file_id is not None)


class EmptySpaceTracker:
    def __init__(self):
        self.pointers = [0 for _ in range(10)]
        self.spaces = [[] for _ in range(10)]
        self.heaps = [[] for _ in range(10)]

    def push_back(self, i: int, size: int):
        self.spaces[size].append(i)

    def use(self, size: int) -> int:
        idx = NOT_FOUND = 1337_000_000
        used_size = None
        used_heap = False

        for i in range(size, 10):
            if self.pointers[i] < len(self.spaces[i]):
                from_list = self.spaces[i][self.pointers[i]]
                if from_list < idx:
                    idx = from_list
                    used_size = i
                    used_heap = False

            heap = self.heaps[i]
            if heap:
                from_heap = heap[0]
                if from_heap < idx:
                    idx = from_heap
                    used_size = i
                    used_heap = True

        if used_size is None:
            return NOT_FOUND

        if used_heap:
            heappop(self.heaps[used_size])
        else:
            self.pointers[used_size] += 1

        rem = used_size - size
        if rem > 0:
            heappush(self.heaps[rem], idx + size)

        return idx


def with_lists_and_heaps(nums: list[int]) -> int:
    files = []
    spaces = EmptySpaceTracker()
    pos = 0
    for i, size in enumerate(nums):
        if i & 1:
            spaces.push_back(pos, size)
        else:
            files.append([pos, size, i >> 1])
        pos += size

    checksum = 0
    for pos, size, file_id in reversed(files):
        free_idx = spaces.use(size)
        if free_idx < pos:
            pos = free_idx
        checksum += file_id * ((size * (size - 1) // 2) + pos * size)

    return checksum


def with_heaps(nums: list[int]) -> int:
    files = []
    heaps = [[] for _ in range(10)]
    pos = 0
    for i, size in enumerate(nums):
        if i & 1:
            heaps[size].append(pos)
        else:
            files.append([pos, size, i >> 1])
        pos += size

    checksum = 0
    for pos, size, file_id in reversed(files):
        used_heap = None
        for i in range(size, 10):
            if heaps[i] and heaps[i][0] < pos:
                pos = heaps[i][0]
                used_heap = i
        if used_heap:
            heappop(heaps[used_heap])
            rem = used_heap - size
            heappush(heaps[rem], pos + size)
        checksum += file_id * ((size * (size - 1) // 2) + pos * size)

    return checksum


# FIXME: this function has a bug
# it fails the example even though it produces
# the right answer with the actual input
def with_lists(nums: list[int]) -> int:
    files = []
    lists = [[] for _ in range(10)]
    pointers = [0 for _ in range(10)]
    used_positions = {}
    pos = 0
    for i, size in enumerate(nums):
        if i & 1:
            for j in range(1, size + 1):
                lists[j].append((pos, size))
        else:
            files.append([pos, size, i >> 1])
        pos += size

    checksum = 0
    for original_pos, size, file_id in reversed(files):
        ptr = pointers[size]
        pos = 1337_000_000
        while ptr < len(lists[size]):
            pos, space_size = lists[size][ptr]
            while pos in used_positions:
                space_size -= used_positions[pos] - pos
                pos = used_positions[pos]
            if space_size >= size:
                break
            ptr += 1
        if original_pos < pos:
            pos = original_pos
        else:
            used_positions[pos] = pos + size
        checksum += file_id * ((size * (size - 1) // 2) + pos * size)

    return checksum


def compare_times(nums):
    import timeit
    for func in (with_lists_and_heaps, with_heaps, with_lists):
        test_result = func([2,3,3,3,1,3,3,1,2,1,4,1,4,1,3,1,4,0,2])
        errmsg = f"{func.__name__} returned {test_result} (expected 2858)"
        assert test_result == 2858, errmsg
        print(f"{func.__name__}:")
        t = timeit.timeit(lambda: func(nums), number=10)
        print(f"  {t:.3}s\n")


def main():
    with open("input.txt") as f:
        s = f.read().rstrip()
    nums = [int(digit) for digit in s]
    print("Part 1:", part1(nums))
    print("Part 2:", with_heaps(nums))


if __name__ == "__main__":
    main()
