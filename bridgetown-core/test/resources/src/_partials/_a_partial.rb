render html ->{ <<-HTML
  <output>#{text->{"Does this work?"}.pipe{ upcase | concat(" ") | concat(abc.to_s) }}</output>
HTML
}