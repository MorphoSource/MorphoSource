// code for handling site-wide modals

document.addEventListener("DOMContentLoaded", () => {

    const modal1 = document.getElementById("sitewide-modal");
    const modal2 = document.getElementById("sitewide-modal-2");

    function openModal(modal) {
      if (modal) {
        // Create overlay
        const overlay = document.createElement("div");
        overlay.classList.add("modal-overlay");
        overlay.id = "modal-overlay";
        document.body.appendChild(overlay);

        modal.style.display = "block";
        modal.setAttribute("aria-hidden", "false");
      }
    }

    function closeModal(modal) {
      if (modal) {
        document.activeElement.blur();
        modal.style.display = "none";
        modal.setAttribute("aria-hidden", "true");
        document.body.classList.remove("modal-open");

        // Remove overlay if it exists
        const overlay = document.getElementById("modal-overlay");
        if (overlay) overlay.remove();
      }
    }

    // Start with modal1 open
    openModal(modal1);

    // For pages that have a download form, open modal1 after form submission
    const downloadForm = document.getElementById("download-form");
    const downloadModal = document.getElementById("download-modal");
    const downloadModal2 = document.getElementById("download-modal-2");

    if (downloadForm) {
      downloadForm.addEventListener("submit", () => {
        setTimeout(() => {
          openModal(downloadModal);
        }, 500);
      });
    }

    // Attach click listeners to document (event delegation)
    document.body.addEventListener("click", function (e) {
      const target = e.target;

      if (target.matches(".maybe-later") || target.matches(".already-donated")) {
        e.preventDefault();
        closeModal(modal1);
        closeModal(downloadModal);
      }

      if (target.closest("#sitewide-modal") && target.matches(".no-thanks")) {
        e.preventDefault();
        closeModal(modal1);
        if (modal2) {
          openModal(modal2);
        }
      }

      if (target.matches("#download-modal .no-thanks")) {
        e.preventDefault();
        closeModal(downloadModal);
        if (modal2) {
          openModal(downloadModal2);
        }
      }

      if (target.matches("#sitewide-modal .not-now")) {
        e.preventDefault();
        closeModal(modal1);
      }

      if (target.matches("#sitewide-modal-2 .not-now")) {
        e.preventDefault();
        closeModal(modal2);
      }

      if (target.matches("#download-modal .not-now")) {
        e.preventDefault();
        closeModal(downloadModal);
      }

      if (target.matches("#download-modal-2 .not-now")) {
        e.preventDefault();
        closeModal(downloadModal2);
      }

      if (target.matches("#closeModal2")) {
        e.preventDefault();
        closeModal(modal2);
        closeModal(downloadModal2);
      }
    });

    // Escape key handling
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") {
        if (modal1 && modal1.style.display === "block") {
          closeModal(modal1);
          if (modal2) openModal(modal2);
        } else if (modal2 && modal2.style.display === "block") {
          closeModal(modal2);
        } else if (downloadModal && downloadModal.style.display === "block") {
          closeModal(downloadModal);
        } else if (downloadModal2 && downloadModal2.style.display === "block") {
          closeModal(downloadModal2);
        }
      }
    });

    // Click outside to close modal2 only
    if (modal2 || downloadModal2) {
      modal2.addEventListener("click", (e) => {
        if (e.target === modal2) {
          closeModal(modal2);
        } else if (e.target === downloadModal2) {
          closeModal(downloadModal2);
        }
      });
    }

    document.addEventListener("ajax:success", function (e) {
      const target = e.target;
      const siteModal = document.getElementById("sitewide-modal");
      const downModal = document.getElementById("download-modal");

      if (target.classList.contains("already-donated") || target.classList.contains("maybe-later")) {

        if (siteModal) {
          siteModal.style.display = "none";
          siteModal.setAttribute("aria-hidden", "true");
        } else if (downModal) {
          downModal.style.display = "none";
          downModal.setAttribute("aria-hidden", "true");
        }
      }
    });
  });
