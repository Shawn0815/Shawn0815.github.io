# Shawn Yu's Blog

<https://shawn0815.github.io>

Jekyll + [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy)（gem 版，`~> 7.4.1`）。push 到 `main` 後由 GitHub Actions（`pages-deploy.yml`）build 並部署到 GitHub Pages。

## 本機預覽

```bash
bundle install
bundle exec jekyll s -l    # http://127.0.0.1:4000
```

## 自訂的部分

主題本身由 gem 提供，下面這些檔案會覆蓋 gem 裡的同名檔案：

| 檔案 | 改了什麼 |
|---|---|
| `_layouts/post.html` | 標題改用 `.post-title`、LeetCode 資訊卡（`topic`、`level`、`class`、`important`、`company`、`leetcode_url`、`neetcode_url`）、`[black]...[/black]` 標記 |
| `_includes/favicons.html`、`assets/feed.xml` | favicon 改用 `favicon-32x32.png` |
| `assets/css/jekyll-theme-chirpy.scss` | 載入 `custom.scss` |
| `assets/css/custom.scss` | 標題、內文、列點、引文、分隔線、`aside` 的樣式 |
| `_plugins/aside-helper.rb` | `aside` 自動解析 Markdown、整行粗體改成黑色 |

文章內文的段落從 `##` 開始（`#` 是文章標題，由 front matter 的 `title` 顯示）。

升級主題時，先比對 gem 新版的 `_layouts/post.html` 有沒有改，再調整 Gemfile 的版本。
