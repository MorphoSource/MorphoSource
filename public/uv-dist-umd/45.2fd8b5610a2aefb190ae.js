(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[45],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js":
/*!******************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js ***!
  \******************************************************************************/
/*! exports provided: a, b, c, d, e, f, h, i, n, p, r */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return raf; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return assert; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return clamp; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "d", function() { return debounceEvent; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "e", function() { return debounce; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "f", function() { return findItemLabel; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "h", function() { return hasShadowDom; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "i", function() { return isEndSide; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "n", function() { return now; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "p", function() { return pointerCoord; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "r", function() { return renderHiddenInput; });
/**
 * Patched version of requestAnimationFrame that avoids ngzone
 * Use only when you know ngzone should not run
 */
var raf = function (h) {
    if (typeof __zone_symbol__requestAnimationFrame === 'function') {
        return __zone_symbol__requestAnimationFrame(h);
    }
    if (typeof requestAnimationFrame === 'function') {
        return requestAnimationFrame(h);
    }
    return setTimeout(h);
};
var hasShadowDom = function (el) {
    return !!el.shadowRoot && !!el.attachShadow;
};
var findItemLabel = function (componentEl) {
    var itemEl = componentEl.closest('ion-item');
    if (itemEl) {
        return itemEl.querySelector('ion-label');
    }
    return null;
};
var renderHiddenInput = function (always, container, name, value, disabled) {
    if (always || hasShadowDom(container)) {
        var input = container.querySelector('input.aux-input');
        if (!input) {
            input = container.ownerDocument.createElement('input');
            input.type = 'hidden';
            input.classList.add('aux-input');
            container.appendChild(input);
        }
        input.disabled = disabled;
        input.name = name;
        input.value = value || '';
    }
};
var clamp = function (min, n, max) {
    return Math.max(min, Math.min(n, max));
};
var assert = function (actual, reason) {
    if (!actual) {
        var message = 'ASSERT: ' + reason;
        console.error(message);
        debugger; // tslint:disable-line
        throw new Error(message);
    }
};
var now = function (ev) {
    return ev.timeStamp || Date.now();
};
var pointerCoord = function (ev) {
    // get X coordinates for either a mouse click
    // or a touch depending on the given event
    if (ev) {
        var changedTouches = ev.changedTouches;
        if (changedTouches && changedTouches.length > 0) {
            var touch = changedTouches[0];
            return { x: touch.clientX, y: touch.clientY };
        }
        if (ev.pageX !== undefined) {
            return { x: ev.pageX, y: ev.pageY };
        }
    }
    return { x: 0, y: 0 };
};
/**
 * @hidden
 * Given a side, return if it should be on the end
 * based on the value of dir
 * @param side the side
 * @param isRTL whether the application dir is rtl
 */
var isEndSide = function (side) {
    var isRTL = document.dir === 'rtl';
    switch (side) {
        case 'start': return isRTL;
        case 'end': return !isRTL;
        default:
            throw new Error("\"" + side + "\" is not a valid value for [side]. Use \"start\" or \"end\" instead.");
    }
};
var debounceEvent = function (event, wait) {
    var original = event._original || event;
    return {
        _original: event,
        emit: debounce(original.emit.bind(original), wait)
    };
};
var debounce = function (func, wait) {
    if (wait === void 0) { wait = 0; }
    var timer;
    return function () {
        var args = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            args[_i] = arguments[_i];
        }
        clearTimeout(timer);
        timer = setTimeout.apply(void 0, [func, wait].concat(args));
    };
};



/***/ }),

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-header-md.entry.js":
/*!*********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-header-md.entry.js ***!
  \*********************************************************************************/
/*! exports provided: ion_header */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_header", function() { return Header; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./helpers-1644482e.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js");
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


var TRANSITION = 'all 0.2s ease-in-out';
var cloneElement = function (tagName) {
    var getCachedEl = document.querySelector(tagName + ".ion-cloned-element");
    if (getCachedEl !== null) {
        return getCachedEl;
    }
    var clonedEl = document.createElement(tagName);
    clonedEl.classList.add('ion-cloned-element');
    clonedEl.style.setProperty('display', 'none');
    document.body.appendChild(clonedEl);
    return clonedEl;
};
var createHeaderIndex = function (headerEl) {
    if (!headerEl) {
        return;
    }
    var toolbars = headerEl.querySelectorAll('ion-toolbar');
    return {
        el: headerEl,
        toolbars: Array.from(toolbars).map(function (toolbar) {
            var ionTitleEl = toolbar.querySelector('ion-title');
            return {
                el: toolbar,
                background: toolbar.shadowRoot.querySelector('.toolbar-background'),
                ionTitleEl: ionTitleEl,
                innerTitleEl: (ionTitleEl) ? ionTitleEl.shadowRoot.querySelector('.toolbar-title') : null,
                ionButtonsEl: Array.from(toolbar.querySelectorAll('ion-buttons')) || []
            };
        }) || [[]]
    };
};
var handleContentScroll = function (scrollEl, scrollHeaderIndex) {
    Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["m"])(function () {
        var scrollTop = scrollEl.scrollTop;
        var scale = Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["c"])(1, 1 + (-scrollTop / 500), 1.1);
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["w"])(function () {
            scaleLargeTitles(scrollHeaderIndex.toolbars, scale);
        });
    });
};
var setToolbarBackgroundOpacity = function (toolbar, opacity) {
    if (opacity === undefined) {
        toolbar.background.style.removeProperty('--opacity');
    }
    else {
        toolbar.background.style.setProperty('--opacity', opacity.toString());
    }
};
var handleToolbarBorderIntersection = function (ev, mainHeaderIndex) {
    if (!ev[0].isIntersecting) {
        return;
    }
    var scale = ((1 - ev[0].intersectionRatio) * 100) / 75;
    setToolbarBackgroundOpacity(mainHeaderIndex.toolbars[0], (scale === 1) ? undefined : scale);
};
/**
 * If toolbars are intersecting, hide the scrollable toolbar content
 * and show the primary toolbar content. If the toolbars are not intersecting,
 * hide the primary toolbar content and show the scrollable toolbar content
 */
var handleToolbarIntersection = function (ev, mainHeaderIndex, scrollHeaderIndex) {
    Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["w"])(function () {
        handleToolbarBorderIntersection(ev, mainHeaderIndex);
        var event = ev[0];
        var intersection = event.intersectionRect;
        var intersectionArea = intersection.width * intersection.height;
        var rootArea = event.rootBounds.width * event.rootBounds.height;
        var isPageHidden = intersectionArea === 0 && rootArea === 0;
        var leftDiff = Math.abs(intersection.left - event.boundingClientRect.left);
        var rightDiff = Math.abs(intersection.right - event.boundingClientRect.right);
        var isPageTransitioning = intersectionArea > 0 && (leftDiff >= 5 || rightDiff >= 5);
        if (isPageHidden || isPageTransitioning) {
            return;
        }
        if (event.isIntersecting) {
            setHeaderActive(mainHeaderIndex, false);
            setHeaderActive(scrollHeaderIndex);
        }
        else {
            /**
             * There is a bug with IntersectionObserver on Safari
             * where `event.isIntersecting === false` when cancelling
             * a swipe to go back gesture. Checking the intersection
             * x, y, width, and height provides a workaround. This bug
             * does not happen when using Safari + Web Animations,
             * only Safari + CSS Animations.
             */
            var hasValidIntersection = (intersection.x === 0 && intersection.y === 0) || (intersection.width !== 0 && intersection.height !== 0);
            if (hasValidIntersection) {
                setHeaderActive(mainHeaderIndex);
                setHeaderActive(scrollHeaderIndex, false);
                setToolbarBackgroundOpacity(mainHeaderIndex.toolbars[0], 1);
            }
        }
    });
};
var setHeaderActive = function (headerIndex, active) {
    if (active === void 0) { active = true; }
    Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["w"])(function () {
        if (active) {
            headerIndex.el.classList.remove('header-collapse-condense-inactive');
        }
        else {
            headerIndex.el.classList.add('header-collapse-condense-inactive');
        }
    });
};
var scaleLargeTitles = function (toolbars, scale, transition) {
    if (toolbars === void 0) { toolbars = []; }
    if (scale === void 0) { scale = 1; }
    if (transition === void 0) { transition = false; }
    toolbars.forEach(function (toolbar) {
        var ionTitle = toolbar.ionTitleEl;
        var titleDiv = toolbar.innerTitleEl;
        if (!ionTitle || ionTitle.size !== 'large') {
            return;
        }
        titleDiv.style.transformOrigin = 'left center';
        titleDiv.style.transition = (transition) ? TRANSITION : '';
        titleDiv.style.transform = "scale3d(" + scale + ", " + scale + ", 1)";
    });
};
var Header = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        this.collapsibleHeaderInitialized = false;
        /**
         * If `true`, the header will be translucent.
         * Only applies when the mode is `"ios"` and the device supports
         * [`backdrop-filter`](https://developer.mozilla.org/en-US/docs/Web/CSS/backdrop-filter#Browser_compatibility).
         *
         * Note: In order to scroll content behind the header, the `fullscreen`
         * attribute needs to be set on the content.
         */
        this.translucent = false;
    }
    class_1.prototype.componentDidLoad = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.checkCollapsibleHeader()];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.componentDidUpdate = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0: return [4 /*yield*/, this.checkCollapsibleHeader()];
                    case 1:
                        _a.sent();
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.componentDidUnload = function () {
        this.destroyCollapsibleHeader();
    };
    class_1.prototype.checkCollapsibleHeader = function () {
        return __awaiter(this, void 0, void 0, function () {
            var hasCollapse, canCollapse, pageEl, contentEl;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        hasCollapse = this.collapse === 'condense';
                        canCollapse = (hasCollapse && Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this) === 'ios') ? hasCollapse : false;
                        if (!(!canCollapse && this.collapsibleHeaderInitialized)) return [3 /*break*/, 1];
                        this.destroyCollapsibleHeader();
                        return [3 /*break*/, 3];
                    case 1:
                        if (!(canCollapse && !this.collapsibleHeaderInitialized)) return [3 /*break*/, 3];
                        pageEl = this.el.closest('ion-app,ion-page,.ion-page,page-inner');
                        contentEl = (pageEl) ? pageEl.querySelector('ion-content') : null;
                        return [4 /*yield*/, this.setupCollapsibleHeader(contentEl, pageEl)];
                    case 2:
                        _a.sent();
                        _a.label = 3;
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.destroyCollapsibleHeader = function () {
        if (this.intersectionObserver) {
            this.intersectionObserver.disconnect();
            this.intersectionObserver = undefined;
        }
        if (this.scrollEl && this.contentScrollCallback) {
            this.scrollEl.removeEventListener('scroll', this.contentScrollCallback);
            this.contentScrollCallback = undefined;
        }
    };
    class_1.prototype.setupCollapsibleHeader = function (contentEl, pageEl) {
        return __awaiter(this, void 0, void 0, function () {
            var _a;
            var _this = this;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        if (!contentEl || !pageEl) {
                            console.error('ion-header requires a content to collapse, make sure there is an ion-content.');
                            return [2 /*return*/];
                        }
                        _a = this;
                        return [4 /*yield*/, contentEl.getScrollElement()];
                    case 1:
                        _a.scrollEl = _b.sent();
                        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["m"])(function () {
                            var headers = pageEl.querySelectorAll('ion-header');
                            var mainHeader = Array.from(headers).find(function (header) { return header.collapse !== 'condense'; });
                            if (!mainHeader || !_this.scrollEl) {
                                return;
                            }
                            var mainHeaderIndex = createHeaderIndex(mainHeader);
                            var scrollHeaderIndex = createHeaderIndex(_this.el);
                            if (!mainHeaderIndex || !scrollHeaderIndex) {
                                return;
                            }
                            setHeaderActive(mainHeaderIndex, false);
                            Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["m"])(function () {
                                var mainHeaderHeight = mainHeaderIndex.el.clientHeight;
                                /**
                                 * Handle interaction between toolbar collapse and
                                 * showing/hiding content in the primary ion-header
                                 * as well as progressively showing/hiding the main header
                                 * border as the top-most toolbar collapses or expands.
                                 */
                                var toolbarIntersection = function (ev) { handleToolbarIntersection(ev, mainHeaderIndex, scrollHeaderIndex); };
                                _this.intersectionObserver = new IntersectionObserver(toolbarIntersection, { threshold: [0.25, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1], rootMargin: "-" + mainHeaderHeight + "px 0px 0px 0px" });
                                _this.intersectionObserver.observe(scrollHeaderIndex.toolbars[0].el);
                            });
                            /**
                             * Handle scaling of large iOS titles and
                             * showing/hiding border on last toolbar
                             * in primary header
                             */
                            _this.contentScrollCallback = function () { handleContentScroll(_this.scrollEl, scrollHeaderIndex); };
                            _this.scrollEl.addEventListener('scroll', _this.contentScrollCallback);
                        });
                        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["w"])(function () {
                            cloneElement('ion-title');
                            cloneElement('ion-back-button');
                        });
                        this.collapsibleHeaderInitialized = true;
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.render = function () {
        var _a;
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        var collapse = this.collapse || 'none';
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { role: "banner", class: (_a = {},
                _a[mode] = true,
                // Used internally for styling
                _a["header-" + mode] = true,
                _a["header-translucent"] = this.translucent,
                _a["header-collapse-" + collapse] = true,
                _a["header-translucent-" + mode] = this.translucent,
                _a) }));
    };
    Object.defineProperty(class_1.prototype, "el", {
        get: function () { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["d"])(this); },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "style", {
        get: function () { return "ion-header{display:block;position:relative;-ms-flex-order:-1;order:-1;width:100%;z-index:10}ion-header ion-toolbar:first-child{padding-top:var(--ion-safe-area-top,0)}.header-md:after{left:0;bottom:-5px;background-position:left 0 top -2px;position:absolute;width:100%;height:5px;background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAHBAMAAADzDtBxAAAAD1BMVEUAAAAAAAAAAAAAAAAAAABPDueNAAAABXRSTlMUCS0gBIh/TXEAAAAaSURBVAjXYxCEAgY4UIICBmMogMsgFLtAAQCNSwXZKOdPxgAAAABJRU5ErkJggg==);background-repeat:repeat-x;content:\"\"}:host-context([dir=rtl]) .header-md:after,[dir=rtl] .header-md:after{left:unset;right:unset;right:0;background-position:right 0 top -2px}.header-collapse-condense,.header-md[no-border]:after{display:none}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());



/***/ })

}]);
//# sourceMappingURL=45.2fd8b5610a2aefb190ae.js.map