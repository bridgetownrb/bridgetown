class HelloWorld < HTMLElement
  def connected_callback()
    self.inner_html = "<p><strong>Hello World!</strong></p>"
  end
end

# Try adding `<hello-world></hello-world>` somewhere on your site to see this
# example web component in action!
custom_elements.define "hello-world", HelloWorld
