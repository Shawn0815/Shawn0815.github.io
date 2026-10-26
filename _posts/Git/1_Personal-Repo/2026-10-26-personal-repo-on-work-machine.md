---
title: "[Git]  在工作電腦上使用個人 GitHub repo"
date: 2026-10-26 18:46 +0800
categories: ["Git", "Personal Repo"]
tags: []
order: "000001_personal-repo/000001.000001_personal-repo-on-work-machine.md"
image: {path: "/assets/img/covers/Git.png"}
source: DDAN_Usandbox/0_Personal/Git/1_Personal-Repo/1.1_Personal-Repo-on-Work-Machine.md
render_with_liquid: false
---

## Abstract

在工作電腦上 clone 個人的 GitHub repo，要 commit、push 回個人帳號時，會碰到兩個問題：這台電腦沒有設定 git 身分，以及 `gh` 和鑰匙圈登入的是工作帳號。

解法是 git 身分只設在這個 repo（`--local`），push 用個人帳號的 Personal Access Token，並把帳號名稱寫進 remote 網址，跟工作帳號的登入分開。
環境是 macOS、`git version 2.54.0 (Apple Git-157)`。

---

## 先看現況

```sh
cd 0_Personal/Leetcode
git config --global user.name;  git config --global user.email
git config --local user.name;   git config --local user.email
git remote -v
git config --get credential.helper
gh auth status
```

當時的結果：

| 項目 | 值 | 代表 |
|------|----|------|
| `user.name` / `user.email`（global、local） | 都是空的 | 這台電腦從沒設定過 git 身分 |
| `origin` | `https://github.com/Shawn0815/Leetcode.git` | 用 HTTPS 連線 |
| `credential.helper` | `osxkeychain` | HTTPS 的帳密存在 macOS 鑰匙圈 |
| `gh auth status` | `Logged in to github.com account shawn-yu_tmemu (keyring)` | 登入的是**工作帳號** |

之前的 commit 作者：

```sh
git log -3 --format='%an <%ae> | %s'
```

```
Shawn0815 <F7123542@gmail.com> | Refactor
Shawn0815 <F7123542@gmail.com> | 2026-03-12 Latest modify
Shawn Yu <F7123542@gmail.com> | Modify 1
```

---

## 問題一：沒有設定身分，commit 會失敗

每個 commit 都要記錄作者的名字和 email，來源是 git 設定的 `user.name`、`user.email`。
沒有設定時（在暫存 repo 重現）：

```sh
git commit -m test
```

```
Author identity unknown

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.

fatal: unable to auto-detect email address (got 'shawn_yu@TW-ShawnYu.(none)')
```

git 會試著用「使用者名稱@電腦名稱」自己猜一個 email，但電腦名稱沒有網域（`.(none)`），猜不出來，所以直接失敗（exit code 128）。

### git 設定的三個層級

| 層級 | 參數 | 存在哪 | 影響範圍 |
|------|------|--------|----------|
| system | `--system` | git 安裝目錄 | 這台電腦所有使用者 |
| global | `--global` | `~/.gitconfig` | 這個使用者的所有 repo |
| local | `--local` | repo 裡的 `.git/config` | **只有這個 repo** |

同一個設定在多個層級都有時，==越小的範圍越優先==：local > global > system。

### 解法：只對這個 repo 設定

錯誤訊息建議用 `--global`，但==工作電腦不要這樣做==：global 會套用到所有 repo，之後在工作的 repo commit，作者也會變成個人帳號。
所以只設在這個 repo：

```sh
git config --local user.name "Shawn0815"
git config --local user.email "F7123542@gmail.com"
```

`--local` 可以省略（在 repo 裡執行 `git config` 預設就是 local），寫出來比較清楚。

確認設定從哪裡來：

```sh
git config --show-origin --get user.email
```

```
file:.git/config	F7123542@gmail.com
```

`.git/config` 裡多了：

```
[user]
	name = Shawn0815
	email = F7123542@gmail.com
```

設定完 commit 就成功了，作者是：

```
Shawn0815 <F7123542@gmail.com>
```

==email 要用 GitHub 帳號有登記的 email==，GitHub 才會把 commit 算在這個帳號上（顯示頭像、算進貢獻圖）。

---

## 問題二：push 會用到工作帳號的登入

### 兩個「帳號」是不同的東西

| | 設定在哪 | 作用 |
|---|---|---|
| **commit 作者** | `user.name`、`user.email` | 只是寫在 commit 裡的文字，誰都能填任何值 |
| **push 的登入** | HTTPS：credential helper；SSH：金鑰 | GitHub 用它判斷你**有沒有權限**寫這個 repo |

所以就算作者設成 `Shawn0815`，push 時如果用工作帳號 `shawn-yu_tmemu` 登入，GitHub 會因為工作帳號沒有 `Shawn0815/Leetcode` 的寫入權限而拒絕。

### HTTPS 的帳密怎麼存

remote 是 `https://...` 時，git 把帳密交給 `credential.helper` 管理。
這台的 helper 是 `osxkeychain`，帳密存在 macOS 鑰匙圈，==依「主機 + 帳號名稱」分開存==。

網址沒有寫帳號名稱時（`https://github.com/...`），git 只知道主機是 `github.com`，可能拿到鑰匙圈裡已經存的工作帳號。

### 解法：把帳號名稱寫進 remote 網址

```sh
git remote set-url origin https://Shawn0815@github.com/Shawn0815/Leetcode.git
git remote -v
```

```
origin	https://Shawn0815@github.com/Shawn0815/Leetcode.git (fetch)
origin	https://Shawn0815@github.com/Shawn0815/Leetcode.git (push)
```

`Shawn0815@` 告訴 git「這個 repo 用 Shawn0815 這個帳號」，鑰匙圈就會去找、或新存一筆 `github.com` + `Shawn0815` 的密碼，不會跟工作帳號那筆混在一起。

### 密碼要用 Personal Access Token

GitHub 從 2021 年起，HTTPS 的 git 操作==不接受帳號密碼==，要用 Personal Access Token（PAT）代替密碼。

產生 token（用==個人帳號==登入 GitHub）：

1. 右上角頭像 → ==Settings== → ==Developer settings== → ==Personal access tokens== → ==Fine-grained tokens== → ==Generate new token==
2. ==Repository access== 選 ==Only select repositories== → 選 `Leetcode`
3. ==Permissions== → ==Contents== 設為 ==Read and write==
4. 產生後==馬上複製==，離開頁面就看不到了

Fine-grained token 可以限定只能存取哪些 repo、能做什麼，就算外流，影響範圍也只有這個 repo。

### 第一次 push

```sh
git commit -m "Add Python solutions for 1, 217"
git push
```

要求輸入密碼時，==貼上 token，不是 GitHub 的登入密碼==。
鑰匙圈會記住，之後 push 就不會再問。

`[待確認]`：第一次 push 的實際提示和輸出，push 後補上。

---

## 其他做法（沒採用）

| 做法 | 說明 | 沒採用的原因 |
|------|------|--------------|
| `gh auth login` 加第二個帳號，用 `gh auth switch` 切換 | gh 可以同時登入多個帳號 | 每次要記得切換，忘了切回來，工作的操作就會用到個人帳號 |
| SSH + 每個帳號各一把金鑰，在 `~/.ssh/config` 設 host 別名 | 例如 `github-personal` 對應個人金鑰 | 要另外產生金鑰、改 remote 網址成別名，設定比較多 |
| `git config --global` 設成個人身分 | 最省事 | 工作 repo 的 commit 作者會變成個人帳號 |
