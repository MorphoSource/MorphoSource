(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[80],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-nav-push.entry.js":
/*!********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-nav-push.entry.js ***!
  \********************************************************************************/
/*! exports provided: ion_nav_push */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_nav_push", function() { return NavPush; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _nav_link_utils_7601dc1b_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./nav-link-utils-7601dc1b.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/nav-link-utils-7601dc1b.js");


var NavPush = /** @class */ (function () {
    function class_1(hostRef) {
        var _this = this;
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        this.push = function () {
            return Object(_nav_link_utils_7601dc1b_js__WEBPACK_IMPORTED_MODULE_1__["n"])(_this.el, 'forward', _this.component, _this.componentProps);
        };
    }
    class_1.prototype.componentDidLoad = function () {
        console.warn('[DEPRECATED][ion-nav-push] `<ion-nav-push component="MyComponent">` is deprecated. Use `<ion-nav-link component="MyComponent">` instead.');
    };
    class_1.prototype.render = function () {
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { onClick: this.push }));
    };
    Object.defineProperty(class_1.prototype, "el", {
        get: function () { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["d"])(this); },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



/***/ }),

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/nav-link-utils-7601dc1b.js":
/*!*************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/nav-link-utils-7601dc1b.js ***!
  \*************************************************************************************/
/*! exports provided: n */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "n", function() { return navLink; });
var navLink = function (el, routerDirection, component, componentProps) {
    var nav = el.closest('ion-nav');
    if (nav) {
        if (routerDirection === 'forward') {
            if (component !== undefined) {
                return nav.push(component, componentProps, { skipIfBusy: true });
            }
        }
        else if (routerDirection === 'root') {
            if (component !== undefined) {
                return nav.setRoot(component, componentProps, { skipIfBusy: true });
            }
        }
        else if (routerDirection === 'back') {
            return nav.pop({ skipIfBusy: true });
        }
    }
    return Promise.resolve(false);
};



/***/ })

}]);
//# sourceMappingURL=80.d135357002352cffc278.js.map