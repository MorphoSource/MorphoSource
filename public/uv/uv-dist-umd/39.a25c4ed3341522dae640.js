(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[39],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/cubic-bezier-287346e4.js":
/*!***********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/cubic-bezier-287346e4.js ***!
  \***********************************************************************************/
/*! exports provided: P, g */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "P", function() { return Point; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "g", function() { return getTimeGivenProgression; });
/**
 * Based on:
 * https://stackoverflow.com/questions/7348009/y-coordinate-for-a-given-x-cubic-bezier
 * https://math.stackexchange.com/questions/26846/is-there-an-explicit-form-for-cubic-b%C3%A9zier-curves
 * TODO: Reduce rounding error
 */
var Point = /** @class */ (function () {
    function Point(x, y) {
        this.x = x;
        this.y = y;
    }
    return Point;
}());
/**
 * Given a cubic-bezier curve, get the x value (time) given
 * the y value (progression).
 * Ex: cubic-bezier(0.32, 0.72, 0, 1);
 * P0: (0, 0)
 * P1: (0.32, 0.72)
 * P2: (0, 1)
 * P3: (1, 1)
 *
 * If you give a cubic bezier curve that never reaches the
 * provided progression, this function will return NaN.
 */
var getTimeGivenProgression = function (p0, p1, p2, p3, progression) {
    var tValues = solveCubicBezier(p0.y, p1.y, p2.y, p3.y, progression);
    return solveCubicParametricEquation(p0.x, p1.x, p2.x, p3.x, tValues[0]); // TODO: Add better strategy for dealing with multiple solutions
};
/**
 * Solve a cubic equation in one dimension (time)
 */
var solveCubicParametricEquation = function (p0, p1, p2, p3, t) {
    var partA = (3 * p1) * Math.pow(t - 1, 2);
    var partB = (-3 * p2 * t) + (3 * p2) + (p3 * t);
    var partC = p0 * Math.pow(t - 1, 3);
    return t * (partA + (t * partB)) - partC;
};
/**
 * Find the `t` value for a cubic bezier using Cardano's formula
 */
var solveCubicBezier = function (p0, p1, p2, p3, refPoint) {
    p0 -= refPoint;
    p1 -= refPoint;
    p2 -= refPoint;
    p3 -= refPoint;
    var roots = solveCubicEquation(p3 - 3 * p2 + 3 * p1 - p0, 3 * p2 - 6 * p1 + 3 * p0, 3 * p1 - 3 * p0, p0);
    return roots.filter(function (root) { return root >= 0 && root <= 1; });
};
var solveQuadraticEquation = function (a, b, c) {
    var discriminant = b * b - 4 * a * c;
    if (discriminant < 0) {
        return [];
    }
    else {
        return [
            (-b + Math.sqrt(discriminant)) / (2 * a),
            (-b - Math.sqrt(discriminant)) / (2 * a)
        ];
    }
};
var solveCubicEquation = function (a, b, c, d) {
    if (a === 0) {
        return solveQuadraticEquation(b, c, d);
    }
    b /= a;
    c /= a;
    d /= a;
    var p = (3 * c - b * b) / 3;
    var q = (2 * b * b * b - 9 * b * c + 27 * d) / 27;
    if (p === 0) {
        return [Math.pow(-q, 1 / 3)];
    }
    else if (q === 0) {
        return [Math.sqrt(-p), -Math.sqrt(-p)];
    }
    var discriminant = Math.pow(q / 2, 2) + Math.pow(p / 3, 3);
    if (discriminant === 0) {
        return [Math.pow(q / 2, 1 / 2) - b / 3];
    }
    else if (discriminant > 0) {
        return [Math.pow(-(q / 2) + Math.sqrt(discriminant), 1 / 3) - Math.pow((q / 2) + Math.sqrt(discriminant), 1 / 3) - b / 3];
    }
    var r = Math.sqrt(Math.pow(-(p / 3), 3));
    var phi = Math.acos(-(q / (2 * Math.sqrt(Math.pow(-(p / 3), 3)))));
    var s = 2 * Math.pow(r, 1 / 3);
    return [
        s * Math.cos(phi / 3) - b / 3,
        s * Math.cos((phi + 2 * Math.PI) / 3) - b / 3,
        s * Math.cos((phi + 4 * Math.PI) / 3) - b / 3
    ];
};



/***/ }),

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-menu-md.entry.js":
/*!*******************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-menu-md.entry.js ***!
  \*******************************************************************************/
/*! exports provided: ion_menu */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_menu", function() { return Menu; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./helpers-1644482e.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js");
/* harmony import */ var _animation_d551500b_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./animation-d551500b.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/animation-d551500b.js");
/* harmony import */ var _cubic_bezier_287346e4_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./cubic-bezier-287346e4.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/cubic-bezier-287346e4.js");
/* harmony import */ var _index_14bae62d_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./index-14bae62d.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-14bae62d.js");
/* harmony import */ var _index_cc681366_js__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./index-cc681366.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-cc681366.js");
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






var Menu = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        this.lastOnEnd = 0;
        this.blocker = _index_14bae62d_js__WEBPACK_IMPORTED_MODULE_4__["GESTURE_CONTROLLER"].createBlocker({ disableScroll: true });
        this.mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        this.isAnimating = false;
        this._isOpen = false;
        this.isPaneVisible = false;
        this.isEndSide = false;
        /**
         * If `true`, the menu is disabled.
         */
        this.disabled = false;
        /**
         * Which side of the view the menu should be placed.
         */
        this.side = 'start';
        /**
         * If `true`, swiping the menu is enabled.
         */
        this.swipeGesture = true;
        /**
         * The edge threshold for dragging the menu open.
         * If a drag/swipe happens over this value, the menu is not triggered.
         */
        this.maxEdgeStart = 50;
        this.ionWillOpen = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionWillOpen", 7);
        this.ionWillClose = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionWillClose", 7);
        this.ionDidOpen = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionDidOpen", 7);
        this.ionDidClose = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionDidClose", 7);
        this.ionMenuChange = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionMenuChange", 7);
    }
    class_1.prototype.typeChanged = function (type, oldType) {
        var contentEl = this.contentEl;
        if (contentEl) {
            if (oldType !== undefined) {
                contentEl.classList.remove("menu-content-" + oldType);
            }
            contentEl.classList.add("menu-content-" + type);
            contentEl.removeAttribute('style');
        }
        if (this.menuInnerEl) {
            // Remove effects of previous animations
            this.menuInnerEl.removeAttribute('style');
        }
        this.animation = undefined;
    };
    class_1.prototype.disabledChanged = function () {
        this.updateState();
        this.ionMenuChange.emit({
            disabled: this.disabled,
            open: this._isOpen
        });
    };
    class_1.prototype.sideChanged = function () {
        this.isEndSide = Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["i"])(this.side);
    };
    class_1.prototype.swipeGestureChanged = function () {
        this.updateState();
    };
    class_1.prototype.connectedCallback = function () {
        return __awaiter(this, void 0, void 0, function () {
            var el, parent, content, _a;
            var _this = this;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        if (this.type === undefined) {
                            this.type = _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["i"].get('menuType', this.mode === 'ios' ? 'reveal' : 'overlay');
                        }
                        el = this.el;
                        parent = el.parentNode;
                        if (this.contentId === undefined) {
                            console.warn("[DEPRECATED][ion-menu] Using the [main] attribute is deprecated, please use the \"contentId\" property instead:\nBEFORE:\n  <ion-menu>...</ion-menu>\n  <div main>...</div>\n\nAFTER:\n  <ion-menu contentId=\"my-content\"></ion-menu>\n  <div id=\"my-content\">...</div>\n");
                        }
                        content = this.contentId !== undefined
                            ? document.getElementById(this.contentId)
                            : parent && parent.querySelector && parent.querySelector('[main]');
                        if (!content || !content.tagName) {
                            // requires content element
                            console.error('Menu: must have a "content" element to listen for drag events on.');
                            return [2 /*return*/];
                        }
                        this.contentEl = content;
                        // add menu's content classes
                        content.classList.add('menu-content');
                        this.typeChanged(this.type, undefined);
                        this.sideChanged();
                        // register this menu with the app's menu controller
                        _index_cc681366_js__WEBPACK_IMPORTED_MODULE_5__["m"]._register(this);
                        _a = this;
                        return [4 /*yield*/, Promise.resolve(/*! import() */).then(__webpack_require__.bind(null, /*! ./index-14bae62d.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-14bae62d.js"))];
                    case 1:
                        _a.gesture = (_b.sent()).createGesture({
                            el: document,
                            gestureName: 'menu-swipe',
                            gesturePriority: 30,
                            threshold: 10,
                            canStart: function (ev) { return _this.canStart(ev); },
                            onWillStart: function () { return _this.onWillStart(); },
                            onStart: function () { return _this.onStart(); },
                            onMove: function (ev) { return _this.onMove(ev); },
                            onEnd: function (ev) { return _this.onEnd(ev); },
                        });
                        this.updateState();
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.componentDidLoad = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                this.ionMenuChange.emit({ disabled: this.disabled, open: this._isOpen });
                this.updateState();
                return [2 /*return*/];
            });
        });
    };
    class_1.prototype.disconnectedCallback = function () {
        this.blocker.destroy();
        _index_cc681366_js__WEBPACK_IMPORTED_MODULE_5__["m"]._unregister(this);
        if (this.animation) {
            this.animation.destroy();
        }
        if (this.gesture) {
            this.gesture.destroy();
            this.gesture = undefined;
        }
        this.animation = undefined;
        this.contentEl = this.backdropEl = this.menuInnerEl = undefined;
    };
    class_1.prototype.onSplitPaneChanged = function (ev) {
        this.isPaneVisible = ev.detail.isPane(this.el);
        this.updateState();
    };
    class_1.prototype.onBackdropClick = function (ev) {
        if (this._isOpen && this.lastOnEnd < ev.timeStamp - 100) {
            var shouldClose = (ev.composedPath)
                ? !ev.composedPath().includes(this.menuInnerEl)
                : false;
            if (shouldClose) {
                ev.preventDefault();
                ev.stopPropagation();
                this.close();
            }
        }
    };
    /**
     * Returns `true` is the menu is open.
     */
    class_1.prototype.isOpen = function () {
        return Promise.resolve(this._isOpen);
    };
    /**
     * Returns `true` is the menu is active.
     *
     * A menu is active when it can be opened or closed, meaning it's enabled
     * and it's not part of a `ion-split-pane`.
     */
    class_1.prototype.isActive = function () {
        return Promise.resolve(this._isActive());
    };
    /**
     * Opens the menu. If the menu is already open or it can't be opened,
     * it returns `false`.
     */
    class_1.prototype.open = function (animated) {
        if (animated === void 0) { animated = true; }
        return this.setOpen(true, animated);
    };
    /**
     * Closes the menu. If the menu is already closed or it can't be closed,
     * it returns `false`.
     */
    class_1.prototype.close = function (animated) {
        if (animated === void 0) { animated = true; }
        return this.setOpen(false, animated);
    };
    /**
     * Toggles the menu. If the menu is already open, it will try to close, otherwise it will try to open it.
     * If the operation can't be completed successfully, it returns `false`.
     */
    class_1.prototype.toggle = function (animated) {
        if (animated === void 0) { animated = true; }
        return this.setOpen(!this._isOpen, animated);
    };
    /**
     * Opens or closes the button.
     * If the operation can't be completed successfully, it returns `false`.
     */
    class_1.prototype.setOpen = function (shouldOpen, animated) {
        if (animated === void 0) { animated = true; }
        return _index_cc681366_js__WEBPACK_IMPORTED_MODULE_5__["m"]._setOpen(this, shouldOpen, animated);
    };
    class_1.prototype._setOpen = function (shouldOpen, animated) {
        if (animated === void 0) { animated = true; }
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        // If the menu is disabled or it is currently being animated, let's do nothing
                        if (!this._isActive() || this.isAnimating || shouldOpen === this._isOpen) {
                            return [2 /*return*/, false];
                        }
                        this.beforeAnimation(shouldOpen);
                        return [4 /*yield*/, this.loadAnimation()];
                    case 1:
                        _a.sent();
                        return [4 /*yield*/, this.startAnimation(shouldOpen, animated)];
                    case 2:
                        _a.sent();
                        this.afterAnimation(shouldOpen);
                        return [2 /*return*/, true];
                }
            });
        });
    };
    class_1.prototype.loadAnimation = function () {
        return __awaiter(this, void 0, void 0, function () {
            var width, _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        width = this.menuInnerEl.offsetWidth;
                        if (width === this.width && this.animation !== undefined) {
                            return [2 /*return*/];
                        }
                        this.width = width;
                        // Destroy existing animation
                        if (this.animation) {
                            this.animation.destroy();
                            this.animation = undefined;
                        }
                        // Create new animation
                        _a = this;
                        return [4 /*yield*/, _index_cc681366_js__WEBPACK_IMPORTED_MODULE_5__["m"]._createAnimation(this.type, this)];
                    case 1:
                        // Create new animation
                        _a.animation = _b.sent();
                        if (!_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["i"].getBoolean('animated', true)) {
                            this.animation.duration(0);
                        }
                        this.animation.fill('both');
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.startAnimation = function (shouldOpen, animated) {
        return __awaiter(this, void 0, void 0, function () {
            var isReversed, ani;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        isReversed = !shouldOpen;
                        ani = this.animation
                            .direction((isReversed) ? 'reverse' : 'normal')
                            .easing((isReversed) ? 'cubic-bezier(0.4, 0.0, 0.6, 1)' : 'cubic-bezier(0.0, 0.0, 0.2, 1)');
                        if (!animated) return [3 /*break*/, 2];
                        return [4 /*yield*/, ani.playAsync()];
                    case 1:
                        _a.sent();
                        return [3 /*break*/, 3];
                    case 2:
                        ani.playSync();
                        _a.label = 3;
                    case 3: return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype._isActive = function () {
        return !this.disabled && !this.isPaneVisible;
    };
    class_1.prototype.canSwipe = function () {
        return this.swipeGesture && !this.isAnimating && this._isActive();
    };
    class_1.prototype.canStart = function (detail) {
        if (!this.canSwipe()) {
            return false;
        }
        if (this._isOpen) {
            return true;
            // TODO error
        }
        else if (_index_cc681366_js__WEBPACK_IMPORTED_MODULE_5__["m"]._getOpenSync()) {
            return false;
        }
        return checkEdgeSide(window, detail.currentX, this.isEndSide, this.maxEdgeStart);
    };
    class_1.prototype.onWillStart = function () {
        this.beforeAnimation(!this._isOpen);
        return this.loadAnimation();
    };
    class_1.prototype.onStart = function () {
        if (!this.isAnimating || !this.animation) {
            Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["b"])(false, 'isAnimating has to be true');
            return;
        }
        // the cloned animation should not use an easing curve during seek
        this.animation
            .direction((this._isOpen) ? 'reverse' : 'normal')
            .progressStart(true);
    };
    class_1.prototype.onMove = function (detail) {
        if (!this.isAnimating || !this.animation) {
            Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["b"])(false, 'isAnimating has to be true');
            return;
        }
        var delta = computeDelta(detail.deltaX, this._isOpen, this.isEndSide);
        var stepValue = delta / this.width;
        this.animation.progressStep(stepValue);
    };
    class_1.prototype.onEnd = function (detail) {
        var _this = this;
        if (!this.isAnimating || !this.animation) {
            Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["b"])(false, 'isAnimating has to be true');
            return;
        }
        var isOpen = this._isOpen;
        var isEndSide = this.isEndSide;
        var delta = computeDelta(detail.deltaX, isOpen, isEndSide);
        var width = this.width;
        var stepValue = delta / width;
        var velocity = detail.velocityX;
        var z = width / 2.0;
        var shouldCompleteRight = velocity >= 0 && (velocity > 0.2 || detail.deltaX > z);
        var shouldCompleteLeft = velocity <= 0 && (velocity < -0.2 || detail.deltaX < -z);
        var shouldComplete = isOpen
            ? isEndSide ? shouldCompleteRight : shouldCompleteLeft
            : isEndSide ? shouldCompleteLeft : shouldCompleteRight;
        var shouldOpen = !isOpen && shouldComplete;
        if (isOpen && !shouldComplete) {
            shouldOpen = true;
        }
        this.lastOnEnd = detail.timeStamp;
        // Account for rounding errors in JS
        var newStepValue = (shouldComplete) ? 0.001 : -0.001;
        /**
         * TODO: stepValue can sometimes return a negative
         * value, but you can't have a negative time value
         * for the cubic bezier curve (at least with web animations)
         * Not sure if the negative step value is an error or not
         */
        var adjustedStepValue = (stepValue <= 0) ? 0.01 : stepValue;
        /**
         * Animation will be reversed here, so need to
         * reverse the easing curve as well
         *
         * Additionally, we need to account for the time relative
         * to the new easing curve, as `stepValue` is going to be given
         * in terms of a linear curve.
         */
        newStepValue += Object(_cubic_bezier_287346e4_js__WEBPACK_IMPORTED_MODULE_3__["g"])(new _cubic_bezier_287346e4_js__WEBPACK_IMPORTED_MODULE_3__["P"](0, 0), new _cubic_bezier_287346e4_js__WEBPACK_IMPORTED_MODULE_3__["P"](0.4, 0), new _cubic_bezier_287346e4_js__WEBPACK_IMPORTED_MODULE_3__["P"](0.6, 1), new _cubic_bezier_287346e4_js__WEBPACK_IMPORTED_MODULE_3__["P"](1, 1), Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["c"])(0, adjustedStepValue, 1));
        this.animation
            .easing('cubic-bezier(0.4, 0.0, 0.6, 1)')
            .onFinish(function () { return _this.afterAnimation(shouldOpen); }, { oneTimeCallback: true })
            .progressEnd(shouldComplete ? 1 : 0, newStepValue, 300);
    };
    class_1.prototype.beforeAnimation = function (shouldOpen) {
        Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["b"])(!this.isAnimating, '_before() should not be called while animating');
        // this places the menu into the correct location before it animates in
        // this css class doesn't actually kick off any animations
        this.el.classList.add(SHOW_MENU);
        if (this.backdropEl) {
            this.backdropEl.classList.add(SHOW_BACKDROP);
        }
        this.blocker.block();
        this.isAnimating = true;
        if (shouldOpen) {
            this.ionWillOpen.emit();
        }
        else {
            this.ionWillClose.emit();
        }
    };
    class_1.prototype.afterAnimation = function (isOpen) {
        Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["b"])(this.isAnimating, '_before() should be called while animating');
        // keep opening/closing the menu disabled for a touch more yet
        // only add listeners/css if it's enabled and isOpen
        // and only remove listeners/css if it's not open
        // emit opened/closed events
        this._isOpen = isOpen;
        this.isAnimating = false;
        if (!this._isOpen) {
            this.blocker.unblock();
        }
        if (isOpen) {
            // add css class
            if (this.contentEl) {
                this.contentEl.classList.add(MENU_CONTENT_OPEN);
            }
            // emit open event
            this.ionDidOpen.emit();
        }
        else {
            // remove css classes
            this.el.classList.remove(SHOW_MENU);
            if (this.contentEl) {
                this.contentEl.classList.remove(MENU_CONTENT_OPEN);
            }
            if (this.backdropEl) {
                this.backdropEl.classList.remove(SHOW_BACKDROP);
            }
            if (this.animation) {
                this.animation.stop();
            }
            // emit close event
            this.ionDidClose.emit();
        }
    };
    class_1.prototype.updateState = function () {
        var isActive = this._isActive();
        if (this.gesture) {
            this.gesture.setDisabled(!isActive || !this.swipeGesture);
        }
        // Close menu immediately
        if (!isActive && this._isOpen) {
            // close if this menu is open, and should not be enabled
            this.forceClosing();
        }
        if (!this.disabled) {
            _index_cc681366_js__WEBPACK_IMPORTED_MODULE_5__["m"]._setActiveMenu(this);
        }
        Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["b"])(!this.isAnimating, 'can not be animating');
    };
    class_1.prototype.forceClosing = function () {
        Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["b"])(this._isOpen, 'menu cannot be closed');
        this.isAnimating = true;
        var ani = this.animation.direction('reverse');
        ani.playSync();
        this.afterAnimation(false);
    };
    class_1.prototype.render = function () {
        var _a;
        var _this = this;
        var _b = this, isEndSide = _b.isEndSide, type = _b.type, disabled = _b.disabled, mode = _b.mode, isPaneVisible = _b.isPaneVisible;
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { role: "navigation", class: (_a = {},
                _a[mode] = true,
                _a["menu-type-" + type] = true,
                _a['menu-enabled'] = !disabled,
                _a['menu-side-end'] = isEndSide,
                _a['menu-side-start'] = !isEndSide,
                _a['menu-pane-visible'] = isPaneVisible,
                _a) }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "menu-inner", ref: function (el) { return _this.menuInnerEl = el; } }, Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("slot", null)), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("ion-backdrop", { ref: function (el) { return _this.backdropEl = el; }, class: "menu-backdrop", tappable: false, stopPropagation: false })));
    };
    Object.defineProperty(class_1.prototype, "el", {
        get: function () { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["d"])(this); },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "watchers", {
        get: function () {
            return {
                "type": ["typeChanged"],
                "disabled": ["disabledChanged"],
                "side": ["sideChanged"],
                "swipeGesture": ["swipeGestureChanged"]
            };
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "style", {
        get: function () { return ":host{--width:304px;--min-width:auto;--max-width:auto;--height:100%;--min-height:auto;--max-height:auto;--background:var(--ion-background-color,#fff);left:0;right:0;top:0;bottom:0;display:none;position:absolute;contain:strict}:host(.show-menu){display:block}.menu-inner{left:0;right:auto;top:0;bottom:0;-webkit-transform:translate3d(-9999px,0,0);transform:translate3d(-9999px,0,0);display:-ms-flexbox;display:flex;position:absolute;-ms-flex-direction:column;flex-direction:column;-ms-flex-pack:justify;justify-content:space-between;width:var(--width);min-width:var(--min-width);max-width:var(--max-width);height:var(--height);min-height:var(--min-height);max-height:var(--max-height);background:var(--background);contain:strict}:host-context([dir=rtl]) .menu-inner,[dir=rtl] .menu-inner{left:unset;right:unset;left:auto;right:0;-webkit-transform:translate3d(calc(-1 * -9999px),0,0);transform:translate3d(calc(-1 * -9999px),0,0)}:host(.menu-side-start) .menu-inner{--ion-safe-area-right:0px;right:auto;left:0}:host(.menu-side-end) .menu-inner{--ion-safe-area-left:0px;right:0;left:auto}ion-backdrop{display:none;opacity:.01;z-index:-1}\@media (max-width:340px){.menu-inner{--width:264px}}:host(.menu-type-reveal){z-index:0}:host(.menu-type-reveal.show-menu) .menu-inner{-webkit-transform:translateZ(0);transform:translateZ(0)}:host(.menu-type-overlay){z-index:1000}:host(.menu-type-overlay) .show-backdrop{display:block;cursor:pointer}:host(.menu-pane-visible) .menu-inner{left:0;right:0;width:auto;-webkit-transform:none!important;transform:none!important;-webkit-box-shadow:none!important;box-shadow:none!important}:host(.menu-pane-visible) ion-backdrop{display:hidden!important}:host(.menu-type-overlay) .menu-inner{-webkit-box-shadow:0 2px 22px 0 rgba(0,0,0,.09),4px 0 16px 0 rgba(0,0,0,.18);box-shadow:0 2px 22px 0 rgba(0,0,0,.09),4px 0 16px 0 rgba(0,0,0,.18)}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());
var computeDelta = function (deltaX, isOpen, isEndSide) {
    return Math.max(0, isOpen !== isEndSide ? -deltaX : deltaX);
};
var checkEdgeSide = function (win, posX, isEndSide, maxEdgeStart) {
    if (isEndSide) {
        return posX >= win.innerWidth - maxEdgeStart;
    }
    else {
        return posX <= maxEdgeStart;
    }
};
var SHOW_MENU = 'show-menu';
var SHOW_BACKDROP = 'show-backdrop';
var MENU_CONTENT_OPEN = 'menu-content-open';



/***/ })

}]);
//# sourceMappingURL=39.a25c4ed3341522dae640.js.map