/*jshint esversion: 6 */

$( document ).ready(function() {
  if ($('div[class="submission_flow"]').length) { // check if the page is submission flow page
    class SubmissionData {
      constructor(sessionState=null) {
        if (sessionState) {
          this.constructSubmissionParams(sessionState);
          this.constructCreateParams(sessionState);
        }
      }

      constructSubmissionParams(sessionState) {
        var submissionParamsArray = ['saved_step', 'fund_code', 'submission_media_type',
          'submission_modality', 'raw_or_derived_media', 'parent_media_list',
          'parent_media_not_in_ms', 'biological_specimen_or_cultural_heritage_object',
          'biological_specimen_id', 'idigbio_id', 'will_create_biological_specimen',
          'cultural_heritage_object_id', 'will_create_cultural_heritage_object',
          'organization_id', 'no_organization', 'will_create_organization',
          'taxonomy_id_array', 'taxonomy_gbif_key_array', 'will_create_taxonomy',
          'device_id', 'will_create_device', 'device_organization_id',
          'device_no_organization', 'will_create_device_organization'];

        for (let param of submissionParamsArray) {
          if (sessionState.form_data && sessionState.form_data.hasOwnProperty(param)) {
            this[this.underscoreToCamelCase(param)] = sessionState.form_data[param];
          }
        }
      }

      constructCreateParams(sessionState) {
        var createParamsHash = {
          'organization': 'organizationCreateParams',
          'taxonomy': 'taxonomyCreateParams',
          'biological_specimen': 'biologicalSpecimenCreateParams',
          'cultural_heritage_object': 'culturalHeritageObjectCreateParams',
          'device': 'deviceCreateParams',
          'device_organization': 'deviceOrganizationCreateParams',
          'imaging_event': 'imagingEventCreateParams',
          'processing_event': 'processingEventCreateParams'
        };

        for (let workName in createParamsHash) {
          if (sessionState.work_data && sessionState.work_data.hasOwnProperty(workName)) {
            this[createParamsHash[workName]] =
              this.objectToCreateParams(
                sessionState.work_data[workName],
                workName
              );
          }
        }
      }

      objectToCreateParams(object, objectName) {
        var paramArray = [];
        for (let property in object) {
          if (object[property]){
            if (Array.isArray(object[property])){
              for (let element of object[property]) {
                paramArray.push({ 'name': objectName + '[' + property + '][]', 'value': element });
              }
            }else if (object[property] instanceof Object){
              continue;
            }else{
              paramArray.push({ 'name': objectName + '[' + property + ']', 'value': object[property] });
            }
          }
        }
        return paramArray;
      }

      setPhysicalObjectDefaults() {
        this.biologicalSpecimenId = null;
        this.idigbioId = null;
        this.willCreateBiologicalSpecimen = null;
        this.culturalHeritageObjectId = null;
        this.willCreateCulturalHeritageObject = null;
      }

      setOrganizationDefaults() {
        this.organizationId = null;
        this.organizationCollectionCode = null;
        this.organizationInstitutionCode = null;
        this.noOrganization =  null;
        this.willCreateOrganization = null;
        this.organizationCreateParams = null;
      }

      setDeviceDefaults() {
        this.deviceId = null;
        this.willCreateDevice = null;
        this.deviceCreateParams = null;
      }

      setDeviceOrganizationDefaults() {
        this.deviceOrganizationId = null;
        this.deviceNoOrganization = null;
        this.willCreateDeviceOrganization = null;
        this.deviceOrganizationCreateParams = null;
      }

      underscoreToCamelCase(x) {
      return x.replace(/([-_][a-z])/ig, ($1) => {
          return $1.toUpperCase()
            .replace('-', '')
            .replace('_', '');
        });
      }

      // Currently unused but functional
      save() {
        console.log('Saving data...');

        let createParams = ['organizationCreateParams', 'taxonomyCreateParams',
          'biologicalSpecimenCreateParams', 'culturalHeritageObjectCreateParams', 'deviceCreateParams',
          'deviceOrganizationCreateParams', 'imagingEventCreateParams',
          'processingEventCreateParams'];

        saveDataObj = [];

        for (let k in this) {
          if (this[k] instanceof Function ) {
            continue;
          } else if (createParams.includes(k)) {
            if (Array.isArray(this[k])) {
              for (let createParamField of this[k]) {
                if (createParamField['name'] != 'utf8' && createParamField['name'] != 'authenticity_token') {
                  if (createParamField['name'].slice(-2) == '[]') {
                    // Multi-value field
                    saveDataObj.push(
                      { 'name': 'submission[work_data[' + createParamField['name'].slice(0, -2) + ']][]',
                        'value': createParamField['value'] }
                    );
                  } else {
                    saveDataObj.push(
                      { 'name': 'submission[work_data[' + createParamField['name'] + ']]',
                        'value': createParamField['value'] }
                    );
                  }
                }
              }
            }
          } else {
            saveDataObj.push(
              { 'name': 'submission[form_data[' + camelcaseToUnderscore(k) + ']]',
                'value': this[k] }
            );
          }
        }

        console.log(saveDataObj);

        $.post('save_data', saveDataObj, function(post_data){
          console.log('Data successfully saved!');
        });

      };
    }

    class SubmissionView {
      constructor(id, form) {
        this.id = id;
        this.form = form;
      }

      init() {
        // overwrite this for form re-instantiation (not implemented for now)
      }

      eventFuncs() {
        // overwrite this to provide jquery event listeners
      }

      triggerChangeVal(selector, v) {
        $(selector).val(v);
        $(selector).trigger('change');
      }

      removeValue(list, value) {
        list = list.split(',');
        list.splice(list.indexOf(value), 1);
        return list.join(',');
      }
    }

    class RawOrDerivedView extends SubmissionView {
      constructor(form) {
        super(1, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        // Proxy user select
        $("select[name='submission[on_behalf_of]']").change(function() {
          //console.log('proxy user changed');
          self.triggerChangeVal("select[name='media[on_behalf_of]']", $(this).val());
          self.triggerChangeVal("select[name='biological_specimen[on_behalf_of]']", $(this).val());
          self.triggerChangeVal("select[name='cultural_heritage_object[on_behalf_of]']", $(this).val());
          self.triggerChangeVal("select[name='taxonomy[on_behalf_of]']", $(this).val());
          self.triggerChangeVal("select[name='imaging_event[on_behalf_of]']", $(this).val());
          self.triggerChangeVal("select[name='processing_event[on_behalf_of]']", $(this).val());
          // set the reviewer
          var reviewer = {
            "id": $(this).val(),
            "user_key": $(this).val(),
            "text": $("select[name='submission[on_behalf_of]'] option:selected").text()
          }
          $('#media_download_reviewer').userSearchMultiple(reviewer);
        });

        // Media type select
        $("select[name='submission[submission_media_type]']").change(function() {
          console.log('View 1 Step 1 media type changed');

          self.triggerChangeVal("select[name='media[media_type]']", $(this).val());
          setRawDerivedStatus();
        });

        // Modality select
        $("select[name='submission[submission_modality]']").change(function() {
          console.log('View 1 Step 1 modality changed');

          // Image capture field set
          self.triggerChangeVal("select[name='imaging_event[ie_modality]']", $(this).val());
          // New device field set
          self.triggerChangeVal("select[name='device[modality][]']", $(this).val());
          setRawDerivedStatus();
        });

        var setRawDerivedStatus = function() {
          var mediaType = $("select[name='submission[submission_media_type]']").val();
          var modality = $("select[name='submission[submission_modality]']").val();

          console.log(mediaType);
          console.log(modality);

          if (submissionYaml.status.hasOwnProperty(mediaType) &&
             (submissionYaml.status[mediaType].hasOwnProperty(modality))
          ) {
            if (submissionYaml.status[mediaType][modality] == 'raw') {
              $('#submission-suggestions-container').removeClass('hide').addClass('show');
              $('#submission-suggestions-examples').removeClass('show').addClass('hide');
              $('#submission-raw-or-derived-section').removeClass('show').addClass('hide');

              $('#raw-or-derived-btn-group').attr('disabled', 'disabled');
              $('#radio_raw').addClass('active');
              $('#radio_derived').removeClass('active');
              $('#submission-suggestions').text('Your media is considered raw.');
            } else if (submissionYaml.status[mediaType][modality] == 'derived') {
              $('#submission-suggestions-container').removeClass('hide').addClass('show');
              $('#submission-suggestions-examples').removeClass('show').addClass('hide');
              $('#submission-raw-or-derived-section').removeClass('show').addClass('hide');

              $('#raw-or-derived-btn-group').attr('disabled', 'disabled');
              $('#radio_derived').addClass('active');
              $('#radio_raw').removeClass('active');
              $('#submission-suggestions').text('Your media is considered derived.');
            } else if (submissionYaml.status[mediaType][modality] == 'none') {
              $('#submission-suggestions-container').removeClass('hide').addClass('show');
              $('#submission-suggestions-examples').removeClass('show').addClass('hide');
              $('#submission-raw-or-derived-section').removeClass('show').addClass('hide');

              $('#raw-or-derived-btn-group').attr('disabled', 'disabled');
              $('#radio_raw').removeClass('active');
              $('#radio_derived').removeClass('active');
              $('#submission-suggestions').text('This combination is not permitted. Please choose a different media type and/or modality.');
            } else if (submissionYaml.status[mediaType][modality] == 'any') {
              $('#raw-or-derived-btn-group').removeAttr('disabled');
              $('#radio_raw').removeClass('active');
              $('#radio_derived').removeClass('active');

              if (submissionYaml.examples.hasOwnProperty(mediaType) &&
                 (submissionYaml.examples[mediaType].hasOwnProperty(modality))
              ) {
                $('#submission-suggestions').text('Your media could be raw or derived, depending on different factors. See the examples below and select whether your media is better described as raw or derived.');

                $('#submission-suggestions-examples-raw li').remove();
                for (const raw_example of submissionYaml.examples[mediaType][modality].raw) {
                  console.log(raw_example);
                  $('#submission-suggestions-examples-raw').append('<li>' + raw_example + '</li>');
                }

                $('#submission-suggestions-examples-derived li').remove();
                for (const derived_example of submissionYaml.examples[mediaType][modality].derived) {
                  $('#submission-suggestions-examples-derived').append('<li>' + derived_example + '</li>');
                }
                $('#submission-suggestions-examples').removeClass('hide').addClass('show');
              } else {
                $('#submission-suggestions').text('Your media could be raw or derived, depending on different factors. Select whether your media is better described as raw or derived.');
                $('#submission-suggestions-examples-raw li').remove();
                $('#submission-suggestions-examples-derived li').remove();
              }

              $('#submission-raw-or-derived-section').removeClass('hide').addClass('show');
              $('#submission-suggestions-container').removeClass('hide').addClass('show');
            }
          } else if (mediaType && modality) {
            $('#submission-raw-or-derived-section').removeClass('hide').addClass('show');
            $('#submission-suggestions-container').removeClass('show').addClass('hide');
          }
        };

        // Button: Continue
        $('#raw_or_derived_form').submit(function(event){
          event.preventDefault();
          console.log('View 1 Continue Button');

          data.fundCode = $( "select#submission_fund_code").val();
          data.submissionMediaType = $( "select#submission_submission_media_type").val();
          data.submissionModality = $( "select#submission_submission_modality").val();
          data.savedStep = 1;

          self.form.setSidebarViewCheck(1);
          if ($('#radio_raw').hasClass('active')) {
            data.rawOrDerivedMedia = 'raw';
            self.form.setVisibleView(3); // view 3 Physical Object
            self.form.setSidebarViewFade([1, 2, 9]);
          } else if ($('#radio_derived').hasClass('active')) {
            data.rawOrDerivedMedia = 'derived';
            self.form.setVisibleView(2); // view 2 Parent Media
            self.form.setSidebarViewFade(1);
          }
        });
      }
    }

    class ParentMediaView extends SubmissionView {
      constructor(form) {
        super(2, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        // Parent Media Selected
        $('input[id="submission_parent_media_list"]').change(function(){
          if ($(this).val()) {
            $('#submission_parent_media_submit').removeAttr('disabled');
          } else {
            $('#submission_parent_media_submit').attr('disabled', 'disabled');
          }
        });

        // Button: Continue With Selected Parent
        $('#parent_search_form').submit(function(event){
          event.preventDefault();
          console.log('View 2 Continue with parent button');

          var parentMediaList = $('input[id="submission_parent_media_list"]').val();
          if (parentMediaList != '') {
            console.log('List not empty');
            data.parentMediaList = parentMediaList;
            data.parentMediaNotInMs = false;
            data.savedStep = 2;

            // TODO add in other behavior from plan doc
            self.form.setVisibleView(9); // view 12 Media Processing Event
            self.form.setSidebarViewCheck([2, 3, 4, 5, 6, 7, 8]);
            self.form.setSidebarViewFade(2);

            // Get organization permissions fields if applicable
            self.form.setDefaultMediaPermissionFields();
          }
          console.log(data);
        });

        // Button: Parent Not In MorphoSource
        $('#btn_parents_not_in_morphosource').click(function(event){
          event.preventDefault();
          console.log('View 2 parent not in Ms button');

          data.parentMediaNotInMs = true;
          data.parentMediaList = null;
          data.savedStep = 2;

          self.form.setVisibleView(3); // view 3 Physical Object Type
          self.form.setSidebarViewCheck(2);
          self.form.setSidebarViewFade(2);

          console.log(data);
        });

        $('#btn_add_parent').click(function(event){
          event.preventDefault();
          var currentParentList = $('input[id="submission_parent_media_list"]').val();
          var selectedId = $("input.parent_id").val();
          if (currentParentList.indexOf(selectedId) != -1) {
            // parent has already been added
            // todo: see if it is possible to exclude the already-added parents from the autocomplete dropdown
            alert('Add new distinct parent media or select parent not available.');
          } else {
            if (currentParentList != '')
              currentParentList += ',';
            currentParentList += selectedId;
            self.triggerChangeVal('input[id="submission_parent_media_list"]', currentParentList);
            // display a new parent media row
            $('.parent_row:last-child').after(self.newParentRow(selectedId));
          }
          $('input[id="submission_parent_media_search"]').val('');
          $("input.parent_id").val('');
          $("input.parent_title").val('');
        });

        $('input#submission_parent_media_search').on('keypress',function(e) {
          if (e.which == 13) {
            // pressing enter key on this field should add a parent instead of submitting the form
            event.preventDefault();
            $('#btn_add_parent').trigger('click');
          }
        });

        $('div#parents').on('click', '#btn-remove-parent', function(event){
            event.preventDefault();
            let row = $(this).parent().parent();
            let id = row.data('id');
            row.remove();
            var currentParentList = $('input[id="submission_parent_media_list"]').val();
            var newParentList = self.removeValue(currentParentList, id);
            self.triggerChangeVal('input[id="submission_parent_media_list"]', newParentList);
        });
      }

      newParentRow(id) {
        var row = '<div class="parent_row row" data-id="' + id + '">' +
          '<div class="col-sm-6 col-sm-offset-3 block">' +
          '<span>' + $("input.parent_title").val() + '</span>' +
          '<i id="btn-remove-parent" class="fas fa-trash-alt btn_remove_parent clickable" style="float: right;"></i>' +
          '</div></div>';
        return row;
      }
    }

    class PhysicalObjectSearchCreateView extends SubmissionView {
      constructor(form) {
        super(3, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        // physical object type listeners
        $('#btn_object_type_biological').click(function(event){
          event.preventDefault();
          console.log('View 3 physical object type biological continue button');

          data.biologicalSpecimenOrCulturalHeritageObject = 'bso';
          $('#submission_bso_search_section').addClass('show').removeClass('hide');
          $('#submission_cho_search_section').addClass('hide').removeClass('show');
          $('#submission_physical_object_type_section').addClass('hide').removeClass('show');

          console.log(data);
        });

        $('#btn_object_type_cultural').click(function(event){
          event.preventDefault();
          console.log('View 3 physical object type cultural continue button');

          data.biologicalSpecimenOrCulturalHeritageObject = 'cho';
          $('#submission_cho_search_section').addClass('show').removeClass('hide');
          $('#submission_bso_search_section').addClass('hide').removeClass('show');
          $('#submission_physical_object_type_section').addClass('hide').removeClass('show');

          console.log(data);
        });

        // po search listeners
        $('#bso_search_ajax_form, #cho_search_ajax_form').submit(function(event){
          console.log('View 3 BSO or CHO search button');

          if ($(this).find('input[type=text]')
            .filter(function() {
              return this.value !== "" && this.value !== "0";
            })
            .length > 0 )
          {
            if (data.biologicalSpecimenOrCulturalHeritageObject == 'bso') {
              console.log('toggling viewability');
              $('#bso_search_non_search_options').addClass('hide').removeClass('show');
              $('#submission_po_search_loading').addClass('show').removeClass('hide');
              $('#submission_po_search_results').addClass('hide').removeClass('show');
              $('#submission_po_search_ajax').addClass('show').removeClass('hide');
              return true;
            } else if (data.biologicalSpecimenOrCulturalHeritageObject == 'cho') {
              console.log('toggling viewability');
              $('#cho_search_non_search_options').addClass('hide').removeClass('show');
              $('#submission_po_search_loading').addClass('show').removeClass('hide');
              $('#submission_po_search_results').addClass('hide').removeClass('show');
              $('#submission_po_search_ajax').addClass('show').removeClass('hide');
              return true;
            }
          } else {
            return false;
          }

        });

        $('#submission_po_search_results_container').on(
          'click', '#po-search-results-close', function(event){
            console.log('View 3 BSO or CHO search results close button');
            $('#submission_po_search_ajax').addClass('hide').removeClass('show');
            $('#submission_po_search_loading').addClass('show').removeClass('hide');
            $('#submission_po_search_results').addClass('hide').removeClass('show');
            if (data.biologicalSpecimenOrCulturalHeritageObject == 'bso') {
              $('#bso_search_non_search_options').addClass('show').removeClass('hide');
            } else if (data.biologicalSpecimenOrCulturalHeritageObject == 'cho') {
              $('#cho_search_non_search_options').addClass('show').removeClass('hide');
            }
        });

        $('#submission_po_search_results_container').on(
          'click', '.use-morphosource-object', function(event){
            event.preventDefault();
            console.log('View 3 use morphosource object button');

            data.setPhysicalObjectDefaults();
            data.savedStep = 3;

            if (data.biologicalSpecimenOrCulturalHeritageObject == 'bso' && $(this).attr('id')) {
              data.biologicalSpecimenId = $(this).attr('id');

              self.form.setSidebarViewCheck([3, 4, 5, 6]);
              self.form.setSidebarViewFade([3, 4, 5, 6]);
            } else if (data.biologicalSpecimenOrCulturalHeritageObject == 'cho' && $(this).attr('id')) {
              data.culturalHeritageObjectId = $(this).attr('id');

              self.form.setSidebarViewCheck([3, 4, 6]);
              self.form.setSidebarViewFade([3, 4, 5, 6]);
            }

            self.form.setVisibleView(7); // view 7 media device
            self.form.setDefaultMediaPermissionFields(); // Organization default fields
            console.log(data);
        });

        $('#submission_po_search_results_container').on(
          'click', '.import-idigbio-object', function(event){
          event.preventDefault();
          console.log('View 3 import idigbio object');

          data.setPhysicalObjectDefaults();
          data.idigbioId = $(this).attr('id');
          var recordsetId = $(this).data('recordset');

          if (data.idigbioId && recordsetId) {
            // Is there a MS organization that matches this recordset?
            $.get('organization_for_recordset',
              { 'recordset_id': recordsetId },
              function(getData){
                console.log(getData);
                if (getData.organization_found && getData.organization_id) {
                  // Set organization data
                  data.setOrganizationDefaults();
                  data.organizationId = getData.organization_id;
                  data.noOrganization = false;
                  data.willCreateOrganization = false;

                  // Set organization-related default media permission fields
                  self.form.setDefaultMediaPermissionFields();

                  // Proceed
                  data.savedStep = 3;
                  self.form.setSidebarViewCheck([3, 4, 5, 6]);
                  self.form.setSidebarViewFade([3, 4, 5, 6]);
                  self.form.setVisibleView(7); // view 7 select device
                } else {
                  data.savedStep = 3;
                  self.form.setSidebarViewCheck([3, 5, 6]);
                  self.form.setSidebarViewFade([3, 5, 6]);
                  self.form.setVisibleView(4); // view 4 select organization
                }
              }
            );
          }

          console.log(data);
        });

        $('#submission_will_create_bso').click(function(event){
          event.preventDefault();
          console.log('View 3 create new physical object button');

          data.willCreateBiologicalSpecimen = true;
          data.savedStep = 3;
          self.form.setSidebarViewCheck(3);
          self.form.setSidebarViewFade(3);
          self.form.setVisibleView(4); // view 4 create organization

          console.log(data);
        });

        $('#submission_will_create_cho').click(function(event){
          event.preventDefault();
          console.log('View 3 create new physical object button');

          data.willCreateCulturalHeritageObject = true;
          data.savedStep = 3;

          // Set CHO details form to visible
          $('#submission_bso_create_section').addClass('hide').removeClass('show');
          $('#submission_cho_create_section').addClass('show').removeClass('hide');

          self.form.setSidebarViewCheck(3);
          self.form.setSidebarViewFade(3);
          self.form.setVisibleView(4); // view 4 create organization

          console.log(data);
        });

        $('.submission_back_to_po_type').click(function(event){
          event.preventDefault();
          console.log('View 3 back to physical object type button');

          data.setPhysicalObjectDefaults();

          $('#submission_cho_search_section').addClass('hide').removeClass('show');
          $('#submission_bso_search_section').addClass('hide').removeClass('show');
          $('#submission_physical_object_type_section').addClass('show').removeClass('hide');
          console.log(data);
        });
      }
    }

    class OrganizationView extends SubmissionView {
      constructor(form) {
        super(4, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        // Select Organization Events
        $('#submission_organization_select_display_container').on(
          'click', '#organization-select-close', function(event){
            // Remove data values
            $("#submission_organization_search").val('');
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
            data.organizationCollectionCode = $('#organization_search_form input.organization_collection_code').val().split(',');
            data.organizationInstitutionCode = $('#organization_search_form input.organization_institution_code').val().split(',');
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

        // Commenting out create organization events for now
        // Create Organization Events

        // $('#submission_show_create_organization').click(function(event){
        //   event.preventDefault();
        //   self.toggleCreateOrganizationVisibility();
        // });

        // $('#organization-create-close').click(function(event){
        //   event.preventDefault();
        //   $('#submission_select_organization_section').addClass('show').removeClass('hide');
        //   $('#submission_create_organization_button_section').addClass('show').removeClass('hide');
        //   $('#submission_no_organization_section').addClass('show').removeClass('hide');
        //   $('#submission_create_organization_form_section').addClass('hide').removeClass('show');
        // });

        // $('form#new_organization').submit(function(event){
        //   event.preventDefault();
        //   console.log('View 4 create organization and continue button');

        //   data.setOrganizationDefaults();
        //   data.noOrganization = false;
        //   data.willCreateOrganization = true;
        //   data.organizationCreateParams = $('#new_organization').serializeArray();
        //   data.organizationInstitutionCode = $('#organization_institution_code').val();
        //   data.organizationCollectionCode = [];
        //   $("[name='organization[collection_code][]']").map((index, collection_code) => {
        //     if ($(collection_code).val()) {
        //       data.organizationCollectionCode.push($(collection_code).val());
        //     }
        //   });
        //   data.savedStep = 4;
        //   self.populatePhysicalObjectInstitutionCollectionCodes();
        //   self.next();

        //   console.log(data);
        // });
      }

      populatePhysicalObjectInstitutionCollectionCodes() {
        $("#biological_specimen_institution_code").empty();
        $("#cultural_heritage_object_institution_code").empty();
        data.organizationInstitutionCode.forEach((institution_code) => {
          $("#biological_specimen_institution_code").append($('<option>', {value: institution_code, text: institution_code}));
          $("#cultural_heritage_object_institution_code").append($('<option>', {value: institution_code, text: institution_code}));
        });
        $("#biological_specimen_institution_code").append($('<option>'));
        $("#cultural_heritage_object_institution_code").append($('<option>'));

        $("#biological_specimen_collection_code").empty();
        $("#cultural_heritage_object_collection_code").empty();
        data.organizationCollectionCode.forEach((collection_code) => {
          $("#biological_specimen_collection_code").append($('<option>', {value: collection_code, text: collection_code}));
          $("#cultural_heritage_object_collection_code").append($('<option>', {value: collection_code, text: collection_code}));
        });
        $("#biological_specimen_collection_code").append($('<option>'));
        $("#cultural_heritage_object_collection_code").append($('<option>'));
      }

      next() {
        this.form.setSidebarViewCheck(4);
        if (data.idigbioId) {
          this.form.setSidebarViewCheck([5, 6]);
          this.form.setSidebarViewFade([5, 6]);
          this.form.setVisibleView(7); // view 7 media device
        } else if (data.biologicalSpecimenOrCulturalHeritageObject == 'cho') {
          this.form.setSidebarViewFade(5); // fade out view 5 taxonomy
          this.form.setVisibleView(6); // view 6 details
        } else {
          this.form.setVisibleView(5); // view 5 taxonomy
        }
      }

      toggleSelectedOrganizationVisibility() {
        $('#submission_organization_select_display').addClass('show').removeClass('hide');
        $('#submission_create_organization_button_section').addClass('hide').removeClass('show');
        $('#submission_create_organization_form_section').addClass('hide').removeClass('show');
        $('#submission_no_organization_section').addClass('hide').removeClass('show');
      }

      toggleCreateOrganizationVisibility() {
        $('#submission_create_organization_form_section').addClass('show').removeClass('hide');
        $('#submission_select_organization_section').addClass('hide').removeClass('show');
        $('#submission_create_organization_button_section').addClass('hide').removeClass('show');
        $('#submission_no_organization_section').addClass('hide').removeClass('show');
      }

      toggleNoOrganizationVisibility() {
        $('#submission_no_organization_display_section').addClass('show').removeClass('hide');
        $('#submission_create_organization_form_section').addClass('hide').removeClass('show');
        $('#submission_select_organization_section').addClass('hide').removeClass('show');
        $('#submission_create_organization_button_section').addClass('hide').removeClass('show');
        $('#submission_no_organization_section').addClass('hide').removeClass('show');
        $('#submission_organization_select_display_container').addClass('hide').removeClass('show');
      }
    }

    class TaxonomyView extends SubmissionView {
      constructor(form) {
        super(5, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        $('#submission_select_taxonomy_submit').click(function(event){
          $('form#taxonomy_search_form').submit();
        });

        $('form#taxonomy_search_form').submit(function(event){
          event.preventDefault();
          console.log('View 5 Continue with selected taxonomy button');

          if ((data.willCreateTaxonomy) ||
              (data.taxonomyIdArray && data.taxonomyIdArray.length) ||
              (data.taxonomyGbifKeyArray && data.taxonomyGbifKeyArray.length)
          ) {
            if (data.willCreateTaxonomy) {
              data.taxonomyCreateParams = $('#new_taxonomy').serializeArray();
            } else {
              data.taxonomyCreateParams = null;
            }

            data.savedStep = 5;
            self.form.setSidebarViewCheck(5);
            self.form.setVisibleView(6); // view 6 create physical object details
          }

          console.log(data);
        });

        $('#submission_show_create_taxonomy').click(function(event){
          event.preventDefault();
          data.willCreateTaxonomy = true;
          self.toggleCreateTaxonomyVisibility();
          $('#submission_select_taxonomy_submit').removeAttr('disabled');

        });

        $('#taxonomy-create-close').click(function(event){
          event.preventDefault();
          data.willCreateTaxonomy = false;

          $('#submission_create_taxonomy_button_section').addClass('show').removeClass('hide');
          $('#submission_create_taxonomy_form_section').addClass('hide').removeClass('show');

          if (
            (!data.taxonomyIdArray || !data.taxonomyIdArray.length) &&
            (!data.taxonomyGbifKeyArray || !data.taxonomyGbifKeyArray.length)
          ) {
            $('#submission_select_taxonomy_submit').attr('disabled', 'disabled');
          }
        });

        $('#btn_add_taxonomy').click(function(event){
          event.preventDefault();
          console.log('View 5 add taxonomy to list button');

          var newId = $("input.taxonomy_id").val();
          var newGbifKey = $("input.taxonomy_gbif_key").val();

          if (newId && newId.indexOf('gbif:') == -1) {
            if (!Array.isArray(data.taxonomyIdArray)) {
              data.taxonomyIdArray = [];
            }
            data.taxonomyIdArray.push(newId);
          }

          if (newGbifKey) {
            if (!Array.isArray(data.taxonomyGbifKeyArray)) {
              data.taxonomyGbifKeyArray = [];
            }
            data.taxonomyGbifKeyArray.push(newGbifKey);
          }

          // Display a new taxonomy row
          if (newId || newGbifKey) {
            $('.taxonomy_row:last-child').after(self.newTaxonomyRow(newId, newGbifKey));
          }

          // Clear temp values for new taxonomy to be added
          $('input[id="submission_taxonomy_search"]').val('');
          $("input.taxonomy_id").val('');
          $("input.taxonomy_gbif_key").val('');
          $("input.taxonomy_title").val('');

          // Enable step completion
          $('#submission_select_taxonomy_submit').removeAttr('disabled');
        });

        $('div#taxonomies').on('click', '#btn-remove-taxonomy', function(event){
            event.preventDefault();
            let row = $(this).parent().parent();
            let id = row.data('id').toString();
            let gbifKey = row.data('gbifkey').toString();
            console.log(gbifKey);
            row.remove();

            if (id && Array.isArray(data.taxonomyIdArray)) {
              if (data.taxonomyIdArray.indexOf(id) > -1) {
                data.taxonomyIdArray.splice(data.taxonomyIdArray.indexOf(id), 1);
              }
            }
            if (gbifKey && Array.isArray(data.taxonomyGbifKeyArray)) {
              if (data.taxonomyGbifKeyArray.indexOf(gbifKey) > -1) {
                data.taxonomyGbifKeyArray.splice(data.taxonomyGbifKeyArray.indexOf(gbifKey), 1);
              }
            }

            if (
              (!data.taxonomyIdArray || !data.taxonomyIdArray.length) &&
              (!data.taxonomyGbifKeyArray || !data.taxonomyGbifKeyArray.length)
            ) {
              $('#submission_select_taxonomy_submit').attr('disabled', 'disabled');
            }
        });
      }

      newTaxonomyRow(id, gbifKey) {
        var row = '<div class="taxonomy_row row" data-id="' + id + '" data-gbifkey="' + gbifKey + '">' +
          '<div class="col-sm-6 col-sm-offset-3 block">' +
          '<span>' + $("input.taxonomy_title").val() + '</span>' +
          '<i id="btn-remove-taxonomy" class="fas fa-trash-alt btn_remove_parent clickable" style="float: right;"></i>' +
          '</div></div>';
        return row;
      }

      toggleCreateTaxonomyVisibility() {
        $('#submission_create_taxonomy_form_section').addClass('show').removeClass('hide');
        $('#submission_create_taxonomy_button_section').addClass('hide').removeClass('show');
      }


    }

    class PhysicalObjectDetailsView extends SubmissionView {
      constructor(form) {
        super(6, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        // bso details listeners
        $('form#new_biological_specimen').submit(function(event){
          event.preventDefault();
          console.log('View 8 create BSO and continue button');

          data.setPhysicalObjectDefaults();
          data.biologicalSpecimenOrCulturalHeritageObject = 'bso';
          data.willCreateBiologicalSpecimen = true;
          data.biologicalSpecimenCreateParams = $('form#new_biological_specimen').serializeArray();
          data.savedStep = 6;

          self.form.setSidebarViewCheck(6);
          self.form.setVisibleView(7); // view 7 media device

          console.log(data);
        });

        // cho details listeners
        $('form#new_cultural_heritage_object').submit(function(event){
          event.preventDefault();
          console.log('View 6 create CHO and continue button');

          data.setPhysicalObjectDefaults();
          data.biologicalSpecimenOrCulturalHeritageObject = 'cho';
          data.willCreateCulturalHeritageObject = true;
          data.culturalHeritageObjectCreateParams = $('form#new_cultural_heritage_object').serializeArray();
          data.savedStep = 6;

          self.form.setSidebarViewCheck(6);
          self.form.setVisibleView(7); // view 7 media device

          console.log(data);
        });
      }
    }

    class DeviceView extends SubmissionView {
      constructor(form) {
        super(7, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;
        // Select device events
        $('select[name="submission[device_id]"]').change(function(event){
          console.log($(this).find(':selected').data('modality'));
          console.log(data.submissionModality);
          if ($(this).val()){
            if ($(this).find(':selected').data('modality').includes(data.submissionModality)) {
              self.toggleSelectDeviceVisibility($(this).find(':selected'));
              $('#submission_select_device_continue').removeAttr('disabled');
            } else {
              alert('Modality of selected device must match modality entered in Initial Information step.');
              $(this).val('');
              $('#submission_select_device_continue').attr('disabled', 'disabled');
            }
         } else {
          $('#submission_select_device_continue').attr('disabled', 'disabled');
         }
        });

        $('#submission_device_select_display_container').on(
          'click', '#device-select-close', function(event){
            $('select[name="submission[device_id]"]').val('');
            $('#submission_select_device_section').addClass('show').removeClass('hide');
            $('#submission_create_device_button_section').addClass('show').removeClass('hide');
            $('#submission_device_select_display').addClass('hide').removeClass('show');
            $('#submission_select_device_continue').attr('disabled', 'disabled');
        });

        $('#submission_select_device_continue').click(function(event) {
          event.preventDefault();
          console.log('View 10 select device button');

          if ($(this).attr('disabled')) {
            return;
          }

          data.setDeviceDefaults();
          data.setDeviceOrganizationDefaults();
          data.deviceId = $('select[name="submission[device_id]"]').val();
          data.willCreateDevice = false;
          data.willCreateDeviceOrganization = false;
          data.savedStep = 7;

          self.next();

          console.log(data);
        });

        // Commenting out all events related to creating devices for now!

      //   // Create device events
      //   $('#submission_show_create_device').click(function(event){
      //     event.preventDefault();
      //     self.toggleCreateDeviceVisibility();
      //   });

      //   $('#submission_create_device_continue').click(function(event){
      //     event.preventDefault();
      //     console.log('View 10 create device and continue button');

      //     // Check device organization...
      //     if ($("#device_organization_search_form input.device_organization_id").val()) {
      //       data.setDeviceOrganizationDefaults();
      //       data.deviceOrganizationId =
      //         $("#device_organization_search_form input.device_organization_id").val();
      //       data.noDeviceOrganization = false;
      //       data.willCreateDeviceOrganization = false;
      //     } else if (data.willCreateDeviceOrganization) {
      //       if ($('form#new_device_organization')[0].checkValidity()) {
      //         data.setDeviceOrganizationDefaults();
      //         data.deviceOrganizationCreateParams = $('#new_device_organization').serializeArray();
      //         data.willCreateDeviceOrganization = true;
      //         data.noDeviceOrganization = false;
      //       } else {
      //         $('form#new_device_organization').find(':submit').click();
      //         return false;
      //       }
      //     } else if (data.noDeviceOrganization === true) {
      //       data.setDeviceOrganizationDefaults();
      //       data.noDeviceOrganization = true;
      //       data.willCreateDeviceOrganization = false;
      //     } else {
      //       $('div#device_create_organization_section').addClass('div-invalid');
      //       return false;
      //     }

      //     if ($('form#new_device')[0].checkValidity()) {
      //       // Does modality match previously selected?
      //       var modalityMatch = false;
      //       $('select[name="device[modality][]"]').each(function() {
      //         if ($(this).val() == data.submissionModality) { modalityMatch = true; }
      //       });

      //       if (modalityMatch) {
      //         data.setDeviceDefaults();
      //         data.willCreateDevice = true;
      //         data.deviceCreateParams = $('#new_device').serializeArray();
      //         data.savedStep = 7;

      //         self.next();
      //         console.log(data);
      //       } else {
      //         alert('At least one device modality selection must match modality entered in Initial Information step.');
      //       }
      //     } else {
      //       $('form#new_device').find(':submit').click(); // Submit to show errors
      //       return false;
      //     }

      //     return false;
      //   });

      //   $('#submission_create_device_close').click(function(event){
      //     event.preventDefault();
      //     $('#submission_create_device_form_section').addClass('hide').removeClass('show');
      //     $('#submission_select_device_section').addClass('show').removeClass('hide');
      //     $('#submission_create_device_button_section').addClass('show').removeClass('hide');
      //   });

      //   // Device organization events

      //   // Device organization select events
      //   $('#device_organization_select_display_container').on(
      //     'click', '#device-organization-select-close', function(event){
      //       // Remove data values
      //       $("#submission_device_organization_search").val('');
      //       $("#device_organization_search_form input.device_organization_id").val('');
      //       $("#device_organization_search_form input.device_organization_title").val('');
      //       $("#device_organization_search_form input.device_organization_label").val('');
      //       data.setDeviceOrganizationDefaults();

      //       // UI visibility
      //       $('#submission_create_device_organization_button_section').addClass('show').removeClass('hide');
      //       $('#submission_no_device_organization_section').addClass('show').removeClass('hide');
      //       $('#device_organization_select_display_container').addClass('hide').removeClass('show');
      //   });


      //   // Device organization create events
      //   $('form#new_device_organization').submit(function(event){
      //     event.preventDefault();
      //   });

      //   $('#submission_show_create_device_organization').click(function(event){
      //     event.preventDefault();
      //     console.log('View 10 create device organization button');

      //     data.setDeviceOrganizationDefaults();
      //     data.willCreateDeviceOrganization = true;
      //     $('select[name="submission[device_organization_id]"]').val('');
      //     self.toggleCreateDeviceOrganizationVisibility();
      //   });

      //   $('#device-organization-create-close').click(function(event){
      //     event.preventDefault();

      //     data.setDeviceOrganizationDefaults();
      //     $('#submission_select_device_organization_section').addClass('show').removeClass('hide');
      //     $('#submission_create_device_organization_button_section').addClass('show').removeClass('hide');
      //     $('#submission_no_device_organization_section').addClass('show').removeClass('hide');
      //     $('#submission_create_device_organization_form_section').addClass('hide').removeClass('show');
      //   });


      //   // Device organization no organization events
      //   $('#submission_no_device_organization').click(function(event){
      //     event.preventDefault();
      //     console.log('View 10 no device organization button');

      //     data.setDeviceOrganizationDefaults();
      //     data.noDeviceOrganization = true;
      //     data.willCreateDeviceOrganization = false;
      //     $('select[name="submission[device_organization_id]"]').val('');
      //     self.toggleNoDeviceOrganizationVisibility();

      //     console.log(data);
      //   });

      //   $('#no-device-organization-close').click(function(event){
      //     event.preventDefault();
      //     console.log('closing no device organization pane');

      //     data.setDeviceOrganizationDefaults();
      //     $('#submission_select_device_organization_section').addClass('show').removeClass('hide');
      //     $('#submission_create_device_organization_button_section').addClass('show').removeClass('hide');
      //     $('#submission_no_device_organization_section').addClass('show').removeClass('hide');
      //     $('#submission_no_device_organization_display_section').addClass('hide').removeClass('show');
      //     console.log(data);
      //   });

      }

      showDeviceSelectDisplay(selectedOpt) {
        $('#device-display-title').text(selectedOpt.text());
        $('#device-display-creator').text(selectedOpt.data('creator'));
        $('#device-display-modality').text(selectedOpt.data('modality'));
        $('#device-display-description').text(selectedOpt.data('description'));
        $('#submission_device_select_display').addClass('show').removeClass('hide');
      }

      toggleSelectDeviceVisibility(selectedOpt) {
        $('#submission_create_device_button_section').addClass('hide').removeClass('show');
        $('#submission_create_device_form_section').addClass('hide').removeClass('show');
        this.showDeviceSelectDisplay(selectedOpt);
      }

      toggleCreateDeviceVisibility() {
        $('#submission_create_device_form_section').addClass('show').removeClass('hide');
        $('#submission_select_device_section').addClass('hide').removeClass('show');
        $('#submission_create_device_button_section').addClass('hide').removeClass('show');
      }

      toggleSelectDeviceOrganizationVisibility() {
        $('#device_organization_select_display_container').addClass('show').removeClass('hide');
        $('#submission_create_device_organization_button_section').addClass('hide').removeClass('show');
        $('#submission_create_device_organization_form_section').addClass('hide').removeClass('show');
        $('#submission_no_device_organization_section').addClass('hide').removeClass('show');
        $('#submission_no_device_organization_display_section').addClass('hide').removeClass('show');
      }

      toggleCreateDeviceOrganizationVisibility() {
        $('#submission_create_device_organization_form_section').addClass('show').removeClass('hide');
        $('#submission_select_device_organization_section').addClass('hide').removeClass('show');
        $('#submission_create_device_organization_button_section').addClass('hide').removeClass('show');
        $('#submission_no_device_organization_section').addClass('hide').removeClass('show');
        $('#submission_no_device_organization_display_section').addClass('hide').removeClass('show');
        $('#device_organization_select_display_container').addClass('hide').removeClass('show');
      }

      toggleNoDeviceOrganizationVisibility() {
        $('#submission_no_device_organization_display_section').addClass('show').removeClass('hide');
        $('#submission_create_device_organization_form_section').addClass('hide').removeClass('show');
        $('#submission_select_device_organization_section').addClass('hide').removeClass('show');
        $('#submission_create_device_organization_button_section').addClass('hide').removeClass('show');
        $('#submission_no_device_organization_section').addClass('hide').removeClass('show');
        $('#device_organization_select_display_container').addClass('hide').removeClass('show');
      }

      next() {
        this.form.setSidebarViewCheck(7);
        this.form.setVisibleView(8); // view 8 create imaging event
      }
    }

    class ImagingEventView extends SubmissionView {
      constructor(form) {
        super(8, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        $("select[name='imaging_event[ie_modality]']").change(function(event){
          if ($(this).val() !== $('select#submission_submission_modality').val()) {
            alert('Capture modality must match modality selected in initial information.');
            self.triggerChangeVal("select[name='imaging_event[ie_modality]']", $('select#submission_submission_modality').val());
          }
        });

        $('form#new_imaging_event').submit(function(event){
          event.preventDefault();
          console.log('View 11 create imaging event button');

          data.imagingEventCreateParams = $('#new_imaging_event').serializeArray();
          data.savedStep = 8;

          if (data.rawOrDerivedMedia == 'derived') {
            self.form.setSidebarViewCheck(8);
            self.form.setVisibleView(9); // view 9 processing event
          } else {
            self.form.setSidebarViewCheck(8);
            self.form.setSidebarViewFade(9);
            self.form.setVisibleView(10); // view 10 create media details
          }

          console.log(data);
        });
      }
    }

    class ProcessingEventView extends SubmissionView {
      constructor(form) {
        super(9, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        $('form#new_processing_event').submit(function(event){
          event.preventDefault();
          console.log('View 12 create processing event button');

          data.processingEventCreateParams = $('form#new_processing_event').serializeArray();
          data.savedStep = 9;
          self.form.setSidebarViewCheck(9);
          self.form.setVisibleView(10);

          console.log(data);
        });
      }
    }

    class MediaView extends SubmissionView {
      constructor(form) {
        super(10, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

        $("select[name='media[media_type]']").change(function(event){
          // Check media type against initially selected
          if ($(this).val() !== $('select#submission_submission_media_type').val()) {
            alert('Media type must match media type selected in initial information.');
            self.triggerChangeVal("select[name='media[media_type]']", $('select#submission_submission_media_type').val());
          }
        });

        $('a#organization-attachment-remove').click(function(event){
          event.preventDefault();
          $('div#organization-attachment-section').addClass('hide').removeClass('show');
          $('div#work-attachment-section').addClass('show').removeClass('hide');
          data.organizationForAttachment = null;
        });

        $('a#organization-attachment-replace').click(function(event){
          event.preventDefault();
          $('div#organization-attachment-section').addClass('show').removeClass('hide');
          $('div#work-attachment-section').addClass('hide').removeClass('show');
          data.organizationForAttachment = data.organizationId;
        });

        $('#new_media').submit(function(){
          if (!uploadStatusOK) {
            // file upload is in progress. Prompt for auto save
            promptAutoSave(".btn-save-media");
            return false;
          }
          if (!noFileCheck()) {
            return false;
          }

          prepareFieldsBeforeSubmit();
          disablePageAndSave(".btn-save-media");

          var createParams = ['organizationCreateParams', 'taxonomyCreateParams',
            'biologicalSpecimenCreateParams', 'culturalHeritageObjectCreateParams', 'deviceCreateParams',
            'deviceOrganizationCreateParams', 'imagingEventCreateParams',
            'processingEventCreateParams'];

          for (let k in data) {
            if (data[k] instanceof Function ) {
              continue;
            } else if (createParams.includes(k)) { // Create params, must iterate
              if (Array.isArray(data[k])) {
                for (let createParamField of data[k]) {
                  if (createParamField != 'utf8' && createParamField != 'authenticity_token') {
                    let paramName = createParamField['name'];
                    if (k == 'deviceOrganizationCreateParams') {
                      paramName = paramName.replace('organization[', 'device_organization[');
                    }

                    self.addParamToForm('#new_media', paramName, createParamField['value']);
                  }
                }
              }
            } else {
              self.addParamToForm('#new_media', 'submission[' + camelcaseToUnderscore(k) + ']', data[k]);
            }
          }

          // Add IE and PE attachments, if necessary
          if ($('input#pe_description').val()) {
            var fileField = $('input#pe_description');
            fileField.addClass('hide');
            var clone = fileField.clone();
            fileField.after(clone).appendTo('#new_media');
          }

          if ($('input#ie_description').val()) {
            var fileField = $('input#ie_description');
            fileField.addClass('hide');
            var clone = fileField.clone();
            fileField.after(clone).appendTo('#new_media');
          }
          if ($('input#ie_reference').val()) {
            var fileField = $('input#ie_reference');
            fileField.addClass('hide');
            var clone = fileField.clone();
            fileField.after(clone).appendTo('#new_media');
          }

          console.log($('#new_media').serializeArray());
          return true;
        });
      }

      addParamToForm(formId, paramName, paramValue) {
        $('<input />').attr('type', 'hidden')
          .attr('name', paramName)
          .attr('value', paramValue)
          .appendTo(formId);
      }
    }

    class SubmissionForm {
      constructor(submissionData) {
        this.data = submissionData;

        this.views = [
          new RawOrDerivedView(this),
          new ParentMediaView(this),
          new PhysicalObjectSearchCreateView(this),
          new OrganizationView(this),
          new TaxonomyView(this),
          new PhysicalObjectDetailsView(this),
          new DeviceView(this),
          new ImagingEventView(this),
          new ProcessingEventView(this),
          new MediaView(this)
        ];

        this.viewSidebarClass = {
          1: '.sidebar_raw_derived',
          2: '.sidebar_parent_media',
          3: '.sidebar_search_or_create',
          4: '.sidebar_organization',
          5: '.sidebar_taxonomy',
          6: '.sidebar_details',
          7: '.sidebar_device',
          8: '.sidebar_capture',
          9: '.sidebar_processing',
          10: '.sidebar_upload_details'
        };

        this.viewSectionIds = {
          1: '#submission_choose_raw_or_derived_media',
          2: '#submission_parents_in_ms',
          3: '#submission_physical_object',
          4: '#submission_organization',
          5: '#submission_taxonomy',
          6: '#submission_physical_object_details',
          7: '#submission_device',
          8: '#submission_image_capture',
          9: '#submission_processing_event',
          10: '#submission_media'
        };

        this.initializeForm();

      }

      initializeForm() {
        $('.required').addClass('required-flag');
        $('.submission_flow input:not(#media_submit)').removeAttr('data-disable-with');
        this.sidebarEventFuncs();
        this.setMediaPermissionFieldEvent();

        // Comment out for debug ability to access any step any time
        this.setSidebarViewFade([2, 3, 4, 5, 6, 7, 8, 9, 10]);
      }

      setMediaPermissionFieldEvent() {
        $('form#new_media div,form#new_media a').click(function(event) {
          //console.log('in setMediaPermissionFieldEvent');
          if ($(this).hasClass('permissions-field')) {
            //console.log('hi2');
            alert($('#organization-alert-message').text());
            $(this).off(event); // Only fire once
          }
        });
      }

      setDefaultMediaPermissionFields() {
        let self = this;

        $.get('organization_default_media_fields',
         {
          'parent_media_list': this.data.parentMediaList,
          'organization_id': this.data.organizationId,
          'biological_specimen_id': this.data.biologicalSpecimenId,
          'cultural_heritage_object_id': this.data.culturalHeritageObjectId
         },
         function(getData){
          console.log('Got organization default fields');
          console.log(getData);
          if (getData.default_fields) {
            console.log($('form#new_media div#submission-media-ownership'));
            // Add loading to media page
            $('form#new_media div#submission-media-ownership').addClass('ui-loading-whole-page');

            // Remove previous settings, if present
            $('form#new_media div#submission-media-ownership div').removeClass('permissions-field');
            $('form#new_media div#submission-media-ownership i.fa-university').remove();
            self.emptyMediaFields(getData.default_fields);

            // Set up text
            $('#organization-alert-message').text(getData.organization_alert_message);
            $('#organization-name').text(getData.organization_title);
            $('#ownership-section-header-text').addClass('show').removeClass('hide');

            // Add new settings
            self.fillMediaFields(getData.default_fields);

            // Organization agreement attachment
            if (getData.default_fields.attachment_url && getData.organization_id) {
              self.data.organizationForAttachment = getData.organization_id;
              $('#organization-attachment-url').attr('href', getData.default_fields.attachment_url);
              $('#organization-attachment-section').addClass('show').removeClass('hide');
              $('div#organization-attachment-replace-row').addClass('show').removeClass('hide');
              $('#work-attachment-section').addClass('hide').removeClass('show');
            } else {
              self.data.organizationForAttachment = null;
              $('#organization-attachment-url').attr('href', '#');
              $('#organization-attachment-section').addClass('hide').removeClass('show');
              $('div#organization-attachment-replace-row').addClass('hide').removeClass('show');
              $('#work-attachment-section').addClass('show').removeClass('hide');
            }

            // Remove loading
            $('form#new_media div#submission-media-ownership').removeClass('ui-loading-whole-page');
          }
         });
      }

      emptyMediaFields(defaultFields) {
        for (const f in defaultFields) {
          if (defaultFields[f]) {
            this.emptyMediaField(f);
          }
        }
      }

      emptyMediaField(field) {
        let multiSelector =
          "form#new_media select[name='media[" + field + "][]'], " +
          "form#new_media input[name='media[" + field + "][]']";
        let selector =
          "form#new_media select[name='media[" + field + "]'], " +
          "form#new_media input[name='media[" + field + "]'], " +
          "form#new_media textarea[name='media[" + field + "]']";

        switch(field) {
          case 'download_permission':
            $('form#new_media input#media_visibility_open').trigger('click');
            break;
          case 'rights_holder': // multi-value
            $("form#new_media input[name='media[rights_holder_name][]']").first().val('');
            $("form#new_media input[name='media[rights_holder_type][]']").first().val('');
            $("form#new_media input[name='media[rights_holder_name][]']").slice(1).parent().remove();
            break;
          case 'download_reviewer':
            $(selector).val('').trigger('change');
            // $('form#new_media div.media_download_reviewer span.select2-chosen').text('');
            break;
          case 'license': // multi-value fields
          case 'agreement_uri':
          case 'funding':
          case 'publisher':
            $(multiSelector).first().val('');
            $(multiSelector).slice(1).parent().remove();
            break;
          default: // single-value fields
            $(selector).val('');
        }
      }

      fillMediaFields(defaultFields) {
        for (const f in defaultFields) {
          if (defaultFields[f] && defaultFields[f] != []) {
            console.log(f);
            console.log(defaultFields[f]);
            this.fillMediaField(f, defaultFields[f]);
          }
        }
      }

      fillMediaField(field, val) {
        let multiSelector =
          "form#new_media select[name='media[" + field + "][]'], " +
          "form#new_media input[name='media[" + field + "][]']";
        let selector =
          "form#new_media select[name='media[" + field + "]'], " +
          "form#new_media input[name='media[" + field + "]'], " +
          "form#new_media textarea[name='media[" + field + "]']";

        if (Array.isArray(val)) {
          val = val.filter(v => v !== '');
        }

        if ( !val || (Array.isArray(val) && ( !val.length || val[0] == 'Name: , Type: ') ) ) {
          return;
        }

        console.log(val);
        switch(field) {
          case 'download_permission':
            if (val == 'preview_only') {
              let val = 'preview';
            }
            $('form#new_media input#media_visibility_' + val.toLowerCase()).trigger('click');
            $('form#new_media div.media_download_permission').addClass('permissions-field');
            $('form#new_media div.media_download_permission').find('i.tooltip-icon').after(
              "<i class='fas fa-university'></i>"
            );
            break;
          case 'rights_holder': // multi-value
            if (Array.isArray(val) && val.length > 1) {
              for (i = 0; i < val.length; i++) {
                if (val[i]) {
                  // console.log('element: ' + val[i]);
                  let rightsHolderArray = this.extractRightsHolderArray(val[i]);
                  // console.log(rightsHolderArray);
                  $("form#new_media input[name='media[rights_holder_name][]']").eq(i).val(rightsHolderArray[0]);
                  $("form#new_media select[name='media[rights_holder_type][]']").eq(i).val(rightsHolderArray[1]);
                  $(multiSelector).eq(i).val(val[i]);
                  if (i < (val.length - 1) && val[i+1]) {
                    $("form#new_media input[name='media[rights_holder_name][]']").eq(i).parent().find('button.add').trigger('click');
                  }  else {
                    $('form#new_media div.media_rights_holder').addClass('permissions-field');
                    $('form#new_media div.media_rights_holder').find('i.tooltip-icon').after(
                      "<i class='fas fa-university'></i>"
                    );
                  }
                }
              }
            } else {
              let rightsHolderArray = this.extractRightsHolderArray(val[0]);
              $("form#new_media input[name='media[rights_holder_name][]']").val(rightsHolderArray[0]);
              $("form#new_media select[name='media[rights_holder_type][]']").val(rightsHolderArray[1]);
              $('form#new_media div.media_rights_holder').addClass('permissions-field');
              // console.log($('form#new_media div#media_rights_holder_visible').find('label'));
              $('form#new_media div#media_rights_holder_visible').find('i.tooltip-icon').after(
                "<i class='fas fa-university'></i>"
              );
            }
            break;
          case 'download_reviewer':
            $(multiSelector).select2('destroy').empty().userSearchMultiple(val);
            $('form#new_media div.media_download_reviewer').addClass('permissions-field');
            $('form#new_media div.media_download_reviewer').find('i.tooltip-icon').after(
              "<i class='fas fa-university'></i>"
            );

            $('#media_download_reviewer').one("select2-opening", function() {
              alert($('#organization-alert-message').text());
            });
            break;
          case 'license': // multi-value fields
          case 'agreement_uri':
          case 'funding':
          case 'publisher':
            if (Array.isArray(val) && val.length > 1) {
              for (i = 0; i < val.length; i++) {
                if (val[i]) {
                  // console.log('element: ' + val[i]);
                  $(multiSelector).eq(i).val(val[i]);
                  if (i < (val.length - 1) && val[i+1]) {
                    $(multiSelector).eq(i).parent().find('button.add').trigger('click');
                  } else {
                    $(multiSelector).parents('div .media_'+field).addClass('permissions-field');
                    $(multiSelector).parents('div .media_'+field).find('i.tooltip-icon').after(
                      "<i class='fas fa-university'></i>"
                    );
                  }

                }
              }
            } else {
              $(multiSelector).val(val);
              $(multiSelector).parents('div .media_'+field).addClass('permissions-field');
              $(multiSelector).parents('div .media_'+field).find('i.tooltip-icon').after(
                "<i class='fas fa-university'></i>"
              );
            }
            break;
          case 'attachment_url':
            $('div#organization-attachment-row').addClass('permissions-field');
            $('div#organization-attachment-row label span').after(
              "<i class='fas fa-university'></i>"
            );
            break;
          default: // single-value fields
            $(selector).val(val);
            $(selector).parents('div .media_'+field).addClass('permissions-field');
            $(selector).parents('div .media_'+field).find('i.tooltip-icon').after(
              "<i class='fas fa-university'></i>"
            );

        }
      }

      extractRightsHolderArray(s) {
        let rightsHolder = s.substring(s.indexOf('Name: ') + 6, s.lastIndexOf(', Type: '));
        let rightsHolderType = s.substring(s.lastIndexOf(', Type: ') + 8);
        return [rightsHolder, rightsHolderType];
      }

      // TODO: Implement submission data checking? Probably best done at the end

      sidebarEventFuncs() {
        let self = this;

        $('.sidebar a.sidebar-clickable').click(function(){
          console.log('sidebar click');
          event.preventDefault();
          if ($(this).hasClass('selected') || $(this).hasClass('inactive')) {
            return false;
          } else {
            self.setVisibleView($(this).data('view'));
          }
        });
      }

      setSidebarViewCheck(sidebarViewCheck) {
        var sidebarViewCheck = Array.isArray(sidebarViewCheck) ? sidebarViewCheck : [sidebarViewCheck];

        for (const s of sidebarViewCheck) {
          $(this.viewSidebarClass[s]).children('.fa-check').css('visibility', 'visible');
        }
      }

      setSidebarViewFade(sidebarViewFade) {
        var sidebarViewFade = Array.isArray(sidebarViewFade) ? sidebarViewFade : [sidebarViewFade];

        for (const s of sidebarViewFade) {
          $(this.viewSidebarClass[s]).addClass('inactive');
        }
      }

      setSidebarViewCheckAndFade(sidebarView) {
        this.self.form.setSidebarViewCheck(sidebarView);
        this.self.form.setSidebarViewFade(sidebarView);
      }

      setVisibleView(v) {
        this.setVisibility([this.viewSectionIds[v]]);
        $('.sidebar a').removeClass('selected');
        $(this.viewSidebarClass[v]).addClass('selected');
        $(this.viewSidebarClass[v]).removeClass('inactive');
      }

      setVisibility(idArray) {
        $('.submission_section').addClass('hide').removeClass('show');
        $(idArray.join(', ')).addClass('show').removeClass('hide');
      }
    }

    cookie_expired_days = 7;

    setupTooltip();
    var data = new SubmissionData();
    var submissionForm = new SubmissionForm(data);

    console.log(data);

    // Submissions Utility Functions
    var camelcaseToUnderscore = function(x) {
      return x.split(/(?=[A-Z])/).join('_').toLowerCase();
    };

    var underscoreToCamelCase = function(x) {
      return s.replace(/([-_][a-z])/ig, ($1) => {
        return $1.toUpperCase()
          .replace('-', '')
          .replace('_', '');
      });
    };
  } // end if the page is submission flow page
});
