class WiggleNote extends HTMLElement {
  static {
    customElements.define("wiggle-note", this)
  }

  connectedCallback() {
    this.style.display = "block"
    this.style.transform = "rotate(-2.5deg)"
    this._observer = new IntersectionObserver(this.wiggle.bind(this), {
      root: null,
      rootMargin: "0px",
      threshold: 1,
    })
    this._observer.observe(this)
  }

  wiggle(entries) {
    if (entries[0].isIntersecting) {
      clearTimeout(this._timer)
      this._timer = setTimeout(
        () =>
          this.animate(
            [
              { transform: "rotate(-2.5deg)" },
              { transform: "rotate(-0.1deg)" },
              { transform: "rotate(-4deg)" },
              { transform: "rotate(-0.5deg)" },
              { transform: "rotate(-3deg)" },
              { transform: "rotate(-2.5deg)" },
            ],
            { duration: 600, easing: "cubic-bezier(0.25, 0, 0.55, 1)" }
          ),
        600
      )
    }
  }
}
