export const reeler = {
  toggleFullscreen: function() {
    const viewport = document.querySelector(".viewport");

    if (!document.fullscreenElement) {
      if (viewport.requestFullscreen) {
        viewport.requestPointerLock();
        viewport.requestFullscreen();
      }
    } else {
      if (document.exitFullscreen) {
        document.exitPointerLock();
        document.exitFullscreen();
      }
    }
  }
};

if (document.querySelector(".reeler")) {
  document.addEventListener("keydown", function(event) {
    if (event.key === "f") {
      reeler.toggleFullscreen();
    }
  });

  document.addEventListener("htmx:beforeTransition", function(event) {
    const slide = htmx.find("#slide");
    const data = event.detail.elt.dataset;

    htmx.removeClass(slide, "reeler-slide-left");
    htmx.removeClass(slide, "reeler-slide-right");

    if (data.direction === "forward") {
      htmx.addClass(slide, "reeler-slide-left");
    } else if (data.direction === "backward") {
      htmx.addClass(slide, "reeler-slide-right");
    };
  });
}
