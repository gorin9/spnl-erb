# 人が書く Controller. spnl-router がこのファイルを読んで
# ROUTES から router.generated.rb を生成する.
class BlogController
  ROUTES = {
    "/"          => :index,
    "/about"     => :about,
    "/posts/:id" => :show
  }

  SITE_NAME     = "spinel.blog"
  SITE_TAGLINE  = "AOT-compiled Ruby for serious people."
  FOUNDED       = "2026-01-15"
  GENERATED_AT  = "2026-05-13 14:00:00"

  # ----- actions -----

  def index
    @posts = Post.all
    @total_count = 42
    @page_title = "Latest posts"
    render_posts_index
  end

  def show(id)
    @post = Post.all[id]
    @comments = Comment.recent
    @page_title = @post.title
    render_posts_show
  end

  def about
    @stats_posts        = 42
    @stats_comments     = 137
    @founded            = FOUNDED
    @tech               = ["Spinel AOT", "spnl-erb", "spnl-schema",
                           "spnl-router", "Fiber + epoll", "SQLite"]
    @template_size_bytes = 3210
    @binary_size_kb      = 96
    @page_title         = "About"
    render_about
  end

  # ----- framework helper (spnl-router 生成 dispatcher が呼ぶ) -----

  def set_chrome(nav, content)
    @active_nav    = nav
    @content       = content
    @site_name     = SITE_NAME
    @site_tagline  = SITE_TAGLINE
    @year          = "2026"
    @generated_at  = GENERATED_AT
    @render_count  = @render_count.nil? ? 1 : @render_count + 1
  end
end
