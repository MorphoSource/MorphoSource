$( document ).ready(function() {
  if ($('.exp-date-wrapper').length) { 
    $('input[name=expiration_date]').change(function() {
      if ($(this).val() == "") {
        $('input[name=exp-date-submit]').prop("disabled", true);
      } else {
        $('input[name=exp-date-submit]').prop("disabled", false);
      }
    });
  }
});