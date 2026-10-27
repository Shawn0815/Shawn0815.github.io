---
title: "[Database]  Race Condition"
date: 2026-10-26 18:46 +0800
categories: ["Database", "Transaction"]
tags: []
order: "000005_transaction/000005.000002_race-condition.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/5_Transaction/5.2_Race-Condition.md
render_with_liquid: false
---

## Abstract

多個操作同時讀寫同一份資料，結果取決於誰先誰後，就是 Race Condition。
最常見的是「先查後寫」（Check-then-Act）：單一 request 沒問題，兩個 request 幾乎同時跑時都通過檢查、都寫入。
程式裡的檢查擋不住，真正的防線要放在資料庫：Unique Constraint、Lock、原子操作。

---

## 先查後寫為什麼不安全

註冊流程：先查 email 是否存在，不存在就 insert。
兩個 request 同時用同一個 email 註冊：

```txt
Request A：查詢 email → 不存在
Request B：查詢 email → 不存在
Request A：insert
Request B：insert
```

兩邊查的當下都看到「不存在」，結果同一個 email 建了兩筆，即使程式「有檢查過」。
檢查和寫入之間永遠有時間差。

---

## 防護方式

| 方式 | 做法 |
|---|---|
| Unique Constraint | email 加唯一約束，同時 insert 只有一筆會成功，另一筆收到錯誤，程式再轉成「帳號已存在」 |
| Lock | `SELECT ... FOR UPDATE` 鎖住要檢查的列，同一時間只有一個 request 能往下 |
| 原子操作 | 把檢查和寫入合成一條 SQL，例如 `INSERT ... ON DUPLICATE KEY UPDATE`（MySQL），不留時間差 |

Unique Constraint 被違反時，資料庫直接拒絕：

```sql
CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT UNIQUE);
INSERT INTO users (email) VALUES ('a@example.com');
INSERT INTO users (email) VALUES ('a@example.com');
-- → Error: UNIQUE constraint failed: users.email
```

（在本機 `sqlite3 3.54.0` 跑的輸出。）

**程式裡的檢查只是為了提早給使用者錯誤訊息，防止資料出錯一定要靠資料庫。**
