class Comment
  attr_accessor :id, :author, :body, :posted_at_epoch, :edited_at_epoch

  def initialize(id, author, body, posted_at_epoch, edited_at_epoch)
    @id              = id
    @author          = author
    @body            = body
    @posted_at_epoch = posted_at_epoch
    @edited_at_epoch = edited_at_epoch
  end

  def edited?
    @edited_at_epoch > @posted_at_epoch
  end

  # 相対時刻表示: "5 minutes ago" / "2 hours ago" / "3 days ago"
  def posted_at
    diff = Time.now.to_i - @posted_at_epoch
    return "just now" if diff < 60
    return (diff / 60).to_s + " minutes ago"  if diff < 3600
    return (diff / 3600).to_s + " hours ago"  if diff < 86400
    (diff / 86400).to_s + " days ago"
  end
end
