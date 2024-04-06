render html ->{ <<~HTML
  <output>#{text "Does this work?", -> { upcase | concat(" ") | concat(abc.to_s) }}</output>
HTML
}