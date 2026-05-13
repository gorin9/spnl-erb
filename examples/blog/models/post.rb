# Post model — POJO + business logic.
# 実プロジェクトでは spnl-schema が attr_accessor/initialize/find/save 等を
# post.generated.rb に生成し, この post.rb で business 用 helper を書く想定.
class Post
  attr_accessor :id, :slug, :title, :author, :body, :tags,
                :posted_at_epoch, :views, :comments_count, :status, :is_featured

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

  # epoch -> "YYYY-MM-DD" (UTC, 自前で組み立て)
  # Spinel の Time#strftime は使えないため Julian day から逆算する.
  def posted_date
    days = @posted_at_epoch / 86400
    jdn  = 2440588 + days
    j  = jdn + 32044
    g  = j / 146097
    dg = j % 146097
    c  = (dg / 36524 + 1) * 3 / 4
    dc = dg - c * 36524
    b  = dc / 1461
    db = dc % 1461
    a  = (db / 365 + 1) * 3 / 4
    da = db - a * 365
    y  = g * 400 + c * 100 + b * 4 + a
    m  = (da * 5 + 308) / 153 - 2
    d  = da - (m + 4) * 153 / 5 + 122
    year  = y - 4800 + (m + 2) / 12
    month = (m + 2) % 12 + 1
    day   = d + 1
    pad2(year, 4) + "-" + pad2(month, 2) + "-" + pad2(day, 2)
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
