(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[122],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-menu-controller.entry.js":
/*!***************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-menu-controller.entry.js ***!
  \***************************************************************************************/
/*! exports provided: ion_menu_controller */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_menu_controller", function() { return MenuController; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./helpers-1644482e.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js");
/* harmony import */ var _animation_d551500b_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./animation-d551500b.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/animation-d551500b.js");
/* harmony import */ var _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./index-cc681366.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-cc681366.js");
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




var MenuController = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
    }
    /**
     * Open the menu. If a menu is not provided then it will open the first
     * menu found. If the specified menu is `start` or `end`, then it will open
     * the enabled menu on that side. Otherwise, it will try to find the menu
     * using the menu's `id` property. If a menu is not found then it will
     * return `false`.
     *
     * @param menu The menuId or side of the menu to open.
     */
    class_1.prototype.open = function (menu) {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].open(menu);
    };
    /**
     * Close the menu. If a menu is specified, it will close that menu.
     * If no menu is specified, then it will close any menu that is open.
     * If it does not find any open menus, it will return `false`.
     *
     * @param menu The menuId or side of the menu to close.
     */
    class_1.prototype.close = function (menu) {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].close(menu);
    };
    /**
     * Toggle the menu open or closed. If the menu is already open, it will try to
     * close the menu, otherwise it will try to open it. Returns `false` if
     * a menu is not found.
     *
     * @param menu The menuId or side of the menu to toggle.
     */
    class_1.prototype.toggle = function (menu) {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].toggle(menu);
    };
    /**
     * Enable or disable a menu. Disabling a menu will not allow gestures
     * for that menu or any calls to open it. This is useful when there are
     * multiple menus on the same side and only one of them should be allowed
     * to open. Enabling a menu will automatically disable all other menus
     * on that side.
     *
     * @param enable If `true`, the menu should be enabled.
     * @param menu The menuId or side of the menu to enable or disable.
     */
    class_1.prototype.enable = function (enable, menu) {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].enable(enable, menu);
    };
    /**
     * Enable or disable the ability to swipe open the menu.
     *
     * @param enable If `true`, the menu swipe gesture should be enabled.
     * @param menu The menuId or side of the menu to enable or disable the swipe gesture on.
     */
    class_1.prototype.swipeGesture = function (enable, menu) {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].swipeGesture(enable, menu);
    };
    /**
     * Get whether or not the menu is open. Returns `true` if the specified
     * menu is open. If a menu is not specified, it will return `true` if
     * any menu is currently open.
     *
     * @param menu The menuId or side of the menu that is being checked.
     */
    class_1.prototype.isOpen = function (menu) {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].isOpen(menu);
    };
    /**
     * Get whether or not the menu is enabled. Returns `true` if the
     * specified menu is enabled. Returns `false` if a menu is disabled
     * or not found.
     *
     * @param menu The menuId or side of the menu that is being checked.
     */
    class_1.prototype.isEnabled = function (menu) {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].isEnabled(menu);
    };
    /**
     * Get a menu instance. If a menu is not provided then it will return the first
     * menu found. If the specified menu is `start` or `end`, then it will return the
     * enabled menu on that side. Otherwise, it will try to find the menu using the menu's
     * `id` property. If a menu is not found then it will return `null`.
     *
     * @param menu The menuId or side of the menu.
     */
    class_1.prototype.get = function (menu) {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].get(menu);
    };
    /**
     * Get the instance of the opened menu. Returns `null` if a menu is not found.
     */
    class_1.prototype.getOpen = function () {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].getOpen();
    };
    /**
     * Get all menu instances.
     */
    class_1.prototype.getMenus = function () {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].getMenus();
    };
    /**
     * Get whether or not a menu is animating. Returns `true` if any
     * menu is currently animating.
     */
    class_1.prototype.isAnimating = function () {
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].isAnimating();
    };
    /**
     * Registers a new animation that can be used with any `ion-menu` by
     * passing the name of the animation in its `type` property.
     *
     * @param name The name of the animation to register.
     * @param animation The animation function to register.
     */
    class_1.prototype.registerAnimation = function (name, animation) {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                return [2 /*return*/, _index_cc681366_js__WEBPACK_IMPORTED_MODULE_3__["m"].registerAnimation(name, animation)];
            });
        });
    };
    return class_1;
}());



/***/ })

}]);
//# sourceMappingURL=122.74f786fa708945708baf.js.map