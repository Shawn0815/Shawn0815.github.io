# frozen_string_literal: true

# ------------------------------------------------------------
#  bold-highlight.rb
#
#  功能：**粗體** 在文章裡是紅字黃色螢光筆（CSS 在 assets/css/custom.scss）。
#   帶冒號的粗體是標籤，加上 class="plain" 顯示一般粗體：
#   粗體裡以冒號結尾（**Example 1:**），或粗體後面緊接冒號（**Follow-up**: …、**Time**：…）。
#   想手動指定一般粗體，筆記裡寫 <b>文字</b>（CSS 只上色 <strong>）。
#   <pre>、<code> 裡面不動。
# ------------------------------------------------------------

LABEL = %r{<strong>((?:(?!</?strong>).)*?[:：]\s*)</strong>|<strong>((?:(?!</?strong>).)*?)</strong>(?=\s*[:：])}m

Jekyll::Hooks.register :posts, :post_render do |doc|
  next if doc.output.nil?

  parts = doc.output.split(%r{(<pre[\s>].*?</pre>|<code[\s>].*?</code>)}m)
  doc.output = parts.each_with_index.map do |part, i|
    next part if i.odd?

    part.gsub(LABEL) { %(<strong class="plain">#{Regexp.last_match(1) || Regexp.last_match(2)}</strong>) }
  end.join
end
