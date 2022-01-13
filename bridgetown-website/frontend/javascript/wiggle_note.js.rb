class WiggleNote < HTMLElement
  def connected_callback()
    self.style.display = "block"
    self.style.transform = "rotate(-2.5deg)"
    @observer = IntersectionObserver.new(wiggle, root: nil, rootMargin: "0px", threshold: 1.0)
    @observer.observe self
  end

  def wiggle(entries)
    if entries.first.is_intersecting?
      clear_timeout @timer
      @timer = set_timeout 600 do
        self.animate [
          { transform: "rotate(-2.5deg)" },
          { transform: "rotate(-0.1deg)" },
          { transform: "rotate(-4deg)" },
          { transform: "rotate(-0.5deg)" },
          { transform: "rotate(-3deg)" },
          { transform: "rotate(-2.5deg)" },
        ], duration: 600, easing: "cubic-bezier(0.25, 0, 0.55, 1)"
      end
    end
  end
end

custom_elements.define "wiggle-note", WiggleNote
