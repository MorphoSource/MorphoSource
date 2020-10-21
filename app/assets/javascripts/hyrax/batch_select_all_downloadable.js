
$( document ).ready(function() {

  downloadForm = $('form#form-download-selected');
  //if ( $('.cart-page').length ) {
  if ( downloadForm.length ) {
    
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
//      $('[type="checkbox"][id="batch_download_' + itemId + '"]').trigger('click');
      set_agreements(itemId);
      showAgreementModal();
    });

    $('#unrestricted_documents input[type="checkbox"]').bind('click', function(e) {
      set_agreements();
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
    if (itemId == 'SELECTED') {
      downloadForm.submit();
    } else if (itemId != '') { 
      $('#link-to-download-item-'+itemId).trigger('click');      
    } else {
      console.log('error: itemId missing');
    }
    $('#downloadAgreementsModal').modal('hide');
  });

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


// function to hide or show the batch update buttons based on how may items are checked
function toggleButtons(forceOn, otherPage ){
  forceOn = typeof forceOn !== 'undefined' ? forceOn : false
  otherPage = typeof otherPage !== 'undefined' ? otherPage : !window.batch_part_on_other_page;
  var n = $(".batch_document_selector:checked").length;
  if ((n>0) || (forceOn)) {
      $('.batch-toggle').show();
      $('.batch-select-all').removeClass('hidden');
      $('#batch-edit').removeClass('hidden');
  } else if ( otherPage){
      $('.batch-toggle').hide();
      $('.batch-select-all').addClass('hidden');
      $('#batch-edit').addClass('hidden');
  }
  $("body").css("cursor", "auto");
}


// change the state of a cog menu item and add or remove the check beside it
// using on or off instead of true or false
function toggleState (obj, state) {
  toggleStateBool(obj, state == 'on');
}

// change the state of a cog menu item and add or remove the check beside it
function toggleStateBool (obj, state) {
  if (state){
    obj.attr("data-state", 'on');
    obj.find('a i').addClass('glyphicon glyphicon-ok');
  }else {
    obj.attr("data-state", 'off');
    obj.find('a i').removeClass('glyphicon glyphicon-ok');
  }

}


// check all the check boxes on the page
function check_all_downloadable_page(e) {
  // get the check box state
  var checked = $("#check_all_unrestricted")[0]['checked'];

  // check each individual box
  $("input[type='checkbox'].downloadable_items").each(function(index, value) {
     value['checked'] = checked;
  });
  toggleButtons();

  // set menu check marks
  toggleStateBool($("[data-behavior='batch-edit-select-page']"),checked);
  toggleStateBool($("[data-behavior='batch-edit-select-none']"),!checked);

}

// check all the restricted check boxes on the page
function check_all_restricted_page(e) {
  // get the check box state
  var checked = $("#check_all_restricted")[0]['checked'];

  // check each individual box
  $("input[type='checkbox'].restricted_items").each(function(index, value) {
     value['checked'] = checked;
  });
  toggleButtons();

  // set menu check marks
  toggleStateBool($("[data-behavior='batch-edit-select-page']"),checked);
  toggleStateBool($("[data-behavior='batch-edit-select-none']"),!checked);

}

// turn page selection on or off
// state == true for on
function select_page ( state) {
  // check everything on the current page on or off based on state
  // $("#check_all_unrestricted").prop('checked', state);
  $("#check_all_restricted").prop('checked', state);
  // check_all_downloadable_page();
  check_all_restricted_page();
}


Blacklight.onLoad(function() {
// check the select all page cog menu item and select the entire page
$("[data-behavior='batch-edit-select-page']").bind('click', function(e) {
  e.preventDefault();
  select_page(true);
});

// check the select none cog menu item and de-select the entire page
$("[data-behavior='batch-edit-select-none']").bind('click', function(e) {
  e.preventDefault();
  select_page(false);
});

// check all check boxes
$("#check_all_unrestricted").bind('click', check_all_downloadable_page);

// check all check boxes
$("#check_all_restricted").bind('click', check_all_restricted_page);

// select/deselect all check boxes
$("#checkAllBox").change(function () {
  $("input:checkbox").prop('checked', $(this).prop("checked"));
});

// toggle button on or off based on boxes being clicked
$(".batch_document_selector").bind('click', function(e) {
   toggleButtons();
});

// toggle the state of the select boxes in the cog menu if all buttons are
$(".batch_document_selector").bind('click', function(e) {

    // count the check boxes currently checked
    var selectedCount = $(".batch_document_selector:checked").length;

    // toggle the cog menu check boxes
    toggleStateBool($("[data-behavior='batch-edit-select-page']"),selectedCount == window.document_list_count);
    toggleStateBool($("[data-behavior='batch-edit-select-none']"),selectedCount == 0);

    // toggle the check all check box
    $("#check_all").attr('checked', (selectedCount == window.document_list_count));

  });

  if ($("#check_all").length > 0) select_page(false);

});
