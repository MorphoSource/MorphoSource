/*
    TODO: Including this in a file like this may not be the best way to handle this.
    This javascript is needed for using Select2 to provide search functionality in the respective selection widgets.
*/
$(document).ready(function () {
    $("#submission_institution_id").select2();
    $("#submission_object_id").select2();
    $("#submission_imaging_event_id").select2();
});

$(document).ready(function() {
    $('a#show_create_institution').click(function(event){
        event.preventDefault();
        $('div#select_institution').addClass('hidden');
        $('div#create_institution').removeClass('hidden');
    });
});

$(document).ready(function() {
    $('a#show_select_institution').click(function(event){
        event.preventDefault();
        $('div#create_institution').addClass('hidden');
        $('div#select_institution').removeClass('hidden');
    });
});

$(document).ready(function() {
    $('a#show_create_biological_specimen').click(function(event){
        event.preventDefault();
        $('div#select_physical_object').addClass('hidden');
        $('div#create_biological_specimen').removeClass('hidden');
    });
});

$(document).ready(function() {
    $('a#show_create_cultural_heritage_object').click(function(event){
        event.preventDefault();
        $('div#select_physical_object').addClass('hidden');
        $('div#create_cultural_heritage_object').removeClass('hidden');
    });
});

$(document).ready(function() {
    $('a#show_select_physical_object').click(function(event){
        event.preventDefault();
        $('div#create_biological_specimen').addClass('hidden');
        $('div#create_cultural_heritage_object').addClass('hidden');
        $('div#select_physical_object').removeClass('hidden');
    });
});
