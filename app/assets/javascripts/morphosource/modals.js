// code for handling site-wide modals

document.addEventListener("DOMContentLoaded", () => {

    const modal1 = document.getElementById("sitewideModal");
    const modal2 = document.getElementById("sitewideModal2");
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
      }
    }

    function showAgreementsModal() {
      if (agreementsModal) {
        $('#downloadAgreementsModal').modal('show');
        $('#modal-agree').prop('checked', false);
        $('#modal-download').attr('disabled', 'disabled');

        // reset things on modal close
        $("#downloadAgreementsModal").on("hidden.bs.modal", function () {
          // remove selected items from modal
          $('form#download-form .download-items-wrapper').html('');
          $("input[type='checkbox'].downloadable_items").each(function(index, value) {
            value['checked'] = false;
          });
          $("#check_all_unrestricted").prop('checked', false);
          $("input#download-selected").prop('disabled', true);
        });
      }
    }

    // Start with modal1 open, unless on a page that has a download agreement modal
    // if (modal1 && !agreementsModal) {

      openModal(modal1);

    // }

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
        showAgreementsModal();
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
