(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[119],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-item-group-ios.entry.js":
/*!**************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-item-group-ios.entry.js ***!
  \**************************************************************************************/
/*! exports provided: ion_item_group */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_item_group", function() { return ItemGroup; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");

var ItemGroup = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
    }
    class_1.prototype.render = function () {
        var _a;
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { role: "group", class: (_a = {},
                _a[mode] = true,
                // Used internally for styling
                _a["item-group-" + mode] = true,
                _a['item'] = true,
                _a) }));
    };
    Object.defineProperty(class_1, "style", {
        get: function () { return "ion-item-group{display:block}.item-group-ios ion-item-sliding:last-child .item,.item-group-ios ion-item:last-child{--border-width:0}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



/***/ })

}]);
//# sourceMappingURL=119.54d8b2e193dbaf7691ac.js.map