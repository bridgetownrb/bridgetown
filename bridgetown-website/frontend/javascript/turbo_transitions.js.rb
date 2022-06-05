document.add_event_listener "turbo:visit" do
  main = document.query_selector "main-content"

  movement, scale = "15px", "0.99"
  movement, scale = "7px", "1" if window.match_media("(prefers-reduced-motion: reduce)").matches

  main.style.transform_origin = "50% 0%"
  main.dataset[:animating_out] = true
  main.animate [
    { opacity: 1, transform: "translateY(0px) scale(1)" },
    { opacity: 0, transform: "translateY(#{movement}) scale(#{scale})" },
  ], duration: 300, easing: "cubic-bezier(0.45, 0, 0.55, 1)", fill: "forwards"

  Promise.all(
    main.get_animations().map do |animation|
      animation.finished
    end
  ).then do
    main.style.visibility = "hidden" if main.dataset[:animating_out]
  end
end

document.add_event_listener "turbo:load" do
  set_timeout 1000 do
    document.document_element.set_attribute :loaded, ""
  end
  main = document.query_selector "main-content"

  movement, scale = "-10px", "0.99"
  movement, scale = "-5px", "1" if window.match_media("(prefers-reduced-motion: reduce)").matches

  main.style.visibility = "visible"
  main.style.transform_origin = "50% 0%"
  main.dataset.delete :animating_out
  main.animate [
    { opacity: 0, transform: "translateY(#{movement}) scale(#{scale})" },
    { opacity: 1, transform: "translateY(0px) scale(1)" },
  ], duration: 150, easing: "cubic-bezier(0.45, 0, 0.55, 1)"
end
