---
title: "[Database]  Isolation Level"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Transaction"]
tags: []
order: "000005_transaction/000005.000003_isolation-level.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/5_Transaction/5.3_Isolation-Level.md
render_with_liquid: false
---

## Abstract

每次讀寫都鎖得很嚴，資料最安全但系統很慢，資料庫一直在正確性和效能之間取捨。
Isolation Level 定義 Transaction 之間允許互相影響到什麼程度：等級越高，能避免的問題越多，效能越差。
選擇的原則是用最低的成本滿足業務需求。

---

## 三種讀取問題

### Dirty Read：讀到還沒 Commit 的資料

1. A 把餘額從 100 改成 200，還沒 `COMMIT`。
2. B 讀到 200。
3. A `ROLLBACK`，餘額回到 100。

B 看到了一個從來不存在的 200。

### Non-repeatable Read：同一筆讀兩次結果不同

1. A 讀到 `stock = 10`。
2. B 改成 5 並 `COMMIT`。
3. A 再讀一次，得到 5。

### Phantom Read：筆數變了

1. A 查 `WHERE amount > 1000` 得到 10 筆。
2. B 新增一筆訂單並 `COMMIT`。
3. A 再查一次，得到 11 筆，憑空多出一筆。

前兩個是同一筆資料被改，Phantom Read 是資料筆數改變。

---

## 四個等級

| 等級 | Dirty Read | Non-repeatable Read | Phantom Read | 說明 |
|---|---|---|---|---|
| Read Uncommitted | 會 | 會 | 會 | 幾乎不隔離，最快，實務很少用 |
| Read Committed | 不會 | 會 | 會 | 只能讀到已 Commit 的資料，Oracle、PostgreSQL 的預設 |
| Repeatable Read | 不會 | 不會 | 理論上會 | 同一筆在同一個 Transaction 裡讀到的都一樣，MySQL InnoDB 的預設 |
| Serializable | 不會 | 不會 | 不會 | 像一個一個排隊執行，等待最多、吞吐量最低 |

MySQL InnoDB 在 Repeatable Read 下用 MVCC、Gap Lock、Next-Key Lock 進一步降低 Phantom Read，所以常被誤以為 Repeatable Read 完全沒有 Phantom Read。

---

## 怎麼選

不是越高越好，隔離越強效能越差。

| 情境 | 常見選擇 |
|---|---|
| 一般電商查詢 | Read Committed |
| 庫存扣減 | Repeatable Read 加 Locking |
| 金融交易 | 才考慮 Serializable |

Locking 是怎麼保護資料，Isolation Level 是要保護到什麼程度，兩者是同一件事的兩面。
