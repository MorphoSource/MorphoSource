$(document).ready(function(){

  if ($('div[class="submission_flow"]').length) { // check if the page is submission new page

    // possibly not needed. remove later
    //$("#submission_device_id").select2();
    //$("#submission_institution_id").select2();
    //$('div#submission_new div#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');;
    //$('div#submission_new div#submission_biospec').addClass('hide').removeClass('show');

    //$('.new_media, .derived_media').addClass('hide').removeClass('show');

    // Begin Raw media flow
    $('input#submission_raw_or_derived_media_raw').click(function(event){
      $('div#submission_choose_raw_or_derived_media').addClass('hide').removeClass('show');
      $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
    });

    $('input#submission_biospec_or_cho_biospec').click(function(event){
      $('#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');
      $('div#submission_biospec').addClass('show').removeClass('hide');
    });

    $('a#submission_show_create_biospec').click(function(event){
      event.preventDefault();
      $('div#submission_biospec_search').addClass('hide').removeClass('show');
      $('div#submission_choose_create_biospec').addClass('hide').removeClass('show');;
      $('div#submission_create_biospec').addClass('show').removeClass('hide');
    });

    $('a#submission_show_create_institution').click(function(event){
      event.preventDefault();
      $('div#submission_institution_select').addClass('hide').removeClass('show');
      $('div#submission_choose_create_institution').addClass('hide').removeClass('show');;
      $('div#submission_create_institution').addClass('show').removeClass('hide');
    });

    $('a#submission_show_create_device').click(function(event){
      event.preventDefault();
      $('div#submission_device_select').addClass('hide').removeClass('show');
      // the following line might not be needed.  remove it later
      //$('div#submission_choose_create_institution').addClass('hide').removeClass('show');;
      $('div#submission_create_device').addClass('show').removeClass('hide');
    });

    $('input#submission_biospec_or_cho_cho').click(function(event){
      //$('#submission_choose_biospec_or_cho').addClass('hide').removeClass('show');
      alert('Not yet implemented');
    });

    // End Raw media flow

    // Begin Derived media flow
    $('input#submission_raw_or_derived_media_derived').click(function(event){
      $('div#submission_choose_raw_or_derived_media').addClass('hide').removeClass('show');
      $('div#submission_parents_in_ms').addClass('show').removeClass('hide');
    });

    $('#btn_parents_not_in_morphosource').click(function(event){
      event.preventDefault();
      $('div#submission_parents_in_ms').addClass('hide').removeClass('show');
      $('div#submission_parents_not_in_ms').addClass('show').removeClass('hide');
    });

    $('#btn_parent_media_how_to_proceed_continue').click(function(event){
      event.preventDefault();
      $('div#submission_parents_not_in_ms').addClass('hide').removeClass('show');
      if ( $('input[name="submission[parent_media_how_to_proceed]"]:checked').val() == 'now' ) {
        // start over
        $('div#submission_choose_raw_or_derived_media').addClass('show').removeClass('hide');
      } else {
        // go to phsyical object
        $('#submission_choose_biospec_or_cho').addClass('show').removeClass('hide');
      }
      clearForms();
    });
    // End Derived media flow

    var clearForms = function() {
      // if there are other forms (or radios) on the page that should not be cleared. Add condition here.
      $('form').each(function() {
        this.reset();
      });
      $('.radio_buttons').prop('checked', false);
    }

    $('#btn_add_parent').click(function(event){
      event.preventDefault();
      var currentParentList = $('input[id="submission_parent_media_list"]').val();
      var selectedId = $("input.parent_id").val();
      if (currentParentList.indexOf(selectedId) != -1) {
        // parent has already been added
        // todo: see if it is possible to exclude the already-added parents from the autocomplete dropdown
        alert('already added');
      } else {
        if (currentParentList != '')
          currentParentList += ',';
        currentParentList += selectedId;
        $('input[id="submission_parent_media_list"]').val(currentParentList);
        // display a new parent media row
        $('.parent_row:last-child').after(newParentRow(selectedId));
      }
      $('input[id="submission_parent_media_search"]').val('');
      $("input.parent_id").val('');
      $("input.parent_title").val('');
    });

    var newParentRow = function(id){
      var row = '<div class="parent_row ' + id + '">'
        + '<div class="col-sm-4"><div class="parent_title">'
        + $("input.parent_title").val() + '</div></div>'
        + '<div class="col-sm-2"><a class="btn_remove_parent btn btn-primary" onClick="removeParent(\'' + id + '\')">Remove</a> <!--' + id + '--></div>'
        + '</div>';
      return row;
    }
    removeParent = function(id){
      event.preventDefault();
      $('div.' + id).remove();
      var currentParentList = $('input[id="submission_parent_media_list"]').val();
      var newParentList = removeValue(currentParentList, id);
      $('input[id="submission_parent_media_list"]').val(newParentList);
    }

    function removeValue(list, value) {
      list = list.split(',');
      list.splice(list.indexOf(value), 1);
      return list.join(',');
    }

    /*
    $('.btn_remove_parent').click(function(event){
      event.preventDefault();
      var removeId = $(this).attr('data-remove-id').val();
      alert('removing ' + removeId);

    });
    */
  }
});
