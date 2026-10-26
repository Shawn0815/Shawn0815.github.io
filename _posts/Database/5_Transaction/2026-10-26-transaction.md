---
title: "[Database]  Transaction"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Transaction"]
tags: []
order: "000005_transaction/000005.000001_transaction.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/5_Transaction/5.1_Transaction.md
render_with_liquid: false
---

## Abstract

一個商業行為（下單、轉帳、退款）通常是好幾條 SQL，Transaction 保證它們全部成功或全部失敗，不會做到一半。
ACID 是 Transaction 要達成的四個目標。
設計時的重點是邊界：只把屬於同一個商業行為、必須一起成功的資料變動放進去，而且越短越好。

---

## 為什麼需要

銀行轉帳是兩條 SQL：A 扣 1000、B 加 1000。
做到一半失敗，A 扣了、B 沒加，1000 元就憑空消失。

電商下單也一樣：建立 Order、建立 OrderItem、扣庫存、建立付款紀錄。
如果扣庫存失敗，訂單已經成立但庫存沒扣，資料就進入不合理的狀態。

Transaction 解決的是「做到一半」：

```sql
BEGIN;
INSERT INTO orders ...;
UPDATE products SET stock = stock - 1 WHERE id = 1;
COMMIT;      -- 全部成功才寫入
-- 中途出錯就 ROLLBACK，回到 BEGIN 之前，像什麼都沒發生
```

---

## ACID

| 特性 | 意思 | 解決什麼 |
|---|---|---|
| Atomicity（原子性） | 全部成功或全部失敗 | 做到一半 |
| Consistency（一致性） | 執行前後，系統規則仍然成立 | 這是最終目標 |
| Isolation（隔離性） | Transaction 之間不互相干擾 | 同時做 |
| Durability（持久性） | `COMMIT` 後資料永久保存，當機、斷電也不會掉 | `COMMIT` 後遺失 |

Consistency 最容易被誤解。
它的意思不是「資料前後一樣」，而是業務規則（Business Invariant）仍然成立：轉帳前後 A + B 的總額都是 2000、庫存永遠 `>= 0`。
Atomicity、Isolation、Durability 都是幫忙維持 Consistency 的手段。

Isolation 的例子：庫存剩 1，A、B 同時讀到 1，都下單成功，結果賣出兩件。
Durability 通常靠 Redo Log、Write-Ahead Logging（WAL）實現。

---

## 邊界怎麼畫

問題通常不是「要不要開 Transaction」，而是哪些操作要放在同一個裡面。
判斷方式：哪些資料變動屬於同一個商業行為？

- 放進去：Order、OrderItem、Inventory，三者一起代表「下單」。
- 不用放：寄 Email、發 Slack、更新 Analytics、更新推薦系統，失敗了也不會破壞資料正確性。

Transaction 的邊界就是資料一致性的邊界。

### 越短越好

Transaction 執行期間通常會持有 Lock，越久其他 Transaction 等越久，吞吐量就下降。

**不要把慢操作放進 Transaction**：

- 第三方付款、物流系統、外部 API：慢、可能 timeout、不可控。
- 寄 Email。
- 大量運算、報表分析。
- 等待使用者操作。

放進去可能讓資料庫被鎖住好幾秒，影響整個系統。

---

## Transaction 管不到的事

Transaction 解決「做到一半」，但不能完全解決「同時做」。
商品剩 1 件、兩個人同時下單，即使兩邊都有 Transaction 還是可能超賣。
這要靠 Race Condition 的防護、Locking 和 Isolation Level。
