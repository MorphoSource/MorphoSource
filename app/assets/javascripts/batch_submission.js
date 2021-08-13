$( document ).ready(function() {

  if ($('[class*="batch-submission"]').length) { // check if the page is submission flow page


    class BatchSubmissionData {
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

    } // BatchSubmissionData


    class BatchSubmissionForm {
      constructor(submissionData) {
        this.data = submissionData;

        this.views = [
          new OrganizationView(this),
          new DeviceView(this),
//          new ImagingEventView(this),
//          new ProcessingEventView(this),
//          new MediaView(this)
        ];

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
    } // BatchSubmissionForm

    class BatchSubmissionView {
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

    class OrganizationView extends BatchSubmissionView {
      constructor(form) {
        super(4, form);
        this.eventFuncs();
      }

      eventFuncs() {
        let self = this;

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
          console.log('select organization button');
          var selectedOrganizationID = $('#organization_search_form input.organization_id').val();
          if (selectedOrganizationID) {
            data.setOrganizationDefaults();
            data.organizationId = selectedOrganizationID;
            data.organizationCollectionCode = $('#organization_search_form input.organization_collection_code').val().split(', ');
            data.organizationInstitutionCode = $('#organization_search_form input.organization_institution_code').val().split(', ');
            data.noOrganization = false;
            data.willCreateOrganization = false;
            data.savedStep = 4;
//            self.populatePhysicalObjectInstitutionCollectionCodes();
//            self.next();

            console.log(data);
//            self.form.setDefaultMediaPermissionFields();
          }
        });

        // No Organization Event

        $('#submission_no_organization').click(function(event){
          event.preventDefault();
          console.log('no organization button');

          data.setOrganizationDefaults();
          data.noOrganization = true;
          data.willCreateOrganization = false;
 //         data.savedStep = 4;
          self.toggleNoOrganizationVisibility();
          ['biological_specimen','cultural_heritage_object'].forEach((physical_object_type) => {
            ['collection_code','institution_code'].forEach((code_type) => {
              var dom_id = physical_object_type + '_' + code_type;
              var form_input_name = physical_object_type + '[' + code_type + ']';
              $('#' + dom_id).replaceWith($('<input>',{id: dom_id, name: form_input_name, class: 'form-control string optional'}));
            });
          });
//          self.next();

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
      } // eventFuncs

      next() {
        if (data.idigbioId) {
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
    } //OrganizationView

    class DeviceView extends BatchSubmissionView {
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
          $('form#submission_device_select_form select#batch_submission_device_id option').each(function () {
            $("#batch_submission_device_id").select2('val', null);
            if ($(this).attr('value')) {
              $(this).remove();
            }
          });
        }

        function removePreviousSelection() {
          $("#batch_submission_device_id").select2('val', null);
          $('#submission_device_select_display').addClass('hide').removeClass('show');
          $('#submission_select_device_continue').attr('disabled', 'disabled');
        }

        function enableDeviceList() {
          $('form#submission_device_select_form select#batch_submission_device_id').removeAttr('disabled');
          $('form#submission_device_select_form div.batch_submission_device_id label').removeClass('disabled');
        }

        function listDevices(devices) {
          for (const device of devices) {
            $('form#submission_device_select_form select#batch_submission_device_id')
              .append($('<option></option>')
                .attr('value', device.id)
                .attr('data-modality', device.modality)
                .attr('data-description', device.description)
                .text(device.text)
              );
          }
        }

        // Device select

        $("#batch_submission_device_id").select2({
          placeholder: 'Select device'
        });

        $('#batch_submission_device_id').on('select2-selecting', function (e) {
          console.log(JSON.stringify(e.choice));
          var item = e.choice;

/*

todo: might have to check modality later

          if (e.choice && e.choice.id) {
*/
            var deviceObj = deviceData[e.choice.id]
/*
            if (deviceObj && deviceObj.modality && data.submissionModality && deviceObj.modality.includes(data.submissionModality)) {
              console.log('Value provided and validated');
              console.log(deviceObj.modality);
              console.log(data.submissionModality);
*/
              self.toggleSelectDeviceVisibility(deviceObj);
              $('#submission_select_device_continue').removeAttr('disabled');
/*
            } else {
              console.log(deviceObj.modality);
              console.log(data.submissionModality);
              alert('Modality of selected device must match modality entered in Initial Information step.');
              $('#submission_select_device_continue').attr('disabled', 'disabled');
              e.preventDefault();
            }
          } else {
            $("#batch_submission_device_id").select2('val', null);
            $('#submission_select_device_continue').attr('disabled', 'disabled');
            e.preventDefault();
          }
*/          
        });

        $('#submission_device_select_display_container').on(
          'click', '#device-select-close', function(event){
            $("#batch_submission_device_id").select2('val', null);
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

    var data = new BatchSubmissionData();
    var batchSubmissionForm = new BatchSubmissionForm(data);

  } // end if the page is submission flow page
});
