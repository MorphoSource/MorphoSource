// Manages the modal configuration page

$(document).ready(function() {
  // Return if not on the modal configuration page
  if (!document.body.classList.contains("modal-config")) return;

  const testModal = document.getElementById("test-modal");
  const guiltTripModal = document.getElementById("test-guilt-trip-modal");
  const testModalBtn = document.querySelector('[data-target="#test-modal"]');

  if (testModalBtn) {
    testModalBtn.addEventListener("click", () => openModal(testModal));
  }

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

  function openModal(modal) {
    if (!modal) return;
    ensureOverlay();
    modal.removeAttribute("hidden");
    modal.style.display = "block";
    modal.setAttribute("aria-hidden", "false");
  }

  function closeModal(modal) {
    if (!modal) return;
    modal.style.display = "none";
    modal.setAttribute("aria-hidden", "true");
    document.querySelectorAll(".modal-overlay").forEach(el => el.remove());
  }

  // Populate the example modal with initial form values
  var initialValue = $('[id*="_modal_template"]').val();
  $("." + initialValue).show();
  var clonedElement = $("." + initialValue).clone();
  outerHTML = clonedElement[0].outerHTML;
  $('#test-modal').empty().append(outerHTML);

  // Populate the example guilt trip modal with initial form values
  var initialValue = $('[id*="_guilt_trip_template"]').val();
  if (initialValue.length) {
    $("." + initialValue + "2").show();
    var clonedElement = $("." + initialValue + "2").clone();
    clonedElement.show();
    outerHTML = clonedElement[0].outerHTML;
    $('#test-guilt-trip-modal').empty().append(outerHTML);
  }

  // Display the selected modal template as the example
  $('[id*="_modal_template"]').change(function() {
    var selectedValue = $(this).val();
    $( ".modal-example" ).css( "display", "none" );
    $("." + selectedValue).show();

    var clonedElement = $("." + selectedValue).clone();
    outerHTML = clonedElement[0].outerHTML;
    $('#test-modal').empty().append(outerHTML);
  });

  // Display the selected guilt trip template as the example
  $('[id*="_guilt_trip_template"]').change(function() {
    var selectedValue = $(this).val();
    $( ".guilt-trip-example" ).css( "display", "none" );
    $("." + selectedValue + "2").show();
    if (!selectedValue.length) {
      $('#test-guilt-trip-modal').empty();
      return;
    } else {
      var clonedElement = $("." + selectedValue + "2").clone();
      clonedElement.show();
      outerHTML = clonedElement[0].outerHTML;
      $('#test-guilt-trip-modal').empty().append(outerHTML);
    }
  });

  // Update the example modal title when it's changed in the form
  $('[id*="_modal_title"]').change(function() {
    var selectedValue = $(this).val();
    $( ".modal-example .modal-title" ).text(selectedValue);
  });

  // Update the example guilt trip modal title when it's changed in the form
  $('[id*="_guilt_trip_title"]').change(function() {
    var selectedValue = $(this).val();
    $( ".guilt-trip-example .modal-title" ).text(selectedValue);
  });

  // Update the example modal bodies with the Trix editor content
  document.addEventListener("trix-change", function(event) {
    const editor = event.target;
    const inputId = editor.getAttribute("input");
    const hiddenInput = document.getElementById(inputId);
    const value = hiddenInput.value;

    if (editor.id.endsWith('_modal_body')) {
      document.querySelectorAll(".modal-example .modal-text").forEach(function(el) {
        el.innerHTML = value;
      });
    } else if (editor.id.endsWith('_guilt_trip_body')) {
      document.querySelectorAll(".guilt-trip-example .modal-text").forEach(function(el) {
        el.innerHTML = value;
      });
    }
  });

  // Close the test modal
  // If there is a guilt trip modal selected, show that when the no-thanks button is clicked
  if (testModal) {
    testModal.addEventListener("click", (e) => {
      const target = e.target;
      if (target.matches(".no-thanks")) {
        e.preventDefault();
        closeModal(testModal);
        if ($('[id*="_guilt_trip_template"]').val().length) {
          openModal(guiltTripModal);
        }
      } else if (target.closest("button, a")) {
        closeModal(testModal);
      }
    });
  }

  if (guiltTripModal) {
    guiltTripModal.addEventListener("click", (e) => {
      const target = e.target;
      if (target.closest("button, a")) {
        closeModal(guiltTripModal);
      }
    });
  }
});