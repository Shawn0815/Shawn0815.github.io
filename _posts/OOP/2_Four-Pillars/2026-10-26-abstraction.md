---
title: "[OOP]  Abstraction"
date: 2026-10-26 18:46 +0800
categories: ["OOP", "Four Pillars"]
tags: []
order: "000002_four-pillars/000002.000004_abstraction.md"
image: {path: "/assets/img/covers/OOP.png"}
source: DDAN_Usandbox/0_Personal/OOP/2_Four-Pillars/2.4_Abstraction.md
render_with_liquid: false
---

## Abstract

Abstraction 只對外暴露呼叫端需要的功能，隱藏內部怎麼完成：對外定義「能做什麼」，實作負責「怎麼做」。
它是設計概念，不等於 `abstract` 關鍵字；Abstract Class 和 Interface 只是常用的工具。
Abstract Class 適合同一類型、要共用 State 和部分實作；Interface 適合定義共同能力或契約，讓實作可以替換。

---

## 解決什麼問題

結帳流程直接處理信用卡的細節，就要知道卡號格式、加密、銀行連線、付款 API、交易怎麼存；換成 LINE Pay 又要再加一套判斷。
呼叫端知道太多實作細節，實作一改呼叫端就要跟著改。

```java
interface Payment {
    void pay(int amount);
}

class CheckoutService {
    public void checkout(Payment payment, int amount) {
        payment.pay(amount);    // 不用知道是信用卡還是 LINE Pay、內部怎麼做
    }
}
```

每一層只需要知道完成自己工作必要的細節。

一般的 Method 也是 Abstraction：`order.cancel()` 的呼叫端不用知道內部怎麼檢查狀態、算退款、記錄變化。

---

## Abstraction vs Encapsulation

| | Encapsulation | Abstraction |
|---|---|---|
| 關心 | 內部資料能被怎麼操作 | 外部需要看到哪些功能 |
| 保護 | Object 的 State 和規則 | 呼叫端不受實作細節影響 |
| 例子 | 不能直接改 `balance`，要經過 `withdraw()` | 呼叫 `withdraw()` 不用知道內部怎麼檢查和記錄 |

同一個設計常常兩者都有。

---

## Abstract Class

不能直接建立 Object，定義一組相關 Child 共同的 State、行為和抽象操作：

```java
abstract class Payment {
    protected int amount;

    Payment(int amount) {
        this.amount = amount;
    }

    protected void validateAmount() {      // 共用的實作
        if (amount <= 0) throw new IllegalArgumentException();
    }

    public abstract void pay();            // 每種付款各自實作
}

class CreditCardPayment extends Payment {
    CreditCardPayment(int amount) { super(amount); }

    @Override
    public void pay() {
        validateAmount();
        System.out.println("Pay by credit card");
    }
}
```

`new Payment(100)` 會編譯失敗：Payment 只是共同概念，不知道實際要用什麼方式付款，必須建立具體的 Child。

Abstract Method 只有形式沒有實作，Child 必須 Override；沒實作完的 Child 也要宣告成 `abstract`。

---

## Interface

一份契約：實作它的 Class 必須提供哪些行為。

```java
interface Notification {
    void send(String message);
}

class EmailNotification implements Notification {
    @Override
    public void send(String message) { /* 寄 Email */ }
}

class SmsNotification implements Notification {
    @Override
    public void send(String message) { /* 傳簡訊 */ }
}
```

適合不同 Class 沒有共同的 Parent、也不共用 State，但都具備同一種能力。
一個 Class 只能繼承一個 Parent，但可以實作多個 Interface：`class SmartPhone implements Callable, Playable, Connectable`。

Interface 也可以有常數、`default`、`static`、`private` Method，但不保存每個 Object 的可變狀態；Field 都是 `public static final` 常數。

---

## 怎麼選

| | Abstract Class | Interface |
|---|---|---|
| 表達 | 是什麼（is-a），同一類型的共同基礎 | 能做什麼（can-do），共同能力或契約 |
| Instance Field | 可以 | 只有常數 |
| Constructor | 可以 | 沒有 |
| 數量 | 只能繼承一個 | 可以實作多個 |
| 適合 | 共用 State、Constructor、部分實作 | 定義可替換的共同契約 |

- 要共用 Instance State（`amount`、`createdAt`）或 Constructor：Abstract Class。
- 只是描述能力（可以列印、付款、通知、排序）：Interface。
- Dog、Cat 都是 Animal：Abstract Class 可能合理；Email、SMS 都能通知：Interface 比較合適。

---

## 依賴抽象，不依賴實作

```java
// 耦合高：直接依賴具體 Class，很難換付款方式
class CheckoutService {
    private CreditCardPayment payment = new CreditCardPayment();
}

// 依賴 Interface，從外部傳入
class CheckoutService {
    private final Payment payment;

    CheckoutService(Payment payment) {
        this.payment = payment;
    }
}

new CheckoutService(new CreditCardPayment());
new CheckoutService(new LinePayPayment());
```

測試時可以傳 `FakePayment`，不用真的呼叫第三方金流。

Abstraction 定義呼叫端依賴的共同功能，Polymorphism 讓不同的具體 Object 透過它被操作，兩者常一起出現。

---

## 問題與常見錯誤

- 契約抽錯：`interface Bird { void fly(); }`，Penguin 無法合理實作。
- 抽象層太多：簡單功能拆成一堆 Interface、Abstract Class、Wrapper，反而更難追。
- **抽象洩漏實作細節**：`BankApiResponse pay()` 讓呼叫端還是依賴特定銀行的型別，應該回傳系統自己的 `PaymentResult`。
- Interface 太大：`Worker` 同時要 `work()`、`eat()`、`sleep()`、`drive()`、`print()`，實作被迫寫不需要的 Method。
- 每個 Class 都先建 Interface：有多個實作、需要替換、需要隔離依賴時才有價值。
- 只為了共用程式碼就用 Abstract Class：要先有合理的 is-a 關係。
