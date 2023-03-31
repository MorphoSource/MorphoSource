(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[91],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-skeleton-text.entry.js":
/*!*************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-skeleton-text.entry.js ***!
  \*************************************************************************************/
/*! exports provided: ion_skeleton_text */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_skeleton_text", function() { return SkeletonText; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _theme_955ba954_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./theme-955ba954.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/theme-955ba954.js");


var SkeletonText = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        /**
         * If `true`, the skeleton text will animate.
         */
        this.animated = false;
    }
    class_1.prototype.calculateWidth = function () {
        // If width was passed in to the property use that first
        // tslint:disable-next-line: deprecation
        if (this.width !== undefined) {
            return {
                style: {
                    // tslint:disable-next-line: deprecation
                    width: this.width
                }
            };
        }
        return;
    };
    class_1.prototype.render = function () {
        var _a;
        var animated = this.animated && _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["i"].getBoolean('animated', true);
        var inMedia = Object(_theme_955ba954_js__WEBPACK_IMPORTED_MODULE_1__["h"])('ion-avatar', this.el) || Object(_theme_955ba954_js__WEBPACK_IMPORTED_MODULE_1__["h"])('ion-thumbnail', this.el);
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], Object.assign({ class: (_a = {},
                _a[mode] = true,
                _a['skeleton-text-animated'] = animated,
                _a['in-media'] = inMedia,
                _a) }, this.calculateWidth()), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("span", null, "\u00A0")));
    };
    Object.defineProperty(class_1.prototype, "el", {
        get: function () { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["d"])(this); },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "style", {
        get: function () { return ":host{--background:rgba(var(--background-rgb,var(--ion-text-color-rgb,0,0,0)),0.065);border-radius:var(--border-radius,inherit);display:block;width:100%;height:inherit;margin-top:4px;margin-bottom:4px;background:var(--background);line-height:10px;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;pointer-events:none}span{display:inline-block}:host(.in-media){margin-left:0;margin-right:0;margin-top:0;margin-bottom:0;height:100%}:host(.skeleton-text-animated){position:relative;background:-webkit-gradient(linear,left top,right top,color-stop(8%,rgba(var(--background-rgb,var(--ion-text-color-rgb,0,0,0)),.065)),color-stop(18%,rgba(var(--background-rgb,var(--ion-text-color-rgb,0,0,0)),.135)),color-stop(33%,rgba(var(--background-rgb,var(--ion-text-color-rgb,0,0,0)),.065)));background:linear-gradient(90deg,rgba(var(--background-rgb,var(--ion-text-color-rgb,0,0,0)),.065) 8%,rgba(var(--background-rgb,var(--ion-text-color-rgb,0,0,0)),.135) 18%,rgba(var(--background-rgb,var(--ion-text-color-rgb,0,0,0)),.065) 33%);background-size:800px 104px;-webkit-animation-duration:1s;animation-duration:1s;-webkit-animation-fill-mode:forwards;animation-fill-mode:forwards;-webkit-animation-iteration-count:infinite;animation-iteration-count:infinite;-webkit-animation-name:shimmer;animation-name:shimmer;-webkit-animation-timing-function:linear;animation-timing-function:linear}\@-webkit-keyframes shimmer{0%{background-position:-468px 0}to{background-position:468px 0}}\@keyframes shimmer{0%{background-position:-468px 0}to{background-position:468px 0}}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



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
//# sourceMappingURL=91.8a6bdcaad53a50d75a76.js.map