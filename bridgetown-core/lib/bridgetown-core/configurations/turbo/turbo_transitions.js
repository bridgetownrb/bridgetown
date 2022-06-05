document.addEventListener("turbo:visit", () => {
  let main = document.querySelector("main");
  if (main.dataset.turboTransition == "false") return;

  let [movement, scale] = ["15px", "0.99"];

  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    [movement, scale] = ["7px", "1"]
  };

  main.style.transformOrigin = "50% 0%";
  main.dataset.animatingOut = true;

  main.animate(
    [
      { opacity: 1, transform: "translateY(0px) scale(1)" },
      { opacity: 0, transform: `translateY(${movement}) scale(${scale})` }
    ],
    { duration: 300, easing: "cubic-bezier(0.45, 0, 0.55, 1)", fill: "forwards" }
  );

  Promise.all(main.getAnimations().map(animation => animation.finished)).then(() => {
    if (main.dataset.animatingOut) main.style.visibility = "hidden"
  })
});

document.addEventListener("turbo:load", () => {
  let main = document.querySelector("main");
  if (main.dataset.turboTransition == "false") return;

  let [movement, scale] = ["-10px", "0.99"];

  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    [movement, scale] = ["-5px", "1"]
  };

  main.style.visibility = "visible";
  main.style.transformOrigin = "50% 0%";
  delete main.dataset.animatingOut;

  main.animate(
    [
      { opacity: 0, transform: `translateY(${movement}) scale(${scale})` },
      { opacity: 1, transform: "translateY(0px) scale(1)" }
    ],
    { duration: 150, easing: "cubic-bezier(0.45, 0, 0.55, 1)" }
  )
})
