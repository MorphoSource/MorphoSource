/*
    TODO: Including this in a file like this may not be the best way to handle this.
    This javascript is needed for using Select2 to provide search functionality in the respective selection widgets.
*/
$(document).ready(function () {
    $("#submission_institution_id").select2();
    $("#submission_object_id").select2();
    $("#submission_imaging_event_id").select2();
});
