$( document ).ready(function() {

  if ($('[class*="batch-submission"]').length) { // check if the page is submission flow page

    initializeForm();

    function initializeForm() {

      $('.required').addClass('required-flag');
    }

        // Select Organization Events
        $("#batch_submission_organization_search").select2({
          data: orgData, // Defined in new.html.erb view
          placeholder: 'Enter institution or organization name or codes'
        });

        $('#batch_submission_organization_search').on('select2-selecting', function (e) {
          console.log(JSON.stringify(e.choice));
          var item = e.choice;

          if (e.choice && e.choice.id) {
            $("#organization_search_form input.organization_id").val(item.id);
            $("#organization_search_form input.organization_title").val(item.title);
            $("#organization_search_form input.organization_label").val(item.text);

            $("#organization_search_form input.organization_collection_code").val(item.collection_code);
            $("#organization_search_form input.organization_institution_code").val(item.institution_code);

            // Display selected organization
            $('#submission_organization_select_display').addClass('show').removeClass('hide');
            for (const prop in item) {
              if (item[prop]) {
                $('#submission_organization_select_display #'+prop).text(item[prop]);
              }
            }

            // Other UI control
            $('#submission_create_organization_button_section').addClass('hide').removeClass('show');
            $('#submission_create_organization_form_section').addClass('hide').removeClass('show');
            $('#submission_no_organization_section').addClass('hide').removeClass('show');
            $('#submission_select_organization').removeAttr('disabled');
          }
        });

        $('#submission_organization_select_display_container').on(
          'click', '#organization-select-close', function(event){
            // Remove data values
            $("#submission_organization_search").select2('val', null);
            $("#organization_search_form input.organization_id").val('');
            $("#organization_search_form input.organization_title").val('');
            $("#organization_search_form input.organization_label").val('');
            $("#submission_organization_select_display .showcase-value").text('');

            // UI controls
            $('#submission_select_organization_section').addClass('show').removeClass('hide');
            $('#submission_create_organization_button_section').addClass('show').removeClass('hide');
            $('#submission_no_organization_section').addClass('show').removeClass('hide');
            $('#submission_organization_select_display').addClass('hide').removeClass('show');
            $('#submission_select_organization').attr('disabled', 'disabled');
        });

        $('#submission_select_organization').click(function(event){
          event.preventDefault();
          console.log('View 4 select organization button');

          var selectedOrganizationID = $('#organization_search_form input.organization_id').val();

          if (selectedOrganizationID) {
            data.setOrganizationDefaults();
            data.organizationId = selectedOrganizationID;
            data.organizationCollectionCode = $('#organization_search_form input.organization_collection_code').val().split(', ');
            data.organizationInstitutionCode = $('#organization_search_form input.organization_institution_code').val().split(', ');
            data.noOrganization = false;
            data.willCreateOrganization = false;
            data.savedStep = 4;
            self.populatePhysicalObjectInstitutionCollectionCodes();
            self.next();

            console.log(data);
            self.form.setDefaultMediaPermissionFields();
          }
        });

        // No Organization Event

        $('#submission_no_organization').click(function(event){
          event.preventDefault();
          console.log('View 4 no organization button');

          data.setOrganizationDefaults();
          data.noOrganization = true;
          data.willCreateOrganization = false;
          data.savedStep = 4;
          self.toggleNoOrganizationVisibility();
          ['biological_specimen','cultural_heritage_object'].forEach((physical_object_type) => {
            ['collection_code','institution_code'].forEach((code_type) => {
              var dom_id = physical_object_type + '_' + code_type;
              var form_input_name = physical_object_type + '[' + code_type + ']';
              $('#' + dom_id).replaceWith($('<input>',{id: dom_id, name: form_input_name, class: 'form-control string optional'}));
            });
          });
          self.next();

          console.log(data);
        });

        $('#no-organization-close').click(function(event){
          event.preventDefault();
          console.log('closing no organization pane');

          data.setDeviceOrganizationDefaults();
          $('#submission_select_organization_section').addClass('show').removeClass('hide');
          $('#submission_create_organization_button_section').addClass('show').removeClass('hide');
          $('#submission_no_organization_section').addClass('show').removeClass('hide');
          $('#submission_no_organization_display_section').addClass('hide').removeClass('show');
          console.log(data);
        });

  } // end if the page is submission flow page
});
