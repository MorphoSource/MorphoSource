//= require morphosource/submission/submission_form

$( document ).ready(function() {

  if ($('[class*="batch-submission-form"]').length) { // check if the page is submission form
    showAlert = false;
    selectedDeviceModality = "";

    class BatchSubmissionData {
      constructor(sessionState=null) {
        if (sessionState) {
          this.constructSubmissionParams(sessionState);
          this.constructCreateParams(sessionState);
        }
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
          console.log("org selected ", JSON.stringify(e.choice));
          var item = e.choice;
          if (e.choice && e.choice.id) {
            $("input.organization_id").val(item.id);
            $("input.organization_title").val(item.title);
            $("input.organization_label").val(item.text);
            $("input.organization_collection_code").val(item.collection_code);
            $("input.organization_institution_code").val(item.institution_code);
            $("input.organization_recordset_id").val(item.recordset_id);

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
          setOrgData();
        });

        $('#submission_organization_select_display_container').on(
          'click', '#organization-select-close', function(event){
            // Remove data values
            $("#submission_organization_search").select2('val', null);
            $("input.organization_id").val('');
            $("input.organization_title").val('');
            $("input.organization_label").val('');
            $("#submission_organization_select_display .showcase-value").text('');
            $('input#batch_submission_media_agreement_uri').val('');
            $('input#batch_submission_media_org_for_attachment').val('');

            // UI controls
            $('#submission_select_organization_section').addClass('show').removeClass('hide');
            $('#submission_create_organization_button_section').addClass('show').removeClass('hide');
            $('#submission_no_organization_section').addClass('show').removeClass('hide');
            $('#submission_organization_select_display').addClass('hide').removeClass('show');
            $('#submission_select_organization').attr('disabled', 'disabled');

            $("#batch_submission_organization_search").select2('val', null);
            data.setOrganizationDefaults();
            data.noOrganization = true;

            setSubmitStatus();
        });

        //$('#submission_select_organization').click(function(event){
        var setOrgData = function() {
          //event.preventDefault();
          console.log('set organization data');
          var selectedOrganizationID = $('input.organization_id').val();
          if (selectedOrganizationID) {
            data.setOrganizationDefaults();
            data.organizationId = selectedOrganizationID;
            data.organizationCollectionCode = $('input.organization_collection_code').val().split(', ');
            data.organizationInstitutionCode = $('input.organization_institution_code').val().split(', ');
            data.noOrganization = false;
            data.willCreateOrganization = false;
            data.savedStep = 4;

            console.log(data);
            self.form.setDefaultMediaPermissionFields();
          }
          setSubmitStatus();
        }

        // No Organization Event

        $('#submission_no_organization').click(function(event){
          event.preventDefault();
          console.log('no organization button');

          data.setOrganizationDefaults();
          data.noOrganization = true;
          data.willCreateOrganization = false;

          self.toggleNoOrganizationVisibility();

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
          $('select#batch_submission_device_id option').each(function () {
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
          $('select#batch_submission_device_id').removeAttr('disabled');
          $('div.batch_submission_device_id label').removeClass('disabled');
        }

        function listDevices(devices) {
          for (const device of devices) {
            $('select#batch_submission_device_id')
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
          console.log('device selected ' + JSON.stringify(e.choice));
          var item = e.choice;

          var deviceObj = deviceData[e.choice.id]
          selectedDeviceModality = deviceObj["modality"]
          console.log('selected device modality : ' + selectedDeviceModality);
          self.toggleSelectDeviceVisibility(deviceObj);

          if (selectedDeviceModality.split(',').length > 1) {
            // more than one modality supported by the device
            $('select#batch_submission_modality').val('').change();
          } else {
            $('select#batch_submission_modality').val(selectedDeviceModality).change();
          }

          data.setDeviceDefaults();
          data.deviceId = $('select[name="submission[device_id]"]').val();
          setSubmitStatus();
        });

        $('#submission_device_select_display_container').on(
          'click', '#device-select-close', function(event){
            $("#batch_submission_device_id").select2('val', null);
            $('select#batch_submission_modality').val('').change();
            $('#submission_select_device_section').addClass('show').removeClass('hide');
            $('#submission_create_device_button_section').addClass('show').removeClass('hide');
            $('#submission_device_select_display').addClass('hide').removeClass('show');
            setSubmitStatus();
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
      }
    }

    var data = new BatchSubmissionData();
    var batchSubmissionForm = new SubmissionForm(data);

    batchSubmissionForm.views = [
      new OrganizationView(batchSubmissionForm),
      new DeviceView(batchSubmissionForm),
    ];
    batchSubmissionForm.initializeForm();

    $('#submission_organization_select_display_container').on('click', '#organization-select-close', function(event) {
        // user click close button to remove selected org
        console.log("removing selected org");
        batchSubmissionForm.resetFormFromOrg(batchSubmissionForm.organizationDefaultMediaFields);
    });
      
    $('#manifest_file, #batch_submission_modality').on('change', function(){ setSubmitStatus() });
    $(".btn-submit-wrapper").on('mouseover', function(){ 
      showAlert = true;
      setSubmitStatus();
    });

    var setSubmitStatus = function(){
      var okToSubmit = true;
      var selectedOrganizationID = $('input.organization_id').val();
      if (selectedOrganizationID == "") {
        okToSubmit = false;
         if (showAlert) $(".select-organization").addClass('text-alert');
      } else {
        $(".select-organization").removeClass('text-alert');        
      }
      if ($('#submission_device_select_display').hasClass('hide')) {
        okToSubmit = false;
        if (showAlert) $(".select-device").addClass('text-alert');
      } else {
        $(".select-device").removeClass('text-alert');        
      }
      if ($('select[name="batch_submission[modality]"]').val() == "") {
        okToSubmit = false;
        if (showAlert) $(".select-modality").addClass('text-alert');
      } else if (selectedDeviceModality.indexOf( $('select[name="batch_submission[modality]"]').val() ) == -1) {
        okToSubmit = false;
        if (showAlert) $(".select-modality").addClass('text-alert');
        console.log('modality not match');
      } else {
        $(".select-modality").removeClass('text-alert');        
      }
      if ($("#manifest_file").val() == "") {
        okToSubmit = false;
         if (showAlert) $(".select-manifest b").addClass('text-alert');
      } else {
        $(".select-manifest b").removeClass('text-alert');        
      }
      if (okToSubmit) {
        $("#btn-submit").prop('disabled', false);
      } else {
        $("#btn-submit").prop('disabled', true);
      }
    };

  } // end if the page is submission flow page
});
