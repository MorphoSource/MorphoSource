// code for handling site-wide modals

function initSitewideModals() {
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
    console.log("Opening modal:", modal.id);

    ensureOverlay();
    // Use aria-hidden as the state flag; CSS can handle display via [aria-hidden]
    modal.setAttribute("aria-hidden", "false");

    // Also set inline display for safety if your CSS isn't in yet
    modal.style.display = "block";

    document.body.classList.add("modal-open");
  }

  function closeModal(modal) {
    if (!modal) return;
    console.log("Closing modal:", modal.id);

    modal.setAttribute("aria-hidden", "true");
    modal.style.display = "none";

    // Remove overlay only if no other configured modal is open
    removeOverlayIfNoneOpen();
  }

  // HARD RESET at init: force everything hidden, then open what you want.
  [modal1, modal2, downloadModal, downloadModal2].forEach((m) => {
    if (!m) return;
    m.setAttribute("aria-hidden", "true");
    m.style.display = "none";
  });

  // Start with modal1 open (if present)
  openModal(modal1);

  // After download form submission, open download modal
  if (downloadForm) {
    downloadForm.addEventListener("submit", () => {
      setTimeout(() => openModal(downloadModal), 500);
    });
  }

  // Delegated clicks using closest() (more reliable than matches())
  document.body.addEventListener("click", function (e) {
    const maybeLater = e.target.closest("a.maybe-later");
    const alreadyDonated = e.target.closest("a.already-donated");
    const noThanksSite1 = e.target.closest("#sitewide-modal a.no-thanks");
    const notNowSite2 = e.target.closest("#sitewide-modal-2 a.not-now");
    const notNowSite1 = e.target.closest("#sitewide-modal a.not-now");

    const noThanksDownload = e.target.closest("#download-modal a.no-thanks");
    const notNowDownload = e.target.closest("#download-modal a.not-now");
    const notNowDownload2 = e.target.closest("#download-modal-2 a.not-now");

    if (maybeLater || alreadyDonated) {
      e.preventDefault();
      closeModal(modal1);
      closeModal(downloadModal);
      return;
    }

    if (noThanksSite1) {
      e.preventDefault();
      closeModal(modal1);
      openModal(modal2);
      return;
    }

    if (notNowSite1) {
      e.preventDefault();
      closeModal(modal1);
      return;
    }

    if (notNowSite2) {
      e.preventDefault();
      closeModal(modal2);
      return;
    }

    if (noThanksDownload) {
      e.preventDefault();
      closeModal(downloadModal);
      openModal(downloadModal2);
      return;
    }

    if (notNowDownload) {
      e.preventDefault();
      closeModal(downloadModal);
      return;
    }

    if (notNowDownload2) {
      e.preventDefault();
      closeModal(downloadModal2);
      return;
    }
  });

  // Escape closes whichever is open (with your “modal1 -> modal2” behavior)
  document.addEventListener("keydown", function (e) {
    if (e.key !== "Escape") return;

    if (modal1?.getAttribute("aria-hidden") === "false") {
      closeModal(modal1);
      if (modal2) openModal(modal2);
      return;
    }
    if (modal2?.getAttribute("aria-hidden") === "false") {
      closeModal(modal2);
      return;
    }
    if (downloadModal?.getAttribute("aria-hidden") === "false") {
      closeModal(downloadModal);
      return;
    }
    if (downloadModal2?.getAttribute("aria-hidden") === "false") {
      closeModal(downloadModal2);
      return;
    }
  });

  // Backdrop click: close only when clicking the backdrop element itself
  [modal2, downloadModal2].filter(Boolean).forEach((m) => {
    m.addEventListener("click", (e) => {
      if (e.target === m) closeModal(m);
    });
  });

  // If you're using rails-ujs: hide the modal that the clicked link belongs to
  document.addEventListener("ajax:success", function (e) {
    const link = e.target.closest("a.already-donated, a.maybe-later");
    if (!link) return;

    const parentModal = link.closest("#sitewide-modal, #download-modal");
    if (!parentModal) return;

    closeModal(parentModal);
  });
}

// Turbo + non-Turbo support
document.addEventListener("turbo:load", initSitewideModals);
document.addEventListener("DOMContentLoaded", initSitewideModals);
