// Overrides hyrax/app/assets/javascripts/hyrax/ga_events.js
// in order to use gtag.js library instead of legacy ga.js

// Documentation: https://developers.google.com/analytics/devguides/collection/gtagjs/events

// Download from Showcase Media Page
$(document).on('click', '#file_download', function(e) {
  gtag('event', 'Downloaded', {
    'event_category': 'Files',
    'event_label': $(this).data('label')
  });
});

// Media Cart

// Get Work Ids from Checkbox Inputs
function getIds(inputs){
  var ids = [];
  inputs.each(function(){
    let document_id = this.closest('tr').id
    let n = document_id.lastIndexOf('_');
    let work_id = document_id.substring(n+1);
    if (work_id != "") {
      ids.push(work_id)
    }
  });
  return ids
}

// Send GTag
function createGTags(workIds){
  workIds.forEach(function(workId){
    gtag('event', 'Downloaded', {
      'event_category': 'Files',
      'event_label': workId
    });
  });
}

// Media Cart - Download All
function getUnrestrictedWorkIds() {
  var allItems = $('#unrestricted_documents').find(':checkbox');
  return getIds(allItems);
}

$(document).on('click', '#download-all', function(e) {
  var workIds = getUnrestrictedWorkIds();
  createGTags(workIds);
});

// Media Cart - Download Selected
function getWorkIds() {
  var checkedItems = $('#unrestricted_documents').find('input:checked');
  return getIds(checkedItems);
}

$(document).on('click', '#download-selected', function(e) {
  var workIds = getWorkIds();
  createGTags(workIds);
});
