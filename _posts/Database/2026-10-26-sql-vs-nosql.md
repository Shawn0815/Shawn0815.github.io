---
title: "[Database]  SQL vs. NoSQL"
date: 2026-10-26 16:49 +0800
categories: ["Database"]
tags: ["Database"]
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/1_Fundamentals/1.1_SQL-vs-NoSQL.md
---

## Abstract

選資料庫時要問的不是「哪個比較好」，而是兩者各自解決什麼問題、付出什麼代價。

Relational Database 把資料拆開、用關係連起來，換到一致性和複雜查詢；NoSQL 依查詢方式決定怎麼存，換到 Schema 彈性和水平擴展。

實務上通常是核心交易資料用 SQL，其他特殊用途的資料再搭配不同的資料庫。

---

## Relational Database：拆開、建立關係

如果把資料照直覺巢狀存，商品名稱會在每一張訂單裡各存一份：

```json
{
  "user": {
    "id": 1,
    "orders": [
      { "id": 1001, "products": [{ "id": 10, "name": "iPhone" }] }
    ]
  }
}
```

100 萬張訂單就有 100 萬份 `"iPhone"`，改名時要改 100 萬個地方，漏改一筆就不一致。

Relational Database 的做法是每種資料只存一次，其他地方用 id 指過去，要完整資料時再 `JOIN` 回來：

```
  users        (id, name, email)
  products     (id, name, price)
  orders       (id, user_id, amount)
  order_items  (id, order_id, product_id, quantity)
```

優點：

- Schema 明確，每張表的欄位固定。
- 資料不重複，改一個地方就好。
- 用 Primary Key、Foreign Key、Constraint、Transaction 保護資料正確。
- 擅長複雜查詢：`JOIN`、`GROUP BY`、`ORDER BY`。

代價：

- 查詢常要好幾層 `JOIN`，資料量大時會慢。
- Schema 固定，大表 `ALTER TABLE` 成本高。
- 水平擴展難：資料切到不同機器後，跨機器的 `JOIN`、Transaction、Foreign Key 都很難做。

---

## NoSQL：照查詢方式存

Log、點擊事件、聊天訊息、Feed、IoT 感測資料這類資料量大、寫入多、彼此關聯弱、查詢方式固定，不太需要 `JOIN` 和強 Transaction，反而更在意吞吐量、延遲和水平擴展。

NoSQL 就是放棄 Relational Database 的部分能力，換取這些場景下的效能和彈性。
它是一大類資料庫的統稱，常見的有：

| 類型 | 例子 |
|---|---|
| Document | MongoDB |
| Key-Value | Redis |
| Wide Column | Cassandra |
| Distributed Key-Value | DynamoDB |

以 Document Database 為例，常一起讀的資料直接存在一起，不拆表：

```json
{
  "id": 1,
  "name": "Shawn",
  "addresses": [{ "city": "Taipei", "zip": "100" }]
}
```

兩者設計時的出發點不同：

- Relational：有哪些 Entity？彼此什麼關係？怎麼避免重複？
- NoSQL：系統最常怎麼查？怎麼存才能最快讀出來？

**NoSQL 並沒有比較簡單**：同一份資料複製到多個 Document 後，哪些要同步、更新到一半失敗怎麼辦、能不能接受暫時不一致，這些原本由資料庫保證的事，變成要由程式或系統設計自己處理。

---

## 怎麼選

| | SQL | NoSQL |
|---|---|---|
| 資料模型 | Table | Document、Key-Value、Wide Column |
| Schema | 固定、明確 | 彈性 |
| 關聯 | 強，擅長 `JOIN` | 弱，通常避免 `JOIN` |
| Transaction | 強 | 看資料庫和場景 |
| 一致性 | 通常較強 | 依需求取捨 |
| 水平擴展 | 較難 | 較容易 |
| 常見場景 | 訂單、付款、會員、庫存 | Log、Feed、聊天、Cache |

- 選 SQL：資料結構明確、關聯強、需要 `JOIN`、需要 Transaction 和強一致性。
- 選 NoSQL：資料量大、關聯弱、Schema 常變、寫入量高、查詢方式固定、需要水平擴展。

### 電商系統

User、Product、Order、OrderItem、Payment、Inventory 彼此關聯很強，下單、扣庫存、付款又需要 Transaction，所以核心交易資料用 MySQL 或 PostgreSQL。

其他資料依用途搭配：

| 用途 | 資料庫 |
|---|---|
| 商品搜尋 | Elasticsearch |
| 熱門排行榜 | Redis |
| 使用者行為 Log | NoSQL、Data Pipeline |
| 推薦系統事件 | NoSQL、Event Store |

### MySQL vs PostgreSQL

兩者都支援 Schema、`JOIN`、Transaction、ACID，差別在工程實務：

- PostgreSQL：資料型別和進階功能比較多（JSONB、Array），適合複雜查詢。
- MySQL：普及、資源多，Spring Data JPA 的範例也多。

沒有絕對優劣，看團隊熟悉度、需要的功能、讀寫模式和既有技術。
