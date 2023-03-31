(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[146],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/md.transition-93bb0365.js":
/*!************************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/md.transition-93bb0365.js ***!
  \************************************************************************************/
/*! exports provided: mdTransitionAnimation */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "mdTransitionAnimation", function() { return mdTransitionAnimation; });
/* harmony import */ var _core_684c60cc_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./core-684c60cc.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/core-684c60cc.js");
/* harmony import */ var _helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./helpers-1644482e.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js");
/* harmony import */ var _animation_d551500b_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./animation-d551500b.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/animation-d551500b.js");
/* harmony import */ var _index_f1ea188f_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./index-f1ea188f.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/index-f1ea188f.js");




var mdTransitionAnimation = function (_, opts) {
    var OFF_BOTTOM = '40px';
    var CENTER = '0px';
    var backDirection = (opts.direction === 'back');
    var enteringEl = opts.enteringEl;
    var leavingEl = opts.leavingEl;
    var ionPageElement = Object(_index_f1ea188f_js__WEBPACK_IMPORTED_MODULE_3__["g"])(enteringEl);
    var enteringToolbarEle = ionPageElement.querySelector('ion-toolbar');
    var rootTransition = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_2__["c"])();
    rootTransition
        .addElement(ionPageElement)
        .fill('both')
        .beforeRemoveClass('ion-page-invisible');
    // animate the component itself
    if (backDirection) {
        rootTransition
            .duration(opts.duration || 200)
            .easing('cubic-bezier(0.47,0,0.745,0.715)');
    }
    else {
        rootTransition
            .duration(opts.duration || 280)
            .easing('cubic-bezier(0.36,0.66,0.04,1)')
            .fromTo('transform', "translateY(" + OFF_BOTTOM + ")", "translateY(" + CENTER + ")")
            .fromTo('opacity', 0.01, 1);
    }
    // Animate toolbar if it's there
    if (enteringToolbarEle) {
        var enteringToolBar = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_2__["c"])();
        enteringToolBar.addElement(enteringToolbarEle);
        rootTransition.addAnimation(enteringToolBar);
    }
    // setup leaving view
    if (leavingEl && backDirection) {
        // leaving content
        rootTransition
            .duration(opts.duration || 200)
            .easing('cubic-bezier(0.47,0,0.745,0.715)');
        var leavingPage = Object(_animation_d551500b_js__WEBPACK_IMPORTED_MODULE_2__["c"])();
        leavingPage
            .addElement(Object(_index_f1ea188f_js__WEBPACK_IMPORTED_MODULE_3__["g"])(leavingEl))
            .afterStyles({ 'display': 'none' })
            .fromTo('transform', "translateY(" + CENTER + ")", "translateY(" + OFF_BOTTOM + ")")
            .fromTo('opacity', 1, 0);
        rootTransition.addAnimation(leavingPage);
    }
    return rootTransition;
};



/***/ })

}]);
//# sourceMappingURL=146.2ef4a184361b953c2a71.js.map