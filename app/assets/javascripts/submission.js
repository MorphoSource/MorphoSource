$(document).ready(function () {

    $("#submission_device_id").select2();
    $("#submission_institution_id").select2();

    $('div#submission_new div#submission_choose_biospec_or_cho').addClass('hidden');
    $('div#submission_new div#submission_biospec').addClass('hidden')

    $('input#submission_raw_or_derived_media_raw').click(function(event){
        $('div#submission_choose_biospec_or_cho').removeClass('hidden')
        }
    );

    $('input#submission_raw_or_derived_media_derived').click(function(event){
        event.preventDefault();
        alert('Not yet implemented');
        }
    );

    $('input#submission_biospec_or_cho_biospec').click(function(event){
        $('div#submission_biospec').removeClass('hidden')
        }
    );

    $('input#submission_biospec_or_cho_cho').click(function(event){
        event.preventDefault();
        alert('Not yet implemented');
        }
    );

    $('a#submission_show_create_biospec').click(function(event){
        event.preventDefault();
        $('div#submission_biospec_search').addClass('hidden')
        $('div#submission_choose_create_biospec').addClass('hidden');
        $('div#submission_create_biospec').removeClass('hidden');
        }
    );

    $('a#submission_show_create_institution').click(function(event){
            event.preventDefault();
            $('div#submission_institution_select').addClass('hidden')
            $('div#submission_choose_create_institution').addClass('hidden');
            $('div#submission_create_institution').removeClass('hidden');
        }
    );

    $('a#submission_show_create_device').click(function(event){
            event.preventDefault();
            $('div#submission_device_select').addClass('hidden')
            $('div#submission_choose_create_institution').addClass('hidden');
            $('div#submission_create_institution').removeClass('hidden');
        }
    );

});
