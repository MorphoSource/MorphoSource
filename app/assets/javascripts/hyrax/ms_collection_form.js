function afterLogoUpload() {
  disableUpload('fileuploadlogo');
}  

function afterBannerUpload() {
  disableUpload('fileuploadbanner');
}  

function enableUpload(className) {
  $('.' + className + ' input[type="file"]').prop("disabled", false);
  $('.' + className + ' .fileinput-button').removeClass('disabled');
}

function disableUpload(className) {
  $('.' + className + ' input[type="file"]').prop("disabled", true);
  $('.' + className + ' .fileinput-button').addClass('disabled');
}

$(document).ready(function() {

  if ($('body').hasClass('ms-collection') && !$('body').hasClass('organization_collections')) {
    var collectionId = $('#collection-id').text();
    $('#remove-selected-from-collection').on('click', function (e) {
      selectedMediaIDs = [];
      $('input[name="batch_work_ids[]"]').each(function() {
        if ($(this).is(':checked')) {
          selectedMediaIDs.push($(this).val());
        }
      });
      if (confirm(`Removing selected media will not remove them from MorphoSource, only from this collection. Are you sure you want to remove selected media from the collection?`) == false) {
        e.preventDefault();
        return false;
      } else {
        disablePage();
        $.ajax({
          type: "POST",
          url: '/dashboard/collections/' + collectionId + '/batch_remove',
          dataType: 'json',
          data: { remove_ids: selectedMediaIDs },
          success: function(response) {
            if (response.status === 'success') {
              flashNotice('alert-success', 'Media are being removed in the background. You can refresh the page later to see the changes.');
            } else {
              flashNotice('alert-warning', 'There is a problem removing selected media. Please try again.');
            }
          },
          error: function(xhr, status, error) {
            flashNotice('alert-warning', 'There is a problem removing selected media. Error: ' + error);
          }
        }).always(function() {
          $('.batch_add_selector, #select-all-for-download').prop('checked', false);
          enablePage();
          $('html, body').animate({ scrollTop: 0 }, 'fast');
        });
        return false;
      }
    });

    function flashNotice(alertClass, message) {
      var notice = `
        <div class="alert ${alertClass} alert-dismissable" role="alert">
          <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
          ${message}
        </div>
      `;
      $('#collection-id').after(notice);
    }
  } // end if (!$('body').hasClass('organization_collections'

  if ( $('form[id*="edit_collection"]').length ||
       $('form[id*="edit_media_list"]').length ||
       $('form[id*="edit_sequential_section_list"]').length ||
       $('form[id*="edit_organization_collection"]').length) { // if collection form page (edit)

    if ($('.branding-logo-remove').length) {
      disableUpload('fileuploadlogo');
    }

    if ($('.branding-banner-remove').length) {
      disableUpload('fileuploadbanner');
    }

    setupTooltip();
    removeLastRepeatable();

    // Handling Actions dropdown menu clicks
    $('.actions-add-subcollection').on('click', function (e) {
      $('.sub-collections-wrapper button.add-subcollection').trigger('click');
    });

    $('.btn-remove-media').on('click', function (e) {

      if ($('.team-remove-media').length) {
        var collectionType = 'team'
      } else {
        var collectionType = 'project'
      }

      if (confirm(`Removing this work will not remove it from MorphoSource, only from this ${collectionType}. Are you sure you want to remove this work from the ${collectionType}?`) == false) {
        e.preventDefault();
        return false;
      } else {
        disablePageAndSave(".dropdown-toggle");
        return true;
      }
    });

    form = $('form[id*="edit_"]')[0]

    form.addEventListener("submit", function(submitEvent) {
      //submitEvent.preventDefault();
      disablePageAndSave(".dropdown-toggle");
    })

    $('.btn-delete-collection').click(function() {
      disablePageAndSave(".dropdown-toggle");
    });

    // Temporary access link UI

    $('input#collection_temporary_link_expires_at').change(function() {
      let a = $('a#generate-temporary-collection-access-link').first();
      let url = new URL(a.attr('href'));
      url.searchParams.set("expires_at", $(this).val());
      a.attr('href', url);
    });

    var clipboard = new Clipboard('.copy-temporary-collection-link');
    clipboard.on('success', function(e) {
      $(e.trigger).tooltip('show');
      e.clearSelection();
    });

  } // end if collection form page


  // the following are taken from and overridden for teams and projects
  // https://raw.githubusercontent.com/samvera/hyrax/v2.7.0/app/assets/javascripts/hyrax/collections.js
  // note that there is a similar method handleDeleteCollection in https://github.com/MorphoSource/MorphoSource/blob/main/app/assets/javascripts/morphosource/my/collections.js
  $('.delete-team-or-project-button').on('click', handleDeleteTeamOrProject);

  function handleDeleteTeamOrProject(e) {
    e.preventDefault();
    var $self = $(this),
      $tr = $self.parents('tr'),
      totalitems = $self.data('totalitems'),
      // membership set to true indicates admin_set
      membership = $self.data('membership') === true,
      collectionId = $tr.data('id'),
      modalId = '';

    // Permissions denial
    if ($(this).data('hasaccess') !== true) {
      $('#collection-to-delete-deny-modal').modal('show');
      return;
    }
    // Admin set with child items
    if (totalitems > 0 && membership) {
      $('#collection-admin-set-delete-deny-modal').modal('show');
      return;
    }
    modalId = (totalitems > 0 ?
      '#collection-to-delete-modal' :
      '#collection-empty-to-delete-modal'
    );
    addDataAttributesToModal(modalId, ['id', 'post-delete-url'], $tr);
    $(modalId).modal('show');
  }

  function addDataAttributesToModal(modalId, dataAttributes, $dataEl) {
    console.log(dataAttributes);
    console.log($dataEl);
    // Remove and add new data attributes
    dataAttributes.forEach(function(attribute) {
      $(modalId).removeAttr('data-' + attribute).attr('data-' + attribute, $dataEl.data(attribute));
    });
  }

})
