(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[128],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-reorder-ios.entry.js":
/*!***********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-reorder-ios.entry.js ***!
  \***********************************************************************************/
/*! exports provided: ion_reorder */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_reorder", function() { return Reorder; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");

var Reorder = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
    }
    class_1.prototype.onClick = function (ev) {
        ev.preventDefault();
        ev.stopImmediatePropagation();
    };
    class_1.prototype.render = function () {
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { class: Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this) }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("slot", null, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-icon", { name: "reorder", lazy: false, class: "reorder-icon" }))));
    };
    Object.defineProperty(class_1, "style", {
        get: function () { return ":host([slot]){display:none;line-height:0;z-index:100}.reorder-icon{display:block;font-size:22px;font-size:34px;opacity:.4}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



/***/ })

}]);
//# sourceMappingURL=128.045c84588c4bb890042e.js.map