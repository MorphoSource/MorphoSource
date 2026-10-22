// code for handling site-wide modals

function initSitewideModals() {
  if (document.body.classList.contains("modal-config")) return;

  const modal1 = document.getElementById("sitewide-modal");
  const modal2 = document.getElementById("sitewide-modal-2");

  const downloadForm = document.getElementById("download-form");
  const downloadModal = document.getElementById("download-modal");
  const downloadModal2 = document.getElementById("download-modal-2");

  function ensureOverlay() {
    let overlay = document.getElementById("modal-overlay");
    if (!overlay) {
      overlay = document.createElement("div");
      overlay.classList.add("modal-overlay");
      overlay.id = "modal-overlay";
      document.body.appendChild(overlay);
    }
    return overlay;
  }

  function anyModalOpen() {
    return !!document.querySelector('.configured-modal[aria-hidden="false"]');
  }

  function removeOverlayIfNoneOpen() {
    if (!anyModalOpen()) {
      document.getElementById("modal-overlay")?.remove();
      document.body.classList.remove("modal-open");
    }
  }

  function openModal(modal) {
    if (!modal) return;
    ensureOverlay();
    modal.removeAttribute("hidden");
    modal.setAttribute("aria-hidden", "false");
    modal.style.display = "block";
    document.body.classList.add("modal-open");
  }

  function closeModal(modal) {
    if (!modal) return;
    modal.setAttribute("aria-hidden", "true");
    modal.style.display = "none";
    // Remove overlay only if no other configured modal is open
    removeOverlayIfNoneOpen();
  }

  // Dismiss via the modal's one-hour snooze button so the dismissal persists across pages
  function snoozeModal(modal) {
    const snoozeButton = modal?.querySelector(".snooze-form .maybe-later, .snooze-form .not-now");
    if (snoozeButton) {
      snoozeButton.click();
    } else {
      closeModal(modal);
    }
  }

  // force everything hidden
  [modal1, modal2, downloadModal, downloadModal2].forEach((m) => {
    if (!m) return;
    m.setAttribute("aria-hidden", "true");
    m.style.display = "none";
  });

  // Start with modal1 open
  openModal(modal1);

  // After download form submission, open download modal
  if (downloadForm) {
    downloadForm.addEventListener("submit", () => {
      setTimeout(() => openModal(downloadModal), 500);
    });
  }

  // Attach click listeners to document (event delegation)
  document.body.addEventListener("click", function (e) {
    const noThanksSite1 = e.target.closest("#sitewide-modal .no-thanks");
    const noThanksDownload = e.target.closest("#download-modal .no-thanks");
    const noThanksDownload2 = e.target.closest("#download-modal-2 .no-thanks");

    if (noThanksSite1) {
      e.preventDefault();
      closeModal(modal1);
      openModal(modal2);
      return;
    }
    if (noThanksDownload) {
      e.preventDefault();
      closeModal(downloadModal);
      openModal(downloadModal2);
      return;
    }
    if (noThanksDownload2) {
      e.preventDefault();
      snoozeModal(downloadModal2);
      return;
    }
  });

  // Escape key handling
  document.addEventListener("keydown", function (e) {
    if (e.key !== "Escape") return;

    if (modal1?.getAttribute("aria-hidden") === "false") {
      closeModal(modal1);
      if (modal2) openModal(modal2);
      return;
    }
    if (modal2?.getAttribute("aria-hidden") === "false") {
      snoozeModal(modal2);
      return;
    }
    if (downloadModal?.getAttribute("aria-hidden") === "false") {
      snoozeModal(downloadModal);
      return;
    }
    if (downloadModal2?.getAttribute("aria-hidden") === "false") {
      snoozeModal(downloadModal2);
      return;
    }
  });

  [modal2, downloadModal2].filter(Boolean).forEach((m) => {
    m.addEventListener("click", (e) => {
      if (e.target === m) snoozeModal(m);
    });
  });

  // Snooze forms close their modal only once the server has set the snooze cookie
  document.addEventListener("ajax:success", function (e) {
    const form = e.target.closest("form.snooze-form");
    if (!form) return;

    const parentModal = form.closest(".configured-modal");
    if (!parentModal) return;

    closeModal(parentModal);
  });

  document.addEventListener("ajax:error", function (e) {
    const form = e.target.closest("form.snooze-form");
    if (!form) return;

    form.closest(".configured-modal")?.querySelector(".snooze-error")?.removeAttribute("hidden");
  });

}

document.addEventListener("turbo:load", initSitewideModals);
document.addEventListener("DOMContentLoaded", initSitewideModals);