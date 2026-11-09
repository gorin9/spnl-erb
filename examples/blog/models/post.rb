# Post model — POJO + business logic.
# 実プロジェクトでは spnl-schema が attr_accessor/initialize/find/save 等を
# post.generated.rb に生成し, この post.rb で business 用 helper を書く想定.
class Post
  attr_accessor :id, :slug, :title, :author, :body, :tags,
                :posted_at_epoch, :views, :comments_count, :status, :is_featured

  def self.all
    body1 = "Spinel compiles a supported Ruby subset to native executables. " \
          + "It does whole-program type inference. " \
          + "It targets serious systems programming with Ruby ergonomics. " \
          + "There is no runtime require, no method_missing, no eval. " \
          + "Templates are compiled at build time via spnl-erb. " \
          + "Models come from spnl-schema."
    body2 = "spnl-erb takes .erb templates and emits Spinel-friendly Ruby. " \
          + "No runtime eval. No binding. No string interpolation at request time. " \
          + "Standard ERB source becomes an ordinary Ruby rendering method."
    body3 = "What if your ORM was just a generated file? " \
          + "spnl-schema reads CREATE TABLE statements and emits class definitions."
    out = []
    out.push(Post.new(1, "spinel-philosophy", "Spinel philosophy in 6 lines",
                      "matz", body1, ["spinel", "philosophy", "aot"],
                      1700000000, 1234, 8, :published, true))
    out.push(Post.new(2, "spnl-erb-intro", "Introducing spnl-erb",
                      "gorin9", body2, ["spnl-erb", "build-time"],
                      1701000000, 567, 3, :published, false))
    out.push(Post.new(3, "spnl-schema-intro", "Compile-time ActiveRecord with spnl-schema",
                      "gorin9", body3, ["spnl-schema", "orm"],
                      1702500000, 890, 0, :draft, false))
    out
  end

  def initialize(id, slug, title, author, body, tags,
                 posted_at_epoch, views, comments_count, status, is_featured)
    @id              = id
    @slug            = slug
    @title           = title
    @author          = author
    @body            = body
    @tags            = tags
    @posted_at_epoch = posted_at_epoch
    @views           = views
    @comments_count  = comments_count
    @status          = status
    @is_featured     = is_featured
  end

  def featured?
    @is_featured
  end

  # Standard Time formatting replaces the prototype's calendar arithmetic.
  def posted_date
    Time.at(@posted_at_epoch).utc.strftime('%Y-%m-%d')
  end

  # 200 wpm 想定の読書時間 (英文を字数 / 5 で語数推定)
  def reading_minutes
    wc = @body.length / 5
    rt = wc / 200
    rt < 1 ? 1 : rt
  end

  # n 文字に切り詰めて "..." を付ける
  def excerpt(n)
    return @body if @body.length <= n
    @body[0, n].to_s + "..."
  end

  private

  def pad2(n, width)
    s = n.to_s
    while s.length < width
      s = "0" + s
    end
    s
  end
end
