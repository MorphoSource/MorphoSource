$( document ).ready(function() {

  var downloadForm = $('form#form-download-selected');
  var isMediaPage = ($('#media-page-download-agreements').length);
  var isCartPage = (downloadForm.length);
  var isRequestPage = ($('.my-requests').length);

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

    $('#unrestricted_documents input[type="checkbox"]').bind('click', function(e) {
      set_agreements();
    });

  }

  if ( isCartPage || isRequestPage ) {
    $('.btn-download-item').bind('click', function(e) { 
      // download item clicked
      e.preventDefault();
      var itemId = $(this).attr('data-item-id');
      set_agreements(itemId);
      showAgreementModal();
    });
  }

  if ( isMediaPage || isCartPage || isRequestPage ) {

    clearProfileForm(); // initially clear any fields that have been pre-filled with profile settings

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

    function clearProfileForm() {
      $('.profile-checkbox-list input[type=checkbox]').prop("checked", false);
      $('.profile-checkbox-list input[type=text][name="user[intent][]"]').val('');
    }

    function checkAndShowDownload() {
      if ( $('#modal-agree').prop('checked') &&
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
       
    if ( isMediaPage ) {
      $('.btn-download-item').bind('click', function(e) { 
        // media page download button clicked
        e.preventDefault();
        set_agreements('CURRENT');
        showAgreementModal();
      });  
    }
  
    $(document).on('click', '#modal-agree', function(){
      checkAndShowDownload();
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

    $(document).on('click', '#modal-download', function(){
      if ( $('#modal-agree').prop('checked') &&
            $('#custom-usage').val().length >= 50 &&
              usageList() != "" )  {

        var itemId = $(this).attr('data-download-item-id');
        //console.log(' downloading item '+ itemId);
        $('#downloadAgreementsModal').modal('hide');
        var usage = $('#custom-usage').val();
        if (itemId == 'SELECTED') {
          console.log('item(s) selected in cart');
          $('#batch_usage').val(usage);
          $('#batch_usage_list').val(usageList());
          downloadForm.submit();
        } else if (itemId == 'CURRENT') { 
          console.log('current item download in media page');
          var link = $('#hidden-file-download').attr('href') + 
            "&usage=" + encodeURIComponent(usage) + "&usage_list=" + encodeURIComponent(usageList());
          $('#hidden-file-download').attr('href', link); 
          jQuery('#hidden-file-download')[0].click();
        } else if (itemId != '') { 
          console.log("(single) download item button in cart or my request");
          var link = $('#link-to-download-item-'+itemId).attr('href') + 
            "&usage=" + encodeURIComponent(usage) + "&usage_list=" + encodeURIComponent(usageList());
          $('#link-to-download-item-'+itemId).attr('href', link); 
          //alert(link);
          $('#link-to-download-item-'+itemId).trigger('click');    
        } else {
          console.log('error: itemId missing');
        }        
      } else {
        alert('Please make sure you have selected one or more categories and filled out your intended usage');
      }
    });

    $(document).on('click', '#get-profile-intent', function(){
      isProfileUsed = $(this).prop('checked');
      if (isProfileUsed) {
        $('form.edit_user')[0].reset(); // this will re-populated the checkboxes and text field
        $('.modal-body .checkbox-form-group input').attr("disabled", true);
      } else {
        clearProfileForm();        
        $('.modal-body .checkbox-form-group input').attr("disabled", false);
      }
      checkAndShowDownload();
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

  if (itemId) {
    // set the item id in the button for download one item
    $('input#modal-download').attr('data-download-item-id', itemId);
    var agreementWrapper = '[data-item-id="' + itemId + '"] ';
    var agreementLink = $(agreementWrapper + '[data-field="agreement_description"]').html();
    var customLink = $(agreementWrapper + '[data-field="agreement_uri"] .showcase-link').html();
    var display = buildSingleAgreement(agreementLink, customLink);
    $('.agreement-items-wrapper').empty().append(display);

  } else {

    var agreements = new Array();
    var customLinks = new Array();
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

