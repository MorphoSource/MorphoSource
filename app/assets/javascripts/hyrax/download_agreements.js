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
      checkAndShowDownload();
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

        var usage = $('#custom-usage').val();
        if (usage.length < 50) {
          alert('Please enter a minimum of 50 characters for your intended usage');
        } else {
          var usage_list = $('.profile-checkbox-list input[type=checkbox]:checked').map(function(_, el) {
            return $(el).val();
          })
          var other = $('.profile-checkbox-list input[type=text][name="user[intent][]"]').val();
          if (other != '') {
            usage_list.push(other);
          }        
          //console.log('usage_list: '+ usage_list);
          var link = $('#link-to-download-item-'+itemId).attr('href') + 
            "&usage=" + encodeURIComponent(usage) + "&usage_list=" + encodeURIComponent(usage_list.get().join(';'));
          $('#link-to-download-item-'+itemId).attr('href', link); 
          $('#link-to-download-item-'+itemId).trigger('click');    
        }


      } else {
        console.log('error: itemId missing');
      }
    });

    $('#custom-usage').keyup(function() {
      var textlen = $(this).val().length;
      $('#rchars').text(textlen);
      checkAndShowDownload();
    });

    $(document).on('click', '#get-profile-intent', function(){
      isChecked = $(this).prop('checked');
      $('.profile-checkbox-list input').attr("disabled", isChecked);
      $('form.edit_user')[0].reset(); // reset 
    });

  }
});

function checkAndShowDownload() {
  if ($('#modal-agree').prop('checked')) {
    if ($('#custom-usage').val().length >= 50) {
      $('#char-alert').removeClass('text-alert');
      $('#modal-download').removeAttr('disabled');
    } else {
      $('#char-alert').addClass('text-alert');
      $('#modal-download').attr('disabled', 'disabled');
    }
  } else {
    $('#modal-download').attr('disabled', 'disabled');
  }  
}

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

