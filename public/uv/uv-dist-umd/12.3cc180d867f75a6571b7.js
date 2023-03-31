(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[12],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/status-tap-7e7b1839.js":
/*!*********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/status-tap-7e7b1839.js ***!
  \*********************************************************************************/
/*! exports provided: startStatusTap */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "startStatusTap", function() { return startStatusTap; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");

var startStatusTap = function () {
    var win = window;
    win.addEventListener('statusTap', function () {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["m"])(function () {
            var width = win.innerWidth;
            var height = win.innerHeight;
            var el = document.elementFromPoint(width / 2, height / 2);
            if (!el) {
                return;
            }
            var contentEl = el.closest('ion-content');
            if (contentEl) {
                contentEl.componentOnReady().then(function () {
                    Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["w"])(function () { return contentEl.scrollToTop(300); });
                });
            }
        });
    });
};



/***/ })

}]);
//# sourceMappingURL=12.3cc180d867f75a6571b7.js.map