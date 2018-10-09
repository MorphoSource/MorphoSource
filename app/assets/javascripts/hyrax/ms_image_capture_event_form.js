// Javascript code for the Image Capture Event add/edit form

$(document).on('turbolinks:load', function() {
    //console.log('ready... length='+ $('form[id*="image_capture_event"]').length) ;
    if ($('form[id*="image_capture_event"]').length) { // in ICE add/edit form page
        showFieldsByModality();
    }
});

var showFieldsByModality = function() {
    // hide modality specific fields, then show only specific fields based on the modality
    $('.ice_xray_ct, .ice_photogrammetry, .ice_photography').addClass('hide').removeClass('show');
    var selectedModality = $('select[name="image_capture_event[ice_modality]"]').val();
    //console.log('ICE: ' + selectedModality);
    switch(selectedModality) {
        case 'MicroNanoXRayComputedTomography':
            $('.ice_xray_ct').addClass('show').removeClass('hide');
            break;
        case 'MedicalXRayComputedTomography':
            $('.ice_xray_ct').addClass('show').removeClass('hide');
            break;
        case 'Photogrammetry':
            $('.ice_photogrammetry').addClass('show').removeClass('hide');
            break;
        case 'Photography':
            $('.ice_photography').addClass('show').removeClass('hide');
            break;
        //default:
    }
}

