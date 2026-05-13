# Blog example: 4 views + 2 models をすべて render して out/*.html に書き出す.
#
# 使い方:
#   cd examples/blog/
#   RUBY=ruby ./build.sh             # views を *.generated.rb に変換
#   spinel app.rb -o blog_app        # AOT compile
#   ./blog_app                       # out/*.html を生成
#
# Spinel 制約から `module + class method` (stateless mode) を使用.
# @var に Array<UserClass> を保持すると SIGSEGV するためインスタンス化しない.
require_relative "models/post"
require_relative "models/comment"
require_relative "views/layout.html.generated"
require_relative "views/posts/index.html.generated"
require_relative "views/posts/show.html.generated"
require_relative "views/about.html.generated"

SITE_NAME    = "spinel.blog"
SITE_TAGLINE = "AOT-compiled Ruby for serious people."
FOUNDED      = "2026-01-15"
GENERATED_AT = "2026-05-13 14:00:00"

def make_posts
  posts = []

  body1 = "Spinel is a Ruby AOT compiler that fits in 22KB. " \
        + "It does whole-program type inference. " \
        + "It targets serious systems programming with Ruby ergonomics. " \
        + "There is no runtime require, no method_missing, no eval. " \
        + "Templates are compiled at build time via spnl-erb. " \
        + "Models come from spnl-schema. " \
        + "What you give up in dynamism you gain in static dispatch."
  posts.push(Post.new(
    1, "spinel-philosophy", "Spinel philosophy in 6 lines",
    "matz", body1, ["spinel", "philosophy", "aot"],
    1700000000, 1234, 8, :published, true
  ))

  body2 = "spnl-erb takes .erb templates and emits Spinel-friendly Ruby. " \
        + "No runtime eval. No binding. No string interpolation at request time. " \
        + "Just pre-baked _out = _out + literal concatenation. " \
        + "The result: HTML responses with the same overhead as printf."
  posts.push(Post.new(
    2, "spnl-erb-intro", "Introducing spnl-erb",
    "gorin9", body2, ["spnl-erb", "build-time", "template"],
    1701000000, 567, 3, :published, false
  ))

  body3 = "What if your ORM was just a generated file? " \
        + "spnl-schema reads CREATE TABLE statements and emits class definitions. " \
        + "User.find(id), User.find_by_email, User.create — all static, all type-checked. " \
        + "No reflection, no surprise n+1, no method_missing rabbit hole."
  posts.push(Post.new(
    3, "spnl-schema-intro", "Compile-time ActiveRecord with spnl-schema",
    "gorin9", body3, ["spnl-schema", "orm", "build-time"],
    1702500000, 890, 0, :draft, false
  ))

  posts
end

def make_comments
  c = []
  now = Time.now.to_i
  c.push(Comment.new(1, "alice", "Great post! The 22KB number is wild.",      now - 3700, now - 3700))
  c.push(Comment.new(2, "bob",   "How does this compare to Crystal?",          now - 1800, now - 1800))
  c.push(Comment.new(3, "carol", "I had to fix a typo here.",                  now - 600,  now - 300))
  c
end

def wrap(page_title, active_nav, content, render_count)
  LayoutView.render(
    page_title, SITE_NAME, SITE_TAGLINE, active_nav, content,
    "2026", GENERATED_AT, render_count
  )
end

posts = make_posts
comments = make_comments

# page 1: index
idx_content = PostsIndexView.render(posts, 42)
page_index  = wrap("Latest posts", "home", idx_content, 1)

# page 2: show (post 1 + comments)
show_content = PostsShowView.render(posts[0], comments)
page_show    = wrap(posts[0].title, "home", show_content, 2)

# page 3: about
tech = ["Spinel AOT", "spnl-erb", "spnl-schema", "Fiber + epoll", "SQLite", "OpenSSL FFI"]
about_content = AboutView.render(
  SITE_NAME, SITE_TAGLINE, 42, 137, FOUNDED, tech, 3210, 96
)
page_about = wrap("About", "about", about_content, 3)

def write_file(path, content)
  File.write(path, content)
  puts "wrote " + path + " (" + content.length.to_s + " bytes)"
end

# 出力 dir は build.sh で予め作っておく前提
# (Spinel の Dir.mkdir/exist? が dispatch しないため)

write_file("out/index.html",      page_index)
write_file("out/posts/show.html", page_show)
write_file("out/about.html",      page_about)

puts ""
puts "Open out/index.html in a browser to see the result."
