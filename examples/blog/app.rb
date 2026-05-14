# Blog example (Controller + Router + ERB).
#
# spnl-erb + spnl-router の組合せで,
#   path文字列 -> Router.dispatch(path) -> HTML
# のフローを AOT 単一バイナリに焼き込む.
#
# ビルド:
#   ./build.sh         # *.erb → *.generated.rb (spnl-erb)
#                      # blog_controller.rb → router.generated.rb (spnl-router)
#   spinel app.rb -o blog_app
#   ./blog_app
require_relative "models/post"
require_relative "models/comment"

# 1) Controller (人が書く: ROUTES + action + set_chrome)
require_relative "blog_controller"

# 2) 生成された render_xxx を BlogController に追加 (open class reopen)
require_relative "views/layout.html.generated"
require_relative "views/posts/index.html.generated"
require_relative "views/posts/show.html.generated"
require_relative "views/about.html.generated"

# 3) 生成された Router.dispatch(path)
require_relative "router.generated"

def write_file(path, content)
  File.write(path, content)
  puts "wrote " + path + " (" + content.length.to_s + " bytes)"
end

# 4) URL を Router に渡すだけ. HTTP loop で respond_v11 する場合も同じ.
write_file("out/index.html",      Router.dispatch("/"))
write_file("out/posts/show.html", Router.dispatch("/posts/0"))
write_file("out/about.html",      Router.dispatch("/about"))

# 未定義 path は "404"
not_found = Router.dispatch("/nonexistent")
puts ""
puts "404 sample: " + not_found
puts ""
puts "Open out/index.html in a browser."
