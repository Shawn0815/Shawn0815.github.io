---
title: "基本語法"
date: 2026-10-26 11:43 +0800
categories: ["Languages", "Python"]
tags: ["Python"]
image: {path: "/assets/img/covers/Python.png"}
source: DDAN_Usandbox/0_Personal/Python/1_Basics/1.1_Basic-Syntax.md
---

## Abstract

用 Python 寫 LeetCode 必須會的語法，以及容易寫錯的地方：程式結構、型別、縮排、運算子、真假值、條件與迴圈、函式、字串。

範例都在本機 `Python 3.14.8` 跑過，程式碼區塊裡 `# →` 後面是實際執行的輸出。

---

## 程式結構：LeetCode 模板與本機執行

LeetCode 給的模板：

```python
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        ...
```

- `class Solution:` 定義一個類別，`def` 定義方法。
- **`self` 是方法的第一個參數**，代表這個物件本身。在方法裡呼叫同一個類別的其他方法要寫 `self.helper()`。呼叫 `twoSum` 時不用傳 `self`，Python 會自動帶入。
- `nums: List[int]`、`-> List[int]` 是 type hints，見下面 2.4。
- `...` 是佔位用的語法，等於「這裡還沒寫」。

### 建立物件、呼叫方法

```python
sol = Solution()                 # class 名稱加 () 就是建立物件，不需要其他關鍵字
result = sol.twoSum([2, 7, 11, 15], 9)

result = Solution().twoSum([2, 7, 11, 15], 9)    # 同一件事寫成一行
```

一行的寫法是「建立物件後馬上呼叫方法」，物件沒有存進變數。物件只用一次就寫一行；同一個物件要用好幾次時才存成變數。

### 本機測試

本機測試用 pytest，測試直接寫在 `Solution.py` 裡，按 VS Code 的 ▶ 就能跑。

### `if __name__ == "__main__":`

檔案最下面常見的這段：

```python
if __name__ == "__main__":
    ...
```

**意思**：每個 Python 檔案都有一個內建變數 `__name__`。直接執行這個檔案時，它的值是 `"__main__"`；被別的檔案 `import` 時，它的值是模組名稱。所以這段測試只會在直接執行時跑，被 import 時不會跑。

```python
print(__name__)
# → __main__
```

工作上的 code 也會看到這個寫法，意思一樣。

---

## 變數與型別

### 不用宣告型別

```python
x = 5
x = "now a string"    # 同一個變數可以換成別種值
```

Python 是**動態型別**：變數只是一個名字，型別屬於值。用 `type()` 看值的型別：

```python
print(type(10), type(3.5), type("a"), type(True), type(None))
# → <class 'int'> <class 'float'> <class 'str'> <class 'bool'> <class 'NoneType'>
```

| 型別 | 例子 | 說明 |
|------|------|------|
| `int` | `10`、`-3` | 整數，沒有大小上限 |
| `float` | `3.5`、`float("inf")` | 浮點數 |
| `str` | `"abc"`、`'abc'` | 字串，單引號雙引號一樣 |
| `bool` | `True`、`False` | 大寫開頭 |
| `None` | `None` | 「沒有值」 |

### int 沒有上限

```python
print(2 ** 100)      # ** 是次方
# → 1267650600228229401496703205376
```

Python 的整數會自動變大，不會 overflow，所以「答案很大」的題目不用特別處理型別。但題目要求「回傳 mod 10^9+7」時，還是要自己 `%`。

### 無限大

找最小值時，初始值常設成無限大：

```python
min_val = float("inf")
print(float("inf") > 10**18, -float("inf"))
# → True -inf
```

最大值的初始值就用 `-float("inf")`。

### Type hints：只是註解

```python
def add(a: int, b: int) -> int:
    return a + b

print(add("a", "b"))
# → ab          ← 傳字串也照跑，不會報錯
```

`a: int`、`-> int` 是給人和工具（編輯器、檢查器）看的提示，**執行時不檢查**。可寫可不寫。

LeetCode 模板的 `List[int]` 來自 `typing` 模組。LeetCode 網站已經 import 好了；本機要自己加 `from typing import List`，不然會出現 `NameError: name 'List' is not defined`。也可以直接寫小寫的 `list[int]`，不用 import。

### 變數名稱不要用內建名稱 ⚠️

`dict`、`list`、`set`、`str`、`sum`、`max`、`min`、`len` 這些都是 Python 內建的名字。拿來當變數名稱不會報錯，但從那之後，這個名字就變成你的變數，原本的功能就不能用了：

```python
dict = {}
dict(a=1)
# → TypeError: 'dict' object is not callable

list = [1, 2]
list("abc")
# → TypeError: 'list' object is not callable
```

建立空容器用 `{}`、`[]` 不會用到這些名字，所以 `dict = {}` 這行本身能跑。出問題的是之後的**轉換**，例如 `list("abc")` 把字串轉成 list、`list(d.keys())`，錯誤訊息又看不出原因，很難查。

變數名稱取「它存了什麼」，例如 `seen`、`count`、`index_of`，讀的人也比較好懂。

### 編輯器裡變灰色的變數

VS Code 的 Python 擴充（Pylance）會把**有定義、但後面沒有用到**的變數顯示成灰色：

```python
seen = {}                      # 後面還沒用到 → 灰色
complement = target - num      # 後面還沒用到 → 灰色
```

後面的程式用到它之後，就會變回正常顏色。其他會變灰的：import 了但沒用到的模組、寫在 `return` 後面永遠執行不到的程式碼。

看到灰色可以順便檢查：是不是忘了用某個變數，或這個變數根本多餘。

---

## 縮排就是區塊

Python 用 **`:` 加縮排**表示區塊，沒有大括號。縮排錯了就是語法錯誤。慣例是 4 個空白。

```python
if x > 0:
    print("positive")     # if 的區塊
    x -= 1                # 還在 if 裡
print("done")             # 縮排回來，離開 if
```

區塊不能是空的。還沒想好要寫什麼時，用 `pass` 佔位：

```python
if x > 0:
    pass
```

---

## 運算子

### 算術

| 運算子 | 意思 | 例子 |
|--------|------|------|
| `+` `-` `*` | 加減乘 | |
| `/` | 除法，**結果一定是 float** | `7 / 2` → `3.5` |
| `//` | 整數除法，**往負無限大取整** | `7 // 2` → `3`，`-7 // 2` → `-4` |
| `%` | 餘數，**正負號跟著除數** | `-7 % 2` → `1` |
| `**` | 次方 | `2 ** 10` → `1024` |

```python
print(7 // 2, -7 // 2, 7 / 2)
# → 3 -4 3.5

print(-7 % 2, 7 % -2)
# → 1 -1

print(int(-7 / 2))
# → -3
```

要注意的幾點：

- **整數除法一律用 `//`**。用 `/` 會得到 float，拿去當 index 會報錯。
- `//` 是往**負無限大**取整，所以 `-7 // 2` 是 `-4`，不是 `-3`。只有正數時（例如 Binary Search 的 `(left + right) // 2`）不會有差別。
- 需要「往 0 取整」時寫 `int(a / b)`，例如 `-7` 除以 `2` 要得到 `-3`（LeetCode 150 Evaluate Reverse Polish Notation 就要這樣）。
- `%` 的結果正負號跟除數一樣，所以 `-7 % 2` 是 `1`。「取最後一位數」「判斷奇偶」只要處理正數就不會出問題。

### 遞增：沒有 `++`

```python
i += 1     # 正確
i -= 1
i++        # SyntaxError
```

### 邏輯：`and` / `or` / `not`

```python
if not visited and 0 <= r < rows:
    ...
```

用英文單字，沒有符號版本。

### 比較：`==` 和 `is`

- `==`：比較**值是否相等**
- `is`：比較**是不是同一個物件**

```python
a = [1, 2]
b = [1, 2]
print(a == b, a is b)
# → True False       ← 內容一樣，但是兩個不同的 list
```

**判斷 `None` 一律用 `is`**：`if node is None:`、`if node is not None:`。這是 Python 的慣例，工作上的 code 也都這樣寫。其他情況用 `==`。

### 連續比較

比較可以串在一起，檢查 index 有沒有越界很好用：

```python
i, n = 3, 5
print(0 <= i < n)       # 等於 0 <= i and i < n
# → True
```

走格子（BFS / DFS）時常寫成 `0 <= r < rows and 0 <= c < cols`。

### 條件運算式（一行的 if-else）

```python
print("even" if i % 2 == 0 else "odd")
# → odd
```

順序是「**值 if 條件 else 另一個值**」。

---

## 真假值（Truthiness）

`if` 和 `while` 後面可以放任何值，不一定要是 `True` / `False`。以下這些都當作 **False**，其他都是 True：

```python
for v in [None, False, 0, 0.0, "", [], {}, set(), "0", [0]]:
    print(repr(v), bool(v))
# → None False
# → False False
# → 0 False
# → 0.0 False
# → '' False
# → [] False
# → {} False
# → set() False
# → '0' True       ← 非空字串
# → [0] True       ← 非空 list
```

規則：**`None`、`False`、數字 `0`、空的容器**是 False。

所以檢查空不空，直接寫：

```python
if stack:          # stack 不是空的
if not stack:      # stack 是空的
if not s:          # 字串是空的
while queue:       # queue 還有東西就繼續
```

**陷阱**：數字 `0` 也是 False。變數可能是 `0`、也可能是 `None` 時，要寫 `is None` 才分得出來：

```python
idx = d.get(key)        # 找不到是 None，找到可能是 0
if idx:                 # ❌ idx == 0 時也進不來
    ...
if idx is not None:     # ✅
    ...
```

---

## 條件與迴圈

### if / elif / else

```python
if x > 0:
    ...
elif x < 0:
    ...
else:
    ...
```

`elif` 是 else if 的縮寫，寫成 `else if` 會報錯。

### for：逐一取出序列的值

Python 的 `for` 一律是「**從一個序列裡逐一取值**」：

```python
for x in nums:          # 逐一取出 list 的元素
for ch in s:            # 逐一取出字串的字元
for key in d:           # 逐一取出 dict 的 key
```

需要用數字（index）跑迴圈時，用 `range()` 產生一串數字：

```python
print(list(range(5)), list(range(2, 8, 2)), list(range(4, -1, -1)))
# → [0, 1, 2, 3, 4] [2, 4, 6] [4, 3, 2, 1, 0]
```

| 寫法 | 產生 | 用途 |
|------|------|------|
| `range(n)` | `0, 1, …, n-1` | 跑 index |
| `range(a, b)` | `a, …, b-1` | 指定起點 |
| `range(a, b, step)` | 每次加 `step` | 跳著走 |
| `range(n - 1, -1, -1)` | `n-1, …, 0` | 倒著走 |

**`range` 不包含結尾**。倒著走到 0 時，結尾要寫 `-1`。

### enumerate：同時要 index 和值

```python
for idx, val in enumerate(["a", "b", "c"]):
    print(idx, val)
# → 0 a
# → 1 b
# → 2 c
```

需要 index 又需要值時，用 `enumerate` 比 `for i in range(len(nums)):` 再寫 `nums[i]` 更簡潔。**寫題很常用。**

### zip：兩個序列一起走

```python
for p, q in zip([1, 2, 3], ["x", "y"]):
    print(p, q)
# → 1 x
# → 2 y       ← 以短的為準，3 被丟掉
```

### while、break、continue

```python
while left <= right:
    ...
    if found:
        break       # 跳出迴圈
    if skip:
        continue    # 直接進下一輪
```

Python 沒有 do-while。要「至少跑一次」時，寫 `while True:`，在裡面判斷後 `break`。

### for-else

`for` 後面可以接 `else`：**迴圈正常跑完、沒有被 `break` 中斷**時才執行。

```python
for v in [1, 3, 5]:
    if v % 2 == 0:
        print("found even")
        break
else:
    print("no even")
# → no even
```

寫題不一定會用，但讀 code 看到時要知道：這個 `else` 是配 `for` 的，不是配 `if`。

---

## 函式

### 定義與回傳多個值

```python
def min_max(nums):
    return min(nums), max(nums)

lo, hi = min_max([3, 1, 4])
print(lo, hi, min_max([3, 1, 4]))
# → 1 4 (1, 4)
```

- 用 `def` 定義，不用寫回傳型別。
- **可以一次回傳多個值**：實際上回傳的是一個 tuple `(1, 4)`，接收時用多個變數拆開（unpacking，細節在 1.3）。

### 交換兩個變數

```python
p, q = 1, 2
p, q = q, p
print(p, q)
# → 2 1
```

不需要暫存變數。Two Pointers 交換兩個位置：`nums[l], nums[r] = nums[r], nums[l]`。

### 函式裡的函式（DFS 常用）

函式裡可以再定義函式，內層函式可以直接**讀**外層的變數：

```python
def num_islands(grid):
    rows, cols = len(grid), len(grid[0])

    def dfs(r, c):          # 讀得到 grid、rows、cols
        ...

    ...
```

內層要**重新賦值**外層的變數（例如 `count += 1`）時，要先宣告 `nonlocal`，否則會報錯：

```python
def outer():
    count = 0

    def inner():
        count += 1          # ❌
    inner()
# → UnboundLocalError: cannot access local variable 'count' where it is not associated with a value

def outer():
    count = 0

    def inner():
        nonlocal count      # ✅ 告訴 Python：count 是外層的那個
        count += 1
    inner()
    print(count)
# → 1
```

只是**修改內容**（`visited.add(x)`、`result.append(x)`）不算重新賦值，不需要 `nonlocal`。

### 預設參數的陷阱 ⚠️

```python
def append_to(x, bucket=[]):
    bucket.append(x)
    return bucket

print(append_to(1), append_to(2))
# → [1, 2] [1, 2]       ← 第二次呼叫還留著第一次的 1
```

預設值只在**定義函式時建立一次**。預設值是 list、dict 這種可修改的物件時，每次呼叫都會共用同一個。

正確寫法：預設值用 `None`，在函式裡才建新的：

```python
def append_ok(x, bucket=None):
    if bucket is None:
        bucket = []
    bucket.append(x)
    return bucket

print(append_ok(1), append_ok(2))
# → [1] [2]
```

工作上的 code 看到 `def f(x, items=None):` 接著 `if items is None:`，就是在避開這個陷阱。

---

## 字串

### 取值與切片

```python
s = "hello"
print(s[0], type(s[0]), s[-1], s[1:3], s[::-1], len(s))
# → h <class 'str'> o el olleh 5
```

| 寫法 | 結果 | 說明 |
|------|------|------|
| `s[0]` | `'h'` | 第一個字元。Python 沒有字元型別，取出來還是長度 1 的 `str` |
| `s[-1]` | `'o'` | 負數 index 從後面數，`-1` 是最後一個 |
| `s[1:3]` | `'el'` | 切片：從 index 1 到 3（不含 3） |
| `s[::-1]` | `'olleh'` | 反轉 |
| `len(s)` | `5` | 長度 |

切片的完整寫法是 `[start:stop:step]`，list 也通用，細節在 1.2。

### 字串不能修改

```python
s[0] = "H"
# → TypeError: 'str' object does not support item assignment
```

字串建立後就不能改。要逐字修改時，先轉成 list，改完再接回字串：

```python
chars = list("hello")
chars[0] = "H"
print("".join(chars))
# → Hello
```

`"".join(list)` 是把 list 裡的字串用 `""` 接起來。迴圈裡一直用 `s += ch` 也能跑，但每次都會建立新字串；量大時，先收集到 list，最後再 `join`。

### 字元和數字互轉

```python
print(ord("a"), chr(98), ord("c") - ord("a"))
# → 97 b 2
```

- `ord(ch)`：字元 → 編碼數字
- `chr(n)`：編碼數字 → 字元

`ord(ch) - ord("a")` 可以把 `a`～`z` 轉成 `0`～`25`，統計 26 個字母次數的題目常用。

### f-string：格式化

```python
name, cnt = "py", 3
print(f"{name} x {cnt} = {name * cnt}")
# → py x 3 = pypypy

print(f"{cnt=}")      # Debug 用：同時印出變數名和值
# → cnt=3
```

字串前面加 `f`，`{}` 裡可以放任何運算式。`"py" * 3` 是把字串重複 3 次。

工作上的 code 還會看到兩種舊寫法，結果一樣：

```python
print("%s-%d" % ("a", 1), "{}-{}".format("a", 1))
# → a-1 a-1
```

---

## 常見錯誤速查

| 錯誤訊息 | 常見原因 |
|----------|----------|
| `SyntaxError: invalid syntax` | 用了 Python 沒有的語法，例如 `i++`、`&&` |
| `SyntaxError: expected ':'` | `if`、`for`、`def` 後面忘了 `:`，或寫成 `else if`（要用 `elif`） |
| `IndentationError` | 縮排層級對不上，或 `:` 後面的區塊是空的（要寫 `pass`） |
| `TabError: inconsistent use of tabs and spaces` | 同一個區塊混用 tab 和空白；把編輯器設成一律用 4 個空白 |
| `TypeError: list indices must be integers or slices, not float` | 用 `/` 算 index，要改用 `//` |
| `TypeError: 'str' object does not support item assignment` | 想直接改字串，要先轉 list |
| `NameError: name 'List' is not defined` | 本機跑 LeetCode 模板沒有 `from typing import List` |
| `TypeError: 'dict' object is not callable`（或 `'list'`） | 前面把 `dict`、`list` 當成變數名稱，蓋掉了內建的名字 |
| `UnboundLocalError: cannot access local variable ...` | 內層函式重新賦值外層變數，要加 `nonlocal` |
| `IndexError: list index out of range` | index 越界，檢查 `range` 的邊界和 `len()` |
