// Javascript view functions for show/edit forms
$(document).ready(function () {
    showFieldsByModality();
});

var showFieldsByModality = function() {

    // hide modality specific fields, then show only specific fields based on the modality
    $('.ice_xray_ct, .ice_photogrammetry, .ice_photography').addClass('hide').removeClass('show');
    var selectedModality = $('select[name="image_capture_event[ice_modality]"]').val();
    //console.log(selectedModality);
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

