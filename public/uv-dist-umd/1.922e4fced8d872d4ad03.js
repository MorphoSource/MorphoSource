(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([[1],{

/***/ "./node_modules/@universalviewer/aleph/dist/esm-es5/animation-d551500b.js":
/*!********************************************************************************!*\
  !*** ./node_modules/@universalviewer/aleph/dist/esm-es5/animation-d551500b.js ***!
  \********************************************************************************/
/*! exports provided: c */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return createAnimation; });
/* harmony import */ var _helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./helpers-1644482e.js */ "./node_modules/@universalviewer/aleph/dist/esm-es5/helpers-1644482e.js");

var setStyleProperty = function (element, propertyName, value) {
    element.style.setProperty(propertyName, value);
};
var removeStyleProperty = function (element, propertyName) {
    element.style.removeProperty(propertyName);
};
var animationEnd = function (el, callback) {
    var unRegTrans;
    var opts = { passive: true };
    var unregister = function () {
        if (unRegTrans) {
            unRegTrans();
        }
    };
    var onTransitionEnd = function (ev) {
        if (el === ev.target) {
            unregister();
            callback(ev);
        }
    };
    if (el) {
        el.addEventListener('webkitAnimationEnd', onTransitionEnd, opts);
        el.addEventListener('animationend', onTransitionEnd, opts);
        unRegTrans = function () {
            el.removeEventListener('webkitAnimationEnd', onTransitionEnd, opts);
            el.removeEventListener('animationend', onTransitionEnd, opts);
        };
    }
    return unregister;
};
var generateKeyframeRules = function (keyframes) {
    if (keyframes === void 0) { keyframes = []; }
    return keyframes.map(function (keyframe) {
        var offset = keyframe.offset;
        var frameString = [];
        for (var property in keyframe) {
            if (keyframe.hasOwnProperty(property) && property !== 'offset') {
                frameString.push(property + ": " + keyframe[property] + ";");
            }
        }
        return offset * 100 + "% { " + frameString.join(' ') + " }";
    }).join(' ');
};
var keyframeIds = [];
var generateKeyframeName = function (keyframeRules) {
    var index = keyframeIds.indexOf(keyframeRules);
    if (index < 0) {
        index = (keyframeIds.push(keyframeRules) - 1);
    }
    return "ion-animation-" + index;
};
var getStyleContainer = function (element) {
    var rootNode = element.getRootNode();
    return (rootNode.head || rootNode);
};
var createKeyframeStylesheet = function (keyframeName, keyframeRules, element) {
    var styleContainer = getStyleContainer(element);
    var existingStylesheet = styleContainer.querySelector('#' + keyframeName);
    if (existingStylesheet) {
        return existingStylesheet;
    }
    var stylesheet = (element.ownerDocument || document).createElement('style');
    stylesheet.id = keyframeName;
    stylesheet.textContent = "@keyframes " + keyframeName + " { " + keyframeRules + " } @keyframes " + keyframeName + "-alt { " + keyframeRules + " }";
    styleContainer.appendChild(stylesheet);
    return stylesheet;
};
var addClassToArray = function (classes, className) {
    if (classes === void 0) { classes = []; }
    if (className !== undefined) {
        var classNameToAppend = (Array.isArray(className)) ? className : [className];
        return classes.concat(classNameToAppend);
    }
    return classes;
};
// TODO: Add more tests. until then, be sure to manually test menu and swipe to go back/routing transitions
var createAnimation = function () {
    var _delay;
    var _duration;
    var _easing;
    var _iterations;
    var _fill;
    var _direction;
    var _keyframes = [];
    var beforeAddClasses = [];
    var beforeRemoveClasses = [];
    var initialized = false;
    var parentAnimation;
    var beforeStylesValue = {};
    var afterAddClasses = [];
    var afterRemoveClasses = [];
    var afterStylesValue = {};
    var numAnimationsRunning = 0;
    var shouldForceLinearEasing = false;
    var shouldForceSyncPlayback = false;
    var cssAnimationsTimerFallback;
    var forceDirectionValue;
    var forceDurationValue;
    var forceDelayValue;
    var willComplete = true;
    var finished = false;
    var shouldCalculateNumAnimations = true;
    var keyframeName;
    var ani;
    var onFinishCallbacks = [];
    var onFinishOneTimeCallbacks = [];
    var elements = [];
    var childAnimations = [];
    var stylesheets = [];
    var _beforeAddReadFunctions = [];
    var _beforeAddWriteFunctions = [];
    var _afterAddReadFunctions = [];
    var _afterAddWriteFunctions = [];
    var webAnimations = [];
    var supportsAnimationEffect = (typeof AnimationEffect === 'function' || typeof window.AnimationEffect === 'function');
    var supportsWebAnimations = (typeof Element === 'function') && (typeof Element.prototype.animate === 'function') && supportsAnimationEffect;
    var ANIMATION_END_FALLBACK_PADDING_MS = 100;
    var getWebAnimations = function () {
        return webAnimations;
    };
    var destroy = function () {
        childAnimations.forEach(function (childAnimation) {
            childAnimation.destroy();
        });
        cleanUp();
        elements.length = 0;
        childAnimations.length = 0;
        _keyframes.length = 0;
        clearOnFinish();
        initialized = false;
        shouldCalculateNumAnimations = true;
        return ani;
    };
    /**
     * Cancels any Web Animations, removes
     * any animation properties from the
     * animation's elements, and removes the
     * animation's stylesheets from the DOM.
     */
    var cleanUp = function () {
        cleanUpElements();
        cleanUpStyleSheets();
    };
    var onFinish = function (callback, opts) {
        var callbacks = (opts && opts.oneTimeCallback) ? onFinishOneTimeCallbacks : onFinishCallbacks;
        callbacks.push({ c: callback, o: opts });
        return ani;
    };
    var clearOnFinish = function () {
        onFinishCallbacks.length = 0;
        onFinishOneTimeCallbacks.length = 0;
        return ani;
    };
    /**
     * Cancels any Web Animations and removes
     * any animation properties from the
     * the animation's elements.
     */
    var cleanUpElements = function () {
        if (supportsWebAnimations) {
            webAnimations.forEach(function (animation) {
                animation.cancel();
            });
            webAnimations.length = 0;
        }
        else {
            var elementsArray_1 = elements.slice();
            Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_0__["a"])(function () {
                elementsArray_1.forEach(function (element) {
                    removeStyleProperty(element, 'animation-name');
                    removeStyleProperty(element, 'animation-duration');
                    removeStyleProperty(element, 'animation-timing-function');
                    removeStyleProperty(element, 'animation-iteration-count');
                    removeStyleProperty(element, 'animation-delay');
                    removeStyleProperty(element, 'animation-play-state');
                    removeStyleProperty(element, 'animation-fill-mode');
                    removeStyleProperty(element, 'animation-direction');
                });
            });
        }
    };
    /**
     * Removes the animation's stylesheets
     * from the DOM.
     */
    var cleanUpStyleSheets = function () {
        stylesheets.forEach(function (stylesheet) {
            /**
             * When sharing stylesheets, it's possible
             * for another animation to have already
             * cleaned up a particular stylesheet
             */
            if (stylesheet && stylesheet.parentNode) {
                stylesheet.parentNode.removeChild(stylesheet);
            }
        });
        stylesheets.length = 0;
    };
    var beforeAddRead = function (readFn) {
        _beforeAddReadFunctions.push(readFn);
        return ani;
    };
    var beforeAddWrite = function (writeFn) {
        _beforeAddWriteFunctions.push(writeFn);
        return ani;
    };
    var afterAddRead = function (readFn) {
        _afterAddReadFunctions.push(readFn);
        return ani;
    };
    var afterAddWrite = function (writeFn) {
        _afterAddWriteFunctions.push(writeFn);
        return ani;
    };
    var beforeAddClass = function (className) {
        beforeAddClasses = addClassToArray(beforeAddClasses, className);
        return ani;
    };
    var beforeRemoveClass = function (className) {
        beforeRemoveClasses = addClassToArray(beforeRemoveClasses, className);
        return ani;
    };
    /**
     * Set CSS inline styles to the animation's
     * elements before the animation begins.
     */
    var beforeStyles = function (styles) {
        if (styles === void 0) { styles = {}; }
        beforeStylesValue = styles;
        return ani;
    };
    /**
     * Clear CSS inline styles from the animation's
     * elements before the animation begins.
     */
    var beforeClearStyles = function (propertyNames) {
        if (propertyNames === void 0) { propertyNames = []; }
        for (var _i = 0, propertyNames_1 = propertyNames; _i < propertyNames_1.length; _i++) {
            var property = propertyNames_1[_i];
            beforeStylesValue[property] = '';
        }
        return ani;
    };
    var afterAddClass = function (className) {
        afterAddClasses = addClassToArray(afterAddClasses, className);
        return ani;
    };
    var afterRemoveClass = function (className) {
        afterRemoveClasses = addClassToArray(afterRemoveClasses, className);
        return ani;
    };
    var afterStyles = function (styles) {
        if (styles === void 0) { styles = {}; }
        afterStylesValue = styles;
        return ani;
    };
    var afterClearStyles = function (propertyNames) {
        if (propertyNames === void 0) { propertyNames = []; }
        for (var _i = 0, propertyNames_2 = propertyNames; _i < propertyNames_2.length; _i++) {
            var property = propertyNames_2[_i];
            afterStylesValue[property] = '';
        }
        return ani;
    };
    var getFill = function () {
        if (_fill !== undefined) {
            return _fill;
        }
        if (parentAnimation) {
            return parentAnimation.getFill();
        }
        return 'both';
    };
    var getDirection = function () {
        if (forceDirectionValue !== undefined) {
            return forceDirectionValue;
        }
        if (_direction !== undefined) {
            return _direction;
        }
        if (parentAnimation) {
            return parentAnimation.getDirection();
        }
        return 'normal';
    };
    var getEasing = function () {
        if (shouldForceLinearEasing) {
            return 'linear';
        }
        if (_easing !== undefined) {
            return _easing;
        }
        if (parentAnimation) {
            return parentAnimation.getEasing();
        }
        return 'linear';
    };
    var getDuration = function () {
        if (shouldForceSyncPlayback) {
            return 0;
        }
        if (forceDurationValue !== undefined) {
            return forceDurationValue;
        }
        if (_duration !== undefined) {
            return _duration;
        }
        if (parentAnimation) {
            return parentAnimation.getDuration();
        }
        return 0;
    };
    var getIterations = function () {
        if (_iterations !== undefined) {
            return _iterations;
        }
        if (parentAnimation) {
            return parentAnimation.getIterations();
        }
        return 1;
    };
    var getDelay = function () {
        if (forceDelayValue !== undefined) {
            return forceDelayValue;
        }
        if (_delay !== undefined) {
            return _delay;
        }
        if (parentAnimation) {
            return parentAnimation.getDelay();
        }
        return 0;
    };
    var getKeyframes = function () {
        return _keyframes;
    };
    var direction = function (animationDirection) {
        _direction = animationDirection;
        update(true);
        return ani;
    };
    var fill = function (animationFill) {
        _fill = animationFill;
        update(true);
        return ani;
    };
    var delay = function (animationDelay) {
        _delay = animationDelay;
        update(true);
        return ani;
    };
    var easing = function (animationEasing) {
        _easing = animationEasing;
        update(true);
        return ani;
    };
    var duration = function (animationDuration) {
        /**
         * CSS Animation Durations of 0ms work fine on Chrome
         * but do not run on Safari, so force it to 1ms to
         * get it to run on both platforms.
         */
        if (!supportsWebAnimations && animationDuration === 0) {
            animationDuration = 1;
        }
        _duration = animationDuration;
        update(true);
        return ani;
    };
    var iterations = function (animationIterations) {
        _iterations = animationIterations;
        update(true);
        return ani;
    };
    var parent = function (animation) {
        parentAnimation = animation;
        return ani;
    };
    var addElement = function (el) {
        if (el != null) {
            if (el.nodeType === 1) {
                elements.push(el);
            }
            else if (el.length >= 0) {
                for (var i = 0; i < el.length; i++) {
                    elements.push(el[i]);
                }
            }
            else {
                console.error('Invalid addElement value');
            }
        }
        return ani;
    };
    var addAnimation = function (animationToAdd) {
        if (animationToAdd != null) {
            if (Array.isArray(animationToAdd)) {
                for (var _i = 0, animationToAdd_1 = animationToAdd; _i < animationToAdd_1.length; _i++) {
                    var animation = animationToAdd_1[_i];
                    animation.parent(ani);
                    childAnimations.push(animation);
                }
            }
            else {
                animationToAdd.parent(ani);
                childAnimations.push(animationToAdd);
            }
        }
        return ani;
    };
    var keyframes = function (keyframeValues) {
        _keyframes = keyframeValues;
        return ani;
    };
    /**
     * Runs all before read callbacks
     */
    var runBeforeRead = function () {
        _beforeAddReadFunctions.forEach(function (callback) {
            callback();
        });
    };
    /**
     * Runs all before write callbacks
     */
    var runBeforeWrite = function () {
        _beforeAddWriteFunctions.forEach(function (callback) {
            callback();
        });
    };
    /**
     * Updates styles and classes before animation runs
     */
    var runBeforeStyles = function () {
        var addClasses = beforeAddClasses;
        var removeClasses = beforeRemoveClasses;
        var styles = beforeStylesValue;
        elements.forEach(function (el) {
            var elementClassList = el.classList;
            addClasses.forEach(function (c) { return elementClassList.add(c); });
            removeClasses.forEach(function (c) { return elementClassList.remove(c); });
            for (var property in styles) {
                if (styles.hasOwnProperty(property)) {
                    setStyleProperty(el, property, styles[property]);
                }
            }
        });
    };
    /**
     * Run all "before" animation hooks.
     */
    var beforeAnimation = function () {
        runBeforeRead();
        runBeforeWrite();
        runBeforeStyles();
    };
    /**
     * Runs all after read callbacks
     */
    var runAfterRead = function () {
        _afterAddReadFunctions.forEach(function (callback) {
            callback();
        });
    };
    /**
     * Runs all after write callbacks
     */
    var runAfterWrite = function () {
        _afterAddWriteFunctions.forEach(function (callback) {
            callback();
        });
    };
    /**
     * Updates styles and classes before animation ends
     */
    var runAfterStyles = function () {
        var addClasses = afterAddClasses;
        var removeClasses = afterRemoveClasses;
        var styles = afterStylesValue;
        elements.forEach(function (el) {
            var elementClassList = el.classList;
            addClasses.forEach(function (c) { return elementClassList.add(c); });
            removeClasses.forEach(function (c) { return elementClassList.remove(c); });
            for (var property in styles) {
                if (styles.hasOwnProperty(property)) {
                    setStyleProperty(el, property, styles[property]);
                }
            }
        });
    };
    /**
     * Run all "after" animation hooks.
     */
    var afterAnimation = function () {
        clearCSSAnimationsTimeout();
        runAfterRead();
        runAfterWrite();
        runAfterStyles();
        var currentStep = willComplete ? 1 : 0;
        onFinishCallbacks.forEach(function (onFinishCallback) {
            return onFinishCallback.c(currentStep, ani);
        });
        onFinishOneTimeCallbacks.forEach(function (onFinishCallback) {
            return onFinishCallback.c(currentStep, ani);
        });
        onFinishOneTimeCallbacks.length = 0;
        shouldCalculateNumAnimations = true;
        finished = true;
    };
    var animationFinish = function () {
        if (numAnimationsRunning === 0) {
            return;
        }
        numAnimationsRunning--;
        if (numAnimationsRunning === 0) {
            afterAnimation();
            if (parentAnimation) {
                parentAnimation.animationFinish();
            }
        }
    };
    var initializeCSSAnimation = function (toggleAnimationName) {
        if (toggleAnimationName === void 0) { toggleAnimationName = true; }
        cleanUpStyleSheets();
        elements.forEach(function (element) {
            if (_keyframes.length > 0) {
                var keyframeRules = generateKeyframeRules(_keyframes);
                keyframeName = generateKeyframeName(keyframeRules);
                var stylesheet_1 = createKeyframeStylesheet(keyframeName, keyframeRules, element);
                stylesheets.push(stylesheet_1);
                setStyleProperty(element, 'animation-duration', getDuration() + "ms");
                setStyleProperty(element, 'animation-timing-function', getEasing());
                setStyleProperty(element, 'animation-delay', getDelay() + "ms");
                setStyleProperty(element, 'animation-fill-mode', getFill());
                setStyleProperty(element, 'animation-direction', getDirection());
                var iterationsCount = (getIterations() === Infinity)
                    ? 'infinite'
                    : getIterations().toString();
                setStyleProperty(element, 'animation-iteration-count', iterationsCount);
                setStyleProperty(element, 'animation-play-state', 'paused');
                if (toggleAnimationName) {
                    setStyleProperty(element, 'animation-name', stylesheet_1.id + "-alt");
                }
                Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_0__["a"])(function () {
                    setStyleProperty(element, 'animation-name', stylesheet_1.id || null);
                });
            }
        });
    };
    var initializeWebAnimation = function () {
        elements.forEach(function (element) {
            var animation = element.animate(_keyframes, {
                delay: getDelay(),
                duration: getDuration(),
                easing: getEasing(),
                iterations: getIterations(),
                fill: getFill(),
                direction: getDirection()
            });
            animation.pause();
            webAnimations.push(animation);
        });
        if (webAnimations.length > 0) {
            webAnimations[0].onfinish = function () {
                animationFinish();
            };
        }
    };
    var initializeAnimation = function (toggleAnimationName) {
        if (toggleAnimationName === void 0) { toggleAnimationName = true; }
        beforeAnimation();
        if (_keyframes.length > 0) {
            if (supportsWebAnimations) {
                initializeWebAnimation();
            }
            else {
                initializeCSSAnimation(toggleAnimationName);
            }
        }
        initialized = true;
    };
    var setAnimationStep = function (step) {
        step = Math.min(Math.max(step, 0), 0.999);
        if (supportsWebAnimations) {
            webAnimations.forEach(function (animation) {
                animation.currentTime = animation.effect.getComputedTiming().delay + (getDuration() * step);
                animation.pause();
            });
        }
        else {
            var animationDelay = getDelay() || 0;
            var animationDuration_1 = "-" + (animationDelay + (getDuration() * step)) + "ms";
            elements.forEach(function (element) {
                if (_keyframes.length > 0) {
                    setStyleProperty(element, 'animation-delay', animationDuration_1);
                    setStyleProperty(element, 'animation-play-state', 'paused');
                }
            });
        }
    };
    var updateWebAnimation = function () {
        webAnimations.forEach(function (animation) {
            animation.effect.updateTiming({
                delay: getDelay(),
                duration: getDuration(),
                easing: getEasing(),
                iterations: getIterations(),
                fill: getFill(),
                direction: getDirection()
            });
        });
    };
    var updateCSSAnimation = function (toggleAnimationName) {
        if (toggleAnimationName === void 0) { toggleAnimationName = true; }
        elements.forEach(function (element) {
            Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_0__["a"])(function () {
                setStyleProperty(element, 'animation-name', keyframeName || null);
                setStyleProperty(element, 'animation-duration', getDuration() + "ms");
                setStyleProperty(element, 'animation-timing-function', getEasing());
                setStyleProperty(element, 'animation-delay', getDelay() + "ms");
                setStyleProperty(element, 'animation-fill-mode', getFill() || null);
                setStyleProperty(element, 'animation-direction', getDirection() || null);
                var iterationsCount = (getIterations() === Infinity)
                    ? 'infinite'
                    : getIterations().toString();
                setStyleProperty(element, 'animation-iteration-count', iterationsCount);
                if (toggleAnimationName) {
                    setStyleProperty(element, 'animation-name', keyframeName + "-alt");
                }
                Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_0__["a"])(function () {
                    setStyleProperty(element, 'animation-name', keyframeName || null);
                });
            });
        });
    };
    var update = function (deep, toggleAnimationName) {
        if (deep === void 0) { deep = false; }
        if (toggleAnimationName === void 0) { toggleAnimationName = true; }
        if (deep) {
            childAnimations.forEach(function (animation) {
                animation.update(deep);
            });
        }
        if (supportsWebAnimations) {
            updateWebAnimation();
        }
        else {
            updateCSSAnimation(toggleAnimationName);
        }
        return ani;
    };
    var progressStart = function (forceLinearEasing) {
        if (forceLinearEasing === void 0) { forceLinearEasing = false; }
        childAnimations.forEach(function (animation) {
            animation.progressStart(forceLinearEasing);
        });
        pauseAnimation();
        shouldForceLinearEasing = forceLinearEasing;
        if (!initialized) {
            initializeAnimation();
        }
        else {
            update();
            setAnimationStep(0);
        }
        return ani;
    };
    var progressStep = function (step) {
        childAnimations.forEach(function (animation) {
            animation.progressStep(step);
        });
        setAnimationStep(step);
        return ani;
    };
    var progressEnd = function (playTo, step, dur) {
        shouldForceLinearEasing = false;
        childAnimations.forEach(function (animation) {
            animation.progressEnd(playTo, step, dur);
        });
        if (dur !== undefined) {
            forceDurationValue = dur;
        }
        finished = false;
        willComplete = playTo === 1;
        if (!willComplete) {
            forceDirectionValue = (getDirection() === 'reverse') ? 'normal' : 'reverse';
            if (supportsWebAnimations) {
                update();
                setAnimationStep(1 - step);
            }
            else {
                forceDelayValue = ((1 - step) * getDuration()) * -1;
                update(false, false);
            }
        }
        else {
            if (!supportsWebAnimations) {
                forceDelayValue = (step * getDuration()) * -1;
                update(false, false);
            }
        }
        onFinish(function () {
            willComplete = true;
            forceDurationValue = undefined;
            forceDirectionValue = undefined;
            forceDelayValue = undefined;
        }, {
            oneTimeCallback: true
        });
        if (!parentAnimation) {
            play();
        }
        return ani;
    };
    var pauseAnimation = function () {
        if (initialized) {
            if (supportsWebAnimations) {
                webAnimations.forEach(function (animation) {
                    animation.pause();
                });
            }
            else {
                elements.forEach(function (element) {
                    setStyleProperty(element, 'animation-play-state', 'paused');
                });
            }
        }
    };
    var pause = function () {
        childAnimations.forEach(function (animation) {
            animation.pause();
        });
        pauseAnimation();
        return ani;
    };
    var playAsync = function () {
        return play();
    };
    var playSync = function () {
        play({ sync: true });
        return ani;
    };
    var onAnimationEndFallback = function () {
        cssAnimationsTimerFallback = undefined;
        animationFinish();
    };
    var clearCSSAnimationsTimeout = function () {
        if (cssAnimationsTimerFallback) {
            clearTimeout(cssAnimationsTimerFallback);
        }
    };
    var playCSSAnimations = function () {
        clearCSSAnimationsTimeout();
        elements.forEach(function (element) {
            if (_keyframes.length > 0) {
                Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_0__["a"])(function () {
                    setStyleProperty(element, 'animation-play-state', 'running');
                });
            }
        });
        if (_keyframes.length === 0 || elements.length === 0) {
            animationFinish();
        }
        else {
            /**
             * This is a catchall in the event that a CSS Animation did not finish.
             * The Web Animations API has mechanisms in place for preventing this.
             * CSS Animations will not fire an `animationend` event
             * for elements with `display: none`. The Web Animations API
             * accounts for this, but using raw CSS Animations requires
             * this workaround.
             */
            var animationDelay = getDelay() || 0;
            var animationDuration = getDuration() || 0;
            var animationIterations = getIterations() || 1;
            cssAnimationsTimerFallback = setTimeout(onAnimationEndFallback, animationDelay + (animationDuration * animationIterations) + ANIMATION_END_FALLBACK_PADDING_MS);
            animationEnd(elements[0], function () {
                clearCSSAnimationsTimeout();
                /**
                 * Ensure that clean up
                 * is always done a frame
                 * before the onFinish handlers
                 * are fired. Otherwise, there
                 * may be flickering if a new
                 * animation is started on the same
                 * element too quickly
                 *
                 * TODO: Is there a cleaner way to do this?
                 */
                Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_0__["a"])(function () {
                    clearCSSAnimationPlayState();
                    Object(_helpers_1644482e_js__WEBPACK_IMPORTED_MODULE_0__["a"])(animationFinish);
                });
            });
        }
    };
    var clearCSSAnimationPlayState = function () {
        elements.forEach(function (element) {
            removeStyleProperty(element, 'animation-duration');
            removeStyleProperty(element, 'animation-delay');
            removeStyleProperty(element, 'animation-play-state');
        });
    };
    var playWebAnimations = function () {
        webAnimations.forEach(function (animation) {
            animation.play();
        });
        if (_keyframes.length === 0 || elements.length === 0) {
            animationFinish();
        }
    };
    var resetAnimation = function () {
        if (supportsWebAnimations) {
            setAnimationStep(0);
        }
        else {
            updateCSSAnimation();
        }
    };
    var play = function (opts) {
        return new Promise(function (resolve) {
            if (opts && opts.sync) {
                shouldForceSyncPlayback = true;
                onFinish(function () { return shouldForceSyncPlayback = false; }, { oneTimeCallback: true });
            }
            if (!initialized) {
                initializeAnimation();
            }
            if (finished) {
                resetAnimation();
                finished = false;
            }
            if (shouldCalculateNumAnimations) {
                numAnimationsRunning = childAnimations.length + 1;
                shouldCalculateNumAnimations = false;
            }
            onFinish(function () { return resolve(); }, { oneTimeCallback: true });
            childAnimations.forEach(function (animation) {
                animation.play();
            });
            if (supportsWebAnimations) {
                playWebAnimations();
            }
            else {
                playCSSAnimations();
            }
        });
    };
    var stop = function () {
        childAnimations.forEach(function (animation) {
            animation.stop();
        });
        if (initialized) {
            cleanUpElements();
            initialized = false;
        }
    };
    var from = function (property, value) {
        var _a;
        var firstFrame = _keyframes[0];
        if (firstFrame !== undefined && firstFrame.offset === 0) {
            firstFrame[property] = value;
        }
        else {
            _keyframes = [
                (_a = { offset: 0 }, _a[property] = value, _a)
            ].concat(_keyframes);
        }
        return ani;
    };
    var to = function (property, value) {
        var _a;
        var lastFrame = _keyframes[_keyframes.length - 1];
        if (lastFrame !== undefined && lastFrame.offset === 1) {
            lastFrame[property] = value;
        }
        else {
            _keyframes = _keyframes.concat([
                (_a = { offset: 1 }, _a[property] = value, _a)
            ]);
        }
        return ani;
    };
    var fromTo = function (property, fromValue, toValue) {
        return from(property, fromValue).to(property, toValue);
    };
    return ani = {
        parentAnimation: parentAnimation,
        elements: elements,
        childAnimations: childAnimations,
        animationFinish: animationFinish,
        from: from,
        to: to,
        fromTo: fromTo,
        parent: parent,
        play: play,
        playAsync: playAsync,
        playSync: playSync,
        pause: pause,
        stop: stop,
        destroy: destroy,
        keyframes: keyframes,
        addAnimation: addAnimation,
        addElement: addElement,
        update: update,
        fill: fill,
        direction: direction,
        iterations: iterations,
        duration: duration,
        easing: easing,
        delay: delay,
        getWebAnimations: getWebAnimations,
        getKeyframes: getKeyframes,
        getFill: getFill,
        getDirection: getDirection,
        getDelay: getDelay,
        getIterations: getIterations,
        getEasing: getEasing,
        getDuration: getDuration,
        afterAddRead: afterAddRead,
        afterAddWrite: afterAddWrite,
        afterClearStyles: afterClearStyles,
        afterStyles: afterStyles,
        afterRemoveClass: afterRemoveClass,
        afterAddClass: afterAddClass,
        beforeAddRead: beforeAddRead,
        beforeAddWrite: beforeAddWrite,
        beforeClearStyles: beforeClearStyles,
        beforeStyles: beforeStyles,
        beforeRemoveClass: beforeRemoveClass,
        beforeAddClass: beforeAddClass,
        onFinish: onFinish,
        progressStart: progressStart,
        progressStep: progressStep,
        progressEnd: progressEnd
    };
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



/***/ })

}]);
//# sourceMappingURL=1.922e4fced8d872d4ad03.js.map