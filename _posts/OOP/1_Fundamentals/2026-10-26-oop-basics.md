---
title: "[OOP]  OOP 基礎"
date: 2026-10-26 18:46 +0800
categories: ["OOP", "Fundamentals"]
tags: []
order: "000001_fundamentals/000001.000001_oop-basics.md"
image: {path: "/assets/img/covers/OOP.png"}
source: DDAN_Usandbox/0_Personal/OOP/1_Fundamentals/1.1_OOP-Basics.md
render_with_liquid: false
---

## Abstract

OOP（Object-Oriented Programming）以 Object 為核心，把相關的資料、行為和規則放在一起，再讓不同的 Object 合作完成功能。
它的價值不是拆出很多 Class，而是建立清楚的責任邊界：每一組資料和規則都有明確的負責者。
Class 定義一類 Object 的 Field、Constructor、Method；Object 是照 Class 建出來的實體，有自己的 State、Behavior、Identity。

---

## 為什麼需要 OOP

程式變大之後，如果訂單資料在一個地方、取消規則在另一個地方、出貨規則又在第三個地方，就會：

- 看不出哪些資料和行為屬於同一個概念。
- 同一條規則在不同地方各寫一次，改的時候容易漏。
- 外部可以任意改資料。

OOP 把它們集中到 Object：

```txt
Order
├── items、status、createdAt     資料
└── calculateTotal()、cancel()、ship()   行為和規則
```

---

## Object 的三個特徵

| 特徵 | 意思 | 例子 |
|---|---|---|
| State | 目前保存的資料 | `name = Shawn`、`accountStatus = Active` |
| Behavior | 能執行的操作，通常會讀或改自己的 State | `login()`、`suspendAccount()` |
| Identity | 是不是同一個 Object | 兩個都叫 Shawn 的 User，仍然是兩個 Object |

Behavior 代表「這個操作和規則由哪個 Object 負責」。
帳號停權應該是 `user.suspendAccount()`，而不是外部直接 `user.accountStatus = SUSPENDED`。

---

## Class 與 Object

Class 是一類 Object 的定義；Object 是照它建出來的實體。

```java
class User {
    String name;                  // Field：保存 State
    int age;

    User(String name, int age) {  // Constructor：建立時初始化
        this.name = name;
        this.age = age;
    }

    void changeName(String newName) {  // Method：Behavior
        name = newName;
    }
}

User user1 = new User("Shawn", 28);
User user2 = new User("Amy", 25);
```

- Field：這個 Object 要記住什麼。
- Constructor：確保 Object 建好時就是可以運作的狀態。一張 Order 一定要有 User，就不該先建一個空的再等外部補。
- Method：這個 Object 負責什麼行為。

```java
void cancel() {
    if (status == OrderStatus.SHIPPED) {
        throw new IllegalStateException();
    }
    status = OrderStatus.CANCELLED;
}
```

由 Order 自己判斷能不能取消，而不是讓外部直接改 `order.status`。

### new 做了什麼

`new User("Shawn", 28)` 會配置空間、建立 Object、初始化 Field、執行 Constructor，最後回傳指向這個 Object 的 Reference。
變數 `user` 存的是 Reference，不是整個 Object。

---

## Object 與 Reference

```java
User user1 = new User("Shawn", 28);
User user2 = user1;            // 同一個 Object，兩個 Reference

user2.changeName("Amy");
// 透過 user1 讀也是 Amy
```

```txt
user1 ──┐
        ├──> User Object
user2 ──┘
```

**`user2 = user1` 不會複製 Object**，兩個變數改的是同一個。
要兩個不同的 Object 就要 `new` 兩次；即使 State 一樣，Identity 也不同。

### this

`this` 是目前正在執行這段程式的 Object。
`this.name = name` 裡，`this.name` 是 Field，`name` 是參數；沒有命名衝突時可以省略 `this`。

---

## 四大特性

| 特性 | 做什麼 | 例子 |
|---|---|---|
| Encapsulation | 控制 Object 的資料怎麼被操作 | `account.withdraw(100)`，不能 `account.balance = -10000` |
| Inheritance | 建立 Parent / Child 的 is-a 關係，取得共同內容 | Dog is an Animal |
| Polymorphism | 用共同型別操作不同 Object，執行各自的實作 | `payment.pay()` 依實際物件走信用卡或 LINE Pay |
| Abstraction | 只暴露需要的功能，隱藏內部怎麼做 | 呼叫 `pay()` 不用知道怎麼呼叫第三方 API |

---

## 看到需求怎麼拆 Class

不是每個名詞都建一個 Class，而是找出有獨立責任的概念。

1. 找出系統真正關心的概念：User、Product、Cart、Order，各有自己的資料、行為和生命週期。
2. 定義每個 Class 的責任：Product 管價格、判斷庫存夠不夠；Order 管訂單項目、算金額、管狀態。
3. 找 State 和 Behavior：要記住什麼是 Field，要負責做什麼是 Method。
4. 把行為放在最了解資料的 Object：「能不能取消」看的是訂單狀態，所以是 `order.cancel()`。
5. 檢查合作關係：
   - 有沒有 Class 負責太多事？
   - 關係是 is-a 還是 has-a？
   - 跨 Object 的流程由誰協調？

Order 管自己的狀態規則；寄 Email、呼叫付款 API、操作資料庫，交給其他 Object 或 Service。
