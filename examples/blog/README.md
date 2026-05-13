# Blog example

spnl-erb の **multi-view / model / layout** 統合サンプル. ブログ風サイトの
index / show / about の 3 ページを **AOT compile 後の単一バイナリ**から生成する.

## 構成

```
examples/blog/
├── views/
│   ├── layout.html.erb           ← 共通レイアウト (nav / footer / content slot)
│   ├── about.html.erb            ← About ページ
│   └── posts/
│       ├── index.html.erb        ← Post 一覧 (loop, conditional, tag)
│       └── show.html.erb         ← 1 Post + comments (case/when, edited 判定)
├── models/
│   ├── post.rb                   ← title/author/tags/body + 計算 method
│   │                                 (excerpt / reading_minutes / posted_date)
│   └── comment.rb                ← author/body + edited? + posted_at (相対時刻)
├── app.rb                        ← データ生成 + 全 view render + out/*.html 書き出し
├── build.sh                      ← spnl-erb で *.erb -> *.generated.rb
└── out/                          ← 生成 HTML (.gitignore)
```

合計 **400+ 行** (views 200 / models 100 / app 110), 出力 HTML **10KB**.

## ビルド & 実行

```sh
cd examples/blog/

# 1. テンプレートをコンパイル (CRuby, 1 秒未満)
RUBY=ruby ./build.sh

# 2. Ruby を Spinel で AOT compile (約 3 秒)
spinel app.rb -o blog_app

# 3. 実行 -> out/*.html 生成
./blog_app
# wrote out/index.html (4138 bytes)
# wrote out/posts/show.html (3360 bytes)
# wrote out/about.html (2638 bytes)

# 4. ブラウザで確認
open out/index.html
```

## 何を実演しているか

### View

| 機能 | テンプレで使用 |
|---|---|
| **共通 layout** (slot 機能) | `<%= @content %>` で文字列を流し込む |
| **条件分岐** | `<% if @posts.length == 0 %>...<% else %>...<% end %>` |
| **case/when (Symbol)** | `case @post.status; when :published ... ; when :draft` |
| **ループ + 局所変数** | `<% i = 0 %><% posts.each do |p| %><% i = i + 1 %>` |
| **三項演算子** | `<%= active_nav == "home" ? "active" : "" %>` |
| **method call chain** | `<%= p.tags.each ... %>`, `<%= post.title.upcase %>` |
| **Object method 呼び出し** | `<%= p.excerpt(160) %>`, `<%= comment.edited? %>` |
| **HTML escape は手動** | 必要な箇所では `H.html_escape(s)` を呼ぶ (本例は省略) |

### Model

| 機能 | 実装場所 |
|---|---|
| POJO (attr_accessor + initialize) | `Post.new(id, slug, title, ...)` |
| 計算 method | `Post#reading_minutes` (語数 / 200 wpm) |
| 文字列 helper | `Post#excerpt(n)` |
| 日付計算 (Time API 制限) | `Post#posted_date` (JDN 逆算で "YYYY-MM-DD") |
| 相対時刻 | `Comment#posted_at` ("3 hours ago") |
| 状態判定 | `Post#featured?`, `Comment#edited?` |
| Symbol 状態 enum | `Post#status` (`:published` / `:draft` / `:archived`) |

### App コード

| 機能 | 例 |
|---|---|
| Top-level data 生成 | `make_posts` / `make_comments` |
| View 呼び出し (module 形式) | `PostsIndexView.render(posts, total)` |
| Layout 適用 | `LayoutView.render(title, ..., content, ...)` |
| File output | `File.write(path, html_str)` |

## 重要な Spinel 制約への対応

このサンプルは **2 つの Spinel 制約に直面**し,
それぞれ以下の方法で回避している.

### 1. `@var` に `Array<UserClass>` を保持すると SIGSEGV

```ruby
# ❌ クラッシュする
class V
  def initialize(posts); @posts = posts; end
  def render; @posts.each { ... }; end
end

# ✅ stateless module (spnl-erb のデフォルト)
module V
  def self.render(posts)
    posts.each { ... }
  end
end
```

`spnl-erb` はデフォルトで `--mode stateless` を採用し,
**class instance variable を完全に避ける**.
テンプレートで `@x` と書いても generator が局所変数 `x` に書き換える.

### 2. `Dir.exist?` / `Dir.mkdir` が dispatch しない

`build.sh` で `mkdir -p out/posts` を事前実行する.
Spinel は file 書き込みは `File.write` で OK だが, ディレクトリ作成は shell に任せる.

## ベンチマーク

```
- spnl-erb compile (4 templates):    35 ms (CRuby)
- spinel compile (app.rb + views):    3.0 s
- bin/blog_app 実行 (3 page output):  16 ms (Spinel binary)
- 出力 HTML 合計サイズ:               10,136 bytes
```

3 ページ render が 16ms = **1 page あたり 5ms**.
runtime ERB の Rails と比べて 1〜2 桁速い (eval/parser コストなし).

## 改造のヒント

- **/archives ページ追加**: 月別アーカイブで Post をソート (`Post.posted_date` で group_by)
- **本物の HTTP サーバ化**: spinel-demo の httpd_async と組み合わせて Server-Side Rendering
- **DB 統合**: spnl-schema で User/Post を生成し, app.rb の make_posts を `Post.all` に置換
- **partial 風機能**: `LayoutView.render` のように content slot を文字列で渡せば実質 partial
