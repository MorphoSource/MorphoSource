
$( document ).ready(function() {
  if ($('form[data-param-key="device"], form[data-param-key="device_resource"], form[id*="device"]').length) { // if device form page

    removeLastRepeatable();

    $(document).on("submit", 'form[data-param-key="device"]', function() {
      disablePage();
    });

    // Select Organization Functions
    $(document).on("click", "#btn-select-device-organization", function() {
      var selected = null;

      if ($('#s2id_device_find_organization').length && typeof $('#s2id_device_find_organization').select2 === 'function') {
        selected = $('#s2id_device_find_organization').select2('data');
      }
      if (Array.isArray(selected)) selected = selected[0];
      if (!selected || !selected.id) {
        return false;
      }

      $('#device_resource_organization_id').val(selected.id);
      $('#selected-device-organization-label').text(selected.text || selected.label || selected.id);
      return false;
    });

    // no organization
    $(document).on("click", "#btn-no-device-organization", function() {
      $('#device_resource_organization_id').val('');
      if ($('#s2id_device_find_organization').length && typeof $('#s2id_device_find_organization').select2 === 'function') {
        $('#s2id_device_find_organization').select2("val", "");
      } else {
        $('#device_find_organization').val('');
      }
      $('#selected-device-organization-label').text("None");
      return false;
    });
  }
});
