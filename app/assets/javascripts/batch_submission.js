$( document ).ready(function() {

  if ($('[class*="batch-submission-form"]').length) { // check if the page is submission form


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


    class BatchSubmissionForm {
      constructor(submissionData) {
        this.data = submissionData;
        this.views = [
          new OrganizationView(this),
          new DeviceView(this),
        ];
      }


      setDefaultMediaPermissionFields() {
        let self = this;

        $.get('/submissions/organization_default_media_fields',
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
          case 'download_reviewer':
            $(selector).val('').trigger('change');
            // $('form#new_media div.media_download_reviewer span.select2-chosen').text('');
            break;
          case 'license': // multi-value fields
          case 'rights_holder':
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
          case 'rights_holder':
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

        //$('#submission_select_organization').click(function(event){
        var setOrgData = function() {
          //event.preventDefault();
          console.log('set organization data');
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
            self.form.setDefaultMediaPermissionFields();
          }
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

          var deviceObj = deviceData[e.choice.id]
          self.toggleSelectDeviceVisibility(deviceObj);
          $('#submission_select_device_continue').removeAttr('disabled');

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
      }
    }

    var data = new BatchSubmissionData();
    var batchSubmissionForm = new BatchSubmissionForm(data);

  } // end if the page is submission flow page
});
