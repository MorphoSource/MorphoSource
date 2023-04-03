(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[135],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-select-popover.entry.js":
/*!**************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-select-popover.entry.js ***!
  \**************************************************************************************/
/*! exports provided: ion_select_popover */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_select_popover", function() { return SelectPopover; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./overlays-84052d05.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/overlays-84052d05.js");


var SelectPopover = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        /** Array of options for the popover */
        this.options = [];
    }
    class_1.prototype.onSelect = function (ev) {
        var option = this.options.find(function (o) { return o.value === ev.target.value; });
        if (option) {
            Object(_overlays_84052d05_js__WEBPACK_IMPORTED_MODULE_1__["s"])(option.handler);
        }
    };
    class_1.prototype.render = function () {
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { class: Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this) }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-list", null, this.header !== undefined && Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-list-header", null, this.header), (this.subHeader !== undefined || this.message !== undefined) &&
            Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-item", null, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-label", { class: "ion-text-wrap" }, this.subHeader !== undefined && Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("h3", null, this.subHeader), this.message !== undefined && Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("p", null, this.message))), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-radio-group", null, this.options.map(function (option) { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-item", null, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-label", null, option.text), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-radio", { checked: option.checked, value: option.value, disabled: option.disabled })); })))));
    };
    Object.defineProperty(class_1, "style", {
        get: function () { return ".sc-ion-select-popover-h ion-list.sc-ion-select-popover{margin-left:0;margin-right:0;margin-top:-1px;margin-bottom:-1px}.sc-ion-select-popover-h ion-label.sc-ion-select-popover, .sc-ion-select-popover-h ion-list-header.sc-ion-select-popover{margin-left:0;margin-right:0;margin-top:0;margin-bottom:0}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



/***/ })

}]);
//# sourceMappingURL=135.c4d883746a8d1ebbd699.js.map