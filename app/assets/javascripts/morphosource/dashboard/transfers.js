$( document ).ready(function() {
  if ( $('div.ownership-transfer').length ) { // if contributor application form
    $(document).click(function (e) {
      var checkedStatus = this.checked;
      $('.batch_transfers').each(function() {
        $(this).prop('checked', checkedStatus);
      });
      if ($('input.batch_transfers:checked').length) {
        $('.btn#batch-decision-button').removeAttr('disabled');
      } else {
        $('.btn#batch-decision-button').attr('disabled', 'disabled');
      }
    });

    $('input.batch_transfers').on('change', function(e){
      if ($('input.batch_transfers:checked').length) {
        $('.btn#batch-decision-button').removeAttr('disabled');
      } else {
        $('.btn#batch-decision-button').attr('disabled', 'disabled');
        $('#select-all-for-decision').prop('checked', false);
      }
    });

    $('a.batch-decide').click(function (event) {
      event.preventDefault();
      if ($(this).hasClass('accept')) {
        addParamToForm('#batch-transfer-decide', 'decision', 'accept');
        if ($(this).hasClass('accept-reset')) {
          addParamToForm('#batch-transfer-decide', 'reset', 'true');
        }
        if ($(this).hasClass('accept-stick')) {
          addParamToForm('#batch-transfer-decide', 'sticky', 'true');
        }
      } else if ($(this).hasClass('reject')) {
        addParamToForm('#batch-transfer-decide', 'decision', 'reject');
      }

      $('form#batch-transfer-decide').submit();
      return false;
    });

    var addParamToForm = function(formId, paramName, paramValue) {
      $('<input />').attr('type', 'hidden')
        .attr('name', paramName)
        .attr('value', paramValue)
        .appendTo(formId);
    };
  }
});