# frozen_string_literal: true

# ------------------------------------------------------------
#  solve-log-table.rb
#
#  功能：LeetCode 文章「## 解題紀錄」底下那張表加上 class="solve-log"，
#   讓 assets/css/custom.scss 只調這張表的欄寬（卡點寬、解法窄），其他表格不動。
# ------------------------------------------------------------

SOLVE_LOG = %r{(<h2 id="解題紀錄".*?</h2>\s*<div class="table-wrapper"><table)>}m

Jekyll::Hooks.register :posts, :post_render do |doc|
  next if doc.output.nil?

  doc.output = doc.output.sub(SOLVE_LOG, '\1 class="solve-log">')
end
