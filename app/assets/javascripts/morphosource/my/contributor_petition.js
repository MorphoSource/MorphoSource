$( document ).ready(function() {
  if ( $('form[id="new_contributor_petition"]').length ) { // if contributor application form
    $('form[id="new_contributor_petition"]').submit(function(event) {
      // Check if demographics are filled out, cancel submit if not
      if (
        !$('form[id="new_contributor_petition"] input[name="contributor_petition[user_demographics][]"]').is(':checked') &&
        !$('form[id="new_contributor_petition"] input[name="contributor_petition[user_demographics_other]"]').val()
      ) {
        alert('You must enter user demographic data to submit the contributor application.');
        event.preventDefault();
        return false;
      }
    });
  }
});