---
title: "[Python]  套件安裝與虛擬環境（venv）"
date: 2026-10-26 18:56 +0800
categories: ["Python", "Environment"]
tags: []
order: "000002_environment/000002.000001_package-install-and-venv.md"
image: {path: "/assets/img/covers/Python.png"}
source: DDAN_Usandbox/0_Personal/Python/2_Environment/2.1_Package-Install-and-venv.md
render_with_liquid: false
---

## Abstract

在 macOS 上用 Homebrew 裝的 Python 執行 `pip3 install pytest`，會被 `externally-managed-environment` 擋下來：Homebrew 的 Python 不讓 pip 直接裝東西進去。
解法是在專案裡建一個 venv，把套件裝在 venv 裡。

這篇從錯誤訊息開始，說明為什麼被擋、venv 怎麼建和怎麼用，最後是用在 LeetCode 的設定。
環境是 macOS、Homebrew 的 `Python 3.14.8`（`/opt/homebrew/bin/python3`）、pip 26.2.1。

---

## 問題：pip install 被擋

```sh
pip3 install pytest
```

```
error: externally-managed-environment

× This environment is externally managed
╰─> To install Python packages system-wide, try brew install
    xyz, where xyz is the package you are trying to
    install.

    If you wish to install a Python library that isn't in Homebrew,
    use a virtual environment:

    python3 -m venv path/to/venv
    source path/to/venv/bin/activate
    python3 -m pip install xyz

    If you wish to install a Python application that isn't in Homebrew,
    it may be easiest to use 'pipx install xyz', which will manage a
    virtual environment for you. You can install pipx with

    brew install pipx
```

錯誤訊息本身就列出了解法：用 venv，或是用 pipx。

---

## 為什麼會被擋

### EXTERNALLY-MANAGED 標記檔

Homebrew 在 Python 標準函式庫的資料夾裡放了一個檔案：

```
/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/3.14/lib/python3.14/EXTERNALLY-MANAGED
```

內容開頭：

```
[externally-managed]
Error=To install Python packages system-wide, try brew install
 xyz, where xyz is the package you are trying to
 install.
...
```

這是 Python 的標準機制 **PEP 668**：Python 底下如果有 `EXTERNALLY-MANAGED` 這個檔案，就代表「這個 Python 由別的工具管理」，pip 會拒絕往裡面裝東西，並印出檔案裡 `Error=` 後面的訊息。

找出自己的 Python 有沒有這個檔：

```sh
ls "$(python3 -c 'import sysconfig; print(sysconfig.get_path("stdlib"))')"/EXTERNALLY-MANAGED
```

### 為什麼要擋

這個 Python 是 Homebrew 裝的、歸 Homebrew 管。
如果再用 pip 往裡面裝：

1. **兩個工具改同一個地方**：Homebrew 自己也會在這個 Python 裡裝套件，pip 可能把它們換成不同版本，Homebrew 的東西就可能壞掉。
2. **升級就消失**：Homebrew 把 Python 從 3.14 升到 3.15 時，會換成新的資料夾，之前用 pip 裝的套件都不在新版本裡。

Linux 的 Debian、Ubuntu 也有同樣的機制，用系統 Python 跑 `pip install` 會看到一樣的錯誤。

---

## 解法比較

| 做法 | 指令 | 適合 | 缺點 |
|------|------|------|------|
| **venv** | `python3 -m venv .venv` | 專案要長期用的套件（例如 pytest） | 要記得用 venv 裡的 Python |
| **uv 臨時帶入** | `uv run --no-project --with pytest pytest ...` | 偶爾跑一下，不想建環境 | 指令長 |
| pipx | `pipx install xxx` | 裝成命令列工具來用（例如 `black`、`httpie`） | 不適合 pytest 這種要跟自己的程式一起執行的套件 |
| `--break-system-packages` | `pip3 install --break-system-packages xxx` | — | **不要用** |

---

## venv 是什麼

**venv（virtual environment）是一個專屬某個專案的 Python 環境**：一個資料夾，裡面有自己的 `python` 和自己的套件目錄。
在 venv 裡裝的套件只存在這個資料夾，不會動到 Homebrew 的 Python。

### 建立

```sh
cd 0_Personal/Leetcode
python3 -m venv .venv
```

`.venv` 是資料夾名稱，可以自己取，`.venv` 是慣例。
建立後的內容：

```
.venv/
├ bin/
│ ├ activate          ← 啟用 venv 用的 script
│ ├ pip、pip3
│ └ python、python3、python3.14
├ include/
├ lib/                ← 之後裝的套件放在 lib/python3.14/site-packages/
└ pyvenv.cfg
```

`bin/` 裡的 `python` 不是複製一份，而是**連結**回 Homebrew 的 Python：

```
.venv/bin/python -> python3.14
.venv/bin/python3 -> python3.14
.venv/bin/python3.14 -> /opt/homebrew/opt/python@3.14/bin/python3.14
```

`pyvenv.cfg` 記錄這個 venv 是用哪個 Python 建的：

```
home = /opt/homebrew/opt/python@3.14/bin
include-system-site-packages = false
version = 3.14.8
executable = /opt/homebrew/Cellar/python@3.14/3.14.8/Frameworks/Python.framework/Versions/3.14/bin/python3.14
command = /opt/homebrew/opt/python@3.14/bin/python3.14 -m venv /Users/shawn_yu/DDAN_Usandbox/0_Personal/Leetcode/.venv
```

`include-system-site-packages = false`：venv 裡**看不到** Homebrew Python 裝的套件，只有自己裝的。

### Python 怎麼知道自己在 venv 裡

執行 `.venv/bin/python` 時，Python 會在上一層找到 `pyvenv.cfg`，就把套件目錄換成 venv 自己的。
可以用 `sys.prefix` 確認：

```sh
.venv/bin/python -c 'import sys; print(sys.prefix); print(sys.base_prefix); print(sys.executable)'
```

```
/Users/shawn_yu/DDAN_Usandbox/0_Personal/Leetcode/.venv
/opt/homebrew/opt/python@3.14/Frameworks/Python.framework/Versions/3.14
/Users/shawn_yu/DDAN_Usandbox/0_Personal/Leetcode/.venv/bin/python
```

| 變數 | 意思 |
|------|------|
| `sys.prefix` | 目前環境的位置，在 venv 裡就是 venv 資料夾 |
| `sys.base_prefix` | 背後真正的 Python 安裝位置 |

兩個不一樣，就代表現在在 venv 裡。

### 在 venv 裡裝套件

```sh
.venv/bin/python -m pip install pytest
```

```
Installing collected packages: pygments, pluggy, packaging, iniconfig, pytest

Successfully installed iniconfig-2.3.1 packaging-26.3 pluggy-1.6.0 pygments-2.21.0 pytest-9.1.1
```

pytest 依賴的其他套件也會一起裝。
裝完的清單：

```sh
.venv/bin/python -m pip list
```

```
Package   Version
--------- -------
iniconfig 2.3.1
packaging 26.3
pip       26.2.1
pluggy    1.6.0
Pygments  2.21.0
pytest    9.1.1
```

系統的 Python 還是沒有 pytest，兩邊互不影響：

```sh
python3 -c 'import pytest'
```

```
ModuleNotFoundError: No module named 'pytest'
```

### 為什麼寫 `python -m pip`，不直接寫 `pip`

`python -m pip` 的意思是「用**這個** python 執行 pip 模組」，套件一定裝進這個 python 對應的環境。
直接打 `pip`，用的是 PATH 上找到的第一個 pip，不一定是你以為的那個。
電腦上有多個 Python 時，`python -m pip` 比較不會裝錯地方。
`python -m pytest` 也是同樣道理。

---

## activate：讓 `python` 直接指向 venv

每次都打 `.venv/bin/python` 很長。
`activate` 會修改目前這個 terminal 的 `PATH`，把 `.venv/bin` 放在最前面，之後打 `python3`、`pytest` 就會先找到 venv 裡的：

```sh
which python3
source .venv/bin/activate
which python3
which pytest
echo $VIRTUAL_ENV
deactivate
which python3
```

```
/opt/homebrew/bin/python3                                                  ← 啟用前：Homebrew 的
/Users/shawn_yu/DDAN_Usandbox/0_Personal/Leetcode/.venv/bin/python3        ← 啟用後：venv 的
/Users/shawn_yu/DDAN_Usandbox/0_Personal/Leetcode/.venv/bin/pytest
/Users/shawn_yu/DDAN_Usandbox/0_Personal/Leetcode/.venv                    ← VIRTUAL_ENV 變數
/opt/homebrew/bin/python3                                                  ← deactivate 後恢復
```

- `source .venv/bin/activate`：啟用，terminal 提示字元前面通常會多出 `(.venv)`。
- `deactivate`：恢復原狀。
- **只對目前這個 terminal 有效**，開新的 terminal 要重新 `source`。
- 不想 activate，就直接寫完整路徑：`.venv/bin/python -m pytest ...`，效果一樣。

VS Code 也要指定用這個 venv，不然編輯器會說找不到 `pytest`（`import pytest` 下面出現波浪線）。
做法：`Cmd+Shift+P` → `Python: Select Interpreter` → 選 `.venv` 裡的 Python。

---

## 不要把 venv commit 進 git

venv 裡的連結指向**這台電腦**的 Python 路徑，換一台電腦就不能用；而且裝的套件可以隨時重裝。
所以 `.venv/` 要加進 `.gitignore`。

`0_Personal/Leetcode/.gitignore`：

```
.venv/
__pycache__/
.pytest_cache/
```

| 項目 | 是什麼 |
|------|--------|
| `.venv/` | 虛擬環境 |
| `__pycache__/` | Python 把 `.py` 編譯成 bytecode 的快取（`.pyc`），執行時自動產生 |
| `.pytest_cache/` | pytest 記錄上次執行結果的快取 |

確認被忽略：`git status` 裡不會出現 `.venv/`。

### `__pycache__` 是什麼

Python 執行 `.py` 前會先把它編譯成 bytecode。
**被 import 的檔案**，Python 會把編譯結果存進同一層的 `__pycache__/`，下次檔案沒改就直接用，省下重新編譯的時間。

pytest 跑測試時會 import `Solution.py`，所以跑完題目資料夾裡就多了：

```
_001_Two_Sum/__pycache__/Solution.cpython-314-pytest-9.1.1.pyc
```

檔名的 `cpython-314` 是 Python 3.14 產生的；多了 `pytest-9.1.1` 是因為 pytest 會改寫 `assert` 好印出詳細的比較結果，所以存成另一個版本。

它只是快取：刪掉沒關係，下次執行會再產生。
git 已經在 `.gitignore` 排除了。

### 讓 VS Code 不顯示

`DDAN_Usandbox/.vscode/settings.json`：

```json
{
    "files.exclude": {
        "**/__pycache__": true,
        "**/.pytest_cache": true
    }
}
```

`files.exclude` 只是讓 VS Code 的檔案總管**不顯示**，資料夾還在硬碟上。
`**/` 代表任何一層底下的同名資料夾。
這個設定放在工作區的 `.vscode/` 裡，只影響這個工作區。

換電腦或 venv 壞掉時，直接刪掉重建：

```sh
rm -rf .venv
python3 -m venv .venv
.venv/bin/python -m pip install pytest
```

---

## 另一個選擇：uv 臨時帶入套件

`uv` 是另一套 Python 套件管理工具，這台電腦已經用 Homebrew 裝好。
它可以**不建 venv**，臨時把套件帶進來執行一次：

```sh
uv run --no-project --with pytest pytest test_add_demo.py -v
```

```
test_add_demo.py::test_add[positive] PASSED                              [ 33%]
test_add_demo.py::test_add[negative] PASSED                              [ 66%]
test_add_demo.py::test_add[wrong_on_purpose] FAILED                      [100%]
...
========================= 1 failed, 2 passed in 0.01s ==========================
```

| 參數 | 意思 |
|------|------|
| `--with pytest` | 這次執行需要 pytest |
| `--no-project` | 不要把目前資料夾當成 uv 專案（沒有 `pyproject.toml` 時加上） |

第一次會下載 pytest 放進 uv 的快取，之後就直接用快取。
適合偶爾跑一次；每天都用的話，venv 比較方便。

---

## 用在 LeetCode

### 測試直接寫在 Solution.py

不用另外開測試檔，解答和測試放在同一個檔案：

```python
import pytest

class Solution:
    def add(self, a, b):
        return a + b

@pytest.mark.parametrize("a, b, expected", [
    pytest.param(1, 2, 3, id="positive"),
    pytest.param(-1, 1, 0, id="negative"),
])
def test_add(a, b, expected):
    assert Solution().add(a, b) == expected
```

- 測試函式要放在 `class` **外面**（不要縮排），名稱用 `test_` 開頭。
- 同一個檔案裡，直接用 `Solution()` 就好，不用 import。
- 交到 LeetCode 時只複製 `class Solution` 的部分。

### 執行：一定要指定檔案

```sh
cd 0_Personal/Leetcode
.venv/bin/python -m pytest _999_Demo/Solution.py -v
```

```
_999_Demo/Solution.py::test_add[positive] PASSED                         [ 50%]
_999_Demo/Solution.py::test_add[negative] PASSED                         [100%]

============================== 2 passed in 0.01s ===============================
```

只指定資料夾的話，什麼都不會跑：

```sh
.venv/bin/python -m pytest _999_Demo/ -q
```

```
no tests ran in 0.00s
```

原因：pytest **自動搜尋**時，只收集檔名符合 `test_*.py` 或 `*_test.py` 的檔案，`Solution.py` 不符合；但**直接指定的檔案**不受這個規則限制，裡面的 `test_` 函式都會被收集。

如果沒有做下面的設定，直接 `python3 Solution.py` 執行不會跑測試：檔案裡只有定義 class 和函式，沒有人去呼叫測試函式，所以什麼都不會發生（exit code 0，沒有任何輸出），看起來像是通過了，其實根本沒測。

#### 按 VS Code 的 ▶ 就能跑測試

在 `Solution.py` 最下面加：

```python
if __name__ == "__main__":
    pytest.main([__file__, "-v"])
```

- `pytest.main([...])`：在程式裡呼叫 pytest，list 裡放的就是命令列參數。
- `__file__`：這個檔案自己的路徑。
- 直接執行檔案（按 ▶ 或 `.venv/bin/python Solution.py`）時，`__name__ == "__main__"` 成立，就會跑 pytest；被 pytest 或 LeetCode 載入時不會執行。

實際用 venv 的 Python 執行：

```
.../_999_Demo/Solution.py::test_add[positive] PASSED [ 50%]
.../_999_Demo/Solution.py::test_add[negative] PASSED [100%]

============================== 2 passed in 0.01s ===============================
```

▶ 用的是 VS Code 選的 interpreter，**要先選 `.venv`**。
如果選的還是系統的 Python，會出現：

```
ModuleNotFoundError: No module named 'pytest'
```

**一定要放最下面嗎？
** 不一定，但要放在 `import pytest` **後面**。
實際測試：

- 放在 class 上面也能跑（`1 passed`）。
  因為 `pytest.main` 不會用「現在執行到一半的這份程式」，而是**自己重新載入整個檔案**再收集測試，所以這時 class 和測試函式有沒有定義好都沒關係。
- 放在 `import pytest` 前面就會失敗，因為程式由上往下執行，跑到這裡時 `pytest` 還不存在：
  ```
  NameError: name 'pytest' is not defined. Did you mean: 'bytes'?
  ```

慣例還是**放在最下面**：上面放定義，最下面放「直接執行時要做的事」，大家一看就知道這是程式的進入點。

### 另一種放法：獨立的 test_solution.py

如果想把測試分開：

```
_001_Two_Sum/
├ Solution.py
└ test_solution.py      ← from Solution import Solution
```

這樣就可以只指定資料夾（`pytest _001_Two_Sum/`）。
`from Solution import Solution` 能 import，是因為 pytest 會把**測試檔所在的資料夾**加進 `sys.path`（資料夾裡沒有 `__init__.py` 時的預設行為）。

但每題都叫 `test_solution.py`，在 `Leetcode/` 一次跑全部題目會出錯：

```
import file mismatch:
imported module 'test_solution' has this __file__attribute:
  .../_998_Other/test_solution.py
which is not the same as the test file we want to collect:
  .../_999_Demo/test_solution.py
HINT: remove __pycache__ / .pyc files and/or use a unique basename for your test file modules
```

兩個資料夾的測試檔被當成同一個模組名稱 `test_solution`，Python 同一個模組名稱只會載入一次，所以第二個對不上。
改用 `--import-mode=importlib` 也不行，這個模式不會把測試檔的資料夾加進 `sys.path`，會變成 `ModuleNotFoundError: No module named 'Solution'`。

LeetCode 一次寫一題，**測試直接寫在 `Solution.py` 最簡單**。
