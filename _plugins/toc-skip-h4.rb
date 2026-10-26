# frozen_string_literal: true

# ------------------------------------------------------------
#  toc-skip-h4.rb
#
#  功能：文章右側的 TOC 只列 h2、h3
#   Chirpy 的 TOC 會列 h2～h4，略過有 data-toc-skip 的標題，
#   所以替文章裡所有的 h4 加上 data-toc-skip。
# ------------------------------------------------------------

Jekyll::Hooks.register :posts, :post_render do |doc|
  next if doc.output.nil?

  doc.output = doc.output.gsub(/<h4(?![^>]*data-toc-skip)/, '<h4 data-toc-skip=""')
end
