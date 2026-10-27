---
title: "[OS]  Race Condition"
date: 2026-10-26 18:56 +0800
categories: ["OS", "Concurrency"]
tags: []
order: "000002_concurrency/000002.000001_race-condition.md"
image: {path: "/assets/img/covers/OS.png"}
source: DDAN_Usandbox/0_Personal/OS/2_Concurrency/2.1_Race-Condition.md
render_with_liquid: false
---

## Abstract

多個執行緒（或多條呼叫路徑）同時存取同一份共享資料，至少一邊在寫，結果取決於誰先誰後，就是 Race Condition。
根本原因是「讀取、修改、寫回」不是原子操作，中間可以被別人插進來。
用 Lock 保護可以解決，但 Lock 用得不好又會變成 Deadlock。

---

## 怎麼發生

兩個 thread 同時執行 `balance -= 10`：

```txt
Thread A：讀到 balance = 100
Thread B：讀到 balance = 100
Thread A：寫回 90
Thread B：寫回 90       ← 應該是 80，A 的結果被蓋掉
```

**關鍵不是有沒有平行執行，而是結果會不會因為執行順序不同而不同。**

常見情境：

- 多個 thread 共享同一塊記憶體或同一份狀態。
- 一段原本只有單一入口呼叫的函式，後來被另一條路徑直接呼叫，繞過原本的保護機制。
- Callback 或跨模組呼叫，以為「只有我在動這份資料」，其實別人也在動。

呼叫路徑變多這種情況通常不會一開始就發現，而是某次上線、或新的呼叫者加入後才暴露。
Code review 時要注意：這段邏輯現在有幾條路徑會走到？

---

## 怎麼判斷有沒有風險

不用等到看到 bug，先問三個問題：

1. 這份資料可能被超過一個執行緒同時存取嗎？
2. 這些存取裡至少有一個是寫入嗎？
3. 沒有任何保護時，兩個執行緒交錯執行，結果會跟預期不一樣嗎？

三個都是「會」，就要加同步機制（Mutex、Semaphore、Lock）。

---

## Race Condition vs Deadlock

| | Race Condition | Deadlock |
|---|---|---|
| 原因 | 沒有保護，資料被搶著讀寫 | 保護過頭或設計不當，執行緒互相等待 |
| 結果 | 資料錯亂 | 系統整個卡住 |

Lock 用來解決 Race Condition，但 Lock 用得不好就會製造 Deadlock。
