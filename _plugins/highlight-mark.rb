# frozen_string_literal: true

# ------------------------------------------------------------
#  highlight-mark.rb
#
#  功能：==重點== 轉成 <mark>重點</mark>，CSS 讓它變紅字黃色螢光筆。
#   **粗體** 只是一般粗體。
#   <pre>、<code> 裡面不轉（程式碼的 == 照原樣）；
#   == 的內側不能是空白，所以 a == b 這種比較不會被轉。
# ------------------------------------------------------------

Jekyll::Hooks.register :posts, :post_render do |doc|
  next if doc.output.nil?

  parts = doc.output.split(%r{(<pre[\s>].*?</pre>|<code[\s>].*?</code>)}m)
  doc.output = parts.each_with_index.map do |part, i|
    next part if i.odd?

    part.gsub(/==(?=\S)([^=<>\n]+?)(?<=\S)==/, '<mark>\1</mark>')
  end.join
end
