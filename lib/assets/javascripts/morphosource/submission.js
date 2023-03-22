//= require morphosource/submission/submission_data
//= require morphosource/submission/submission_form

/*jshint esversion: 6 */

const MorphosourceAutocomplete = require('morphosource/ms_autocomplete');
const GettyControlledVocabulary = require('morphosource/editor/getty_controlled_vocabulary');

$( document ).ready(function() {
  if ($('div[class="submission_flow"]').length) { // check if the page is submission flow page

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
          data.onBehalfOf = $(this).val();
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

          $('#media_member_of_collection_ids').attr('data-autocomplete-url', '/my/collections/search.json?modality=' + $(this).val());
          $('#s2id_media_member_of_collection_ids').trigger('change');

        });

        var setRawDerivedStatus = function() {
          var mediaType = $("select[name='submission[submission_media_type]']").val();
          var modality = $("select[name='submission[submission_modality]']").val();

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

        $('#submission_parent_media_search').select2({
          placeholder: "Enter parent media ID",
          minimumInputLength: 2,
          ajax: {
            url: findMediaUrl, // Defined in submission new.html.erb
            dataType: 'json',
            quietMillis: 500,
            data: function (term, page) {
              return {
                q: term, // search term
              };
            },
            results: function (data, page) { // parse the results into the format expected by Select2.
              var modified_data = $.map(data, function (val, i) {
                var result_text = 'Media ' + val.id + ': ' + val.label;
                if (val.object_title) {
                  result_text = result_text + ' [Object: ' + val.object_title + ']'
                }
                return { id: val.id, text: result_text };
              });

              return {
                results: modified_data
              };
            },
            cache: true
          }
        });

        $('#submission_parent_media_search').on('select2-selecting', function (e) {
          var item = e.choice;

          if (e.choice && e.choice.id) {
            $("input.parent_id").val(item.id);
            $("input.parent_title").val(item.text);

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
            $("input.parent_id").val('');
            $("input.parent_title").val('');
            e.preventDefault();
            $('#submission_parent_media_search').select2('close');
          }
        });

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

            $('#media_member_of_collection_ids').attr('data-selected-object', $(this).attr('id'));

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

            // Set organization data
            data.setOrganizationDefaults();
            data.organizationId = $(this).data('organization-id');
            data.noOrganization = false;
            data.willCreateOrganization = false;

            // Set organization-related default media permission fields
            self.form.setDefaultMediaPermissionFields();

            console.log(data);
        });

        $('#submission_po_search_results_container').on(
          'click', '.import-idigbio-object', function(event){
          event.preventDefault();
          console.log('View 3 import idigbio object');

          data.setPhysicalObjectDefaults();
          data.idigbioId = $(this).attr('id');
          var recordsetId = $(this).data('recordset');

          var setViewAfterIDBImport = function(recordsetMatch) {
            if (recordsetMatch) {
              // Skip physical object steps and proceed to select device
              data.savedStep = 3;
              self.form.setSidebarViewCheck([3, 4, 5, 6]);
              self.form.setSidebarViewFade([3, 4, 5, 6]);
              self.form.setVisibleView(7); // view 7 select device
            } else {
              // Must select organization
              data.savedStep = 3;
              self.form.setSidebarViewCheck([3, 5, 6]);
              self.form.setSidebarViewFade([3, 5, 6]);
              self.form.setVisibleView(4); // view 4 select organization
            }
          };

          if (data.idigbioId && recordsetId) {
            var recordsetMatch = false;

            // Is there a MS organization that matches this recordset?
            $.get('organization_for_recordset',
              { 'recordset_id': recordsetId },
              function(getData) {
                console.log(getData);
                if (getData.organization_found && getData.organization_id) {
                  // Set variables for view next step logic
                  recordsetMatch = true;

                  // Set organization data
                  data.setOrganizationDefaults();
                  data.organizationId = getData.organization_id;
                  data.noOrganization = false;
                  data.willCreateOrganization = false;

                  // Set organization-related default media permission fields
                  self.form.setDefaultMediaPermissionFields();
                }
              }
            ).always(function () {
              setViewAfterIDBImport(recordsetMatch);
            });
          } else {
            setViewAfterIDBImport(false);
          }

          console.log(data);
        });

        $('#submission_will_create_bso').click(function(event){
          event.preventDefault();
          console.log('View 3 create new physical object button');

          $('#new_biological_specimen .controlled_vocabulary.form-group').each((_idx, controlled_field) =>
            new GettyControlledVocabulary(controlled_field, 'biological_specimen')
          )

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

          $('#new_cultural_heritage_object .controlled_vocabulary.form-group').each((_idx, controlled_field) =>
            new GettyControlledVocabulary(controlled_field, 'cultural_heritage_object')
          )

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
        $("#submission_organization_search").select2({
          data: orgData, // Defined in new.html.erb view
          placeholder: 'Enter institution or organization name or codes'
        });

        $('#submission_organization_search').on('select2-selecting', function (e) {
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

        $('form#organization_search_form').submit(function(event){
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
          submissionForm.resetFormFromOrg(submissionForm.organizationDefaultMediaFields);

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

        // Select taxonomy

        $('#submission_taxonomy_search').select2({
          placeholder: "Enter taxonomy keywords (species, genus, higher terms)",
          minimumInputLength: 2,
          ajax: {
            url: findTaxonomyUrl, // Defined in submission new.html.erb
            dataType: 'json',
            quietMillis: 500,
            data: function (term, page) {
              return {
                q: term, // search term
              };
            },
            results: function (data, page) { // parse the results into the format expected by Select2.
              console.log(data);
              return {
                results: data
              };
            },
            cache: true
          },
          formatResult: formatTaxonomy,
          formatSelection: formatTaxonomy
        });

        function formatTaxonomy(taxon) {
          return "<div>" +
            buildName(taxon.name, taxon.rank) +
            "<br/><span style='font-size: small;'>" +
            taxon.higher_taxonomy +
            "</span><br/>" +
            taxon.source_info +
            "</div>";
        }

        function buildName(name, rank) {
          var s = "";
          if (rank) {
            if (rank == 'GENUS' || rank == 'SPECIES' || rank == 'SUBSPECIES') {
              s = s + "<i>" + name + "</i>";
            } else {
              s = s + name;
            }
            s = s + " (" + rank.toLowerCase() + ")";
          } else {
            s = s + "<i>" + name + "</i>";
          }
          return s;
        }

        $('#submission_taxonomy_search').on('select2-selecting', function (e) {
          console.log(JSON.stringify(e.choice));
          var item = e.choice;

          if (e.choice && e.choice.id) {
            $("input.taxonomy_id").val(item.id);
            $("input.taxonomy_gbif_key").val(item.gbif_key);
            $("input.taxonomy_title").val(buildNameNoFormatting(item.name, item.rank));

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
            $("input.taxonomy_id").val('');
            $("input.taxonomy_gbif_key").val('');
            $("input.taxonomy_title").val('');

            // Clear select2
            e.preventDefault();
            $('#submission_taxonomy_search').select2('close');

            // Enable step completion
            $('#submission_select_taxonomy_submit').removeAttr('disabled');
          }
        });

        function buildNameNoFormatting(name, rank) {
          var s = name;
          if (rank) {
            s = s + " (" + rank.toLowerCase() + ")";
          }
          return s;
        }

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

        // Create taxonomy

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

        // Continue button

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

        // Device organization select

        $("#submission_device_select_organization_search").select2({
          data: orgData,
          placeholder: 'Enter institution or organization name or codes'
        });

        $('#submission_device_select_organization_search').on('select2-selecting', function (e) {
          console.log(JSON.stringify(e.choice));
          var item = e.choice;

          if (e.choice && e.choice.id) {
            console.log(e.choice);
            clearList();
            removePreviousSelection();

            var devices = $.map(e.choice.devices, function( val, i ) {
              return deviceData[val];
            });
            if (devices) {
              enableDeviceList();
              listDevices(devices);
            }
          }
        });

        // No organization select

        $('#submission_select_device_no_organization').click(function(event) {
          event.preventDefault();
          console.log(nullOrg);
          if (nullOrg) {
            clearList();
            removePreviousSelection();

            $("#submission_device_select_organization_search").select2('data', nullOrg);

            var devices = $.map(nullOrg.devices, function( val, i ) {
              return deviceData[val];
            });
            if (devices) {
              enableDeviceList();
              listDevices(devices);
            }
          }
        });

        // Organization utility function

        function clearList() {
          $('form#submission_device_select_form select#submission_device_id option').each(function () {
            $("#submission_device_id").select2('val', null);
            if ($(this).attr('value')) {
              $(this).remove();
            }
          });
        }

        function removePreviousSelection() {
          $("#submission_device_id").select2('val', null);
          $('#submission_device_select_display').addClass('hide').removeClass('show');
          $('#submission_select_device_continue').attr('disabled', 'disabled');
        }

        function enableDeviceList() {
          $('form#submission_device_select_form select#submission_device_id').removeAttr('disabled');
          $('form#submission_device_select_form div.submission_device_id label').removeClass('disabled');
        }

        function listDevices(devices) {
          for (const device of devices) {
            $('form#submission_device_select_form select#submission_device_id')
              .append($('<option></option>')
                .attr('value', device.id)
                .attr('data-modality', device.modality)
                .attr('data-description', device.description)
                .text(device.text)
              );
          }
        }

        // Device select

        $("#submission_device_id").select2({
          placeholder: 'Select device'
        });

        $('#submission_device_id').on('select2-selecting', function (e) {
          console.log(JSON.stringify(e.choice));
          var item = e.choice;


          if (e.choice && e.choice.id) {
            var deviceObj = deviceData[e.choice.id]
            if (deviceObj && deviceObj.modality && data.submissionModality && deviceObj.modality.split(',').includes(data.submissionModality)) {
              console.log('Value provided and validated');
              console.log(deviceObj.modality);
              console.log(data.submissionModality);
              self.toggleSelectDeviceVisibility(deviceObj);
              $('#submission_select_device_continue').removeAttr('disabled');
            } else {
              console.log(deviceObj.modality);
              console.log(data.submissionModality);
              alert('Modality of selected device must match modality entered in Initial Information step.');
              $('#submission_select_device_continue').attr('disabled', 'disabled');
              e.preventDefault();
            }
          } else {
            $("#submission_device_id").select2('val', null);
            $('#submission_select_device_continue').attr('disabled', 'disabled');
            e.preventDefault();
          }
        });

        $('#submission_device_select_display_container').on(
          'click', '#device-select-close', function(event){
            $("#submission_device_id").select2('val', null);
            $('#submission_select_device_section').addClass('show').removeClass('hide');
            $('#submission_create_device_button_section').addClass('show').removeClass('hide');
            $('#submission_device_select_display').addClass('hide').removeClass('show');
            $('#submission_select_device_continue').attr('disabled', 'disabled');
        });

        // Continue

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
      }

      showDeviceSelectDisplay(deviceObj) {
        $('#device-display-title').text(deviceObj.title);
        $('#device-display-creator').text(deviceObj.creator);
        $('#device-display-modality').text(deviceObj.modality);
        $('#device-display-description').text(deviceObj.description);
        $('#submission_device_select_display').addClass('show').removeClass('hide');
      }

      toggleSelectDeviceVisibility(deviceObj) {
        $('#submission_create_device_button_section').addClass('hide').removeClass('show');
        $('#submission_create_device_form_section').addClass('hide').removeClass('show');
        this.showDeviceSelectDisplay(deviceObj);
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

          /* For RAW, get creator and creation date from imaging event
             For DERIVED, get them from processing event (and fall back on imaging event) */
          var IE_CreatorsCount = $('[name="imaging_event[creator][]"]').length;
          $('[name="imaging_event[creator][]"]').each(function(index) {
            if ($(this).val() != '') {
              console.log('setting default creator from IE: '+$(this).val());
              $('[name="media[creator][]"]').eq(index).val($(this).val());
            }
            // add another creator field if needed
            if (IE_CreatorsCount != index + 1) {
              $(".media_creator").find("button.add").last().trigger("click");
            }
          });
          $('[name="media[date_created]"]').val($('#imaging_event_date_created').val());

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

          /* For RAW, get creator and creation date from imaging event
             For DERIVED, get them from processing event (and fall back on imaging event) */
          if (data.rawOrDerivedMedia == 'derived') {
            var PE_CreatorsCount = $('[name="processing_event[creator][]"]').length;
            if (PE_CreatorsCount > 0 && $('[name="processing_event[creator][]"]').eq(0).val() != '') {
              // remove all media creators before adding
              $(".media_creator").find("button.remove:not(:first)").trigger("click");
              $('[name="processing_event[creator][]"]').each(function(index) {
                if ($(this).val() != '') {
                  console.log('setting default creator from PE: '+$(this).val());
                  $('[name="media[creator][]"]').eq(index).val($(this).val());
                }
                // add another creator field if needed
                if (PE_CreatorsCount != index + 1) {
                  $(".media_creator").find("button.add").last().trigger("click");
                }
              });
            }
            if ($('#processing_event_date_created').val() != '') {
              $('[name="media[date_created]"]').val($('#processing_event_date_created').val());
            }
          }

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

        $("select#media_transfer_management, input[name='media[visibility]']").change(function(event){
          self.form.updateOrganizationDataManagementInfo();
        });

        $('#media_submit').click(function(event){
          event.preventDefault();

          if (!hasRequiredFields()) {
            return false;
          }

          if (fileOrigin == 'local') {
            if (!uploadStatusOK) {
              // file upload is in progress. Prompt for auto save
              promptAutoSave(".btn-save-media");
              return false;
            }
            if (!noFileCheck()) {
              return false;
            }
            self.submitMedia();

          } else { // remote
            remoteFileCheckAndSubmit(self);
          }

        });
      }

      submitMedia() {
        let self = this;

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

        // Re-enable media permission fields possibly disabled by org mandate
        $('form#new_media div#submission-media-ownership div#media-ownership-fields input,select,textarea')
          .not('select#media_transfer_management')
          .prop('disabled', false);

        $('#new_media').submit();
      }

      addParamToForm(formId, paramName, paramValue) {
        $('<input />').attr('type', 'hidden')
          .attr('name', paramName)
          .attr('value', paramValue)
          .appendTo(formId);
      }
    }

    cookie_expired_days = 7;

    setupTooltip();

    if (typeof depositor !== 'undefined') {
      var data = new SubmissionData(depositor);
    } else {
      var data = new SubmissionData();
    }
    var submissionForm = new SubmissionForm(data);

    submissionForm.views = [
      new RawOrDerivedView(submissionForm),
      new ParentMediaView(submissionForm),
      new PhysicalObjectSearchCreateView(submissionForm),
      new OrganizationView(submissionForm),
      new TaxonomyView(submissionForm),
      new PhysicalObjectDetailsView(submissionForm),
      new DeviceView(submissionForm),
      new ImagingEventView(submissionForm),
      new ProcessingEventView(submissionForm),
      new MediaView(submissionForm)
    ];
    submissionForm.viewSidebarClass = {
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
    submissionForm.viewSectionIds = {
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
    submissionForm.initializeForm();

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

    $("#tab-remote-file-section a").click(function(){
      // Clear the hash to prevent showing remote file tab if user reloads the page
      location.hash = '';
    });

  } // end if the page is submission flow page
});
