
$( document ).ready(function() {
  if ($('form[id*="edit_engineering_object"]').length) { // if CHO form page

    function updateObjectTitle() {
      var title = [ 
        $('#engineering_object_institution_code').val(),
        $('#engineering_object_collection_code').val(),
        $('#engineering_object_catalog_number').val(),
      ];
      title = $.map( title, function(v){ return v === "" ? null : v; }).join(':');
      title = title + ' ' + $('#engineering_object_short_title').val();
      if (title == '' || title == ' ')
        title = $('#engineering_object_identifier').val();
      if (title == '' || title == ' ')
        title = "Vouchered object contributed by " + $('[name="current-user"]').data('userKey');
      $('#showcase-title').text(title);
    }

    setupEmbeddedWorkForm('organization', 'new', false, updateObjectTitle);
    setupTooltip();
    removeLastRepeatable();

    // Select Organization Functions

    // select2-associated select organization button
    $('#btn_select_organization').click(function() {
      var org = $('#s2id_engineering_object_find_organization').select2('data');
      console.log(org);

      // modify current organization properties
      $('.organization-details #organization-id-value').val(org.id);
      $('.organization-details #organization_type').text(org.organization_type || '');
      $('.organization-details #institution_name').text(org.institution_name || '');
      $('.organization-details #title').text(org.text || '');
      $('.organization-details #institution_code').text(org.institution_code || '');
      $('.organization-details #collection_code').text(org.collection_code || '');
      $('.organization-details #related_url').text(org.related_url || '');
      $('.organization-details #address').text(org.address || '');
      $('.organization-details #city').text(org.city || '');
      $('.organization-details #state_province').text(org.state_province || '');
      $('.organization-details #postal_code').text(org.postal_code || '');
      $('.organization-details #country').text(org.country || '');
      $('.organization-details #contact_person').text(org.contact_person || '');
      $('.organization-details #description').text(org.description || '');

      // modify the form
      $('form.edit_engineering_object input[name^="engineering_object[organization_id]"]').remove();
      $('<input />').attr('type', 'hidden')
        .attr('name', 'engineering_object[organization_id][]')
        .attr('value', org.id )
        .appendTo($('form.edit_engineering_object')
      );   
    });

    // remove organization when clicking no organization button  
    $('#btn_no_organization').click(function() {
      // modify current organization properties
      $('.organization-details #organization-id-value').val(null);
      $('.organization-details #organization_type').text('');
      $('.organization-details #institution_name').text('');
      $('.organization-details #title').text('');
      $('.organization-details #institution_code').text('');
      $('.organization-details #collection_code').text('');
      $('.organization-details #related_url').text('');
      $('.organization-details #address').text('');
      $('.organization-details #city').text('');
      $('.organization-details #state_province').text('');
      $('.organization-details #postal_code').text('');
      $('.organization-details #country').text('');
      $('.organization-details #contact_person').text('');
      $('.organization-details #description').text('');

      // modify the form
      $('form.edit_engineering_object input[name^="engineering_object[organization_id]"]').remove();
      $('<input />').attr('type', 'hidden')
        .attr('name', 'engineering_object[organization_id][]')
        .attr('value', '' )
        .appendTo($('form.edit_engineering_object')
      );   
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
    $('#engineering_object_institution_code, #engineering_object_collection_code, #engineering_object_catalog_number, #engineering_object_short_title, #engineering_object_identifier').change(updateObjectTitle);

    // change badges on the fly when corresponding fields are updated
    $('#engineering_object_vouchered').change(function(){
      if ($(this).val() == 'Yes')
        $('#in-collection-badge').text('In Collection');
      else
        $('#in-collection-badge').text('Not in Collection');
    })

    $(document).on("submit", 'form[data-param-key="engineering_object"]', function() {
      disablePage();
    })

  }
});
