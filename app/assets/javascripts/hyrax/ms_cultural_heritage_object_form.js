
$( document ).ready(function() {
  if ($('form[id*="edit_cultural_heritage_object"]').length) { // if CHO form page

    function updateObjectTitle() {
      var title = [ $('#cultural_heritage_object_institution_code').val(),
                          $('#cultural_heritage_object_collection_code').val(),
                          $('#cultural_heritage_object_catalog_number').val(),
                          $('#cultural_heritage_object_short_title').val() ]
      title = $.map( title, function(v){ return v === "" ? null : v; }).join(':');
      if (title == '')
        title = $('#cultural_heritage_object_identifier').val();
      if (title == '')
        title = "Vouchered object contributed by " + $('[name="current-user"]').data('userKey');
      $('#showcase-title').text(title);
    }

    setupEmbeddedWorkForm('organization', 'new', false, updateObjectTitle);
    setupTooltip();
    removeLastRepeatable();

    // remove organization when clicking no organization button
    $('#btn_no_organization').click(function() {
      var removeOrganizationButton = $('#parent-relationships-organizations').find('[data-behavior="remove-relationship"]');
      if (removeOrganizationButton.length) {
        removeOrganizationButton.trigger('click');
      }
      $('#embedded_div_new_organization').hide();
      $('#cultural_heritage_object_institution_code').val('');
      updateObjectTitle();
    })

    // An organization has been selected.  set the institution code field on the object detail tab, then update title
    $('#btn-add-organization').click(function() {
      $('#cultural_heritage_object_institution_code').val( $('#organization-code').text() );
      updateObjectTitle();
    })

    // when selecting an organization or taxonomy, hide the new work form if any
    $('[data-behavior="add-relationship"]').click(function() {
      $('.embedded_div').hide();
    })

    // when switching to another tab, hide the new work form from other tab if any
    $('.nav-tabs > li').click(function() {
      if ($(this).find('a[aria-expanded="false"]').length)
        $('.embedded_div').hide();
    })

    // Change title on the fly when corresponding fields are updated
    $('#cultural_heritage_object_institution_code, #cultural_heritage_object_collection_code, #cultural_heritage_object_catalog_number, #cultural_heritage_object_short_title, #cultural_heritage_object_identifier').change(updateObjectTitle);

    // change badges on the fly when corresponding fields are updated
    $('#cultural_heritage_object_vouchered').change(function(){
      if ($(this).val() == 'Yes')
        $('#in-collection-badge').text('In Collection');
      else
        $('#in-collection-badge').text('Not in Collection');
    })

    $(document).on("submit", 'form[data-param-key="cultural_heritage_object"]', function() {
      disablePage();
    })

  }
});
