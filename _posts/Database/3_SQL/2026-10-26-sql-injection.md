---
title: "[Database]  SQL Injection 與參數綁定"
date: 2026-10-26 18:46 +0800
categories: ["Database", "SQL"]
tags: []
order: "000003_sql/000003.000005_sql-injection.md"
image: {path: "/assets/img/covers/Database.png"}
source: DDAN_Usandbox/0_Personal/Database/3_SQL/3.5_SQL-Injection.md
render_with_liquid: false
---

## Abstract

SQL Injection 是把使用者輸入直接拼進 SQL，讓輸入的內容改變查詢的邏輯，例如繞過登入，甚至刪資料。
防護的核心是參數綁定（Prepared Statement），把 SQL 結構和資料分開。
參數綁定只能綁「值」，不能綁欄位名稱，所以讓使用者選排序欄位時要改用白名單。

---

## 怎麼發生

用字串拼接寫的登入查詢：

```java
String sql = "SELECT * FROM users WHERE email = '" + email + "'";
```

使用者在 email 輸入 `' OR '1'='1`，組出來的 SQL 變成：

```sql
SELECT * FROM users WHERE email = '' OR '1'='1'
```

`'1'='1'` 永遠成立，回傳所有使用者，登入驗證就被繞過了。

---

## 參數綁定

```java
String sql = "SELECT * FROM users WHERE email = ?";
PreparedStatement stmt = connection.prepareStatement(sql);
stmt.setString(1, email);
```

`?` 是佔位符。
資料庫先編譯好 SQL 的結構，`email` 只會被當成資料帶進去，不會被解析成語法。
輸入 `' OR '1'='1` 也只會拿這個字串去比對 `email` 欄位。

---

## 排序欄位要用白名單

==參數綁定只能綁值（Value），不能綁識別字（Identifier）==，例如欄位名稱、表名稱：

```sql
SELECT * FROM books WHERE category_id = ?   -- 可以，? 是值
SELECT * FROM books ORDER BY ?              -- 不行，? 沒辦法當成欄位名稱
```

API 讓使用者用 `?sort=price` 選排序欄位時，先定義允許的欄位清單，傳入的值只拿來查清單：

```java
private static final Map<String, String> SORT_WHITELIST = Map.of(
    "price", "price",
    "created_at", "created_at",
    "name", "name"
);

public String resolveSortColumn(String sortParam) {
    return SORT_WHITELIST.getOrDefault(sortParam, "created_at");
}

String sql = "SELECT * FROM books ORDER BY " + resolveSortColumn(sortParam);
```

拼進 SQL 的是程式自己定義的字串，不是使用者的原始輸入。
傳入 `price; DROP TABLE books;--` 時清單裡找不到，直接回傳預設的 `created_at`。

---

## 其他防護

- 輸入驗證：檢查型別、長度、格式，不合法的及早擋掉。
- 最小權限：資料庫帳號只給必要的權限，真的被注入也能降低影響範圍。
- ORM：Spring Data JPA、MyBatis 預設都用參數綁定，**MyBatis 要用 `#{}`，不要用 `${}`**（`${}` 是直接字串替換）。
