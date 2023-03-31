(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[22],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/haptic-e2bb9344.js":
/*!*****************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/haptic-e2bb9344.js ***!
  \*****************************************************************************/
/*! exports provided: a, b, c, h */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return hapticSelectionStart; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return hapticSelectionChanged; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return hapticSelectionEnd; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "h", function() { return hapticSelection; });
/**
 * Check to see if the Haptic Plugin is available
 * @return Returns `true` or false if the plugin is available
 */
/**
 * Trigger a selection changed haptic event. Good for one-time events
 * (not for gestures)
 */
var hapticSelection = function () {
    var engine = window.TapticEngine;
    if (engine) {
        engine.selection();
    }
};
/**
 * Tell the haptic engine that a gesture for a selection change is starting.
 */
var hapticSelectionStart = function () {
    var engine = window.TapticEngine;
    if (engine) {
        engine.gestureSelectionStart();
    }
};
/**
 * Tell the haptic engine that a selection changed during a gesture.
 */
var hapticSelectionChanged = function () {
    var engine = window.TapticEngine;
    if (engine) {
        engine.gestureSelectionChanged();
    }
};
/**
 * Tell the haptic engine we are done with a gesture. This needs to be
 * called lest resources are not properly recycled.
 */
var hapticSelectionEnd = function () {
    var engine = window.TapticEngine;
    if (engine) {
        engine.gestureSelectionEnd();
    }
};



/***/ }),

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

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/ion-picker-column-ios.entry.js":
/*!*****************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/ion-picker-column-ios.entry.js ***!
  \*****************************************************************************************/
/*! exports provided: ion_picker_column */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ion_picker_column", function() { return PickerColumnCmp; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./helpers-1644482e.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js");
/* harmony import */ var _haptic_e2bb9344_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./haptic-e2bb9344.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/haptic-e2bb9344.js");
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



var PickerColumnCmp = /** @class */ (function () {
    function class_1(hostRef) {
        Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["r"])(this, hostRef);
        this.optHeight = 0;
        this.rotateFactor = 0;
        this.scaleFactor = 1;
        this.velocity = 0;
        this.y = 0;
        this.noAnimate = true;
        this.ionPickerColChange = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["c"])(this, "ionPickerColChange", 7);
    }
    class_1.prototype.colChanged = function () {
        this.refresh();
    };
    class_1.prototype.connectedCallback = function () {
        return __awaiter(this, void 0, void 0, function () {
            var pickerRotateFactor, pickerScaleFactor, mode, _a;
            var _this = this;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        pickerRotateFactor = 0;
                        pickerScaleFactor = 0.81;
                        mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
                        if (mode === 'ios') {
                            pickerRotateFactor = -0.46;
                            pickerScaleFactor = 1;
                        }
                        this.rotateFactor = pickerRotateFactor;
                        this.scaleFactor = pickerScaleFactor;
                        _a = this;
                        return [4 /*yield*/, __webpack_require__.e(/*! import() */ 2).then(__webpack_require__.bind(null, /*! ./index-14bae62d.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-14bae62d.js"))];
                    case 1:
                        _a.gesture = (_b.sent()).createGesture({
                            el: this.el,
                            gestureName: 'picker-swipe',
                            gesturePriority: 100,
                            threshold: 0,
                            onStart: function (ev) { return _this.onStart(ev); },
                            onMove: function (ev) { return _this.onMove(ev); },
                            onEnd: function (ev) { return _this.onEnd(ev); },
                        });
                        this.gesture.setDisabled(false);
                        this.tmrId = setTimeout(function () {
                            _this.noAnimate = false;
                            _this.refresh(true);
                        }, 250);
                        return [2 /*return*/];
                }
            });
        });
    };
    class_1.prototype.componentDidLoad = function () {
        var colEl = this.optsEl;
        if (colEl) {
            // DOM READ
            // We perfom a DOM read over a rendered item, this needs to happen after the first render
            this.optHeight = (colEl.firstElementChild ? colEl.firstElementChild.clientHeight : 0);
        }
        this.refresh();
    };
    class_1.prototype.disconnectedCallback = function () {
        cancelAnimationFrame(this.rafId);
        clearTimeout(this.tmrId);
        if (this.gesture) {
            this.gesture.destroy();
            this.gesture = undefined;
        }
    };
    class_1.prototype.emitColChange = function () {
        this.ionPickerColChange.emit(this.col);
    };
    class_1.prototype.setSelected = function (selectedIndex, duration) {
        // if there is a selected index, then figure out it's y position
        // if there isn't a selected index, then just use the top y position
        var y = (selectedIndex > -1) ? -(selectedIndex * this.optHeight) : 0;
        this.velocity = 0;
        // set what y position we're at
        cancelAnimationFrame(this.rafId);
        this.update(y, duration, true);
        this.emitColChange();
    };
    class_1.prototype.update = function (y, duration, saveY) {
        if (!this.optsEl) {
            return;
        }
        // ensure we've got a good round number :)
        var translateY = 0;
        var translateZ = 0;
        var _a = this, col = _a.col, rotateFactor = _a.rotateFactor;
        var selectedIndex = col.selectedIndex = this.indexForY(-y);
        var durationStr = (duration === 0) ? '' : duration + 'ms';
        var scaleStr = "scale(" + this.scaleFactor + ")";
        var children = this.optsEl.children;
        for (var i = 0; i < children.length; i++) {
            var button = children[i];
            var opt = col.options[i];
            var optOffset = (i * this.optHeight) + y;
            var transform = '';
            if (rotateFactor !== 0) {
                var rotateX = optOffset * rotateFactor;
                if (Math.abs(rotateX) <= 90) {
                    translateY = 0;
                    translateZ = 90;
                    transform = "rotateX(" + rotateX + "deg) ";
                }
                else {
                    translateY = -9999;
                }
            }
            else {
                translateZ = 0;
                translateY = optOffset;
            }
            var selected = selectedIndex === i;
            transform += "translate3d(0px," + translateY + "px," + translateZ + "px) ";
            if (this.scaleFactor !== 1 && !selected) {
                transform += scaleStr;
            }
            // Update transition duration
            if (this.noAnimate) {
                opt.duration = 0;
                button.style.transitionDuration = '';
            }
            else if (duration !== opt.duration) {
                opt.duration = duration;
                button.style.transitionDuration = durationStr;
            }
            // Update transform
            if (transform !== opt.transform) {
                opt.transform = transform;
                button.style.transform = transform;
            }
            // Update selected item
            if (selected !== opt.selected) {
                opt.selected = selected;
                if (selected) {
                    button.classList.add(PICKER_OPT_SELECTED);
                }
                else {
                    button.classList.remove(PICKER_OPT_SELECTED);
                }
            }
        }
        this.col.prevSelected = selectedIndex;
        if (saveY) {
            this.y = y;
        }
        if (this.lastIndex !== selectedIndex) {
            // have not set a last index yet
            Object(_haptic_e2bb9344_js__WEBPACK_IMPORTED_MODULE_2__["b"])();
            this.lastIndex = selectedIndex;
        }
    };
    class_1.prototype.decelerate = function () {
        var _this = this;
        if (this.velocity !== 0) {
            // still decelerating
            this.velocity *= DECELERATION_FRICTION;
            // do not let it go slower than a velocity of 1
            this.velocity = (this.velocity > 0)
                ? Math.max(this.velocity, 1)
                : Math.min(this.velocity, -1);
            var y = this.y + this.velocity;
            if (y > this.minY) {
                // whoops, it's trying to scroll up farther than the options we have!
                y = this.minY;
                this.velocity = 0;
            }
            else if (y < this.maxY) {
                // gahh, it's trying to scroll down farther than we can!
                y = this.maxY;
                this.velocity = 0;
            }
            this.update(y, 0, true);
            var notLockedIn = (Math.round(y) % this.optHeight !== 0) || (Math.abs(this.velocity) > 1);
            if (notLockedIn) {
                // isn't locked in yet, keep decelerating until it is
                this.rafId = requestAnimationFrame(function () { return _this.decelerate(); });
            }
            else {
                this.velocity = 0;
                this.emitColChange();
            }
        }
        else if (this.y % this.optHeight !== 0) {
            // needs to still get locked into a position so options line up
            var currentPos = Math.abs(this.y % this.optHeight);
            // create a velocity in the direction it needs to scroll
            this.velocity = (currentPos > (this.optHeight / 2) ? 1 : -1);
            this.decelerate();
        }
    };
    class_1.prototype.indexForY = function (y) {
        return Math.min(Math.max(Math.abs(Math.round(y / this.optHeight)), 0), this.col.options.length - 1);
    };
    // TODO should this check disabled?
    class_1.prototype.onStart = function (detail) {
        // We have to prevent default in order to block scrolling under the picker
        // but we DO NOT have to stop propagation, since we still want
        // some "click" events to capture
        detail.event.preventDefault();
        detail.event.stopPropagation();
        // reset everything
        cancelAnimationFrame(this.rafId);
        var options = this.col.options;
        var minY = (options.length - 1);
        var maxY = 0;
        for (var i = 0; i < options.length; i++) {
            if (!options[i].disabled) {
                minY = Math.min(minY, i);
                maxY = Math.max(maxY, i);
            }
        }
        this.minY = -(minY * this.optHeight);
        this.maxY = -(maxY * this.optHeight);
    };
    class_1.prototype.onMove = function (detail) {
        detail.event.preventDefault();
        detail.event.stopPropagation();
        // update the scroll position relative to pointer start position
        var y = this.y + detail.deltaY;
        if (y > this.minY) {
            // scrolling up higher than scroll area
            y = Math.pow(y, 0.8);
            this.bounceFrom = y;
        }
        else if (y < this.maxY) {
            // scrolling down below scroll area
            y += Math.pow(this.maxY - y, 0.9);
            this.bounceFrom = y;
        }
        else {
            this.bounceFrom = 0;
        }
        this.update(y, 0, false);
    };
    class_1.prototype.onEnd = function (detail) {
        if (this.bounceFrom > 0) {
            // bounce back up
            this.update(this.minY, 100, true);
            this.emitColChange();
            return;
        }
        else if (this.bounceFrom < 0) {
            // bounce back down
            this.update(this.maxY, 100, true);
            this.emitColChange();
            return;
        }
        this.velocity = Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["c"])(-MAX_PICKER_SPEED, detail.velocityY * 23, MAX_PICKER_SPEED);
        if (this.velocity === 0 && detail.deltaY === 0) {
            var opt = detail.event.target.closest('.picker-opt');
            if (opt && opt.hasAttribute('opt-index')) {
                this.setSelected(parseInt(opt.getAttribute('opt-index'), 10), TRANSITION_DURATION);
            }
        }
        else {
            this.y += detail.deltaY;
            this.decelerate();
        }
    };
    class_1.prototype.refresh = function (forceRefresh) {
        var min = this.col.options.length - 1;
        var max = 0;
        var options = this.col.options;
        for (var i = 0; i < options.length; i++) {
            if (!options[i].disabled) {
                min = Math.min(min, i);
                max = Math.max(max, i);
            }
        }
        /**
         * Only update selected value if column has a
         * velocity of 0. If it does not, then the
         * column is animating might land on
         * a value different than the value at
         * selectedIndex
         */
        if (this.velocity !== 0) {
            return;
        }
        var selectedIndex = Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__["c"])(min, this.col.selectedIndex || 0, max);
        if (this.col.prevSelected !== selectedIndex || forceRefresh) {
            var y = (selectedIndex * this.optHeight) * -1;
            this.velocity = 0;
            this.update(y, TRANSITION_DURATION, true);
        }
    };
    class_1.prototype.render = function () {
        var _a;
        var _this = this;
        var col = this.col;
        var Button = 'button';
        var mode = Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["f"])(this);
        return (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["H"], { class: (_a = {},
                _a[mode] = true,
                _a['picker-col'] = true,
                _a['picker-opts-left'] = this.col.align === 'left',
                _a['picker-opts-right'] = this.col.align === 'right',
                _a), style: {
                'max-width': this.col.columnWidth
            } }, col.prefix && (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "picker-prefix", style: { width: col.prefixWidth } }, col.prefix)), Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "picker-opts", style: { maxWidth: col.optionsWidth }, ref: function (el) { return _this.optsEl = el; } }, col.options.map(function (o, index) { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])(Button, { type: "button", class: { 'picker-opt': true, 'picker-opt-disabled': !!o.disabled }, "opt-index": index }, o.text); })), col.suffix && (Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["h"])("div", { class: "picker-suffix", style: { width: col.suffixWidth } }, col.suffix))));
    };
    Object.defineProperty(class_1.prototype, "el", {
        get: function () { return Object(_core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__["d"])(this); },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "watchers", {
        get: function () {
            return {
                "col": ["colChanged"]
            };
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(class_1, "style", {
        get: function () { return ".picker-col{display:-ms-flexbox;display:flex;position:relative;-ms-flex:1;flex:1;-ms-flex-pack:center;justify-content:center;height:100%;-webkit-box-sizing:content-box;box-sizing:content-box;contain:content}.picker-opts{position:relative;-ms-flex:1;flex:1;max-width:100%}.picker-opt{left:0;top:0;display:block;position:absolute;width:100%;border:0;text-align:center;text-overflow:ellipsis;white-space:nowrap;contain:strict;overflow:hidden;will-change:transform}:host-context([dir=rtl]) .picker-opt,[dir=rtl] .picker-opt{left:unset;right:unset;right:0}.picker-opt.picker-opt-disabled{pointer-events:none}.picker-opt-disabled{opacity:0}.picker-opts-left{-ms-flex-pack:start;justify-content:flex-start}.picker-opts-right{-ms-flex-pack:end;justify-content:flex-end}.picker-opt:active,.picker-opt:focus{outline:none}.picker-prefix{text-align:end}.picker-prefix,.picker-suffix{position:relative;-ms-flex:1;flex:1;white-space:nowrap}.picker-suffix{text-align:start}.picker-col{padding-left:4px;padding-right:4px;padding-top:0;padding-bottom:0;-webkit-transform-style:preserve-3d;transform-style:preserve-3d}\@supports ((-webkit-margin-start:0) or (margin-inline-start:0)) or (-webkit-margin-start:0){.picker-col{padding-left:unset;padding-right:unset;-webkit-padding-start:4px;padding-inline-start:4px;-webkit-padding-end:4px;padding-inline-end:4px}}.picker-opts,.picker-prefix,.picker-suffix{top:77px;pointer-events:none}.picker-opt,.picker-opts,.picker-prefix,.picker-suffix{-webkit-transform-style:preserve-3d;transform-style:preserve-3d;color:inherit;font-size:20px;line-height:42px}.picker-opt{padding-left:0;padding-right:0;padding-top:0;padding-bottom:0;margin-left:0;margin-right:0;margin-top:0;margin-bottom:0;-webkit-transform-origin:center center;transform-origin:center center;height:46px;-webkit-transition-timing-function:ease-out;transition-timing-function:ease-out;background:transparent;-webkit-backface-visibility:hidden;backface-visibility:hidden;pointer-events:auto}:host-context([dir=rtl]) .picker-opt,[dir=rtl] .picker-opt{-webkit-transform-origin:calc(100% - center) center;transform-origin:calc(100% - center) center}"; },
        enumerable: true,
        configurable: true
    });
    return class_1;
}());
var PICKER_OPT_SELECTED = 'picker-opt-selected';
var DECELERATION_FRICTION = 0.97;
var MAX_PICKER_SPEED = 90;
var TRANSITION_DURATION = 150;



/***/ })

}]);
//# sourceMappingURL=22.590358f95855ca04115b.js.map