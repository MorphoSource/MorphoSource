(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[30],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-fbd2c40b.js":
/*!****************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/index-fbd2c40b.js ***!
  \****************************************************************************/
/*! exports provided: s */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "s", function() { return sanitizeDOMString; });
/**
 * Does a simple sanitization of all elements
 * in an untrusted string
 */
var sanitizeDOMString = function (untrustedString) {
    try {
        if (typeof untrustedString !== 'string' || untrustedString === '') {
            return untrustedString;
        }
        /**
         * Create a document fragment
         * separate from the main DOM,
         * create a div to do our work in
         */
        var documentFragment_1 = document.createDocumentFragment();
        var workingDiv = document.createElement('div');
        documentFragment_1.appendChild(workingDiv);
        workingDiv.innerHTML = untrustedString;
        /**
         * Remove any elements
         * that are blocked
         */
        blockedTags.forEach(function (blockedTag) {
            var getElementsToRemove = documentFragment_1.querySelectorAll(blockedTag);
            for (var elementIndex = getElementsToRemove.length - 1; elementIndex >= 0; elementIndex--) {
                var element = getElementsToRemove[elementIndex];
                if (element.parentNode) {
                    element.parentNode.removeChild(element);
                }
                else {
                    documentFragment_1.removeChild(element);
                }
                /**
                 * We still need to sanitize
                 * the children of this element
                 * as they are left behind
                 */
                var childElements = getElementChildren(element);
                /* tslint:disable-next-line */
                for (var childIndex = 0; childIndex < childElements.length; childIndex++) {
                    sanitizeElement(childElements[childIndex]);
                }
            }
        });
        /**
         * Go through remaining elements and remove
         * non-allowed attribs
         */
        // IE does not support .children on document fragments, only .childNodes
        var dfChildren = getElementChildren(documentFragment_1);
        /* tslint:disable-next-line */
        for (var childIndex = 0; childIndex < dfChildren.length; childIndex++) {
            sanitizeElement(dfChildren[childIndex]);
        }
        // Append document fragment to div
        var fragmentDiv = document.createElement('div');
        fragmentDiv.appendChild(documentFragment_1);
        // First child is always the div we did our work in
        var getInnerDiv = fragmentDiv.querySelector('div');
        return (getInnerDiv !== null) ? getInnerDiv.innerHTML : fragmentDiv.innerHTML;
    }
    catch (err) {
        console.error(err);
        return '';
    }
};
/**
 * Clean up current element based on allowed attributes
 * and then recursively dig down into any child elements to
 * clean those up as well
 */
var sanitizeElement = function (element) {
    // IE uses childNodes, so ignore nodes that are not elements
    if (element.nodeType && element.nodeType !== 1) {
        return;
    }
    for (var i = element.attributes.length - 1; i >= 0; i--) {
        var attribute = element.attributes.item(i);
        var attributeName = attribute.name;
        // remove non-allowed attribs
        if (!allowedAttributes.includes(attributeName.toLowerCase())) {
            element.removeAttribute(attributeName);
            continue;
        }
        // clean up any allowed attribs
        // that attempt to do any JS funny-business
        var attributeValue = attribute.value;
        /* tslint:disable-next-line */
        if (attributeValue != null && attributeValue.toLowerCase().includes('javascript:')) {
            element.removeAttribute(attributeName);
        }
    }
    /**
     * Sanitize any nested children
     */
    var childElements = getElementChildren(element);
    /* tslint:disable-next-line */
    for (var i = 0; i < childElements.length; i++) {
        sanitizeElement(childElements[i]);
    }
};
/**
 * IE doesn't always support .children
 * so we revert to .childNodes instead
 */
var getElementChildren = function (el) {
    return (el.children != null) ? el.children : el.childNodes;
};
var allowedAttributes = ['class', 'id', 'href', 'src', 'name', 'slot'];
var blockedTags = ['script', 'style', 'iframe', 'meta', 'link', 'object', 'embed'];



/***/ }),

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-alert-ios.entry.js":
/*!*********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-alert-ios.entry.js ***!
  \*********************************************************************************/
/*! exports provided: ion_alert */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_alert", function() { return Alert; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./helpers-1644482e.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js");
/* harmony import */ var _theme_955ba954_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./theme-955ba954.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/theme-955ba954.js");
/* harmony import */ var _overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./overlays-84052d05.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/overlays-84052d05.js");
/* harmony import */ var _animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./animation-d551500b.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/animation-d551500b.js");
/* harmony import */ var _index_fbd2c40b_js__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./index-fbd2c40b.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-fbd2c40b.js");






/**
 * iOS Alert Enter Animation
 */
var iosEnterAnimation = function (baseEl) {
    var baseAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    var backdropAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    var wrapperAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    backdropAnimation
        .addElement(baseEl.querySelector('ion-backdrop'))
        .fromTo('opacity', 0.01, 0.3);
    wrapperAnimation
        .addElement(baseEl.querySelector('.alert-wrapper'))
        .keyframes([
        { offset: 0, opacity: '0.01', transform: 'scale(1.1)' },
        { offset: 1, opacity: '1', transform: 'scale(1)' }
    ]);
    return baseAnimation
        .addElement(baseEl)
        .easing('ease-in-out')
        .duration(200)
        .addAnimation([backdropAnimation, wrapperAnimation]);
};
/**
 * iOS Alert Leave Animation
 */
var iosLeaveAnimation = function (baseEl) {
    var baseAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    var backdropAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    var wrapperAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    backdropAnimation
        .addElement(baseEl.querySelector('ion-backdrop'))
        .fromTo('opacity', 0.3, 0);
    wrapperAnimation
        .addElement(baseEl.querySelector('.alert-wrapper'))
        .keyframes([
        { offset: 0, opacity: 0.99, transform: 'scale(1)' },
        { offset: 1, opacity: 0, transform: 'scale(0.9)' }
    ]);
    return baseAnimation
        .addElement(baseEl)
        .easing('ease-in-out')
        .duration(200)
        .addAnimation([backdropAnimation, wrapperAnimation]);
};
/**
 * Md Alert Enter Animation
 */
var mdEnterAnimation = function (baseEl) {
    var baseAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    var backdropAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    var wrapperAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    backdropAnimation
        .addElement(baseEl.querySelector('ion-backdrop'))
        .fromTo('opacity', 0.01, 0.32);
    wrapperAnimation
        .addElement(baseEl.querySelector('.alert-wrapper'))
        .keyframes([
        { offset: 0, opacity: '0.01', transform: 'scale(0.9)' },
        { offset: 1, opacity: '1', transform: 'scale(1)' }
    ]);
    return baseAnimation
        .addElement(baseEl)
        .easing('ease-in-out')
        .duration(150)
        .addAnimation([backdropAnimation, wrapperAnimation]);
};
/**
 * Md Alert Leave Animation
 */
var mdLeaveAnimation = function (baseEl) {
    var baseAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    var backdropAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    var wrapperAnimation = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_4__["c"])();
    backdropAnimation
        .addElement(baseEl.querySelector('ion-backdrop'))
        .fromTo('opacity', 0.32, 0);
    wrapperAnimation
        .addElement(baseEl.querySelector('.alert-wrapper'))
        .fromTo('opacity', 0.99, 0);
    return baseAnimation
        .addElement(baseEl)
        .easing('ease-in-out')
        .duration(150)
        .addAnimation([backdropAnimation, wrapperAnimation]);
};
var Alert = /** @class */ (function () {
    function class_1(hostRef) {
        var _this = this;
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        this.processedInputs = [];
        this.processedButtons = [];
        this.presented = false;
        this.mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        /**
         * If `true`, the keyboard will be automatically dismissed when the overlay is presented.
         */
        this.keyboardClose = true;
        /**
         * Array of buttons to be added to the alert.
         */
        this.buttons = [];
        /**
         * Array of input to show in the alert.
         */
        this.inputs = [];
        /**
         * If `true`, the alert will be dismissed when the backdrop is clicked.
         */
        this.backdropDismiss = true;
        /**
         * If `true`, the alert will be translucent.
         * Only applies when the mode is `"ios"` and the device supports
         * [`backdrop-filter`](https://developer.mozilla.org/en-US/docs/Web/CSS/backdrop-filter#Browser_compatibility).
         */
        this.translucent = false;
        /**
         * If `true`, the alert will animate.
         */
        this.animated = true;
        this.onBackdropTap = function () {
            _this.dismiss(undefined, _overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["B"]);
        };
        this.dispatchCancelHandler = function (ev) {
            var role = ev.detail.role;
            if (Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["i"])(role)) {
                var cancelButton = _this.processedButtons.find(function (b) { return b.role === 'cancel'; });
                _this.callButtonHandler(cancelButton);
            }
        };
        Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["c"])(this.el);
        this.didPresent = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionAlertDidPresent", 7);
        this.willPresent = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionAlertWillPresent", 7);
        this.willDismiss = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionAlertWillDismiss", 7);
        this.didDismiss = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionAlertDidDismiss", 7);
    }
    class_1.prototype.buttonsChanged = function () {
        var buttons = this.buttons;
        this.processedButtons = buttons.map(function (btn) {
            return (typeof btn === 'string')
                ? { text: btn, role: btn.toLowerCase() === 'cancel' ? 'cancel' : undefined }
                : btn;
        });
    };
    class_1.prototype.inputsChanged = function () {
        var _this = this;
        var inputs = this.inputs;
        // An alert can be created with several different inputs. Radios,
        // checkboxes and inputs are all accepted, but they cannot be mixed.
        var inputTypes = new Set(inputs.map(function (i) { return i.type; }));
        if (inputTypes.has('checkbox') && inputTypes.has('radio')) {
            console.warn("Alert cannot mix input types: " + (Array.from(inputTypes.values()).join('/')) + ". Please see alert docs for more info.");
        }
        this.inputType = inputTypes.values().next().value;
        this.processedInputs = inputs.map(function (i, index) { return ({
            type: i.type || 'text',
            name: i.name || "" + index,
            placeholder: i.placeholder || '',
            value: i.value,
            label: i.label,
            checked: !!i.checked,
            disabled: !!i.disabled,
            id: i.id || "alert-input-" + _this.overlayIndex + "-" + index,
            handler: i.handler,
            min: i.min,
            max: i.max
        }); });
    };
    class_1.prototype.componentWillLoad = function () {
        this.inputsChanged();
        this.buttonsChanged();
    };
    /**
     * Present the alert overlay after it has been created.
     */
    class_1.prototype.present = function () {
        return Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["d"])(this, 'alertEnter', iosEnterAnimation, mdEnterAnimation);
    };
    /**
     * Dismiss the alert overlay after it has been presented.
     *
     * @param data Any data to emit in the dismiss events.
     * @param role The role of the element that is dismissing the alert.
     * This can be useful in a button handler for determining which button was
     * clicked to dismiss the alert.
     * Some examples include: ``"cancel"`, `"destructive"`, "selected"`, and `"backdrop"`.
     */
    class_1.prototype.dismiss = function (data, role) {
        return Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["e"])(this, data, role, 'alertLeave', iosLeaveAnimation, mdLeaveAnimation);
    };
    /**
     * Returns a promise that resolves when the alert did dismiss.
     */
    class_1.prototype.onDidDismiss = function () {
        return Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["f"])(this.el, 'ionAlertDidDismiss');
    };
    /**
     * Returns a promise that resolves when the alert will dismiss.
     */
    class_1.prototype.onWillDismiss = function () {
        return Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["f"])(this.el, 'ionAlertWillDismiss');
    };
    class_1.prototype.rbClick = function (selectedInput) {
        for (var _i = 0, _a = this.processedInputs; _i < _a.length; _i++) {
            var input = _a[_i];
            input.checked = input === selectedInput;
        }
        this.activeId = selectedInput.id;
        Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["s"])(selectedInput.handler, selectedInput);
        this.el.forceUpdate();
    };
    class_1.prototype.cbClick = function (selectedInput) {
        selectedInput.checked = !selectedInput.checked;
        Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["s"])(selectedInput.handler, selectedInput);
        this.el.forceUpdate();
    };
    class_1.prototype.buttonClick = function (button) {
        var role = button.role;
        var values = this.getValues();
        if (Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["i"])(role)) {
            return this.dismiss({ values: values }, role);
        }
        var returnData = this.callButtonHandler(button, values);
        if (returnData !== false) {
            return this.dismiss(Object.assign({ values: values }, returnData), button.role);
        }
        return Promise.resolve(false);
    };
    class_1.prototype.callButtonHandler = function (button, data) {
        if (button && button.handler) {
            // a handler has been provided, execute it
            // pass the handler the values from the inputs
            var returnData = Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_3__["s"])(button.handler, data);
            if (returnData === false) {
                // if the return value of the handler is false then do not dismiss
                return false;
            }
            if (typeof returnData === 'object') {
                return returnData;
            }
        }
        return {};
    };
    class_1.prototype.getValues = function () {
        if (this.processedInputs.length === 0) {
            // this is an alert without any options/inputs at all
            return undefined;
        }
        if (this.inputType === 'radio') {
            // this is an alert with radio buttons (single value select)
            // return the one value which is checked, otherwise undefined
            var checkedInput = this.processedInputs.find(function (i) { return !!i.checked; });
            return checkedInput ? checkedInput.value : undefined;
        }
        if (this.inputType === 'checkbox') {
            // this is an alert with checkboxes (multiple value select)
            // return an array of all the checked values
            return this.processedInputs.filter(function (i) { return i.checked; }).map(function (i) { return i.value; });
        }
        // this is an alert with text inputs
        // return an object of all the values with the input name as the key
        var values = {};
        this.processedInputs.forEach(function (i) {
            values[i.name] = i.value || '';
        });
        return values;
    };
    class_1.prototype.renderAlertInputs = function (labelledBy) {
        switch (this.inputType) {
            case 'checkbox': return this.renderCheckbox(labelledBy);
            case 'radio': return this.renderRadio(labelledBy);
            default: return this.renderInput(labelledBy);
        }
    };
    class_1.prototype.renderCheckbox = function (labelledby) {
        var _this = this;
        var inputs = this.processedInputs;
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        if (inputs.length === 0) {
            return null;
        }
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-checkbox-group", "aria-labelledby": labelledby }, inputs.map(function (i) { return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("button", { type: "button", onClick: function () { return _this.cbClick(i); }, "aria-checked": "" + i.checked, id: i.id, disabled: i.disabled, tabIndex: 0, role: "checkbox", class: {
                'alert-tappable': true,
                'alert-checkbox': true,
                'alert-checkbox-button': true,
                'ion-focusable': true,
                'alert-checkbox-button-disabled': i.disabled || false
            } }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-button-inner" }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-checkbox-icon" }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-checkbox-inner" })), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-checkbox-label" }, i.label)), mode === 'md' && Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-ripple-effect", null))); })));
    };
    class_1.prototype.renderRadio = function (labelledby) {
        var _this = this;
        var inputs = this.processedInputs;
        if (inputs.length === 0) {
            return null;
        }
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-radio-group", role: "radiogroup", "aria-labelledby": labelledby, "aria-activedescendant": this.activeId }, inputs.map(function (i) { return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("button", { type: "button", onClick: function () { return _this.rbClick(i); }, "aria-checked": "" + i.checked, disabled: i.disabled, id: i.id, tabIndex: 0, class: {
                'alert-radio-button': true,
                'alert-tappable': true,
                'alert-radio': true,
                'ion-focusable': true,
                'alert-radio-button-disabled': i.disabled || false
            }, role: "radio" }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-button-inner" }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-radio-icon" }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-radio-inner" })), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-radio-label" }, i.label)))); })));
    };
    class_1.prototype.renderInput = function (labelledby) {
        var inputs = this.processedInputs;
        if (inputs.length === 0) {
            return null;
        }
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-input-group", "aria-labelledby": labelledby }, inputs.map(function (i) { return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-input-wrapper" }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("input", { placeholder: i.placeholder, value: i.value, type: i.type, min: i.min, max: i.max, onInput: function (e) { return i.value = e.target.value; }, id: i.id, disabled: i.disabled, tabIndex: 0, class: {
                'alert-input': true,
                'alert-input-disabled': i.disabled || false
            } }))); })));
    };
    class_1.prototype.renderAlertButtons = function () {
        var _this = this;
        var buttons = this.processedButtons;
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        var alertButtonGroupClass = {
            'alert-button-group': true,
            'alert-button-group-vertical': buttons.length > 2
        };
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: alertButtonGroupClass }, buttons.map(function (button) { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("button", { type: "button", class: buttonClass(button), tabIndex: 0, onClick: function () { return _this.buttonClick(button); } }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("span", { class: "alert-button-inner" }, button.text), mode === 'md' && Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-ripple-effect", null)); })));
    };
    class_1.prototype.render = function () {
        var _a;
        var _b = this, overlayIndex = _b.overlayIndex, header = _b.header, subHeader = _b.subHeader;
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        var hdrId = "alert-" + overlayIndex + "-hdr";
        var subHdrId = "alert-" + overlayIndex + "-sub-hdr";
        var msgId = "alert-" + overlayIndex + "-msg";
        var labelledById;
        if (header !== undefined) {
            labelledById = hdrId;
        }
        else if (subHeader !== undefined) {
            labelledById = subHdrId;
        }
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { role: "dialog", "aria-modal": "true", style: {
                zIndex: "" + (20000 + overlayIndex),
            }, class: Object.assign(Object.assign({}, Object(_theme_955ba954_js__WEBPACK_IMPORTED_MODULE_2__["g"])(this.cssClass)), (_a = {}, _a[mode] = true, _a['alert-translucent'] = this.translucent, _a)), onIonAlertWillDismiss: this.dispatchCancelHandler, onIonBackdropTap: this.onBackdropTap }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-backdrop", { tappable: this.backdropDismiss }), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-wrapper" }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "alert-head" }, header && Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("h2", { id: hdrId, class: "alert-title" }, header), subHeader && Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("h2", { id: subHdrId, class: "alert-sub-title" }, subHeader)), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { id: msgId, class: "alert-message", innerHTML: Object(_index_fbd2c40b_js__WEBPACK_IMPORTED_MODULE_5__["s"])(this.message) }), this.renderAlertInputs(labelledById), this.renderAlertButtons())));
    };
    Object.defineProperty(class_1.prototype, "el", {
        get: function () { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["d"])(this); },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "watchers", {
        get: function () {
            return {
                "buttons": ["buttonsChanged"],
                "inputs": ["inputsChanged"]
            };
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "style", {
        get: function () { return ".sc-ion-alert-ios-h{--min-width:250px;--width:auto;--min-height:auto;--height:auto;--max-height:90%;-moz-osx-font-smoothing:grayscale;-webkit-font-smoothing:antialiased;left:0;right:0;top:0;bottom:0;display:-ms-flexbox;display:flex;position:fixed;-ms-flex-align:center;align-items:center;-ms-flex-pack:center;justify-content:center;font-family:var(--ion-font-family,inherit);contain:strict;-ms-touch-action:none;touch-action:none;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;z-index:1001}.overlay-hidden.sc-ion-alert-ios-h{display:none}.alert-top.sc-ion-alert-ios-h{padding-top:50px;-ms-flex-align:start;align-items:flex-start}.alert-wrapper.sc-ion-alert-ios{display:-ms-flexbox;display:flex;-ms-flex-direction:column;flex-direction:column;width:var(--width);min-width:var(--min-width);max-width:var(--max-width);height:var(--height);min-height:var(--min-height);max-height:var(--max-height);background:var(--background);contain:content;opacity:0;z-index:10}.alert-title.sc-ion-alert-ios{margin-top:0}.alert-sub-title.sc-ion-alert-ios, .alert-title.sc-ion-alert-ios{margin-left:0;margin-right:0;margin-bottom:0;padding-left:0;padding-right:0;padding-top:0;padding-bottom:0}.alert-sub-title.sc-ion-alert-ios{margin-top:5px;font-weight:400}.alert-message.sc-ion-alert-ios{-webkit-box-sizing:border-box;box-sizing:border-box;-webkit-overflow-scrolling:touch;overflow-y:auto;overscroll-behavior-y:contain}.alert-checkbox-group.sc-ion-alert-ios::-webkit-scrollbar, .alert-message.sc-ion-alert-ios::-webkit-scrollbar, .alert-radio-group.sc-ion-alert-ios::-webkit-scrollbar{display:none}.alert-input.sc-ion-alert-ios{padding-left:0;padding-right:0;padding-top:10px;padding-bottom:10px;width:100%;border:0;background:inherit;font:inherit;-webkit-box-sizing:border-box;box-sizing:border-box}.alert-button-group.sc-ion-alert-ios{display:-ms-flexbox;display:flex;-ms-flex-direction:row;flex-direction:row;width:100%}.alert-button-group-vertical.sc-ion-alert-ios{-ms-flex-direction:column;flex-direction:column;-ms-flex-wrap:nowrap;flex-wrap:nowrap}.alert-button.sc-ion-alert-ios{display:block;border:0;font-size:14px;line-height:20px;z-index:0}.alert-button.ion-focused.sc-ion-alert-ios, .alert-tappable.ion-focused.sc-ion-alert-ios{background:var(--ion-color-step-100,#e6e6e6)}.alert-button-inner.sc-ion-alert-ios{display:-ms-flexbox;display:flex;-ms-flex-flow:row nowrap;flex-flow:row nowrap;-ms-flex-negative:0;flex-shrink:0;-ms-flex-align:center;align-items:center;-ms-flex-pack:center;justify-content:center;width:100%;height:100%}.alert-checkbox-button-disabled.sc-ion-alert-ios .alert-button-inner.sc-ion-alert-ios, .alert-input-disabled.sc-ion-alert-ios, .alert-radio-button-disabled.sc-ion-alert-ios .alert-button-inner.sc-ion-alert-ios{cursor:default;opacity:.5;pointer-events:none}.alert-tappable.sc-ion-alert-ios{margin-left:0;margin-right:0;margin-top:0;margin-bottom:0;padding-left:0;padding-right:0;padding-top:0;padding-bottom:0;display:-ms-flexbox;display:flex;width:100%;border:0;background:transparent;font-size:inherit;line-height:normal;text-align:start;-webkit-appearance:none;-moz-appearance:none;appearance:none;contain:strict}.alert-button.sc-ion-alert-ios, .alert-checkbox.sc-ion-alert-ios, .alert-input.sc-ion-alert-ios, .alert-radio.sc-ion-alert-ios{outline:none}.alert-checkbox-icon.sc-ion-alert-ios, .alert-checkbox-inner.sc-ion-alert-ios, .alert-radio-icon.sc-ion-alert-ios{-webkit-box-sizing:border-box;box-sizing:border-box}.sc-ion-alert-ios-h{--background:var(--ion-overlay-background-color,var(--ion-color-step-100,#f9f9f9));--max-width:270px;font-size:14px}.alert-wrapper.sc-ion-alert-ios{border-radius:13px;-webkit-box-shadow:none;box-shadow:none;overflow:hidden}\@supports ((-webkit-backdrop-filter:blur(0)) or (backdrop-filter:blur(0))){.alert-translucent.sc-ion-alert-ios-h .alert-wrapper.sc-ion-alert-ios{background:rgba(var(--ion-background-color-rgb,255,255,255),.9);-webkit-backdrop-filter:saturate(180%) blur(20px);backdrop-filter:saturate(180%) blur(20px)}}.alert-head.sc-ion-alert-ios{padding-left:16px;padding-right:16px;padding-top:12px;padding-bottom:7px;text-align:center}\@supports ((-webkit-margin-start:0) or (margin-inline-start:0)) or (-webkit-margin-start:0){.alert-head.sc-ion-alert-ios{padding-left:unset;padding-right:unset;-webkit-padding-start:16px;padding-inline-start:16px;-webkit-padding-end:16px;padding-inline-end:16px}}.alert-title.sc-ion-alert-ios{margin-top:8px;color:var(--ion-text-color,#000);font-size:17px;font-weight:600}.alert-sub-title.sc-ion-alert-ios{color:var(--ion-color-step-600,#666);font-size:14px}.alert-input-group.sc-ion-alert-ios, .alert-message.sc-ion-alert-ios{padding-left:16px;padding-right:16px;padding-top:0;padding-bottom:21px;color:var(--ion-text-color,#000);font-size:13px;text-align:center}\@supports ((-webkit-margin-start:0) or (margin-inline-start:0)) or (-webkit-margin-start:0){.alert-input-group.sc-ion-alert-ios, .alert-message.sc-ion-alert-ios{padding-left:unset;padding-right:unset;-webkit-padding-start:16px;padding-inline-start:16px;-webkit-padding-end:16px;padding-inline-end:16px}}.alert-message.sc-ion-alert-ios{max-height:240px}.alert-message.sc-ion-alert-ios:empty{padding-left:0;padding-right:0;padding-top:0;padding-bottom:12px}.alert-input.sc-ion-alert-ios{border-radius:4px;margin-top:10px;padding-left:6px;padding-right:6px;padding-top:6px;padding-bottom:6px;border:.55px solid var(--ion-color-step-250,#bfbfbf);background-color:var(--ion-background-color,#fff);-webkit-appearance:none;-moz-appearance:none;appearance:none}\@supports ((-webkit-margin-start:0) or (margin-inline-start:0)) or (-webkit-margin-start:0){.alert-input.sc-ion-alert-ios{padding-left:unset;padding-right:unset;-webkit-padding-start:6px;padding-inline-start:6px;-webkit-padding-end:6px;padding-inline-end:6px}}.alert-input.sc-ion-alert-ios::-webkit-input-placeholder{color:var(--ion-placeholder-color,var(--ion-color-step-400,#999));font-family:inherit;font-weight:inherit}.alert-input.sc-ion-alert-ios::-moz-placeholder{color:var(--ion-placeholder-color,var(--ion-color-step-400,#999));font-family:inherit;font-weight:inherit}.alert-input.sc-ion-alert-ios:-ms-input-placeholder{color:var(--ion-placeholder-color,var(--ion-color-step-400,#999));font-family:inherit;font-weight:inherit}.alert-input.sc-ion-alert-ios::-ms-input-placeholder{color:var(--ion-placeholder-color,var(--ion-color-step-400,#999));font-family:inherit;font-weight:inherit}.alert-input.sc-ion-alert-ios::placeholder{color:var(--ion-placeholder-color,var(--ion-color-step-400,#999));font-family:inherit;font-weight:inherit}.alert-input.sc-ion-alert-ios::-ms-clear{display:none}.alert-checkbox-group.sc-ion-alert-ios, .alert-radio-group.sc-ion-alert-ios{-ms-scroll-chaining:none;overscroll-behavior:contain;max-height:240px;border-top:.55px solid rgba(var(--ion-text-color-rgb,0,0,0),.2);overflow-y:auto;-webkit-overflow-scrolling:touch}.alert-tappable.sc-ion-alert-ios{height:44px}.alert-radio-label.sc-ion-alert-ios{padding-left:13px;padding-right:13px;padding-top:13px;padding-bottom:13px;-ms-flex:1;flex:1;-ms-flex-order:0;order:0;color:var(--ion-text-color,#000);text-overflow:ellipsis;white-space:nowrap;overflow:hidden}\@supports ((-webkit-margin-start:0) or (margin-inline-start:0)) or (-webkit-margin-start:0){.alert-radio-label.sc-ion-alert-ios{padding-left:unset;padding-right:unset;-webkit-padding-start:13px;padding-inline-start:13px;-webkit-padding-end:13px;padding-inline-end:13px}}[aria-checked=true].sc-ion-alert-ios .alert-radio-label.sc-ion-alert-ios{color:var(--ion-color-primary,#3880ff)}.alert-radio-icon.sc-ion-alert-ios{position:relative;-ms-flex-order:1;order:1;min-width:30px}[aria-checked=true].sc-ion-alert-ios .alert-radio-inner.sc-ion-alert-ios{left:7px;top:-7px;position:absolute;width:6px;height:12px;-webkit-transform:rotate(45deg);transform:rotate(45deg);border-width:2px;border-top-width:0;border-left-width:0;border-style:solid;border-color:var(--ion-color-primary,#3880ff)}[dir=rtl].sc-ion-alert-ios-h [aria-checked=true].sc-ion-alert-ios .alert-radio-inner.sc-ion-alert-ios, [dir=rtl] .sc-ion-alert-ios-h [aria-checked=true].sc-ion-alert-ios .alert-radio-inner.sc-ion-alert-ios, [dir=rtl].sc-ion-alert-ios [aria-checked=true].sc-ion-alert-ios .alert-radio-inner.sc-ion-alert-ios{left:unset;right:unset;right:7px}.alert-checkbox-label.sc-ion-alert-ios{padding-left:13px;padding-right:13px;padding-top:13px;padding-bottom:13px;-ms-flex:1;flex:1;color:var(--ion-text-color,#000);text-overflow:ellipsis;white-space:nowrap;overflow:hidden}\@supports ((-webkit-margin-start:0) or (margin-inline-start:0)) or (-webkit-margin-start:0){.alert-checkbox-label.sc-ion-alert-ios{padding-left:unset;padding-right:unset;-webkit-padding-start:13px;padding-inline-start:13px;-webkit-padding-end:13px;padding-inline-end:13px}}.alert-checkbox-icon.sc-ion-alert-ios{border-radius:50%;margin-left:16px;margin-right:6px;margin-top:10px;margin-bottom:10px;position:relative;width:24px;height:24px;border-width:1px;border-style:solid;border-color:var(--ion-item-border-color,var(--ion-border-color,var(--ion-color-step-250,#c8c7cc)));background-color:var(--ion-item-background,var(--ion-background-color,#fff));contain:strict}\@supports ((-webkit-margin-start:0) or (margin-inline-start:0)) or (-webkit-margin-start:0){.alert-checkbox-icon.sc-ion-alert-ios{margin-left:unset;margin-right:unset;-webkit-margin-start:16px;margin-inline-start:16px;-webkit-margin-end:6px;margin-inline-end:6px}}[aria-checked=true].sc-ion-alert-ios .alert-checkbox-icon.sc-ion-alert-ios{border-color:var(--ion-color-primary,#3880ff);background-color:var(--ion-color-primary,#3880ff)}[aria-checked=true].sc-ion-alert-ios .alert-checkbox-inner.sc-ion-alert-ios{left:9px;top:4px;position:absolute;width:5px;height:12px;-webkit-transform:rotate(45deg);transform:rotate(45deg);border-width:1px;border-top-width:0;border-left-width:0;border-style:solid;border-color:var(--ion-background-color,#fff)}[dir=rtl].sc-ion-alert-ios-h [aria-checked=true].sc-ion-alert-ios .alert-checkbox-inner.sc-ion-alert-ios, [dir=rtl] .sc-ion-alert-ios-h [aria-checked=true].sc-ion-alert-ios .alert-checkbox-inner.sc-ion-alert-ios, [dir=rtl].sc-ion-alert-ios [aria-checked=true].sc-ion-alert-ios .alert-checkbox-inner.sc-ion-alert-ios{left:unset;right:unset;right:9px}.alert-button-group.sc-ion-alert-ios{margin-right:-.55px;-ms-flex-wrap:wrap;flex-wrap:wrap}\@supports ((-webkit-margin-start:0) or (margin-inline-start:0)) or (-webkit-margin-start:0){.alert-button-group.sc-ion-alert-ios{margin-right:unset;-webkit-margin-end:-.55px;margin-inline-end:-.55px}}.alert-button.sc-ion-alert-ios{margin-left:0;margin-right:0;margin-top:0;margin-bottom:0;border-radius:0;-ms-flex:1 1 auto;flex:1 1 auto;min-width:50%;height:44px;border-top:.55px solid rgba(var(--ion-text-color-rgb,0,0,0),.2);border-right:.55px solid rgba(var(--ion-text-color-rgb,0,0,0),.2);background-color:transparent;color:var(--ion-color-primary,#3880ff);font-size:17px;overflow:hidden}[dir=rtl].sc-ion-alert-ios-h .alert-button.sc-ion-alert-ios:first-child, [dir=rtl] .sc-ion-alert-ios-h .alert-button.sc-ion-alert-ios:first-child, [dir=rtl].sc-ion-alert-ios .alert-button.sc-ion-alert-ios:first-child{border-right:0}.alert-button.sc-ion-alert-ios:last-child{border-right:0;font-weight:700}[dir=rtl].sc-ion-alert-ios-h .alert-button.sc-ion-alert-ios:last-child, [dir=rtl] .sc-ion-alert-ios-h .alert-button.sc-ion-alert-ios:last-child, [dir=rtl].sc-ion-alert-ios .alert-button.sc-ion-alert-ios:last-child{border-right:.55px solid rgba(var(--ion-text-color-rgb,0,0,0),.2)}.alert-button.activated.sc-ion-alert-ios{background-color:rgba(var(--ion-text-color-rgb,0,0,0),.1)}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());
var buttonClass = function (button) {
    return Object.assign({ 'alert-button': true, 'ion-focusable': true, 'ion-activatable': true }, Object(_theme_955ba954_js__WEBPACK_IMPORTED_MODULE_2__["g"])(button.cssClass));
};



/***/ }),

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/theme-955ba954.js":
/*!****************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/theme-955ba954.js ***!
  \****************************************************************************/
/*! exports provided: c, g, h, o */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return createColorClasses; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "g", function() { return getClassMap; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "h", function() { return hostContext; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "o", function() { return openURL; });
var __awaiter = (undefined && undefined.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (undefined && undefined.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var _this = undefined;
var hostContext = function (selector, el) {
    return el.closest(selector) !== null;
};
/**
 * Create the mode and color classes for the component based on the classes passed in
 */
var createColorClasses = function (color) {
    var _a;
    return (typeof color === 'string' && color.length > 0) ? (_a = {
            'ion-color': true
        },
        _a["ion-color-" + color] = true,
        _a) : undefined;
};
var getClassList = function (classes) {
    if (classes !== undefined) {
        var array = Array.isArray(classes) ? classes : classes.split(' ');
        return array
            .filter(function (c) { return c != null; })
            .map(function (c) { return c.trim(); })
            .filter(function (c) { return c !== ''; });
    }
    return [];
};
var getClassMap = function (classes) {
    var map = {};
    getClassList(classes).forEach(function (c) { return map[c] = true; });
    return map;
};
var SCHEME = /^[a-z][a-z0-9+\-.]*:/;
var openURL = function (url, ev, direction) { return __awaiter(_this, void 0, void 0, function () {
    var router;
    return __generator(this, function (_a) {
        if (url != null && url[0] !== '#' && !SCHEME.test(url)) {
            router = document.querySelector('ion-router');
            if (router) {
                if (ev != null) {
                    ev.preventDefault();
                }
                return [2 /*return*/, router.push(url, direction)];
            }
        }
        return [2 /*return*/, false];
    });
}); };



/***/ })

}]);
//# sourceMappingURL=30.5b9dc3e0769f06f20dce.js.map