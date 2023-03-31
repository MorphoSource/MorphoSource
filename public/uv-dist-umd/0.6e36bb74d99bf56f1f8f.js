(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[0],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/overlays-84052d05.js":
/*!*******************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/overlays-84052d05.js ***!
  \*******************************************************************************/
/*! exports provided: B, a, b, c, d, e, f, g, h, i, j, k, p, s */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "B", function() { return BACKDROP; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return actionSheetController; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return alertController; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return prepareOverlay; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "d", function() { return present; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "e", function() { return dismiss; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "f", function() { return eventMethod; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "g", function() { return createOverlay; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "h", function() { return dismissOverlay; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "i", function() { return isCancel; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "j", function() { return getOverlay; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "k", function() { return pickerController; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "p", function() { return popoverController; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "s", function() { return safeCall; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
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

var lastId = 0;
var createController = function (tagName) {
    return {
        create: function (options) {
            return createOverlay(tagName, options);
        },
        dismiss: function (data, role, id) {
            return dismissOverlay(document, data, role, tagName, id);
        },
        getTop: function () {
            return __awaiter(this, void 0, void 0, function () {
                return __generator(this, function (_a) {
                    return [2 /*return*/, getOverlay(document, tagName)];
                });
            });
        }
    };
};
var alertController = /*@__PURE__*/ createController('ion-alert');
var actionSheetController = /*@__PURE__*/ createController('ion-action-sheet');
var pickerController = /*@__PURE__*/ createController('ion-picker');
var popoverController = /*@__PURE__*/ createController('ion-popover');
var prepareOverlay = function (el) {
    var doc = document;
    connectListeners(doc);
    var overlayIndex = lastId++;
    el.overlayIndex = overlayIndex;
    if (!el.hasAttribute('id')) {
        el.id = "ion-overlay-" + overlayIndex;
    }
};
var createOverlay = function (tagName, opts) {
    return customElements.whenDefined(tagName).then(function () {
        var doc = document;
        var element = doc.createElement(tagName);
        element.classList.add('overlay-hidden');
        // convert the passed in overlay options into props
        // that get passed down into the new overlay
        Object.assign(element, opts);
        // append the overlay element to the document body
        getAppRoot(doc).appendChild(element);
        return element.componentOnReady();
    });
};
var connectListeners = function (doc) {
    if (lastId === 0) {
        lastId = 1;
        // trap focus inside overlays
        doc.addEventListener('focusin', function (ev) {
            var lastOverlay = getOverlay(doc);
            if (lastOverlay && lastOverlay.backdropDismiss && !isDescendant(lastOverlay, ev.target)) {
                var firstInput = lastOverlay.querySelector('input,button');
                if (firstInput) {
                    firstInput.focus();
                }
            }
        });
        // handle back-button click
        doc.addEventListener('ionBackButton', function (ev) {
            var lastOverlay = getOverlay(doc);
            if (lastOverlay && lastOverlay.backdropDismiss) {
                ev.detail.register(100, function () {
                    return lastOverlay.dismiss(undefined, BACKDROP);
                });
            }
        });
        // handle ESC to close overlay
        doc.addEventListener('keyup', function (ev) {
            if (ev.key === 'Escape') {
                var lastOverlay = getOverlay(doc);
                if (lastOverlay && lastOverlay.backdropDismiss) {
                    lastOverlay.dismiss(undefined, BACKDROP);
                }
            }
        });
    }
};
var dismissOverlay = function (doc, data, role, overlayTag, id) {
    var overlay = getOverlay(doc, overlayTag, id);
    if (!overlay) {
        return Promise.reject('overlay does not exist');
    }
    return overlay.dismiss(data, role);
};
var getOverlays = function (doc, selector) {
    if (selector === undefined) {
        selector = 'ion-alert,ion-action-sheet,ion-loading,ion-modal,ion-picker,ion-popover,ion-toast';
    }
    return Array.from(doc.querySelectorAll(selector))
        .filter(function (c) { return c.overlayIndex > 0; });
};
var getOverlay = function (doc, overlayTag, id) {
    var overlays = getOverlays(doc, overlayTag);
    return (id === undefined)
        ? overlays[overlays.length - 1]
        : overlays.find(function (o) { return o.id === id; });
};
var present = function (overlay, name, iosEnterAnimation, mdEnterAnimation, opts) { return __awaiter(_this, void 0, void 0, function () {
    var animationBuilder, completed;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                if (overlay.presented) {
                    return [2 /*return*/];
                }
                overlay.presented = true;
                overlay.willPresent.emit();
                animationBuilder = (overlay.enterAnimation)
                    ? overlay.enterAnimation
                    : _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["i"].get(name, overlay.mode === 'ios' ? iosEnterAnimation : mdEnterAnimation);
                return [4 /*yield*/, overlayAnimation(overlay, animationBuilder, overlay.el, opts)];
            case 1:
                completed = _a.sent();
                if (completed) {
                    overlay.didPresent.emit();
                }
                return [2 /*return*/];
        }
    });
}); };
var dismiss = function (overlay, data, role, name, iosLeaveAnimation, mdLeaveAnimation, opts) { return __awaiter(_this, void 0, void 0, function () {
    var animationBuilder, err_1;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                if (!overlay.presented) {
                    return [2 /*return*/, false];
                }
                overlay.presented = false;
                _a.label = 1;
            case 1:
                _a.trys.push([1, 3, , 4]);
                overlay.willDismiss.emit({ data: data, role: role });
                animationBuilder = (overlay.leaveAnimation)
                    ? overlay.leaveAnimation
                    : _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["i"].get(name, overlay.mode === 'ios' ? iosLeaveAnimation : mdLeaveAnimation);
                return [4 /*yield*/, overlayAnimation(overlay, animationBuilder, overlay.el, opts)];
            case 2:
                _a.sent();
                overlay.didDismiss.emit({ data: data, role: role });
                return [3 /*break*/, 4];
            case 3:
                err_1 = _a.sent();
                console.error(err_1);
                return [3 /*break*/, 4];
            case 4:
                overlay.el.remove();
                return [2 /*return*/, true];
        }
    });
}); };
var getAppRoot = function (doc) {
    return doc.querySelector('ion-app') || doc.body;
};
var overlayAnimation = function (overlay, animationBuilder, baseEl, opts) { return __awaiter(_this, void 0, void 0, function () {
    var aniRoot, animation, isAnimationBuilder, mod, err_2, animationResult, hasCompleted;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                if (overlay.animation) {
                    overlay.animation.destroy();
                    overlay.animation = undefined;
                    return [2 /*return*/, false];
                }
                // Make overlay visible in case it's hidden
                baseEl.classList.remove('overlay-hidden');
                aniRoot = baseEl.shadowRoot || overlay.el;
                isAnimationBuilder = true;
                _a.label = 1;
            case 1:
                _a.trys.push([1, 4, , 5]);
                return [4 /*yield*/, __webpack_require__.e(/*! import() */ 10).then(__webpack_require__.bind(null, /*! ./index-db7d5039.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-db7d5039.js"))];
            case 2:
                mod = _a.sent();
                return [4 /*yield*/, mod.create(animationBuilder, aniRoot, opts)];
            case 3:
                animation = _a.sent();
                return [3 /*break*/, 5];
            case 4:
                err_2 = _a.sent();
                animation = animationBuilder(aniRoot, opts);
                animation.fill('both');
                isAnimationBuilder = false;
                return [3 /*break*/, 5];
            case 5:
                overlay.animation = animation;
                if (!overlay.animated || !_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["i"].getBoolean('animated', true)) {
                    animation.duration(0);
                }
                if (overlay.keyboardClose) {
                    animation.beforeAddWrite(function () {
                        var activeElement = baseEl.ownerDocument.activeElement;
                        if (activeElement && activeElement.matches('input, ion-input, ion-textarea')) {
                            activeElement.blur();
                        }
                    });
                }
                return [4 /*yield*/, animation.playAsync()];
            case 6:
                animationResult = _a.sent();
                hasCompleted = (typeof animationResult === 'undefined') ? true : animation.hasCompleted;
                if (isAnimationBuilder) {
                    animation.destroy();
                }
                overlay.animation = undefined;
                return [2 /*return*/, hasCompleted];
        }
    });
}); };
var eventMethod = function (element, eventName) {
    var resolve;
    var promise = new Promise(function (r) { return resolve = r; });
    onceEvent(element, eventName, function (event) {
        resolve(event.detail);
    });
    return promise;
};
var onceEvent = function (element, eventName, callback) {
    var handler = function (ev) {
        element.removeEventListener(eventName, handler);
        callback(ev);
    };
    element.addEventListener(eventName, handler);
};
var isCancel = function (role) {
    return role === 'cancel' || role === BACKDROP;
};
var isDescendant = function (parent, child) {
    while (child) {
        if (child === parent) {
            return true;
        }
        child = child.parentElement;
    }
    return false;
};
var defaultGate = function (h) { return h(); };
var safeCall = function (handler, arg) {
    if (typeof handler === 'function') {
        var jmp = _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["i"].get('_zoneGate', defaultGate);
        return jmp(function () {
            try {
                return handler(arg);
            }
            catch (e) {
                console.error(e);
            }
        });
    }
    return undefined;
};
var BACKDROP = 'backdrop';



/***/ })

}]);
//# sourceMappingURL=0.6e36bb74d99bf56f1f8f.js.map