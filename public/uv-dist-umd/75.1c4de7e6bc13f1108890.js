(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[75],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-menu-toggle.entry.js":
/*!***********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-menu-toggle.entry.js ***!
  \***********************************************************************************/
/*! exports provided: ion_menu_toggle */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_menu_toggle", function() { return MenuToggle; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./helpers-1644482e.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js");
/* harmony import */ var _animation_d551500b_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./animation-d551500b.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/animation-d551500b.js");
/* harmony import */ var _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./index-cc681366.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-cc681366.js");
/* harmony import */ var _menu_toggle_util_2b4d1118_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./menu-toggle-util-2b4d1118.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/menu-toggle-util-2b4d1118.js");
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





var MenuToggle = /** @class */ (function () {
    function class_1(hostRef) {
        var _this = this;
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        this.visible = false;
        /**
         * Automatically hides the content when the corresponding menu is not active.
         *
         * By default, it's `true`. Change it to `false` in order to
         * keep `ion-menu-toggle` always visible regardless the state of the menu.
         */
        this.autoHide = true;
        this.onClick = function () {
            return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].toggle(_this.menu);
        };
    }
    class_1.prototype.connectedCallback = function () {
        this.visibilityChanged();
    };
    class_1.prototype.visibilityChanged = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        _a = this;
                        return [4 /*yield*/, Object(_menu_toggle_util_2b4d1118_js__WEBPACK_IMPORTED_MODULE_4__["u"])(this.menu)];
                    case 1:
                        _a.visible = _b.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.render = function () {
        var _a;
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        var hidden = this.autoHide && !this.visible;
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { onClick: this.onClick, "aria-hidden": hidden ? 'true' : null, class: (_a = {},
                _a[mode] = true,
                _a['menu-toggle-hidden'] = hidden,
                _a) }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("slot", null)));
    };
    Object.defineProperty(class_1, "style", {
        get: function () { return ":host(.menu-toggle-hidden){display:none}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



/***/ }),

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/menu-toggle-util-2b4d1118.js":
/*!***************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/menu-toggle-util-2b4d1118.js ***!
  \***************************************************************************************/
/*! exports provided: u */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "u", function() { return updateVisibility; });
/* harmony import */ var _index_cc681366_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./index-cc681366.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-cc681366.js");
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

// Given a menu, return whether or not the menu toggle should be visible
var updateVisibility = function (menu) { return __awaiter(_this, void 0, void 0, function () {
    var menuEl, _a;
    return __generator(this, function (_b) {
        switch (_b.label) {
            case 0: return [4 /*yield*/, _index_cc681366_js__WEBPACK_IMPORTED_MODULE_0__["m"].get(menu)];
            case 1:
                menuEl = _b.sent();
                _a = menuEl;
                if (!_a) return [3 /*break*/, 3];
                return [4 /*yield*/, menuEl.isActive()];
            case 2:
                _a = (_b.sent());
                _b.label = 3;
            case 3: return [2 /*return*/, !!(_a)];
        }
    });
}); };



/***/ })

}]);
//# sourceMappingURL=75.1c4de7e6bc13f1108890.js.map