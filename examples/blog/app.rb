# Blog example (Controller pattern).
#
# 全 view メソッドは BlogController を reopen して定義される (build.sh が生成).
# 利用側はテンプレに登場する @var を BlogController#index/show/about で
# 自然にセットするだけ — 引数の順序を意識する必要なし.
#
# Spinel 制約:
# - @var = Klass.all のように **Controller method 内で代入する Array<UserClass> は OK**
# - 外部 method の param 経由 (def init(posts); @posts = posts) は SIGSEGV
#
# 使い方:
#   cd examples/blog/
#   RUBY=ruby ./build.sh
#   spinel app.rb -o blog_app
#   ./blog_app   # out/*.html
require_relative "models/post"
require_relative "models/comment"

# 1) BlogController の本体 (人が書く).
#    生成された render_xxx は同じ class を別ファイルで reopen して足す.
class BlogController
  SITE_NAME    = "spinel.blog"
  SITE_TAGLINE = "AOT-compiled Ruby for serious people."
  FOUNDED      = "2026-01-15"
  GENERATED_AT = "2026-05-13 14:00:00"

  # 全 action で共通のチェック状態
  def setup_chrome(page_title, active_nav, render_count)
    @page_title    = page_title
    @site_name     = SITE_NAME
    @site_tagline  = SITE_TAGLINE
    @active_nav    = active_nav
    @year          = "2026"
    @generated_at  = GENERATED_AT
    @render_count  = render_count
  end

  # ----- actions -----

  def index
    @posts = Post.all                    # Array<Post>: Controller method 内代入 OK
    @total_count = 42
    setup_chrome("Latest posts", "home", 1)
    @content = render_posts_index
    render_layout
  end

  def show(post_idx)
    @post = Post.all[post_idx]            # 単一 Post — 簡単な参照
    @comments = Comment.recent            # Array<Comment>
    setup_chrome(@post.title, "home", 2)
    @content = render_posts_show
    render_layout
  end

  def about
    @stats_posts        = 42
    @stats_comments     = 137
    @founded            = FOUNDED
    @tech               = ["Spinel AOT", "spnl-erb", "spnl-schema",
                           "Fiber + epoll", "SQLite", "OpenSSL FFI"]
    @template_size_bytes = 3210
    @binary_size_kb      = 96
    setup_chrome("About", "about", 3)
    @content = render_about
    render_layout
  end
end

# 2) 生成された render メソッド (BlogController を reopen).
require_relative "views/layout.html.generated"
require_relative "views/posts/index.html.generated"
require_relative "views/posts/show.html.generated"
require_relative "views/about.html.generated"

# 3) 実行
def write_file(path, content)
  File.write(path, content)
  puts "wrote " + path + " (" + content.length.to_s + " bytes)"
end

c = BlogController.new

write_file("out/index.html",      c.index)
write_file("out/posts/show.html", c.show(0))
write_file("out/about.html",      c.about)

puts ""
puts "Open out/index.html in a browser."
