document.addEventListener("DOMContentLoaded", function() {
  const mediaEditForm = document.querySelector('form[id*="edit_media"]');
  const alephSceneInput = document.getElementById('media_aleph_scene');

  if (mediaEditForm && alephSceneInput) {
    parsePreviewSettings(alephSceneInput);

    // JSON validation for aleph scene input
    alephSceneInput.addEventListener('input', function() {
      parsePreviewSettings(this);
    });

    function parsePreviewSettings(element) {
      const jsonValid = validateJson(element);
      if (jsonValid && element.value) {
        parseRotation(element.value);
        parseAnnotations(element.value);
      };
    }

    function validateJson(element) {
      if (element.value) {
        try {
          JSON.parse(element.value);
          element.setCustomValidity('');
          return true;
        } catch (e) {
          element.setCustomValidity('This does not seem to be valid JSON');
          element.reportValidity();
          return false;
        }
      } else {
        element.setCustomValidity('');
        return true; 
      }
    }

    function parseRotation(jsonString) { 
      const json = JSON.parse(jsonString);
      const rotationElem = document.querySelector('div#media_preview_rotation');
      if (
        json &&
        json?.scene?.rotation &&
        Array.isArray(json.scene.rotation) &&
        json.scene.rotation.length === 3 &&
        json.scene.rotation.every((element) => typeof element === 'number') && 
        json.scene.rotation.some((element) => element !== 0) && 
        rotationElem
      ) {
        // convert rotation[0] from radians to degrees
        const rotationX = json.scene.rotation[0] * (180 / Math.PI);
        const rotationY = json.scene.rotation[1] * (180 / Math.PI);
        const rotationZ = json.scene.rotation[2] * (180 / Math.PI);

        rotationElem.textContent = `X: ${rotationX.toFixed(2)}°, Y: ${rotationY.toFixed(2)}°, Z: ${rotationZ.toFixed(2)}°`;
      } else {
        rotationElem.textContent = '--';
      }
    }

    function parseAnnotations(jsonString) {
      const json = JSON.parse(jsonString);
      const annotationsElem = document.querySelector('div#media_preview_annotations');
      if (
        json &&
        json?.annotations &&
        Array.isArray(json.annotations) &&
        json.annotations.length > 0 &&
        annotationsElem
      ) {
        annotationsElem.textContent = `${json.annotations.length}`;
      } else {
        annotationsElem.textContent = '--';
      }
    }

    // Communicate with viewer iframe to import scene configuration

    // Request viewer iframe to emit scene configuration JSON via postMessage API
    document.querySelector('a#request-iframe-json-emit').addEventListener("click", function(event) {
      event.preventDefault();
      const viewerIframe = document.querySelector('iframe#uv-iframe');
      if (viewerIframe) {
        viewerIframe.contentWindow.postMessage({
          type: 'aljsonemitrequest',
        }, window.location.origin
        );
      }
    });

    // Listen for response from viewer iframe via postMessage API
    window.addEventListener("message", function(event) {
      if (event.origin === window.location.origin) {
        if (event.data.type === "aljsonemit") {
          const alephScene = event.data.data;
          if (alephScene && alephSceneInput) {
            alephSceneInput.value = JSON.stringify(alephScene, null, 2);
            alephSceneInput.dispatchEvent(new Event('input', { bubbles: true })); // Trigger input event to notify any listeners
          }
        }
      }
    });
  }
});