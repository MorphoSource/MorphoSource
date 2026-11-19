$(document).ready(function() {
  const block = document.getElementById('media-download-reviewers');
  if (!block) { return; }

  const pickerRow = document.getElementById('media-record-download-reviewers');
  const picker = document.getElementById('media_record_download_reviewer_users');
  const ownRadio = document.getElementById('media_download_reviewer_mode_record_users');
  const radios = block.querySelectorAll('input[type="radio"]');
  const notRestrictedNotice = document.getElementById('media-download-reviewers-not-restricted');
  const permissionInput = document.getElementById('media_download_permission');

  $(picker).userSearchMultiple($(picker).data('reviewers'));

  function syncPickerRow() {
    // Hide only: clearing the picker here would wipe the stored record list on save.
    pickerRow.classList.toggle('d-none', !ownRadio.checked);
  }

  function setGate(restricted) {
    radios.forEach(function(radio) {
      radio.disabled = !restricted || radio.hasAttribute('data-org-blocked');
    });
    picker.disabled = !restricted;
    $(picker).select2('enable', restricted);
    block.classList.toggle('text-muted', !restricted);
    notRestrictedNotice.classList.toggle('d-none', restricted);
  }

  radios.forEach(function(radio) {
    radio.addEventListener('change', syncPickerRow);
  });

  $('.download-permission-dropdown a').on('click', function() {
    setGate(this.id === 'restricted_download');
  });

  setGate(permissionInput ? permissionInput.value === 'restricted_download' : !picker.disabled);
  syncPickerRow();
});
