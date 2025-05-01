// Manages the modal configuration page

$(document).ready(function() {
  if (!document.body.classList.contains("modal-config")) return;
  const form = document.querySelector("form#modal-form");
  if (form) {
    form.addEventListener("keydown", function (e) {
      if (e.key === "Enter") {
        e.preventDefault();
      }
    });
  }

  var initialValue = $('#admin_modal_sitewide_modal_template').val()
  $("." + initialValue).show();
  var clonedElement = $("." + initialValue).clone();
  outerHTML = clonedElement[0].outerHTML;
  $('#testModal').html(outerHTML);

  $('#admin_modal_sitewide_modal_template').change(function() {
    var selectedValue = $(this).val();
    $( ".modal-example" ).css( "display", "none" );
    $("." + selectedValue).show();

    var clonedElement = $("." + selectedValue).clone();
    outerHTML = clonedElement[0].outerHTML;
    $('#testModal').html(outerHTML);
  });

  $('#admin_modal_sitewide_modal_title').change(function() {
    var selectedValue = $(this).val();
    $( ".modal-title" ).text(selectedValue);
  });

  $('#admin_modal_sitewide_modal_body').change(function() {
    var selectedValue = $(this).val();
    $( ".modal-text" ).text(selectedValue);
  });

  const testModal = document.getElementById("testModal");

  if (testModal) {
    testModal.addEventListener("click", (e) => {
      const target = e.target;

      if (target.closest("button, a")) {
        document.activeElement.blur();
        testModal.style.display = "none";
        testModal.setAttribute("aria-hidden", "true");
        document.querySelectorAll(".modal-backdrop").forEach((backdrop) => {
          backdrop.remove();
        });
      }
    });
  }

});