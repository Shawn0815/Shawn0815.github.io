---
title: "[OOP]  Encapsulation"
date: 2026-10-26 18:46 +0800
categories: ["OOP", "Four Pillars"]
tags: []
order: "000002_four-pillars/000002.000001_encapsulation.md"
image: {path: "/assets/img/covers/OOP.png"}
source: DDAN_Usandbox/0_Personal/OOP/2_Four-Pillars/2.1_Encapsulation.md
render_with_liquid: false
---

## Abstract

Encapsulation 是把相關的資料和行為放在同一個 Object，並控制外部可以怎麼讀、怎麼改它的 State，讓 Object 自己維護規則。
它不只是把 Field 設成 `private`：如果外部仍然能 `setBalance(-10000)`，跟公開 Field 沒有差別。
重點是只提供有業務意義的操作（`withdraw()`），由 Constructor 和 Method 守住 Object 永遠要成立的規則（Object Invariant）。

---

## 沒有封裝會怎樣

```java
class BankAccount {
    public int balance;
}

account.balance = -10000;    // BankAccount 沒辦法保證餘額合法
```

```java
class BankAccount {
    private int balance;

    public void withdraw(int amount) {
        if (amount <= 0) throw new IllegalArgumentException();
        if (amount > balance) throw new IllegalStateException();
        balance -= amount;
    }
}

account.withdraw(100);       // 由 BankAccount 自己檢查後才修改
```

訂單也一樣，`public OrderStatus status` 讓外部可以 `order.status = SHIPPED`，沒付款也能出貨。
改成 `private`，再提供 `ship()`：

```java
public void ship() {
    if (status != OrderStatus.PAID) throw new IllegalStateException();
    status = OrderStatus.SHIPPED;
}
```

---

## private 不等於封裝

```java
private int balance;

public void setBalance(int balance) {
    this.balance = balance;
}

account.setBalance(-10000);  // 跟公開 Field 沒有差別
```

要問的是：外部真的需要改這個資料嗎？改的時候要遵守什麼規則？
`balance` 不該有 `setBalance()`，而是 `deposit()`、`withdraw()`，因為這才是真正允許的狀態變化。

| | 用途 |
|---|---|
| Getter | 控制外部怎麼讀 |
| Setter | 控制外部怎麼設定，可以加驗證，但不是每個 Field 都該有 |
| Behavior Method | 表達合法、有意義的狀態變化：`withdraw()`、`reduceStock()`、`cancel()` |

---

## Constructor Validation 與 Method Validation

```java
class Product {
    private String name;
    private int stock;

    Product(String name, int stock) {
        if (name == null || name.isBlank()) throw new IllegalArgumentException();
        if (stock < 0) throw new IllegalArgumentException();
        this.name = name;
        this.stock = stock;
    }

    public void reduceStock(int quantity) {
        if (quantity <= 0) throw new IllegalArgumentException();   // 參數合不合法
        if (quantity > stock) throw new IllegalStateException();   // 目前狀態允不允許
        stock -= quantity;
    }
}
```

- Constructor Validation：建好的時候就是合法的，`new Product("", -10)` 建不出來。
- Method Validation：每次操作之後仍然合法。

### Object Invariant

Object 合法時永遠要成立的規則：

- BankAccount：`balance >= 0`。
- Product：`stock >= 0`、`price >= 0`、`name` 不能是空的。
- Order：沒付款不能出貨、已取消不能再出貨。

建立、修改、設定這些會改變狀態的入口，都要守住這些規則；封裝的目的就是不讓外部繞過去。

---

## Access Modifier

| 修飾詞 | 誰能用 |
|---|---|
| `private` | 只有自己的 Class |
| `protected` | 自己和 Child Class |
| `public` | 外部 |

原則是只對外暴露必要、安全的操作。

---

## 不要直接暴露內部的 Collection

```java
public List<OrderItem> getItems() {
    return items;
}

order.getItems().clear();    // 繞過 Order 的規則
```

回傳不能修改的 View，修改另外提供方法：

```java
public List<OrderItem> getItems() {
    return Collections.unmodifiableList(items);
}

public void addItem(OrderItem item) {
    // 驗證後加入
}
```

---

## 常見錯誤

- 每個 Field 都自動產生 Setter：外部可以跳過正常的狀態流程，例如直接 `setStatus()`。
- Object 只有資料沒有行為，規則全寫在外部的 Service：Object 保護不了自己的狀態。
- Object 負責太多事：Order 管算金額、判斷能不能取消、改狀態；寄 Email、呼叫金流、操作資料庫、建物流單交給其他 Object 或 Service。
