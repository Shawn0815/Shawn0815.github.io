---
title: "[Python]  內建資料結構"
date: 2026-10-26 18:56 +0800
categories: ["Python", "Basics"]
tags: []
order: "000001_basics/000001.000002_builtin-data-structures.md"
image: {path: "/assets/img/covers/Python.png"}
source: DDAN_Usandbox/0_Personal/Python/1_Basics/1.2_Builtin-Data-Structures.md
render_with_liquid: false
---

## Abstract

寫 LeetCode 會用到的容器怎麼用：list、tuple、dict、set，以及 `collections` 的 `Counter`、`defaultdict`、`deque`，還有 `heapq`、`bisect`。

這篇只寫 Python 的用法，資料結構本身的原理（Heap 為什麼是 O(log n)、Hash 怎麼運作）不在這裡。

範例都在本機 `Python 3.14.8` 跑過，程式碼區塊裡 `# →` 後面是實際執行的輸出。

---

## 怎麼選

| 需求 | 用 | 章節 |
|------|----|------|
| 有順序、用 index 存取、可以改 | `list` | 1 |
| Stack（後進先出） | `list`（`append` / `pop`） | 1.6 |
| 固定的一組值、要當 dict 的 key | `tuple` | 2 |
| key → value 查找、計數、記錄 index | `dict` | 3 |
| 判斷有沒有出現過、去重 | `set` | 4 |
| 計算每個元素出現幾次 | `Counter` | 5.1 |
| 一個 key 對應一串值（圖的鄰接表、分組） | `defaultdict(list)` | 5.2 |
| Queue（先進先出）、BFS | `deque` | 5.3 |
| 每次取最小（或最大）、Top K | `heapq` | 6 |
| 在排好序的 list 找位置 | `bisect` | 7 |

---

## list

### 常用操作

```python
nums = [3, 1, 4]

nums.append(1); print(nums)    # 加到尾端
# → [3, 1, 4, 1]

nums.insert(0, 9); print(nums)    # 插到 index 0
# → [9, 3, 1, 4, 1]

print(nums.pop(), nums)    # 取出並移除最後一個
# → 1 [9, 3, 1, 4]

print(nums.pop(0), nums)    # 取出並移除 index 0
# → 9 [3, 1, 4]

nums.extend([5, 9]); print(nums)    # 接上另一個 list
# → [3, 1, 4, 5, 9]

print(nums.index(4), nums.count(1), 4 in nums, len(nums))
# → 2 1 True 5

nums.remove(1); print(nums)    # 移除第一個值為 1 的元素
# → [3, 4, 5, 9]

print(sum(nums), min(nums), max(nums))
# → 21 3 9
```

| 操作 | 說明 | 複雜度 |
|------|------|--------|
| `a.append(x)` | 加到尾端 | O(1) |
| `a.pop()` | 取出最後一個 | O(1) |
| `a.pop(0)`、`a.insert(0, x)` | 動到開頭，後面全部要搬 | **O(n)** |
| `x in a`、`a.index(x)`、`a.remove(x)` | 從頭找 | **O(n)** |
| `a[i]`、`a[i] = x` | 用 index 存取 | O(1) |
| `len(a)` | 長度 | O(1) |

==要從開頭取出就不要用 list==（`pop(0)` 是 O(n)），改用 `deque`，==要頻繁判斷「有沒有在裡面」也不要用 list==，改用 `set`。

### Slicing（切片）

`a[start:stop:step]`：從 `start` 到 `stop`（不含 stop），每次跳 `step`。
任何一個都可以省略。

```python
a = [0, 1, 2, 3, 4, 5]
print(a[1:4], a[:3], a[3:], a[-2:], a[::2], a[::-1])
# → [1, 2, 3] [0, 1, 2] [3, 4, 5] [4, 5] [0, 2, 4] [5, 4, 3, 2, 1, 0]
```

| 寫法 | 意思 |
|------|------|
| `a[1:4]` | index 1、2、3 |
| `a[:3]` | 前 3 個 |
| `a[3:]` | 從 index 3 到最後 |
| `a[-2:]` | 最後 2 個 |
| `a[::2]` | 每隔一個 |
| `a[::-1]` | 反轉 |
| `a[:]` | 整個複製一份 |

切片超出範圍不會報錯，只會回傳空的或截斷：

```python
print(a[10:])
# → []
```

切片會建立新的 list（O(k)，k 是切出來的長度），在遞迴裡一直切 list 傳下去會很慢，通常改成傳 index。

### 排序

```python
c = [3, 1, 2]
print(sorted(c), c)       # sorted()：回傳新的 list，原本的不變
# → [1, 2, 3] [3, 1, 2]

c.sort(); print(c)        # .sort()：直接改原本的 list
# → [1, 2, 3]

c.sort(reverse=True); print(c)
# → [3, 2, 1]

print(c.sort())           # .sort() 回傳 None
# → None
```

**`result = nums.sort()` 會得到 `None`**，要拿回傳值就用 `sorted(nums)`。

#### 用 key 指定排序依據

`key=` 傳入一個函式，每個元素先經過這個函式，再用結果比大小：

```python
words = ["banana", "kiwi", "apple"]
print(sorted(words, key=len))
# → ['kiwi', 'apple', 'banana']        依長度排
```

排 `[start, end]` 這類區間時，key 常用 `lambda`（一行的匿名函式，細節在 1.3）：

```python
pairs = [[1, 1], [0, 2], [1, 3]]
print(sorted(pairs, key=lambda p: p[0]))
# → [[0, 2], [1, 1], [1, 3]]           依第一個值排

print(sorted(pairs, key=lambda p: (p[0], -p[1])))
# → [[0, 2], [1, 3], [1, 1]]           先依第一個值由小到大，同樣時再依第二個值由大到小
```

- key 回傳 tuple 就是多重排序：先比第一個，一樣再比第二個。
- 某一項要由大到小，數字就加負號（`-p[1]`）。
- 排序是穩定的：key 一樣的元素，維持原本的先後順序。
- 複雜度 O(n log n)。

### 建立固定大小的 list

```python
print([0] * 5)
# → [0, 0, 0, 0, 0]
```

#### 二維 list 的陷阱 ⚠️

```python
grid_bad = [[0] * 3] * 2
grid_bad[0][0] = 1
print(grid_bad)
# → [[1, 0, 0], [1, 0, 0]]      ← 改一列，兩列都變了
```

`[[0] * 3] * 2` 是把==同一個== list 放兩次，兩列其實是同一個物件。
正確寫法是用 comprehension 每列各建一個：

```python
grid_ok = [[0] * 3 for _ in range(2)]
grid_ok[0][0] = 1
print(grid_ok)
# → [[1, 0, 0], [0, 0, 0]]
```

`_` 是「這個變數用不到」的慣例名稱。
DP 表格、`visited` 陣列都要用這種寫法。

### 變數存的是參考

```python
x = [1, 2]
y = x            # y 和 x 指向同一個 list
y.append(3)
print(x)
# → [1, 2, 3]
```

`y = x` 不會複製，兩個名字指向同一個 list。
要複製用 `x[:]` 或 `list(x)`（只複製一層，list 裡面如果還有 list，內層仍是共用的）。

Backtracking 收集答案時最容易出錯：把 `path` 直接加進結果，之後 `path` 再改，結果裡的也跟著變。
要加複本：`result.append(path[:])`。

### 當 Stack 用

```python
st = []
st.append(1)
st.append(2)
print(st[-1], st.pop(), st)      # st[-1] 看頂端但不取出
# → 2 2 [1]
```

`append` 和 `pop()` 都是 O(1)，list 直接當 stack 用就好。
檢查空的寫 `if not st:`。

---

## tuple

```python
t = (1, 2)
print(t[0], len(t))
# → 1 2

t[0] = 5
# → TypeError: 'tuple' object does not support item assignment
```

tuple 是不能修改的 list。
寫題主要用在兩個地方：

1. 當 dict 的 key 或放進 set：例如座標 `(r, c)`。
   list 不能當 key，tuple 可以。
2. 一次放好幾個值：例如 heap 裡放 `(距離, 節點)`，BFS 的 queue 放 `(r, c, 步數)`。

只有一個元素時要加逗號，不然就只是括號：

```python
print(type((1,)), type((1)))
# → <class 'tuple'> <class 'int'>
```

---

## dict

### 基本操作

```python
d = {"a": 1}
d["b"] = 2; print(d)    # 新增或覆蓋
# → {'a': 1, 'b': 2}

print(d["a"], d.get("z"), d.get("z", 0))
# → 1 None 0

print("a" in d, "z" in d)    # 判斷 key 存不存在
# → True False

d["a"] += 1; print(d)
# → {'a': 2, 'b': 2}

del d["a"]; print(d)
# → {'b': 2}

print(d.pop("b"), d)
# → 2 {}
```

用 `d[key]` 取==不存在的 key 會報錯==：

```python
d["z"]
# → KeyError: 'z'
```

| 寫法 | key 不存在時 |
|------|-------------|
| `d[key]` | `KeyError` |
| `d.get(key)` | 回傳 `None` |
| `d.get(key, 預設值)` | 回傳預設值 |
| `key in d` | `False`（只判斷 key，不看 value） |

查找、新增、刪除、`in` 平均都是 O(1)。

#### 查 value 很慢：要查的東西放在 key

```python
d = {"a": 1, "b": 2}
print(2 in d, 2 in d.values(), "b" in d)
# → False True True
```

- `x in d` 只看 key，所以 `2 in d` 是 False。
- 要查 value 可以寫 `x in d.values()`，但這是從頭一個一個比，O(n)，跟在 list 裡找一樣慢。

所以設計 dict 時要反過來想：==之後要「查」的東西當 key，查到之後要「拿」的東西當 value==。
這樣查詢永遠是 O(1)。

### 走訪

```python
d = {"a": 2, "b": 2}
for k, v in d.items():
    print(k, v)
# → a 2
# → b 2

print(list(d.keys()), list(d.values()))
# → ['a', 'b'] [2, 2]
```

- `for k in d:` 只拿 key。
- dict 會保持加入的順序。
- 走訪時不能新增或刪除 key，否則會報錯；要刪除就先收集起來，迴圈結束後再刪。

### 計數的寫法

```python
cnt = {}
for ch in "hello":
    cnt[ch] = cnt.get(ch, 0) + 1
print(cnt)
# → {'h': 1, 'e': 1, 'l': 2, 'o': 1}
```

`get(ch, 0)` 讓第一次出現時從 0 開始算。
同樣的事用 `Counter` 一行就能做到。

### key 必須是不可修改的值

```python
print({(0, 1): "pos"}[(0, 1)])
# → pos                          tuple 可以當 key

{[0, 1]: "x"}
# → TypeError: cannot use 'list' as a dict key (unhashable type: 'list')
```

可以當 key 的：`int`、`str`、`tuple`（裡面也都是不可修改的值）。
不行的：`list`、`dict`、`set`。
set 的元素也是同樣規則。

錯誤訊息裡的 unhashable：dict 和 set 靠 hash 值找位置，會變動的值算不出固定的 hash，所以不能放。
原理在 `Data_Structure/`。

---

## set

```python
s = {1, 2}
s.add(3); s.add(2); print(s)    # 重複的不會加進去
# → {1, 2, 3}

s.discard(9); print(s)    # 不存在也不會報錯
# → {1, 2, 3}

s.remove(9)    # 不存在會報錯
# → KeyError: 9

print(2 in s, len(s))
# → True 3

print(set([1, 1, 2]))    # 去重
# → {1, 2}
```

`add`、`remove`、`in` 平均都是 O(1)，所以「這個值看過沒有」一律用 set，例如 `visited`。

集合運算：

```python
print({1, 2, 3} & {2, 3, 4}, {1, 2} | {3}, {1, 2, 3} - {2})
# → {2, 3} {1, 2, 3} {1, 3}       交集、聯集、差集
```

**建立空 set 要用 `set()`**，`{}` 是空 dict：

```python
print(type({}), type(set()))
# → <class 'dict'> <class 'set'>
```

set 沒有順序，不能用 index 取值。

---

## collections 模組

要先 import：`from collections import Counter, defaultdict, deque`。

### Counter：計數

```python
from collections import Counter

c = Counter("hello")
print(c)
# → Counter({'l': 2, 'h': 1, 'e': 1, 'o': 1})

print(c["l"], c["z"])
# → 2 0              不存在的 key 回傳 0，不會報錯

print(c.most_common(1))
# → [('l', 2)]       出現最多的前 1 名

print(Counter("abc") == Counter("cba"))
# → True             判斷兩個字串的字元組成一樣（Anagram 類題目）
```

`Counter` 本身就是一種 dict，dict 的操作（`items()`、`in`、`del`）都能用。

### defaultdict：key 不存在時自動建立

```python
from collections import defaultdict

g = defaultdict(list)       # 不存在的 key，自動給一個空 list
g["a"].append(1)
print(g)
# → defaultdict(<class 'list'>, {'a': [1]})
```

一般 dict 要先檢查 key 存不存在才能 `append`，`defaultdict(list)` 省掉這一步。
最常用在建立圖的鄰接表和分組。

括號裡放的是「建立預設值的方式」：

| 寫法 | 預設值 | 用途 |
|------|--------|------|
| `defaultdict(list)` | `[]` | 鄰接表、分組 |
| `defaultdict(int)` | `0` | 計數 |
| `defaultdict(set)` | `set()` | 不重複的分組 |

```python
dc = defaultdict(int)
dc["x"] += 1
print(dc)
# → defaultdict(<class 'int'>, {'x': 1})
```

陷阱：只是==讀取==不存在的 key，也會把它建立起來：

```python
print(g["zzz"])
# → []

print(g)
# → defaultdict(<class 'list'>, {'a': [1], 'zzz': []})     ← 多了 'zzz'
```

只想判斷有沒有這個 key，要用 `"zzz" in g`，不會建立。

### deque：兩端都能快速進出的 Queue

```python
from collections import deque

q = deque([1, 2])
q.append(3)          # 加到右邊
q.appendleft(0)      # 加到左邊
print(q)
# → deque([0, 1, 2, 3])

print(q.popleft(), q.pop(), q)
# → 0 3 deque([1, 2])

print(len(q), q[0], q[-1], bool(deque()))
# → 2 1 2 False
```

| 操作 | 複雜度 |
|------|--------|
| `append`、`appendleft`、`pop`、`popleft` | O(1) |
| `q[0]`、`q[-1]` | O(1) |
| `q[i]`（中間） | O(n) |

**BFS 一律用 deque**：`append` 放進去、`popleft` 拿出來，迴圈條件寫 `while q:`。

---

## heapq：每次取出最小值

Python 的 heap 不是一個類別，而是用一般 list 搭配 `heapq` 的函式來操作：

```python
import heapq

h = []
for v in [5, 1, 3]:
    heapq.heappush(h, v)
print(h, h[0])
# → [1, 5, 3] 1          h[0] 永遠是最小值；list 其他位置不是排序好的

print(heapq.heappop(h), h)
# → 1 [3, 5]
```

| 操作 | 說明 | 複雜度 |
|------|------|--------|
| `heapq.heappush(h, x)` | 放入 | O(log n) |
| `heapq.heappop(h)` | 取出最小值 | O(log n) |
| `h[0]` | 看最小值但不取出 | O(1) |
| `heapq.heapify(a)` | 把現有的 list 直接整理成 heap | O(n) |

```python
arr = [5, 2, 8, 1]
heapq.heapify(arr)       # 原地整理，不回傳
print(arr)
# → [1, 2, 8, 5]
```

### 要取最大值：存負數

`heapq` 預設是 min-heap。
要 max-heap 的通用做法是==放進去時加負號，取出來再加負號==：

```python
mh = []
for v in [5, 1, 3]:
    heapq.heappush(mh, -v)
print(-heapq.heappop(mh))
# → 5
```

Python 3.14 新增了 `heappush_max`、`heappop_max`、`heapify_max` 這組 max-heap 函式，本機可以用。
但 LeetCode 上的 Python 版本可能比較舊，不一定支援 `[待確認]`，所以寫題時用負數最保險。

### 放 tuple：依優先權排序

heap 會用 tuple 的第一個值比大小，一樣時才比第二個：

```python
th = []
heapq.heappush(th, (2, "b"))
heapq.heappush(th, (1, "a"))
print(heapq.heappop(th))
# → (1, 'a')
```

Dijkstra 放 `(距離, 節點)`、Top K Frequent 放 `(次數, 元素)` 都是這種用法。

注意：第一個值相同時會比第二個值，第二個值如果是不能比較大小的東西（例如自訂物件、`ListNode`）就會報錯。
這時在中間多放一個不會重複的數字（例如 index）：`(距離, index, 節點)`。

### 直接拿前 K 個

```python
print(heapq.nlargest(2, [5, 1, 3]), heapq.nsmallest(2, [5, 1, 3]))
# → [5, 3] [1, 3]
```

---

## bisect：在排序好的 list 裡找位置

```python
import bisect

sa = [1, 3, 3, 5]
print(bisect.bisect_left(sa, 3), bisect.bisect_right(sa, 3),
      bisect.bisect_left(sa, 4), bisect.bisect_left(sa, 9))
# → 1 3 3 4
```

| 函式 | 回傳 | 例子（`[1, 3, 3, 5]`） |
|------|------|------------------------|
| `bisect_left(a, x)` | 第一個 **≥ x** 的位置 | 找 3 → `1` |
| `bisect_right(a, x)` | 第一個 **> x** 的位置 | 找 3 → `3` |
| 找不到比 x 大的 | `len(a)` | 找 9 → `4` |

- 兩個都是 O(log n)。
- 判斷 `x` 在不在裡面：`i = bisect_left(a, x)`，再檢查 `i < len(a) and a[i] == x`。
- `bisect_right(a, x) - bisect_left(a, x)` 就是 `x` 出現的次數。
- ==list 必須已經排序==，否則結果沒有意義。

插入並保持排序：

```python
bisect.insort(sa, 4)
print(sa)
# → [1, 3, 3, 4, 5]
```

`insort` 找位置是 O(log n)，但插入要搬動後面的元素，整體是 O(n)。

LeetCode 的 Binary Search 題目通常是要你自己寫二分搜尋，`bisect` 是在「二分只是其中一步」的題目裡拿來用的。

---

## 複雜度總表

| 操作 | list | dict / set | deque | heap |
|------|------|-----------|-------|------|
| 尾端加入 / 取出 | O(1) | — | O(1) | — |
| 開頭加入 / 取出 | **O(n)** | — | O(1) | — |
| 用 index 取值 | O(1) | — | 兩端 O(1)，中間 O(n) | — |
| `x in ...` | **O(n)** | O(1) | O(n) | — |
| 放入 / 取出最小 | — | — | — | O(log n) |
| 看最小值 | — | — | — | O(1)（`h[0]`） |

dict / set 的 O(1) 是平均情況。

---

## 常見錯誤速查

| 錯誤訊息或症狀 | 常見原因 |
|----------------|----------|
| `KeyError: 'z'` | 用 `d[key]` 取不存在的 key，改用 `d.get(key, 預設值)` 或先判斷 `in` |
| `KeyError`（set） | `s.remove(x)` 但 `x` 不在裡面，改用 `discard` |
| `TypeError: cannot use 'list' as a dict key (unhashable type: 'list')` | 用 list 當 key 或放進 set，改成 tuple |
| `TypeError: 'tuple' object does not support item assignment` | 想改 tuple 的值 |
| `RuntimeError: dictionary changed size during iteration` | 走訪 dict 時新增或刪除 key，先收集起來，迴圈結束後再改 |
| `TypeError: '<' not supported between instances of ...` | heap 裡的 tuple 第一個值相同，第二個值又不能比較，中間加一個 index |
| 二維 list 改一格、整欄都變了 | 用了 `[[0] * n] * m`，改成 `[[0] * n for _ in range(m)]` |
| 收集的答案最後全部一樣 | 把同一個 list 加進結果好幾次，改成加複本 `path[:]` |
| `x = nums.sort()` 得到 `None` | `.sort()` 不回傳，改用 `sorted(nums)` |
| `{}` 當成空 set 用 | `{}` 是 dict，空 set 要寫 `set()` |
| `defaultdict` 多出不該有的 key | 讀取不存在的 key 也會建立它，判斷存在改用 `in` |
| 程式太慢（TLE） | 在 list 上用 `in` 或 `pop(0)`，改用 set 或 deque |
