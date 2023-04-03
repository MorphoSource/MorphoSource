(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[131],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-route.entry.js":
/*!*****************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-route.entry.js ***!
  \*****************************************************************************/
/*! exports provided: ion_route */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_route", function() { return Route; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");

var Route = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        /**
         * Relative path that needs to match in order for this route to apply.
         *
         * Accepts paths similar to expressjs so that you can define parameters
         * in the url /foo/:bar where bar would be available in incoming props.
         */
        this.url = '';
        this.ionRouteDataChanged = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionRouteDataChanged", 7);
    }
    class_1.prototype.onUpdate = function (newValue) {
        this.ionRouteDataChanged.emit(newValue);
    };
    class_1.prototype.onComponentProps = function (newValue, oldValue) {
        if (newValue === oldValue) {
            return;
        }
        var keys1 = newValue ? Object.keys(newValue) : [];
        var keys2 = oldValue ? Object.keys(oldValue) : [];
        if (keys1.length !== keys2.length) {
            this.onUpdate(newValue);
            return;
        }
        for (var _i = 0, keys1_1 = keys1; _i < keys1_1.length; _i++) {
            var key = keys1_1[_i];
            if (newValue[key] !== oldValue[key]) {
                this.onUpdate(newValue);
                return;
            }
        }
    };
    class_1.prototype.connectedCallback = function () {
        this.ionRouteDataChanged.emit();
    };
    Object.defineProperty(class_1, "watchers", {
        get: function () {
            return {
                "url": ["onUpdate"],
                "component": ["onUpdate"],
                "componentProps": ["onComponentProps"]
            };
        },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



/***/ })

}]);
//# sourceMappingURL=131.5f1177ff3a35bcb477fe.js.map