//= require morphosource/submission/submission_form

$( document ).ready(function() {

  if ($('body[class*="batch-submission"]').length) { // check if the page is batch submission index page
    $('.clear-bs-form').click(function(event){
      // clear previous submitted data before loading the form
      localStorage.removeItem("batchSubmissionFormData");
    })
  }

  if ($('[class*="batch-submission-form"]').length) { // check if the page is batch submission form
    previousBatchSubmissionData = previousSubmissionData();
    prevBsData = {};
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
          if (e.choice) {
            console.log("org selected >>", JSON.stringify(e.choice));
            var item = e.choice;          
          } else if (prevBsData != {}) {
            console.log('getting org from prevBsData >>', prevBsData);
            var item = prevBsData.organization;
          }
          if (item && item.id) {
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

            // UI controls
            $('#submission_select_organization_section').addClass('show').removeClass('hide');
            $('#submission_create_organization_button_section').addClass('show').removeClass('hide');
            $('#submission_no_organization_section').addClass('show').removeClass('hide');
            $('#submission_organization_select_display').addClass('hide').removeClass('show');
            $('#submission_select_organization').attr('disabled', 'disabled');
            $("#no-attachment").addClass('show').removeClass('hide');            
            $("#organization-agreement-uri").addClass('hide').removeClass('show');
            $("#organization-attachment-url").attr("href", "").addClass('hide').removeClass('show');

            $("#batch_submission_organization_search").select2('val', null);
            data.setOrganizationDefaults();
            data.noOrganization = true;

            setSubmitStatus();
        });

        var setOrgData = function() {
          var selectedOrganizationID = $('input.organization_id').val();
          console.log('selectedOrganizationID: ', selectedOrganizationID);
          if (selectedOrganizationID) {
            data.setOrganizationDefaults();
            data.organizationId = selectedOrganizationID;
            data.organizationCollectionCode = $('input.organization_collection_code').val().split(', ');
            data.organizationInstitutionCode = $('input.organization_institution_code').val().split(', ');
            data.noOrganization = false;
            data.willCreateOrganization = false;
            data.savedStep = 4;

            console.log(data);
            if (previousBatchSubmissionData == null || self.form.orgChanged) {
              // new submission, or user has previously changed the org selection
              self.form.setDefaultMediaPermissionFields();
            } else {
              if (data.organizationId != formData['organization_id']) {
                // user selects a different org on a restored form
                self.form.setDefaultMediaPermissionFields();
                self.form.orgChanged = true;
              } else {
                // set org when loading a restored form
                self.form.setPreviousOrgAgreement();
              }
            }
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

        $("select#media_transfer_management, input[name='batch_submission[media][visibility]']").change(function(event){
          self.form.updateOrganizationDataManagementInfo();
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
          if (e.choice) {
            console.log("device org selected >>", JSON.stringify(e.choice));
            var item = e.choice;          
          } else if (prevBsData != {}) {
            console.log('getting device org from prevBsData >>', prevBsData);
            var item = prevBsData.device_organization;
          }
          if (item && item.id) {
            clearList();
            removePreviousSelection();
            var devices = $.map(item.devices, function( val, i ) {
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
          if (e.choice) {
            console.log("device selected >>", JSON.stringify(e.choice));
            var item = e.choice;          
          } else if (prevBsData != {}) {
            console.log('getting device from prevBsData >>', prevBsData);
            var item = prevBsData.device;
          }
          var deviceObj = deviceData[item.id];
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
    var batchSubmissionForm = new RestoreableSubmissionForm(data, previousSubmissionData);

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







    function previousSubmissionData() {
      var bsObj = localStorage.getItem("batchSubmissionFormData");
      if (bsObj != null) {
        var bsFormData = JSON.parse(bsObj);
        var now = new Date().getTime();
        var minOld = Math.floor((now - bsFormData.timestamp)/1000/60);
        if (minOld > 1440) {
          console.log("expiring form data after 1 day...")
          localStorage.removeItem("batchSubmissionFormData");
          return null;
        } else {
          return bsFormData.data;
        }
      }    
    }

    $('#start-over').click(function(){
      if (confirm('Clear the form and start over?')) {
        localStorage.removeItem("batchSubmissionFormData");
        location.reload();
      }
    })
    
    // re-fill the form if needed
    if (previousBatchSubmissionData != null) {
      //console.log("loading previousBatchSubmissionData :", previousBatchSubmissionData);
      var formData = {};
      $.each(previousBatchSubmissionData, function(i, field) {
        if (field.name == "projects") {
          formData["projects"] = field.value;
        } else if (field.name == "reviewers") {
          formData["reviewers"] = field.value;
        } else if (field.name == "orgData") {
          batchSubmissionForm.orgData = field.value;
        } else {
          if (field.value.trim() != "") {
            if (formData[field.name] != undefined) {
              var val = formData[field.name];
              if (!Array.isArray(val)) {
                 arr = [val];
              }
              arr.push(field.value.trim());
              formData[field.name] = arr;
            } else {
              formData[field.name] = field.value;
            }
          }
        }
      });
      populateForm($('#batch_submission_form'), formData);      
    }

    function populateForm(fm, data) {
        // popuplate the select2 dropdowns
        // get the org, device org, and device details from orgData and deviceData objects, 
        // then set the details in prevBsData to be used for select2-selecting event
        console.log("popuplating data :", data);
        var orgId = data["batch_submission[organization_search]"];
        var orgIndex = orgData.findIndex(item => item.id === orgId);
        var deviceOrgId = data["batch_submission[device_organization_search]"];
        var deviceOrgIndex = orgData.findIndex(item => item.id === deviceOrgId);
        var deviceId = data["batch_submission[device_id]"];
        prevBsData = { 
          organization: orgData[orgIndex],
          device_organization: orgData[deviceOrgIndex],
          device: deviceData[deviceId]
        }
        $("#batch_submission_organization_search").select2('val', orgId).trigger('select2-selecting'); 
        $("#submission_device_select_organization_search").select2('val', deviceOrgId).trigger('select2-selecting'); 
        $("#batch_submission_device_id").select2('val', deviceId).trigger('select2-selecting'); 
        // refill download permission
        var visibility = data["batch_submission[media][visibility]"];
        $('[value="' + visibility + '"]').prop('checked', true);
        set_visibility(visibility);  
        // refill the rest
        $.each(data, function(key, value) {
          try {
            var ctrl = fm.find('[name="'+key+'"]');
            if (ctrl.is('select')){
                $('option', ctrl).each(function() {
                    if (this.value == value)
                        this.selected = true;
                });
            } else if (ctrl.is('textarea')) {
                ctrl.val(value);
            } else {
                switch(ctrl.attr("type")) {
                    case "text":
                      if (ctrl.hasClass('multi-text-field')) {
                        if ($.isArray(value)) {
                          var value_ary = value
                        } else {
                          var value_ary = value.split(',');
                        }
                        var input = ctrl;
                        $.each(value_ary, function( idx, v ) {
                          $(input).val(v);
                          if (idx != value_ary.length-1) {
                            ctrl.closest('.form-group').find('.btn.add').last().trigger('click');
                            input = ctrl.closest('.form-group').find('input')[idx+1];
                          }
                        })
                      } else {
                        ctrl.val(value);   
                      }
                      break;                        
                    case "hidden":
                      ctrl.val(value);   
                      break;
                    case "checkbox":
                      if (value == '1')
                        ctrl.prop('checked', true);
                      else
                        ctrl.prop('checked', false);
                      break;
                } 
            }
          } catch (e) {
            console.log('error ', e);        
          }
        });

        var projects_to_add = data["projects"];
        $.each(projects_to_add, function( id, proj ) {
          $('#batch_submission_media_member_of_collection_ids').val(proj.id).trigger('change'); 
          $('[data-id="' + proj.id + '"]').text(proj.name);
        })

        reviewerSelect = $('#media_download_reviewer');
        var reviewers_to_add = data['reviewers'];
        if (reviewers_to_add.length > 0) {
          var reviewers_array = []
          $.each(reviewers_to_add, function( id, reviewer ) {
            reviewers_array.push({ "id":id, "user_key":reviewer.id, "text":reviewer.name }); 
          })
          reviewerSelect.data("reviewers", reviewers_array);
          // add search to download reviewer
          reviewerSelect.userSearchMultiple(reviewerSelect.data('reviewers'));          
        } else {
          // remove the default reviewer
          reviewerSelect.data('reviewers', '');
          reviewerSelect.select2('destroy').empty().userSearchMultiple('');
        }
    };

    $('#batch_submission_form').submit(function(){
      var formData = $('#batch_submission_form').serializeArray();

      var projects = []
      $('.select-projects table').find('tr').not('.hidden').find('.collection-title').each(function( index ) {
        projects.push({ id: $(this).data("id"), name: $(this).html() });
      })
      formData.push({ name: "projects", value: projects });

      var reviewers = []
      var choices = $('.media_download_reviewer').find('.select2-search-choice > div');
      if ((choices.length > 0) && ($('#media_download_reviewer').val() != '')) {
        var reviewerIDs = $('#media_download_reviewer').val().split(',');
        $.each(reviewerIDs, function(index, item) {
          reviewers.push({ id:item , name:$(choices[index]).text() });
        })
      }
      formData.push({ name: "reviewers", value: reviewers });

      formData.push({ name: "orgData", value: batchSubmissionForm.orgData });

      var obj = {data: formData, timestamp: new Date().getTime()}
      localStorage.setItem("batchSubmissionFormData", JSON.stringify(obj));
      //console.log("saved to localStorage... ", localStorage.getItem("batchSubmissionFormData"));
    });

  } // end if the page is submission flow page
});
