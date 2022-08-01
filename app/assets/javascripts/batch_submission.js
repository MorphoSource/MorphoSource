//= require morphosource/submission/submission_data
//= require morphosource/submission/submission_form

/*jshint esversion: 6 */

$( document ).ready(function() {

  if ($('body[class*="batch-submission-dashboard"]').length) { // check if the page is batch submission index page
    // clear previous submitted data 
    localStorage.removeItem("batchSubmissionFormData");
  }

  if ($('[class*="batch-submission-form"]').length) { // check if the page is batch submission form

    class RestoreableSubmissionForm extends SubmissionForm {

      constructor(submissionData) {
        super(submissionData);
      }

      initializeForm() {
        $('.required').addClass('required-flag');
        this.setMediaPermissionFieldEvent();

        this.view = new BatchSubmissionView($('#batch_submission_form'));
        this.previousSubmissionData = this.setPreviousSubmissionData();
        if (this.previousSubmissionData != null) {
          this.view.populateForm(this.previousSubmissionData);
        } 
      }

      setPreviousSubmissionData() {
        let bsObj = localStorage.getItem("batchSubmissionFormData");
        if (bsObj != null) {
          let bsFormData = JSON.parse(bsObj);
          let now = new Date().getTime();
          let minOld = Math.floor((now - bsFormData.timestamp)/1000/60);
          if (minOld > 1440) {
            console.log("expiring form data after 1 day...")
            localStorage.removeItem("batchSubmissionFormData");
            return null;
          } else {
            return bsFormData.data;
          }
        } else {
          return null;
        }
      }

      setPreviousOrgAgreement() {
        let self = this;
        let organization_id = $('[name=organization_id]').val();
        let orgData = self.orgData;
        if (orgData.default_fields && organization_id) {
          if (Object.keys(orgData.default_fields).length) {
            if ( orgData.organization_id && ( orgData.default_fields.attachment_url || orgData.default_fields.agreement_uri ) ) {
              self.setOrganizationAgreement(orgData.default_fields, orgData.organization_id);
            } else {
              self.setNoOrganizationAgreement();
            }
          }
        }

      } 

    } //RestoreableSubmissionForm

    class BatchSubmissionView {
      constructor(form) {
        this.form = form;
        this.eventFuncs();
      }

      init() {
        // overwrite this for form re-instantiation (not implemented for now)
      }

      eventFuncs() {
        let self = this;

        self.form.submit(function(){
          let formData = self.form.serializeArray();

          let projects = []
          $('.select-projects table').find('tr').not('.hidden').find('.collection-title').each(function( index ) {
            projects.push({ id: $(this).data("id"), name: $(this).html() });
          })
          formData.push({ name: "projects", value: projects });

          let reviewers = []
          let choices = $('.media_download_reviewer').find('.select2-search-choice > div');
          if ((choices.length > 0) && ($('#media_download_reviewer').val() != '')) {
            let reviewerIDs = $('#media_download_reviewer').val().split(',');
            $.each(reviewerIDs, function(index, item) {
              reviewers.push({ id:item , name:$(choices[index]).text() });
            })
          }
          formData.push({ name: "reviewers", value: reviewers });

          formData.push({ name: "orgData", value: batchSubmissionForm.orgData });

          let obj = {data: formData, timestamp: new Date().getTime()}
          localStorage.setItem("batchSubmissionFormData", JSON.stringify(obj));
        });

        self.form.find('#start-over').click(function(){
          if (confirm('Clear the form and start over?')) {
            localStorage.removeItem("batchSubmissionFormData");
            location.reload();
          }
        })

        self.form.find('#submission_organization_select_display_container').on('click', '#organization-select-close', function(event) {
          // user click close button to remove selected org
          batchSubmissionForm.resetFormFromOrg(batchSubmissionForm.organizationDefaultMediaFields);
        });
          
        self.form.find('#manifest_file, #batch_submission_modality').on('change', function(){ 
          self.setSubmitStatus();
        });
        
        self.form.find(".btn-submit-wrapper").on('mouseover', function(){ 
          showAlert = true;
          self.setSubmitStatus();
        });

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

      setSubmitStatus() {
        let okToSubmit = true;
        let selectedOrganizationID = $('input.organization_id').val();
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
      }

      populateForm(previousBatchSubmissionData) {
        // re-fill the form if needed
        let formData = {};
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
                   var arr = [val];
                }
                arr.push(field.value.trim());
                formData[field.name] = arr;
              } else {
                formData[field.name] = field.value;
              }
            }
          }
        });
        batchSubmissionForm.restoredFormData = formData;

        let fm = this.form;
        // popuplate the select2 dropdowns
        // get the org, device org, and device details from orgData and deviceData objects, 
        // then set the details in prevBsData to be used for select2-selecting event
        let orgId = formData["batch_submission[organization_search]"];
        let orgIndex = orgData.findIndex(item => item.id === orgId);
        let deviceOrgId = formData["batch_submission[device_organization_search]"];
        let deviceOrgIndex = orgData.findIndex(item => item.id === deviceOrgId);
        let deviceId = formData["batch_submission[device_id]"];
        prevBsData = { 
          organization: orgData[orgIndex],
          device_organization: orgData[deviceOrgIndex],
          device: deviceData[deviceId]
        }
        $("#batch_submission_organization_search").select2('val', orgId).trigger('select2-selecting'); 
        $("#submission_device_select_organization_search").select2('val', deviceOrgId).trigger('select2-selecting'); 
        $("#batch_submission_device_id").select2('val', deviceId).trigger('select2-selecting'); 

        $.each(formData, function(key, value) {
          try {
            let ctrl = fm.find('[name="'+key+'"]');

            if (ctrl.is('select')){
              $('option', ctrl).each(function() {
                if (this.value == value) {
                  this.selected = true;
                }
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

        // refill download permission
        let visibility = formData["batch_submission[media][visibility]"];
        $('[value="' + visibility + '"]').prop('checked', true);
        set_visibility(visibility);  

        let projects_to_add = formData["projects"];
        $.each(projects_to_add, function( id, proj ) {
          $('#batch_submission_media_member_of_collection_ids').val(proj.id).trigger('change'); 
          $('[data-id="' + proj.id + '"]').text(proj.name);
        })

        let reviewerSelect = $('#media_download_reviewer');
        let reviewers_to_add = formData['reviewers'];
        if (reviewers_to_add.length > 0) {
          let reviewers_array = []
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
        window.scrollTo(0,0);
      };
    }

    class OrganizationView extends BatchSubmissionView {
      constructor(form) {
        super(form);
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

            batchSubmissionForm.view.setSubmitStatus();
        });

        let setOrgData = function() {
          let selectedOrganizationID = $('input.organization_id').val();
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
            if (batchSubmissionForm.previousSubmissionData == null || self.form.orgChanged) {
              // new submission, or user has previously changed the org selection
              self.form.setDefaultMediaPermissionFields();
            } else {
              if (data.organizationId != batchSubmissionForm.restoredFormData['organization_id']) {
                // user selects a different org on a restored form
                self.form.setDefaultMediaPermissionFields();
                self.form.orgChanged = true;
              } else {
                // set org when loading a restored form
                self.form.setPreviousOrgAgreement();
              }
            }
          }
          batchSubmissionForm.view.setSubmitStatus();
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
        super(form);
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

            let devices = $.map(nullOrg.devices, function( val, i ) {
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
          batchSubmissionForm.view.setSubmitStatus();
        });

        $('#submission_device_select_display_container').on(
          'click', '#device-select-close', function(event){
            $("#batch_submission_device_id").select2('val', null);
            $('select#batch_submission_modality').val('').change();
            $('#submission_select_device_section').addClass('show').removeClass('hide');
            $('#submission_create_device_button_section').addClass('show').removeClass('hide');
            $('#submission_device_select_display').addClass('hide').removeClass('show');
            batchSubmissionForm.view.setSubmitStatus();
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
    
    prevBsData = {};
    showAlert = false;
    selectedDeviceModality = "";

    if (typeof depositor !== 'undefined') {
      var data = new SubmissionData(depositor);
    } else {
      var data = new SubmissionData();
    }
    batchSubmissionForm = new RestoreableSubmissionForm(data);
  
    batchSubmissionForm.views = [
      new OrganizationView(batchSubmissionForm),
      new DeviceView(batchSubmissionForm),
    ];
    batchSubmissionForm.initializeForm();
    
    // Proxy user select
    $("select[name='batch_submission[on_behalf_of]']").change(function() {
      batchSubmissionForm.data.onBehalfOf = $(this).val();
      // set the reviewer
      var reviewer = {
        "id": $(this).val(),
        "user_key": $(this).val(),
        "text": $("select[name='batch_submission[on_behalf_of]'] option:selected").text()
      }
      $('#media_download_reviewer').userSearchMultiple(reviewer);
      // Unset org transfer settings and reset (in case on behalf of is chosen after org)
      batchSubmissionForm.setDefaultMediaPermissionFields();
    });

    $(window).bind('beforeunload',function(){
      // clear previous submitted data when reloading the form
      localStorage.removeItem("batchSubmissinFormData");
    });

  } // check if the page is batch submission form
});
