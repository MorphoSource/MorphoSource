// these callback must be defined outside of document ready
function downloadRC2Callback() {
//    console.log(grecaptcha.getResponse() );
//    if (grecaptcha.getResponse() != null)
//      rc2Checked = true;
//    else
//      rc2Checked = false;
    checkAndShowDownload();

}
function downloadRC2ExpiredCallback() {
    console.log('rc2 expired')
    checkAndShowDownload();

}

function checkAndShowDownload() {
  //console.log('cr2 response ' + grecaptcha.getResponse().length );
  if ( grecaptcha.getResponse().length > 0 &&
    $('#modal-agree').prop('checked') &&
        $('#custom-usage').val().length >= 50 &&
          usageList() != "" )  {
    $('#modal-download').removeAttr('disabled');
  } else {
    $('#modal-download').attr('disabled', 'disabled');
  }  
  if ($('#custom-usage').val().length >= 50) 
    $('#char-alert, #describe-usage').removeClass('text-alert');
  else
    $('#char-alert, #describe-usage').addClass('text-alert');
  if (usageList() != "") 
    $('#select-categories').removeClass('text-alert');
  else
    $('#select-categories').addClass('text-alert');

}

function checkAndShowRequestDownload() {
  if ( $('#modal-request-download-agree').prop('checked') &&
        $('#intended_use').val().length >= 50 )  {
    $('#modal-request-download').removeAttr('disabled');
  } else {
    $('#modal-request-download').attr('disabled', 'disabled');
  }  
  if ($('#intended_use').val().length >= 50) 
    $('#char-alert, #describe-intended-use').removeClass('text-alert');
  else
    $('#char-alert, #describe-intended-use').addClass('text-alert');
}

function usageList() {
  var usage_list_array = $('.profile-checkbox-list input[type=checkbox]:checked').map(function(_, el) {
    return $(el).val();
  })
  var other = $('.profile-checkbox-list input[type=text][name="user[intent][]"]').val();
  if (other != '') {
    usage_list_array.push(other);
  }   
  return usage_list_array.get().join(';');
} 

$( document ).ready(function() {
  var downloadForm = $('form#form-download-selected');
  isMediaPage = ($('#media-page-download-agreements').length);
  isCartPage = (downloadForm.length);
  isRequestPage = ($('.my-requests').length);

  function sendSelectedItemsToModal() {
    var selectedItems = $('.batch_document_selector.downloadable_items:checked').clone();    
    $('form#download-form .download-items-wrapper').html(selectedItems);
  }

  function sendSelectedRestrictedItemsToModal() {
    var selectedItems = $('.batch_document_selector.restricted_items:checked').clone();    
    $('form#request-download-form .download-items-wrapper').html(selectedItems);
  }

  if ( isCartPage ) {
    
    $(downloadForm).find('input[type="submit"]').bind('click', function(e) {
      // download selected button clicked
      e.preventDefault();
      sendSelectedItemsToModal();
      showAgreementModal();
    });

    $('#download-all').bind('click', function(e) {
      // download all clicked - no item ids are enumerated client-side; #download-form is
      // submitted with an empty .download-items-wrapper, so MediaCartsController#download
      // falls back to every downloadable item in the cart, regardless of pagination or size.
      e.preventDefault();
      document.querySelector('form#download-form .download-items-wrapper').innerHTML = '';
      setAgreementsForAll();
    });

    $('.unrestricted_documents input[type="checkbox"]').bind('click', function(e) {
      set_agreements();
    });

  }

  if ( isCartPage || isRequestPage ) {

    $('.restricted_documents input[type="checkbox"]').bind('click', function(e) {
      set_agreements_for_restricted();
    });

    $('.btn-download-item').bind('click', function(e) {
      // download individual item clicked
      e.preventDefault();
      var itemId = $(this).attr('data-item-id');
      uncheckAllDownloadable();
      $("input[id='batch_download_" + itemId + "']").trigger('click');
      sendSelectedItemsToModal();
      showAgreementModal();
    });
    $('.btn-request-download-item').bind('click', function(e) { 
      // request download individual item button clicked
      e.preventDefault();
      var itemId = $(this).attr('data-item-id');
      uncheckAllRestricted();
      $("input[id='batch_document_" + itemId + "']").trigger('click');
      sendSelectedRestrictedItemsToModal();
    });  
    // reset things on request download modal close
    $("#pageModal").on("hidden.bs.modal", function () {
      // remove selected items from modal
      $('form#request-download-form .download-items-wrapper').html('');  
      uncheckAllRestricted();
      $("#check_all_restricted").prop('checked', false);
      $("#request-selected, #delete-selected-restricted").prop('disabled', true);
    });
  }

  if ( isMediaPage || isCartPage || isRequestPage ) {

    clearProfileForm(); // initially clear any fields that have been pre-filled with profile settings

    function clearProfileForm() {
      $('.profile-checkbox-list input[type=checkbox]').prop("checked", false);
      $('.profile-checkbox-list input[type=text][name="user[intent][]"]').val('');
    }

    $("#pageModal").on("show.bs.modal", function () {
      // clear agreement checkbox whenever request download modal is shown
      $('#modal-request-download-agree').prop('checked', false);
    });
       
    if ( isMediaPage ) {
      $('.btn-download-item').bind('click', function(e) { 
        // media page download button clicked
        e.preventDefault();
        set_agreements('CURRENT', $(this).attr('data-media-id'));
        showAgreementModal();
      });  
      $('.btn-request-download-item').bind('click', function(e) { 
        // media page request download button clicked
        e.preventDefault();
        set_agreements_for_restricted('CURRENT', $(this).attr('data-media-id'));
      });  
    }
  
    $(document).on('click', '#modal-agree', function(){
      checkAndShowDownload();
    });

    $(document).on('click', '#modal-request-download-agree', function(){
      checkAndShowRequestDownload();
    });

    $('.modal-body .checkbox-form-group input').change(function() {
      checkAndShowDownload();      
    });

    $('.profile-checkbox-list input[type=text][name="user[intent][]"]').keyup(function() {
      checkAndShowDownload();
    });

    $('#custom-usage').keyup(function() {
      var textlen = $(this).val().length;
      $('#rchars').text(textlen);
      checkAndShowDownload();
    });

    $('#intended_use').keyup(function() {
      var textlen = $(this).val().length;
      $('#intended-use-rchars').text(textlen);
      checkAndShowRequestDownload();
    });

    $('form#download-form').on('submit', function (e) {
      e.preventDefault();
      hideAgreementModal();

      var usage = $('#custom-usage').val();
      if ( $('#modal-agree').prop('checked') &&
        usage.length >= 50 && usageList() != "" )  {

        formType =$(this).attr('class');
        if (formType == 'download-selected') {
          console.log('downloading selected in cart');
          $('#batch_usage').val(usage);
          $('#batch_usage_list').val(usageList());
          this.submit();
        } else if (formType == 'download-single') {
          console.log('downloading single ');
          $(this).find("#g-recaptcha-response").attr('disabled', 'disabled');
          $('input[name=usage]').val(usage);
          $('input[name=usage_list]').val(usageList());
          this.submit();
        } else {
          alert('There is an error preparing for download');
        }

      } else {
        alert('Please make sure you have selected one or more categories and filled out your intended usage');
      }
    });

    $(document).on('click', '#get-profile-intent', function(){
      isProfileUsed = $(this).prop('checked');
      if (isProfileUsed) {
        $('form#download-form')[0].reset(); // this will re-populate the checkboxes and text field
        $('.modal-body .checkbox-form-group input').attr("disabled", true);
        this.checked = true;
      } else {
        clearProfileForm();        
        $('.modal-body .checkbox-form-group input').attr("disabled", false);
      }
      checkAndShowDownload();
    });

  }
});

function uncheckAllDownloadable() {
  $("input[type='checkbox'].downloadable_items").each(function(index, value) {
     value['checked'] = false;
  });
}

function uncheckAllRestricted() {
  $("input[type='checkbox'].restricted_items").each(function(index, value) {
     value['checked'] = false;
  });
}

function hideAgreementModal() {
  $('#downloadAgreementsModal').modal('hide');
}

function showAgreementModal() {
  $('#downloadAgreementsModal').modal('show');
  $('#modal-agree').prop('checked', false);
  $('#modal-download').attr('disabled', 'disabled');  

  // reset things on modal close
  $("#downloadAgreementsModal").on("hidden.bs.modal", function () {
    // remove selected items from modal
    $('form#download-form .download-items-wrapper').html('');
    uncheckAllDownloadable();
    $("#check_all_unrestricted").prop('checked', false);
    $("input#download-selected").prop('disabled', true);
  });
}

function setAgreementsForAll() {
  // Itemized agreement summary for every downloadable item in the cart, not just the
  // current page - fetched on demand only when Download All is clicked (one batched
  // Solr query server-side), rather than pre-rendering agreement data for the whole
  // cart on every page view regardless of whether it's ever used. The modal is only
  // shown once this data is ready, so there's no "Loading..." state a user could
  // glance at and mistake for the final (missing-links) content.
  document.querySelectorAll('input[name="ids[]"]').forEach(function(input) {
    input.value = 'ALL';
  });
  const modalDownloadBtn = document.querySelector('input#modal-download');
  if (modalDownloadBtn) {
    modalDownloadBtn.setAttribute('data-download-item-id', 'ALL');
  }

  // no-store: this reflects live cart state and must never be served from the browser's
  // HTTP cache or resolved via a 304 conditional revalidation against a stale response.
  fetch('/download_all_agreements', { cache: 'no-store' })
    .then(function(response) { return response.json(); })
    .then(function(data) {
      const agreements = data.map(function(item) { return item.agreement_description_html; });
      const customLinks = [];
      data.forEach(function(item) {
        if (item.custom_link_html) {
          customLinks.push('Media ' + item.media_id + ': ' + item.custom_link_html);
        }
      });
      const agreementGroup = groupCounts(agreements);
      const display = buildAgreements(agreementGroup, customLinks.sort());
      // Scoped to the download modal specifically - the cart page also has a second,
      // separate .agreement-items-wrapper inside the request modal (#pageModal, used
      // for requesting restricted items), rendered earlier in the DOM. Unlike jQuery's
      // $('.agreement-items-wrapper') (which updates every match), querySelector only
      // returns the first one, so this must be scoped or it silently writes into the
      // wrong (invisible) modal's wrapper.
      document.querySelector('#downloadAgreementsModal .agreement-items-wrapper').innerHTML = display;
      showAgreementModal();
    })
    .catch(function(error) {
      console.error('Failed to load Download All agreement summary:', error);
      document.querySelector('#downloadAgreementsModal .agreement-items-wrapper').innerHTML = '<p>Unable to load agreements. Please try again.</p>';
      showAgreementModal();
    });
}

function set_agreements(itemId, singleMediaId) {
  // set the agreement content in the download modal  
  if (itemId) {
    // set the item id in the button for download one item in the cart
    $('input[name="ids[]"]').val(singleMediaId);
    $('input#modal-download').attr('data-download-item-id', itemId);
    var agreementWrapper = '[data-item-id="' + itemId + '"] ';
    var agreementLink = $(agreementWrapper + '[data-field="agreement_description"]').html();
    var customLink = $(agreementWrapper + '[data-field="agreement_uri"] .showcase-link').html();
    var display = buildSingleAgreement(agreementLink, customLink);
    $('.agreement-items-wrapper').empty().append(display);
  } else {
    // set agreements for each checkbox checked
    var agreements = new Array();
    var customLinks = new Array();
    $('input[name="ids[]"]').val('SELECTED');
    $('input#modal-download').attr('data-download-item-id', 'SELECTED');
    var selectedCount = $("input[type='checkbox'].downloadable_items:checked").length;
    $("input[type='checkbox'].downloadable_items:checked").each(function() {
      var itemId = $(this).val();
      var agreementWrapper = '[data-item-id="' + itemId + '"] ';
      var mediaId = $(agreementWrapper + '[data-field="media_doc_id"]').attr('data-value');
      var agreementLink = $(agreementWrapper + '[data-field="agreement_description"]').html();
      agreements.push(agreementLink);
      var customLink = $(agreementWrapper + '[data-field="agreement_uri"] .showcase-link').html();
      if (customLink) {
        customLinks.push('Media ' + mediaId + ': ' + customLink);
      }
    });
    var agreementGroup = groupCounts(agreements);
    var display = buildAgreements(agreementGroup, customLinks.sort());
    $('.agreement-items-wrapper').empty().append(display);
  }
}

function set_agreements_for_restricted(itemId, singleMediaId) {
  // set the agreement content in the request download modal  
  if (itemId) {
    // set the item id in the button for download one item in the cart
    $('input[name="ids[]"]').val(singleMediaId);
    $('input#modal-download').attr('data-download-item-id', itemId);
    var agreementWrapper = '[data-item-id="' + itemId + '"] ';
    var agreementLink = $(agreementWrapper + '[data-field="agreement_description"]').html();
    var customLink = $(agreementWrapper + '[data-field="agreement_uri"] .showcase-link').html();
    var display = buildSingleAgreement(agreementLink, customLink);
    $('.agreement-items-wrapper').empty().append(display);
  } else {
    // set agreements for each checkbox checked
    var agreements = new Array();
    var customLinks = new Array();
    var selectedCount = $("input[type='checkbox'].restricted_items:checked").length;
    $("input[type='checkbox'].restricted_items:checked").each(function() {
      var itemId = $(this).val();
      var agreementWrapper = '[data-item-id="' + itemId + '"] ';
      var mediaId = $(agreementWrapper + '[data-field="media_doc_id"]').attr('data-value');
      var agreementLink = $(agreementWrapper + '[data-field="agreement_description"]').html();
      agreements.push(agreementLink);
      var customLink = $(agreementWrapper + '[data-field="agreement_uri"] .showcase-link').html();
      if (customLink) {
        customLinks.push('Media ' + mediaId + ': ' + customLink);
      }
    });
    var agreementGroup = groupCounts(agreements);
    var display = buildAgreements(agreementGroup, customLinks.sort());
    $('.agreement-items-wrapper').empty().append(display);
  }
}

function buildSingleAgreement(agreement, customLink) {
  var html = "<ul>";
  html += "  <li>" + agreement + "</li>";
  if (customLink)
    html += "  <li>" + customLink + "</li>";
  html += "</ul>";
  wrapper = [
    "<div class='agreement-items'>",
    html,
    "</div>"
  ].join("\n");

  return wrapper;
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

