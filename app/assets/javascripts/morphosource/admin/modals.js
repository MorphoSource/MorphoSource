// Manages the modal configuration page

$(document).ready(function() {
  // Return if not on the modal configuration page
  if (!document.body.classList.contains("modal-config")) return;

  const testModal = document.getElementById("test-modal");
  // const testModal = $('#test-modal')
  const guiltTripModal = document.getElementById("test-guilt-trip-modal");
  // const guiltTripModal = $('#test-guilt-trip-modal')

  function openModal(modal) {
    if (modal) {
      modal.style.display = "block";
      modal.setAttribute("aria-hidden", "false");
      modal.classList.add("in");
      document.querySelectorAll(modal.id + ' *').forEach((el) => {
        if (el.style.display === 'none') {
          el.style.removeProperty('display');
        }
      });
    }
  }

  function closeModal(modal) {
    if (modal) {
      document.activeElement.blur();
      modal.style.display = "none";
      modal.setAttribute("aria-hidden", "true");
      modal.classList.remove("in");
      document.body.classList.remove("modal-open", "no-scroll");
      // Remove any leftover overlays
      document.querySelectorAll(".modal-backdrop, .overlay").forEach((el) => el.remove());
    }
  }

  // Populate the example modal with initial form values
  var initialValue = $('#admin_modal_sitewide_modal_template').val()
  $("." + initialValue).show();
  var clonedElement = $("." + initialValue).clone();
  outerHTML = clonedElement[0].outerHTML;
  $('#test-modal').empty().append(outerHTML);

  // Populate the example guilt trip modal with initial form values
  var initialValue = $('#admin_modal_guilt_trip_template').val()
  if (initialValue.length) {
    $("." + initialValue + "2").show();
    var clonedElement = $("." + initialValue).clone();
    clonedElement.show();
    outerHTML = clonedElement[0].outerHTML;
    $('#test-guilt-trip-modal').empty().append(outerHTML);
  }

  // Display the selected modal template as the example
  $('#admin_modal_sitewide_modal_template').change(function() {
    var selectedValue = $(this).val();
    $( ".modal-example" ).css( "display", "none" );
    $("." + selectedValue).show();

    var clonedElement = $("." + selectedValue).clone();
    outerHTML = clonedElement[0].outerHTML;
    $('#test-modal').empty().append(outerHTML);
  });

  // Display the selected guilt trip template as the example
  $('#admin_modal_guilt_trip_template').change(function() {
    var selectedValue = $(this).val();
    $( ".guilt-trip-example" ).css( "display", "none" );
    $("." + selectedValue + "2").show();
    if (!selectedValue.length) {
      $('#test-guilt-trip-modal').empty();
      return;
    } else {
      var clonedElement = $("." + selectedValue).clone();
      clonedElement.show();
      outerHTML = clonedElement[0].outerHTML;
      $('#test-guilt-trip-modal').empty().append(outerHTML);
    }
  });

  // Update the example modal title when it's changed in the form
  $('#admin_modal_sitewide_modal_title').change(function() {
    var selectedValue = $(this).val();
    $( ".modal-example .modal-title" ).text(selectedValue);
  });

  // Update the example guilt trip modal title when it's changed in the form
  $('#admin_modal_guilt_trip_title').change(function() {
    var selectedValue = $(this).val();
    $( ".guilt-trip-example .modal-title" ).text(selectedValue);
  });

  // Update the example modal bodies with the Trix editor content
  document.addEventListener("trix-change", function(event) {
    const editor = event.target;
    const inputId = editor.getAttribute("input");
    const hiddenInput = document.getElementById(inputId);
    const value = hiddenInput.value;

    if (editor.id === "admin_modal_sitewide_modal_body") {
      document.querySelectorAll(".modal-example .modal-text").forEach(function(el) {
        el.innerHTML = value;
      });
    } else if (editor.id === "admin_modal_guilt_trip_body") {
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
        closeModal(testModal);
        if ($('#admin_modal_guilt_trip_template').val().length) {
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