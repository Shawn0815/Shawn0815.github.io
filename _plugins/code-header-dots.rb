# frozen_string_literal: true

# ------------------------------------------------------------
#  code-header-dots.rb
#
#  功能：程式碼區塊標題列最前面插入 <i class="mac-dots"></i>
#   Chirpy 原本用 .code-header::before 畫三個點，偽元素沒辦法單獨 hover，
#   改成真的元素，滑鼠移到三個點上才顯示 ×、−、全螢幕的圖案（樣式在 custom.scss）。
# ------------------------------------------------------------

add_dots = lambda do |doc|
  next if doc.output.nil?

  doc.output = doc.output.gsub('<div class="code-header">', '<div class="code-header"><i class="mac-dots"></i>')
end

Jekyll::Hooks.register :posts, :post_render, &add_dots
Jekyll::Hooks.register :pages, :post_render, &add_dots
