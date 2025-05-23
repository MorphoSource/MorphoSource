// code for handling site-wide modals

document.addEventListener("DOMContentLoaded", () => {

    const modal1 = document.getElementById("sitewide-modal");
    const modal2 = document.getElementById("sitewide-modal-2");
    const agreementsModal = document.getElementById('downloadAgreementsModal');

    function openModal(modal) {
      if (modal) {
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
      }
    }

    // Start with modal1 open
    openModal(modal1);

    // For pages that have a download form, open modal1 after form submission
    const downloadForm = document.getElementById("download-form");

    if (downloadForm) {
      downloadForm.addEventListener("submit", () => {
        setTimeout(() => {
          openModal(modal1)
        }, 500);
      });
    }

    // Attach click listeners to document (event delegation)
    document.body.addEventListener("click", function (e) {
      const target = e.target;

      if (target.matches(".maybe-later") || target.matches(".already-donated")) {
        e.preventDefault();
        closeModal(modal1);
      }

      if (target.matches(".no-thanks")) {
        e.preventDefault();
        closeModal(modal1);
        if (modal2) {
          openModal(modal2);
        }
      }

      if (target.matches(".not-now")) {
        e.preventDefault();
        if (modal2) {
          closeModal(modal2);
        } else {
          closeModal(modal1);
        }
      }

      if (target.matches("#closeModal2")) {
        e.preventDefault();
        closeModal(modal2);
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
        }
      }
    });

    // Click outside to close modal2 only
    if (modal2) {
      modal2.addEventListener("click", (e) => {
        if (e.target === modal2) closeModal(modal2);
      });
    }

    document.addEventListener("ajax:success", function (e) {
      const target = e.target;

      if (target.classList.contains("already-donated") || target.classList.contains("maybe-later")) {
        const modal = document.getElementById("sitewideModal");
        if (modal) {
          modal.style.display = "none";
          modal.setAttribute("aria-hidden", "true");
        }
      }
    });
  });
