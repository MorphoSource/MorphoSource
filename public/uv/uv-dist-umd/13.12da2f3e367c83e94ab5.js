(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[13],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/swipe-back-5ccee2ef.js":
/*!*********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/swipe-back-5ccee2ef.js ***!
  \*********************************************************************************/
/*! exports provided: createSwipeBackGesture */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "createSwipeBackGesture", function() { return createSwipeBackGesture; });
/* harmony import */ var _index_14bae62d_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./index-14bae62d.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-14bae62d.js");

var createSwipeBackGesture = function (el, canStartHandler, onStartHandler, onMoveHandler, onEndHandler) {
    var win = el.ownerDocument.defaultView;
    var canStart = function (detail) {
        return detail.startX <= 50 && canStartHandler();
    };
    var onMove = function (detail) {
        // set the transition animation's progress
        var delta = detail.deltaX;
        var stepValue = delta / win.innerWidth;
        onMoveHandler(stepValue);
    };
    var onEnd = function (detail) {
        // the swipe back gesture has ended
        var delta = detail.deltaX;
        var width = win.innerWidth;
        var stepValue = delta / width;
        var velocity = detail.velocityX;
        var z = width / 2.0;
        var shouldComplete = velocity >= 0 && (velocity > 0.2 || detail.deltaX > z);
        var missing = shouldComplete ? 1 - stepValue : stepValue;
        var missingDistance = missing * width;
        var realDur = 0;
        if (missingDistance > 5) {
            var dur = missingDistance / Math.abs(velocity);
            realDur = Math.min(dur, 540);
        }
        /**
         * TODO: stepValue can sometimes return a negative
         * value, but you can't have a negative time value
         * for the cubic bezier curve (at least with web animations)
         * Not sure if the negative step value is an error or not
         */
        onEndHandler(shouldComplete, (stepValue <= 0) ? 0.01 : stepValue, realDur);
    };
    return Object(_index_14bae62d_js__WEBPACK_IMPORTED_MODULE_0__["createGesture"])({
        el: el,
        gestureName: 'goback-swipe',
        gesturePriority: 40,
        threshold: 10,
        canStart: canStart,
        onStart: onStartHandler,
        onMove: onMove,
        onEnd: onEnd
    });
};



/***/ })

}]);
//# sourceMappingURL=13.12da2f3e367c83e94ab5.js.map