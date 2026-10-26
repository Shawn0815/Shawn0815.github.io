---
title: "[Spring Boot]  Spring 與 Spring Boot"
date: 2026-10-26 18:56 +0800
categories: ["Spring Boot", "Fundamentals"]
tags: []
order: "000001_fundamentals/000001.000001_spring-and-spring-boot.md"
image: {path: "/assets/img/covers/Spring_boot.png"}
source: DDAN_Usandbox/0_Personal/Spring_Boot/1_Fundamentals/1.1_Spring-and-Spring-Boot.md
render_with_liquid: false
---

## Abstract

Spring Framework 的核心是 IoC Container 和 Dependency Injection，生態涵蓋後端幾乎所有需求，但設定非常繁瑣。
Spring Boot 不是取代 Spring，而是建在它上面，用「約定優於設定」解決三件事：Auto Configuration 自動配常用 Bean、Starter 打包相容的依賴、內嵌 Tomcat 讓專案直接跑。
代價是框架較重、自動化的部分（Magic）多，出問題時比較難追。

---

## Spring Framework

IoC（Inversion of Control）Container：把物件的建立和管理交給容器，透過 Dependency Injection 降低程式之間的耦合。
生態還有 AOP、Spring MVC、Spring Data、Spring Security 等模組。

早期要自己寫 XML 決定哪些 Bean 要建、怎麼建、依賴關係是什麼，還要自己選 Web Server（Tomcat）、處理版本相容，學習和設定成本都很高。

---

## Spring Boot 解決的三件事

| 問題 | 解法 |
|---|---|
| 設定太複雜 | Auto Configuration 自動配常用 Bean |
| 依賴管理太複雜 | Starter 打包一組互相相容的套件版本 |
| 部署啟動太麻煩 | 內嵌 Tomcat，`java -jar` 直接跑 |

### Auto Configuration

加了什麼套件，Spring Boot 就自動做對應的設定。
例如有 `spring-boot-starter-data-jpa` 加上 MySQL driver，就會自動準備 DataSource 等 Bean，不用先手寫一堆 XML 或設定類別。

背後是用 `@Conditional` 判斷這個環境需不需要建某個 Bean。
好處是快，代價是要花時間搞懂「這個 Bean 是誰自動生出來的」。

### Starter

把某個功能需要的所有依賴包成一個 artifact。
`spring-boot-starter-web` 裡就有 Spring MVC、內嵌 Tomcat、Jackson（JSON 序列化），不用自己一個個加、確認版本相容。

常見的有 `spring-boot-starter-web`、`spring-boot-starter-data-jpa`、`spring-boot-starter-security`、`spring-boot-starter-test`。

### 內嵌 Web Server

```txt
傳統：寫好應用 → 部署到外部的 Tomcat
Spring Boot：java -jar app.jar → 服務直接起來
```

==這裡的「內嵌容器」是內嵌的 Java Web Server（Tomcat），不是 Docker Container。==
前者是讓應用自己帶 Web Server，後者是把整個執行環境打包部署。

---

## 缺點

- 框架較重：比 Express、FastAPI 啟動慢、吃記憶體。
- Magic 多：Auto Configuration 省了設定，也讓人看不出 Bean 怎麼來的，出問題較難 debug。
- 學習曲線高：DI、AOP、Spring MVC、Spring Data 都要花時間熟悉。

---

## 跟其他框架比

| 框架 | 特色 | 相對限制 |
|---|---|---|
| Node.js / Express | 輕量、非同步 I/O 效能好 | 風格自由，團隊大時容易不一致 |
| Django | 內建 admin 後台、ORM | 偏單體，彈性較低 |
| FastAPI | Python 生態、非同步支援好，適合中小型 API | 企業級生態（Security、Transaction 管理）不如 Spring 成熟 |
| Spring Boot | 企業級生態成熟（Security、Data JPA、宣告式 Transaction） | 較重、Magic 多 |

電商專案選 Spring Boot，是因為 Spring Security、Spring Data JPA、Transaction 管理剛好對應專案最重要的幾塊，又是 Java 生態的主流，市場需求大、資源多。
