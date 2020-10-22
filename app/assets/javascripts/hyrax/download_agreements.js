$( document ).ready(function() {

  var downloadForm = $('form#form-download-selected');
  var isMediaPage = ($('#media-page-download-agreements').length);
  var isCartPage = (downloadForm.length);

  if ( isCartPage ) {
    
    $(downloadForm).find('input[type="submit"]').bind('click', function(e) { 
      // download selected button clicked
      e.preventDefault();
      showAgreementModal();
    });

    $('#download-all').bind('click', function(e) { 
      // download all clicked
      e.preventDefault();
      $("input[type='checkbox'].downloadable_items").each(function(index, value) {
         value['checked'] = false;
      });
      $("#check_all_unrestricted").prop('checked', false);
      $("#check_all_unrestricted").trigger('click');
      showAgreementModal();
    });

    $('.btn-download-item').bind('click', function(e) { 
      // download item clicked
      e.preventDefault();
      var itemId = $(this).attr('data-item-id');
      set_agreements(itemId);
      showAgreementModal();
    });

    $('#unrestricted_documents input[type="checkbox"]').bind('click', function(e) {
      set_agreements();
    });

  }

  if ( isMediaPage || isCartPage ) {

    if ( isMediaPage ) {
      $('.btn-download-item').bind('click', function(e) { 
        // media page download button clicked
        e.preventDefault();
        set_agreements('CURRENT');
        showAgreementModal();
      });  
    }
  
    $(document).on('click', '#modal-agree', function(){
      if($(this).prop('checked')){
        $('#modal-download').removeAttr('disabled');
      } else {
        $('#modal-download').attr('disabled', 'disabled');
      }
    });

    $(document).on('click', '#modal-download', function(){
      var itemId = $(this).attr('data-download-item-id');
      console.log(' downloading item '+ itemId);
      $('#downloadAgreementsModal').modal('hide');
      if (itemId == 'SELECTED') {
        downloadForm.submit();
      } else if (itemId == 'CURRENT') { 
        jQuery('#hidden-file-download')[0].click();
      } else if (itemId != '') { 
        $('#link-to-download-item-'+itemId).trigger('click');      
      } else {
        console.log('error: itemId missing');
      }
    });

  }
});

function showAgreementModal() {
  $('#downloadAgreementsModal').modal('show');
  $('#modal-agree').prop('checked', false);
  $('#modal-download').attr('disabled', 'disabled');
}

function set_agreements(itemId) {
  // set the agreement content in the modal  
  var agreements = new Array();
  var customLinks = new Array();

  if (itemId) {
      // set the item id in the button for download one item
      $('input#modal-download').attr('data-download-item-id', itemId);

      var agreementWrapper = '[data-item-id="' + itemId + '"] ';
      var mediaId = $(agreementWrapper + '[data-field="media_doc_id"]').attr('data-value');
      //var agreementDesc = $(agreementWrapper + '[data-field="agreement_description"]').attr('data-value');
      var agreementLink = $(agreementWrapper + '[data-field="agreement_description"]').html();
      agreements.push(agreementLink);
      var customLink = $(agreementWrapper + '[data-field="agreement_uri"] .showcase-link').html();
      if (customLink) {
        customLinks.push('Media ' + mediaId + ': ' + customLink);
      }

  } else {

    $('input#modal-download').attr('data-download-item-id', 'SELECTED');

    $("input[type='checkbox'].downloadable_items:checked").each(function() {
      var itemId = $(this).val();

      var agreementWrapper = '[data-item-id="' + itemId + '"] ';
      var mediaId = $(agreementWrapper + '[data-field="media_doc_id"]').attr('data-value');
      //var agreementDesc = $(agreementWrapper + '[data-field="agreement_description"]').attr('data-value');
      var agreementLink = $(agreementWrapper + '[data-field="agreement_description"]').html();
      agreements.push(agreementLink);
      var customLink = $(agreementWrapper + '[data-field="agreement_uri"] .showcase-link').html();
      if (customLink) {
        customLinks.push('Media ' + mediaId + ': ' + customLink);
      }

    });

  }

  var agreementGroup = groupCounts(agreements);
  var display = buildAgreements(agreementGroup, customLinks.sort());
  $('.agreement-items-wrapper').empty().append(display);
}

function buildAgreements(agreementGroup, customLinks) {
  var html = "<ul>";
  jQuery.each(agreementGroup, function(desc, count) {
    html += "  <li>" + count + " media: " + desc + "</li>";
  });
  jQuery.each(customLinks, function(index, link) {
    html += "  <li>" + link + "</li>";
  });
  html += "</ul>";
  wrapper = [
    "<div class='agreement-items'>",
    html,
    "</div>"
  ].join("\n");

  return wrapper;
}

function groupCounts(items) {
  counts = {};
  jQuery.each(items, function(key,value) {
    if (!counts.hasOwnProperty(value)) {
      counts[value] = 1;
    } else {
      counts[value]++;
    }
  });

  return counts;
}

