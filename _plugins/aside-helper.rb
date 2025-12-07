# frozen_string_literal: true

# ------------------------------------------------------------
#  aside_helper.rb
#
#  功能：
#   1. 自動替 <aside> 補上 markdown="1"
#   2. 合併「💡」+「<strong>文字</strong>」成單行提示
#   3. 若 <strong> 佔據整行（只剩 emoji 或空白）→ 自動加 class="strong-line-black"
#   4. 其他 strong 保持紅色（由 CSS 控制）
# ------------------------------------------------------------

Jekyll::Hooks.register :documents, :post_render do |doc|
  next if doc.output.nil?

  html = doc.output

  # --- 1) 自動替 <aside> 標籤加入 markdown="1"
  html.gsub!(/<aside(?![^>]*markdown=)/) do
    '<aside markdown="1"'
  end

  # --- 2) 處理 aside 內容
  html.gsub!(/<aside[^>]*>(.*?)<\/aside>/m) do |aside_block|
    processed = aside_block.dup

    # --- 合併 💡 + <strong>...</strong>
    processed.gsub!(
      /<p>\s*💡\s*<\/p>\s*<p>\s*<strong>(.*?)<\/strong>\s*<\/p>/m,
      '<p>💡 <strong class="strong-line-black">\1</strong></p>'
    )

    processed
  end

  # --- 3) 處理整份文件內的 strong：如果整行只有 strong → 加黑色 class
  html.gsub!(/<p>(.*?)<\/p>/m) do |p_tag|
    inner = p_tag.gsub(/<\/?p>/, '') # 去掉 <p> 包裝

    # 找 strong
    if inner =~ /<strong>(.*?)<\/strong>/
      strong_text = Regexp.last_match(1)

      # 拿掉 strong 後，看看剩下什麼
      remaining = inner.sub(/<strong>.*?<\/strong>/, '').strip

      # emoji / 空白 → 判斷為整行 strong
      if remaining.empty? || remaining.match?(/\A[\p{Emoji}\p{Extended_Pictographic}\s]*\z/u)
        # 套用黑色 strong class
        p_tag.sub!(
          /<strong>(.*?)<\/strong>/,
          '<strong class="strong-line-black">\1</strong>'
        )
      end
    end

    p_tag
  end

  # 更新文檔內容
  doc.output = html
end
