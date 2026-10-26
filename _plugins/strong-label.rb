# frozen_string_literal: true

# ------------------------------------------------------------
#  strong-label.rb
#
#  功能：段落、列點開頭的粗體標籤（**意思**：、**Example 1:**、**Constraints:**）
#   加上 class="strong-label"，CSS 讓它維持一般粗體，不上紅字螢光筆。
#   條件：在 <p> 或 <li> 的最前面、後面接冒號（或冒號在粗體裡面），長度不限。
#   沒有接冒號的粗體才當成重點句，照樣上色。
# ------------------------------------------------------------

Jekyll::Hooks.register :posts, :post_render do |doc|
  next if doc.output.nil?

  doc.output = doc.output.gsub(%r{(<(?:p|li)>\s*)<strong>([^<]+?)</strong>(\s*[：:])?}) do |match|
    open_tag, text, colon_after = Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3)
    has_colon = colon_after || text.end_with?('：', ':')
    label = text.sub(/[：:]\z/, '').strip

    if has_colon && !label.empty?
      "#{open_tag}<strong class=\"strong-label\">#{text}</strong>#{colon_after}"
    else
      match
    end
  end
end
