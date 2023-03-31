(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[130],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-route-redirect.entry.js":
/*!**************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-route-redirect.entry.js ***!
  \**************************************************************************************/
/*! exports provided: ion_route_redirect */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_route_redirect", function() { return RouteRedirect; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");

var RouteRedirect = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        this.ionRouteRedirectChanged = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionRouteRedirectChanged", 7);
    }
    class_1.prototype.propDidChange = function () {
        this.ionRouteRedirectChanged.emit();
    };
    class_1.prototype.connectedCallback = function () {
        this.ionRouteRedirectChanged.emit();
    };
    Object.defineProperty(class_1, "watchers", {
        get: function () {
            return {
                "from": ["propDidChange"],
                "to": ["propDidChange"]
            };
        },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



/***/ })

}]);
//# sourceMappingURL=130.67376284dd05bbcb23bf.js.map