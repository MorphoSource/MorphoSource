(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[48],{

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

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-item-sliding.entry.js":
/*!************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-item-sliding.entry.js ***!
  \************************************************************************************/
/*! exports provided: ion_item_sliding */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_item_sliding", function() { return ItemSliding; });
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


var SWIPE_MARGIN = 30;
var ELASTIC_FACTOR = 0.55;
var openSlidingItem;
var ItemSliding = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        this.item = null;
        this.openAmount = 0;
        this.initialOpenAmount = 0;
        this.optsWidthRightSide = 0;
        this.optsWidthLeftSide = 0;
        this.sides = 0 /* None */;
        this.optsDirty = true;
        this.state = 2 /* Disabled */;
        /**
         * If `true`, the user cannot interact with the sliding item.
         */
        this.disabled = false;
        this.ionDrag = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionDrag", 7);
    }
    class_1.prototype.disabledChanged = function () {
        if (this.gesture) {
            this.gesture.setDisabled(this.disabled);
        }
    };
    class_1.prototype.connectedCallback = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _a;
            var _this = this;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        this.item = this.el.querySelector('ion-item');
                        return [4 /*yield*/, this.updateOptions()];
                    case 1:
                        _b.sent();
                        _a = this;
                        return [4 /*yield*/, __webpack_require__.e(/*! import() */ 2).then(__webpack_require__.bind(null, /*! ./index-14bae62d.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-14bae62d.js"))];
                    case 2:
                        _a.gesture = (_b.sent()).createGesture({
                            el: this.el,
                            gestureName: 'item-swipe',
                            gesturePriority: 100,
                            threshold: 5,
                            canStart: function () { return _this.canStart(); },
                            onStart: function () { return _this.onStart(); },
                            onMove: function (ev) { return _this.onMove(ev); },
                            onEnd: function (ev) { return _this.onEnd(ev); },
                        });
                        this.disabledChanged();
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.disconnectedCallback = function () {
        if (this.gesture) {
            this.gesture.destroy();
            this.gesture = undefined;
        }
        this.item = null;
        this.leftOptions = this.rightOptions = undefined;
        if (openSlidingItem === this.el) {
            openSlidingItem = undefined;
        }
    };
    /**
     * Get the amount the item is open in pixels.
     */
    class_1.prototype.getOpenAmount = function () {
        return Promise.resolve(this.openAmount);
    };
    /**
     * Get the ratio of the open amount of the item compared to the width of the options.
     * If the number returned is positive, then the options on the right side are open.
     * If the number returned is negative, then the options on the left side are open.
     * If the absolute value of the number is greater than 1, the item is open more than
     * the width of the options.
     */
    class_1.prototype.getSlidingRatio = function () {
        return Promise.resolve(this.getSlidingRatioSync());
    };
    /**
     * Open the sliding item.
     *
     * @param side The side of the options to open. If a side is not provided, it will open the first set of options it finds within the item.
     */
    class_1.prototype.open = function (side) {
        return __awaiter(this, void 0, void 0, function () {
            var optionsToOpen, isStartOpen, isEndOpen;
            var _this = this;
            return __generator(this, function (_a) {
                if (this.item === null) {
                    return [2 /*return*/];
                }
                optionsToOpen = this.getOptions(side);
                if (!optionsToOpen) {
                    return [2 /*return*/];
                }
                /**
                 * If side is not set, we need to infer the side
                 * so we know which direction to move the options
                 */
                if (side === undefined) {
                    side = (optionsToOpen === this.leftOptions) ? 'start' : 'end';
                }
                // In RTL we want to switch the sides
                side = Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["i"])(side) ? 'end' : 'start';
                isStartOpen = this.openAmount < 0;
                isEndOpen = this.openAmount > 0;
                /**
                 * If a side is open and a user tries to
                 * re-open the same side, we should not do anything
                 */
                if (isStartOpen && optionsToOpen === this.leftOptions) {
                    return [2 /*return*/];
                }
                if (isEndOpen && optionsToOpen === this.rightOptions) {
                    return [2 /*return*/];
                }
                this.closeOpened();
                this.state = 4 /* Enabled */;
                requestAnimationFrame(function () {
                    _this.calculateOptsWidth();
                    var width = (side === 'end') ? _this.optsWidthRightSide : -_this.optsWidthLeftSide;
                    openSlidingItem = _this.el;
                    _this.setOpenAmount(width, false);
                    _this.state = (side === 'end') ? 8 /* End */ : 16 /* Start */;
                });
                return [2 /*return*/];
            });
        });
    };
    /**
     * Close the sliding item. Items can also be closed from the [List](../../list/List).
     */
    class_1.prototype.close = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this.setOpenAmount(0, true);
                return [2 /*return*/];
            });
        });
    };
    /**
     * Close all of the sliding items in the list. Items can also be closed from the [List](../../list/List).
     */
    class_1.prototype.closeOpened = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                if (openSlidingItem !== undefined) {
                    openSlidingItem.close();
                    openSlidingItem = undefined;
                    return [2 /*return*/, true];
                }
                return [2 /*return*/, false];
            });
        });
    };
    /**
     * Given an optional side, return the ion-item-options element.
     *
     * @param side This side of the options to get. If a side is not provided it will
     * return the first one available.
     */
    class_1.prototype.getOptions = function (side) {
        if (side === undefined) {
            return this.leftOptions || this.rightOptions;
        }
        else if (side === 'start') {
            return this.leftOptions;
        }
        else {
            return this.rightOptions;
        }
    };
    class_1.prototype.updateOptions = function () {
        return __awaiter(this, void 0, void 0, function () {
            var options, sides, i, option, side;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        options = this.el.querySelectorAll('ion-item-options');
                        sides = 0;
                        // Reset left and right options in case they were removed
                        this.leftOptions = this.rightOptions = undefined;
                        i = 0;
                        _a.label = 1;
                    case 1:
                        if (!(i < options.length)) return [3 /*break*/, 4];
                        return [4 /*yield*/, options.item(i).componentOnReady()];
                    case 2:
                        option = _a.sent();
                        side = Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["i"])(option.side) ? 'end' : 'start';
                        if (side === 'start') {
                            this.leftOptions = option;
                            sides |= 1 /* Start */;
                        }
                        else {
                            this.rightOptions = option;
                            sides |= 2 /* End */;
                        }
                        _a.label = 3;
                    case 3:
                        i++;
                        return [3 /*break*/, 1];
                    case 4:
                        this.optsDirty = true;
                        this.sides = sides;
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.canStart = function () {
        var selected = openSlidingItem;
        if (selected && selected !== this.el) {
            this.closeOpened();
            return false;
        }
        return !!(this.rightOptions || this.leftOptions);
    };
    class_1.prototype.onStart = function () {
        openSlidingItem = this.el;
        if (this.tmr !== undefined) {
            clearTimeout(this.tmr);
            this.tmr = undefined;
        }
        if (this.openAmount === 0) {
            this.optsDirty = true;
            this.state = 4 /* Enabled */;
        }
        this.initialOpenAmount = this.openAmount;
        if (this.item) {
            this.item.style.transition = 'none';
        }
    };
    class_1.prototype.onMove = function (gesture) {
        if (this.optsDirty) {
            this.calculateOptsWidth();
        }
        var openAmount = this.initialOpenAmount - gesture.deltaX;
        switch (this.sides) {
            case 2 /* End */:
                openAmount = Math.max(0, openAmount);
                break;
            case 1 /* Start */:
                openAmount = Math.min(0, openAmount);
                break;
            case 3 /* Both */: break;
            case 0 /* None */: return;
            default:
                console.warn('invalid ItemSideFlags value', this.sides);
                break;
        }
        var optsWidth;
        if (openAmount > this.optsWidthRightSide) {
            optsWidth = this.optsWidthRightSide;
            openAmount = optsWidth + (openAmount - optsWidth) * ELASTIC_FACTOR;
        }
        else if (openAmount < -this.optsWidthLeftSide) {
            optsWidth = -this.optsWidthLeftSide;
            openAmount = optsWidth + (openAmount - optsWidth) * ELASTIC_FACTOR;
        }
        this.setOpenAmount(openAmount, false);
    };
    class_1.prototype.onEnd = function (gesture) {
        var velocity = gesture.velocityX;
        var restingPoint = (this.openAmount > 0)
            ? this.optsWidthRightSide
            : -this.optsWidthLeftSide;
        // Check if the drag didn't clear the buttons mid-point
        // and we aren't moving fast enough to swipe open
        var isResetDirection = (this.openAmount > 0) === !(velocity < 0);
        var isMovingFast = Math.abs(velocity) > 0.3;
        var isOnCloseZone = Math.abs(this.openAmount) < Math.abs(restingPoint / 2);
        if (swipeShouldReset(isResetDirection, isMovingFast, isOnCloseZone)) {
            restingPoint = 0;
        }
        var state = this.state;
        this.setOpenAmount(restingPoint, true);
        if ((state & 32 /* SwipeEnd */) !== 0 && this.rightOptions) {
            this.rightOptions.fireSwipeEvent();
        }
        else if ((state & 64 /* SwipeStart */) !== 0 && this.leftOptions) {
            this.leftOptions.fireSwipeEvent();
        }
    };
    class_1.prototype.calculateOptsWidth = function () {
        this.optsWidthRightSide = 0;
        if (this.rightOptions) {
            this.rightOptions.style.display = 'flex';
            this.optsWidthRightSide = this.rightOptions.offsetWidth;
            this.rightOptions.style.display = '';
        }
        this.optsWidthLeftSide = 0;
        if (this.leftOptions) {
            this.leftOptions.style.display = 'flex';
            this.optsWidthLeftSide = this.leftOptions.offsetWidth;
            this.leftOptions.style.display = '';
        }
        this.optsDirty = false;
    };
    class_1.prototype.setOpenAmount = function (openAmount, isFinal) {
        var _this = this;
        if (this.tmr !== undefined) {
            clearTimeout(this.tmr);
            this.tmr = undefined;
        }
        if (!this.item) {
            return;
        }
        var style = this.item.style;
        this.openAmount = openAmount;
        if (isFinal) {
            style.transition = '';
        }
        if (openAmount > 0) {
            this.state = (openAmount >= (this.optsWidthRightSide + SWIPE_MARGIN))
                ? 8 /* End */ | 32 /* SwipeEnd */
                : 8 /* End */;
        }
        else if (openAmount < 0) {
            this.state = (openAmount <= (-this.optsWidthLeftSide - SWIPE_MARGIN))
                ? 16 /* Start */ | 64 /* SwipeStart */
                : 16 /* Start */;
        }
        else {
            this.tmr = setTimeout(function () {
                _this.state = 2 /* Disabled */;
                _this.tmr = undefined;
            }, 600);
            openSlidingItem = undefined;
            style.transform = '';
            return;
        }
        style.transform = "translate3d(" + -openAmount + "px,0,0)";
        this.ionDrag.emit({
            amount: openAmount,
            ratio: this.getSlidingRatioSync()
        });
    };
    class_1.prototype.getSlidingRatioSync = function () {
        if (this.openAmount > 0) {
            return this.openAmount / this.optsWidthRightSide;
        }
        else if (this.openAmount < 0) {
            return this.openAmount / this.optsWidthLeftSide;
        }
        else {
            return 0;
        }
    };
    class_1.prototype.render = function () {
        var _a;
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { class: (_a = {},
                _a[mode] = true,
                _a['item-sliding-active-slide'] = (this.state !== 2 /* Disabled */),
                _a['item-sliding-active-options-end'] = (this.state & 8 /* End */) !== 0,
                _a['item-sliding-active-options-start'] = (this.state & 16 /* Start */) !== 0,
                _a['item-sliding-active-swipe-end'] = (this.state & 32 /* SwipeEnd */) !== 0,
                _a['item-sliding-active-swipe-start'] = (this.state & 64 /* SwipeStart */) !== 0,
                _a) }));
    };
    Object.defineProperty(class_1.prototype, "el", {
        get: function () { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["d"])(this); },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "watchers", {
        get: function () {
            return {
                "disabled": ["disabledChanged"]
            };
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "style", {
        get: function () { return "ion-item-sliding{display:block;position:relative;width:100%;overflow:hidden}ion-item-sliding,ion-item-sliding .item{-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none}.item-sliding-active-slide .item{position:relative;-webkit-transition:-webkit-transform .5s cubic-bezier(.36,.66,.04,1);transition:-webkit-transform .5s cubic-bezier(.36,.66,.04,1);transition:transform .5s cubic-bezier(.36,.66,.04,1);transition:transform .5s cubic-bezier(.36,.66,.04,1),-webkit-transform .5s cubic-bezier(.36,.66,.04,1);opacity:1;z-index:2;pointer-events:none;will-change:transform}.item-sliding-active-swipe-end .item-options-end .item-option-expandable{padding-left:100%;-ms-flex-order:1;order:1;-webkit-transition-duration:.6s;transition-duration:.6s;-webkit-transition-property:padding-left;transition-property:padding-left}:host-context([dir=rtl]) .item-sliding-active-swipe-end .item-options-end .item-option-expandable,[dir=rtl] .item-sliding-active-swipe-end .item-options-end .item-option-expandable{-ms-flex-order:-1;order:-1}.item-sliding-active-swipe-start .item-options-start .item-option-expandable{padding-right:100%;-ms-flex-order:-1;order:-1;-webkit-transition-duration:.6s;transition-duration:.6s;-webkit-transition-property:padding-right;transition-property:padding-right}:host-context([dir=rtl]) .item-sliding-active-swipe-start .item-options-start .item-option-expandable,[dir=rtl] .item-sliding-active-swipe-start .item-options-start .item-option-expandable{-ms-flex-order:1;order:1}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());
var swipeShouldReset = function (isResetDirection, isMovingFast, isOnResetZone) {
    // The logic required to know when the sliding item should close (openAmount=0)
    // depends on three booleans (isResetDirection, isMovingFast, isOnResetZone)
    // and it ended up being too complicated to be written manually without errors
    // so the truth table is attached below: (0=false, 1=true)
    // isResetDirection | isMovingFast | isOnResetZone || shouldClose
    //         0        |       0      |       0       ||    0
    //         0        |       0      |       1       ||    1
    //         0        |       1      |       0       ||    0
    //         0        |       1      |       1       ||    0
    //         1        |       0      |       0       ||    0
    //         1        |       0      |       1       ||    1
    //         1        |       1      |       0       ||    1
    //         1        |       1      |       1       ||    1
    // The resulting expression was generated by resolving the K-map (Karnaugh map):
    return (!isMovingFast && isOnResetZone) || (isResetDirection && isMovingFast);
};



/***/ })

}]);
//# sourceMappingURL=48.72a7e626af70347d881b.js.map