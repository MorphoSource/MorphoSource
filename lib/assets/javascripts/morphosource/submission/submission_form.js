class SubmissionForm {
  constructor(submissionData) {
    this.data = submissionData;
    this.organizationDefaultMediaFields = {};
    this.canAlertDownloadReviewer = false;

    this.views = null;
    this.viewSidebarClass = null;
    this.viewSectionIds = null;

    this.customFormName = "batch_submission[media]";
    this.orgData = null;
    this.orgChanged = false;

    // All below is deprecated, but good example for these properties

    // this.views = [
    //   new RawOrDerivedView(this),
    //   new ParentMediaView(this),
    //   new PhysicalObjectSearchCreateView(this),
    //   new OrganizationView(this),
    //   new TaxonomyView(this),
    //   new PhysicalObjectDetailsView(this),
    //   new DeviceView(this),
    //   new ImagingEventView(this),
    //   new ProcessingEventView(this),
    //   new MediaView(this)
    // ];

    // this.viewSidebarClass = {
    //   1: '.sidebar_raw_derived',
    //   2: '.sidebar_parent_media',
    //   3: '.sidebar_search_or_create',
    //   4: '.sidebar_organization',
    //   5: '.sidebar_taxonomy',
    //   6: '.sidebar_details',
    //   7: '.sidebar_device',
    //   8: '.sidebar_capture',
    //   9: '.sidebar_processing',
    //   10: '.sidebar_upload_details'
    // };

    // this.viewSectionIds = {
    //   1: '#submission_choose_raw_or_derived_media',
    //   2: '#submission_parents_in_ms',
    //   3: '#submission_physical_object',
    //   4: '#submission_organization',
    //   5: '#submission_taxonomy',
    //   6: '#submission_physical_object_details',
    //   7: '#submission_device',
    //   8: '#submission_image_capture',
    //   9: '#submission_processing_event',
    //   10: '#submission_media'
    // };

    // this.initializeForm();

  }

  initializeForm() {
    $('.required').addClass('required-flag');
    $('.submission_flow input:not(#media_submit)').removeAttr('data-disable-with');
    this.setMediaPermissionFieldEvent();
    if (this.viewSidebarClass && this.viewSectionIds) {
      this.sidebarEventFuncs();
    }

    // Comment out for debug ability to access any step any time
    this.setSidebarViewFade([2, 3, 4, 5, 6, 7, 8, 9, 10]);
  }

  setMediaPermissionFieldEvent() {
    $('form.new_media div,form.new_media a').click(function(event) {
      if ($(this).hasClass('permissions-field')) {
        $.alert($('#organization-alert-message').text());
        $(this).off(event); // Only fire once
      }
    });
  }

  setDefaultMediaPermissionFields() {
    let self = this;

    // Remove previous settings from organization, if present
    self.resetFormFromOrg(self.organizationDefaultMediaFields);
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
      self.orgData = getData;
      if (getData.default_fields) {
        self.organizationDefaultMediaFields = getData.default_fields;
        // Add loading to media page
        $('form.new_media div#submission-media-ownership').addClass('ui-loading-whole-page');

        // Prepare for new organization permission fields, empty fields vals from user for current org fields
        self.emptyMediaFields(getData.default_fields);

        // Set up organization recommended/required field values
        if (Object.keys(getData.default_fields).length) {
          // Set up text
          $('#organization-alert-message').text(getData.organization_alert_message);
          $('.organization-name').text(getData.organization_title);
          var mandateValues = getData.organization_permissions_mode == 'Require';
          if (mandateValues) {
            $('#permissions-action').text('mandated');
            $('#permissions-text-follow-up').text('Values can not be modified. Download permission settings may be limited as well.');
          } else {
            $('#permissions-action').text('recommended');
            $('#permissions-text-follow-up').text("If you have agreed to abide by this organization's preferences for media ownership, take caution before changing these settings.");
          }
          $('#ownership-section-header-text').addClass('show').removeClass('hide');

          // Add new settings
          self.fillMediaFields(getData.default_fields, mandateValues);

          // Organization agreement attachment
          if ( getData.organization_id && ( getData.default_fields.attachment_url || getData.default_fields.agreement_uri ) ) {
            self.setOrganizationAgreement(getData.default_fields, getData.organization_id);
          } else {
            self.setNoOrganizationAgreement();
          }
        }

        // Set up organization media transfer settings and warnings
        if (getData.organization_data_manager) {
          if ( ( self.data.onBehalfOf || self.data.depositor ) == getData.organization_data_manager ) {
            // Special case, media deposited by or on behalf of org data manager, special case
            self.addMediaToOrgTeam(getData.organization_title, getData.organization_team_id);
            $('.organization-name').text(getData.organization_title);
            $('.organization-url').attr('href', '/concern/organizations/' + getData.organization_id);
            $('#organizationDataManagerModal').modal({ backdrop: 'static', keyboard: false });
          } else {
            // Usual case, set up org media transfer
            self.enableOrgMediaTransferSettings();
            $('.organization-name').text(getData.organization_title);
            $('.organization-data-manager').text(getData.organization_data_manager_name);
            $('.organization-data-manager').attr('href', '/users/' + getData.organization_data_manager);
            $('#organizationTransferModal').modal({ backdrop: 'static', keyboard: false });
          }
        }

        // Remove loading
        $('form.new_media div#submission-media-ownership').removeClass('ui-loading-whole-page');
      }
     });
  }

  resetFormFromOrg(defaultFields) {
    this.resetPermissionFormElements();
    this.emptyMediaFields(defaultFields);
  }

  resetPermissionFormElements() {
    $('#ownership-section-header-text').addClass('hide').removeClass('show');
    $('form.new_media div#submission-media-ownership div').removeClass('permissions-field');
    $('form.new_media div#submission-media-ownership div#media-ownership-fields div.permissions-label').remove();
    $('form.new_media div#submission-media-ownership div#media-ownership-fields button.btn.btn-link').removeClass('hide');
    $('form.new_media div#submission-media-ownership div#media-ownership-fields li.input-group').removeClass('required-input-group');
    $('form.new_media div#submission-media-ownership div#media-ownership-fields input,select,textarea').prop('disabled', false); 
    this.resetOrgMediaTransferSettings();
  }

  emptyMediaFields(defaultFields) {
    for (const f in defaultFields) {
        this.emptyMediaField(f);
    }
  }

  emptyMediaField(field) {
    let multiSelector =
      "form.new_media select[name$='[" + field + "][]'], " +
      "form.new_media input[name$='[" + field + "][]']";
    let selector =
      "form.new_media select[name$='[" + field + "]'], " +
      "form.new_media input[name$='[" + field + "]'], " +
      "form.new_media textarea[name$='[" + field + "]']";

    switch(field) {
      case 'download_permission':
        $('form.new_media input[id$="visibility_open"]').trigger('click');
        break;
      case 'download_reviewer':
        $(multiSelector).select2('destroy').empty().userSearchMultiple($(multiSelector).data('reviewers'));
        this.canAlertDownloadReviewer = false;
        break;
      case 'rights_holder':
        $(multiSelector).first().val('');
        $(multiSelector).slice(1).parent().remove();
        break;
      default: // single-value fields
        if ( $(selector).is('select') )  {
          $(selector).prop('selectedIndex',0);
        } else {
          $(selector).val('');
        } 
    }
  }

  fillMediaFields(defaultFields, mandateValues) {
    for (const f in defaultFields) {
      this.fillMediaField(f, defaultFields[f], mandateValues);
    }
  }

  fillMediaField(field, val, mandateValues) {
    let multiSelector =
      "form.new_media select[name$='[" + field + "][]'], " +
      "form.new_media input[name$='[" + field + "][]']";
    let selector =
      "form.new_media select[name$='[" + field + "]'], " +
      "form.new_media input[name$='[" + field + "]'], " +
      "form.new_media textarea[name$='[" + field + "]']";

    switch(field) {
      case 'download_permission':
        if (Array.isArray(val)) {
          val = val[0];
        }
        if (val == 'preview_only') {
          val = 'preview';
        }
        $('form.new_media input[id$="visibility_' + val.toLowerCase() + '"]').trigger('click');
        this.recommendOrRequirePermissions(
          $('form.new_media div.media_download_permission'),
          val.toLowerCase(), 
          mandateValues
        );
        break;
      case 'download_reviewer':
        $(multiSelector).select2('destroy').empty().userSearchMultiple(val);
        this.recommendOrRequirePermissions(
          $('form.new_media div.media_download_reviewer'), 
          null, 
          mandateValues
        );
        break; 
      case 'rights_holder': // multi-value field
        if (Array.isArray(val) && val.length > 1) {
          var self = this;
          $.each(val, function(i, v) {
            if (v) {
              $(multiSelector).eq(i).val(v);
              if (i < (val.length - 1) && val[i+1]) {
                $(multiSelector).eq(i).parent().find('button.add').trigger('click');
              } else {
                self.recommendOrRequirePermissions(
                  $(multiSelector).parents('div [class*="media_' + field + '"]'), 
                  null, 
                  mandateValues
                );
              }

            }
          });
        } else {
          $(multiSelector).val(val);
          this.recommendOrRequirePermissions(
            $(multiSelector).parents('div [class*="media_' + field + '"]'), 
            null, 
            mandateValues
          );
        }
        break;
      case 'attachment_url':
        this.recommendOrRequirePermissions(
          $('div.media_agreement_uri'), 
          null, 
          mandateValues
        );
        break;
      default: // single-value fields
        $(selector).val(val);
        this.recommendOrRequirePermissions(
          $(selector).parents('div [class*="media_' + field + '"]'), 
          null, 
          mandateValues
        );
    }
  }

  recommendOrRequirePermissions(element, val, mandateValues) {
    if (mandateValues) { // required
      if (element.hasClass('media_download_permission')) {
        if (val == 'open') {
          $('form.new_media input[id$="visibility_restricted_download"]').prop('disabled', 'disabled');
          element.find('div.showcase-value ul#publication-options').before(
            "<div class='permissions-label' style='padding-left: 8px;'><span class='label label-default'><i class='fas fa-exclamation-circle fa-lg'></i> Limited to Open or Private</span></div>"
          );
        } else if (val == 'restricted_download') {
          $('form.new_media input[id$="visibility_open"]').prop('disabled', 'disabled');
          element.find('div.showcase-value ul#publication-options').before(
            "<div class='permissions-label' style='padding-left: 8px;'><span class='label label-default'><i class='fas fa-exclamation-circle fa-lg'></i> Limited to Restricted or Private</span></div>"
          );
        } else {
          element.find('input, select, textarea').prop('disabled', 'disabled');
        }
      } else {
        element.find('input, select, textarea').prop('disabled', 'disabled');
        element.find('div.showcase-value').append(
          "<div class='permissions-label'><span class='label label-default'><i class='fas fa-exclamation-circle fa-lg'></i> Mandated by Organization</span></div>"
        );
      }

      element.find('button.btn.btn-link').addClass('hide');
      element.find('li.input-group').addClass('required-input-group');
    } else { // recommended
      if (element.hasClass('media_download_reviewer')) {
        this.canAlertDownloadReviewer = true;
        var self = this;
        $('#media_download_reviewer').one("select2-opening", function() {
          if (self.canAlertDownloadReviewer) {
            $.alert($('#organization-alert-message').text());
          }
        });
      }

      element.addClass('permissions-field');
      element.find('div.showcase-value').append(
        "<div class='permissions-label'><span class='label label-default'><i class='fas fa-exclamation-circle fa-lg'></i> Recommended by Organization</span></div>"
      );
    }
  }

  setOrganizationAgreement(defaultFields, organizationID) {
    if (defaultFields.attachment_url) {
      this.data.organizationForAttachment = organizationID;

      $('#organization-attachment-url').attr('href', defaultFields.attachment_url);
      $('#organization-attachment-url').addClass('show').removeClass('hide');

      $('#no-attachment').addClass('hide').removeClass('show');

      $('#organization-agreement-uri').text('');
      $('#organization-agreement-uri').addClass('hide').removeClass('show');

      $('#organization-agreement-help').addClass('show').removeClass('hide');
      $('#no-agreement-help').addClass('hide').removeClass('show');
    } else if (defaultFields.agreement_uri) {
      this.data.organizationForAttachment = null;

      $('#organization-agreement-uri').text(defaultFields.agreement_uri);
      $('#organization-agreement-uri').addClass('show').removeClass('hide');

      $('#no-attachment').addClass('hide').removeClass('show');

      $('#organization-attachment-url').attr('href', '#');
      $('#organization-attachment-url').addClass('hide').removeClass('show');

      $('#organization-agreement-help').addClass('show').removeClass('hide');
      $('#no-agreement-help').addClass('hide').removeClass('show');
    }
  }

  setNoOrganizationAgreement() {
    this.data.organizationForAttachment = null;
    $('#no-attachment').addClass('show').removeClass('hide');

    $('#organization-agreement-uri').text('');
    $('#organization-agreement-uri').addClass('hide').removeClass('show');

    $('#organization-attachment-url').attr('href', '#');
    $('#organization-attachment-url').addClass('hide').removeClass('show');

    $('#no-agreement-help').addClass('show').removeClass('hide');
    $('#organization-agreement-help').addClass('hide').removeClass('show');
  }

  // Methods for controlling transfer of media to organization with specified data manager
  addMediaToOrgTeam(organization_title, organization_team_id) {
    if (organization_title && organization_team_id) {
      let RelationshipsControl = require('morphosource/ms_control');
      let Resource = require('hyrax/relationships/resource');
      let collection_form_group = $('[data-behavior="collection-relationships"]').first();
      
      let control = new RelationshipsControl(collection_form_group,
        collection_form_group.data('members'),
        collection_form_group.data('paramKey'),
        'member_of_collections_attributes',
        'tmpl-collection'
      );
      control.registry.addResource(
        new Resource(organization_team_id, organization_title)
      );
      control.registry.serializeToForm();
    }
  }


  enableOrgMediaTransferSettings() {
    $('#ownership-section-header-text2').addClass('show').removeClass('hide');
    $('div#media_transfer_management').addClass('show').removeClass('hide');
    $('select#media_transfer_management').removeAttr('disabled');

    this.updateOrganizationDataManagementInfo();
  }

  resetOrgMediaTransferSettings() {
    $('#ownership-section-header-text2').addClass('hide').removeClass('show');
    $('div#media_transfer_management').addClass('hide').removeClass('show');
    $('select#media_transfer_management').attr('disabled', 'disabled');
  };

  updateOrganizationDataManagementInfo() {
    if (
      $('select#media_transfer_management').val() == 'immediate' || 
      ( $('select#media_transfer_management').val() == 'publication' && 
        ( $('input#media_visibility_open, input#batch_submission_media_visibility_open').prop('checked') || 
          $('input#media_visibility_restricted_download, input#batch_submission_media_visibility_restricted_download').prop('checked') 
        ) 
      ) 
    ) {
      $('span#permissions-org-management-status').text('immediately when this media is submitted');
    } else {
      $('span#permissions-org-management-status').text('when this media is published in the future after submission');
    }
  }

  // TODO: Implement submission data checking? Probably best done at the end

  sidebarEventFuncs() {
    let self = this;

    $('.sidebar a.sidebar-clickable').click(function(){
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
    // temporarily skip this for batch submission form
    if ($('[class*="batch-submission-form"]').length == 0) {
      var sidebarViewFade = Array.isArray(sidebarViewFade) ? sidebarViewFade : [sidebarViewFade];

      for (const s of sidebarViewFade) {
        $(this.viewSidebarClass[s]).addClass('inactive');
      }    
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