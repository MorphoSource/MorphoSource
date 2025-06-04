/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/packs/";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./app/javascript/packs/application.js");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./app/javascript/packs/application.js":
/*!*********************************************!*\
  !*** ./app/javascript/packs/application.js ***!
  \*********************************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var actiontext__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! actiontext */ "./node_modules/actiontext/app/javascript/actiontext/index.js");
/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)



/***/ }),

/***/ "./node_modules/actiontext/app/javascript/actiontext/attachment_upload.js":
/*!********************************************************************************!*\
  !*** ./node_modules/actiontext/app/javascript/actiontext/attachment_upload.js ***!
  \********************************************************************************/
/*! exports provided: AttachmentUpload */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "AttachmentUpload", function() { return AttachmentUpload; });
/* harmony import */ var activestorage__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! activestorage */ "./node_modules/activestorage/app/assets/javascripts/activestorage.js");
/* harmony import */ var activestorage__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(activestorage__WEBPACK_IMPORTED_MODULE_0__);
function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
function _classCallCheck(a, n) { if (!(a instanceof n)) throw new TypeError("Cannot call a class as a function"); }
function _defineProperties(e, r) { for (var t = 0; t < r.length; t++) { var o = r[t]; o.enumerable = o.enumerable || !1, o.configurable = !0, "value" in o && (o.writable = !0), Object.defineProperty(e, _toPropertyKey(o.key), o); } }
function _createClass(e, r, t) { return r && _defineProperties(e.prototype, r), t && _defineProperties(e, t), Object.defineProperty(e, "prototype", { writable: !1 }), e; }
function _toPropertyKey(t) { var i = _toPrimitive(t, "string"); return "symbol" == _typeof(i) ? i : i + ""; }
function _toPrimitive(t, r) { if ("object" != _typeof(t) || !t) return t; var e = t[Symbol.toPrimitive]; if (void 0 !== e) { var i = e.call(t, r || "default"); if ("object" != _typeof(i)) return i; throw new TypeError("@@toPrimitive must return a primitive value."); } return ("string" === r ? String : Number)(t); }

var AttachmentUpload = /*#__PURE__*/function () {
  function AttachmentUpload(attachment, element) {
    _classCallCheck(this, AttachmentUpload);
    this.attachment = attachment;
    this.element = element;
    this.directUpload = new activestorage__WEBPACK_IMPORTED_MODULE_0__["DirectUpload"](attachment.file, this.directUploadUrl, this);
  }
  return _createClass(AttachmentUpload, [{
    key: "start",
    value: function start() {
      this.directUpload.create(this.directUploadDidComplete.bind(this));
    }
  }, {
    key: "directUploadWillStoreFileWithXHR",
    value: function directUploadWillStoreFileWithXHR(xhr) {
      var _this = this;
      xhr.upload.addEventListener("progress", function (event) {
        var progress = event.loaded / event.total * 100;
        _this.attachment.setUploadProgress(progress);
      });
    }
  }, {
    key: "directUploadDidComplete",
    value: function directUploadDidComplete(error, attributes) {
      if (error) {
        throw new Error("Direct upload failed: ".concat(error));
      }
      this.attachment.setAttributes({
        sgid: attributes.attachable_sgid,
        url: this.createBlobUrl(attributes.signed_id, attributes.filename)
      });
    }
  }, {
    key: "createBlobUrl",
    value: function createBlobUrl(signedId, filename) {
      return this.blobUrlTemplate.replace(":signed_id", signedId).replace(":filename", encodeURIComponent(filename));
    }
  }, {
    key: "directUploadUrl",
    get: function get() {
      return this.element.dataset.directUploadUrl;
    }
  }, {
    key: "blobUrlTemplate",
    get: function get() {
      return this.element.dataset.blobUrlTemplate;
    }
  }]);
}();

/***/ }),

/***/ "./node_modules/actiontext/app/javascript/actiontext/index.js":
/*!********************************************************************!*\
  !*** ./node_modules/actiontext/app/javascript/actiontext/index.js ***!
  \********************************************************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var trix__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! trix */ "./node_modules/trix/dist/trix.esm.min.js");
/* harmony import */ var _attachment_upload__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./attachment_upload */ "./node_modules/actiontext/app/javascript/actiontext/attachment_upload.js");


addEventListener("trix-attachment-add", function (event) {
  var attachment = event.attachment,
    target = event.target;
  if (attachment.file) {
    var upload = new _attachment_upload__WEBPACK_IMPORTED_MODULE_1__["AttachmentUpload"](attachment, target);
    upload.start();
  }
});

/***/ }),

/***/ "./node_modules/activestorage/app/assets/javascripts/activestorage.js":
/*!****************************************************************************!*\
  !*** ./node_modules/activestorage/app/assets/javascripts/activestorage.js ***!
  \****************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
(function (global, factory) {
  ( false ? undefined : _typeof(exports)) === "object" && typeof module !== "undefined" ? factory(exports) :  true ? !(__WEBPACK_AMD_DEFINE_ARRAY__ = [exports], __WEBPACK_AMD_DEFINE_FACTORY__ = (factory),
				__WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ?
				(__WEBPACK_AMD_DEFINE_FACTORY__.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__)) : __WEBPACK_AMD_DEFINE_FACTORY__),
				__WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__)) : undefined;
})(this, function (exports) {
  "use strict";

  function createCommonjsModule(fn, module) {
    return module = {
      exports: {}
    }, fn(module, module.exports), module.exports;
  }
  var sparkMd5 = createCommonjsModule(function (module, exports) {
    (function (factory) {
      {
        module.exports = factory();
      }
    })(function (undefined) {
      var hex_chr = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"];
      function md5cycle(x, k) {
        var a = x[0],
          b = x[1],
          c = x[2],
          d = x[3];
        a += (b & c | ~b & d) + k[0] - 680876936 | 0;
        a = (a << 7 | a >>> 25) + b | 0;
        d += (a & b | ~a & c) + k[1] - 389564586 | 0;
        d = (d << 12 | d >>> 20) + a | 0;
        c += (d & a | ~d & b) + k[2] + 606105819 | 0;
        c = (c << 17 | c >>> 15) + d | 0;
        b += (c & d | ~c & a) + k[3] - 1044525330 | 0;
        b = (b << 22 | b >>> 10) + c | 0;
        a += (b & c | ~b & d) + k[4] - 176418897 | 0;
        a = (a << 7 | a >>> 25) + b | 0;
        d += (a & b | ~a & c) + k[5] + 1200080426 | 0;
        d = (d << 12 | d >>> 20) + a | 0;
        c += (d & a | ~d & b) + k[6] - 1473231341 | 0;
        c = (c << 17 | c >>> 15) + d | 0;
        b += (c & d | ~c & a) + k[7] - 45705983 | 0;
        b = (b << 22 | b >>> 10) + c | 0;
        a += (b & c | ~b & d) + k[8] + 1770035416 | 0;
        a = (a << 7 | a >>> 25) + b | 0;
        d += (a & b | ~a & c) + k[9] - 1958414417 | 0;
        d = (d << 12 | d >>> 20) + a | 0;
        c += (d & a | ~d & b) + k[10] - 42063 | 0;
        c = (c << 17 | c >>> 15) + d | 0;
        b += (c & d | ~c & a) + k[11] - 1990404162 | 0;
        b = (b << 22 | b >>> 10) + c | 0;
        a += (b & c | ~b & d) + k[12] + 1804603682 | 0;
        a = (a << 7 | a >>> 25) + b | 0;
        d += (a & b | ~a & c) + k[13] - 40341101 | 0;
        d = (d << 12 | d >>> 20) + a | 0;
        c += (d & a | ~d & b) + k[14] - 1502002290 | 0;
        c = (c << 17 | c >>> 15) + d | 0;
        b += (c & d | ~c & a) + k[15] + 1236535329 | 0;
        b = (b << 22 | b >>> 10) + c | 0;
        a += (b & d | c & ~d) + k[1] - 165796510 | 0;
        a = (a << 5 | a >>> 27) + b | 0;
        d += (a & c | b & ~c) + k[6] - 1069501632 | 0;
        d = (d << 9 | d >>> 23) + a | 0;
        c += (d & b | a & ~b) + k[11] + 643717713 | 0;
        c = (c << 14 | c >>> 18) + d | 0;
        b += (c & a | d & ~a) + k[0] - 373897302 | 0;
        b = (b << 20 | b >>> 12) + c | 0;
        a += (b & d | c & ~d) + k[5] - 701558691 | 0;
        a = (a << 5 | a >>> 27) + b | 0;
        d += (a & c | b & ~c) + k[10] + 38016083 | 0;
        d = (d << 9 | d >>> 23) + a | 0;
        c += (d & b | a & ~b) + k[15] - 660478335 | 0;
        c = (c << 14 | c >>> 18) + d | 0;
        b += (c & a | d & ~a) + k[4] - 405537848 | 0;
        b = (b << 20 | b >>> 12) + c | 0;
        a += (b & d | c & ~d) + k[9] + 568446438 | 0;
        a = (a << 5 | a >>> 27) + b | 0;
        d += (a & c | b & ~c) + k[14] - 1019803690 | 0;
        d = (d << 9 | d >>> 23) + a | 0;
        c += (d & b | a & ~b) + k[3] - 187363961 | 0;
        c = (c << 14 | c >>> 18) + d | 0;
        b += (c & a | d & ~a) + k[8] + 1163531501 | 0;
        b = (b << 20 | b >>> 12) + c | 0;
        a += (b & d | c & ~d) + k[13] - 1444681467 | 0;
        a = (a << 5 | a >>> 27) + b | 0;
        d += (a & c | b & ~c) + k[2] - 51403784 | 0;
        d = (d << 9 | d >>> 23) + a | 0;
        c += (d & b | a & ~b) + k[7] + 1735328473 | 0;
        c = (c << 14 | c >>> 18) + d | 0;
        b += (c & a | d & ~a) + k[12] - 1926607734 | 0;
        b = (b << 20 | b >>> 12) + c | 0;
        a += (b ^ c ^ d) + k[5] - 378558 | 0;
        a = (a << 4 | a >>> 28) + b | 0;
        d += (a ^ b ^ c) + k[8] - 2022574463 | 0;
        d = (d << 11 | d >>> 21) + a | 0;
        c += (d ^ a ^ b) + k[11] + 1839030562 | 0;
        c = (c << 16 | c >>> 16) + d | 0;
        b += (c ^ d ^ a) + k[14] - 35309556 | 0;
        b = (b << 23 | b >>> 9) + c | 0;
        a += (b ^ c ^ d) + k[1] - 1530992060 | 0;
        a = (a << 4 | a >>> 28) + b | 0;
        d += (a ^ b ^ c) + k[4] + 1272893353 | 0;
        d = (d << 11 | d >>> 21) + a | 0;
        c += (d ^ a ^ b) + k[7] - 155497632 | 0;
        c = (c << 16 | c >>> 16) + d | 0;
        b += (c ^ d ^ a) + k[10] - 1094730640 | 0;
        b = (b << 23 | b >>> 9) + c | 0;
        a += (b ^ c ^ d) + k[13] + 681279174 | 0;
        a = (a << 4 | a >>> 28) + b | 0;
        d += (a ^ b ^ c) + k[0] - 358537222 | 0;
        d = (d << 11 | d >>> 21) + a | 0;
        c += (d ^ a ^ b) + k[3] - 722521979 | 0;
        c = (c << 16 | c >>> 16) + d | 0;
        b += (c ^ d ^ a) + k[6] + 76029189 | 0;
        b = (b << 23 | b >>> 9) + c | 0;
        a += (b ^ c ^ d) + k[9] - 640364487 | 0;
        a = (a << 4 | a >>> 28) + b | 0;
        d += (a ^ b ^ c) + k[12] - 421815835 | 0;
        d = (d << 11 | d >>> 21) + a | 0;
        c += (d ^ a ^ b) + k[15] + 530742520 | 0;
        c = (c << 16 | c >>> 16) + d | 0;
        b += (c ^ d ^ a) + k[2] - 995338651 | 0;
        b = (b << 23 | b >>> 9) + c | 0;
        a += (c ^ (b | ~d)) + k[0] - 198630844 | 0;
        a = (a << 6 | a >>> 26) + b | 0;
        d += (b ^ (a | ~c)) + k[7] + 1126891415 | 0;
        d = (d << 10 | d >>> 22) + a | 0;
        c += (a ^ (d | ~b)) + k[14] - 1416354905 | 0;
        c = (c << 15 | c >>> 17) + d | 0;
        b += (d ^ (c | ~a)) + k[5] - 57434055 | 0;
        b = (b << 21 | b >>> 11) + c | 0;
        a += (c ^ (b | ~d)) + k[12] + 1700485571 | 0;
        a = (a << 6 | a >>> 26) + b | 0;
        d += (b ^ (a | ~c)) + k[3] - 1894986606 | 0;
        d = (d << 10 | d >>> 22) + a | 0;
        c += (a ^ (d | ~b)) + k[10] - 1051523 | 0;
        c = (c << 15 | c >>> 17) + d | 0;
        b += (d ^ (c | ~a)) + k[1] - 2054922799 | 0;
        b = (b << 21 | b >>> 11) + c | 0;
        a += (c ^ (b | ~d)) + k[8] + 1873313359 | 0;
        a = (a << 6 | a >>> 26) + b | 0;
        d += (b ^ (a | ~c)) + k[15] - 30611744 | 0;
        d = (d << 10 | d >>> 22) + a | 0;
        c += (a ^ (d | ~b)) + k[6] - 1560198380 | 0;
        c = (c << 15 | c >>> 17) + d | 0;
        b += (d ^ (c | ~a)) + k[13] + 1309151649 | 0;
        b = (b << 21 | b >>> 11) + c | 0;
        a += (c ^ (b | ~d)) + k[4] - 145523070 | 0;
        a = (a << 6 | a >>> 26) + b | 0;
        d += (b ^ (a | ~c)) + k[11] - 1120210379 | 0;
        d = (d << 10 | d >>> 22) + a | 0;
        c += (a ^ (d | ~b)) + k[2] + 718787259 | 0;
        c = (c << 15 | c >>> 17) + d | 0;
        b += (d ^ (c | ~a)) + k[9] - 343485551 | 0;
        b = (b << 21 | b >>> 11) + c | 0;
        x[0] = a + x[0] | 0;
        x[1] = b + x[1] | 0;
        x[2] = c + x[2] | 0;
        x[3] = d + x[3] | 0;
      }
      function md5blk(s) {
        var md5blks = [],
          i;
        for (i = 0; i < 64; i += 4) {
          md5blks[i >> 2] = s.charCodeAt(i) + (s.charCodeAt(i + 1) << 8) + (s.charCodeAt(i + 2) << 16) + (s.charCodeAt(i + 3) << 24);
        }
        return md5blks;
      }
      function md5blk_array(a) {
        var md5blks = [],
          i;
        for (i = 0; i < 64; i += 4) {
          md5blks[i >> 2] = a[i] + (a[i + 1] << 8) + (a[i + 2] << 16) + (a[i + 3] << 24);
        }
        return md5blks;
      }
      function md51(s) {
        var n = s.length,
          state = [1732584193, -271733879, -1732584194, 271733878],
          i,
          length,
          tail,
          tmp,
          lo,
          hi;
        for (i = 64; i <= n; i += 64) {
          md5cycle(state, md5blk(s.substring(i - 64, i)));
        }
        s = s.substring(i - 64);
        length = s.length;
        tail = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        for (i = 0; i < length; i += 1) {
          tail[i >> 2] |= s.charCodeAt(i) << (i % 4 << 3);
        }
        tail[i >> 2] |= 128 << (i % 4 << 3);
        if (i > 55) {
          md5cycle(state, tail);
          for (i = 0; i < 16; i += 1) {
            tail[i] = 0;
          }
        }
        tmp = n * 8;
        tmp = tmp.toString(16).match(/(.*?)(.{0,8})$/);
        lo = parseInt(tmp[2], 16);
        hi = parseInt(tmp[1], 16) || 0;
        tail[14] = lo;
        tail[15] = hi;
        md5cycle(state, tail);
        return state;
      }
      function md51_array(a) {
        var n = a.length,
          state = [1732584193, -271733879, -1732584194, 271733878],
          i,
          length,
          tail,
          tmp,
          lo,
          hi;
        for (i = 64; i <= n; i += 64) {
          md5cycle(state, md5blk_array(a.subarray(i - 64, i)));
        }
        a = i - 64 < n ? a.subarray(i - 64) : new Uint8Array(0);
        length = a.length;
        tail = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        for (i = 0; i < length; i += 1) {
          tail[i >> 2] |= a[i] << (i % 4 << 3);
        }
        tail[i >> 2] |= 128 << (i % 4 << 3);
        if (i > 55) {
          md5cycle(state, tail);
          for (i = 0; i < 16; i += 1) {
            tail[i] = 0;
          }
        }
        tmp = n * 8;
        tmp = tmp.toString(16).match(/(.*?)(.{0,8})$/);
        lo = parseInt(tmp[2], 16);
        hi = parseInt(tmp[1], 16) || 0;
        tail[14] = lo;
        tail[15] = hi;
        md5cycle(state, tail);
        return state;
      }
      function rhex(n) {
        var s = "",
          j;
        for (j = 0; j < 4; j += 1) {
          s += hex_chr[n >> j * 8 + 4 & 15] + hex_chr[n >> j * 8 & 15];
        }
        return s;
      }
      function hex(x) {
        var i;
        for (i = 0; i < x.length; i += 1) {
          x[i] = rhex(x[i]);
        }
        return x.join("");
      }
      if (hex(md51("hello")) !== "5d41402abc4b2a76b9719d911017c592") ;
      if (typeof ArrayBuffer !== "undefined" && !ArrayBuffer.prototype.slice) {
        (function () {
          function clamp(val, length) {
            val = val | 0 || 0;
            if (val < 0) {
              return Math.max(val + length, 0);
            }
            return Math.min(val, length);
          }
          ArrayBuffer.prototype.slice = function (from, to) {
            var length = this.byteLength,
              begin = clamp(from, length),
              end = length,
              num,
              target,
              targetArray,
              sourceArray;
            if (to !== undefined) {
              end = clamp(to, length);
            }
            if (begin > end) {
              return new ArrayBuffer(0);
            }
            num = end - begin;
            target = new ArrayBuffer(num);
            targetArray = new Uint8Array(target);
            sourceArray = new Uint8Array(this, begin, num);
            targetArray.set(sourceArray);
            return target;
          };
        })();
      }
      function toUtf8(str) {
        if (/[\u0080-\uFFFF]/.test(str)) {
          str = unescape(encodeURIComponent(str));
        }
        return str;
      }
      function utf8Str2ArrayBuffer(str, returnUInt8Array) {
        var length = str.length,
          buff = new ArrayBuffer(length),
          arr = new Uint8Array(buff),
          i;
        for (i = 0; i < length; i += 1) {
          arr[i] = str.charCodeAt(i);
        }
        return returnUInt8Array ? arr : buff;
      }
      function arrayBuffer2Utf8Str(buff) {
        return String.fromCharCode.apply(null, new Uint8Array(buff));
      }
      function concatenateArrayBuffers(first, second, returnUInt8Array) {
        var result = new Uint8Array(first.byteLength + second.byteLength);
        result.set(new Uint8Array(first));
        result.set(new Uint8Array(second), first.byteLength);
        return returnUInt8Array ? result : result.buffer;
      }
      function hexToBinaryString(hex) {
        var bytes = [],
          length = hex.length,
          x;
        for (x = 0; x < length - 1; x += 2) {
          bytes.push(parseInt(hex.substr(x, 2), 16));
        }
        return String.fromCharCode.apply(String, bytes);
      }
      function SparkMD5() {
        this.reset();
      }
      SparkMD5.prototype.append = function (str) {
        this.appendBinary(toUtf8(str));
        return this;
      };
      SparkMD5.prototype.appendBinary = function (contents) {
        this._buff += contents;
        this._length += contents.length;
        var length = this._buff.length,
          i;
        for (i = 64; i <= length; i += 64) {
          md5cycle(this._hash, md5blk(this._buff.substring(i - 64, i)));
        }
        this._buff = this._buff.substring(i - 64);
        return this;
      };
      SparkMD5.prototype.end = function (raw) {
        var buff = this._buff,
          length = buff.length,
          i,
          tail = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          ret;
        for (i = 0; i < length; i += 1) {
          tail[i >> 2] |= buff.charCodeAt(i) << (i % 4 << 3);
        }
        this._finish(tail, length);
        ret = hex(this._hash);
        if (raw) {
          ret = hexToBinaryString(ret);
        }
        this.reset();
        return ret;
      };
      SparkMD5.prototype.reset = function () {
        this._buff = "";
        this._length = 0;
        this._hash = [1732584193, -271733879, -1732584194, 271733878];
        return this;
      };
      SparkMD5.prototype.getState = function () {
        return {
          buff: this._buff,
          length: this._length,
          hash: this._hash
        };
      };
      SparkMD5.prototype.setState = function (state) {
        this._buff = state.buff;
        this._length = state.length;
        this._hash = state.hash;
        return this;
      };
      SparkMD5.prototype.destroy = function () {
        delete this._hash;
        delete this._buff;
        delete this._length;
      };
      SparkMD5.prototype._finish = function (tail, length) {
        var i = length,
          tmp,
          lo,
          hi;
        tail[i >> 2] |= 128 << (i % 4 << 3);
        if (i > 55) {
          md5cycle(this._hash, tail);
          for (i = 0; i < 16; i += 1) {
            tail[i] = 0;
          }
        }
        tmp = this._length * 8;
        tmp = tmp.toString(16).match(/(.*?)(.{0,8})$/);
        lo = parseInt(tmp[2], 16);
        hi = parseInt(tmp[1], 16) || 0;
        tail[14] = lo;
        tail[15] = hi;
        md5cycle(this._hash, tail);
      };
      SparkMD5.hash = function (str, raw) {
        return SparkMD5.hashBinary(toUtf8(str), raw);
      };
      SparkMD5.hashBinary = function (content, raw) {
        var hash = md51(content),
          ret = hex(hash);
        return raw ? hexToBinaryString(ret) : ret;
      };
      SparkMD5.ArrayBuffer = function () {
        this.reset();
      };
      SparkMD5.ArrayBuffer.prototype.append = function (arr) {
        var buff = concatenateArrayBuffers(this._buff.buffer, arr, true),
          length = buff.length,
          i;
        this._length += arr.byteLength;
        for (i = 64; i <= length; i += 64) {
          md5cycle(this._hash, md5blk_array(buff.subarray(i - 64, i)));
        }
        this._buff = i - 64 < length ? new Uint8Array(buff.buffer.slice(i - 64)) : new Uint8Array(0);
        return this;
      };
      SparkMD5.ArrayBuffer.prototype.end = function (raw) {
        var buff = this._buff,
          length = buff.length,
          tail = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          i,
          ret;
        for (i = 0; i < length; i += 1) {
          tail[i >> 2] |= buff[i] << (i % 4 << 3);
        }
        this._finish(tail, length);
        ret = hex(this._hash);
        if (raw) {
          ret = hexToBinaryString(ret);
        }
        this.reset();
        return ret;
      };
      SparkMD5.ArrayBuffer.prototype.reset = function () {
        this._buff = new Uint8Array(0);
        this._length = 0;
        this._hash = [1732584193, -271733879, -1732584194, 271733878];
        return this;
      };
      SparkMD5.ArrayBuffer.prototype.getState = function () {
        var state = SparkMD5.prototype.getState.call(this);
        state.buff = arrayBuffer2Utf8Str(state.buff);
        return state;
      };
      SparkMD5.ArrayBuffer.prototype.setState = function (state) {
        state.buff = utf8Str2ArrayBuffer(state.buff, true);
        return SparkMD5.prototype.setState.call(this, state);
      };
      SparkMD5.ArrayBuffer.prototype.destroy = SparkMD5.prototype.destroy;
      SparkMD5.ArrayBuffer.prototype._finish = SparkMD5.prototype._finish;
      SparkMD5.ArrayBuffer.hash = function (arr, raw) {
        var hash = md51_array(new Uint8Array(arr)),
          ret = hex(hash);
        return raw ? hexToBinaryString(ret) : ret;
      };
      return SparkMD5;
    });
  });
  var classCallCheck = function classCallCheck(instance, Constructor) {
    if (!(instance instanceof Constructor)) {
      throw new TypeError("Cannot call a class as a function");
    }
  };
  var createClass = function () {
    function defineProperties(target, props) {
      for (var i = 0; i < props.length; i++) {
        var descriptor = props[i];
        descriptor.enumerable = descriptor.enumerable || false;
        descriptor.configurable = true;
        if ("value" in descriptor) descriptor.writable = true;
        Object.defineProperty(target, descriptor.key, descriptor);
      }
    }
    return function (Constructor, protoProps, staticProps) {
      if (protoProps) defineProperties(Constructor.prototype, protoProps);
      if (staticProps) defineProperties(Constructor, staticProps);
      return Constructor;
    };
  }();
  var fileSlice = File.prototype.slice || File.prototype.mozSlice || File.prototype.webkitSlice;
  var FileChecksum = function () {
    createClass(FileChecksum, null, [{
      key: "create",
      value: function create(file, callback) {
        var instance = new FileChecksum(file);
        instance.create(callback);
      }
    }]);
    function FileChecksum(file) {
      classCallCheck(this, FileChecksum);
      this.file = file;
      this.chunkSize = 2097152;
      this.chunkCount = Math.ceil(this.file.size / this.chunkSize);
      this.chunkIndex = 0;
    }
    createClass(FileChecksum, [{
      key: "create",
      value: function create(callback) {
        var _this = this;
        this.callback = callback;
        this.md5Buffer = new sparkMd5.ArrayBuffer();
        this.fileReader = new FileReader();
        this.fileReader.addEventListener("load", function (event) {
          return _this.fileReaderDidLoad(event);
        });
        this.fileReader.addEventListener("error", function (event) {
          return _this.fileReaderDidError(event);
        });
        this.readNextChunk();
      }
    }, {
      key: "fileReaderDidLoad",
      value: function fileReaderDidLoad(event) {
        this.md5Buffer.append(event.target.result);
        if (!this.readNextChunk()) {
          var binaryDigest = this.md5Buffer.end(true);
          var base64digest = btoa(binaryDigest);
          this.callback(null, base64digest);
        }
      }
    }, {
      key: "fileReaderDidError",
      value: function fileReaderDidError(event) {
        this.callback("Error reading " + this.file.name);
      }
    }, {
      key: "readNextChunk",
      value: function readNextChunk() {
        if (this.chunkIndex < this.chunkCount || this.chunkIndex == 0 && this.chunkCount == 0) {
          var start = this.chunkIndex * this.chunkSize;
          var end = Math.min(start + this.chunkSize, this.file.size);
          var bytes = fileSlice.call(this.file, start, end);
          this.fileReader.readAsArrayBuffer(bytes);
          this.chunkIndex++;
          return true;
        } else {
          return false;
        }
      }
    }]);
    return FileChecksum;
  }();
  function getMetaValue(name) {
    var element = findElement(document.head, 'meta[name="' + name + '"]');
    if (element) {
      return element.getAttribute("content");
    }
  }
  function findElements(root, selector) {
    if (typeof root == "string") {
      selector = root;
      root = document;
    }
    var elements = root.querySelectorAll(selector);
    return toArray$1(elements);
  }
  function findElement(root, selector) {
    if (typeof root == "string") {
      selector = root;
      root = document;
    }
    return root.querySelector(selector);
  }
  function dispatchEvent(element, type) {
    var eventInit = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : {};
    var disabled = element.disabled;
    var bubbles = eventInit.bubbles,
      cancelable = eventInit.cancelable,
      detail = eventInit.detail;
    var event = document.createEvent("Event");
    event.initEvent(type, bubbles || true, cancelable || true);
    event.detail = detail || {};
    try {
      element.disabled = false;
      element.dispatchEvent(event);
    } finally {
      element.disabled = disabled;
    }
    return event;
  }
  function toArray$1(value) {
    if (Array.isArray(value)) {
      return value;
    } else if (Array.from) {
      return Array.from(value);
    } else {
      return [].slice.call(value);
    }
  }
  var BlobRecord = function () {
    function BlobRecord(file, checksum, url) {
      var _this = this;
      classCallCheck(this, BlobRecord);
      this.file = file;
      this.attributes = {
        filename: file.name,
        content_type: file.type,
        byte_size: file.size,
        checksum: checksum
      };
      this.xhr = new XMLHttpRequest();
      this.xhr.open("POST", url, true);
      this.xhr.responseType = "json";
      this.xhr.setRequestHeader("Content-Type", "application/json");
      this.xhr.setRequestHeader("Accept", "application/json");
      this.xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
      this.xhr.setRequestHeader("X-CSRF-Token", getMetaValue("csrf-token"));
      this.xhr.addEventListener("load", function (event) {
        return _this.requestDidLoad(event);
      });
      this.xhr.addEventListener("error", function (event) {
        return _this.requestDidError(event);
      });
    }
    createClass(BlobRecord, [{
      key: "create",
      value: function create(callback) {
        this.callback = callback;
        this.xhr.send(JSON.stringify({
          blob: this.attributes
        }));
      }
    }, {
      key: "requestDidLoad",
      value: function requestDidLoad(event) {
        if (this.status >= 200 && this.status < 300) {
          var response = this.response;
          var direct_upload = response.direct_upload;
          delete response.direct_upload;
          this.attributes = response;
          this.directUploadData = direct_upload;
          this.callback(null, this.toJSON());
        } else {
          this.requestDidError(event);
        }
      }
    }, {
      key: "requestDidError",
      value: function requestDidError(event) {
        this.callback('Error creating Blob for "' + this.file.name + '". Status: ' + this.status);
      }
    }, {
      key: "toJSON",
      value: function toJSON() {
        var result = {};
        for (var key in this.attributes) {
          result[key] = this.attributes[key];
        }
        return result;
      }
    }, {
      key: "status",
      get: function get$$1() {
        return this.xhr.status;
      }
    }, {
      key: "response",
      get: function get$$1() {
        var _xhr = this.xhr,
          responseType = _xhr.responseType,
          response = _xhr.response;
        if (responseType == "json") {
          return response;
        } else {
          return JSON.parse(response);
        }
      }
    }]);
    return BlobRecord;
  }();
  var BlobUpload = function () {
    function BlobUpload(blob) {
      var _this = this;
      classCallCheck(this, BlobUpload);
      this.blob = blob;
      this.file = blob.file;
      var _blob$directUploadDat = blob.directUploadData,
        url = _blob$directUploadDat.url,
        headers = _blob$directUploadDat.headers;
      this.xhr = new XMLHttpRequest();
      this.xhr.open("PUT", url, true);
      this.xhr.responseType = "text";
      for (var key in headers) {
        this.xhr.setRequestHeader(key, headers[key]);
      }
      this.xhr.addEventListener("load", function (event) {
        return _this.requestDidLoad(event);
      });
      this.xhr.addEventListener("error", function (event) {
        return _this.requestDidError(event);
      });
    }
    createClass(BlobUpload, [{
      key: "create",
      value: function create(callback) {
        this.callback = callback;
        this.xhr.send(this.file.slice());
      }
    }, {
      key: "requestDidLoad",
      value: function requestDidLoad(event) {
        var _xhr = this.xhr,
          status = _xhr.status,
          response = _xhr.response;
        if (status >= 200 && status < 300) {
          this.callback(null, response);
        } else {
          this.requestDidError(event);
        }
      }
    }, {
      key: "requestDidError",
      value: function requestDidError(event) {
        this.callback('Error storing "' + this.file.name + '". Status: ' + this.xhr.status);
      }
    }]);
    return BlobUpload;
  }();
  var id = 0;
  var DirectUpload = function () {
    function DirectUpload(file, url, delegate) {
      classCallCheck(this, DirectUpload);
      this.id = ++id;
      this.file = file;
      this.url = url;
      this.delegate = delegate;
    }
    createClass(DirectUpload, [{
      key: "create",
      value: function create(callback) {
        var _this = this;
        FileChecksum.create(this.file, function (error, checksum) {
          if (error) {
            callback(error);
            return;
          }
          var blob = new BlobRecord(_this.file, checksum, _this.url);
          notify(_this.delegate, "directUploadWillCreateBlobWithXHR", blob.xhr);
          blob.create(function (error) {
            if (error) {
              callback(error);
            } else {
              var upload = new BlobUpload(blob);
              notify(_this.delegate, "directUploadWillStoreFileWithXHR", upload.xhr);
              upload.create(function (error) {
                if (error) {
                  callback(error);
                } else {
                  callback(null, blob.toJSON());
                }
              });
            }
          });
        });
      }
    }]);
    return DirectUpload;
  }();
  function notify(object, methodName) {
    if (object && typeof object[methodName] == "function") {
      for (var _len = arguments.length, messages = Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
        messages[_key - 2] = arguments[_key];
      }
      return object[methodName].apply(object, messages);
    }
  }
  var DirectUploadController = function () {
    function DirectUploadController(input, file) {
      classCallCheck(this, DirectUploadController);
      this.input = input;
      this.file = file;
      this.directUpload = new DirectUpload(this.file, this.url, this);
      this.dispatch("initialize");
    }
    createClass(DirectUploadController, [{
      key: "start",
      value: function start(callback) {
        var _this = this;
        var hiddenInput = document.createElement("input");
        hiddenInput.type = "hidden";
        hiddenInput.name = this.input.name;
        this.input.insertAdjacentElement("beforebegin", hiddenInput);
        this.dispatch("start");
        this.directUpload.create(function (error, attributes) {
          if (error) {
            hiddenInput.parentNode.removeChild(hiddenInput);
            _this.dispatchError(error);
          } else {
            hiddenInput.value = attributes.signed_id;
          }
          _this.dispatch("end");
          callback(error);
        });
      }
    }, {
      key: "uploadRequestDidProgress",
      value: function uploadRequestDidProgress(event) {
        var progress = event.loaded / event.total * 100;
        if (progress) {
          this.dispatch("progress", {
            progress: progress
          });
        }
      }
    }, {
      key: "dispatch",
      value: function dispatch(name) {
        var detail = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
        detail.file = this.file;
        detail.id = this.directUpload.id;
        return dispatchEvent(this.input, "direct-upload:" + name, {
          detail: detail
        });
      }
    }, {
      key: "dispatchError",
      value: function dispatchError(error) {
        var event = this.dispatch("error", {
          error: error
        });
        if (!event.defaultPrevented) {
          alert(error);
        }
      }
    }, {
      key: "directUploadWillCreateBlobWithXHR",
      value: function directUploadWillCreateBlobWithXHR(xhr) {
        this.dispatch("before-blob-request", {
          xhr: xhr
        });
      }
    }, {
      key: "directUploadWillStoreFileWithXHR",
      value: function directUploadWillStoreFileWithXHR(xhr) {
        var _this2 = this;
        this.dispatch("before-storage-request", {
          xhr: xhr
        });
        xhr.upload.addEventListener("progress", function (event) {
          return _this2.uploadRequestDidProgress(event);
        });
      }
    }, {
      key: "url",
      get: function get$$1() {
        return this.input.getAttribute("data-direct-upload-url");
      }
    }]);
    return DirectUploadController;
  }();
  var inputSelector = "input[type=file][data-direct-upload-url]:not([disabled])";
  var DirectUploadsController = function () {
    function DirectUploadsController(form) {
      classCallCheck(this, DirectUploadsController);
      this.form = form;
      this.inputs = findElements(form, inputSelector).filter(function (input) {
        return input.files.length;
      });
    }
    createClass(DirectUploadsController, [{
      key: "start",
      value: function start(callback) {
        var _this = this;
        var controllers = this.createDirectUploadControllers();
        var startNextController = function startNextController() {
          var controller = controllers.shift();
          if (controller) {
            controller.start(function (error) {
              if (error) {
                callback(error);
                _this.dispatch("end");
              } else {
                startNextController();
              }
            });
          } else {
            callback();
            _this.dispatch("end");
          }
        };
        this.dispatch("start");
        startNextController();
      }
    }, {
      key: "createDirectUploadControllers",
      value: function createDirectUploadControllers() {
        var controllers = [];
        this.inputs.forEach(function (input) {
          toArray$1(input.files).forEach(function (file) {
            var controller = new DirectUploadController(input, file);
            controllers.push(controller);
          });
        });
        return controllers;
      }
    }, {
      key: "dispatch",
      value: function dispatch(name) {
        var detail = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
        return dispatchEvent(this.form, "direct-uploads:" + name, {
          detail: detail
        });
      }
    }]);
    return DirectUploadsController;
  }();
  var processingAttribute = "data-direct-uploads-processing";
  var submitButtonsByForm = new WeakMap();
  var started = false;
  function start() {
    if (!started) {
      started = true;
      document.addEventListener("click", didClick, true);
      document.addEventListener("submit", didSubmitForm);
      document.addEventListener("ajax:before", didSubmitRemoteElement);
    }
  }
  function didClick(event) {
    var target = event.target;
    if ((target.tagName == "INPUT" || target.tagName == "BUTTON") && target.type == "submit" && target.form) {
      submitButtonsByForm.set(target.form, target);
    }
  }
  function didSubmitForm(event) {
    handleFormSubmissionEvent(event);
  }
  function didSubmitRemoteElement(event) {
    if (event.target.tagName == "FORM") {
      handleFormSubmissionEvent(event);
    }
  }
  function handleFormSubmissionEvent(event) {
    var form = event.target;
    if (form.hasAttribute(processingAttribute)) {
      event.preventDefault();
      return;
    }
    var controller = new DirectUploadsController(form);
    var inputs = controller.inputs;
    if (inputs.length) {
      event.preventDefault();
      form.setAttribute(processingAttribute, "");
      inputs.forEach(disable);
      controller.start(function (error) {
        form.removeAttribute(processingAttribute);
        if (error) {
          inputs.forEach(enable);
        } else {
          submitForm(form);
        }
      });
    }
  }
  function submitForm(form) {
    var button = submitButtonsByForm.get(form) || findElement(form, "input[type=submit], button[type=submit]");
    if (button) {
      var _button = button,
        disabled = _button.disabled;
      button.disabled = false;
      button.focus();
      button.click();
      button.disabled = disabled;
    } else {
      button = document.createElement("input");
      button.type = "submit";
      button.style.display = "none";
      form.appendChild(button);
      button.click();
      form.removeChild(button);
    }
    submitButtonsByForm["delete"](form);
  }
  function disable(input) {
    input.disabled = true;
  }
  function enable(input) {
    input.disabled = false;
  }
  function autostart() {
    if (window.ActiveStorage) {
      start();
    }
  }
  setTimeout(autostart, 1);
  exports.start = start;
  exports.DirectUpload = DirectUpload;
  Object.defineProperty(exports, "__esModule", {
    value: true
  });
});

/***/ }),

/***/ "./node_modules/trix/dist/trix.esm.min.js":
/*!************************************************!*\
  !*** ./node_modules/trix/dist/trix.esm.min.js ***!
  \************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return oo; });
function _wrapNativeSuper(t) { var r = "function" == typeof Map ? new Map() : void 0; return _wrapNativeSuper = function _wrapNativeSuper(t) { if (null === t || !_isNativeFunction(t)) return t; if ("function" != typeof t) throw new TypeError("Super expression must either be null or a function"); if (void 0 !== r) { if (r.has(t)) return r.get(t); r.set(t, Wrapper); } function Wrapper() { return _construct(t, arguments, _getPrototypeOf(this).constructor); } return Wrapper.prototype = Object.create(t.prototype, { constructor: { value: Wrapper, enumerable: !1, writable: !0, configurable: !0 } }), _setPrototypeOf(Wrapper, t); }, _wrapNativeSuper(t); }
function _isNativeFunction(t) { try { return -1 !== Function.toString.call(t).indexOf("[native code]"); } catch (n) { return "function" == typeof t; } }
function _toArray(r) { return _arrayWithHoles(r) || _iterableToArray(r) || _unsupportedIterableToArray(r) || _nonIterableRest(); }
function _defineProperty(e, r, t) { return (r = _toPropertyKey(r)) in e ? Object.defineProperty(e, r, { value: t, enumerable: !0, configurable: !0, writable: !0 }) : e[r] = t, e; }
function _superPropGet(t, o, e, r) { var p = _get(_getPrototypeOf(1 & r ? t.prototype : t), o, e); return 2 & r && "function" == typeof p ? function (t) { return p.apply(e, t); } : p; }
function _get() { return _get = "undefined" != typeof Reflect && Reflect.get ? Reflect.get.bind() : function (e, t, r) { var p = _superPropBase(e, t); if (p) { var n = Object.getOwnPropertyDescriptor(p, t); return n.get ? n.get.call(arguments.length < 3 ? e : r) : n.value; } }, _get.apply(null, arguments); }
function _superPropBase(t, o) { for (; !{}.hasOwnProperty.call(t, o) && null !== (t = _getPrototypeOf(t));); return t; }
function _construct(t, e, r) { if (_isNativeReflectConstruct()) return Reflect.construct.apply(null, arguments); var o = [null]; o.push.apply(o, e); var p = new (t.bind.apply(t, o))(); return r && _setPrototypeOf(p, r.prototype), p; }
function _createForOfIteratorHelper(r, e) { var t = "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (!t) { if (Array.isArray(r) || (t = _unsupportedIterableToArray(r)) || e && r && "number" == typeof r.length) { t && (r = t); var _n32 = 0, F = function F() {}; return { s: F, n: function n() { return _n32 >= r.length ? { done: !0 } : { done: !1, value: r[_n32++] }; }, e: function e(r) { throw r; }, f: F }; } throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); } var o, a = !0, u = !1; return { s: function s() { t = t.call(r); }, n: function n() { var r = t.next(); return a = r.done, r; }, e: function e(r) { u = !0, o = r; }, f: function f() { try { a || null == t["return"] || t["return"](); } finally { if (u) throw o; } } }; }
function _slicedToArray(r, e) { return _arrayWithHoles(r) || _iterableToArrayLimit(r, e) || _unsupportedIterableToArray(r, e) || _nonIterableRest(); }
function _nonIterableRest() { throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }
function _iterableToArrayLimit(r, l) { var t = null == r ? null : "undefined" != typeof Symbol && r[Symbol.iterator] || r["@@iterator"]; if (null != t) { var e, n, i, u, a = [], f = !0, o = !1; try { if (i = (t = t.call(r)).next, 0 === l) { if (Object(t) !== t) return; f = !1; } else for (; !(f = (e = i.call(t)).done) && (a.push(e.value), a.length !== l); f = !0); } catch (r) { o = !0, n = r; } finally { try { if (!f && null != t["return"] && (u = t["return"](), Object(u) !== u)) return; } finally { if (o) throw n; } } return a; } }
function _arrayWithHoles(r) { if (Array.isArray(r)) return r; }
function _toConsumableArray(r) { return _arrayWithoutHoles(r) || _iterableToArray(r) || _unsupportedIterableToArray(r) || _nonIterableSpread(); }
function _nonIterableSpread() { throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method."); }
function _unsupportedIterableToArray(r, a) { if (r) { if ("string" == typeof r) return _arrayLikeToArray(r, a); var t = {}.toString.call(r).slice(8, -1); return "Object" === t && r.constructor && (t = r.constructor.name), "Map" === t || "Set" === t ? Array.from(r) : "Arguments" === t || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(t) ? _arrayLikeToArray(r, a) : void 0; } }
function _iterableToArray(r) { if ("undefined" != typeof Symbol && null != r[Symbol.iterator] || null != r["@@iterator"]) return Array.from(r); }
function _arrayWithoutHoles(r) { if (Array.isArray(r)) return _arrayLikeToArray(r); }
function _arrayLikeToArray(r, a) { (null == a || a > r.length) && (a = r.length); for (var e = 0, n = Array(a); e < a; e++) n[e] = r[e]; return n; }
function _callSuper(t, o, e) { return o = _getPrototypeOf(o), _possibleConstructorReturn(t, _isNativeReflectConstruct() ? Reflect.construct(o, e || [], _getPrototypeOf(t).constructor) : o.apply(t, e)); }
function _possibleConstructorReturn(t, e) { if (e && ("object" == _typeof(e) || "function" == typeof e)) return e; if (void 0 !== e) throw new TypeError("Derived constructors may only return object or undefined"); return _assertThisInitialized(t); }
function _assertThisInitialized(e) { if (void 0 === e) throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); return e; }
function _isNativeReflectConstruct() { try { var t = !Boolean.prototype.valueOf.call(Reflect.construct(Boolean, [], function () {})); } catch (t) {} return (_isNativeReflectConstruct = function _isNativeReflectConstruct() { return !!t; })(); }
function _getPrototypeOf(t) { return _getPrototypeOf = Object.setPrototypeOf ? Object.getPrototypeOf.bind() : function (t) { return t.__proto__ || Object.getPrototypeOf(t); }, _getPrototypeOf(t); }
function _inherits(t, e) { if ("function" != typeof e && null !== e) throw new TypeError("Super expression must either be null or a function"); t.prototype = Object.create(e && e.prototype, { constructor: { value: t, writable: !0, configurable: !0 } }), Object.defineProperty(t, "prototype", { writable: !1 }), e && _setPrototypeOf(t, e); }
function _setPrototypeOf(t, e) { return _setPrototypeOf = Object.setPrototypeOf ? Object.setPrototypeOf.bind() : function (t, e) { return t.__proto__ = e, t; }, _setPrototypeOf(t, e); }
function _classCallCheck(a, n) { if (!(a instanceof n)) throw new TypeError("Cannot call a class as a function"); }
function _defineProperties(e, r) { for (var t = 0; t < r.length; t++) { var o = r[t]; o.enumerable = o.enumerable || !1, o.configurable = !0, "value" in o && (o.writable = !0), Object.defineProperty(e, _toPropertyKey(o.key), o); } }
function _createClass(e, r, t) { return r && _defineProperties(e.prototype, r), t && _defineProperties(e, t), Object.defineProperty(e, "prototype", { writable: !1 }), e; }
function _toPropertyKey(t) { var i = _toPrimitive(t, "string"); return "symbol" == _typeof(i) ? i : i + ""; }
function _toPrimitive(t, r) { if ("object" != _typeof(t) || !t) return t; var e = t[Symbol.toPrimitive]; if (void 0 !== e) { var i = e.call(t, r || "default"); if ("object" != _typeof(i)) return i; throw new TypeError("@@toPrimitive must return a primitive value."); } return ("string" === r ? String : Number)(t); }
function _typeof(o) { "@babel/helpers - typeof"; return _typeof = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (o) { return typeof o; } : function (o) { return o && "function" == typeof Symbol && o.constructor === Symbol && o !== Symbol.prototype ? "symbol" : typeof o; }, _typeof(o); }
/*
Trix 2.1.14
Copyright © 2025 37signals, LLC
 */
var t = "2.1.14";
var e = "[data-trix-attachment]",
  i = {
    preview: {
      presentation: "gallery",
      caption: {
        name: !0,
        size: !0
      }
    },
    file: {
      caption: {
        size: !0
      }
    }
  },
  n = {
    "default": {
      tagName: "div",
      parse: !1
    },
    quote: {
      tagName: "blockquote",
      nestable: !0
    },
    heading1: {
      tagName: "h1",
      terminal: !0,
      breakOnReturn: !0,
      group: !1
    },
    code: {
      tagName: "pre",
      terminal: !0,
      htmlAttributes: ["language"],
      text: {
        plaintext: !0
      }
    },
    bulletList: {
      tagName: "ul",
      parse: !1
    },
    bullet: {
      tagName: "li",
      listAttribute: "bulletList",
      group: !1,
      nestable: !0,
      test: function test(t) {
        return r(t.parentNode) === n[this.listAttribute].tagName;
      }
    },
    numberList: {
      tagName: "ol",
      parse: !1
    },
    number: {
      tagName: "li",
      listAttribute: "numberList",
      group: !1,
      nestable: !0,
      test: function test(t) {
        return r(t.parentNode) === n[this.listAttribute].tagName;
      }
    },
    attachmentGallery: {
      tagName: "div",
      exclusive: !0,
      terminal: !0,
      parse: !1,
      group: !1
    }
  },
  r = function r(t) {
    var e;
    return null == t || null === (e = t.tagName) || void 0 === e ? void 0 : e.toLowerCase();
  },
  o = navigator.userAgent.match(/android\s([0-9]+.*Chrome)/i),
  s = o && parseInt(o[1]);
var a = {
    composesExistingText: /Android.*Chrome/.test(navigator.userAgent),
    recentAndroid: s && s > 12,
    samsungAndroid: s && navigator.userAgent.match(/Android.*SM-/),
    forcesObjectResizing: /Trident.*rv:11/.test(navigator.userAgent),
    supportsInputEvents: "undefined" != typeof InputEvent && ["data", "getTargetRanges", "inputType"].every(function (t) {
      return t in InputEvent.prototype;
    })
  },
  l = {
    ADD_ATTR: ["language"],
    SAFE_FOR_XML: !1,
    RETURN_DOM: !0
  },
  c = {
    attachFiles: "Attach Files",
    bold: "Bold",
    bullets: "Bullets",
    "byte": "Byte",
    bytes: "Bytes",
    captionPlaceholder: "Add a caption…",
    code: "Code",
    heading1: "Heading",
    indent: "Increase Level",
    italic: "Italic",
    link: "Link",
    numbers: "Numbers",
    outdent: "Decrease Level",
    quote: "Quote",
    redo: "Redo",
    remove: "Remove",
    strike: "Strikethrough",
    undo: "Undo",
    unlink: "Unlink",
    url: "URL",
    urlPlaceholder: "Enter a URL…",
    GB: "GB",
    KB: "KB",
    MB: "MB",
    PB: "PB",
    TB: "TB"
  };
var u = [c.bytes, c.KB, c.MB, c.GB, c.TB, c.PB];
var h = {
  prefix: "IEC",
  precision: 2,
  formatter: function formatter(t) {
    switch (t) {
      case 0:
        return "0 ".concat(c.bytes);
      case 1:
        return "1 ".concat(c["byte"]);
      default:
        var _e2;
        "SI" === this.prefix ? _e2 = 1e3 : "IEC" === this.prefix && (_e2 = 1024);
        var _i2 = Math.floor(Math.log(t) / Math.log(_e2)),
          _n2 = (t / Math.pow(_e2, _i2)).toFixed(this.precision).replace(/0*$/, "").replace(/\.$/, "");
        return "".concat(_n2, " ").concat(u[_i2]);
    }
  }
};
var d = "\uFEFF",
  g = " ",
  m = function m(t) {
    for (var _e3 in t) {
      var _i3 = t[_e3];
      this[_e3] = _i3;
    }
    return this;
  },
  p = document.documentElement,
  f = p.matches,
  b = function b(t) {
    var _ref = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      e = _ref.onElement,
      i = _ref.matchingSelector,
      n = _ref.withCallback,
      r = _ref.inPhase,
      o = _ref.preventDefault,
      s = _ref.times;
    var a = e || p,
      l = i,
      c = "capturing" === r,
      _u = function u(t) {
        null != s && 0 == --s && _u.destroy();
        var e = y(t.target, {
          matchingSelector: l
        });
        null != e && (null == n || n.call(e, t, e), o && t.preventDefault());
      };
    return _u.destroy = function () {
      return a.removeEventListener(t, _u, c);
    }, a.addEventListener(t, _u, c), _u;
  },
  v = function v(t) {
    var _ref2 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      e = _ref2.onElement,
      i = _ref2.bubbles,
      n = _ref2.cancelable,
      r = _ref2.attributes;
    var o = null != e ? e : p;
    i = !1 !== i, n = !1 !== n;
    var s = document.createEvent("Events");
    return s.initEvent(t, i, n), null != r && m.call(s, r), o.dispatchEvent(s);
  },
  A = function A(t, e) {
    if (1 === (null == t ? void 0 : t.nodeType)) return f.call(t, e);
  },
  y = function y(t) {
    var _ref3 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      e = _ref3.matchingSelector,
      i = _ref3.untilNode;
    for (; t && t.nodeType !== Node.ELEMENT_NODE;) t = t.parentNode;
    if (null != t) {
      if (null == e) return t;
      if (t.closest && null == i) return t.closest(e);
      for (; t && t !== i;) {
        if (A(t, e)) return t;
        t = t.parentNode;
      }
    }
  },
  x = function x(t) {
    return document.activeElement !== t && C(t, document.activeElement);
  },
  C = function C(t, e) {
    if (t && e) for (; e;) {
      if (e === t) return !0;
      e = e.parentNode;
    }
  },
  E = function E(t) {
    var e;
    if (null === (e = t) || void 0 === e || !e.parentNode) return;
    var i = 0;
    for (t = t.previousSibling; t;) i++, t = t.previousSibling;
    return i;
  },
  S = function S(t) {
    var e;
    return null == t || null === (e = t.parentNode) || void 0 === e ? void 0 : e.removeChild(t);
  },
  R = function R(t) {
    var _ref4 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      e = _ref4.onlyNodesOfType,
      i = _ref4.usingFilter,
      n = _ref4.expandEntityReferences;
    var r = function () {
      switch (e) {
        case "element":
          return NodeFilter.SHOW_ELEMENT;
        case "text":
          return NodeFilter.SHOW_TEXT;
        case "comment":
          return NodeFilter.SHOW_COMMENT;
        default:
          return NodeFilter.SHOW_ALL;
      }
    }();
    return document.createTreeWalker(t, r, null != i ? i : null, !0 === n);
  },
  k = function k(t) {
    var e;
    return null == t || null === (e = t.tagName) || void 0 === e ? void 0 : e.toLowerCase();
  },
  T = function T(t) {
    var e,
      i,
      n = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
    "object" == _typeof(t) ? (n = t, t = n.tagName) : n = {
      attributes: n
    };
    var r = document.createElement(t);
    if (null != n.editable && (null == n.attributes && (n.attributes = {}), n.attributes.contenteditable = n.editable), n.attributes) for (e in n.attributes) i = n.attributes[e], r.setAttribute(e, i);
    if (n.style) for (e in n.style) i = n.style[e], r.style[e] = i;
    if (n.data) for (e in n.data) i = n.data[e], r.dataset[e] = i;
    return n.className && n.className.split(" ").forEach(function (t) {
      r.classList.add(t);
    }), n.textContent && (r.textContent = n.textContent), n.childNodes && [].concat(n.childNodes).forEach(function (t) {
      r.appendChild(t);
    }), r;
  };
var w;
var L = function L() {
    if (null != w) return w;
    w = [];
    for (var _t2 in n) {
      var _e4 = n[_t2];
      _e4.tagName && w.push(_e4.tagName);
    }
    return w;
  },
  D = function D(t) {
    return I(null == t ? void 0 : t.firstChild);
  },
  N = function N(t) {
    var _ref5 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {
        strict: !0
      },
      e = _ref5.strict;
    return e ? I(t) : I(t) || !I(t.firstChild) && function (t) {
      return L().includes(k(t)) && !L().includes(k(t.firstChild));
    }(t);
  },
  I = function I(t) {
    return O(t) && "block" === (null == t ? void 0 : t.data);
  },
  O = function O(t) {
    return (null == t ? void 0 : t.nodeType) === Node.COMMENT_NODE;
  },
  _F = function F(t) {
    var _ref6 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      e = _ref6.name;
    if (t) return B(t) ? t.data === d ? !e || t.parentNode.dataset.trixCursorTarget === e : void 0 : _F(t.firstChild);
  },
  P = function P(t) {
    return A(t, e);
  },
  M = function M(t) {
    return B(t) && "" === (null == t ? void 0 : t.data);
  },
  B = function B(t) {
    return (null == t ? void 0 : t.nodeType) === Node.TEXT_NODE;
  },
  _ = {
    level2Enabled: !0,
    getLevel: function getLevel() {
      return this.level2Enabled && a.supportsInputEvents ? 2 : 0;
    },
    pickFiles: function pickFiles(t) {
      var e = T("input", {
        type: "file",
        multiple: !0,
        hidden: !0,
        id: this.fileInputId
      });
      e.addEventListener("change", function () {
        t(e.files), S(e);
      }), S(document.getElementById(this.fileInputId)), document.body.appendChild(e), e.click();
    }
  };
var j = {
    removeBlankTableCells: !1,
    tableCellSeparator: " | ",
    tableRowSeparator: "\n"
  },
  W = {
    bold: {
      tagName: "strong",
      inheritable: !0,
      parser: function parser(t) {
        var e = window.getComputedStyle(t);
        return "bold" === e.fontWeight || e.fontWeight >= 600;
      }
    },
    italic: {
      tagName: "em",
      inheritable: !0,
      parser: function parser(t) {
        return "italic" === window.getComputedStyle(t).fontStyle;
      }
    },
    href: {
      groupTagName: "a",
      parser: function parser(t) {
        var i = "a:not(".concat(e, ")"),
          n = t.closest(i);
        if (n) return n.getAttribute("href");
      }
    },
    strike: {
      tagName: "del",
      inheritable: !0
    },
    frozen: {
      style: {
        backgroundColor: "highlight"
      }
    }
  },
  U = {
    getDefaultHTML: function getDefaultHTML() {
      return '<div class="trix-button-row">\n      <span class="trix-button-group trix-button-group--text-tools" data-trix-button-group="text-tools">\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-bold" data-trix-attribute="bold" data-trix-key="b" title="'.concat(c.bold, '" tabindex="-1">').concat(c.bold, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-italic" data-trix-attribute="italic" data-trix-key="i" title="').concat(c.italic, '" tabindex="-1">').concat(c.italic, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-strike" data-trix-attribute="strike" title="').concat(c.strike, '" tabindex="-1">').concat(c.strike, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-link" data-trix-attribute="href" data-trix-action="link" data-trix-key="k" title="').concat(c.link, '" tabindex="-1">').concat(c.link, '</button>\n      </span>\n\n      <span class="trix-button-group trix-button-group--block-tools" data-trix-button-group="block-tools">\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-heading-1" data-trix-attribute="heading1" title="').concat(c.heading1, '" tabindex="-1">').concat(c.heading1, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-quote" data-trix-attribute="quote" title="').concat(c.quote, '" tabindex="-1">').concat(c.quote, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-code" data-trix-attribute="code" title="').concat(c.code, '" tabindex="-1">').concat(c.code, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-bullet-list" data-trix-attribute="bullet" title="').concat(c.bullets, '" tabindex="-1">').concat(c.bullets, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-number-list" data-trix-attribute="number" title="').concat(c.numbers, '" tabindex="-1">').concat(c.numbers, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-decrease-nesting-level" data-trix-action="decreaseNestingLevel" title="').concat(c.outdent, '" tabindex="-1">').concat(c.outdent, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-increase-nesting-level" data-trix-action="increaseNestingLevel" title="').concat(c.indent, '" tabindex="-1">').concat(c.indent, '</button>\n      </span>\n\n      <span class="trix-button-group trix-button-group--file-tools" data-trix-button-group="file-tools">\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-attach" data-trix-action="attachFiles" title="').concat(c.attachFiles, '" tabindex="-1">').concat(c.attachFiles, '</button>\n      </span>\n\n      <span class="trix-button-group-spacer"></span>\n\n      <span class="trix-button-group trix-button-group--history-tools" data-trix-button-group="history-tools">\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-undo" data-trix-action="undo" data-trix-key="z" title="').concat(c.undo, '" tabindex="-1">').concat(c.undo, '</button>\n        <button type="button" class="trix-button trix-button--icon trix-button--icon-redo" data-trix-action="redo" data-trix-key="shift+z" title="').concat(c.redo, '" tabindex="-1">').concat(c.redo, '</button>\n      </span>\n    </div>\n\n    <div class="trix-dialogs" data-trix-dialogs>\n      <div class="trix-dialog trix-dialog--link" data-trix-dialog="href" data-trix-dialog-attribute="href">\n        <div class="trix-dialog__link-fields">\n          <input type="url" name="href" class="trix-input trix-input--dialog" placeholder="').concat(c.urlPlaceholder, '" aria-label="').concat(c.url, '" data-trix-validate-href required data-trix-input>\n          <div class="trix-button-group">\n            <input type="button" class="trix-button trix-button--dialog" value="').concat(c.link, '" data-trix-method="setAttribute">\n            <input type="button" class="trix-button trix-button--dialog" value="').concat(c.unlink, '" data-trix-method="removeAttribute">\n          </div>\n        </div>\n      </div>\n    </div>');
    }
  };
var V = {
  interval: 5e3
};
var z = Object.freeze({
  __proto__: null,
  attachments: i,
  blockAttributes: n,
  browser: a,
  css: {
    attachment: "attachment",
    attachmentCaption: "attachment__caption",
    attachmentCaptionEditor: "attachment__caption-editor",
    attachmentMetadata: "attachment__metadata",
    attachmentMetadataContainer: "attachment__metadata-container",
    attachmentName: "attachment__name",
    attachmentProgress: "attachment__progress",
    attachmentSize: "attachment__size",
    attachmentToolbar: "attachment__toolbar",
    attachmentGallery: "attachment-gallery"
  },
  dompurify: l,
  fileSize: h,
  input: _,
  keyNames: {
    8: "backspace",
    9: "tab",
    13: "return",
    27: "escape",
    37: "left",
    39: "right",
    46: "delete",
    68: "d",
    72: "h",
    79: "o"
  },
  lang: c,
  parser: j,
  textAttributes: W,
  toolbar: U,
  undo: V
});
var q = /*#__PURE__*/function () {
  function q() {
    _classCallCheck(this, q);
  }
  return _createClass(q, null, [{
    key: "proxyMethod",
    value: function proxyMethod(t) {
      var _H = H(t),
        e = _H.name,
        i = _H.toMethod,
        n = _H.toProperty,
        r = _H.optional;
      this.prototype[e] = function () {
        var t, o;
        var s, a;
        i ? o = r ? null === (s = this[i]) || void 0 === s ? void 0 : s.call(this) : this[i]() : n && (o = this[n]);
        return r ? (t = null === (a = o) || void 0 === a ? void 0 : a[e], t ? J.call(t, o, arguments) : void 0) : (t = o[e], J.call(t, o, arguments));
      };
    }
  }]);
}();
var H = function H(t) {
    var e = t.match(K);
    if (!e) throw new Error("can't parse @proxyMethod expression: ".concat(t));
    var i = {
      name: e[4]
    };
    return null != e[2] ? i.toMethod = e[1] : i.toProperty = e[1], null != e[3] && (i.optional = !0), i;
  },
  J = Function.prototype.apply,
  K = new RegExp("^(.+?)(\\(\\))?(\\?)?\\.(.+?)$");
var G, Y, $;
var X = /*#__PURE__*/function (_q) {
  function X(t, e) {
    var _this;
    _classCallCheck(this, X);
    _this = _callSuper(this, X, arguments), _this.ucs2String = t, _this.codepoints = e, _this.length = _this.codepoints.length, _this.ucs2Length = _this.ucs2String.length;
    return _this;
  }
  _inherits(X, _q);
  return _createClass(X, [{
    key: "offsetToUCS2Offset",
    value: function offsetToUCS2Offset(t) {
      return it(this.codepoints.slice(0, Math.max(0, t))).length;
    }
  }, {
    key: "offsetFromUCS2Offset",
    value: function offsetFromUCS2Offset(t) {
      return et(this.ucs2String.slice(0, Math.max(0, t))).length;
    }
  }, {
    key: "slice",
    value: function slice() {
      var _this$codepoints;
      return this.constructor.fromCodepoints((_this$codepoints = this.codepoints).slice.apply(_this$codepoints, arguments));
    }
  }, {
    key: "charAt",
    value: function charAt(t) {
      return this.slice(t, t + 1);
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      return this.constructor.box(t).ucs2String === this.ucs2String;
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return this.ucs2String;
    }
  }, {
    key: "getCacheKey",
    value: function getCacheKey() {
      return this.ucs2String;
    }
  }, {
    key: "toString",
    value: function toString() {
      return this.ucs2String;
    }
  }], [{
    key: "box",
    value: function box() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : "";
      return t instanceof this ? t : this.fromUCS2String(null == t ? void 0 : t.toString());
    }
  }, {
    key: "fromUCS2String",
    value: function fromUCS2String(t) {
      return new this(t, et(t));
    }
  }, {
    key: "fromCodepoints",
    value: function fromCodepoints(t) {
      return new this(it(t), t);
    }
  }]);
}(q);
var Z = 1 === (null === (G = Array.from) || void 0 === G ? void 0 : G.call(Array, "👼").length),
  Q = null != (null === (Y = " ".codePointAt) || void 0 === Y ? void 0 : Y.call(" ", 0)),
  tt = " 👼" === (null === ($ = String.fromCodePoint) || void 0 === $ ? void 0 : $.call(String, 32, 128124));
var et, it;
et = Z && Q ? function (t) {
  return Array.from(t).map(function (t) {
    return t.codePointAt(0);
  });
} : function (t) {
  var e = [];
  var i = 0;
  var n = t.length;
  for (; i < n;) {
    var _r2 = t.charCodeAt(i++);
    if (55296 <= _r2 && _r2 <= 56319 && i < n) {
      var _e5 = t.charCodeAt(i++);
      56320 == (64512 & _e5) ? _r2 = ((1023 & _r2) << 10) + (1023 & _e5) + 65536 : i--;
    }
    e.push(_r2);
  }
  return e;
}, it = tt ? function (t) {
  return String.fromCodePoint.apply(String, _toConsumableArray(Array.from(t || [])));
} : function (t) {
  return function () {
    var e = [];
    return Array.from(t).forEach(function (t) {
      var i = "";
      t > 65535 && (t -= 65536, i += String.fromCharCode(t >>> 10 & 1023 | 55296), t = 56320 | 1023 & t), e.push(i + String.fromCharCode(t));
    }), e;
  }().join("");
};
var nt = 0;
var rt = /*#__PURE__*/function (_q2) {
  function rt() {
    var _this2;
    _classCallCheck(this, rt);
    _this2 = _callSuper(this, rt, arguments), _this2.id = ++nt;
    return _this2;
  }
  _inherits(rt, _q2);
  return _createClass(rt, [{
    key: "hasSameConstructorAs",
    value: function hasSameConstructorAs(t) {
      return this.constructor === (null == t ? void 0 : t.constructor);
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      return this === t;
    }
  }, {
    key: "inspect",
    value: function inspect() {
      var t = [],
        e = this.contentsForInspection() || {};
      for (var _i4 in e) {
        var _n3 = e[_i4];
        t.push("".concat(_i4, "=").concat(_n3));
      }
      return "#<".concat(this.constructor.name, ":").concat(this.id).concat(t.length ? " ".concat(t.join(", ")) : "", ">");
    }
  }, {
    key: "contentsForInspection",
    value: function contentsForInspection() {}
  }, {
    key: "toJSONString",
    value: function toJSONString() {
      return JSON.stringify(this);
    }
  }, {
    key: "toUTF16String",
    value: function toUTF16String() {
      return X.box(this);
    }
  }, {
    key: "getCacheKey",
    value: function getCacheKey() {
      return this.id.toString();
    }
  }], [{
    key: "fromJSONString",
    value: function fromJSONString(t) {
      return this.fromJSON(JSON.parse(t));
    }
  }]);
}(q);
var ot = function ot() {
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [],
      e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : [];
    if (t.length !== e.length) return !1;
    for (var _i5 = 0; _i5 < t.length; _i5++) {
      if (t[_i5] !== e[_i5]) return !1;
    }
    return !0;
  },
  st = function st(t) {
    var e = t.slice(0);
    for (var i = arguments.length, n = new Array(i > 1 ? i - 1 : 0), r = 1; r < i; r++) n[r - 1] = arguments[r];
    return e.splice.apply(e, n), e;
  },
  at = /[\u05BE\u05C0\u05C3\u05D0-\u05EA\u05F0-\u05F4\u061B\u061F\u0621-\u063A\u0640-\u064A\u066D\u0671-\u06B7\u06BA-\u06BE\u06C0-\u06CE\u06D0-\u06D5\u06E5\u06E6\u200F\u202B\u202E\uFB1F-\uFB28\uFB2A-\uFB36\uFB38-\uFB3C\uFB3E\uFB40\uFB41\uFB43\uFB44\uFB46-\uFBB1\uFBD3-\uFD3D\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFB\uFE70-\uFE72\uFE74\uFE76-\uFEFC]/,
  lt = function () {
    var t = T("input", {
        dir: "auto",
        name: "x",
        dirName: "x.dir"
      }),
      e = T("textarea", {
        dir: "auto",
        name: "y",
        dirName: "y.dir"
      }),
      i = T("form");
    i.appendChild(t), i.appendChild(e);
    var n = function () {
        try {
          return new FormData(i).has(e.dirName);
        } catch (t) {
          return !1;
        }
      }(),
      r = function () {
        try {
          return t.matches(":dir(ltr),:dir(rtl)");
        } catch (t) {
          return !1;
        }
      }();
    return n ? function (t) {
      return e.value = t, new FormData(i).get(e.dirName);
    } : r ? function (e) {
      return t.value = e, t.matches(":dir(rtl)") ? "rtl" : "ltr";
    } : function (t) {
      var e = t.trim().charAt(0);
      return at.test(e) ? "rtl" : "ltr";
    };
  }();
var ct = null,
  ut = null,
  ht = null,
  dt = null;
var gt = function gt() {
    return ct || (ct = bt().concat(pt())), ct;
  },
  mt = function mt(t) {
    return n[t];
  },
  pt = function pt() {
    return ut || (ut = Object.keys(n)), ut;
  },
  ft = function ft(t) {
    return W[t];
  },
  bt = function bt() {
    return ht || (ht = Object.keys(W)), ht;
  },
  vt = function vt(t, e) {
    At(t).textContent = e.replace(/%t/g, t);
  },
  At = function At(t) {
    var e = document.createElement("style");
    e.setAttribute("type", "text/css"), e.setAttribute("data-tag-name", t.toLowerCase());
    var i = yt();
    return i && e.setAttribute("nonce", i), document.head.insertBefore(e, document.head.firstChild), e;
  },
  yt = function yt() {
    var t = xt("trix-csp-nonce") || xt("csp-nonce");
    if (t) {
      var _e6 = t.nonce,
        _i6 = t.content;
      return "" == _e6 ? _i6 : _e6;
    }
  },
  xt = function xt(t) {
    return document.head.querySelector("meta[name=".concat(t, "]"));
  },
  Ct = {
    "application/x-trix-feature-detection": "test"
  },
  Et = function Et(t) {
    var e = t.getData("text/plain"),
      i = t.getData("text/html");
    if (!e || !i) return null == e ? void 0 : e.length;
    {
      var _DOMParser$parseFromS = new DOMParser().parseFromString(i, "text/html"),
        _t3 = _DOMParser$parseFromS.body;
      if (_t3.textContent === e) return !_t3.querySelector("*");
    }
  },
  St = /Mac|^iP/.test(navigator.platform) ? function (t) {
    return t.metaKey;
  } : function (t) {
    return t.ctrlKey;
  };
var Rt = function Rt(t) {
    return setTimeout(t, 1);
  },
  kt = function kt() {
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {};
    var e = {};
    for (var _i7 in t) {
      var _n4 = t[_i7];
      e[_i7] = _n4;
    }
    return e;
  },
  Tt = function Tt() {
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {},
      e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
    if (Object.keys(t).length !== Object.keys(e).length) return !1;
    for (var _i8 in t) {
      if (t[_i8] !== e[_i8]) return !1;
    }
    return !0;
  },
  wt = function wt(t) {
    if (null != t) return Array.isArray(t) || (t = [t, t]), [Nt(t[0]), Nt(null != t[1] ? t[1] : t[0])];
  },
  Lt = function Lt(t) {
    if (null == t) return;
    var _wt = wt(t),
      _wt2 = _slicedToArray(_wt, 2),
      e = _wt2[0],
      i = _wt2[1];
    return It(e, i);
  },
  Dt = function Dt(t, e) {
    if (null == t || null == e) return;
    var _wt3 = wt(t),
      _wt4 = _slicedToArray(_wt3, 2),
      i = _wt4[0],
      n = _wt4[1],
      _wt5 = wt(e),
      _wt6 = _slicedToArray(_wt5, 2),
      r = _wt6[0],
      o = _wt6[1];
    return It(i, r) && It(n, o);
  },
  Nt = function Nt(t) {
    return "number" == typeof t ? t : kt(t);
  },
  It = function It(t, e) {
    return "number" == typeof t ? t === e : Tt(t, e);
  };
var Ot = /*#__PURE__*/function (_q3) {
  function Ot() {
    var _this3;
    _classCallCheck(this, Ot);
    _this3 = _callSuper(this, Ot, arguments), _this3.update = _this3.update.bind(_assertThisInitialized(_this3)), _this3.selectionManagers = [];
    return _this3;
  }
  _inherits(Ot, _q3);
  return _createClass(Ot, [{
    key: "start",
    value: function start() {
      this.started || (this.started = !0, document.addEventListener("selectionchange", this.update, !0));
    }
  }, {
    key: "stop",
    value: function stop() {
      if (this.started) return this.started = !1, document.removeEventListener("selectionchange", this.update, !0);
    }
  }, {
    key: "registerSelectionManager",
    value: function registerSelectionManager(t) {
      if (!this.selectionManagers.includes(t)) return this.selectionManagers.push(t), this.start();
    }
  }, {
    key: "unregisterSelectionManager",
    value: function unregisterSelectionManager(t) {
      if (this.selectionManagers = this.selectionManagers.filter(function (e) {
        return e !== t;
      }), 0 === this.selectionManagers.length) return this.stop();
    }
  }, {
    key: "notifySelectionManagersOfSelectionChange",
    value: function notifySelectionManagersOfSelectionChange() {
      return this.selectionManagers.map(function (t) {
        return t.selectionDidChange();
      });
    }
  }, {
    key: "update",
    value: function update() {
      this.notifySelectionManagersOfSelectionChange();
    }
  }, {
    key: "reset",
    value: function reset() {
      this.update();
    }
  }]);
}(q);
var Ft = new Ot(),
  Pt = function Pt() {
    var t = window.getSelection();
    if (t.rangeCount > 0) return t;
  },
  Mt = function Mt() {
    var t;
    var e = null === (t = Pt()) || void 0 === t ? void 0 : t.getRangeAt(0);
    if (e && !_t(e)) return e;
  },
  Bt = function Bt(t) {
    var e = window.getSelection();
    return e.removeAllRanges(), e.addRange(t), Ft.update();
  },
  _t = function _t(t) {
    return jt(t.startContainer) || jt(t.endContainer);
  },
  jt = function jt(t) {
    return !Object.getPrototypeOf(t);
  },
  Wt = function Wt(t) {
    return t.replace(new RegExp("".concat(d), "g"), "").replace(new RegExp("".concat(g), "g"), " ");
  },
  Ut = new RegExp("[^\\S".concat(g, "]")),
  Vt = function Vt(t) {
    return t.replace(new RegExp("".concat(Ut.source), "g"), " ").replace(/\ {2,}/g, " ");
  },
  zt = function zt(t, e) {
    if (t.isEqualTo(e)) return ["", ""];
    var i = qt(t, e),
      n = i.utf16String.length;
    var r;
    if (n) {
      var _o = i.offset,
        _s = t.codepoints.slice(0, _o).concat(t.codepoints.slice(_o + n));
      r = qt(e, X.fromCodepoints(_s));
    } else r = qt(e, t);
    return [i.utf16String.toString(), r.utf16String.toString()];
  },
  qt = function qt(t, e) {
    var i = 0,
      n = t.length,
      r = e.length;
    for (; i < n && t.charAt(i).isEqualTo(e.charAt(i));) i++;
    for (; n > i + 1 && t.charAt(n - 1).isEqualTo(e.charAt(r - 1));) n--, r--;
    return {
      utf16String: t.slice(i, n),
      offset: i
    };
  };
var Ht = /*#__PURE__*/function (_rt) {
  function Ht() {
    var _this4;
    _classCallCheck(this, Ht);
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {};
    _this4 = _callSuper(this, Ht, arguments), _this4.values = Gt(t);
    return _this4;
  }
  _inherits(Ht, _rt);
  return _createClass(Ht, [{
    key: "add",
    value: function add(t, e) {
      return this.merge(Jt(t, e));
    }
  }, {
    key: "remove",
    value: function remove(t) {
      return new Ht(Gt(this.values, t));
    }
  }, {
    key: "get",
    value: function get(t) {
      return this.values[t];
    }
  }, {
    key: "has",
    value: function has(t) {
      return t in this.values;
    }
  }, {
    key: "merge",
    value: function merge(t) {
      return new Ht(Kt(this.values, $t(t)));
    }
  }, {
    key: "slice",
    value: function slice(t) {
      var _this5 = this;
      var e = {};
      return Array.from(t).forEach(function (t) {
        _this5.has(t) && (e[t] = _this5.values[t]);
      }), new Ht(e);
    }
  }, {
    key: "getKeys",
    value: function getKeys() {
      return Object.keys(this.values);
    }
  }, {
    key: "getKeysCommonToHash",
    value: function getKeysCommonToHash(t) {
      var _this6 = this;
      return t = Yt(t), this.getKeys().filter(function (e) {
        return _this6.values[e] === t.values[e];
      });
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      return ot(this.toArray(), Yt(t).toArray());
    }
  }, {
    key: "isEmpty",
    value: function isEmpty() {
      return 0 === this.getKeys().length;
    }
  }, {
    key: "toArray",
    value: function toArray() {
      if (!this.array) {
        var _t4 = [];
        for (var _e7 in this.values) {
          var _i9 = this.values[_e7];
          _t4.push(_t4.push(_e7, _i9));
        }
        this.array = _t4.slice(0);
      }
      return this.array;
    }
  }, {
    key: "toObject",
    value: function toObject() {
      return Gt(this.values);
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return this.toObject();
    }
  }, {
    key: "contentsForInspection",
    value: function contentsForInspection() {
      return {
        values: JSON.stringify(this.values)
      };
    }
  }], [{
    key: "fromCommonAttributesOfObjects",
    value: function fromCommonAttributesOfObjects() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
      if (!t.length) return new this();
      var e = Yt(t[0]),
        i = e.getKeys();
      return t.slice(1).forEach(function (t) {
        i = e.getKeysCommonToHash(Yt(t)), e = e.slice(i);
      }), e;
    }
  }, {
    key: "box",
    value: function box(t) {
      return Yt(t);
    }
  }]);
}(rt);
var Jt = function Jt(t, e) {
    var i = {};
    return i[t] = e, i;
  },
  Kt = function Kt(t, e) {
    var i = Gt(t);
    for (var _t5 in e) {
      var _n5 = e[_t5];
      i[_t5] = _n5;
    }
    return i;
  },
  Gt = function Gt(t, e) {
    var i = {};
    return Object.keys(t).sort().forEach(function (n) {
      n !== e && (i[n] = t[n]);
    }), i;
  },
  Yt = function Yt(t) {
    return t instanceof Ht ? t : new Ht(t);
  },
  $t = function $t(t) {
    return t instanceof Ht ? t.values : t;
  };
var Xt = /*#__PURE__*/function () {
  function Xt() {
    _classCallCheck(this, Xt);
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [],
      _ref7 = arguments.length > 1 ? arguments[1] : void 0,
      e = _ref7.depth,
      i = _ref7.asTree;
    this.objects = t, i && (this.depth = e, this.objects = this.constructor.groupObjects(this.objects, {
      asTree: i,
      depth: this.depth + 1
    }));
  }
  return _createClass(Xt, [{
    key: "getObjects",
    value: function getObjects() {
      return this.objects;
    }
  }, {
    key: "getDepth",
    value: function getDepth() {
      return this.depth;
    }
  }, {
    key: "getCacheKey",
    value: function getCacheKey() {
      var t = ["objectGroup"];
      return Array.from(this.getObjects()).forEach(function (e) {
        t.push(e.getCacheKey());
      }), t.join("/");
    }
  }], [{
    key: "groupObjects",
    value: function groupObjects() {
      var _this7 = this;
      var t,
        e = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [],
        _ref8 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
        i = _ref8.depth,
        n = _ref8.asTree;
      n && null == i && (i = 0);
      var r = [];
      return Array.from(e).forEach(function (e) {
        var o;
        if (t) {
          var s, a, l;
          if (null !== (s = e.canBeGrouped) && void 0 !== s && s.call(e, i) && null !== (a = (l = t[t.length - 1]).canBeGroupedWith) && void 0 !== a && a.call(l, e, i)) return void t.push(e);
          r.push(new _this7(t, {
            depth: i,
            asTree: n
          })), t = null;
        }
        null !== (o = e.canBeGrouped) && void 0 !== o && o.call(e, i) ? t = [e] : r.push(e);
      }), t && r.push(new this(t, {
        depth: i,
        asTree: n
      })), r;
    }
  }]);
}();
var Zt = /*#__PURE__*/function (_q4) {
  function Zt() {
    var _this8;
    _classCallCheck(this, Zt);
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
    _this8 = _callSuper(this, Zt, arguments), _this8.objects = {}, Array.from(t).forEach(function (t) {
      var e = JSON.stringify(t);
      null == _this8.objects[e] && (_this8.objects[e] = t);
    });
    return _this8;
  }
  _inherits(Zt, _q4);
  return _createClass(Zt, [{
    key: "find",
    value: function find(t) {
      var e = JSON.stringify(t);
      return this.objects[e];
    }
  }]);
}(q);
var Qt = /*#__PURE__*/function () {
  function Qt(t) {
    _classCallCheck(this, Qt);
    this.reset(t);
  }
  return _createClass(Qt, [{
    key: "add",
    value: function add(t) {
      var e = te(t);
      this.elements[e] = t;
    }
  }, {
    key: "remove",
    value: function remove(t) {
      var e = te(t),
        i = this.elements[e];
      if (i) return delete this.elements[e], i;
    }
  }, {
    key: "reset",
    value: function reset() {
      var _this9 = this;
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
      return this.elements = {}, Array.from(t).forEach(function (t) {
        _this9.add(t);
      }), t;
    }
  }]);
}();
var te = function te(t) {
  return t.dataset.trixStoreKey;
};
var ee = /*#__PURE__*/function (_q5) {
  function ee() {
    _classCallCheck(this, ee);
    return _callSuper(this, ee, arguments);
  }
  _inherits(ee, _q5);
  return _createClass(ee, [{
    key: "isPerforming",
    value: function isPerforming() {
      return !0 === this.performing;
    }
  }, {
    key: "hasPerformed",
    value: function hasPerformed() {
      return !0 === this.performed;
    }
  }, {
    key: "hasSucceeded",
    value: function hasSucceeded() {
      return this.performed && this.succeeded;
    }
  }, {
    key: "hasFailed",
    value: function hasFailed() {
      return this.performed && !this.succeeded;
    }
  }, {
    key: "getPromise",
    value: function getPromise() {
      var _this0 = this;
      return this.promise || (this.promise = new Promise(function (t, e) {
        return _this0.performing = !0, _this0.perform(function (i, n) {
          _this0.succeeded = i, _this0.performing = !1, _this0.performed = !0, _this0.succeeded ? t(n) : e(n);
        });
      })), this.promise;
    }
  }, {
    key: "perform",
    value: function perform(t) {
      return t(!1);
    }
  }, {
    key: "release",
    value: function release() {
      var t, e;
      null === (t = this.promise) || void 0 === t || null === (e = t.cancel) || void 0 === e || e.call(t), this.promise = null, this.performing = null, this.performed = null, this.succeeded = null;
    }
  }]);
}(q);
ee.proxyMethod("getPromise().then"), ee.proxyMethod("getPromise().catch");
var ie = /*#__PURE__*/function (_q6) {
  function ie(t) {
    var _this1;
    _classCallCheck(this, ie);
    var e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
    _this1 = _callSuper(this, ie, arguments), _this1.object = t, _this1.options = e, _this1.childViews = [], _this1.rootView = _assertThisInitialized(_this1);
    return _this1;
  }
  _inherits(ie, _q6);
  return _createClass(ie, [{
    key: "getNodes",
    value: function getNodes() {
      return this.nodes || (this.nodes = this.createNodes()), this.nodes.map(function (t) {
        return t.cloneNode(!0);
      });
    }
  }, {
    key: "invalidate",
    value: function invalidate() {
      var t;
      return this.nodes = null, this.childViews = [], null === (t = this.parentView) || void 0 === t ? void 0 : t.invalidate();
    }
  }, {
    key: "invalidateViewForObject",
    value: function invalidateViewForObject(t) {
      var e;
      return null === (e = this.findViewForObject(t)) || void 0 === e ? void 0 : e.invalidate();
    }
  }, {
    key: "findOrCreateCachedChildView",
    value: function findOrCreateCachedChildView(t, e, i) {
      var n = this.getCachedViewForObject(e);
      return n ? this.recordChildView(n) : (n = this.createChildView.apply(this, arguments), this.cacheViewForObject(n, e)), n;
    }
  }, {
    key: "createChildView",
    value: function createChildView(t, e) {
      var i = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : {};
      e instanceof Xt && (i.viewClass = t, t = ne);
      var n = new t(e, i);
      return this.recordChildView(n);
    }
  }, {
    key: "recordChildView",
    value: function recordChildView(t) {
      return t.parentView = this, t.rootView = this.rootView, this.childViews.push(t), t;
    }
  }, {
    key: "getAllChildViews",
    value: function getAllChildViews() {
      var t = [];
      return this.childViews.forEach(function (e) {
        t.push(e), t = t.concat(e.getAllChildViews());
      }), t;
    }
  }, {
    key: "findElement",
    value: function findElement() {
      return this.findElementForObject(this.object);
    }
  }, {
    key: "findElementForObject",
    value: function findElementForObject(t) {
      var e = null == t ? void 0 : t.id;
      if (e) return this.rootView.element.querySelector("[data-trix-id='".concat(e, "']"));
    }
  }, {
    key: "findViewForObject",
    value: function findViewForObject(t) {
      var _iterator = _createForOfIteratorHelper(this.getAllChildViews()),
        _step;
      try {
        for (_iterator.s(); !(_step = _iterator.n()).done;) {
          var _e8 = _step.value;
          if (_e8.object === t) return _e8;
        }
      } catch (err) {
        _iterator.e(err);
      } finally {
        _iterator.f();
      }
    }
  }, {
    key: "getViewCache",
    value: function getViewCache() {
      return this.rootView !== this ? this.rootView.getViewCache() : this.isViewCachingEnabled() ? (this.viewCache || (this.viewCache = {}), this.viewCache) : void 0;
    }
  }, {
    key: "isViewCachingEnabled",
    value: function isViewCachingEnabled() {
      return !1 !== this.shouldCacheViews;
    }
  }, {
    key: "enableViewCaching",
    value: function enableViewCaching() {
      this.shouldCacheViews = !0;
    }
  }, {
    key: "disableViewCaching",
    value: function disableViewCaching() {
      this.shouldCacheViews = !1;
    }
  }, {
    key: "getCachedViewForObject",
    value: function getCachedViewForObject(t) {
      var e;
      return null === (e = this.getViewCache()) || void 0 === e ? void 0 : e[t.getCacheKey()];
    }
  }, {
    key: "cacheViewForObject",
    value: function cacheViewForObject(t, e) {
      var i = this.getViewCache();
      i && (i[e.getCacheKey()] = t);
    }
  }, {
    key: "garbageCollectCachedViews",
    value: function garbageCollectCachedViews() {
      var t = this.getViewCache();
      if (t) {
        var _e9 = this.getAllChildViews().concat(this).map(function (t) {
          return t.object.getCacheKey();
        });
        for (var _i0 in t) _e9.includes(_i0) || delete t[_i0];
      }
    }
  }]);
}(q);
var ne = /*#__PURE__*/function (_ie) {
  function ne() {
    var _this10;
    _classCallCheck(this, ne);
    _this10 = _callSuper(this, ne, arguments), _this10.objectGroup = _this10.object, _this10.viewClass = _this10.options.viewClass, delete _this10.options.viewClass;
    return _this10;
  }
  _inherits(ne, _ie);
  return _createClass(ne, [{
    key: "getChildViews",
    value: function getChildViews() {
      var _this11 = this;
      return this.childViews.length || Array.from(this.objectGroup.getObjects()).forEach(function (t) {
        _this11.findOrCreateCachedChildView(_this11.viewClass, t, _this11.options);
      }), this.childViews;
    }
  }, {
    key: "createNodes",
    value: function createNodes() {
      var t = this.createContainerElement();
      return this.getChildViews().forEach(function (e) {
        Array.from(e.getNodes()).forEach(function (e) {
          t.appendChild(e);
        });
      }), [t];
    }
  }, {
    key: "createContainerElement",
    value: function createContainerElement() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : this.objectGroup.getDepth();
      return this.getChildViews()[0].createContainerElement(t);
    }
  }]);
}(ie);
/*! @license DOMPurify 3.2.5 | (c) Cure53 and other contributors | Released under the Apache license 2.0 and Mozilla Public License 2.0 | github.com/cure53/DOMPurify/blob/3.2.5/LICENSE */
var re = Object.entries,
  oe = Object.setPrototypeOf,
  se = Object.isFrozen,
  ae = Object.getPrototypeOf,
  le = Object.getOwnPropertyDescriptor;
var ce = Object.freeze,
  ue = Object.seal,
  he = Object.create,
  _ref9 = "undefined" != typeof Reflect && Reflect,
  de = _ref9.apply,
  ge = _ref9.construct;
ce || (ce = function ce(t) {
  return t;
}), ue || (ue = function ue(t) {
  return t;
}), de || (de = function de(t, e, i) {
  return t.apply(e, i);
}), ge || (ge = function ge(t, e) {
  return _construct(t, _toConsumableArray(e));
});
var me = Le(Array.prototype.forEach),
  pe = Le(Array.prototype.lastIndexOf),
  fe = Le(Array.prototype.pop),
  be = Le(Array.prototype.push),
  ve = Le(Array.prototype.splice),
  Ae = Le(String.prototype.toLowerCase),
  ye = Le(String.prototype.toString),
  xe = Le(String.prototype.match),
  Ce = Le(String.prototype.replace),
  Ee = Le(String.prototype.indexOf),
  Se = Le(String.prototype.trim),
  Re = Le(Object.prototype.hasOwnProperty),
  ke = Le(RegExp.prototype.test),
  Te = (we = TypeError, function () {
    for (var t = arguments.length, e = new Array(t), i = 0; i < t; i++) e[i] = arguments[i];
    return ge(we, e);
  });
var we;
function Le(t) {
  return function (e) {
    e instanceof RegExp && (e.lastIndex = 0);
    for (var i = arguments.length, n = new Array(i > 1 ? i - 1 : 0), r = 1; r < i; r++) n[r - 1] = arguments[r];
    return de(t, e, n);
  };
}
function De(t, e) {
  var i = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : Ae;
  oe && oe(t, null);
  var n = e.length;
  for (; n--;) {
    var _r3 = e[n];
    if ("string" == typeof _r3) {
      var _t6 = i(_r3);
      _t6 !== _r3 && (se(e) || (e[n] = _t6), _r3 = _t6);
    }
    t[_r3] = !0;
  }
  return t;
}
function Ne(t) {
  for (var _e0 = 0; _e0 < t.length; _e0++) {
    Re(t, _e0) || (t[_e0] = null);
  }
  return t;
}
function Ie(t) {
  var e = he(null);
  var _iterator2 = _createForOfIteratorHelper(re(t)),
    _step2;
  try {
    for (_iterator2.s(); !(_step2 = _iterator2.n()).done;) {
      var _ref0 = _step2.value;
      var _ref1 = _slicedToArray(_ref0, 2);
      var _i1 = _ref1[0];
      var _n6 = _ref1[1];
      Re(t, _i1) && (Array.isArray(_n6) ? e[_i1] = Ne(_n6) : _n6 && "object" == _typeof(_n6) && _n6.constructor === Object ? e[_i1] = Ie(_n6) : e[_i1] = _n6);
    }
  } catch (err) {
    _iterator2.e(err);
  } finally {
    _iterator2.f();
  }
  return e;
}
function Oe(t, e) {
  for (; null !== t;) {
    var _i10 = le(t, e);
    if (_i10) {
      if (_i10.get) return Le(_i10.get);
      if ("function" == typeof _i10.value) return Le(_i10.value);
    }
    t = ae(t);
  }
  return function () {
    return null;
  };
}
var Fe = ce(["a", "abbr", "acronym", "address", "area", "article", "aside", "audio", "b", "bdi", "bdo", "big", "blink", "blockquote", "body", "br", "button", "canvas", "caption", "center", "cite", "code", "col", "colgroup", "content", "data", "datalist", "dd", "decorator", "del", "details", "dfn", "dialog", "dir", "div", "dl", "dt", "element", "em", "fieldset", "figcaption", "figure", "font", "footer", "form", "h1", "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html", "i", "img", "input", "ins", "kbd", "label", "legend", "li", "main", "map", "mark", "marquee", "menu", "menuitem", "meter", "nav", "nobr", "ol", "optgroup", "option", "output", "p", "picture", "pre", "progress", "q", "rp", "rt", "ruby", "s", "samp", "section", "select", "shadow", "small", "source", "spacer", "span", "strike", "strong", "style", "sub", "summary", "sup", "table", "tbody", "td", "template", "textarea", "tfoot", "th", "thead", "time", "tr", "track", "tt", "u", "ul", "var", "video", "wbr"]),
  Pe = ce(["svg", "a", "altglyph", "altglyphdef", "altglyphitem", "animatecolor", "animatemotion", "animatetransform", "circle", "clippath", "defs", "desc", "ellipse", "filter", "font", "g", "glyph", "glyphref", "hkern", "image", "line", "lineargradient", "marker", "mask", "metadata", "mpath", "path", "pattern", "polygon", "polyline", "radialgradient", "rect", "stop", "style", "switch", "symbol", "text", "textpath", "title", "tref", "tspan", "view", "vkern"]),
  Me = ce(["feBlend", "feColorMatrix", "feComponentTransfer", "feComposite", "feConvolveMatrix", "feDiffuseLighting", "feDisplacementMap", "feDistantLight", "feDropShadow", "feFlood", "feFuncA", "feFuncB", "feFuncG", "feFuncR", "feGaussianBlur", "feImage", "feMerge", "feMergeNode", "feMorphology", "feOffset", "fePointLight", "feSpecularLighting", "feSpotLight", "feTile", "feTurbulence"]),
  Be = ce(["animate", "color-profile", "cursor", "discard", "font-face", "font-face-format", "font-face-name", "font-face-src", "font-face-uri", "foreignobject", "hatch", "hatchpath", "mesh", "meshgradient", "meshpatch", "meshrow", "missing-glyph", "script", "set", "solidcolor", "unknown", "use"]),
  _e = ce(["math", "menclose", "merror", "mfenced", "mfrac", "mglyph", "mi", "mlabeledtr", "mmultiscripts", "mn", "mo", "mover", "mpadded", "mphantom", "mroot", "mrow", "ms", "mspace", "msqrt", "mstyle", "msub", "msup", "msubsup", "mtable", "mtd", "mtext", "mtr", "munder", "munderover", "mprescripts"]),
  je = ce(["maction", "maligngroup", "malignmark", "mlongdiv", "mscarries", "mscarry", "msgroup", "mstack", "msline", "msrow", "semantics", "annotation", "annotation-xml", "mprescripts", "none"]),
  We = ce(["#text"]),
  Ue = ce(["accept", "action", "align", "alt", "autocapitalize", "autocomplete", "autopictureinpicture", "autoplay", "background", "bgcolor", "border", "capture", "cellpadding", "cellspacing", "checked", "cite", "class", "clear", "color", "cols", "colspan", "controls", "controlslist", "coords", "crossorigin", "datetime", "decoding", "default", "dir", "disabled", "disablepictureinpicture", "disableremoteplayback", "download", "draggable", "enctype", "enterkeyhint", "face", "for", "headers", "height", "hidden", "high", "href", "hreflang", "id", "inputmode", "integrity", "ismap", "kind", "label", "lang", "list", "loading", "loop", "low", "max", "maxlength", "media", "method", "min", "minlength", "multiple", "muted", "name", "nonce", "noshade", "novalidate", "nowrap", "open", "optimum", "pattern", "placeholder", "playsinline", "popover", "popovertarget", "popovertargetaction", "poster", "preload", "pubdate", "radiogroup", "readonly", "rel", "required", "rev", "reversed", "role", "rows", "rowspan", "spellcheck", "scope", "selected", "shape", "size", "sizes", "span", "srclang", "start", "src", "srcset", "step", "style", "summary", "tabindex", "title", "translate", "type", "usemap", "valign", "value", "width", "wrap", "xmlns", "slot"]),
  Ve = ce(["accent-height", "accumulate", "additive", "alignment-baseline", "amplitude", "ascent", "attributename", "attributetype", "azimuth", "basefrequency", "baseline-shift", "begin", "bias", "by", "class", "clip", "clippathunits", "clip-path", "clip-rule", "color", "color-interpolation", "color-interpolation-filters", "color-profile", "color-rendering", "cx", "cy", "d", "dx", "dy", "diffuseconstant", "direction", "display", "divisor", "dur", "edgemode", "elevation", "end", "exponent", "fill", "fill-opacity", "fill-rule", "filter", "filterunits", "flood-color", "flood-opacity", "font-family", "font-size", "font-size-adjust", "font-stretch", "font-style", "font-variant", "font-weight", "fx", "fy", "g1", "g2", "glyph-name", "glyphref", "gradientunits", "gradienttransform", "height", "href", "id", "image-rendering", "in", "in2", "intercept", "k", "k1", "k2", "k3", "k4", "kerning", "keypoints", "keysplines", "keytimes", "lang", "lengthadjust", "letter-spacing", "kernelmatrix", "kernelunitlength", "lighting-color", "local", "marker-end", "marker-mid", "marker-start", "markerheight", "markerunits", "markerwidth", "maskcontentunits", "maskunits", "max", "mask", "media", "method", "mode", "min", "name", "numoctaves", "offset", "operator", "opacity", "order", "orient", "orientation", "origin", "overflow", "paint-order", "path", "pathlength", "patterncontentunits", "patterntransform", "patternunits", "points", "preservealpha", "preserveaspectratio", "primitiveunits", "r", "rx", "ry", "radius", "refx", "refy", "repeatcount", "repeatdur", "restart", "result", "rotate", "scale", "seed", "shape-rendering", "slope", "specularconstant", "specularexponent", "spreadmethod", "startoffset", "stddeviation", "stitchtiles", "stop-color", "stop-opacity", "stroke-dasharray", "stroke-dashoffset", "stroke-linecap", "stroke-linejoin", "stroke-miterlimit", "stroke-opacity", "stroke", "stroke-width", "style", "surfacescale", "systemlanguage", "tabindex", "tablevalues", "targetx", "targety", "transform", "transform-origin", "text-anchor", "text-decoration", "text-rendering", "textlength", "type", "u1", "u2", "unicode", "values", "viewbox", "visibility", "version", "vert-adv-y", "vert-origin-x", "vert-origin-y", "width", "word-spacing", "wrap", "writing-mode", "xchannelselector", "ychannelselector", "x", "x1", "x2", "xmlns", "y", "y1", "y2", "z", "zoomandpan"]),
  ze = ce(["accent", "accentunder", "align", "bevelled", "close", "columnsalign", "columnlines", "columnspan", "denomalign", "depth", "dir", "display", "displaystyle", "encoding", "fence", "frame", "height", "href", "id", "largeop", "length", "linethickness", "lspace", "lquote", "mathbackground", "mathcolor", "mathsize", "mathvariant", "maxsize", "minsize", "movablelimits", "notation", "numalign", "open", "rowalign", "rowlines", "rowspacing", "rowspan", "rspace", "rquote", "scriptlevel", "scriptminsize", "scriptsizemultiplier", "selection", "separator", "separators", "stretchy", "subscriptshift", "supscriptshift", "symmetric", "voffset", "width", "xmlns"]),
  qe = ce(["xlink:href", "xml:id", "xlink:title", "xml:space", "xmlns:xlink"]),
  He = ue(/\{\{[\w\W]*|[\w\W]*\}\}/gm),
  Je = ue(/<%[\w\W]*|[\w\W]*%>/gm),
  Ke = ue(/\$\{[\w\W]*/gm),
  Ge = ue(/^data-[\-\w.\u00B7-\uFFFF]+$/),
  Ye = ue(/^aria-[\-\w]+$/),
  $e = ue(/^(?:(?:(?:f|ht)tps?|mailto|tel|callto|sms|cid|xmpp):|[^a-z]|[a-z+.\-]+(?:[^a-z+.\-:]|$))/i),
  Xe = ue(/^(?:\w+script|data):/i),
  Ze = ue(/[\u0000-\u0020\u00A0\u1680\u180E\u2000-\u2029\u205F\u3000]/g),
  Qe = ue(/^html$/i),
  ti = ue(/^[a-z][.\w]*(-[.\w]+)+$/i);
var ei = Object.freeze({
  __proto__: null,
  ARIA_ATTR: Ye,
  ATTR_WHITESPACE: Ze,
  CUSTOM_ELEMENT: ti,
  DATA_ATTR: Ge,
  DOCTYPE_NAME: Qe,
  ERB_EXPR: Je,
  IS_ALLOWED_URI: $e,
  IS_SCRIPT_OR_DATA: Xe,
  MUSTACHE_EXPR: He,
  TMPLIT_EXPR: Ke
});
var ii = 1,
  ni = 3,
  ri = 7,
  oi = 8,
  si = 9,
  ai = function ai() {
    return "undefined" == typeof window ? null : window;
  };
var li = function t() {
  var e = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : ai();
  var i = function i(e) {
    return t(e);
  };
  if (i.version = "3.2.5", i.removed = [], !e || !e.document || e.document.nodeType !== si || !e.Element) return i.isSupported = !1, i;
  var n = e.document;
  var r = n,
    o = r.currentScript,
    s = e.DocumentFragment,
    a = e.HTMLTemplateElement,
    l = e.Node,
    c = e.Element,
    u = e.NodeFilter,
    _e$NamedNodeMap = e.NamedNodeMap,
    h = _e$NamedNodeMap === void 0 ? e.NamedNodeMap || e.MozNamedAttrMap : _e$NamedNodeMap,
    d = e.HTMLFormElement,
    g = e.DOMParser,
    m = e.trustedTypes,
    p = c.prototype,
    f = Oe(p, "cloneNode"),
    b = Oe(p, "remove"),
    v = Oe(p, "nextSibling"),
    A = Oe(p, "childNodes"),
    y = Oe(p, "parentNode");
  if ("function" == typeof a) {
    var _t7 = n.createElement("template");
    _t7.content && _t7.content.ownerDocument && (n = _t7.content.ownerDocument);
  }
  var x,
    C = "";
  var _n7 = n,
    E = _n7.implementation,
    S = _n7.createNodeIterator,
    R = _n7.createDocumentFragment,
    k = _n7.getElementsByTagName,
    T = r.importNode;
  var w = {
    afterSanitizeAttributes: [],
    afterSanitizeElements: [],
    afterSanitizeShadowDOM: [],
    beforeSanitizeAttributes: [],
    beforeSanitizeElements: [],
    beforeSanitizeShadowDOM: [],
    uponSanitizeAttribute: [],
    uponSanitizeElement: [],
    uponSanitizeShadowNode: []
  };
  i.isSupported = "function" == typeof re && "function" == typeof y && E && void 0 !== E.createHTMLDocument;
  var L = ei.MUSTACHE_EXPR,
    D = ei.ERB_EXPR,
    N = ei.TMPLIT_EXPR,
    I = ei.DATA_ATTR,
    O = ei.ARIA_ATTR,
    F = ei.IS_SCRIPT_OR_DATA,
    P = ei.ATTR_WHITESPACE,
    M = ei.CUSTOM_ELEMENT;
  var B = ei.IS_ALLOWED_URI,
    _ = null;
  var j = De({}, [].concat(_toConsumableArray(Fe), _toConsumableArray(Pe), _toConsumableArray(Me), _toConsumableArray(_e), _toConsumableArray(We)));
  var W = null;
  var U = De({}, [].concat(_toConsumableArray(Ue), _toConsumableArray(Ve), _toConsumableArray(ze), _toConsumableArray(qe)));
  var V = Object.seal(he(null, {
      tagNameCheck: {
        writable: !0,
        configurable: !1,
        enumerable: !0,
        value: null
      },
      attributeNameCheck: {
        writable: !0,
        configurable: !1,
        enumerable: !0,
        value: null
      },
      allowCustomizedBuiltInElements: {
        writable: !0,
        configurable: !1,
        enumerable: !0,
        value: !1
      }
    })),
    z = null,
    q = null,
    H = !0,
    J = !0,
    K = !1,
    G = !0,
    Y = !1,
    $ = !0,
    X = !1,
    Z = !1,
    Q = !1,
    tt = !1,
    et = !1,
    it = !1,
    nt = !0,
    rt = !1,
    ot = !0,
    st = !1,
    at = {},
    lt = null;
  var ct = De({}, ["annotation-xml", "audio", "colgroup", "desc", "foreignobject", "head", "iframe", "math", "mi", "mn", "mo", "ms", "mtext", "noembed", "noframes", "noscript", "plaintext", "script", "style", "svg", "template", "thead", "title", "video", "xmp"]);
  var ut = null;
  var ht = De({}, ["audio", "video", "img", "source", "image", "track"]);
  var dt = null;
  var gt = De({}, ["alt", "class", "for", "id", "label", "name", "pattern", "placeholder", "role", "summary", "title", "value", "style", "xmlns"]),
    mt = "http://www.w3.org/1998/Math/MathML",
    pt = "http://www.w3.org/2000/svg",
    ft = "http://www.w3.org/1999/xhtml";
  var bt = ft,
    vt = !1,
    At = null;
  var yt = De({}, [mt, pt, ft], ye);
  var xt = De({}, ["mi", "mo", "mn", "ms", "mtext"]),
    Ct = De({}, ["annotation-xml"]);
  var Et = De({}, ["title", "style", "font", "a", "script"]);
  var St = null;
  var Rt = ["application/xhtml+xml", "text/html"];
  var kt = null,
    Tt = null;
  var wt = n.createElement("form"),
    Lt = function Lt(t) {
      return t instanceof RegExp || t instanceof Function;
    },
    Dt = function Dt() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {};
      if (!Tt || Tt !== t) {
        if (t && "object" == _typeof(t) || (t = {}), t = Ie(t), St = -1 === Rt.indexOf(t.PARSER_MEDIA_TYPE) ? "text/html" : t.PARSER_MEDIA_TYPE, kt = "application/xhtml+xml" === St ? ye : Ae, _ = Re(t, "ALLOWED_TAGS") ? De({}, t.ALLOWED_TAGS, kt) : j, W = Re(t, "ALLOWED_ATTR") ? De({}, t.ALLOWED_ATTR, kt) : U, At = Re(t, "ALLOWED_NAMESPACES") ? De({}, t.ALLOWED_NAMESPACES, ye) : yt, dt = Re(t, "ADD_URI_SAFE_ATTR") ? De(Ie(gt), t.ADD_URI_SAFE_ATTR, kt) : gt, ut = Re(t, "ADD_DATA_URI_TAGS") ? De(Ie(ht), t.ADD_DATA_URI_TAGS, kt) : ht, lt = Re(t, "FORBID_CONTENTS") ? De({}, t.FORBID_CONTENTS, kt) : ct, z = Re(t, "FORBID_TAGS") ? De({}, t.FORBID_TAGS, kt) : {}, q = Re(t, "FORBID_ATTR") ? De({}, t.FORBID_ATTR, kt) : {}, at = !!Re(t, "USE_PROFILES") && t.USE_PROFILES, H = !1 !== t.ALLOW_ARIA_ATTR, J = !1 !== t.ALLOW_DATA_ATTR, K = t.ALLOW_UNKNOWN_PROTOCOLS || !1, G = !1 !== t.ALLOW_SELF_CLOSE_IN_ATTR, Y = t.SAFE_FOR_TEMPLATES || !1, $ = !1 !== t.SAFE_FOR_XML, X = t.WHOLE_DOCUMENT || !1, tt = t.RETURN_DOM || !1, et = t.RETURN_DOM_FRAGMENT || !1, it = t.RETURN_TRUSTED_TYPE || !1, Q = t.FORCE_BODY || !1, nt = !1 !== t.SANITIZE_DOM, rt = t.SANITIZE_NAMED_PROPS || !1, ot = !1 !== t.KEEP_CONTENT, st = t.IN_PLACE || !1, B = t.ALLOWED_URI_REGEXP || $e, bt = t.NAMESPACE || ft, xt = t.MATHML_TEXT_INTEGRATION_POINTS || xt, Ct = t.HTML_INTEGRATION_POINTS || Ct, V = t.CUSTOM_ELEMENT_HANDLING || {}, t.CUSTOM_ELEMENT_HANDLING && Lt(t.CUSTOM_ELEMENT_HANDLING.tagNameCheck) && (V.tagNameCheck = t.CUSTOM_ELEMENT_HANDLING.tagNameCheck), t.CUSTOM_ELEMENT_HANDLING && Lt(t.CUSTOM_ELEMENT_HANDLING.attributeNameCheck) && (V.attributeNameCheck = t.CUSTOM_ELEMENT_HANDLING.attributeNameCheck), t.CUSTOM_ELEMENT_HANDLING && "boolean" == typeof t.CUSTOM_ELEMENT_HANDLING.allowCustomizedBuiltInElements && (V.allowCustomizedBuiltInElements = t.CUSTOM_ELEMENT_HANDLING.allowCustomizedBuiltInElements), Y && (J = !1), et && (tt = !0), at && (_ = De({}, We), W = [], !0 === at.html && (De(_, Fe), De(W, Ue)), !0 === at.svg && (De(_, Pe), De(W, Ve), De(W, qe)), !0 === at.svgFilters && (De(_, Me), De(W, Ve), De(W, qe)), !0 === at.mathMl && (De(_, _e), De(W, ze), De(W, qe))), t.ADD_TAGS && (_ === j && (_ = Ie(_)), De(_, t.ADD_TAGS, kt)), t.ADD_ATTR && (W === U && (W = Ie(W)), De(W, t.ADD_ATTR, kt)), t.ADD_URI_SAFE_ATTR && De(dt, t.ADD_URI_SAFE_ATTR, kt), t.FORBID_CONTENTS && (lt === ct && (lt = Ie(lt)), De(lt, t.FORBID_CONTENTS, kt)), ot && (_["#text"] = !0), X && De(_, ["html", "head", "body"]), _.table && (De(_, ["tbody"]), delete z.tbody), t.TRUSTED_TYPES_POLICY) {
          if ("function" != typeof t.TRUSTED_TYPES_POLICY.createHTML) throw Te('TRUSTED_TYPES_POLICY configuration option must provide a "createHTML" hook.');
          if ("function" != typeof t.TRUSTED_TYPES_POLICY.createScriptURL) throw Te('TRUSTED_TYPES_POLICY configuration option must provide a "createScriptURL" hook.');
          x = t.TRUSTED_TYPES_POLICY, C = x.createHTML("");
        } else void 0 === x && (x = function (t, e) {
          if ("object" != _typeof(t) || "function" != typeof t.createPolicy) return null;
          var i = null;
          var n = "data-tt-policy-suffix";
          e && e.hasAttribute(n) && (i = e.getAttribute(n));
          var r = "dompurify" + (i ? "#" + i : "");
          try {
            return t.createPolicy(r, {
              createHTML: function createHTML(t) {
                return t;
              },
              createScriptURL: function createScriptURL(t) {
                return t;
              }
            });
          } catch (t) {
            return console.warn("TrustedTypes policy " + r + " could not be created."), null;
          }
        }(m, o)), null !== x && "string" == typeof C && (C = x.createHTML(""));
        ce && ce(t), Tt = t;
      }
    },
    Nt = De({}, [].concat(_toConsumableArray(Pe), _toConsumableArray(Me), _toConsumableArray(Be))),
    It = De({}, [].concat(_toConsumableArray(_e), _toConsumableArray(je))),
    Ot = function Ot(t) {
      be(i.removed, {
        element: t
      });
      try {
        y(t).removeChild(t);
      } catch (e) {
        b(t);
      }
    },
    Ft = function Ft(t, e) {
      try {
        be(i.removed, {
          attribute: e.getAttributeNode(t),
          from: e
        });
      } catch (t) {
        be(i.removed, {
          attribute: null,
          from: e
        });
      }
      if (e.removeAttribute(t), "is" === t) if (tt || et) try {
        Ot(e);
      } catch (t) {} else try {
        e.setAttribute(t, "");
      } catch (t) {}
    },
    Pt = function Pt(t) {
      var e = null,
        i = null;
      if (Q) t = "<remove></remove>" + t;else {
        var _e1 = xe(t, /^[\r\n\t ]+/);
        i = _e1 && _e1[0];
      }
      "application/xhtml+xml" === St && bt === ft && (t = '<html xmlns="http://www.w3.org/1999/xhtml"><head></head><body>' + t + "</body></html>");
      var r = x ? x.createHTML(t) : t;
      if (bt === ft) try {
        e = new g().parseFromString(r, St);
      } catch (t) {}
      if (!e || !e.documentElement) {
        e = E.createDocument(bt, "template", null);
        try {
          e.documentElement.innerHTML = vt ? C : r;
        } catch (t) {}
      }
      var o = e.body || e.documentElement;
      return t && i && o.insertBefore(n.createTextNode(i), o.childNodes[0] || null), bt === ft ? k.call(e, X ? "html" : "body")[0] : X ? e.documentElement : o;
    },
    Mt = function Mt(t) {
      return S.call(t.ownerDocument || t, t, u.SHOW_ELEMENT | u.SHOW_COMMENT | u.SHOW_TEXT | u.SHOW_PROCESSING_INSTRUCTION | u.SHOW_CDATA_SECTION, null);
    },
    Bt = function Bt(t) {
      return t instanceof d && ("string" != typeof t.nodeName || "string" != typeof t.textContent || "function" != typeof t.removeChild || !(t.attributes instanceof h) || "function" != typeof t.removeAttribute || "function" != typeof t.setAttribute || "string" != typeof t.namespaceURI || "function" != typeof t.insertBefore || "function" != typeof t.hasChildNodes);
    },
    _t = function _t(t) {
      return "function" == typeof l && t instanceof l;
    };
  function jt(t, e, n) {
    me(t, function (t) {
      t.call(i, e, n, Tt);
    });
  }
  var Wt = function Wt(t) {
      var e = null;
      if (jt(w.beforeSanitizeElements, t, null), Bt(t)) return Ot(t), !0;
      var n = kt(t.nodeName);
      if (jt(w.uponSanitizeElement, t, {
        tagName: n,
        allowedTags: _
      }), t.hasChildNodes() && !_t(t.firstElementChild) && ke(/<[/\w!]/g, t.innerHTML) && ke(/<[/\w!]/g, t.textContent)) return Ot(t), !0;
      if (t.nodeType === ri) return Ot(t), !0;
      if ($ && t.nodeType === oi && ke(/<[/\w]/g, t.data)) return Ot(t), !0;
      if (!_[n] || z[n]) {
        if (!z[n] && Vt(n)) {
          if (V.tagNameCheck instanceof RegExp && ke(V.tagNameCheck, n)) return !1;
          if (V.tagNameCheck instanceof Function && V.tagNameCheck(n)) return !1;
        }
        if (ot && !lt[n]) {
          var _e10 = y(t) || t.parentNode,
            _i11 = A(t) || t.childNodes;
          if (_i11 && _e10) {
            for (var _n8 = _i11.length - 1; _n8 >= 0; --_n8) {
              var _r4 = f(_i11[_n8], !0);
              _r4.__removalCount = (t.__removalCount || 0) + 1, _e10.insertBefore(_r4, v(t));
            }
          }
        }
        return Ot(t), !0;
      }
      return t instanceof c && !function (t) {
        var e = y(t);
        e && e.tagName || (e = {
          namespaceURI: bt,
          tagName: "template"
        });
        var i = Ae(t.tagName),
          n = Ae(e.tagName);
        return !!At[t.namespaceURI] && (t.namespaceURI === pt ? e.namespaceURI === ft ? "svg" === i : e.namespaceURI === mt ? "svg" === i && ("annotation-xml" === n || xt[n]) : Boolean(Nt[i]) : t.namespaceURI === mt ? e.namespaceURI === ft ? "math" === i : e.namespaceURI === pt ? "math" === i && Ct[n] : Boolean(It[i]) : t.namespaceURI === ft ? !(e.namespaceURI === pt && !Ct[n]) && !(e.namespaceURI === mt && !xt[n]) && !It[i] && (Et[i] || !Nt[i]) : !("application/xhtml+xml" !== St || !At[t.namespaceURI]));
      }(t) ? (Ot(t), !0) : "noscript" !== n && "noembed" !== n && "noframes" !== n || !ke(/<\/no(script|embed|frames)/i, t.innerHTML) ? (Y && t.nodeType === ni && (e = t.textContent, me([L, D, N], function (t) {
        e = Ce(e, t, " ");
      }), t.textContent !== e && (be(i.removed, {
        element: t.cloneNode()
      }), t.textContent = e)), jt(w.afterSanitizeElements, t, null), !1) : (Ot(t), !0);
    },
    Ut = function Ut(t, e, i) {
      if (nt && ("id" === e || "name" === e) && (i in n || i in wt)) return !1;
      if (J && !q[e] && ke(I, e)) ;else if (H && ke(O, e)) ;else if (!W[e] || q[e]) {
        if (!(Vt(t) && (V.tagNameCheck instanceof RegExp && ke(V.tagNameCheck, t) || V.tagNameCheck instanceof Function && V.tagNameCheck(t)) && (V.attributeNameCheck instanceof RegExp && ke(V.attributeNameCheck, e) || V.attributeNameCheck instanceof Function && V.attributeNameCheck(e)) || "is" === e && V.allowCustomizedBuiltInElements && (V.tagNameCheck instanceof RegExp && ke(V.tagNameCheck, i) || V.tagNameCheck instanceof Function && V.tagNameCheck(i)))) return !1;
      } else if (dt[e]) ;else if (ke(B, Ce(i, P, ""))) ;else if ("src" !== e && "xlink:href" !== e && "href" !== e || "script" === t || 0 !== Ee(i, "data:") || !ut[t]) {
        if (K && !ke(F, Ce(i, P, ""))) ;else if (i) return !1;
      } else ;
      return !0;
    },
    Vt = function Vt(t) {
      return "annotation-xml" !== t && xe(t, M);
    },
    zt = function zt(t) {
      jt(w.beforeSanitizeAttributes, t, null);
      var e = t.attributes;
      if (!e || Bt(t)) return;
      var n = {
        attrName: "",
        attrValue: "",
        keepAttr: !0,
        allowedAttributes: W,
        forceKeepAttr: void 0
      };
      var r = e.length;
      var _loop = function _loop() {
          var o = e[r],
            s = o.name,
            a = o.namespaceURI,
            l = o.value,
            c = kt(s);
          var u = "value" === s ? l : Se(l);
          if (n.attrName = c, n.attrValue = u, n.keepAttr = !0, n.forceKeepAttr = void 0, jt(w.uponSanitizeAttribute, t, n), u = n.attrValue, !rt || "id" !== c && "name" !== c || (Ft(s, t), u = "user-content-" + u), $ && ke(/((--!?|])>)|<\/(style|title)/i, u)) {
            Ft(s, t);
            return 0; // continue
          }
          if (n.forceKeepAttr) return 0; // continue
          if (Ft(s, t), !n.keepAttr) return 0; // continue
          if (!G && ke(/\/>/i, u)) {
            Ft(s, t);
            return 0; // continue
          }
          Y && me([L, D, N], function (t) {
            u = Ce(u, t, " ");
          });
          var h = kt(t.nodeName);
          if (Ut(h, c, u)) {
            if (x && "object" == _typeof(m) && "function" == typeof m.getAttributeType) if (a) ;else switch (m.getAttributeType(h, c)) {
              case "TrustedHTML":
                u = x.createHTML(u);
                break;
              case "TrustedScriptURL":
                u = x.createScriptURL(u);
            }
            try {
              a ? t.setAttributeNS(a, s, u) : t.setAttribute(s, u), Bt(t) ? Ot(t) : fe(i.removed);
            } catch (t) {}
          }
        },
        _ret;
      for (; r--;) {
        _ret = _loop();
        if (_ret === 0) continue;
      }
      jt(w.afterSanitizeAttributes, t, null);
    },
    qt = function t(e) {
      var i = null;
      var n = Mt(e);
      for (jt(w.beforeSanitizeShadowDOM, e, null); i = n.nextNode();) jt(w.uponSanitizeShadowNode, i, null), Wt(i), zt(i), i.content instanceof s && t(i.content);
      jt(w.afterSanitizeShadowDOM, e, null);
    };
  return i.sanitize = function (t) {
    var e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      n = null,
      o = null,
      a = null,
      c = null;
    if (vt = !t, vt && (t = "\x3c!--\x3e"), "string" != typeof t && !_t(t)) {
      if ("function" != typeof t.toString) throw Te("toString is not a function");
      if ("string" != typeof (t = t.toString())) throw Te("dirty is not a string, aborting");
    }
    if (!i.isSupported) return t;
    if (Z || Dt(e), i.removed = [], "string" == typeof t && (st = !1), st) {
      if (t.nodeName) {
        var _e11 = kt(t.nodeName);
        if (!_[_e11] || z[_e11]) throw Te("root node is forbidden and cannot be sanitized in-place");
      }
    } else if (t instanceof l) n = Pt("\x3c!----\x3e"), o = n.ownerDocument.importNode(t, !0), o.nodeType === ii && "BODY" === o.nodeName || "HTML" === o.nodeName ? n = o : n.appendChild(o);else {
      if (!tt && !Y && !X && -1 === t.indexOf("<")) return x && it ? x.createHTML(t) : t;
      if (n = Pt(t), !n) return tt ? null : it ? C : "";
    }
    n && Q && Ot(n.firstChild);
    var u = Mt(st ? t : n);
    for (; a = u.nextNode();) Wt(a), zt(a), a.content instanceof s && qt(a.content);
    if (st) return t;
    if (tt) {
      if (et) for (c = R.call(n.ownerDocument); n.firstChild;) c.appendChild(n.firstChild);else c = n;
      return (W.shadowroot || W.shadowrootmode) && (c = T.call(r, c, !0)), c;
    }
    var h = X ? n.outerHTML : n.innerHTML;
    return X && _["!doctype"] && n.ownerDocument && n.ownerDocument.doctype && n.ownerDocument.doctype.name && ke(Qe, n.ownerDocument.doctype.name) && (h = "<!DOCTYPE " + n.ownerDocument.doctype.name + ">\n" + h), Y && me([L, D, N], function (t) {
      h = Ce(h, t, " ");
    }), x && it ? x.createHTML(h) : h;
  }, i.setConfig = function () {
    Dt(arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {}), Z = !0;
  }, i.clearConfig = function () {
    Tt = null, Z = !1;
  }, i.isValidAttribute = function (t, e, i) {
    Tt || Dt({});
    var n = kt(t),
      r = kt(e);
    return Ut(n, r, i);
  }, i.addHook = function (t, e) {
    "function" == typeof e && be(w[t], e);
  }, i.removeHook = function (t, e) {
    if (void 0 !== e) {
      var _i12 = pe(w[t], e);
      return -1 === _i12 ? void 0 : ve(w[t], _i12, 1)[0];
    }
    return fe(w[t]);
  }, i.removeHooks = function (t) {
    w[t] = [];
  }, i.removeAllHooks = function () {
    w = {
      afterSanitizeAttributes: [],
      afterSanitizeElements: [],
      afterSanitizeShadowDOM: [],
      beforeSanitizeAttributes: [],
      beforeSanitizeElements: [],
      beforeSanitizeShadowDOM: [],
      uponSanitizeAttribute: [],
      uponSanitizeElement: [],
      uponSanitizeShadowNode: []
    };
  }, i;
}();
li.addHook("uponSanitizeAttribute", function (t, e) {
  /^data-trix-/.test(e.attrName) && (e.forceKeepAttr = !0);
});
var ci = "style href src width height language class".split(" "),
  ui = "javascript:".split(" "),
  hi = "script iframe form noscript".split(" ");
var di = /*#__PURE__*/function (_q7) {
  function di(t) {
    var _this12;
    _classCallCheck(this, di);
    var _ref10 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      e = _ref10.allowedAttributes,
      i = _ref10.forbiddenProtocols,
      n = _ref10.forbiddenElements;
    _this12 = _callSuper(this, di, arguments), _this12.allowedAttributes = e || ci, _this12.forbiddenProtocols = i || ui, _this12.forbiddenElements = n || hi, _this12.body = gi(t);
    return _this12;
  }
  _inherits(di, _q7);
  return _createClass(di, [{
    key: "sanitize",
    value: function sanitize() {
      return this.sanitizeElements(), this.normalizeListElementNesting(), li.setConfig(l), this.body = li.sanitize(this.body), this.body;
    }
  }, {
    key: "getHTML",
    value: function getHTML() {
      return this.body.innerHTML;
    }
  }, {
    key: "getBody",
    value: function getBody() {
      return this.body;
    }
  }, {
    key: "sanitizeElements",
    value: function sanitizeElements() {
      var t = R(this.body),
        e = [];
      for (; t.nextNode();) {
        var _i13 = t.currentNode;
        switch (_i13.nodeType) {
          case Node.ELEMENT_NODE:
            this.elementIsRemovable(_i13) ? e.push(_i13) : this.sanitizeElement(_i13);
            break;
          case Node.COMMENT_NODE:
            e.push(_i13);
        }
      }
      return e.forEach(function (t) {
        return S(t);
      }), this.body;
    }
  }, {
    key: "sanitizeElement",
    value: function sanitizeElement(t) {
      var _this13 = this;
      return t.hasAttribute("href") && this.forbiddenProtocols.includes(t.protocol) && t.removeAttribute("href"), Array.from(t.attributes).forEach(function (e) {
        var i = e.name;
        _this13.allowedAttributes.includes(i) || 0 === i.indexOf("data-trix") || t.removeAttribute(i);
      }), t;
    }
  }, {
    key: "normalizeListElementNesting",
    value: function normalizeListElementNesting() {
      return Array.from(this.body.querySelectorAll("ul,ol")).forEach(function (t) {
        var e = t.previousElementSibling;
        e && "li" === k(e) && e.appendChild(t);
      }), this.body;
    }
  }, {
    key: "elementIsRemovable",
    value: function elementIsRemovable(t) {
      if ((null == t ? void 0 : t.nodeType) === Node.ELEMENT_NODE) return this.elementIsForbidden(t) || this.elementIsntSerializable(t);
    }
  }, {
    key: "elementIsForbidden",
    value: function elementIsForbidden(t) {
      return this.forbiddenElements.includes(k(t));
    }
  }, {
    key: "elementIsntSerializable",
    value: function elementIsntSerializable(t) {
      return "false" === t.getAttribute("data-trix-serialize") && !P(t);
    }
  }], [{
    key: "setHTML",
    value: function setHTML(t, e) {
      var i = new this(e).sanitize(),
        n = i.getHTML ? i.getHTML() : i.outerHTML;
      t.innerHTML = n;
    }
  }, {
    key: "sanitize",
    value: function sanitize(t, e) {
      var i = new this(t, e);
      return i.sanitize(), i;
    }
  }]);
}(q);
var gi = function gi() {
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : "";
    t = t.replace(/<\/html[^>]*>[^]*$/i, "</html>");
    var e = document.implementation.createHTMLDocument("");
    return e.documentElement.innerHTML = t, Array.from(e.head.querySelectorAll("style")).forEach(function (t) {
      e.body.appendChild(t);
    }), e.body;
  },
  mi = z.css;
var pi = /*#__PURE__*/function (_ie2) {
  function pi() {
    var _this14;
    _classCallCheck(this, pi);
    _this14 = _callSuper(this, pi, arguments), _this14.attachment = _this14.object, _this14.attachment.uploadProgressDelegate = _assertThisInitialized(_this14), _this14.attachmentPiece = _this14.options.piece;
    return _this14;
  }
  _inherits(pi, _ie2);
  return _createClass(pi, [{
    key: "createContentNodes",
    value: function createContentNodes() {
      return [];
    }
  }, {
    key: "createNodes",
    value: function createNodes() {
      var t;
      var e = t = T({
          tagName: "figure",
          className: this.getClassName(),
          data: this.getData(),
          editable: !1
        }),
        i = this.getHref();
      return i && (t = T({
        tagName: "a",
        editable: !1,
        attributes: {
          href: i,
          tabindex: -1
        }
      }), e.appendChild(t)), this.attachment.hasContent() ? di.setHTML(t, this.attachment.getContent()) : this.createContentNodes().forEach(function (e) {
        t.appendChild(e);
      }), t.appendChild(this.createCaptionElement()), this.attachment.isPending() && (this.progressElement = T({
        tagName: "progress",
        attributes: {
          "class": mi.attachmentProgress,
          value: this.attachment.getUploadProgress(),
          max: 100
        },
        data: {
          trixMutable: !0,
          trixStoreKey: ["progressElement", this.attachment.id].join("/")
        }
      }), e.appendChild(this.progressElement)), [fi("left"), e, fi("right")];
    }
  }, {
    key: "createCaptionElement",
    value: function createCaptionElement() {
      var t = T({
          tagName: "figcaption",
          className: mi.attachmentCaption
        }),
        e = this.attachmentPiece.getCaption();
      if (e) t.classList.add("".concat(mi.attachmentCaption, "--edited")), t.textContent = e;else {
        var _e12, _i14;
        var _n9 = this.getCaptionConfig();
        if (_n9.name && (_e12 = this.attachment.getFilename()), _n9.size && (_i14 = this.attachment.getFormattedFilesize()), _e12) {
          var _i15 = T({
            tagName: "span",
            className: mi.attachmentName,
            textContent: _e12
          });
          t.appendChild(_i15);
        }
        if (_i14) {
          _e12 && t.appendChild(document.createTextNode(" "));
          var _n0 = T({
            tagName: "span",
            className: mi.attachmentSize,
            textContent: _i14
          });
          t.appendChild(_n0);
        }
      }
      return t;
    }
  }, {
    key: "getClassName",
    value: function getClassName() {
      var t = [mi.attachment, "".concat(mi.attachment, "--").concat(this.attachment.getType())],
        e = this.attachment.getExtension();
      return e && t.push("".concat(mi.attachment, "--").concat(e)), t.join(" ");
    }
  }, {
    key: "getData",
    value: function getData() {
      var t = {
          trixAttachment: JSON.stringify(this.attachment),
          trixContentType: this.attachment.getContentType(),
          trixId: this.attachment.id
        },
        e = this.attachmentPiece.attributes;
      return e.isEmpty() || (t.trixAttributes = JSON.stringify(e)), this.attachment.isPending() && (t.trixSerialize = !1), t;
    }
  }, {
    key: "getHref",
    value: function getHref() {
      if (!bi(this.attachment.getContent(), "a")) return this.attachment.getHref();
    }
  }, {
    key: "getCaptionConfig",
    value: function getCaptionConfig() {
      var t;
      var e = this.attachment.getType(),
        n = kt(null === (t = i[e]) || void 0 === t ? void 0 : t.caption);
      return "file" === e && (n.name = !0), n;
    }
  }, {
    key: "findProgressElement",
    value: function findProgressElement() {
      var t;
      return null === (t = this.findElement()) || void 0 === t ? void 0 : t.querySelector("progress");
    }
  }, {
    key: "attachmentDidChangeUploadProgress",
    value: function attachmentDidChangeUploadProgress() {
      var t = this.attachment.getUploadProgress(),
        e = this.findProgressElement();
      e && (e.value = t);
    }
  }]);
}(ie);
var fi = function fi(t) {
    return T({
      tagName: "span",
      textContent: d,
      data: {
        trixCursorTarget: t,
        trixSerialize: !1
      }
    });
  },
  bi = function bi(t, e) {
    var i = T("div");
    return di.setHTML(i, t || ""), i.querySelector(e);
  };
var vi = /*#__PURE__*/function (_pi) {
  function vi() {
    var _this15;
    _classCallCheck(this, vi);
    _this15 = _callSuper(this, vi, arguments), _this15.attachment.previewDelegate = _assertThisInitialized(_this15);
    return _this15;
  }
  _inherits(vi, _pi);
  return _createClass(vi, [{
    key: "createContentNodes",
    value: function createContentNodes() {
      return this.image = T({
        tagName: "img",
        attributes: {
          src: ""
        },
        data: {
          trixMutable: !0
        }
      }), this.refresh(this.image), [this.image];
    }
  }, {
    key: "createCaptionElement",
    value: function createCaptionElement() {
      var t = _superPropGet(vi, "createCaptionElement", this, 3)(arguments);
      return t.textContent || t.setAttribute("data-trix-placeholder", c.captionPlaceholder), t;
    }
  }, {
    key: "refresh",
    value: function refresh(t) {
      var e;
      t || (t = null === (e = this.findElement()) || void 0 === e ? void 0 : e.querySelector("img"));
      if (t) return this.updateAttributesForImage(t);
    }
  }, {
    key: "updateAttributesForImage",
    value: function updateAttributesForImage(t) {
      var e = this.attachment.getURL(),
        i = this.attachment.getPreviewURL();
      if (t.src = i || e, i === e) t.removeAttribute("data-trix-serialized-attributes");else {
        var _i16 = JSON.stringify({
          src: e
        });
        t.setAttribute("data-trix-serialized-attributes", _i16);
      }
      var n = this.attachment.getWidth(),
        r = this.attachment.getHeight();
      null != n && (t.width = n), null != r && (t.height = r);
      var o = ["imageElement", this.attachment.id, t.src, t.width, t.height].join("/");
      t.dataset.trixStoreKey = o;
    }
  }, {
    key: "attachmentDidChangeAttributes",
    value: function attachmentDidChangeAttributes() {
      return this.refresh(this.image), this.refresh();
    }
  }]);
}(pi);
var Ai = /*#__PURE__*/function (_ie3) {
  function Ai() {
    var _this16;
    _classCallCheck(this, Ai);
    _this16 = _callSuper(this, Ai, arguments), _this16.piece = _this16.object, _this16.attributes = _this16.piece.getAttributes(), _this16.textConfig = _this16.options.textConfig, _this16.context = _this16.options.context, _this16.piece.attachment ? _this16.attachment = _this16.piece.attachment : _this16.string = _this16.piece.toString();
    return _this16;
  }
  _inherits(Ai, _ie3);
  return _createClass(Ai, [{
    key: "createNodes",
    value: function createNodes() {
      var t = this.attachment ? this.createAttachmentNodes() : this.createStringNodes();
      var e = this.createElement();
      if (e) {
        var _i17 = function (t) {
          for (; null !== (e = t) && void 0 !== e && e.firstElementChild;) {
            var e;
            t = t.firstElementChild;
          }
          return t;
        }(e);
        Array.from(t).forEach(function (t) {
          _i17.appendChild(t);
        }), t = [e];
      }
      return t;
    }
  }, {
    key: "createAttachmentNodes",
    value: function createAttachmentNodes() {
      var t = this.attachment.isPreviewable() ? vi : pi;
      return this.createChildView(t, this.piece.attachment, {
        piece: this.piece
      }).getNodes();
    }
  }, {
    key: "createStringNodes",
    value: function createStringNodes() {
      var t;
      if (null !== (t = this.textConfig) && void 0 !== t && t.plaintext) return [document.createTextNode(this.string)];
      {
        var _t8 = [],
          _e13 = this.string.split("\n");
        for (var _i18 = 0; _i18 < _e13.length; _i18++) {
          var _n1 = _e13[_i18];
          if (_i18 > 0) {
            var _e14 = T("br");
            _t8.push(_e14);
          }
          if (_n1.length) {
            var _e15 = document.createTextNode(this.preserveSpaces(_n1));
            _t8.push(_e15);
          }
        }
        return _t8;
      }
    }
  }, {
    key: "createElement",
    value: function createElement() {
      var t, e, i;
      var n = {};
      for (e in this.attributes) {
        i = this.attributes[e];
        var _o2 = ft(e);
        if (_o2) {
          if (_o2.tagName) {
            var r;
            var _e16 = T(_o2.tagName);
            r ? (r.appendChild(_e16), r = _e16) : t = r = _e16;
          }
          if (_o2.styleProperty && (n[_o2.styleProperty] = i), _o2.style) for (e in _o2.style) i = _o2.style[e], n[e] = i;
        }
      }
      if (Object.keys(n).length) for (e in t || (t = T("span")), n) i = n[e], t.style[e] = i;
      return t;
    }
  }, {
    key: "createContainerElement",
    value: function createContainerElement() {
      for (var _t9 in this.attributes) {
        var _e17 = this.attributes[_t9],
          _i19 = ft(_t9);
        if (_i19 && _i19.groupTagName) {
          var _n10 = {};
          return _n10[_t9] = _e17, T(_i19.groupTagName, _n10);
        }
      }
    }
  }, {
    key: "preserveSpaces",
    value: function preserveSpaces(t) {
      return this.context.isLast && (t = t.replace(/\ $/, g)), t = t.replace(/(\S)\ {3}(\S)/g, "$1 ".concat(g, " $2")).replace(/\ {2}/g, "".concat(g, " ")).replace(/\ {2}/g, " ".concat(g)), (this.context.isFirst || this.context.followsWhitespace) && (t = t.replace(/^\ /, g)), t;
    }
  }]);
}(ie);
var yi = /*#__PURE__*/function (_ie4) {
  function yi() {
    var _this17;
    _classCallCheck(this, yi);
    _this17 = _callSuper(this, yi, arguments), _this17.text = _this17.object, _this17.textConfig = _this17.options.textConfig;
    return _this17;
  }
  _inherits(yi, _ie4);
  return _createClass(yi, [{
    key: "createNodes",
    value: function createNodes() {
      var t = [],
        e = Xt.groupObjects(this.getPieces()),
        i = e.length - 1;
      for (var _r5 = 0; _r5 < e.length; _r5++) {
        var _o3 = e[_r5],
          _s2 = {};
        0 === _r5 && (_s2.isFirst = !0), _r5 === i && (_s2.isLast = !0), xi(n) && (_s2.followsWhitespace = !0);
        var _a = this.findOrCreateCachedChildView(Ai, _o3, {
          textConfig: this.textConfig,
          context: _s2
        });
        t.push.apply(t, _toConsumableArray(Array.from(_a.getNodes() || [])));
        var n = _o3;
      }
      return t;
    }
  }, {
    key: "getPieces",
    value: function getPieces() {
      return Array.from(this.text.getPieces()).filter(function (t) {
        return !t.hasAttribute("blockBreak");
      });
    }
  }]);
}(ie);
var xi = function xi(t) {
    return /\s$/.test(null == t ? void 0 : t.toString());
  },
  Ci = z.css;
var Ei = /*#__PURE__*/function (_ie5) {
  function Ei() {
    var _this18;
    _classCallCheck(this, Ei);
    _this18 = _callSuper(this, Ei, arguments), _this18.block = _this18.object, _this18.attributes = _this18.block.getAttributes();
    return _this18;
  }
  _inherits(Ei, _ie5);
  return _createClass(Ei, [{
    key: "createNodes",
    value: function createNodes() {
      var t = [document.createComment("block")];
      if (this.block.isEmpty()) t.push(T("br"));else {
        var e;
        var _i20 = null === (e = mt(this.block.getLastAttribute())) || void 0 === e ? void 0 : e.text,
          _n11 = this.findOrCreateCachedChildView(yi, this.block.text, {
            textConfig: _i20
          });
        t.push.apply(t, _toConsumableArray(Array.from(_n11.getNodes() || []))), this.shouldAddExtraNewlineElement() && t.push(T("br"));
      }
      if (this.attributes.length) return t;
      {
        var _e18;
        var _i21 = n["default"].tagName;
        this.block.isRTL() && (_e18 = {
          dir: "rtl"
        });
        var _r6 = T({
          tagName: _i21,
          attributes: _e18
        });
        return t.forEach(function (t) {
          return _r6.appendChild(t);
        }), [_r6];
      }
    }
  }, {
    key: "createContainerElement",
    value: function createContainerElement(t) {
      var e = {};
      var i;
      var n = this.attributes[t],
        _mt = mt(n),
        r = _mt.tagName,
        _mt$htmlAttributes = _mt.htmlAttributes,
        o = _mt$htmlAttributes === void 0 ? [] : _mt$htmlAttributes;
      if (0 === t && this.block.isRTL() && Object.assign(e, {
        dir: "rtl"
      }), "attachmentGallery" === n) {
        var _t0 = this.block.getBlockBreakPosition();
        i = "".concat(Ci.attachmentGallery, " ").concat(Ci.attachmentGallery, "--").concat(_t0);
      }
      return Object.entries(this.block.htmlAttributes).forEach(function (t) {
        var _t1 = _slicedToArray(t, 2),
          i = _t1[0],
          n = _t1[1];
        o.includes(i) && (e[i] = n);
      }), T({
        tagName: r,
        className: i,
        attributes: e
      });
    }
  }, {
    key: "shouldAddExtraNewlineElement",
    value: function shouldAddExtraNewlineElement() {
      return /\n\n$/.test(this.block.toString());
    }
  }]);
}(ie);
var Si = /*#__PURE__*/function (_ie6) {
  function Si() {
    var _this19;
    _classCallCheck(this, Si);
    _this19 = _callSuper(this, Si, arguments), _this19.element = _this19.options.element, _this19.elementStore = new Qt(), _this19.setDocument(_this19.object);
    return _this19;
  }
  _inherits(Si, _ie6);
  return _createClass(Si, [{
    key: "setDocument",
    value: function setDocument(t) {
      t.isEqualTo(this.document) || (this.document = this.object = t);
    }
  }, {
    key: "render",
    value: function render() {
      var _this20 = this;
      if (this.childViews = [], this.shadowElement = T("div"), !this.document.isEmpty()) {
        var _t10 = Xt.groupObjects(this.document.getBlocks(), {
          asTree: !0
        });
        Array.from(_t10).forEach(function (t) {
          var e = _this20.findOrCreateCachedChildView(Ei, t);
          Array.from(e.getNodes()).map(function (t) {
            return _this20.shadowElement.appendChild(t);
          });
        });
      }
    }
  }, {
    key: "isSynced",
    value: function isSynced() {
      return ki(this.shadowElement, this.element);
    }
  }, {
    key: "sync",
    value: function sync() {
      var t = this.createDocumentFragmentForSync();
      for (; this.element.lastChild;) this.element.removeChild(this.element.lastChild);
      return this.element.appendChild(t), this.didSync();
    }
  }, {
    key: "didSync",
    value: function didSync() {
      var _this21 = this;
      return this.elementStore.reset(Ri(this.element)), Rt(function () {
        return _this21.garbageCollectCachedViews();
      });
    }
  }, {
    key: "createDocumentFragmentForSync",
    value: function createDocumentFragmentForSync() {
      var _this22 = this;
      var t = document.createDocumentFragment();
      return Array.from(this.shadowElement.childNodes).forEach(function (e) {
        t.appendChild(e.cloneNode(!0));
      }), Array.from(Ri(t)).forEach(function (t) {
        var e = _this22.elementStore.remove(t);
        e && t.parentNode.replaceChild(e, t);
      }), t;
    }
  }], [{
    key: "render",
    value: function render(t) {
      var e = T("div"),
        i = new this(t, {
          element: e
        });
      return i.render(), i.sync(), e;
    }
  }]);
}(ie);
var Ri = function Ri(t) {
    return t.querySelectorAll("[data-trix-store-key]");
  },
  ki = function ki(t, e) {
    return Ti(t.innerHTML) === Ti(e.innerHTML);
  },
  Ti = function Ti(t) {
    return t.replace(/&nbsp;/g, " ");
  };
function wi(t) {
  var e, i;
  function n(e, i) {
    try {
      var o = t[e](i),
        s = o.value,
        a = s instanceof Li;
      Promise.resolve(a ? s.v : s).then(function (i) {
        if (a) {
          var l = "return" === e ? "return" : "next";
          if (!s.k || i.done) return n(l, i);
          i = t[l](i).value;
        }
        r(o.done ? "return" : "normal", i);
      }, function (t) {
        n("throw", t);
      });
    } catch (t) {
      r("throw", t);
    }
  }
  function r(t, r) {
    switch (t) {
      case "return":
        e.resolve({
          value: r,
          done: !0
        });
        break;
      case "throw":
        e.reject(r);
        break;
      default:
        e.resolve({
          value: r,
          done: !1
        });
    }
    (e = e.next) ? n(e.key, e.arg) : i = null;
  }
  this._invoke = function (t, r) {
    return new Promise(function (o, s) {
      var a = {
        key: t,
        arg: r,
        resolve: o,
        reject: s,
        next: null
      };
      i ? i = i.next = a : (e = i = a, n(t, r));
    });
  }, "function" != typeof t["return"] && (this["return"] = void 0);
}
function Li(t, e) {
  this.v = t, this.k = e;
}
function Di(t, e, i) {
  return (e = Ni(e)) in t ? Object.defineProperty(t, e, {
    value: i,
    enumerable: !0,
    configurable: !0,
    writable: !0
  }) : t[e] = i, t;
}
function Ni(t) {
  var e = function (t, e) {
    if ("object" != _typeof(t) || null === t) return t;
    var i = t[Symbol.toPrimitive];
    if (void 0 !== i) {
      var n = i.call(t, e || "default");
      if ("object" != _typeof(n)) return n;
      throw new TypeError("@@toPrimitive must return a primitive value.");
    }
    return ("string" === e ? String : Number)(t);
  }(t, "string");
  return "symbol" == _typeof(e) ? e : String(e);
}
wi.prototype["function" == typeof Symbol && Symbol.asyncIterator || "@@asyncIterator"] = function () {
  return this;
}, wi.prototype.next = function (t) {
  return this._invoke("next", t);
}, wi.prototype["throw"] = function (t) {
  return this._invoke("throw", t);
}, wi.prototype["return"] = function (t) {
  return this._invoke("return", t);
};
function Ii(t, e) {
  return Pi(t, Fi(t, e, "get"));
}
function Oi(t, e, i) {
  return Mi(t, Fi(t, e, "set"), i), i;
}
function Fi(t, e, i) {
  if (!e.has(t)) throw new TypeError("attempted to " + i + " private field on non-instance");
  return e.get(t);
}
function Pi(t, e) {
  return e.get ? e.get.call(t) : e.value;
}
function Mi(t, e, i) {
  if (e.set) e.set.call(t, i);else {
    if (!e.writable) throw new TypeError("attempted to set read only private field");
    e.value = i;
  }
}
function Bi(t, e, i) {
  if (!e.has(t)) throw new TypeError("attempted to get private field on non-instance");
  return i;
}
function _i(t, e) {
  if (e.has(t)) throw new TypeError("Cannot initialize the same private elements twice on an object");
}
function ji(t, e, i) {
  _i(t, e), e.set(t, i);
}
var Wi = /*#__PURE__*/function (_rt2) {
  function Wi(t) {
    var _this23;
    _classCallCheck(this, Wi);
    var e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
    _this23 = _callSuper(this, Wi, arguments), _this23.attributes = Ht.box(e);
    return _this23;
  }
  _inherits(Wi, _rt2);
  return _createClass(Wi, [{
    key: "copyWithAttributes",
    value: function copyWithAttributes(t) {
      return new this.constructor(this.getValue(), t);
    }
  }, {
    key: "copyWithAdditionalAttributes",
    value: function copyWithAdditionalAttributes(t) {
      return this.copyWithAttributes(this.attributes.merge(t));
    }
  }, {
    key: "copyWithoutAttribute",
    value: function copyWithoutAttribute(t) {
      return this.copyWithAttributes(this.attributes.remove(t));
    }
  }, {
    key: "copy",
    value: function copy() {
      return this.copyWithAttributes(this.attributes);
    }
  }, {
    key: "getAttribute",
    value: function getAttribute(t) {
      return this.attributes.get(t);
    }
  }, {
    key: "getAttributesHash",
    value: function getAttributesHash() {
      return this.attributes;
    }
  }, {
    key: "getAttributes",
    value: function getAttributes() {
      return this.attributes.toObject();
    }
  }, {
    key: "hasAttribute",
    value: function hasAttribute(t) {
      return this.attributes.has(t);
    }
  }, {
    key: "hasSameStringValueAsPiece",
    value: function hasSameStringValueAsPiece(t) {
      return t && this.toString() === t.toString();
    }
  }, {
    key: "hasSameAttributesAsPiece",
    value: function hasSameAttributesAsPiece(t) {
      return t && (this.attributes === t.attributes || this.attributes.isEqualTo(t.attributes));
    }
  }, {
    key: "isBlockBreak",
    value: function isBlockBreak() {
      return !1;
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      return _superPropGet(Wi, "isEqualTo", this, 3)(arguments) || this.hasSameConstructorAs(t) && this.hasSameStringValueAsPiece(t) && this.hasSameAttributesAsPiece(t);
    }
  }, {
    key: "isEmpty",
    value: function isEmpty() {
      return 0 === this.length;
    }
  }, {
    key: "isSerializable",
    value: function isSerializable() {
      return !0;
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return {
        type: this.constructor.type,
        attributes: this.getAttributes()
      };
    }
  }, {
    key: "contentsForInspection",
    value: function contentsForInspection() {
      return {
        type: this.constructor.type,
        attributes: this.attributes.inspect()
      };
    }
  }, {
    key: "canBeGrouped",
    value: function canBeGrouped() {
      return this.hasAttribute("href");
    }
  }, {
    key: "canBeGroupedWith",
    value: function canBeGroupedWith(t) {
      return this.getAttribute("href") === t.getAttribute("href");
    }
  }, {
    key: "getLength",
    value: function getLength() {
      return this.length;
    }
  }, {
    key: "canBeConsolidatedWith",
    value: function canBeConsolidatedWith(t) {
      return !1;
    }
  }], [{
    key: "registerType",
    value: function registerType(t, e) {
      e.type = t, this.types[t] = e;
    }
  }, {
    key: "fromJSON",
    value: function fromJSON(t) {
      var e = this.types[t.type];
      if (e) return e.fromJSON(t);
    }
  }]);
}(rt);
Di(Wi, "types", {});
var Ui = /*#__PURE__*/function (_ee) {
  function Ui(t) {
    var _this24;
    _classCallCheck(this, Ui);
    _this24 = _callSuper(this, Ui, arguments), _this24.url = t;
    return _this24;
  }
  _inherits(Ui, _ee);
  return _createClass(Ui, [{
    key: "perform",
    value: function perform(t) {
      var _this25 = this;
      var e = new Image();
      e.onload = function () {
        return e.width = _this25.width = e.naturalWidth, e.height = _this25.height = e.naturalHeight, t(!0, e);
      }, e.onerror = function () {
        return t(!1);
      }, e.src = this.url;
    }
  }]);
}(ee);
var Vi = /*#__PURE__*/function (_rt3) {
  function Vi() {
    var _this26;
    _classCallCheck(this, Vi);
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {};
    _this26 = _callSuper(this, Vi, [t]), _this26.releaseFile = _this26.releaseFile.bind(_assertThisInitialized(_this26)), _this26.attributes = Ht.box(t), _this26.didChangeAttributes();
    return _this26;
  }
  _inherits(Vi, _rt3);
  return _createClass(Vi, [{
    key: "getAttribute",
    value: function getAttribute(t) {
      return this.attributes.get(t);
    }
  }, {
    key: "hasAttribute",
    value: function hasAttribute(t) {
      return this.attributes.has(t);
    }
  }, {
    key: "getAttributes",
    value: function getAttributes() {
      return this.attributes.toObject();
    }
  }, {
    key: "setAttributes",
    value: function setAttributes() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {};
      var e = this.attributes.merge(t);
      var i, n, r, o;
      if (!this.attributes.isEqualTo(e)) return this.attributes = e, this.didChangeAttributes(), null === (i = this.previewDelegate) || void 0 === i || null === (n = i.attachmentDidChangeAttributes) || void 0 === n || n.call(i, this), null === (r = this.delegate) || void 0 === r || null === (o = r.attachmentDidChangeAttributes) || void 0 === o ? void 0 : o.call(r, this);
    }
  }, {
    key: "didChangeAttributes",
    value: function didChangeAttributes() {
      if (this.isPreviewable()) return this.preloadURL();
    }
  }, {
    key: "isPending",
    value: function isPending() {
      return null != this.file && !(this.getURL() || this.getHref());
    }
  }, {
    key: "isPreviewable",
    value: function isPreviewable() {
      return this.attributes.has("previewable") ? this.attributes.get("previewable") : Vi.previewablePattern.test(this.getContentType());
    }
  }, {
    key: "getType",
    value: function getType() {
      return this.hasContent() ? "content" : this.isPreviewable() ? "preview" : "file";
    }
  }, {
    key: "getURL",
    value: function getURL() {
      return this.attributes.get("url");
    }
  }, {
    key: "getHref",
    value: function getHref() {
      return this.attributes.get("href");
    }
  }, {
    key: "getFilename",
    value: function getFilename() {
      return this.attributes.get("filename") || "";
    }
  }, {
    key: "getFilesize",
    value: function getFilesize() {
      return this.attributes.get("filesize");
    }
  }, {
    key: "getFormattedFilesize",
    value: function getFormattedFilesize() {
      var t = this.attributes.get("filesize");
      return "number" == typeof t ? h.formatter(t) : "";
    }
  }, {
    key: "getExtension",
    value: function getExtension() {
      var t;
      return null === (t = this.getFilename().match(/\.(\w+)$/)) || void 0 === t ? void 0 : t[1].toLowerCase();
    }
  }, {
    key: "getContentType",
    value: function getContentType() {
      return this.attributes.get("contentType");
    }
  }, {
    key: "hasContent",
    value: function hasContent() {
      return this.attributes.has("content");
    }
  }, {
    key: "getContent",
    value: function getContent() {
      return this.attributes.get("content");
    }
  }, {
    key: "getWidth",
    value: function getWidth() {
      return this.attributes.get("width");
    }
  }, {
    key: "getHeight",
    value: function getHeight() {
      return this.attributes.get("height");
    }
  }, {
    key: "getFile",
    value: function getFile() {
      return this.file;
    }
  }, {
    key: "setFile",
    value: function setFile(t) {
      if (this.file = t, this.isPreviewable()) return this.preloadFile();
    }
  }, {
    key: "releaseFile",
    value: function releaseFile() {
      this.releasePreloadedFile(), this.file = null;
    }
  }, {
    key: "getUploadProgress",
    value: function getUploadProgress() {
      return null != this.uploadProgress ? this.uploadProgress : 0;
    }
  }, {
    key: "setUploadProgress",
    value: function setUploadProgress(t) {
      var e, i;
      if (this.uploadProgress !== t) return this.uploadProgress = t, null === (e = this.uploadProgressDelegate) || void 0 === e || null === (i = e.attachmentDidChangeUploadProgress) || void 0 === i ? void 0 : i.call(e, this);
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return this.getAttributes();
    }
  }, {
    key: "getCacheKey",
    value: function getCacheKey() {
      return [_superPropGet(Vi, "getCacheKey", this, 3)(arguments), this.attributes.getCacheKey(), this.getPreviewURL()].join("/");
    }
  }, {
    key: "getPreviewURL",
    value: function getPreviewURL() {
      return this.previewURL || this.preloadingURL;
    }
  }, {
    key: "setPreviewURL",
    value: function setPreviewURL(t) {
      var e, i, n, r;
      if (t !== this.getPreviewURL()) return this.previewURL = t, null === (e = this.previewDelegate) || void 0 === e || null === (i = e.attachmentDidChangeAttributes) || void 0 === i || i.call(e, this), null === (n = this.delegate) || void 0 === n || null === (r = n.attachmentDidChangePreviewURL) || void 0 === r ? void 0 : r.call(n, this);
    }
  }, {
    key: "preloadURL",
    value: function preloadURL() {
      return this.preload(this.getURL(), this.releaseFile);
    }
  }, {
    key: "preloadFile",
    value: function preloadFile() {
      if (this.file) return this.fileObjectURL = URL.createObjectURL(this.file), this.preload(this.fileObjectURL);
    }
  }, {
    key: "releasePreloadedFile",
    value: function releasePreloadedFile() {
      this.fileObjectURL && (URL.revokeObjectURL(this.fileObjectURL), this.fileObjectURL = null);
    }
  }, {
    key: "preload",
    value: function preload(t, e) {
      var _this27 = this;
      if (t && t !== this.getPreviewURL()) {
        this.preloadingURL = t;
        return new Ui(t).then(function (i) {
          var n = i.width,
            r = i.height;
          return _this27.getWidth() && _this27.getHeight() || _this27.setAttributes({
            width: n,
            height: r
          }), _this27.preloadingURL = null, _this27.setPreviewURL(t), null == e ? void 0 : e();
        })["catch"](function () {
          return _this27.preloadingURL = null, null == e ? void 0 : e();
        });
      }
    }
  }], [{
    key: "attachmentForFile",
    value: function attachmentForFile(t) {
      var e = new this(this.attributesForFile(t));
      return e.setFile(t), e;
    }
  }, {
    key: "attributesForFile",
    value: function attributesForFile(t) {
      return new Ht({
        filename: t.name,
        filesize: t.size,
        contentType: t.type
      });
    }
  }, {
    key: "fromJSON",
    value: function fromJSON(t) {
      return new this(t);
    }
  }]);
}(rt);
Di(Vi, "previewablePattern", /^image(\/(gif|png|webp|jpe?g)|$)/);
var zi = /*#__PURE__*/function (_Wi) {
  function zi(t) {
    var _this28;
    _classCallCheck(this, zi);
    _this28 = _callSuper(this, zi, arguments), _this28.attachment = t, _this28.length = 1, _this28.ensureAttachmentExclusivelyHasAttribute("href"), _this28.attachment.hasContent() || _this28.removeProhibitedAttributes();
    return _this28;
  }
  _inherits(zi, _Wi);
  return _createClass(zi, [{
    key: "ensureAttachmentExclusivelyHasAttribute",
    value: function ensureAttachmentExclusivelyHasAttribute(t) {
      this.hasAttribute(t) && (this.attachment.hasAttribute(t) || this.attachment.setAttributes(this.attributes.slice([t])), this.attributes = this.attributes.remove(t));
    }
  }, {
    key: "removeProhibitedAttributes",
    value: function removeProhibitedAttributes() {
      var t = this.attributes.slice(zi.permittedAttributes);
      t.isEqualTo(this.attributes) || (this.attributes = t);
    }
  }, {
    key: "getValue",
    value: function getValue() {
      return this.attachment;
    }
  }, {
    key: "isSerializable",
    value: function isSerializable() {
      return !this.attachment.isPending();
    }
  }, {
    key: "getCaption",
    value: function getCaption() {
      return this.attributes.get("caption") || "";
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      var e;
      return _superPropGet(zi, "isEqualTo", this, 3)([t]) && this.attachment.id === (null == t || null === (e = t.attachment) || void 0 === e ? void 0 : e.id);
    }
  }, {
    key: "toString",
    value: function toString() {
      return "￼";
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      var t = _superPropGet(zi, "toJSON", this, 3)(arguments);
      return t.attachment = this.attachment, t;
    }
  }, {
    key: "getCacheKey",
    value: function getCacheKey() {
      return [_superPropGet(zi, "getCacheKey", this, 3)(arguments), this.attachment.getCacheKey()].join("/");
    }
  }, {
    key: "toConsole",
    value: function toConsole() {
      return JSON.stringify(this.toString());
    }
  }], [{
    key: "fromJSON",
    value: function fromJSON(t) {
      return new this(Vi.fromJSON(t.attachment), t.attributes);
    }
  }]);
}(Wi);
Di(zi, "permittedAttributes", ["caption", "presentation"]), Wi.registerType("attachment", zi);
var qi = /*#__PURE__*/function (_Wi2) {
  function qi(t) {
    var _this29;
    _classCallCheck(this, qi);
    _this29 = _callSuper(this, qi, arguments), _this29.string = function (t) {
      return t.replace(/\r\n?/g, "\n");
    }(t), _this29.length = _this29.string.length;
    return _this29;
  }
  _inherits(qi, _Wi2);
  return _createClass(qi, [{
    key: "getValue",
    value: function getValue() {
      return this.string;
    }
  }, {
    key: "toString",
    value: function toString() {
      return this.string.toString();
    }
  }, {
    key: "isBlockBreak",
    value: function isBlockBreak() {
      return "\n" === this.toString() && !0 === this.getAttribute("blockBreak");
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      var t = _superPropGet(qi, "toJSON", this, 3)(arguments);
      return t.string = this.string, t;
    }
  }, {
    key: "canBeConsolidatedWith",
    value: function canBeConsolidatedWith(t) {
      return t && this.hasSameConstructorAs(t) && this.hasSameAttributesAsPiece(t);
    }
  }, {
    key: "consolidateWith",
    value: function consolidateWith(t) {
      return new this.constructor(this.toString() + t.toString(), this.attributes);
    }
  }, {
    key: "splitAtOffset",
    value: function splitAtOffset(t) {
      var e, i;
      return 0 === t ? (e = null, i = this) : t === this.length ? (e = this, i = null) : (e = new this.constructor(this.string.slice(0, t), this.attributes), i = new this.constructor(this.string.slice(t), this.attributes)), [e, i];
    }
  }, {
    key: "toConsole",
    value: function toConsole() {
      var t = this.string;
      return t.length > 15 && (t = t.slice(0, 14) + "…"), JSON.stringify(t.toString());
    }
  }], [{
    key: "fromJSON",
    value: function fromJSON(t) {
      return new this(t.string, t.attributes);
    }
  }]);
}(Wi);
Wi.registerType("string", qi);
var Hi = /*#__PURE__*/function (_rt4) {
  function Hi() {
    var _this30;
    _classCallCheck(this, Hi);
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
    _this30 = _callSuper(this, Hi, arguments), _this30.objects = t.slice(0), _this30.length = _this30.objects.length;
    return _this30;
  }
  _inherits(Hi, _rt4);
  return _createClass(Hi, [{
    key: "indexOf",
    value: function indexOf(t) {
      return this.objects.indexOf(t);
    }
  }, {
    key: "splice",
    value: function splice() {
      for (var t = arguments.length, e = new Array(t), i = 0; i < t; i++) e[i] = arguments[i];
      return new this.constructor(st.apply(void 0, [this.objects].concat(e)));
    }
  }, {
    key: "eachObject",
    value: function eachObject(t) {
      return this.objects.map(function (e, i) {
        return t(e, i);
      });
    }
  }, {
    key: "insertObjectAtIndex",
    value: function insertObjectAtIndex(t, e) {
      return this.splice(e, 0, t);
    }
  }, {
    key: "insertSplittableListAtIndex",
    value: function insertSplittableListAtIndex(t, e) {
      return this.splice.apply(this, [e, 0].concat(_toConsumableArray(t.objects)));
    }
  }, {
    key: "insertSplittableListAtPosition",
    value: function insertSplittableListAtPosition(t, e) {
      var _this$splitObjectAtPo = this.splitObjectAtPosition(e),
        _this$splitObjectAtPo2 = _slicedToArray(_this$splitObjectAtPo, 2),
        i = _this$splitObjectAtPo2[0],
        n = _this$splitObjectAtPo2[1];
      return new this.constructor(i).insertSplittableListAtIndex(t, n);
    }
  }, {
    key: "editObjectAtIndex",
    value: function editObjectAtIndex(t, e) {
      return this.replaceObjectAtIndex(e(this.objects[t]), t);
    }
  }, {
    key: "replaceObjectAtIndex",
    value: function replaceObjectAtIndex(t, e) {
      return this.splice(e, 1, t);
    }
  }, {
    key: "removeObjectAtIndex",
    value: function removeObjectAtIndex(t) {
      return this.splice(t, 1);
    }
  }, {
    key: "getObjectAtIndex",
    value: function getObjectAtIndex(t) {
      return this.objects[t];
    }
  }, {
    key: "getSplittableListInRange",
    value: function getSplittableListInRange(t) {
      var _this$splitObjectsAtR = this.splitObjectsAtRange(t),
        _this$splitObjectsAtR2 = _slicedToArray(_this$splitObjectsAtR, 3),
        e = _this$splitObjectsAtR2[0],
        i = _this$splitObjectsAtR2[1],
        n = _this$splitObjectsAtR2[2];
      return new this.constructor(e.slice(i, n + 1));
    }
  }, {
    key: "selectSplittableList",
    value: function selectSplittableList(t) {
      var e = this.objects.filter(function (e) {
        return t(e);
      });
      return new this.constructor(e);
    }
  }, {
    key: "removeObjectsInRange",
    value: function removeObjectsInRange(t) {
      var _this$splitObjectsAtR3 = this.splitObjectsAtRange(t),
        _this$splitObjectsAtR4 = _slicedToArray(_this$splitObjectsAtR3, 3),
        e = _this$splitObjectsAtR4[0],
        i = _this$splitObjectsAtR4[1],
        n = _this$splitObjectsAtR4[2];
      return new this.constructor(e).splice(i, n - i + 1);
    }
  }, {
    key: "transformObjectsInRange",
    value: function transformObjectsInRange(t, e) {
      var _this$splitObjectsAtR5 = this.splitObjectsAtRange(t),
        _this$splitObjectsAtR6 = _slicedToArray(_this$splitObjectsAtR5, 3),
        i = _this$splitObjectsAtR6[0],
        n = _this$splitObjectsAtR6[1],
        r = _this$splitObjectsAtR6[2],
        o = i.map(function (t, i) {
          return n <= i && i <= r ? e(t) : t;
        });
      return new this.constructor(o);
    }
  }, {
    key: "splitObjectsAtRange",
    value: function splitObjectsAtRange(t) {
      var _this$constructor$spl, _this$constructor$spl2;
      var e,
        _this$splitObjectAtPo3 = this.splitObjectAtPosition(Ki(t)),
        _this$splitObjectAtPo4 = _slicedToArray(_this$splitObjectAtPo3, 3),
        i = _this$splitObjectAtPo4[0],
        n = _this$splitObjectAtPo4[1],
        r = _this$splitObjectAtPo4[2];
      return _this$constructor$spl = new this.constructor(i).splitObjectAtPosition(Gi(t) + r), _this$constructor$spl2 = _slicedToArray(_this$constructor$spl, 2), i = _this$constructor$spl2[0], e = _this$constructor$spl2[1], [i, n, e - 1];
    }
  }, {
    key: "getObjectAtPosition",
    value: function getObjectAtPosition(t) {
      var _this$findIndexAndOff = this.findIndexAndOffsetAtPosition(t),
        e = _this$findIndexAndOff.index;
      return this.objects[e];
    }
  }, {
    key: "splitObjectAtPosition",
    value: function splitObjectAtPosition(t) {
      var e, i;
      var _this$findIndexAndOff2 = this.findIndexAndOffsetAtPosition(t),
        n = _this$findIndexAndOff2.index,
        r = _this$findIndexAndOff2.offset,
        o = this.objects.slice(0);
      if (null != n) {
        if (0 === r) e = n, i = 0;else {
          var _t11 = this.getObjectAtIndex(n),
            _t$splitAtOffset = _t11.splitAtOffset(r),
            _t$splitAtOffset2 = _slicedToArray(_t$splitAtOffset, 2),
            _s3 = _t$splitAtOffset2[0],
            _a2 = _t$splitAtOffset2[1];
          o.splice(n, 1, _s3, _a2), e = n + 1, i = _s3.getLength() - r;
        }
      } else e = o.length, i = 0;
      return [o, e, i];
    }
  }, {
    key: "consolidate",
    value: function consolidate() {
      var t = [];
      var e = this.objects[0];
      return this.objects.slice(1).forEach(function (i) {
        var n, r;
        null !== (n = (r = e).canBeConsolidatedWith) && void 0 !== n && n.call(r, i) ? e = e.consolidateWith(i) : (t.push(e), e = i);
      }), e && t.push(e), new this.constructor(t);
    }
  }, {
    key: "consolidateFromIndexToIndex",
    value: function consolidateFromIndexToIndex(t, e) {
      var i = this.objects.slice(0).slice(t, e + 1),
        n = new this.constructor(i).consolidate().toArray();
      return this.splice.apply(this, [t, i.length].concat(_toConsumableArray(n)));
    }
  }, {
    key: "findIndexAndOffsetAtPosition",
    value: function findIndexAndOffsetAtPosition(t) {
      var e,
        i = 0;
      for (e = 0; e < this.objects.length; e++) {
        var _n12 = i + this.objects[e].getLength();
        if (i <= t && t < _n12) return {
          index: e,
          offset: t - i
        };
        i = _n12;
      }
      return {
        index: null,
        offset: null
      };
    }
  }, {
    key: "findPositionAtIndexAndOffset",
    value: function findPositionAtIndexAndOffset(t, e) {
      var i = 0;
      for (var _n13 = 0; _n13 < this.objects.length; _n13++) {
        var _r7 = this.objects[_n13];
        if (_n13 < t) i += _r7.getLength();else if (_n13 === t) {
          i += e;
          break;
        }
      }
      return i;
    }
  }, {
    key: "getEndPosition",
    value: function getEndPosition() {
      var _this31 = this;
      return null == this.endPosition && (this.endPosition = 0, this.objects.forEach(function (t) {
        return _this31.endPosition += t.getLength();
      })), this.endPosition;
    }
  }, {
    key: "toString",
    value: function toString() {
      return this.objects.join("");
    }
  }, {
    key: "toArray",
    value: function toArray() {
      return this.objects.slice(0);
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return this.toArray();
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      return _superPropGet(Hi, "isEqualTo", this, 3)(arguments) || Ji(this.objects, null == t ? void 0 : t.objects);
    }
  }, {
    key: "contentsForInspection",
    value: function contentsForInspection() {
      return {
        objects: "[".concat(this.objects.map(function (t) {
          return t.inspect();
        }).join(", "), "]")
      };
    }
  }], [{
    key: "box",
    value: function box(t) {
      return t instanceof this ? t : new this(t);
    }
  }]);
}(rt);
var Ji = function Ji(t) {
    var e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : [];
    if (t.length !== e.length) return !1;
    var i = !0;
    for (var _n14 = 0; _n14 < t.length; _n14++) {
      var _r8 = t[_n14];
      i && !_r8.isEqualTo(e[_n14]) && (i = !1);
    }
    return i;
  },
  Ki = function Ki(t) {
    return t[0];
  },
  Gi = function Gi(t) {
    return t[1];
  };
var Yi = /*#__PURE__*/function (_rt5) {
  function Yi() {
    var _this32;
    _classCallCheck(this, Yi);
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
    _this32 = _callSuper(this, Yi, arguments);
    var e = t.filter(function (t) {
      return !t.isEmpty();
    });
    _this32.pieceList = new Hi(e);
    return _this32;
  }
  _inherits(Yi, _rt5);
  return _createClass(Yi, [{
    key: "copy",
    value: function copy() {
      return this.copyWithPieceList(this.pieceList);
    }
  }, {
    key: "copyWithPieceList",
    value: function copyWithPieceList(t) {
      return new this.constructor(t.consolidate().toArray());
    }
  }, {
    key: "copyUsingObjectMap",
    value: function copyUsingObjectMap(t) {
      var e = this.getPieces().map(function (e) {
        return t.find(e) || e;
      });
      return new this.constructor(e);
    }
  }, {
    key: "appendText",
    value: function appendText(t) {
      return this.insertTextAtPosition(t, this.getLength());
    }
  }, {
    key: "insertTextAtPosition",
    value: function insertTextAtPosition(t, e) {
      return this.copyWithPieceList(this.pieceList.insertSplittableListAtPosition(t.pieceList, e));
    }
  }, {
    key: "removeTextAtRange",
    value: function removeTextAtRange(t) {
      return this.copyWithPieceList(this.pieceList.removeObjectsInRange(t));
    }
  }, {
    key: "replaceTextAtRange",
    value: function replaceTextAtRange(t, e) {
      return this.removeTextAtRange(e).insertTextAtPosition(t, e[0]);
    }
  }, {
    key: "moveTextFromRangeToPosition",
    value: function moveTextFromRangeToPosition(t, e) {
      if (t[0] <= e && e <= t[1]) return;
      var i = this.getTextAtRange(t),
        n = i.getLength();
      return t[0] < e && (e -= n), this.removeTextAtRange(t).insertTextAtPosition(i, e);
    }
  }, {
    key: "addAttributeAtRange",
    value: function addAttributeAtRange(t, e, i) {
      var n = {};
      return n[t] = e, this.addAttributesAtRange(n, i);
    }
  }, {
    key: "addAttributesAtRange",
    value: function addAttributesAtRange(t, e) {
      return this.copyWithPieceList(this.pieceList.transformObjectsInRange(e, function (e) {
        return e.copyWithAdditionalAttributes(t);
      }));
    }
  }, {
    key: "removeAttributeAtRange",
    value: function removeAttributeAtRange(t, e) {
      return this.copyWithPieceList(this.pieceList.transformObjectsInRange(e, function (e) {
        return e.copyWithoutAttribute(t);
      }));
    }
  }, {
    key: "setAttributesAtRange",
    value: function setAttributesAtRange(t, e) {
      return this.copyWithPieceList(this.pieceList.transformObjectsInRange(e, function (e) {
        return e.copyWithAttributes(t);
      }));
    }
  }, {
    key: "getAttributesAtPosition",
    value: function getAttributesAtPosition(t) {
      var e;
      return (null === (e = this.pieceList.getObjectAtPosition(t)) || void 0 === e ? void 0 : e.getAttributes()) || {};
    }
  }, {
    key: "getCommonAttributes",
    value: function getCommonAttributes() {
      var t = Array.from(this.pieceList.toArray()).map(function (t) {
        return t.getAttributes();
      });
      return Ht.fromCommonAttributesOfObjects(t).toObject();
    }
  }, {
    key: "getCommonAttributesAtRange",
    value: function getCommonAttributesAtRange(t) {
      return this.getTextAtRange(t).getCommonAttributes() || {};
    }
  }, {
    key: "getExpandedRangeForAttributeAtOffset",
    value: function getExpandedRangeForAttributeAtOffset(t, e) {
      var i,
        n = i = e;
      var r = this.getLength();
      for (; n > 0 && this.getCommonAttributesAtRange([n - 1, i])[t];) n--;
      for (; i < r && this.getCommonAttributesAtRange([e, i + 1])[t];) i++;
      return [n, i];
    }
  }, {
    key: "getTextAtRange",
    value: function getTextAtRange(t) {
      return this.copyWithPieceList(this.pieceList.getSplittableListInRange(t));
    }
  }, {
    key: "getStringAtRange",
    value: function getStringAtRange(t) {
      return this.pieceList.getSplittableListInRange(t).toString();
    }
  }, {
    key: "getStringAtPosition",
    value: function getStringAtPosition(t) {
      return this.getStringAtRange([t, t + 1]);
    }
  }, {
    key: "startsWithString",
    value: function startsWithString(t) {
      return this.getStringAtRange([0, t.length]) === t;
    }
  }, {
    key: "endsWithString",
    value: function endsWithString(t) {
      var e = this.getLength();
      return this.getStringAtRange([e - t.length, e]) === t;
    }
  }, {
    key: "getAttachmentPieces",
    value: function getAttachmentPieces() {
      return this.pieceList.toArray().filter(function (t) {
        return !!t.attachment;
      });
    }
  }, {
    key: "getAttachments",
    value: function getAttachments() {
      return this.getAttachmentPieces().map(function (t) {
        return t.attachment;
      });
    }
  }, {
    key: "getAttachmentAndPositionById",
    value: function getAttachmentAndPositionById(t) {
      var e = 0;
      var _iterator3 = _createForOfIteratorHelper(this.pieceList.toArray()),
        _step3;
      try {
        for (_iterator3.s(); !(_step3 = _iterator3.n()).done;) {
          var _n15 = _step3.value;
          var i;
          if ((null === (i = _n15.attachment) || void 0 === i ? void 0 : i.id) === t) return {
            attachment: _n15.attachment,
            position: e
          };
          e += _n15.length;
        }
      } catch (err) {
        _iterator3.e(err);
      } finally {
        _iterator3.f();
      }
      return {
        attachment: null,
        position: null
      };
    }
  }, {
    key: "getAttachmentById",
    value: function getAttachmentById(t) {
      var _this$getAttachmentAn = this.getAttachmentAndPositionById(t),
        e = _this$getAttachmentAn.attachment;
      return e;
    }
  }, {
    key: "getRangeOfAttachment",
    value: function getRangeOfAttachment(t) {
      var e = this.getAttachmentAndPositionById(t.id),
        i = e.position;
      if (t = e.attachment) return [i, i + 1];
    }
  }, {
    key: "updateAttributesForAttachment",
    value: function updateAttributesForAttachment(t, e) {
      var i = this.getRangeOfAttachment(e);
      return i ? this.addAttributesAtRange(t, i) : this;
    }
  }, {
    key: "getLength",
    value: function getLength() {
      return this.pieceList.getEndPosition();
    }
  }, {
    key: "isEmpty",
    value: function isEmpty() {
      return 0 === this.getLength();
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      var e;
      return _superPropGet(Yi, "isEqualTo", this, 3)([t]) || (null == t || null === (e = t.pieceList) || void 0 === e ? void 0 : e.isEqualTo(this.pieceList));
    }
  }, {
    key: "isBlockBreak",
    value: function isBlockBreak() {
      return 1 === this.getLength() && this.pieceList.getObjectAtIndex(0).isBlockBreak();
    }
  }, {
    key: "eachPiece",
    value: function eachPiece(t) {
      return this.pieceList.eachObject(t);
    }
  }, {
    key: "getPieces",
    value: function getPieces() {
      return this.pieceList.toArray();
    }
  }, {
    key: "getPieceAtPosition",
    value: function getPieceAtPosition(t) {
      return this.pieceList.getObjectAtPosition(t);
    }
  }, {
    key: "contentsForInspection",
    value: function contentsForInspection() {
      return {
        pieceList: this.pieceList.inspect()
      };
    }
  }, {
    key: "toSerializableText",
    value: function toSerializableText() {
      var t = this.pieceList.selectSplittableList(function (t) {
        return t.isSerializable();
      });
      return this.copyWithPieceList(t);
    }
  }, {
    key: "toString",
    value: function toString() {
      return this.pieceList.toString();
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return this.pieceList.toJSON();
    }
  }, {
    key: "toConsole",
    value: function toConsole() {
      return JSON.stringify(this.pieceList.toArray().map(function (t) {
        return JSON.parse(t.toConsole());
      }));
    }
  }, {
    key: "getDirection",
    value: function getDirection() {
      return lt(this.toString());
    }
  }, {
    key: "isRTL",
    value: function isRTL() {
      return "rtl" === this.getDirection();
    }
  }], [{
    key: "textForAttachmentWithAttributes",
    value: function textForAttachmentWithAttributes(t, e) {
      return new this([new zi(t, e)]);
    }
  }, {
    key: "textForStringWithAttributes",
    value: function textForStringWithAttributes(t, e) {
      return new this([new qi(t, e)]);
    }
  }, {
    key: "fromJSON",
    value: function fromJSON(t) {
      return new this(Array.from(t).map(function (t) {
        return Wi.fromJSON(t);
      }));
    }
  }]);
}(rt);
var $i = /*#__PURE__*/function (_rt6) {
  function $i(t, e, i) {
    var _this33;
    _classCallCheck(this, $i);
    _this33 = _callSuper(this, $i, arguments), _this33.text = Xi(t || new Yi()), _this33.attributes = e || [], _this33.htmlAttributes = i || {};
    return _this33;
  }
  _inherits($i, _rt6);
  return _createClass($i, [{
    key: "isEmpty",
    value: function isEmpty() {
      return this.text.isBlockBreak();
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      return !!_superPropGet($i, "isEqualTo", this, 3)([t]) || this.text.isEqualTo(null == t ? void 0 : t.text) && ot(this.attributes, null == t ? void 0 : t.attributes) && Tt(this.htmlAttributes, null == t ? void 0 : t.htmlAttributes);
    }
  }, {
    key: "copyWithText",
    value: function copyWithText(t) {
      return new $i(t, this.attributes, this.htmlAttributes);
    }
  }, {
    key: "copyWithoutText",
    value: function copyWithoutText() {
      return this.copyWithText(null);
    }
  }, {
    key: "copyWithAttributes",
    value: function copyWithAttributes(t) {
      return new $i(this.text, t, this.htmlAttributes);
    }
  }, {
    key: "copyWithoutAttributes",
    value: function copyWithoutAttributes() {
      return this.copyWithAttributes(null);
    }
  }, {
    key: "copyUsingObjectMap",
    value: function copyUsingObjectMap(t) {
      var e = t.find(this.text);
      return e ? this.copyWithText(e) : this.copyWithText(this.text.copyUsingObjectMap(t));
    }
  }, {
    key: "addAttribute",
    value: function addAttribute(t) {
      var e = this.attributes.concat(rn(t));
      return this.copyWithAttributes(e);
    }
  }, {
    key: "addHTMLAttribute",
    value: function addHTMLAttribute(t, e) {
      var i = Object.assign({}, this.htmlAttributes, _defineProperty({}, t, e));
      return new $i(this.text, this.attributes, i);
    }
  }, {
    key: "removeAttribute",
    value: function removeAttribute(t) {
      var _mt2 = mt(t),
        e = _mt2.listAttribute,
        i = sn(sn(this.attributes, t), e);
      return this.copyWithAttributes(i);
    }
  }, {
    key: "removeLastAttribute",
    value: function removeLastAttribute() {
      return this.removeAttribute(this.getLastAttribute());
    }
  }, {
    key: "getLastAttribute",
    value: function getLastAttribute() {
      return on(this.attributes);
    }
  }, {
    key: "getAttributes",
    value: function getAttributes() {
      return this.attributes.slice(0);
    }
  }, {
    key: "getAttributeLevel",
    value: function getAttributeLevel() {
      return this.attributes.length;
    }
  }, {
    key: "getAttributeAtLevel",
    value: function getAttributeAtLevel(t) {
      return this.attributes[t - 1];
    }
  }, {
    key: "hasAttribute",
    value: function hasAttribute(t) {
      return this.attributes.includes(t);
    }
  }, {
    key: "hasAttributes",
    value: function hasAttributes() {
      return this.getAttributeLevel() > 0;
    }
  }, {
    key: "getLastNestableAttribute",
    value: function getLastNestableAttribute() {
      return on(this.getNestableAttributes());
    }
  }, {
    key: "getNestableAttributes",
    value: function getNestableAttributes() {
      return this.attributes.filter(function (t) {
        return mt(t).nestable;
      });
    }
  }, {
    key: "getNestingLevel",
    value: function getNestingLevel() {
      return this.getNestableAttributes().length;
    }
  }, {
    key: "decreaseNestingLevel",
    value: function decreaseNestingLevel() {
      var t = this.getLastNestableAttribute();
      return t ? this.removeAttribute(t) : this;
    }
  }, {
    key: "increaseNestingLevel",
    value: function increaseNestingLevel() {
      var t = this.getLastNestableAttribute();
      if (t) {
        var _e19 = this.attributes.lastIndexOf(t),
          _i22 = st.apply(void 0, [this.attributes, _e19 + 1, 0].concat(_toConsumableArray(rn(t))));
        return this.copyWithAttributes(_i22);
      }
      return this;
    }
  }, {
    key: "getListItemAttributes",
    value: function getListItemAttributes() {
      return this.attributes.filter(function (t) {
        return mt(t).listAttribute;
      });
    }
  }, {
    key: "isListItem",
    value: function isListItem() {
      var t;
      return null === (t = mt(this.getLastAttribute())) || void 0 === t ? void 0 : t.listAttribute;
    }
  }, {
    key: "isTerminalBlock",
    value: function isTerminalBlock() {
      var t;
      return null === (t = mt(this.getLastAttribute())) || void 0 === t ? void 0 : t.terminal;
    }
  }, {
    key: "breaksOnReturn",
    value: function breaksOnReturn() {
      var t;
      return null === (t = mt(this.getLastAttribute())) || void 0 === t ? void 0 : t.breakOnReturn;
    }
  }, {
    key: "findLineBreakInDirectionFromPosition",
    value: function findLineBreakInDirectionFromPosition(t, e) {
      var i = this.toString();
      var n;
      switch (t) {
        case "forward":
          n = i.indexOf("\n", e);
          break;
        case "backward":
          n = i.slice(0, e).lastIndexOf("\n");
      }
      if (-1 !== n) return n;
    }
  }, {
    key: "contentsForInspection",
    value: function contentsForInspection() {
      return {
        text: this.text.inspect(),
        attributes: this.attributes
      };
    }
  }, {
    key: "toString",
    value: function toString() {
      return this.text.toString();
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return {
        text: this.text,
        attributes: this.attributes,
        htmlAttributes: this.htmlAttributes
      };
    }
  }, {
    key: "getDirection",
    value: function getDirection() {
      return this.text.getDirection();
    }
  }, {
    key: "isRTL",
    value: function isRTL() {
      return this.text.isRTL();
    }
  }, {
    key: "getLength",
    value: function getLength() {
      return this.text.getLength();
    }
  }, {
    key: "canBeConsolidatedWith",
    value: function canBeConsolidatedWith(t) {
      return !this.hasAttributes() && !t.hasAttributes() && this.getDirection() === t.getDirection();
    }
  }, {
    key: "consolidateWith",
    value: function consolidateWith(t) {
      var e = Yi.textForStringWithAttributes("\n"),
        i = this.getTextWithoutBlockBreak().appendText(e);
      return this.copyWithText(i.appendText(t.text));
    }
  }, {
    key: "splitAtOffset",
    value: function splitAtOffset(t) {
      var e, i;
      return 0 === t ? (e = null, i = this) : t === this.getLength() ? (e = this, i = null) : (e = this.copyWithText(this.text.getTextAtRange([0, t])), i = this.copyWithText(this.text.getTextAtRange([t, this.getLength()]))), [e, i];
    }
  }, {
    key: "getBlockBreakPosition",
    value: function getBlockBreakPosition() {
      return this.text.getLength() - 1;
    }
  }, {
    key: "getTextWithoutBlockBreak",
    value: function getTextWithoutBlockBreak() {
      return en(this.text) ? this.text.getTextAtRange([0, this.getBlockBreakPosition()]) : this.text.copy();
    }
  }, {
    key: "canBeGrouped",
    value: function canBeGrouped(t) {
      return this.attributes[t];
    }
  }, {
    key: "canBeGroupedWith",
    value: function canBeGroupedWith(t, e) {
      var i = t.getAttributes(),
        r = i[e],
        o = this.attributes[e];
      return o === r && !(!1 === mt(o).group && !function () {
        if (!dt) {
          dt = [];
          for (var _t12 in n) {
            var _e20 = n[_t12].listAttribute;
            null != _e20 && dt.push(_e20);
          }
        }
        return dt;
      }().includes(i[e + 1])) && (this.getDirection() === t.getDirection() || t.isEmpty());
    }
  }], [{
    key: "fromJSON",
    value: function fromJSON(t) {
      return new this(Yi.fromJSON(t.text), t.attributes, t.htmlAttributes);
    }
  }]);
}(rt);
var Xi = function Xi(t) {
    return t = Zi(t), t = tn(t);
  },
  Zi = function Zi(t) {
    var e = !1;
    var i = t.getPieces();
    var n = i.slice(0, i.length - 1);
    var r = i[i.length - 1];
    return r ? (n = n.map(function (t) {
      return t.isBlockBreak() ? (e = !0, nn(t)) : t;
    }), e ? new Yi([].concat(_toConsumableArray(n), [r])) : t) : t;
  },
  Qi = Yi.textForStringWithAttributes("\n", {
    blockBreak: !0
  }),
  tn = function tn(t) {
    return en(t) ? t : t.appendText(Qi);
  },
  en = function en(t) {
    var e = t.getLength();
    if (0 === e) return !1;
    return t.getTextAtRange([e - 1, e]).isBlockBreak();
  },
  nn = function nn(t) {
    return t.copyWithoutAttribute("blockBreak");
  },
  rn = function rn(t) {
    var _mt3 = mt(t),
      e = _mt3.listAttribute;
    return e ? [e, t] : [t];
  },
  on = function on(t) {
    return t.slice(-1)[0];
  },
  sn = function sn(t, e) {
    var i = t.lastIndexOf(e);
    return -1 === i ? t : st(t, i, 1);
  };
var an = /*#__PURE__*/function (_rt7) {
  function an() {
    var _this34;
    _classCallCheck(this, an);
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
    _this34 = _callSuper(this, an, arguments), 0 === t.length && (t = [new $i()]), _this34.blockList = Hi.box(t);
    return _this34;
  }
  _inherits(an, _rt7);
  return _createClass(an, [{
    key: "isEmpty",
    value: function isEmpty() {
      var t = this.getBlockAtIndex(0);
      return 1 === this.blockList.length && t.isEmpty() && !t.hasAttributes();
    }
  }, {
    key: "copy",
    value: function copy() {
      var t = (arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {}).consolidateBlocks ? this.blockList.consolidate().toArray() : this.blockList.toArray();
      return new this.constructor(t);
    }
  }, {
    key: "copyUsingObjectsFromDocument",
    value: function copyUsingObjectsFromDocument(t) {
      var e = new Zt(t.getObjects());
      return this.copyUsingObjectMap(e);
    }
  }, {
    key: "copyUsingObjectMap",
    value: function copyUsingObjectMap(t) {
      var e = this.getBlocks().map(function (e) {
        return t.find(e) || e.copyUsingObjectMap(t);
      });
      return new this.constructor(e);
    }
  }, {
    key: "copyWithBaseBlockAttributes",
    value: function copyWithBaseBlockAttributes() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
      var e = this.getBlocks().map(function (e) {
        var i = t.concat(e.getAttributes());
        return e.copyWithAttributes(i);
      });
      return new this.constructor(e);
    }
  }, {
    key: "replaceBlock",
    value: function replaceBlock(t, e) {
      var i = this.blockList.indexOf(t);
      return -1 === i ? this : new this.constructor(this.blockList.replaceObjectAtIndex(e, i));
    }
  }, {
    key: "insertDocumentAtRange",
    value: function insertDocumentAtRange(t, e) {
      var i = t.blockList;
      e = wt(e);
      var _e21 = e,
        _e22 = _slicedToArray(_e21, 1),
        n = _e22[0];
      var _this$locationFromPos = this.locationFromPosition(n),
        r = _this$locationFromPos.index,
        o = _this$locationFromPos.offset;
      var s = this;
      var a = this.getBlockAtPosition(n);
      return Lt(e) && a.isEmpty() && !a.hasAttributes() ? s = new this.constructor(s.blockList.removeObjectAtIndex(r)) : a.getBlockBreakPosition() === o && n++, s = s.removeTextAtRange(e), new this.constructor(s.blockList.insertSplittableListAtPosition(i, n));
    }
  }, {
    key: "mergeDocumentAtRange",
    value: function mergeDocumentAtRange(t, e) {
      var i, n;
      e = wt(e);
      var _e23 = e,
        _e24 = _slicedToArray(_e23, 1),
        r = _e24[0],
        o = this.locationFromPosition(r),
        s = this.getBlockAtIndex(o.index).getAttributes(),
        a = t.getBaseBlockAttributes(),
        l = s.slice(-a.length);
      if (ot(a, l)) {
        var _e25 = s.slice(0, -a.length);
        i = t.copyWithBaseBlockAttributes(_e25);
      } else i = t.copy({
        consolidateBlocks: !0
      }).copyWithBaseBlockAttributes(s);
      var c = i.getBlockCount(),
        u = i.getBlockAtIndex(0);
      if (ot(s, u.getAttributes())) {
        var _t13 = u.getTextWithoutBlockBreak();
        if (n = this.insertTextAtRange(_t13, e), c > 1) {
          i = new this.constructor(i.getBlocks().slice(1));
          var _e26 = r + _t13.getLength();
          n = n.insertDocumentAtRange(i, _e26);
        }
      } else n = this.insertDocumentAtRange(i, e);
      return n;
    }
  }, {
    key: "insertTextAtRange",
    value: function insertTextAtRange(t, e) {
      e = wt(e);
      var _e27 = e,
        _e28 = _slicedToArray(_e27, 1),
        i = _e28[0],
        _this$locationFromPos2 = this.locationFromPosition(i),
        n = _this$locationFromPos2.index,
        r = _this$locationFromPos2.offset,
        o = this.removeTextAtRange(e);
      return new this.constructor(o.blockList.editObjectAtIndex(n, function (e) {
        return e.copyWithText(e.text.insertTextAtPosition(t, r));
      }));
    }
  }, {
    key: "removeTextAtRange",
    value: function removeTextAtRange(t) {
      var e;
      t = wt(t);
      var _t14 = t,
        _t15 = _slicedToArray(_t14, 2),
        i = _t15[0],
        n = _t15[1];
      if (Lt(t)) return this;
      var _Array$from = Array.from(this.locationRangeFromRange(t)),
        _Array$from2 = _slicedToArray(_Array$from, 2),
        r = _Array$from2[0],
        o = _Array$from2[1],
        s = r.index,
        a = r.offset,
        l = this.getBlockAtIndex(s),
        c = o.index,
        u = o.offset,
        h = this.getBlockAtIndex(c);
      if (n - i == 1 && l.getBlockBreakPosition() === a && h.getBlockBreakPosition() !== u && "\n" === h.text.getStringAtPosition(u)) e = this.blockList.editObjectAtIndex(c, function (t) {
        return t.copyWithText(t.text.removeTextAtRange([u, u + 1]));
      });else {
        var _t16;
        var _i23 = l.text.getTextAtRange([0, a]),
          _n16 = h.text.getTextAtRange([u, h.getLength()]),
          _r9 = _i23.appendText(_n16);
        _t16 = s !== c && 0 === a && l.getAttributeLevel() >= h.getAttributeLevel() ? h.copyWithText(_r9) : l.copyWithText(_r9);
        var _o4 = c + 1 - s;
        e = this.blockList.splice(s, _o4, _t16);
      }
      return new this.constructor(e);
    }
  }, {
    key: "moveTextFromRangeToPosition",
    value: function moveTextFromRangeToPosition(t, e) {
      var i;
      t = wt(t);
      var _t17 = t,
        _t18 = _slicedToArray(_t17, 2),
        n = _t18[0],
        r = _t18[1];
      if (n <= e && e <= r) return this;
      var o = this.getDocumentAtRange(t),
        s = this.removeTextAtRange(t);
      var a = n < e;
      a && (e -= o.getLength());
      var _o$getBlocks = o.getBlocks(),
        _o$getBlocks2 = _toArray(_o$getBlocks),
        l = _o$getBlocks2[0],
        c = _o$getBlocks2.slice(1);
      return 0 === c.length ? (i = l.getTextWithoutBlockBreak(), a && (e += 1)) : i = l.text, s = s.insertTextAtRange(i, e), 0 === c.length ? s : (o = new this.constructor(c), e += i.getLength(), s.insertDocumentAtRange(o, e));
    }
  }, {
    key: "addAttributeAtRange",
    value: function addAttributeAtRange(t, e, i) {
      var n = this.blockList;
      return this.eachBlockAtRange(i, function (i, r, o) {
        return n = n.editObjectAtIndex(o, function () {
          return mt(t) ? i.addAttribute(t, e) : r[0] === r[1] ? i : i.copyWithText(i.text.addAttributeAtRange(t, e, r));
        });
      }), new this.constructor(n);
    }
  }, {
    key: "addAttribute",
    value: function addAttribute(t, e) {
      var i = this.blockList;
      return this.eachBlock(function (n, r) {
        return i = i.editObjectAtIndex(r, function () {
          return n.addAttribute(t, e);
        });
      }), new this.constructor(i);
    }
  }, {
    key: "removeAttributeAtRange",
    value: function removeAttributeAtRange(t, e) {
      var i = this.blockList;
      return this.eachBlockAtRange(e, function (e, n, r) {
        mt(t) ? i = i.editObjectAtIndex(r, function () {
          return e.removeAttribute(t);
        }) : n[0] !== n[1] && (i = i.editObjectAtIndex(r, function () {
          return e.copyWithText(e.text.removeAttributeAtRange(t, n));
        }));
      }), new this.constructor(i);
    }
  }, {
    key: "updateAttributesForAttachment",
    value: function updateAttributesForAttachment(t, e) {
      var i = this.getRangeOfAttachment(e),
        _Array$from3 = Array.from(i),
        _Array$from4 = _slicedToArray(_Array$from3, 1),
        n = _Array$from4[0],
        _this$locationFromPos3 = this.locationFromPosition(n),
        r = _this$locationFromPos3.index,
        o = this.getTextAtIndex(r);
      return new this.constructor(this.blockList.editObjectAtIndex(r, function (i) {
        return i.copyWithText(o.updateAttributesForAttachment(t, e));
      }));
    }
  }, {
    key: "removeAttributeForAttachment",
    value: function removeAttributeForAttachment(t, e) {
      var i = this.getRangeOfAttachment(e);
      return this.removeAttributeAtRange(t, i);
    }
  }, {
    key: "setHTMLAttributeAtPosition",
    value: function setHTMLAttributeAtPosition(t, e, i) {
      var n = this.getBlockAtPosition(t),
        r = n.addHTMLAttribute(e, i);
      return this.replaceBlock(n, r);
    }
  }, {
    key: "insertBlockBreakAtRange",
    value: function insertBlockBreakAtRange(t) {
      var e;
      t = wt(t);
      var _t19 = t,
        _t20 = _slicedToArray(_t19, 1),
        i = _t20[0],
        _this$locationFromPos4 = this.locationFromPosition(i),
        n = _this$locationFromPos4.offset,
        r = this.removeTextAtRange(t);
      return 0 === n && (e = [new $i()]), new this.constructor(r.blockList.insertSplittableListAtPosition(new Hi(e), i));
    }
  }, {
    key: "applyBlockAttributeAtRange",
    value: function applyBlockAttributeAtRange(t, e, i) {
      var n = this.expandRangeToLineBreaksAndSplitBlocks(i);
      var r = n.document;
      i = n.range;
      var o = mt(t);
      if (o.listAttribute) {
        r = r.removeLastListAttributeAtRange(i, {
          exceptAttributeName: t
        });
        var _e29 = r.convertLineBreaksToBlockBreaksInRange(i);
        r = _e29.document, i = _e29.range;
      } else r = o.exclusive ? r.removeBlockAttributesAtRange(i) : o.terminal ? r.removeLastTerminalAttributeAtRange(i) : r.consolidateBlocksAtRange(i);
      return r.addAttributeAtRange(t, e, i);
    }
  }, {
    key: "removeLastListAttributeAtRange",
    value: function removeLastListAttributeAtRange(t) {
      var e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
        i = this.blockList;
      return this.eachBlockAtRange(t, function (t, n, r) {
        var o = t.getLastAttribute();
        o && mt(o).listAttribute && o !== e.exceptAttributeName && (i = i.editObjectAtIndex(r, function () {
          return t.removeAttribute(o);
        }));
      }), new this.constructor(i);
    }
  }, {
    key: "removeLastTerminalAttributeAtRange",
    value: function removeLastTerminalAttributeAtRange(t) {
      var e = this.blockList;
      return this.eachBlockAtRange(t, function (t, i, n) {
        var r = t.getLastAttribute();
        r && mt(r).terminal && (e = e.editObjectAtIndex(n, function () {
          return t.removeAttribute(r);
        }));
      }), new this.constructor(e);
    }
  }, {
    key: "removeBlockAttributesAtRange",
    value: function removeBlockAttributesAtRange(t) {
      var e = this.blockList;
      return this.eachBlockAtRange(t, function (t, i, n) {
        t.hasAttributes() && (e = e.editObjectAtIndex(n, function () {
          return t.copyWithoutAttributes();
        }));
      }), new this.constructor(e);
    }
  }, {
    key: "expandRangeToLineBreaksAndSplitBlocks",
    value: function expandRangeToLineBreaksAndSplitBlocks(t) {
      var e;
      t = wt(t);
      var _t21 = t,
        _t22 = _slicedToArray(_t21, 2),
        i = _t22[0],
        n = _t22[1];
      var r = this.locationFromPosition(i),
        o = this.locationFromPosition(n);
      var s = this;
      var a = s.getBlockAtIndex(r.index);
      if (r.offset = a.findLineBreakInDirectionFromPosition("backward", r.offset), null != r.offset && (e = s.positionFromLocation(r), s = s.insertBlockBreakAtRange([e, e + 1]), o.index += 1, o.offset -= s.getBlockAtIndex(r.index).getLength(), r.index += 1), r.offset = 0, 0 === o.offset && o.index > r.index) o.index -= 1, o.offset = s.getBlockAtIndex(o.index).getBlockBreakPosition();else {
        var _t23 = s.getBlockAtIndex(o.index);
        "\n" === _t23.text.getStringAtRange([o.offset - 1, o.offset]) ? o.offset -= 1 : o.offset = _t23.findLineBreakInDirectionFromPosition("forward", o.offset), o.offset !== _t23.getBlockBreakPosition() && (e = s.positionFromLocation(o), s = s.insertBlockBreakAtRange([e, e + 1]));
      }
      return i = s.positionFromLocation(r), n = s.positionFromLocation(o), {
        document: s,
        range: t = wt([i, n])
      };
    }
  }, {
    key: "convertLineBreaksToBlockBreaksInRange",
    value: function convertLineBreaksToBlockBreaksInRange(t) {
      t = wt(t);
      var _t24 = t,
        _t25 = _slicedToArray(_t24, 1),
        e = _t25[0];
      var i = this.getStringAtRange(t).slice(0, -1);
      var n = this;
      return i.replace(/.*?\n/g, function (t) {
        e += t.length, n = n.insertBlockBreakAtRange([e - 1, e]);
      }), {
        document: n,
        range: t
      };
    }
  }, {
    key: "consolidateBlocksAtRange",
    value: function consolidateBlocksAtRange(t) {
      t = wt(t);
      var _t26 = t,
        _t27 = _slicedToArray(_t26, 2),
        e = _t27[0],
        i = _t27[1],
        n = this.locationFromPosition(e).index,
        r = this.locationFromPosition(i).index;
      return new this.constructor(this.blockList.consolidateFromIndexToIndex(n, r));
    }
  }, {
    key: "getDocumentAtRange",
    value: function getDocumentAtRange(t) {
      t = wt(t);
      var e = this.blockList.getSplittableListInRange(t).toArray();
      return new this.constructor(e);
    }
  }, {
    key: "getStringAtRange",
    value: function getStringAtRange(t) {
      var e;
      var i = t = wt(t);
      return i[i.length - 1] !== this.getLength() && (e = -1), this.getDocumentAtRange(t).toString().slice(0, e);
    }
  }, {
    key: "getBlockAtIndex",
    value: function getBlockAtIndex(t) {
      return this.blockList.getObjectAtIndex(t);
    }
  }, {
    key: "getBlockAtPosition",
    value: function getBlockAtPosition(t) {
      var _this$locationFromPos5 = this.locationFromPosition(t),
        e = _this$locationFromPos5.index;
      return this.getBlockAtIndex(e);
    }
  }, {
    key: "getTextAtIndex",
    value: function getTextAtIndex(t) {
      var e;
      return null === (e = this.getBlockAtIndex(t)) || void 0 === e ? void 0 : e.text;
    }
  }, {
    key: "getTextAtPosition",
    value: function getTextAtPosition(t) {
      var _this$locationFromPos6 = this.locationFromPosition(t),
        e = _this$locationFromPos6.index;
      return this.getTextAtIndex(e);
    }
  }, {
    key: "getPieceAtPosition",
    value: function getPieceAtPosition(t) {
      var _this$locationFromPos7 = this.locationFromPosition(t),
        e = _this$locationFromPos7.index,
        i = _this$locationFromPos7.offset;
      return this.getTextAtIndex(e).getPieceAtPosition(i);
    }
  }, {
    key: "getCharacterAtPosition",
    value: function getCharacterAtPosition(t) {
      var _this$locationFromPos8 = this.locationFromPosition(t),
        e = _this$locationFromPos8.index,
        i = _this$locationFromPos8.offset;
      return this.getTextAtIndex(e).getStringAtRange([i, i + 1]);
    }
  }, {
    key: "getLength",
    value: function getLength() {
      return this.blockList.getEndPosition();
    }
  }, {
    key: "getBlocks",
    value: function getBlocks() {
      return this.blockList.toArray();
    }
  }, {
    key: "getBlockCount",
    value: function getBlockCount() {
      return this.blockList.length;
    }
  }, {
    key: "getEditCount",
    value: function getEditCount() {
      return this.editCount;
    }
  }, {
    key: "eachBlock",
    value: function eachBlock(t) {
      return this.blockList.eachObject(t);
    }
  }, {
    key: "eachBlockAtRange",
    value: function eachBlockAtRange(t, e) {
      var i, n;
      t = wt(t);
      var _t28 = t,
        _t29 = _slicedToArray(_t28, 2),
        r = _t29[0],
        o = _t29[1],
        s = this.locationFromPosition(r),
        a = this.locationFromPosition(o);
      if (s.index === a.index) return i = this.getBlockAtIndex(s.index), n = [s.offset, a.offset], e(i, n, s.index);
      for (var _t30 = s.index; _t30 <= a.index; _t30++) if (i = this.getBlockAtIndex(_t30), i) {
        switch (_t30) {
          case s.index:
            n = [s.offset, i.text.getLength()];
            break;
          case a.index:
            n = [0, a.offset];
            break;
          default:
            n = [0, i.text.getLength()];
        }
        e(i, n, _t30);
      }
    }
  }, {
    key: "getCommonAttributesAtRange",
    value: function getCommonAttributesAtRange(t) {
      t = wt(t);
      var _t31 = t,
        _t32 = _slicedToArray(_t31, 1),
        e = _t32[0];
      if (Lt(t)) return this.getCommonAttributesAtPosition(e);
      {
        var _e30 = [],
          _i24 = [];
        return this.eachBlockAtRange(t, function (t, n) {
          if (n[0] !== n[1]) return _e30.push(t.text.getCommonAttributesAtRange(n)), _i24.push(ln(t));
        }), Ht.fromCommonAttributesOfObjects(_e30).merge(Ht.fromCommonAttributesOfObjects(_i24)).toObject();
      }
    }
  }, {
    key: "getCommonAttributesAtPosition",
    value: function getCommonAttributesAtPosition(t) {
      var e, i;
      var _this$locationFromPos9 = this.locationFromPosition(t),
        n = _this$locationFromPos9.index,
        r = _this$locationFromPos9.offset,
        o = this.getBlockAtIndex(n);
      if (!o) return {};
      var s = ln(o),
        a = o.text.getAttributesAtPosition(r),
        l = o.text.getAttributesAtPosition(r - 1),
        c = Object.keys(W).filter(function (t) {
          return W[t].inheritable;
        });
      for (e in l) i = l[e], (i === a[e] || c.includes(e)) && (s[e] = i);
      return s;
    }
  }, {
    key: "getRangeOfCommonAttributeAtPosition",
    value: function getRangeOfCommonAttributeAtPosition(t, e) {
      var _this$locationFromPos0 = this.locationFromPosition(e),
        i = _this$locationFromPos0.index,
        n = _this$locationFromPos0.offset,
        r = this.getTextAtIndex(i),
        _Array$from5 = Array.from(r.getExpandedRangeForAttributeAtOffset(t, n)),
        _Array$from6 = _slicedToArray(_Array$from5, 2),
        o = _Array$from6[0],
        s = _Array$from6[1],
        a = this.positionFromLocation({
          index: i,
          offset: o
        }),
        l = this.positionFromLocation({
          index: i,
          offset: s
        });
      return wt([a, l]);
    }
  }, {
    key: "getBaseBlockAttributes",
    value: function getBaseBlockAttributes() {
      var _this35 = this;
      var t = this.getBlockAtIndex(0).getAttributes();
      var _loop2 = function _loop2() {
        var i = _this35.getBlockAtIndex(_e31).getAttributes(),
          n = Math.min(t.length, i.length);
        t = function () {
          var e = [];
          for (var _r0 = 0; _r0 < n && i[_r0] === t[_r0]; _r0++) e.push(i[_r0]);
          return e;
        }();
      };
      for (var _e31 = 1; _e31 < this.getBlockCount(); _e31++) {
        _loop2();
      }
      return t;
    }
  }, {
    key: "getAttachmentById",
    value: function getAttachmentById(t) {
      var _iterator4 = _createForOfIteratorHelper(this.getAttachments()),
        _step4;
      try {
        for (_iterator4.s(); !(_step4 = _iterator4.n()).done;) {
          var _e32 = _step4.value;
          if (_e32.id === t) return _e32;
        }
      } catch (err) {
        _iterator4.e(err);
      } finally {
        _iterator4.f();
      }
    }
  }, {
    key: "getAttachmentPieces",
    value: function getAttachmentPieces() {
      var t = [];
      return this.blockList.eachObject(function (e) {
        var i = e.text;
        return t = t.concat(i.getAttachmentPieces());
      }), t;
    }
  }, {
    key: "getAttachments",
    value: function getAttachments() {
      return this.getAttachmentPieces().map(function (t) {
        return t.attachment;
      });
    }
  }, {
    key: "getRangeOfAttachment",
    value: function getRangeOfAttachment(t) {
      var e = 0;
      var i = this.blockList.toArray();
      for (var _n17 = 0; _n17 < i.length; _n17++) {
        var _r1 = i[_n17].text,
          _o5 = _r1.getRangeOfAttachment(t);
        if (_o5) return wt([e + _o5[0], e + _o5[1]]);
        e += _r1.getLength();
      }
    }
  }, {
    key: "getLocationRangeOfAttachment",
    value: function getLocationRangeOfAttachment(t) {
      var e = this.getRangeOfAttachment(t);
      return this.locationRangeFromRange(e);
    }
  }, {
    key: "getAttachmentPieceForAttachment",
    value: function getAttachmentPieceForAttachment(t) {
      var _iterator5 = _createForOfIteratorHelper(this.getAttachmentPieces()),
        _step5;
      try {
        for (_iterator5.s(); !(_step5 = _iterator5.n()).done;) {
          var _e33 = _step5.value;
          if (_e33.attachment === t) return _e33;
        }
      } catch (err) {
        _iterator5.e(err);
      } finally {
        _iterator5.f();
      }
    }
  }, {
    key: "findRangesForBlockAttribute",
    value: function findRangesForBlockAttribute(t) {
      var e = 0;
      var i = [];
      return this.getBlocks().forEach(function (n) {
        var r = n.getLength();
        n.hasAttribute(t) && i.push([e, e + r]), e += r;
      }), i;
    }
  }, {
    key: "findRangesForTextAttribute",
    value: function findRangesForTextAttribute(t) {
      var _ref11 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
        e = _ref11.withValue,
        i = 0,
        n = [];
      var r = [];
      return this.getPieces().forEach(function (o) {
        var s = o.getLength();
        (function (i) {
          return e ? i.getAttribute(t) === e : i.hasAttribute(t);
        })(o) && (n[1] === i ? n[1] = i + s : r.push(n = [i, i + s])), i += s;
      }), r;
    }
  }, {
    key: "locationFromPosition",
    value: function locationFromPosition(t) {
      var e = this.blockList.findIndexAndOffsetAtPosition(Math.max(0, t));
      if (null != e.index) return e;
      {
        var _t33 = this.getBlocks();
        return {
          index: _t33.length - 1,
          offset: _t33[_t33.length - 1].getLength()
        };
      }
    }
  }, {
    key: "positionFromLocation",
    value: function positionFromLocation(t) {
      return this.blockList.findPositionAtIndexAndOffset(t.index, t.offset);
    }
  }, {
    key: "locationRangeFromPosition",
    value: function locationRangeFromPosition(t) {
      return wt(this.locationFromPosition(t));
    }
  }, {
    key: "locationRangeFromRange",
    value: function locationRangeFromRange(t) {
      if (!(t = wt(t))) return;
      var _Array$from7 = Array.from(t),
        _Array$from8 = _slicedToArray(_Array$from7, 2),
        e = _Array$from8[0],
        i = _Array$from8[1],
        n = this.locationFromPosition(e),
        r = this.locationFromPosition(i);
      return wt([n, r]);
    }
  }, {
    key: "rangeFromLocationRange",
    value: function rangeFromLocationRange(t) {
      var e;
      t = wt(t);
      var i = this.positionFromLocation(t[0]);
      return Lt(t) || (e = this.positionFromLocation(t[1])), wt([i, e]);
    }
  }, {
    key: "isEqualTo",
    value: function isEqualTo(t) {
      return this.blockList.isEqualTo(null == t ? void 0 : t.blockList);
    }
  }, {
    key: "getTexts",
    value: function getTexts() {
      return this.getBlocks().map(function (t) {
        return t.text;
      });
    }
  }, {
    key: "getPieces",
    value: function getPieces() {
      var t = [];
      return Array.from(this.getTexts()).forEach(function (e) {
        t.push.apply(t, _toConsumableArray(Array.from(e.getPieces() || [])));
      }), t;
    }
  }, {
    key: "getObjects",
    value: function getObjects() {
      return this.getBlocks().concat(this.getTexts()).concat(this.getPieces());
    }
  }, {
    key: "toSerializableDocument",
    value: function toSerializableDocument() {
      var t = [];
      return this.blockList.eachObject(function (e) {
        return t.push(e.copyWithText(e.text.toSerializableText()));
      }), new this.constructor(t);
    }
  }, {
    key: "toString",
    value: function toString() {
      return this.blockList.toString();
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return this.blockList.toJSON();
    }
  }, {
    key: "toConsole",
    value: function toConsole() {
      return JSON.stringify(this.blockList.toArray().map(function (t) {
        return JSON.parse(t.text.toConsole());
      }));
    }
  }], [{
    key: "fromJSON",
    value: function fromJSON(t) {
      return new this(Array.from(t).map(function (t) {
        return $i.fromJSON(t);
      }));
    }
  }, {
    key: "fromString",
    value: function fromString(t, e) {
      var i = Yi.textForStringWithAttributes(t, e);
      return new this([new $i(i)]);
    }
  }]);
}(rt);
var ln = function ln(t) {
    var e = {},
      i = t.getLastAttribute();
    return i && (e[i] = !0), e;
  },
  cn = function cn(t) {
    var e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
    return {
      string: t = Wt(t),
      attributes: e,
      type: "string"
    };
  },
  un = function un(t, e) {
    try {
      return JSON.parse(t.getAttribute("data-trix-".concat(e)));
    } catch (t) {
      return {};
    }
  };
var hn = /*#__PURE__*/function (_q8) {
  function hn(t) {
    var _this36;
    _classCallCheck(this, hn);
    var _ref12 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
      e = _ref12.referenceElement;
    _this36 = _callSuper(this, hn, arguments), _this36.html = t, _this36.referenceElement = e, _this36.blocks = [], _this36.blockElements = [], _this36.processedElements = [];
    return _this36;
  }
  _inherits(hn, _q8);
  return _createClass(hn, [{
    key: "getDocument",
    value: function getDocument() {
      return an.fromJSON(this.blocks);
    }
  }, {
    key: "parse",
    value: function parse() {
      try {
        this.createHiddenContainer(), di.setHTML(this.containerElement, this.html);
        var _t34 = R(this.containerElement, {
          usingFilter: pn
        });
        for (; _t34.nextNode();) this.processNode(_t34.currentNode);
        return this.translateBlockElementMarginsToNewlines();
      } finally {
        this.removeHiddenContainer();
      }
    }
  }, {
    key: "createHiddenContainer",
    value: function createHiddenContainer() {
      return this.referenceElement ? (this.containerElement = this.referenceElement.cloneNode(!1), this.containerElement.removeAttribute("id"), this.containerElement.setAttribute("data-trix-internal", ""), this.containerElement.style.display = "none", this.referenceElement.parentNode.insertBefore(this.containerElement, this.referenceElement.nextSibling)) : (this.containerElement = T({
        tagName: "div",
        style: {
          display: "none"
        }
      }), document.body.appendChild(this.containerElement));
    }
  }, {
    key: "removeHiddenContainer",
    value: function removeHiddenContainer() {
      return S(this.containerElement);
    }
  }, {
    key: "processNode",
    value: function processNode(t) {
      switch (t.nodeType) {
        case Node.TEXT_NODE:
          if (!this.isInsignificantTextNode(t)) return this.appendBlockForTextNode(t), this.processTextNode(t);
          break;
        case Node.ELEMENT_NODE:
          return this.appendBlockForElement(t), this.processElement(t);
      }
    }
  }, {
    key: "appendBlockForTextNode",
    value: function appendBlockForTextNode(t) {
      var e = t.parentNode;
      if (e === this.currentBlockElement && this.isBlockElement(t.previousSibling)) return this.appendStringWithAttributes("\n");
      if (e === this.containerElement || this.isBlockElement(e)) {
        var i;
        var _t35 = this.getBlockAttributes(e),
          _n18 = this.getBlockHTMLAttributes(e);
        ot(_t35, null === (i = this.currentBlock) || void 0 === i ? void 0 : i.attributes) || (this.currentBlock = this.appendBlockForAttributesWithElement(_t35, e, _n18), this.currentBlockElement = e);
      }
    }
  }, {
    key: "appendBlockForElement",
    value: function appendBlockForElement(t) {
      var e = this.isBlockElement(t),
        i = C(this.currentBlockElement, t);
      if (e && !this.isBlockElement(t.firstChild)) {
        if (!this.isInsignificantTextNode(t.firstChild) || !this.isBlockElement(t.firstElementChild)) {
          var _e34 = this.getBlockAttributes(t),
            _n19 = this.getBlockHTMLAttributes(t);
          if (t.firstChild) {
            if (i && ot(_e34, this.currentBlock.attributes)) return this.appendStringWithAttributes("\n");
            this.currentBlock = this.appendBlockForAttributesWithElement(_e34, t, _n19), this.currentBlockElement = t;
          }
        }
      } else if (this.currentBlockElement && !i && !e) {
        var _e35 = this.findParentBlockElement(t);
        if (_e35) return this.appendBlockForElement(_e35);
        this.currentBlock = this.appendEmptyBlock(), this.currentBlockElement = null;
      }
    }
  }, {
    key: "findParentBlockElement",
    value: function findParentBlockElement(t) {
      var e = t.parentElement;
      for (; e && e !== this.containerElement;) {
        if (this.isBlockElement(e) && this.blockElements.includes(e)) return e;
        e = e.parentElement;
      }
      return null;
    }
  }, {
    key: "processTextNode",
    value: function processTextNode(t) {
      var e = t.data;
      var i;
      dn(t.parentNode) || (e = Vt(e), vn(null === (i = t.previousSibling) || void 0 === i ? void 0 : i.textContent) && (e = fn(e)));
      return this.appendStringWithAttributes(e, this.getTextAttributes(t.parentNode));
    }
  }, {
    key: "processElement",
    value: function processElement(t) {
      var e;
      if (P(t)) {
        if (e = un(t, "attachment"), Object.keys(e).length) {
          var _i25 = this.getTextAttributes(t);
          this.appendAttachmentWithAttributes(e, _i25), t.innerHTML = "";
        }
        return this.processedElements.push(t);
      }
      switch (k(t)) {
        case "br":
          return this.isExtraBR(t) || this.isBlockElement(t.nextSibling) || this.appendStringWithAttributes("\n", this.getTextAttributes(t)), this.processedElements.push(t);
        case "img":
          e = {
            url: t.getAttribute("src"),
            contentType: "image"
          };
          var _i26 = function (t) {
            var e = t.getAttribute("width"),
              i = t.getAttribute("height"),
              n = {};
            return e && (n.width = parseInt(e, 10)), i && (n.height = parseInt(i, 10)), n;
          }(t);
          for (var _t36 in _i26) {
            var _n20 = _i26[_t36];
            e[_t36] = _n20;
          }
          return this.appendAttachmentWithAttributes(e, this.getTextAttributes(t)), this.processedElements.push(t);
        case "tr":
          if (this.needsTableSeparator(t)) return this.appendStringWithAttributes(j.tableRowSeparator);
          break;
        case "td":
          if (this.needsTableSeparator(t)) return this.appendStringWithAttributes(j.tableCellSeparator);
      }
    }
  }, {
    key: "appendBlockForAttributesWithElement",
    value: function appendBlockForAttributesWithElement(t, e) {
      var i = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : {};
      this.blockElements.push(e);
      var n = function () {
        return {
          text: [],
          attributes: arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {},
          htmlAttributes: arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {}
        };
      }(t, i);
      return this.blocks.push(n), n;
    }
  }, {
    key: "appendEmptyBlock",
    value: function appendEmptyBlock() {
      return this.appendBlockForAttributesWithElement([], null);
    }
  }, {
    key: "appendStringWithAttributes",
    value: function appendStringWithAttributes(t, e) {
      return this.appendPiece(cn(t, e));
    }
  }, {
    key: "appendAttachmentWithAttributes",
    value: function appendAttachmentWithAttributes(t, e) {
      return this.appendPiece(function (t) {
        return {
          attachment: t,
          attributes: arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
          type: "attachment"
        };
      }(t, e));
    }
  }, {
    key: "appendPiece",
    value: function appendPiece(t) {
      return 0 === this.blocks.length && this.appendEmptyBlock(), this.blocks[this.blocks.length - 1].text.push(t);
    }
  }, {
    key: "appendStringToTextAtIndex",
    value: function appendStringToTextAtIndex(t, e) {
      var i = this.blocks[e].text,
        n = i[i.length - 1];
      if ("string" !== (null == n ? void 0 : n.type)) return i.push(cn(t));
      n.string += t;
    }
  }, {
    key: "prependStringToTextAtIndex",
    value: function prependStringToTextAtIndex(t, e) {
      var i = this.blocks[e].text,
        n = i[0];
      if ("string" !== (null == n ? void 0 : n.type)) return i.unshift(cn(t));
      n.string = t + n.string;
    }
  }, {
    key: "getTextAttributes",
    value: function getTextAttributes(t) {
      var e;
      var i = {};
      for (var _n21 in W) {
        var _r10 = W[_n21];
        if (_r10.tagName && y(t, {
          matchingSelector: _r10.tagName,
          untilNode: this.containerElement
        })) i[_n21] = !0;else if (_r10.parser) {
          if (e = _r10.parser(t), e) {
            var _o6 = !1;
            var _iterator6 = _createForOfIteratorHelper(this.findBlockElementAncestors(t)),
              _step6;
            try {
              for (_iterator6.s(); !(_step6 = _iterator6.n()).done;) {
                var _i27 = _step6.value;
                if (_r10.parser(_i27) === e) {
                  _o6 = !0;
                  break;
                }
              }
            } catch (err) {
              _iterator6.e(err);
            } finally {
              _iterator6.f();
            }
            _o6 || (i[_n21] = e);
          }
        } else _r10.styleProperty && (e = t.style[_r10.styleProperty], e && (i[_n21] = e));
      }
      if (P(t)) {
        var _n22 = un(t, "attributes");
        for (var _t37 in _n22) e = _n22[_t37], i[_t37] = e;
      }
      return i;
    }
  }, {
    key: "getBlockAttributes",
    value: function getBlockAttributes(t) {
      var e = [];
      for (; t && t !== this.containerElement;) {
        for (var _r11 in n) {
          var _o7 = n[_r11];
          var i;
          if (!1 !== _o7.parse) if (k(t) === _o7.tagName) (null !== (i = _o7.test) && void 0 !== i && i.call(_o7, t) || !_o7.test) && (e.push(_r11), _o7.listAttribute && e.push(_o7.listAttribute));
        }
        t = t.parentNode;
      }
      return e.reverse();
    }
  }, {
    key: "getBlockHTMLAttributes",
    value: function getBlockHTMLAttributes(t) {
      var e = {},
        i = Object.values(n).find(function (e) {
          return e.tagName === k(t);
        });
      return ((null == i ? void 0 : i.htmlAttributes) || []).forEach(function (i) {
        t.hasAttribute(i) && (e[i] = t.getAttribute(i));
      }), e;
    }
  }, {
    key: "findBlockElementAncestors",
    value: function findBlockElementAncestors(t) {
      var e = [];
      for (; t && t !== this.containerElement;) {
        var _i28 = k(t);
        L().includes(_i28) && e.push(t), t = t.parentNode;
      }
      return e;
    }
  }, {
    key: "isBlockElement",
    value: function isBlockElement(t) {
      if ((null == t ? void 0 : t.nodeType) === Node.ELEMENT_NODE && !P(t) && !y(t, {
        matchingSelector: "td",
        untilNode: this.containerElement
      })) return L().includes(k(t)) || "block" === window.getComputedStyle(t).display;
    }
  }, {
    key: "isInsignificantTextNode",
    value: function isInsignificantTextNode(t) {
      if ((null == t ? void 0 : t.nodeType) !== Node.TEXT_NODE) return;
      if (!bn(t.data)) return;
      var e = t.parentNode,
        i = t.previousSibling,
        n = t.nextSibling;
      return gn(e.previousSibling) && !this.isBlockElement(e.previousSibling) || dn(e) ? void 0 : !i || this.isBlockElement(i) || !n || this.isBlockElement(n);
    }
  }, {
    key: "isExtraBR",
    value: function isExtraBR(t) {
      return "br" === k(t) && this.isBlockElement(t.parentNode) && t.parentNode.lastChild === t;
    }
  }, {
    key: "needsTableSeparator",
    value: function needsTableSeparator(t) {
      if (j.removeBlankTableCells) {
        var e;
        var _i29 = null === (e = t.previousSibling) || void 0 === e ? void 0 : e.textContent;
        return _i29 && /\S/.test(_i29);
      }
      return t.previousSibling;
    }
  }, {
    key: "translateBlockElementMarginsToNewlines",
    value: function translateBlockElementMarginsToNewlines() {
      var t = this.getMarginOfDefaultBlockElement();
      for (var _e36 = 0; _e36 < this.blocks.length; _e36++) {
        var _i30 = this.getMarginOfBlockElementAtIndex(_e36);
        _i30 && (_i30.top > 2 * t.top && this.prependStringToTextAtIndex("\n", _e36), _i30.bottom > 2 * t.bottom && this.appendStringToTextAtIndex("\n", _e36));
      }
    }
  }, {
    key: "getMarginOfBlockElementAtIndex",
    value: function getMarginOfBlockElementAtIndex(t) {
      var e = this.blockElements[t];
      if (e && e.textContent && !L().includes(k(e)) && !this.processedElements.includes(e)) return mn(e);
    }
  }, {
    key: "getMarginOfDefaultBlockElement",
    value: function getMarginOfDefaultBlockElement() {
      var t = T(n["default"].tagName);
      return this.containerElement.appendChild(t), mn(t);
    }
  }], [{
    key: "parse",
    value: function parse(t, e) {
      var i = new this(t, e);
      return i.parse(), i;
    }
  }]);
}(q);
var dn = function dn(t) {
    var _window$getComputedSt = window.getComputedStyle(t),
      e = _window$getComputedSt.whiteSpace;
    return ["pre", "pre-wrap", "pre-line"].includes(e);
  },
  gn = function gn(t) {
    return t && !vn(t.textContent);
  },
  mn = function mn(t) {
    var e = window.getComputedStyle(t);
    if ("block" === e.display) return {
      top: parseInt(e.marginTop),
      bottom: parseInt(e.marginBottom)
    };
  },
  pn = function pn(t) {
    return "style" === k(t) ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT;
  },
  fn = function fn(t) {
    return t.replace(new RegExp("^".concat(Ut.source, "+")), "");
  },
  bn = function bn(t) {
    return new RegExp("^".concat(Ut.source, "*$")).test(t);
  },
  vn = function vn(t) {
    return /\s$/.test(t);
  },
  An = ["contenteditable", "data-trix-id", "data-trix-store-key", "data-trix-mutable", "data-trix-placeholder", "tabindex"],
  yn = "data-trix-serialized-attributes",
  xn = "[".concat(yn, "]"),
  Cn = new RegExp("\x3c!--block--\x3e", "g"),
  En = {
    "application/json": function application_json(t) {
      var e;
      if (t instanceof an) e = t;else {
        if (!(t instanceof HTMLElement)) throw new Error("unserializable object");
        e = hn.parse(t.innerHTML).getDocument();
      }
      return e.toSerializableDocument().toJSONString();
    },
    "text/html": function text_html(t) {
      var e;
      if (t instanceof an) e = Si.render(t);else {
        if (!(t instanceof HTMLElement)) throw new Error("unserializable object");
        e = t.cloneNode(!0);
      }
      return Array.from(e.querySelectorAll("[data-trix-serialize=false]")).forEach(function (t) {
        S(t);
      }), An.forEach(function (t) {
        Array.from(e.querySelectorAll("[".concat(t, "]"))).forEach(function (e) {
          e.removeAttribute(t);
        });
      }), Array.from(e.querySelectorAll(xn)).forEach(function (t) {
        try {
          var _e37 = JSON.parse(t.getAttribute(yn));
          t.removeAttribute(yn);
          for (var _i31 in _e37) {
            var _n23 = _e37[_i31];
            t.setAttribute(_i31, _n23);
          }
        } catch (t) {}
      }), e.innerHTML.replace(Cn, "");
    }
  };
var Sn = Object.freeze({
  __proto__: null
});
var Rn = /*#__PURE__*/function (_q9) {
  function Rn(t, e) {
    var _this37;
    _classCallCheck(this, Rn);
    _this37 = _callSuper(this, Rn, arguments), _this37.attachmentManager = t, _this37.attachment = e, _this37.id = _this37.attachment.id, _this37.file = _this37.attachment.file;
    return _this37;
  }
  _inherits(Rn, _q9);
  return _createClass(Rn, [{
    key: "remove",
    value: function remove() {
      return this.attachmentManager.requestRemovalOfAttachment(this.attachment);
    }
  }]);
}(q);
Rn.proxyMethod("attachment.getAttribute"), Rn.proxyMethod("attachment.hasAttribute"), Rn.proxyMethod("attachment.setAttribute"), Rn.proxyMethod("attachment.getAttributes"), Rn.proxyMethod("attachment.setAttributes"), Rn.proxyMethod("attachment.isPending"), Rn.proxyMethod("attachment.isPreviewable"), Rn.proxyMethod("attachment.getURL"), Rn.proxyMethod("attachment.getHref"), Rn.proxyMethod("attachment.getFilename"), Rn.proxyMethod("attachment.getFilesize"), Rn.proxyMethod("attachment.getFormattedFilesize"), Rn.proxyMethod("attachment.getExtension"), Rn.proxyMethod("attachment.getContentType"), Rn.proxyMethod("attachment.getFile"), Rn.proxyMethod("attachment.setFile"), Rn.proxyMethod("attachment.releaseFile"), Rn.proxyMethod("attachment.getUploadProgress"), Rn.proxyMethod("attachment.setUploadProgress");
var kn = /*#__PURE__*/function (_q0) {
  function kn() {
    var _this38;
    _classCallCheck(this, kn);
    var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
    _this38 = _callSuper(this, kn, arguments), _this38.managedAttachments = {}, Array.from(t).forEach(function (t) {
      _this38.manageAttachment(t);
    });
    return _this38;
  }
  _inherits(kn, _q0);
  return _createClass(kn, [{
    key: "getAttachments",
    value: function getAttachments() {
      var t = [];
      for (var _e38 in this.managedAttachments) {
        var _i32 = this.managedAttachments[_e38];
        t.push(_i32);
      }
      return t;
    }
  }, {
    key: "manageAttachment",
    value: function manageAttachment(t) {
      return this.managedAttachments[t.id] || (this.managedAttachments[t.id] = new Rn(this, t)), this.managedAttachments[t.id];
    }
  }, {
    key: "attachmentIsManaged",
    value: function attachmentIsManaged(t) {
      return t.id in this.managedAttachments;
    }
  }, {
    key: "requestRemovalOfAttachment",
    value: function requestRemovalOfAttachment(t) {
      var e, i;
      if (this.attachmentIsManaged(t)) return null === (e = this.delegate) || void 0 === e || null === (i = e.attachmentManagerDidRequestRemovalOfAttachment) || void 0 === i ? void 0 : i.call(e, t);
    }
  }, {
    key: "unmanageAttachment",
    value: function unmanageAttachment(t) {
      var e = this.managedAttachments[t.id];
      return delete this.managedAttachments[t.id], e;
    }
  }]);
}(q);
var Tn = /*#__PURE__*/function () {
  function Tn(t) {
    _classCallCheck(this, Tn);
    this.composition = t, this.document = this.composition.document;
    var e = this.composition.getSelectedRange();
    this.startPosition = e[0], this.endPosition = e[1], this.startLocation = this.document.locationFromPosition(this.startPosition), this.endLocation = this.document.locationFromPosition(this.endPosition), this.block = this.document.getBlockAtIndex(this.endLocation.index), this.breaksOnReturn = this.block.breaksOnReturn(), this.previousCharacter = this.block.text.getStringAtPosition(this.endLocation.offset - 1), this.nextCharacter = this.block.text.getStringAtPosition(this.endLocation.offset);
  }
  return _createClass(Tn, [{
    key: "shouldInsertBlockBreak",
    value: function shouldInsertBlockBreak() {
      return this.block.hasAttributes() && this.block.isListItem() && !this.block.isEmpty() ? 0 !== this.startLocation.offset : this.breaksOnReturn && "\n" !== this.nextCharacter;
    }
  }, {
    key: "shouldBreakFormattedBlock",
    value: function shouldBreakFormattedBlock() {
      return this.block.hasAttributes() && !this.block.isListItem() && (this.breaksOnReturn && "\n" === this.nextCharacter || "\n" === this.previousCharacter);
    }
  }, {
    key: "shouldDecreaseListLevel",
    value: function shouldDecreaseListLevel() {
      return this.block.hasAttributes() && this.block.isListItem() && this.block.isEmpty();
    }
  }, {
    key: "shouldPrependListItem",
    value: function shouldPrependListItem() {
      return this.block.isListItem() && 0 === this.startLocation.offset && !this.block.isEmpty();
    }
  }, {
    key: "shouldRemoveLastBlockAttribute",
    value: function shouldRemoveLastBlockAttribute() {
      return this.block.hasAttributes() && !this.block.isListItem() && this.block.isEmpty();
    }
  }]);
}();
var wn = /*#__PURE__*/function (_q1) {
  function wn() {
    var _this39;
    _classCallCheck(this, wn);
    _this39 = _callSuper(this, wn, arguments), _this39.document = new an(), _this39.attachments = [], _this39.currentAttributes = {}, _this39.revision = 0;
    return _this39;
  }
  _inherits(wn, _q1);
  return _createClass(wn, [{
    key: "setDocument",
    value: function setDocument(t) {
      var e, i;
      if (!t.isEqualTo(this.document)) return this.document = t, this.refreshAttachments(), this.revision++, null === (e = this.delegate) || void 0 === e || null === (i = e.compositionDidChangeDocument) || void 0 === i ? void 0 : i.call(e, t);
    }
  }, {
    key: "getSnapshot",
    value: function getSnapshot() {
      return {
        document: this.document,
        selectedRange: this.getSelectedRange()
      };
    }
  }, {
    key: "loadSnapshot",
    value: function loadSnapshot(t) {
      var e, i, n, r;
      var o = t.document,
        s = t.selectedRange;
      return null === (e = this.delegate) || void 0 === e || null === (i = e.compositionWillLoadSnapshot) || void 0 === i || i.call(e), this.setDocument(null != o ? o : new an()), this.setSelection(null != s ? s : [0, 0]), null === (n = this.delegate) || void 0 === n || null === (r = n.compositionDidLoadSnapshot) || void 0 === r ? void 0 : r.call(n);
    }
  }, {
    key: "insertText",
    value: function insertText(t) {
      var _ref13 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {
          updatePosition: !0
        },
        e = _ref13.updatePosition;
      var i = this.getSelectedRange();
      this.setDocument(this.document.insertTextAtRange(t, i));
      var n = i[0],
        r = n + t.getLength();
      return e && this.setSelection(r), this.notifyDelegateOfInsertionAtRange([n, r]);
    }
  }, {
    key: "insertBlock",
    value: function insertBlock() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : new $i();
      var e = new an([t]);
      return this.insertDocument(e);
    }
  }, {
    key: "insertDocument",
    value: function insertDocument() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : new an();
      var e = this.getSelectedRange();
      this.setDocument(this.document.insertDocumentAtRange(t, e));
      var i = e[0],
        n = i + t.getLength();
      return this.setSelection(n), this.notifyDelegateOfInsertionAtRange([i, n]);
    }
  }, {
    key: "insertString",
    value: function insertString(t, e) {
      var i = this.getCurrentTextAttributes(),
        n = Yi.textForStringWithAttributes(t, i);
      return this.insertText(n, e);
    }
  }, {
    key: "insertBlockBreak",
    value: function insertBlockBreak() {
      var t = this.getSelectedRange();
      this.setDocument(this.document.insertBlockBreakAtRange(t));
      var e = t[0],
        i = e + 1;
      return this.setSelection(i), this.notifyDelegateOfInsertionAtRange([e, i]);
    }
  }, {
    key: "insertLineBreak",
    value: function insertLineBreak() {
      var t = new Tn(this);
      if (t.shouldDecreaseListLevel()) return this.decreaseListLevel(), this.setSelection(t.startPosition);
      if (t.shouldPrependListItem()) {
        var _e39 = new an([t.block.copyWithoutText()]);
        return this.insertDocument(_e39);
      }
      return t.shouldInsertBlockBreak() ? this.insertBlockBreak() : t.shouldRemoveLastBlockAttribute() ? this.removeLastBlockAttribute() : t.shouldBreakFormattedBlock() ? this.breakFormattedBlock(t) : this.insertString("\n");
    }
  }, {
    key: "insertHTML",
    value: function insertHTML(t) {
      var e = hn.parse(t).getDocument(),
        i = this.getSelectedRange();
      this.setDocument(this.document.mergeDocumentAtRange(e, i));
      var n = i[0],
        r = n + e.getLength() - 1;
      return this.setSelection(r), this.notifyDelegateOfInsertionAtRange([n, r]);
    }
  }, {
    key: "replaceHTML",
    value: function replaceHTML(t) {
      var e = hn.parse(t).getDocument().copyUsingObjectsFromDocument(this.document),
        i = this.getLocationRange({
          strict: !1
        }),
        n = this.document.rangeFromLocationRange(i);
      return this.setDocument(e), this.setSelection(n);
    }
  }, {
    key: "insertFile",
    value: function insertFile(t) {
      return this.insertFiles([t]);
    }
  }, {
    key: "insertFiles",
    value: function insertFiles(t) {
      var _this40 = this;
      var e = [];
      return Array.from(t).forEach(function (t) {
        var i;
        if (null !== (i = _this40.delegate) && void 0 !== i && i.compositionShouldAcceptFile(t)) {
          var _i33 = Vi.attachmentForFile(t);
          e.push(_i33);
        }
      }), this.insertAttachments(e);
    }
  }, {
    key: "insertAttachment",
    value: function insertAttachment(t) {
      return this.insertAttachments([t]);
    }
  }, {
    key: "insertAttachments",
    value: function insertAttachments(t) {
      var _this41 = this;
      var e = new Yi();
      return Array.from(t).forEach(function (t) {
        var n;
        var r = t.getType(),
          o = null === (n = i[r]) || void 0 === n ? void 0 : n.presentation,
          s = _this41.getCurrentTextAttributes();
        o && (s.presentation = o);
        var a = Yi.textForAttachmentWithAttributes(t, s);
        e = e.appendText(a);
      }), this.insertText(e);
    }
  }, {
    key: "shouldManageDeletingInDirection",
    value: function shouldManageDeletingInDirection(t) {
      var e = this.getLocationRange();
      if (Lt(e)) {
        if ("backward" === t && 0 === e[0].offset) return !0;
        if (this.shouldManageMovingCursorInDirection(t)) return !0;
      } else if (e[0].index !== e[1].index) return !0;
      return !1;
    }
  }, {
    key: "deleteInDirection",
    value: function deleteInDirection(t) {
      var e,
        i,
        n,
        _ref14 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
        r = _ref14.length;
      var o = this.getLocationRange();
      var s = this.getSelectedRange();
      var a = Lt(s);
      if (a ? i = "backward" === t && 0 === o[0].offset : n = o[0].index !== o[1].index, i && this.canDecreaseBlockAttributeLevel()) {
        var _t38 = this.getBlock();
        if (_t38.isListItem() ? this.decreaseListLevel() : this.decreaseBlockAttributeLevel(), this.setSelection(s[0]), _t38.isEmpty()) return !1;
      }
      return a && (s = this.getExpandedRangeInDirection(t, {
        length: r
      }), "backward" === t && (e = this.getAttachmentAtRange(s))), e ? (this.editAttachment(e), !1) : (this.setDocument(this.document.removeTextAtRange(s)), this.setSelection(s[0]), !i && !n && void 0);
    }
  }, {
    key: "moveTextFromRange",
    value: function moveTextFromRange(t) {
      var _Array$from9 = Array.from(this.getSelectedRange()),
        _Array$from0 = _slicedToArray(_Array$from9, 1),
        e = _Array$from0[0];
      return this.setDocument(this.document.moveTextFromRangeToPosition(t, e)), this.setSelection(e);
    }
  }, {
    key: "removeAttachment",
    value: function removeAttachment(t) {
      var e = this.document.getRangeOfAttachment(t);
      if (e) return this.stopEditingAttachment(), this.setDocument(this.document.removeTextAtRange(e)), this.setSelection(e[0]);
    }
  }, {
    key: "removeLastBlockAttribute",
    value: function removeLastBlockAttribute() {
      var _Array$from1 = Array.from(this.getSelectedRange()),
        _Array$from10 = _slicedToArray(_Array$from1, 2),
        t = _Array$from10[0],
        e = _Array$from10[1],
        i = this.document.getBlockAtPosition(e);
      return this.removeCurrentAttribute(i.getLastAttribute()), this.setSelection(t);
    }
  }, {
    key: "insertPlaceholder",
    value: function insertPlaceholder() {
      return this.placeholderPosition = this.getPosition(), this.insertString(" ");
    }
  }, {
    key: "selectPlaceholder",
    value: function selectPlaceholder() {
      if (null != this.placeholderPosition) return this.setSelectedRange([this.placeholderPosition, this.placeholderPosition + 1]), this.getSelectedRange();
    }
  }, {
    key: "forgetPlaceholder",
    value: function forgetPlaceholder() {
      this.placeholderPosition = null;
    }
  }, {
    key: "hasCurrentAttribute",
    value: function hasCurrentAttribute(t) {
      var e = this.currentAttributes[t];
      return null != e && !1 !== e;
    }
  }, {
    key: "toggleCurrentAttribute",
    value: function toggleCurrentAttribute(t) {
      var e = !this.currentAttributes[t];
      return e ? this.setCurrentAttribute(t, e) : this.removeCurrentAttribute(t);
    }
  }, {
    key: "canSetCurrentAttribute",
    value: function canSetCurrentAttribute(t) {
      return mt(t) ? this.canSetCurrentBlockAttribute(t) : this.canSetCurrentTextAttribute(t);
    }
  }, {
    key: "canSetCurrentTextAttribute",
    value: function canSetCurrentTextAttribute(t) {
      var e = this.getSelectedDocument();
      if (e) {
        for (var _i34 = 0, _Array$from11 = Array.from(e.getAttachments()); _i34 < _Array$from11.length; _i34++) {
          var _t39 = _Array$from11[_i34];
          if (!_t39.hasContent()) return !1;
        }
        return !0;
      }
    }
  }, {
    key: "canSetCurrentBlockAttribute",
    value: function canSetCurrentBlockAttribute(t) {
      var e = this.getBlock();
      if (e) return !e.isTerminalBlock();
    }
  }, {
    key: "setCurrentAttribute",
    value: function setCurrentAttribute(t, e) {
      return mt(t) ? this.setBlockAttribute(t, e) : (this.setTextAttribute(t, e), this.currentAttributes[t] = e, this.notifyDelegateOfCurrentAttributesChange());
    }
  }, {
    key: "setHTMLAtributeAtPosition",
    value: function setHTMLAtributeAtPosition(t, e, i) {
      var n;
      var r = this.document.getBlockAtPosition(t),
        o = null === (n = mt(r.getLastAttribute())) || void 0 === n ? void 0 : n.htmlAttributes;
      if (r && null != o && o.includes(e)) {
        var _n24 = this.document.setHTMLAttributeAtPosition(t, e, i);
        this.setDocument(_n24);
      }
    }
  }, {
    key: "setTextAttribute",
    value: function setTextAttribute(t, e) {
      var i = this.getSelectedRange();
      if (!i) return;
      var _Array$from12 = Array.from(i),
        _Array$from13 = _slicedToArray(_Array$from12, 2),
        n = _Array$from13[0],
        r = _Array$from13[1];
      if (n !== r) return this.setDocument(this.document.addAttributeAtRange(t, e, i));
      if ("href" === t) {
        var _t40 = Yi.textForStringWithAttributes(e, {
          href: e
        });
        return this.insertText(_t40);
      }
    }
  }, {
    key: "setBlockAttribute",
    value: function setBlockAttribute(t, e) {
      var i = this.getSelectedRange();
      if (this.canSetCurrentAttribute(t)) return this.setDocument(this.document.applyBlockAttributeAtRange(t, e, i)), this.setSelection(i);
    }
  }, {
    key: "removeCurrentAttribute",
    value: function removeCurrentAttribute(t) {
      return mt(t) ? (this.removeBlockAttribute(t), this.updateCurrentAttributes()) : (this.removeTextAttribute(t), delete this.currentAttributes[t], this.notifyDelegateOfCurrentAttributesChange());
    }
  }, {
    key: "removeTextAttribute",
    value: function removeTextAttribute(t) {
      var e = this.getSelectedRange();
      if (e) return this.setDocument(this.document.removeAttributeAtRange(t, e));
    }
  }, {
    key: "removeBlockAttribute",
    value: function removeBlockAttribute(t) {
      var e = this.getSelectedRange();
      if (e) return this.setDocument(this.document.removeAttributeAtRange(t, e));
    }
  }, {
    key: "canDecreaseNestingLevel",
    value: function canDecreaseNestingLevel() {
      var t;
      return (null === (t = this.getBlock()) || void 0 === t ? void 0 : t.getNestingLevel()) > 0;
    }
  }, {
    key: "canIncreaseNestingLevel",
    value: function canIncreaseNestingLevel() {
      var t;
      var e = this.getBlock();
      if (e) {
        if (null === (t = mt(e.getLastNestableAttribute())) || void 0 === t || !t.listAttribute) return e.getNestingLevel() > 0;
        {
          var _t41 = this.getPreviousBlock();
          if (_t41) return function () {
            var t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : [];
            return ot((arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : []).slice(0, t.length), t);
          }(_t41.getListItemAttributes(), e.getListItemAttributes());
        }
      }
    }
  }, {
    key: "decreaseNestingLevel",
    value: function decreaseNestingLevel() {
      var t = this.getBlock();
      if (t) return this.setDocument(this.document.replaceBlock(t, t.decreaseNestingLevel()));
    }
  }, {
    key: "increaseNestingLevel",
    value: function increaseNestingLevel() {
      var t = this.getBlock();
      if (t) return this.setDocument(this.document.replaceBlock(t, t.increaseNestingLevel()));
    }
  }, {
    key: "canDecreaseBlockAttributeLevel",
    value: function canDecreaseBlockAttributeLevel() {
      var t;
      return (null === (t = this.getBlock()) || void 0 === t ? void 0 : t.getAttributeLevel()) > 0;
    }
  }, {
    key: "decreaseBlockAttributeLevel",
    value: function decreaseBlockAttributeLevel() {
      var t;
      var e = null === (t = this.getBlock()) || void 0 === t ? void 0 : t.getLastAttribute();
      if (e) return this.removeCurrentAttribute(e);
    }
  }, {
    key: "decreaseListLevel",
    value: function decreaseListLevel() {
      var _Array$from14 = Array.from(this.getSelectedRange()),
        _Array$from15 = _slicedToArray(_Array$from14, 1),
        t = _Array$from15[0];
      var _this$document$locati = this.document.locationFromPosition(t),
        e = _this$document$locati.index;
      var i = e;
      var n = this.getBlock().getAttributeLevel();
      var r = this.document.getBlockAtIndex(i + 1);
      for (; r && r.isListItem() && !(r.getAttributeLevel() <= n);) i++, r = this.document.getBlockAtIndex(i + 1);
      t = this.document.positionFromLocation({
        index: e,
        offset: 0
      });
      var o = this.document.positionFromLocation({
        index: i,
        offset: 0
      });
      return this.setDocument(this.document.removeLastListAttributeAtRange([t, o]));
    }
  }, {
    key: "updateCurrentAttributes",
    value: function updateCurrentAttributes() {
      var _this42 = this;
      var t = this.getSelectedRange({
        ignoreLock: !0
      });
      if (t) {
        var _e40 = this.document.getCommonAttributesAtRange(t);
        if (Array.from(gt()).forEach(function (t) {
          _e40[t] || _this42.canSetCurrentAttribute(t) || (_e40[t] = !1);
        }), !Tt(_e40, this.currentAttributes)) return this.currentAttributes = _e40, this.notifyDelegateOfCurrentAttributesChange();
      }
    }
  }, {
    key: "getCurrentAttributes",
    value: function getCurrentAttributes() {
      return m.call({}, this.currentAttributes);
    }
  }, {
    key: "getCurrentTextAttributes",
    value: function getCurrentTextAttributes() {
      var t = {};
      for (var _e41 in this.currentAttributes) {
        var _i35 = this.currentAttributes[_e41];
        !1 !== _i35 && ft(_e41) && (t[_e41] = _i35);
      }
      return t;
    }
  }, {
    key: "freezeSelection",
    value: function freezeSelection() {
      return this.setCurrentAttribute("frozen", !0);
    }
  }, {
    key: "thawSelection",
    value: function thawSelection() {
      return this.removeCurrentAttribute("frozen");
    }
  }, {
    key: "hasFrozenSelection",
    value: function hasFrozenSelection() {
      return this.hasCurrentAttribute("frozen");
    }
  }, {
    key: "setSelection",
    value: function setSelection(t) {
      var e;
      var i = this.document.locationRangeFromRange(t);
      return null === (e = this.delegate) || void 0 === e ? void 0 : e.compositionDidRequestChangingSelectionToLocationRange(i);
    }
  }, {
    key: "getSelectedRange",
    value: function getSelectedRange() {
      var t = this.getLocationRange();
      if (t) return this.document.rangeFromLocationRange(t);
    }
  }, {
    key: "setSelectedRange",
    value: function setSelectedRange(t) {
      var e = this.document.locationRangeFromRange(t);
      return this.getSelectionManager().setLocationRange(e);
    }
  }, {
    key: "getPosition",
    value: function getPosition() {
      var t = this.getLocationRange();
      if (t) return this.document.positionFromLocation(t[0]);
    }
  }, {
    key: "getLocationRange",
    value: function getLocationRange(t) {
      return this.targetLocationRange ? this.targetLocationRange : this.getSelectionManager().getLocationRange(t) || wt({
        index: 0,
        offset: 0
      });
    }
  }, {
    key: "withTargetLocationRange",
    value: function withTargetLocationRange(t, e) {
      var i;
      this.targetLocationRange = t;
      try {
        i = e();
      } finally {
        this.targetLocationRange = null;
      }
      return i;
    }
  }, {
    key: "withTargetRange",
    value: function withTargetRange(t, e) {
      var i = this.document.locationRangeFromRange(t);
      return this.withTargetLocationRange(i, e);
    }
  }, {
    key: "withTargetDOMRange",
    value: function withTargetDOMRange(t, e) {
      var i = this.createLocationRangeFromDOMRange(t, {
        strict: !1
      });
      return this.withTargetLocationRange(i, e);
    }
  }, {
    key: "getExpandedRangeInDirection",
    value: function getExpandedRangeInDirection(t) {
      var _ref15 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
        e = _ref15.length,
        _Array$from16 = Array.from(this.getSelectedRange()),
        _Array$from17 = _slicedToArray(_Array$from16, 2),
        i = _Array$from17[0],
        n = _Array$from17[1];
      return "backward" === t ? e ? i -= e : i = this.translateUTF16PositionFromOffset(i, -1) : e ? n += e : n = this.translateUTF16PositionFromOffset(n, 1), wt([i, n]);
    }
  }, {
    key: "shouldManageMovingCursorInDirection",
    value: function shouldManageMovingCursorInDirection(t) {
      if (this.editingAttachment) return !0;
      var e = this.getExpandedRangeInDirection(t);
      return null != this.getAttachmentAtRange(e);
    }
  }, {
    key: "moveCursorInDirection",
    value: function moveCursorInDirection(t) {
      var e, i;
      if (this.editingAttachment) i = this.document.getRangeOfAttachment(this.editingAttachment);else {
        var _n25 = this.getSelectedRange();
        i = this.getExpandedRangeInDirection(t), e = !Dt(_n25, i);
      }
      if ("backward" === t ? this.setSelectedRange(i[0]) : this.setSelectedRange(i[1]), e) {
        var _t42 = this.getAttachmentAtRange(i);
        if (_t42) return this.editAttachment(_t42);
      }
    }
  }, {
    key: "expandSelectionInDirection",
    value: function expandSelectionInDirection(t) {
      var _ref16 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
        e = _ref16.length;
      var i = this.getExpandedRangeInDirection(t, {
        length: e
      });
      return this.setSelectedRange(i);
    }
  }, {
    key: "expandSelectionForEditing",
    value: function expandSelectionForEditing() {
      if (this.hasCurrentAttribute("href")) return this.expandSelectionAroundCommonAttribute("href");
    }
  }, {
    key: "expandSelectionAroundCommonAttribute",
    value: function expandSelectionAroundCommonAttribute(t) {
      var e = this.getPosition(),
        i = this.document.getRangeOfCommonAttributeAtPosition(t, e);
      return this.setSelectedRange(i);
    }
  }, {
    key: "selectionContainsAttachments",
    value: function selectionContainsAttachments() {
      var t;
      return (null === (t = this.getSelectedAttachments()) || void 0 === t ? void 0 : t.length) > 0;
    }
  }, {
    key: "selectionIsInCursorTarget",
    value: function selectionIsInCursorTarget() {
      return this.editingAttachment || this.positionIsCursorTarget(this.getPosition());
    }
  }, {
    key: "positionIsCursorTarget",
    value: function positionIsCursorTarget(t) {
      var e = this.document.locationFromPosition(t);
      if (e) return this.locationIsCursorTarget(e);
    }
  }, {
    key: "positionIsBlockBreak",
    value: function positionIsBlockBreak(t) {
      var e;
      return null === (e = this.document.getPieceAtPosition(t)) || void 0 === e ? void 0 : e.isBlockBreak();
    }
  }, {
    key: "getSelectedDocument",
    value: function getSelectedDocument() {
      var t = this.getSelectedRange();
      if (t) return this.document.getDocumentAtRange(t);
    }
  }, {
    key: "getSelectedAttachments",
    value: function getSelectedAttachments() {
      var t;
      return null === (t = this.getSelectedDocument()) || void 0 === t ? void 0 : t.getAttachments();
    }
  }, {
    key: "getAttachments",
    value: function getAttachments() {
      return this.attachments.slice(0);
    }
  }, {
    key: "refreshAttachments",
    value: function refreshAttachments() {
      var _this43 = this;
      var t = this.document.getAttachments(),
        _ref17 = function () {
          var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [],
            e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : [];
          var i = [],
            n = [],
            r = new Set();
          t.forEach(function (t) {
            r.add(t);
          });
          var o = new Set();
          return e.forEach(function (t) {
            o.add(t), r.has(t) || i.push(t);
          }), t.forEach(function (t) {
            o.has(t) || n.push(t);
          }), {
            added: i,
            removed: n
          };
        }(this.attachments, t),
        e = _ref17.added,
        i = _ref17.removed;
      return this.attachments = t, Array.from(i).forEach(function (t) {
        var e, i;
        t.delegate = null, null === (e = _this43.delegate) || void 0 === e || null === (i = e.compositionDidRemoveAttachment) || void 0 === i || i.call(e, t);
      }), function () {
        var t = [];
        return Array.from(e).forEach(function (e) {
          var i, n;
          e.delegate = _this43, t.push(null === (i = _this43.delegate) || void 0 === i || null === (n = i.compositionDidAddAttachment) || void 0 === n ? void 0 : n.call(i, e));
        }), t;
      }();
    }
  }, {
    key: "attachmentDidChangeAttributes",
    value: function attachmentDidChangeAttributes(t) {
      var e, i;
      return this.revision++, null === (e = this.delegate) || void 0 === e || null === (i = e.compositionDidEditAttachment) || void 0 === i ? void 0 : i.call(e, t);
    }
  }, {
    key: "attachmentDidChangePreviewURL",
    value: function attachmentDidChangePreviewURL(t) {
      var e, i;
      return this.revision++, null === (e = this.delegate) || void 0 === e || null === (i = e.compositionDidChangeAttachmentPreviewURL) || void 0 === i ? void 0 : i.call(e, t);
    }
  }, {
    key: "editAttachment",
    value: function editAttachment(t, e) {
      var i, n;
      if (t !== this.editingAttachment) return this.stopEditingAttachment(), this.editingAttachment = t, null === (i = this.delegate) || void 0 === i || null === (n = i.compositionDidStartEditingAttachment) || void 0 === n ? void 0 : n.call(i, this.editingAttachment, e);
    }
  }, {
    key: "stopEditingAttachment",
    value: function stopEditingAttachment() {
      var t, e;
      this.editingAttachment && (null === (t = this.delegate) || void 0 === t || null === (e = t.compositionDidStopEditingAttachment) || void 0 === e || e.call(t, this.editingAttachment), this.editingAttachment = null);
    }
  }, {
    key: "updateAttributesForAttachment",
    value: function updateAttributesForAttachment(t, e) {
      return this.setDocument(this.document.updateAttributesForAttachment(t, e));
    }
  }, {
    key: "removeAttributeForAttachment",
    value: function removeAttributeForAttachment(t, e) {
      return this.setDocument(this.document.removeAttributeForAttachment(t, e));
    }
  }, {
    key: "breakFormattedBlock",
    value: function breakFormattedBlock(t) {
      var e = t.document;
      var i = t.block;
      var n = t.startPosition,
        r = [n - 1, n];
      i.getBlockBreakPosition() === t.startLocation.offset ? (i.breaksOnReturn() && "\n" === t.nextCharacter ? n += 1 : e = e.removeTextAtRange(r), r = [n, n]) : "\n" === t.nextCharacter ? "\n" === t.previousCharacter ? r = [n - 1, n + 1] : (r = [n, n + 1], n += 1) : t.startLocation.offset - 1 != 0 && (n += 1);
      var o = new an([i.removeLastAttribute().copyWithoutText()]);
      return this.setDocument(e.insertDocumentAtRange(o, r)), this.setSelection(n);
    }
  }, {
    key: "getPreviousBlock",
    value: function getPreviousBlock() {
      var t = this.getLocationRange();
      if (t) {
        var _e42 = t[0].index;
        if (_e42 > 0) return this.document.getBlockAtIndex(_e42 - 1);
      }
    }
  }, {
    key: "getBlock",
    value: function getBlock() {
      var t = this.getLocationRange();
      if (t) return this.document.getBlockAtIndex(t[0].index);
    }
  }, {
    key: "getAttachmentAtRange",
    value: function getAttachmentAtRange(t) {
      var e = this.document.getDocumentAtRange(t);
      if (e.toString() === "".concat("￼", "\n")) return e.getAttachments()[0];
    }
  }, {
    key: "notifyDelegateOfCurrentAttributesChange",
    value: function notifyDelegateOfCurrentAttributesChange() {
      var t, e;
      return null === (t = this.delegate) || void 0 === t || null === (e = t.compositionDidChangeCurrentAttributes) || void 0 === e ? void 0 : e.call(t, this.currentAttributes);
    }
  }, {
    key: "notifyDelegateOfInsertionAtRange",
    value: function notifyDelegateOfInsertionAtRange(t) {
      var e, i;
      return null === (e = this.delegate) || void 0 === e || null === (i = e.compositionDidPerformInsertionAtRange) || void 0 === i ? void 0 : i.call(e, t);
    }
  }, {
    key: "translateUTF16PositionFromOffset",
    value: function translateUTF16PositionFromOffset(t, e) {
      var i = this.document.toUTF16String(),
        n = i.offsetFromUCS2Offset(t);
      return i.offsetToUCS2Offset(n + e);
    }
  }]);
}(q);
wn.proxyMethod("getSelectionManager().getPointRange"), wn.proxyMethod("getSelectionManager().setLocationRangeFromPointRange"), wn.proxyMethod("getSelectionManager().createLocationRangeFromDOMRange"), wn.proxyMethod("getSelectionManager().locationIsCursorTarget"), wn.proxyMethod("getSelectionManager().selectionIsExpanded"), wn.proxyMethod("delegate?.getSelectionManager");
var Ln = /*#__PURE__*/function (_q10) {
  function Ln(t) {
    var _this44;
    _classCallCheck(this, Ln);
    _this44 = _callSuper(this, Ln, arguments), _this44.composition = t, _this44.undoEntries = [], _this44.redoEntries = [];
    return _this44;
  }
  _inherits(Ln, _q10);
  return _createClass(Ln, [{
    key: "recordUndoEntry",
    value: function recordUndoEntry(t) {
      var _ref18 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
        e = _ref18.context,
        i = _ref18.consolidatable;
      var n = this.undoEntries.slice(-1)[0];
      if (!i || !Dn(n, t, e)) {
        var _i36 = this.createEntry({
          description: t,
          context: e
        });
        this.undoEntries.push(_i36), this.redoEntries = [];
      }
    }
  }, {
    key: "undo",
    value: function undo() {
      var t = this.undoEntries.pop();
      if (t) {
        var _e43 = this.createEntry(t);
        return this.redoEntries.push(_e43), this.composition.loadSnapshot(t.snapshot);
      }
    }
  }, {
    key: "redo",
    value: function redo() {
      var t = this.redoEntries.pop();
      if (t) {
        var _e44 = this.createEntry(t);
        return this.undoEntries.push(_e44), this.composition.loadSnapshot(t.snapshot);
      }
    }
  }, {
    key: "canUndo",
    value: function canUndo() {
      return this.undoEntries.length > 0;
    }
  }, {
    key: "canRedo",
    value: function canRedo() {
      return this.redoEntries.length > 0;
    }
  }, {
    key: "createEntry",
    value: function createEntry() {
      var _ref19 = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {},
        t = _ref19.description,
        e = _ref19.context;
      return {
        description: null == t ? void 0 : t.toString(),
        context: JSON.stringify(e),
        snapshot: this.composition.getSnapshot()
      };
    }
  }]);
}(q);
var Dn = function Dn(t, e, i) {
    return (null == t ? void 0 : t.description) === (null == e ? void 0 : e.toString()) && (null == t ? void 0 : t.context) === JSON.stringify(i);
  },
  Nn = "attachmentGallery";
var In = /*#__PURE__*/function () {
  function In(t) {
    _classCallCheck(this, In);
    this.document = t.document, this.selectedRange = t.selectedRange;
  }
  return _createClass(In, [{
    key: "perform",
    value: function perform() {
      return this.removeBlockAttribute(), this.applyBlockAttribute();
    }
  }, {
    key: "getSnapshot",
    value: function getSnapshot() {
      return {
        document: this.document,
        selectedRange: this.selectedRange
      };
    }
  }, {
    key: "removeBlockAttribute",
    value: function removeBlockAttribute() {
      var _this45 = this;
      return this.findRangesOfBlocks().map(function (t) {
        return _this45.document = _this45.document.removeAttributeAtRange(Nn, t);
      });
    }
  }, {
    key: "applyBlockAttribute",
    value: function applyBlockAttribute() {
      var _this46 = this;
      var t = 0;
      this.findRangesOfPieces().forEach(function (e) {
        e[1] - e[0] > 1 && (e[0] += t, e[1] += t, "\n" !== _this46.document.getCharacterAtPosition(e[1]) && (_this46.document = _this46.document.insertBlockBreakAtRange(e[1]), e[1] < _this46.selectedRange[1] && _this46.moveSelectedRangeForward(), e[1]++, t++), 0 !== e[0] && "\n" !== _this46.document.getCharacterAtPosition(e[0] - 1) && (_this46.document = _this46.document.insertBlockBreakAtRange(e[0]), e[0] < _this46.selectedRange[0] && _this46.moveSelectedRangeForward(), e[0]++, t++), _this46.document = _this46.document.applyBlockAttributeAtRange(Nn, !0, e));
      });
    }
  }, {
    key: "findRangesOfBlocks",
    value: function findRangesOfBlocks() {
      return this.document.findRangesForBlockAttribute(Nn);
    }
  }, {
    key: "findRangesOfPieces",
    value: function findRangesOfPieces() {
      return this.document.findRangesForTextAttribute("presentation", {
        withValue: "gallery"
      });
    }
  }, {
    key: "moveSelectedRangeForward",
    value: function moveSelectedRangeForward() {
      this.selectedRange[0] += 1, this.selectedRange[1] += 1;
    }
  }]);
}();
var On = function On(t) {
    var e = new In(t);
    return e.perform(), e.getSnapshot();
  },
  Fn = [On];
var Pn = /*#__PURE__*/function () {
  function Pn(t, e, i) {
    _classCallCheck(this, Pn);
    this.insertFiles = this.insertFiles.bind(this), this.composition = t, this.selectionManager = e, this.element = i, this.undoManager = new Ln(this.composition), this.filters = Fn.slice(0);
  }
  return _createClass(Pn, [{
    key: "loadDocument",
    value: function loadDocument(t) {
      return this.loadSnapshot({
        document: t,
        selectedRange: [0, 0]
      });
    }
  }, {
    key: "loadHTML",
    value: function loadHTML() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : "";
      var e = hn.parse(t, {
        referenceElement: this.element
      }).getDocument();
      return this.loadDocument(e);
    }
  }, {
    key: "loadJSON",
    value: function loadJSON(t) {
      var e = t.document,
        i = t.selectedRange;
      return e = an.fromJSON(e), this.loadSnapshot({
        document: e,
        selectedRange: i
      });
    }
  }, {
    key: "loadSnapshot",
    value: function loadSnapshot(t) {
      return this.undoManager = new Ln(this.composition), this.composition.loadSnapshot(t);
    }
  }, {
    key: "getDocument",
    value: function getDocument() {
      return this.composition.document;
    }
  }, {
    key: "getSelectedDocument",
    value: function getSelectedDocument() {
      return this.composition.getSelectedDocument();
    }
  }, {
    key: "getSnapshot",
    value: function getSnapshot() {
      return this.composition.getSnapshot();
    }
  }, {
    key: "toJSON",
    value: function toJSON() {
      return this.getSnapshot();
    }
  }, {
    key: "deleteInDirection",
    value: function deleteInDirection(t) {
      return this.composition.deleteInDirection(t);
    }
  }, {
    key: "insertAttachment",
    value: function insertAttachment(t) {
      return this.composition.insertAttachment(t);
    }
  }, {
    key: "insertAttachments",
    value: function insertAttachments(t) {
      return this.composition.insertAttachments(t);
    }
  }, {
    key: "insertDocument",
    value: function insertDocument(t) {
      return this.composition.insertDocument(t);
    }
  }, {
    key: "insertFile",
    value: function insertFile(t) {
      return this.composition.insertFile(t);
    }
  }, {
    key: "insertFiles",
    value: function insertFiles(t) {
      return this.composition.insertFiles(t);
    }
  }, {
    key: "insertHTML",
    value: function insertHTML(t) {
      return this.composition.insertHTML(t);
    }
  }, {
    key: "insertString",
    value: function insertString(t) {
      return this.composition.insertString(t);
    }
  }, {
    key: "insertText",
    value: function insertText(t) {
      return this.composition.insertText(t);
    }
  }, {
    key: "insertLineBreak",
    value: function insertLineBreak() {
      return this.composition.insertLineBreak();
    }
  }, {
    key: "getSelectedRange",
    value: function getSelectedRange() {
      return this.composition.getSelectedRange();
    }
  }, {
    key: "getPosition",
    value: function getPosition() {
      return this.composition.getPosition();
    }
  }, {
    key: "getClientRectAtPosition",
    value: function getClientRectAtPosition(t) {
      var e = this.getDocument().locationRangeFromRange([t, t + 1]);
      return this.selectionManager.getClientRectAtLocationRange(e);
    }
  }, {
    key: "expandSelectionInDirection",
    value: function expandSelectionInDirection(t) {
      return this.composition.expandSelectionInDirection(t);
    }
  }, {
    key: "moveCursorInDirection",
    value: function moveCursorInDirection(t) {
      return this.composition.moveCursorInDirection(t);
    }
  }, {
    key: "setSelectedRange",
    value: function setSelectedRange(t) {
      return this.composition.setSelectedRange(t);
    }
  }, {
    key: "activateAttribute",
    value: function activateAttribute(t) {
      var e = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];
      return this.composition.setCurrentAttribute(t, e);
    }
  }, {
    key: "attributeIsActive",
    value: function attributeIsActive(t) {
      return this.composition.hasCurrentAttribute(t);
    }
  }, {
    key: "canActivateAttribute",
    value: function canActivateAttribute(t) {
      return this.composition.canSetCurrentAttribute(t);
    }
  }, {
    key: "deactivateAttribute",
    value: function deactivateAttribute(t) {
      return this.composition.removeCurrentAttribute(t);
    }
  }, {
    key: "setHTMLAtributeAtPosition",
    value: function setHTMLAtributeAtPosition(t, e, i) {
      this.composition.setHTMLAtributeAtPosition(t, e, i);
    }
  }, {
    key: "canDecreaseNestingLevel",
    value: function canDecreaseNestingLevel() {
      return this.composition.canDecreaseNestingLevel();
    }
  }, {
    key: "canIncreaseNestingLevel",
    value: function canIncreaseNestingLevel() {
      return this.composition.canIncreaseNestingLevel();
    }
  }, {
    key: "decreaseNestingLevel",
    value: function decreaseNestingLevel() {
      if (this.canDecreaseNestingLevel()) return this.composition.decreaseNestingLevel();
    }
  }, {
    key: "increaseNestingLevel",
    value: function increaseNestingLevel() {
      if (this.canIncreaseNestingLevel()) return this.composition.increaseNestingLevel();
    }
  }, {
    key: "canRedo",
    value: function canRedo() {
      return this.undoManager.canRedo();
    }
  }, {
    key: "canUndo",
    value: function canUndo() {
      return this.undoManager.canUndo();
    }
  }, {
    key: "recordUndoEntry",
    value: function recordUndoEntry(t) {
      var _ref20 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {},
        e = _ref20.context,
        i = _ref20.consolidatable;
      return this.undoManager.recordUndoEntry(t, {
        context: e,
        consolidatable: i
      });
    }
  }, {
    key: "redo",
    value: function redo() {
      if (this.canRedo()) return this.undoManager.redo();
    }
  }, {
    key: "undo",
    value: function undo() {
      if (this.canUndo()) return this.undoManager.undo();
    }
  }]);
}();
var Mn = /*#__PURE__*/function () {
  function Mn(t) {
    _classCallCheck(this, Mn);
    this.element = t;
  }
  return _createClass(Mn, [{
    key: "findLocationFromContainerAndOffset",
    value: function findLocationFromContainerAndOffset(t, e) {
      var _ref21 = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : {
          strict: !0
        },
        i = _ref21.strict,
        n = 0,
        r = !1;
      var o = {
          index: 0,
          offset: 0
        },
        s = this.findAttachmentElementParentForNode(t);
      s && (t = s.parentNode, e = E(s));
      var a = R(this.element, {
        usingFilter: Wn
      });
      for (; a.nextNode();) {
        var _s4 = a.currentNode;
        if (_s4 === t && B(t)) {
          _F(_s4) || (o.offset += e);
          break;
        }
        if (_s4.parentNode === t) {
          if (n++ === e) break;
        } else if (!C(t, _s4) && n > 0) break;
        N(_s4, {
          strict: i
        }) ? (r && o.index++, o.offset = 0, r = !0) : o.offset += Bn(_s4);
      }
      return o;
    }
  }, {
    key: "findContainerAndOffsetFromLocation",
    value: function findContainerAndOffsetFromLocation(t) {
      var e, i;
      if (0 === t.index && 0 === t.offset) {
        for (e = this.element, i = 0; e.firstChild;) if (e = e.firstChild, D(e)) {
          i = 1;
          break;
        }
        return [e, i];
      }
      var _this$findNodeAndOffs = this.findNodeAndOffsetFromLocation(t),
        _this$findNodeAndOffs2 = _slicedToArray(_this$findNodeAndOffs, 2),
        n = _this$findNodeAndOffs2[0],
        r = _this$findNodeAndOffs2[1];
      if (n) {
        if (B(n)) 0 === Bn(n) ? (e = n.parentNode.parentNode, i = E(n.parentNode), _F(n, {
          name: "right"
        }) && i++) : (e = n, i = t.offset - r);else {
          if (e = n.parentNode, !N(n.previousSibling) && !D(e)) for (; n === e.lastChild && (n = e, e = e.parentNode, !D(e)););
          i = E(n), 0 !== t.offset && i++;
        }
        return [e, i];
      }
    }
  }, {
    key: "findNodeAndOffsetFromLocation",
    value: function findNodeAndOffsetFromLocation(t) {
      var e,
        i,
        n = 0;
      var _iterator7 = _createForOfIteratorHelper(this.getSignificantNodesForIndex(t.index)),
        _step7;
      try {
        for (_iterator7.s(); !(_step7 = _iterator7.n()).done;) {
          var _r12 = _step7.value;
          var _o8 = Bn(_r12);
          if (t.offset <= n + _o8) if (B(_r12)) {
            if (e = _r12, i = n, t.offset === i && _F(e)) break;
          } else e || (e = _r12, i = n);
          if (n += _o8, n > t.offset) break;
        }
      } catch (err) {
        _iterator7.e(err);
      } finally {
        _iterator7.f();
      }
      return [e, i];
    }
  }, {
    key: "findAttachmentElementParentForNode",
    value: function findAttachmentElementParentForNode(t) {
      for (; t && t !== this.element;) {
        if (P(t)) return t;
        t = t.parentNode;
      }
    }
  }, {
    key: "getSignificantNodesForIndex",
    value: function getSignificantNodesForIndex(t) {
      var e = [],
        i = R(this.element, {
          usingFilter: _n
        });
      var n = !1;
      for (; i.nextNode();) {
        var _o9 = i.currentNode;
        var r;
        if (I(_o9)) {
          if (null != r ? r++ : r = 0, r === t) n = !0;else if (n) break;
        } else n && e.push(_o9);
      }
      return e;
    }
  }]);
}();
var Bn = function Bn(t) {
    if (t.nodeType === Node.TEXT_NODE) {
      if (_F(t)) return 0;
      return t.textContent.length;
    }
    return "br" === k(t) || P(t) ? 1 : 0;
  },
  _n = function _n(t) {
    return jn(t) === NodeFilter.FILTER_ACCEPT ? Wn(t) : NodeFilter.FILTER_REJECT;
  },
  jn = function jn(t) {
    return M(t) ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT;
  },
  Wn = function Wn(t) {
    return P(t.parentNode) ? NodeFilter.FILTER_REJECT : NodeFilter.FILTER_ACCEPT;
  };
var Un = /*#__PURE__*/function () {
  function Un() {
    _classCallCheck(this, Un);
  }
  return _createClass(Un, [{
    key: "createDOMRangeFromPoint",
    value: function createDOMRangeFromPoint(t) {
      var e,
        i = t.x,
        n = t.y;
      if (document.caretPositionFromPoint) {
        var _document$caretPositi = document.caretPositionFromPoint(i, n),
          _t43 = _document$caretPositi.offsetNode,
          _r13 = _document$caretPositi.offset;
        return e = document.createRange(), e.setStart(_t43, _r13), e;
      }
      if (document.caretRangeFromPoint) return document.caretRangeFromPoint(i, n);
      if (document.body.createTextRange) {
        var _t44 = Mt();
        try {
          var _t45 = document.body.createTextRange();
          _t45.moveToPoint(i, n), _t45.select();
        } catch (t) {}
        return e = Mt(), Bt(_t44), e;
      }
    }
  }, {
    key: "getClientRectsForDOMRange",
    value: function getClientRectsForDOMRange(t) {
      var e = Array.from(t.getClientRects());
      return [e[0], e[e.length - 1]];
    }
  }]);
}();
var Vn = /*#__PURE__*/function (_q11) {
  function Vn(t) {
    var _this47;
    _classCallCheck(this, Vn);
    _this47 = _callSuper(this, Vn, arguments), _this47.didMouseDown = _this47.didMouseDown.bind(_assertThisInitialized(_this47)), _this47.selectionDidChange = _this47.selectionDidChange.bind(_assertThisInitialized(_this47)), _this47.element = t, _this47.locationMapper = new Mn(_this47.element), _this47.pointMapper = new Un(), _this47.lockCount = 0, b("mousedown", {
      onElement: _this47.element,
      withCallback: _this47.didMouseDown
    });
    return _this47;
  }
  _inherits(Vn, _q11);
  return _createClass(Vn, [{
    key: "getLocationRange",
    value: function getLocationRange() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {};
      return !1 === t.strict ? this.createLocationRangeFromDOMRange(Mt()) : t.ignoreLock ? this.currentLocationRange : this.lockedLocationRange ? this.lockedLocationRange : this.currentLocationRange;
    }
  }, {
    key: "setLocationRange",
    value: function setLocationRange(t) {
      if (this.lockedLocationRange) return;
      t = wt(t);
      var e = this.createDOMRangeFromLocationRange(t);
      e && (Bt(e), this.updateCurrentLocationRange(t));
    }
  }, {
    key: "setLocationRangeFromPointRange",
    value: function setLocationRangeFromPointRange(t) {
      t = wt(t);
      var e = this.getLocationAtPoint(t[0]),
        i = this.getLocationAtPoint(t[1]);
      this.setLocationRange([e, i]);
    }
  }, {
    key: "getClientRectAtLocationRange",
    value: function getClientRectAtLocationRange(t) {
      var e = this.createDOMRangeFromLocationRange(t);
      if (e) return this.getClientRectsForDOMRange(e)[1];
    }
  }, {
    key: "locationIsCursorTarget",
    value: function locationIsCursorTarget(t) {
      var e = Array.from(this.findNodeAndOffsetFromLocation(t))[0];
      return _F(e);
    }
  }, {
    key: "lock",
    value: function lock() {
      0 == this.lockCount++ && (this.updateCurrentLocationRange(), this.lockedLocationRange = this.getLocationRange());
    }
  }, {
    key: "unlock",
    value: function unlock() {
      if (0 == --this.lockCount) {
        var _t46 = this.lockedLocationRange;
        if (this.lockedLocationRange = null, null != _t46) return this.setLocationRange(_t46);
      }
    }
  }, {
    key: "clearSelection",
    value: function clearSelection() {
      var t;
      return null === (t = Pt()) || void 0 === t ? void 0 : t.removeAllRanges();
    }
  }, {
    key: "selectionIsCollapsed",
    value: function selectionIsCollapsed() {
      var t;
      return !0 === (null === (t = Mt()) || void 0 === t ? void 0 : t.collapsed);
    }
  }, {
    key: "selectionIsExpanded",
    value: function selectionIsExpanded() {
      return !this.selectionIsCollapsed();
    }
  }, {
    key: "createLocationRangeFromDOMRange",
    value: function createLocationRangeFromDOMRange(t, e) {
      if (null == t || !this.domRangeWithinElement(t)) return;
      var i = this.findLocationFromContainerAndOffset(t.startContainer, t.startOffset, e);
      if (!i) return;
      var n = t.collapsed ? void 0 : this.findLocationFromContainerAndOffset(t.endContainer, t.endOffset, e);
      return wt([i, n]);
    }
  }, {
    key: "didMouseDown",
    value: function didMouseDown() {
      return this.pauseTemporarily();
    }
  }, {
    key: "pauseTemporarily",
    value: function pauseTemporarily() {
      var _this48 = this;
      var t;
      this.paused = !0;
      var e = function e() {
          if (_this48.paused = !1, clearTimeout(i), Array.from(t).forEach(function (t) {
            t.destroy();
          }), C(document, _this48.element)) return _this48.selectionDidChange();
        },
        i = setTimeout(e, 200);
      t = ["mousemove", "keydown"].map(function (t) {
        return b(t, {
          onElement: document,
          withCallback: e
        });
      });
    }
  }, {
    key: "selectionDidChange",
    value: function selectionDidChange() {
      if (!this.paused && !x(this.element)) return this.updateCurrentLocationRange();
    }
  }, {
    key: "updateCurrentLocationRange",
    value: function updateCurrentLocationRange(t) {
      var e, i;
      if ((null != t ? t : t = this.createLocationRangeFromDOMRange(Mt())) && !Dt(t, this.currentLocationRange)) return this.currentLocationRange = t, null === (e = this.delegate) || void 0 === e || null === (i = e.locationRangeDidChange) || void 0 === i ? void 0 : i.call(e, this.currentLocationRange.slice(0));
    }
  }, {
    key: "createDOMRangeFromLocationRange",
    value: function createDOMRangeFromLocationRange(t) {
      var e = this.findContainerAndOffsetFromLocation(t[0]),
        i = Lt(t) ? e : this.findContainerAndOffsetFromLocation(t[1]) || e;
      if (null != e && null != i) {
        var _t47 = document.createRange();
        return _t47.setStart.apply(_t47, _toConsumableArray(Array.from(e || []))), _t47.setEnd.apply(_t47, _toConsumableArray(Array.from(i || []))), _t47;
      }
    }
  }, {
    key: "getLocationAtPoint",
    value: function getLocationAtPoint(t) {
      var e = this.createDOMRangeFromPoint(t);
      var i;
      if (e) return null === (i = this.createLocationRangeFromDOMRange(e)) || void 0 === i ? void 0 : i[0];
    }
  }, {
    key: "domRangeWithinElement",
    value: function domRangeWithinElement(t) {
      return t.collapsed ? C(this.element, t.startContainer) : C(this.element, t.startContainer) && C(this.element, t.endContainer);
    }
  }]);
}(q);
Vn.proxyMethod("locationMapper.findLocationFromContainerAndOffset"), Vn.proxyMethod("locationMapper.findContainerAndOffsetFromLocation"), Vn.proxyMethod("locationMapper.findNodeAndOffsetFromLocation"), Vn.proxyMethod("pointMapper.createDOMRangeFromPoint"), Vn.proxyMethod("pointMapper.getClientRectsForDOMRange");
var zn = Object.freeze({
    __proto__: null,
    Attachment: Vi,
    AttachmentManager: kn,
    AttachmentPiece: zi,
    Block: $i,
    Composition: wn,
    Document: an,
    Editor: Pn,
    HTMLParser: hn,
    HTMLSanitizer: di,
    LineBreakInsertion: Tn,
    LocationMapper: Mn,
    ManagedAttachment: Rn,
    Piece: Wi,
    PointMapper: Un,
    SelectionManager: Vn,
    SplittableList: Hi,
    StringPiece: qi,
    Text: Yi,
    UndoManager: Ln
  }),
  qn = Object.freeze({
    __proto__: null,
    ObjectView: ie,
    AttachmentView: pi,
    BlockView: Ei,
    DocumentView: Si,
    PieceView: Ai,
    PreviewableAttachmentView: vi,
    TextView: yi
  });
var Hn = z.lang,
  Jn = z.css,
  Kn = z.keyNames,
  Gn = function Gn(t) {
    return function () {
      var e = t.apply(this, arguments);
      e["do"](), this.undos || (this.undos = []), this.undos.push(e.undo);
    };
  };
var Yn = /*#__PURE__*/function (_q12) {
  function Yn(t, e, i) {
    var _this49;
    _classCallCheck(this, Yn);
    var n = arguments.length > 3 && void 0 !== arguments[3] ? arguments[3] : {};
    _this49 = _callSuper(this, Yn, arguments), Di(_assertThisInitialized(_this49), "makeElementMutable", Gn(function () {
      return {
        "do": function _do() {
          _this49.element.dataset.trixMutable = !0;
        },
        undo: function undo() {
          return delete _this49.element.dataset.trixMutable;
        }
      };
    })), Di(_assertThisInitialized(_this49), "addToolbar", Gn(function () {
      var t = T({
        tagName: "div",
        className: Jn.attachmentToolbar,
        data: {
          trixMutable: !0
        },
        childNodes: T({
          tagName: "div",
          className: "trix-button-row",
          childNodes: T({
            tagName: "span",
            className: "trix-button-group trix-button-group--actions",
            childNodes: T({
              tagName: "button",
              className: "trix-button trix-button--remove",
              textContent: Hn.remove,
              attributes: {
                title: Hn.remove
              },
              data: {
                trixAction: "remove"
              }
            })
          })
        })
      });
      return _this49.attachment.isPreviewable() && t.appendChild(T({
        tagName: "div",
        className: Jn.attachmentMetadataContainer,
        childNodes: T({
          tagName: "span",
          className: Jn.attachmentMetadata,
          childNodes: [T({
            tagName: "span",
            className: Jn.attachmentName,
            textContent: _this49.attachment.getFilename(),
            attributes: {
              title: _this49.attachment.getFilename()
            }
          }), T({
            tagName: "span",
            className: Jn.attachmentSize,
            textContent: _this49.attachment.getFormattedFilesize()
          })]
        })
      })), b("click", {
        onElement: t,
        withCallback: _this49.didClickToolbar
      }), b("click", {
        onElement: t,
        matchingSelector: "[data-trix-action]",
        withCallback: _this49.didClickActionButton
      }), v("trix-attachment-before-toolbar", {
        onElement: _this49.element,
        attributes: {
          toolbar: t,
          attachment: _this49.attachment
        }
      }), {
        "do": function _do() {
          return _this49.element.appendChild(t);
        },
        undo: function undo() {
          return S(t);
        }
      };
    })), Di(_assertThisInitialized(_this49), "installCaptionEditor", Gn(function () {
      var t = T({
        tagName: "textarea",
        className: Jn.attachmentCaptionEditor,
        attributes: {
          placeholder: Hn.captionPlaceholder
        },
        data: {
          trixMutable: !0
        }
      });
      t.value = _this49.attachmentPiece.getCaption();
      var e = t.cloneNode();
      e.classList.add("trix-autoresize-clone"), e.tabIndex = -1;
      var i = function i() {
        e.value = t.value, t.style.height = e.scrollHeight + "px";
      };
      b("input", {
        onElement: t,
        withCallback: i
      }), b("input", {
        onElement: t,
        withCallback: _this49.didInputCaption
      }), b("keydown", {
        onElement: t,
        withCallback: _this49.didKeyDownCaption
      }), b("change", {
        onElement: t,
        withCallback: _this49.didChangeCaption
      }), b("blur", {
        onElement: t,
        withCallback: _this49.didBlurCaption
      });
      var n = _this49.element.querySelector("figcaption"),
        r = n.cloneNode();
      return {
        "do": function _do() {
          if (n.style.display = "none", r.appendChild(t), r.appendChild(e), r.classList.add("".concat(Jn.attachmentCaption, "--editing")), n.parentElement.insertBefore(r, n), i(), _this49.options.editCaption) return Rt(function () {
            return t.focus();
          });
        },
        undo: function undo() {
          S(r), n.style.display = null;
        }
      };
    })), _this49.didClickToolbar = _this49.didClickToolbar.bind(_assertThisInitialized(_this49)), _this49.didClickActionButton = _this49.didClickActionButton.bind(_assertThisInitialized(_this49)), _this49.didKeyDownCaption = _this49.didKeyDownCaption.bind(_assertThisInitialized(_this49)), _this49.didInputCaption = _this49.didInputCaption.bind(_assertThisInitialized(_this49)), _this49.didChangeCaption = _this49.didChangeCaption.bind(_assertThisInitialized(_this49)), _this49.didBlurCaption = _this49.didBlurCaption.bind(_assertThisInitialized(_this49)), _this49.attachmentPiece = t, _this49.element = e, _this49.container = i, _this49.options = n, _this49.attachment = _this49.attachmentPiece.attachment, "a" === k(_this49.element) && (_this49.element = _this49.element.firstChild), _this49.install();
    return _this49;
  }
  _inherits(Yn, _q12);
  return _createClass(Yn, [{
    key: "install",
    value: function install() {
      this.makeElementMutable(), this.addToolbar(), this.attachment.isPreviewable() && this.installCaptionEditor();
    }
  }, {
    key: "uninstall",
    value: function uninstall() {
      var t;
      var e = this.undos.pop();
      for (this.savePendingCaption(); e;) e(), e = this.undos.pop();
      null === (t = this.delegate) || void 0 === t || t.didUninstallAttachmentEditor(this);
    }
  }, {
    key: "savePendingCaption",
    value: function savePendingCaption() {
      if (null != this.pendingCaption) {
        var _r14 = this.pendingCaption;
        var t, e, i, n;
        if (this.pendingCaption = null, _r14) null === (t = this.delegate) || void 0 === t || null === (e = t.attachmentEditorDidRequestUpdatingAttributesForAttachment) || void 0 === e || e.call(t, {
          caption: _r14
        }, this.attachment);else null === (i = this.delegate) || void 0 === i || null === (n = i.attachmentEditorDidRequestRemovingAttributeForAttachment) || void 0 === n || n.call(i, "caption", this.attachment);
      }
    }
  }, {
    key: "didClickToolbar",
    value: function didClickToolbar(t) {
      return t.preventDefault(), t.stopPropagation();
    }
  }, {
    key: "didClickActionButton",
    value: function didClickActionButton(t) {
      var e;
      if ("remove" === t.target.getAttribute("data-trix-action")) return null === (e = this.delegate) || void 0 === e ? void 0 : e.attachmentEditorDidRequestRemovalOfAttachment(this.attachment);
    }
  }, {
    key: "didKeyDownCaption",
    value: function didKeyDownCaption(t) {
      var e, i;
      if ("return" === Kn[t.keyCode]) return t.preventDefault(), this.savePendingCaption(), null === (e = this.delegate) || void 0 === e || null === (i = e.attachmentEditorDidRequestDeselectingAttachment) || void 0 === i ? void 0 : i.call(e, this.attachment);
    }
  }, {
    key: "didInputCaption",
    value: function didInputCaption(t) {
      this.pendingCaption = t.target.value.replace(/\s/g, " ").trim();
    }
  }, {
    key: "didChangeCaption",
    value: function didChangeCaption(t) {
      return this.savePendingCaption();
    }
  }, {
    key: "didBlurCaption",
    value: function didBlurCaption(t) {
      return this.savePendingCaption();
    }
  }]);
}(q);
var $n = /*#__PURE__*/function (_q13) {
  function $n(t, i) {
    var _this50;
    _classCallCheck(this, $n);
    _this50 = _callSuper(this, $n, arguments), _this50.didFocus = _this50.didFocus.bind(_assertThisInitialized(_this50)), _this50.didBlur = _this50.didBlur.bind(_assertThisInitialized(_this50)), _this50.didClickAttachment = _this50.didClickAttachment.bind(_assertThisInitialized(_this50)), _this50.element = t, _this50.composition = i, _this50.documentView = new Si(_this50.composition.document, {
      element: _this50.element
    }), b("focus", {
      onElement: _this50.element,
      withCallback: _this50.didFocus
    }), b("blur", {
      onElement: _this50.element,
      withCallback: _this50.didBlur
    }), b("click", {
      onElement: _this50.element,
      matchingSelector: "a[contenteditable=false]",
      preventDefault: !0
    }), b("mousedown", {
      onElement: _this50.element,
      matchingSelector: e,
      withCallback: _this50.didClickAttachment
    }), b("click", {
      onElement: _this50.element,
      matchingSelector: "a".concat(e),
      preventDefault: !0
    });
    return _this50;
  }
  _inherits($n, _q13);
  return _createClass($n, [{
    key: "didFocus",
    value: function didFocus(t) {
      var _this51 = this;
      var e;
      var i = function i() {
        var t, e;
        if (!_this51.focused) return _this51.focused = !0, null === (t = _this51.delegate) || void 0 === t || null === (e = t.compositionControllerDidFocus) || void 0 === e ? void 0 : e.call(t);
      };
      return (null === (e = this.blurPromise) || void 0 === e ? void 0 : e.then(i)) || i();
    }
  }, {
    key: "didBlur",
    value: function didBlur(t) {
      var _this52 = this;
      this.blurPromise = new Promise(function (t) {
        return Rt(function () {
          var e, i;
          x(_this52.element) || (_this52.focused = null, null === (e = _this52.delegate) || void 0 === e || null === (i = e.compositionControllerDidBlur) || void 0 === i || i.call(e));
          return _this52.blurPromise = null, t();
        });
      });
    }
  }, {
    key: "didClickAttachment",
    value: function didClickAttachment(t, e) {
      var i, n;
      var r = this.findAttachmentForElement(e),
        o = !!y(t.target, {
          matchingSelector: "figcaption"
        });
      return null === (i = this.delegate) || void 0 === i || null === (n = i.compositionControllerDidSelectAttachment) || void 0 === n ? void 0 : n.call(i, r, {
        editCaption: o
      });
    }
  }, {
    key: "getSerializableElement",
    value: function getSerializableElement() {
      return this.isEditingAttachment() ? this.documentView.shadowElement : this.element;
    }
  }, {
    key: "render",
    value: function render() {
      var t, e, i, n, r, o;
      (this.revision !== this.composition.revision && (this.documentView.setDocument(this.composition.document), this.documentView.render(), this.revision = this.composition.revision), this.canSyncDocumentView() && !this.documentView.isSynced()) && (null === (i = this.delegate) || void 0 === i || null === (n = i.compositionControllerWillSyncDocumentView) || void 0 === n || n.call(i), this.documentView.sync(), null === (r = this.delegate) || void 0 === r || null === (o = r.compositionControllerDidSyncDocumentView) || void 0 === o || o.call(r));
      return null === (t = this.delegate) || void 0 === t || null === (e = t.compositionControllerDidRender) || void 0 === e ? void 0 : e.call(t);
    }
  }, {
    key: "rerenderViewForObject",
    value: function rerenderViewForObject(t) {
      return this.invalidateViewForObject(t), this.render();
    }
  }, {
    key: "invalidateViewForObject",
    value: function invalidateViewForObject(t) {
      return this.documentView.invalidateViewForObject(t);
    }
  }, {
    key: "isViewCachingEnabled",
    value: function isViewCachingEnabled() {
      return this.documentView.isViewCachingEnabled();
    }
  }, {
    key: "enableViewCaching",
    value: function enableViewCaching() {
      return this.documentView.enableViewCaching();
    }
  }, {
    key: "disableViewCaching",
    value: function disableViewCaching() {
      return this.documentView.disableViewCaching();
    }
  }, {
    key: "refreshViewCache",
    value: function refreshViewCache() {
      return this.documentView.garbageCollectCachedViews();
    }
  }, {
    key: "isEditingAttachment",
    value: function isEditingAttachment() {
      return !!this.attachmentEditor;
    }
  }, {
    key: "installAttachmentEditorForAttachment",
    value: function installAttachmentEditorForAttachment(t, e) {
      var i;
      if ((null === (i = this.attachmentEditor) || void 0 === i ? void 0 : i.attachment) === t) return;
      var n = this.documentView.findElementForObject(t);
      if (!n) return;
      this.uninstallAttachmentEditor();
      var r = this.composition.document.getAttachmentPieceForAttachment(t);
      this.attachmentEditor = new Yn(r, n, this.element, e), this.attachmentEditor.delegate = this;
    }
  }, {
    key: "uninstallAttachmentEditor",
    value: function uninstallAttachmentEditor() {
      var t;
      return null === (t = this.attachmentEditor) || void 0 === t ? void 0 : t.uninstall();
    }
  }, {
    key: "didUninstallAttachmentEditor",
    value: function didUninstallAttachmentEditor() {
      return this.attachmentEditor = null, this.render();
    }
  }, {
    key: "attachmentEditorDidRequestUpdatingAttributesForAttachment",
    value: function attachmentEditorDidRequestUpdatingAttributesForAttachment(t, e) {
      var i, n;
      return null === (i = this.delegate) || void 0 === i || null === (n = i.compositionControllerWillUpdateAttachment) || void 0 === n || n.call(i, e), this.composition.updateAttributesForAttachment(t, e);
    }
  }, {
    key: "attachmentEditorDidRequestRemovingAttributeForAttachment",
    value: function attachmentEditorDidRequestRemovingAttributeForAttachment(t, e) {
      var i, n;
      return null === (i = this.delegate) || void 0 === i || null === (n = i.compositionControllerWillUpdateAttachment) || void 0 === n || n.call(i, e), this.composition.removeAttributeForAttachment(t, e);
    }
  }, {
    key: "attachmentEditorDidRequestRemovalOfAttachment",
    value: function attachmentEditorDidRequestRemovalOfAttachment(t) {
      var e, i;
      return null === (e = this.delegate) || void 0 === e || null === (i = e.compositionControllerDidRequestRemovalOfAttachment) || void 0 === i ? void 0 : i.call(e, t);
    }
  }, {
    key: "attachmentEditorDidRequestDeselectingAttachment",
    value: function attachmentEditorDidRequestDeselectingAttachment(t) {
      var e, i;
      return null === (e = this.delegate) || void 0 === e || null === (i = e.compositionControllerDidRequestDeselectingAttachment) || void 0 === i ? void 0 : i.call(e, t);
    }
  }, {
    key: "canSyncDocumentView",
    value: function canSyncDocumentView() {
      return !this.isEditingAttachment();
    }
  }, {
    key: "findAttachmentForElement",
    value: function findAttachmentForElement(t) {
      return this.composition.document.getAttachmentById(parseInt(t.dataset.trixId, 10));
    }
  }]);
}(q);
var Xn = /*#__PURE__*/function (_q14) {
  function Xn() {
    _classCallCheck(this, Xn);
    return _callSuper(this, Xn, arguments);
  }
  _inherits(Xn, _q14);
  return _createClass(Xn);
}(q);
var Zn = "data-trix-mutable",
  Qn = "[".concat(Zn, "]"),
  tr = {
    attributes: !0,
    childList: !0,
    characterData: !0,
    characterDataOldValue: !0,
    subtree: !0
  };
var er = /*#__PURE__*/function (_q15) {
  function er(t) {
    var _this53;
    _classCallCheck(this, er);
    _this53 = _callSuper(this, er, [t]), _this53.didMutate = _this53.didMutate.bind(_assertThisInitialized(_this53)), _this53.element = t, _this53.observer = new window.MutationObserver(_this53.didMutate), _this53.start();
    return _this53;
  }
  _inherits(er, _q15);
  return _createClass(er, [{
    key: "start",
    value: function start() {
      return this.reset(), this.observer.observe(this.element, tr);
    }
  }, {
    key: "stop",
    value: function stop() {
      return this.observer.disconnect();
    }
  }, {
    key: "didMutate",
    value: function didMutate(t) {
      var _this$mutations;
      var e, i;
      if ((_this$mutations = this.mutations).push.apply(_this$mutations, _toConsumableArray(Array.from(this.findSignificantMutations(t) || []))), this.mutations.length) return null === (e = this.delegate) || void 0 === e || null === (i = e.elementDidMutate) || void 0 === i || i.call(e, this.getMutationSummary()), this.reset();
    }
  }, {
    key: "reset",
    value: function reset() {
      this.mutations = [];
    }
  }, {
    key: "findSignificantMutations",
    value: function findSignificantMutations(t) {
      var _this54 = this;
      return t.filter(function (t) {
        return _this54.mutationIsSignificant(t);
      });
    }
  }, {
    key: "mutationIsSignificant",
    value: function mutationIsSignificant(t) {
      if (this.nodeIsMutable(t.target)) return !1;
      for (var _i37 = 0, _Array$from18 = Array.from(this.nodesModifiedByMutation(t)); _i37 < _Array$from18.length; _i37++) {
        var _e45 = _Array$from18[_i37];
        if (this.nodeIsSignificant(_e45)) return !0;
      }
      return !1;
    }
  }, {
    key: "nodeIsSignificant",
    value: function nodeIsSignificant(t) {
      return t !== this.element && !this.nodeIsMutable(t) && !M(t);
    }
  }, {
    key: "nodeIsMutable",
    value: function nodeIsMutable(t) {
      return y(t, {
        matchingSelector: Qn
      });
    }
  }, {
    key: "nodesModifiedByMutation",
    value: function nodesModifiedByMutation(t) {
      var e = [];
      switch (t.type) {
        case "attributes":
          t.attributeName !== Zn && e.push(t.target);
          break;
        case "characterData":
          e.push(t.target.parentNode), e.push(t.target);
          break;
        case "childList":
          e.push.apply(e, _toConsumableArray(Array.from(t.addedNodes || []))), e.push.apply(e, _toConsumableArray(Array.from(t.removedNodes || [])));
      }
      return e;
    }
  }, {
    key: "getMutationSummary",
    value: function getMutationSummary() {
      return this.getTextMutationSummary();
    }
  }, {
    key: "getTextMutationSummary",
    value: function getTextMutationSummary() {
      var _this$getTextChangesF = this.getTextChangesFromCharacterData(),
        t = _this$getTextChangesF.additions,
        e = _this$getTextChangesF.deletions,
        i = this.getTextChangesFromChildList();
      Array.from(i.additions).forEach(function (e) {
        Array.from(t).includes(e) || t.push(e);
      }), e.push.apply(e, _toConsumableArray(Array.from(i.deletions || [])));
      var n = {},
        r = t.join("");
      r && (n.textAdded = r);
      var o = e.join("");
      return o && (n.textDeleted = o), n;
    }
  }, {
    key: "getMutationsByType",
    value: function getMutationsByType(t) {
      return Array.from(this.mutations).filter(function (e) {
        return e.type === t;
      });
    }
  }, {
    key: "getTextChangesFromChildList",
    value: function getTextChangesFromChildList() {
      var t, e;
      var i = [],
        n = [];
      Array.from(this.getMutationsByType("childList")).forEach(function (t) {
        i.push.apply(i, _toConsumableArray(Array.from(t.addedNodes || []))), n.push.apply(n, _toConsumableArray(Array.from(t.removedNodes || [])));
      });
      0 === i.length && 1 === n.length && I(n[0]) ? (t = [], e = ["\n"]) : (t = _ir(i), e = _ir(n));
      var r = t.filter(function (t, i) {
          return t !== e[i];
        }).map(Wt),
        o = e.filter(function (e, i) {
          return e !== t[i];
        }).map(Wt);
      return {
        additions: r,
        deletions: o
      };
    }
  }, {
    key: "getTextChangesFromCharacterData",
    value: function getTextChangesFromCharacterData() {
      var t, e;
      var i = this.getMutationsByType("characterData");
      if (i.length) {
        var _n26 = i[0],
          _r15 = i[i.length - 1],
          _o0 = function (t, e, _zt, _zt2, _zt3, _zt4) {
            var i, n;
            return t = X.box(t), (e = X.box(e)).length < t.length ? (_zt = zt(t, e), _zt2 = _slicedToArray(_zt, 2), n = _zt2[0], i = _zt2[1], _zt) : (_zt3 = zt(e, t), _zt4 = _slicedToArray(_zt3, 2), i = _zt4[0], n = _zt4[1], _zt3), {
              added: i,
              removed: n
            };
          }(Wt(_n26.oldValue), Wt(_r15.target.data));
        t = _o0.added, e = _o0.removed;
      }
      return {
        additions: t ? [t] : [],
        deletions: e ? [e] : []
      };
    }
  }]);
}(q);
var _ir = function ir() {
  var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : [];
  var e = [];
  for (var _i38 = 0, _Array$from19 = Array.from(t); _i38 < _Array$from19.length; _i38++) {
    var _i39 = _Array$from19[_i38];
    switch (_i39.nodeType) {
      case Node.TEXT_NODE:
        e.push(_i39.data);
        break;
      case Node.ELEMENT_NODE:
        "br" === k(_i39) ? e.push("\n") : e.push.apply(e, _toConsumableArray(Array.from(_ir(_i39.childNodes) || [])));
    }
  }
  return e;
};
var nr = /*#__PURE__*/function (_ee2) {
  function nr(t) {
    var _this55;
    _classCallCheck(this, nr);
    _this55 = _callSuper(this, nr, arguments), _this55.file = t;
    return _this55;
  }
  _inherits(nr, _ee2);
  return _createClass(nr, [{
    key: "perform",
    value: function perform(t) {
      var _this56 = this;
      var e = new FileReader();
      return e.onerror = function () {
        return t(!1);
      }, e.onload = function () {
        e.onerror = null;
        try {
          e.abort();
        } catch (t) {}
        return t(!0, _this56.file);
      }, e.readAsArrayBuffer(this.file);
    }
  }]);
}(ee);
var rr = /*#__PURE__*/function () {
  function rr(t) {
    _classCallCheck(this, rr);
    this.element = t;
  }
  return _createClass(rr, [{
    key: "shouldIgnore",
    value: function shouldIgnore(t) {
      return !!a.samsungAndroid && (this.previousEvent = this.event, this.event = t, this.checkSamsungKeyboardBuggyModeStart(), this.checkSamsungKeyboardBuggyModeEnd(), this.buggyMode);
    }
  }, {
    key: "checkSamsungKeyboardBuggyModeStart",
    value: function checkSamsungKeyboardBuggyModeStart() {
      this.insertingLongTextAfterUnidentifiedChar() && or(this.element.innerText, this.event.data) && (this.buggyMode = !0, this.event.preventDefault());
    }
  }, {
    key: "checkSamsungKeyboardBuggyModeEnd",
    value: function checkSamsungKeyboardBuggyModeEnd() {
      this.buggyMode && "insertText" !== this.event.inputType && (this.buggyMode = !1);
    }
  }, {
    key: "insertingLongTextAfterUnidentifiedChar",
    value: function insertingLongTextAfterUnidentifiedChar() {
      var t;
      return this.isBeforeInputInsertText() && this.previousEventWasUnidentifiedKeydown() && (null === (t = this.event.data) || void 0 === t ? void 0 : t.length) > 50;
    }
  }, {
    key: "isBeforeInputInsertText",
    value: function isBeforeInputInsertText() {
      return "beforeinput" === this.event.type && "insertText" === this.event.inputType;
    }
  }, {
    key: "previousEventWasUnidentifiedKeydown",
    value: function previousEventWasUnidentifiedKeydown() {
      var t, e;
      return "keydown" === (null === (t = this.previousEvent) || void 0 === t ? void 0 : t.type) && "Unidentified" === (null === (e = this.previousEvent) || void 0 === e ? void 0 : e.key);
    }
  }]);
}();
var or = function or(t, e) {
    return ar(t) === ar(e);
  },
  sr = new RegExp("(".concat("￼", "|").concat(d, "|").concat(g, "|\\s)+"), "g"),
  ar = function ar(t) {
    return t.replace(sr, " ").trim();
  };
var lr = /*#__PURE__*/function (_q16) {
  function lr(t) {
    var _this57;
    _classCallCheck(this, lr);
    _this57 = _callSuper(this, lr, arguments), _this57.element = t, _this57.mutationObserver = new er(_this57.element), _this57.mutationObserver.delegate = _assertThisInitialized(_this57), _this57.flakyKeyboardDetector = new rr(_this57.element);
    for (var _t48 in _this57.constructor.events) b(_t48, {
      onElement: _this57.element,
      withCallback: _this57.handlerFor(_t48)
    });
    return _this57;
  }
  _inherits(lr, _q16);
  return _createClass(lr, [{
    key: "elementDidMutate",
    value: function elementDidMutate(t) {}
  }, {
    key: "editorWillSyncDocumentView",
    value: function editorWillSyncDocumentView() {
      return this.mutationObserver.stop();
    }
  }, {
    key: "editorDidSyncDocumentView",
    value: function editorDidSyncDocumentView() {
      return this.mutationObserver.start();
    }
  }, {
    key: "requestRender",
    value: function requestRender() {
      var t, e;
      return null === (t = this.delegate) || void 0 === t || null === (e = t.inputControllerDidRequestRender) || void 0 === e ? void 0 : e.call(t);
    }
  }, {
    key: "requestReparse",
    value: function requestReparse() {
      var t, e;
      return null === (t = this.delegate) || void 0 === t || null === (e = t.inputControllerDidRequestReparse) || void 0 === e || e.call(t), this.requestRender();
    }
  }, {
    key: "attachFiles",
    value: function attachFiles(t) {
      var _this58 = this;
      var e = Array.from(t).map(function (t) {
        return new nr(t);
      });
      return Promise.all(e).then(function (t) {
        _this58.handleInput(function () {
          var e, i;
          return null === (e = this.delegate) || void 0 === e || e.inputControllerWillAttachFiles(), null === (i = this.responder) || void 0 === i || i.insertFiles(t), this.requestRender();
        });
      });
    }
  }, {
    key: "handlerFor",
    value: function handlerFor(t) {
      var _this59 = this;
      return function (e) {
        e.defaultPrevented || _this59.handleInput(function () {
          if (!x(_this59.element)) {
            if (_this59.flakyKeyboardDetector.shouldIgnore(e)) return;
            _this59.eventName = t, _this59.constructor.events[t].call(_this59, e);
          }
        });
      };
    }
  }, {
    key: "handleInput",
    value: function handleInput(t) {
      try {
        var e;
        null === (e = this.delegate) || void 0 === e || e.inputControllerWillHandleInput(), t.call(this);
      } finally {
        var i;
        null === (i = this.delegate) || void 0 === i || i.inputControllerDidHandleInput();
      }
    }
  }, {
    key: "createLinkHTML",
    value: function createLinkHTML(t, e) {
      var i = document.createElement("a");
      return i.href = t, i.textContent = e || t, i.outerHTML;
    }
  }]);
}(q);
var cr;
Di(lr, "events", {});
var ur = z.browser,
  hr = z.keyNames;
var dr = 0;
var gr = /*#__PURE__*/function (_lr) {
  function gr() {
    var _this60;
    _classCallCheck(this, gr);
    _this60 = _callSuper(this, gr, arguments), _this60.resetInputSummary();
    return _this60;
  }
  _inherits(gr, _lr);
  return _createClass(gr, [{
    key: "setInputSummary",
    value: function setInputSummary() {
      var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {};
      this.inputSummary.eventName = this.eventName;
      for (var _e46 in t) {
        var _i40 = t[_e46];
        this.inputSummary[_e46] = _i40;
      }
      return this.inputSummary;
    }
  }, {
    key: "resetInputSummary",
    value: function resetInputSummary() {
      this.inputSummary = {};
    }
  }, {
    key: "reset",
    value: function reset() {
      return this.resetInputSummary(), Ft.reset();
    }
  }, {
    key: "elementDidMutate",
    value: function elementDidMutate(t) {
      var e, i;
      return this.isComposing() ? null === (e = this.delegate) || void 0 === e || null === (i = e.inputControllerDidAllowUnhandledInput) || void 0 === i ? void 0 : i.call(e) : this.handleInput(function () {
        return this.mutationIsSignificant(t) && (this.mutationIsExpected(t) ? this.requestRender() : this.requestReparse()), this.reset();
      });
    }
  }, {
    key: "mutationIsExpected",
    value: function mutationIsExpected(t) {
      var e = t.textAdded,
        i = t.textDeleted;
      if (this.inputSummary.preferDocument) return !0;
      var n = null != e ? e === this.inputSummary.textAdded : !this.inputSummary.textAdded,
        r = null != i ? this.inputSummary.didDelete : !this.inputSummary.didDelete,
        o = ["\n", " \n"].includes(e) && !n,
        s = "\n" === i && !r;
      if (o && !s || s && !o) {
        var _t49 = this.getSelectedRange();
        if (_t49) {
          var a;
          var _i41 = o ? e.replace(/\n$/, "").length || -1 : (null == e ? void 0 : e.length) || 1;
          if (null !== (a = this.responder) && void 0 !== a && a.positionIsBlockBreak(_t49[1] + _i41)) return !0;
        }
      }
      return n && r;
    }
  }, {
    key: "mutationIsSignificant",
    value: function mutationIsSignificant(t) {
      var e;
      var i = Object.keys(t).length > 0,
        n = "" === (null === (e = this.compositionInput) || void 0 === e ? void 0 : e.getEndData());
      return i || !n;
    }
  }, {
    key: "getCompositionInput",
    value: function getCompositionInput() {
      if (this.isComposing()) return this.compositionInput;
      this.compositionInput = new vr(this);
    }
  }, {
    key: "isComposing",
    value: function isComposing() {
      return this.compositionInput && !this.compositionInput.isEnded();
    }
  }, {
    key: "deleteInDirection",
    value: function deleteInDirection(t, e) {
      var i;
      return !1 !== (null === (i = this.responder) || void 0 === i ? void 0 : i.deleteInDirection(t)) ? this.setInputSummary({
        didDelete: !0
      }) : e ? (e.preventDefault(), this.requestRender()) : void 0;
    }
  }, {
    key: "serializeSelectionToDataTransfer",
    value: function serializeSelectionToDataTransfer(t) {
      var e;
      if (!function (t) {
        if (null == t || !t.setData) return !1;
        for (var _e47 in Ct) {
          var _i42 = Ct[_e47];
          try {
            if (t.setData(_e47, _i42), !t.getData(_e47) === _i42) return !1;
          } catch (t) {
            return !1;
          }
        }
        return !0;
      }(t)) return;
      var i = null === (e = this.responder) || void 0 === e ? void 0 : e.getSelectedDocument().toSerializableDocument();
      return t.setData("application/x-trix-document", JSON.stringify(i)), t.setData("text/html", Si.render(i).innerHTML), t.setData("text/plain", i.toString().replace(/\n$/, "")), !0;
    }
  }, {
    key: "canAcceptDataTransfer",
    value: function canAcceptDataTransfer(t) {
      var e = {};
      return Array.from((null == t ? void 0 : t.types) || []).forEach(function (t) {
        e[t] = !0;
      }), e.Files || e["application/x-trix-document"] || e["text/html"] || e["text/plain"];
    }
  }, {
    key: "getPastedHTMLUsingHiddenElement",
    value: function getPastedHTMLUsingHiddenElement(t) {
      var _this61 = this;
      var e = this.getSelectedRange(),
        i = {
          position: "absolute",
          left: "".concat(window.pageXOffset, "px"),
          top: "".concat(window.pageYOffset, "px"),
          opacity: 0
        },
        n = T({
          style: i,
          tagName: "div",
          editable: !0
        });
      return document.body.appendChild(n), n.focus(), requestAnimationFrame(function () {
        var i = n.innerHTML;
        return S(n), _this61.setSelectedRange(e), t(i);
      });
    }
  }]);
}(lr);
Di(gr, "events", {
  keydown: function keydown(t) {
    this.isComposing() || this.resetInputSummary(), this.inputSummary.didInput = !0;
    var e = hr[t.keyCode];
    if (e) {
      var i;
      var _n27 = this.keys;
      ["ctrl", "alt", "shift", "meta"].forEach(function (e) {
        var i;
        t["".concat(e, "Key")] && ("ctrl" === e && (e = "control"), _n27 = null === (i = _n27) || void 0 === i ? void 0 : i[e]);
      }), null != (null === (i = _n27) || void 0 === i ? void 0 : i[e]) && (this.setInputSummary({
        keyName: e
      }), Ft.reset(), _n27[e].call(this, t));
    }
    if (St(t)) {
      var _e48 = String.fromCharCode(t.keyCode).toLowerCase();
      if (_e48) {
        var n;
        var _i43 = ["alt", "shift"].map(function (e) {
          if (t["".concat(e, "Key")]) return e;
        }).filter(function (t) {
          return t;
        });
        _i43.push(_e48), null !== (n = this.delegate) && void 0 !== n && n.inputControllerDidReceiveKeyboardCommand(_i43) && t.preventDefault();
      }
    }
  },
  keypress: function keypress(t) {
    if (null != this.inputSummary.eventName) return;
    if (t.metaKey) return;
    if (t.ctrlKey && !t.altKey) return;
    var e = fr(t);
    var i, n;
    return e ? (null === (i = this.delegate) || void 0 === i || i.inputControllerWillPerformTyping(), null === (n = this.responder) || void 0 === n || n.insertString(e), this.setInputSummary({
      textAdded: e,
      didDelete: this.selectionIsExpanded()
    })) : void 0;
  },
  textInput: function textInput(t) {
    var e = t.data,
      i = this.inputSummary.textAdded;
    if (i && i !== e && i.toUpperCase() === e) {
      var n;
      var _t50 = this.getSelectedRange();
      return this.setSelectedRange([_t50[0], _t50[1] + i.length]), null === (n = this.responder) || void 0 === n || n.insertString(e), this.setInputSummary({
        textAdded: e
      }), this.setSelectedRange(_t50);
    }
  },
  dragenter: function dragenter(t) {
    t.preventDefault();
  },
  dragstart: function dragstart(t) {
    var e, i;
    return this.serializeSelectionToDataTransfer(t.dataTransfer), this.draggedRange = this.getSelectedRange(), null === (e = this.delegate) || void 0 === e || null === (i = e.inputControllerDidStartDrag) || void 0 === i ? void 0 : i.call(e);
  },
  dragover: function dragover(t) {
    if (this.draggedRange || this.canAcceptDataTransfer(t.dataTransfer)) {
      t.preventDefault();
      var _n28 = {
        x: t.clientX,
        y: t.clientY
      };
      var e, i;
      if (!Tt(_n28, this.draggingPoint)) return this.draggingPoint = _n28, null === (e = this.delegate) || void 0 === e || null === (i = e.inputControllerDidReceiveDragOverPoint) || void 0 === i ? void 0 : i.call(e, this.draggingPoint);
    }
  },
  dragend: function dragend(t) {
    var e, i;
    null === (e = this.delegate) || void 0 === e || null === (i = e.inputControllerDidCancelDrag) || void 0 === i || i.call(e), this.draggedRange = null, this.draggingPoint = null;
  },
  drop: function drop(t) {
    var e, i;
    t.preventDefault();
    var n = null === (e = t.dataTransfer) || void 0 === e ? void 0 : e.files,
      r = t.dataTransfer.getData("application/x-trix-document"),
      o = {
        x: t.clientX,
        y: t.clientY
      };
    if (null === (i = this.responder) || void 0 === i || i.setLocationRangeFromPointRange(o), null != n && n.length) this.attachFiles(n);else if (this.draggedRange) {
      var s, a;
      null === (s = this.delegate) || void 0 === s || s.inputControllerWillMoveText(), null === (a = this.responder) || void 0 === a || a.moveTextFromRange(this.draggedRange), this.draggedRange = null, this.requestRender();
    } else if (r) {
      var l;
      var _t51 = an.fromJSONString(r);
      null === (l = this.responder) || void 0 === l || l.insertDocument(_t51), this.requestRender();
    }
    this.draggedRange = null, this.draggingPoint = null;
  },
  cut: function cut(t) {
    var e, i;
    if (null !== (e = this.responder) && void 0 !== e && e.selectionIsExpanded() && (this.serializeSelectionToDataTransfer(t.clipboardData) && t.preventDefault(), null === (i = this.delegate) || void 0 === i || i.inputControllerWillCutText(), this.deleteInDirection("backward"), t.defaultPrevented)) return this.requestRender();
  },
  copy: function copy(t) {
    var e;
    null !== (e = this.responder) && void 0 !== e && e.selectionIsExpanded() && this.serializeSelectionToDataTransfer(t.clipboardData) && t.preventDefault();
  },
  paste: function paste(t) {
    var _this62 = this;
    var e = t.clipboardData || t.testClipboardData,
      i = {
        clipboard: e
      };
    if (!e || br(t)) return void this.getPastedHTMLUsingHiddenElement(function (t) {
      var e, n, r;
      return i.type = "text/html", i.html = t, null === (e = _this62.delegate) || void 0 === e || e.inputControllerWillPaste(i), null === (n = _this62.responder) || void 0 === n || n.insertHTML(i.html), _this62.requestRender(), null === (r = _this62.delegate) || void 0 === r ? void 0 : r.inputControllerDidPaste(i);
    });
    var n = e.getData("URL"),
      r = e.getData("text/html"),
      o = e.getData("public.url-name");
    if (n) {
      var s, a, l;
      var _t52;
      i.type = "text/html", _t52 = o ? Vt(o).trim() : n, i.html = this.createLinkHTML(n, _t52), null === (s = this.delegate) || void 0 === s || s.inputControllerWillPaste(i), this.setInputSummary({
        textAdded: _t52,
        didDelete: this.selectionIsExpanded()
      }), null === (a = this.responder) || void 0 === a || a.insertHTML(i.html), this.requestRender(), null === (l = this.delegate) || void 0 === l || l.inputControllerDidPaste(i);
    } else if (Et(e)) {
      var c, u, h;
      i.type = "text/plain", i.string = e.getData("text/plain"), null === (c = this.delegate) || void 0 === c || c.inputControllerWillPaste(i), this.setInputSummary({
        textAdded: i.string,
        didDelete: this.selectionIsExpanded()
      }), null === (u = this.responder) || void 0 === u || u.insertString(i.string), this.requestRender(), null === (h = this.delegate) || void 0 === h || h.inputControllerDidPaste(i);
    } else if (r) {
      var d, g, m;
      i.type = "text/html", i.html = r, null === (d = this.delegate) || void 0 === d || d.inputControllerWillPaste(i), null === (g = this.responder) || void 0 === g || g.insertHTML(i.html), this.requestRender(), null === (m = this.delegate) || void 0 === m || m.inputControllerDidPaste(i);
    } else if (Array.from(e.types).includes("Files")) {
      var p, f;
      var _t53 = null === (p = e.items) || void 0 === p || null === (p = p[0]) || void 0 === p || null === (f = p.getAsFile) || void 0 === f ? void 0 : f.call(p);
      if (_t53) {
        var b, v, A;
        var _e49 = mr(_t53);
        !_t53.name && _e49 && (_t53.name = "pasted-file-".concat(++dr, ".").concat(_e49)), i.type = "File", i.file = _t53, null === (b = this.delegate) || void 0 === b || b.inputControllerWillAttachFiles(), null === (v = this.responder) || void 0 === v || v.insertFile(i.file), this.requestRender(), null === (A = this.delegate) || void 0 === A || A.inputControllerDidPaste(i);
      }
    }
    t.preventDefault();
  },
  compositionstart: function compositionstart(t) {
    return this.getCompositionInput().start(t.data);
  },
  compositionupdate: function compositionupdate(t) {
    return this.getCompositionInput().update(t.data);
  },
  compositionend: function compositionend(t) {
    return this.getCompositionInput().end(t.data);
  },
  beforeinput: function beforeinput(t) {
    this.inputSummary.didInput = !0;
  },
  input: function input(t) {
    return this.inputSummary.didInput = !0, t.stopPropagation();
  }
}), Di(gr, "keys", {
  backspace: function backspace(t) {
    var e;
    return null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), this.deleteInDirection("backward", t);
  },
  "delete": function _delete(t) {
    var e;
    return null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), this.deleteInDirection("forward", t);
  },
  "return": function _return(t) {
    var e, i;
    return this.setInputSummary({
      preferDocument: !0
    }), null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), null === (i = this.responder) || void 0 === i ? void 0 : i.insertLineBreak();
  },
  tab: function tab(t) {
    var e, i;
    null !== (e = this.responder) && void 0 !== e && e.canIncreaseNestingLevel() && (null === (i = this.responder) || void 0 === i || i.increaseNestingLevel(), this.requestRender(), t.preventDefault());
  },
  left: function left(t) {
    var e;
    if (this.selectionIsInCursorTarget()) return t.preventDefault(), null === (e = this.responder) || void 0 === e ? void 0 : e.moveCursorInDirection("backward");
  },
  right: function right(t) {
    var e;
    if (this.selectionIsInCursorTarget()) return t.preventDefault(), null === (e = this.responder) || void 0 === e ? void 0 : e.moveCursorInDirection("forward");
  },
  control: {
    d: function d(t) {
      var e;
      return null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), this.deleteInDirection("forward", t);
    },
    h: function h(t) {
      var e;
      return null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), this.deleteInDirection("backward", t);
    },
    o: function o(t) {
      var e, i;
      return t.preventDefault(), null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), null === (i = this.responder) || void 0 === i || i.insertString("\n", {
        updatePosition: !1
      }), this.requestRender();
    }
  },
  shift: {
    "return": function _return(t) {
      var e, i;
      null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), null === (i = this.responder) || void 0 === i || i.insertString("\n"), this.requestRender(), t.preventDefault();
    },
    tab: function tab(t) {
      var e, i;
      null !== (e = this.responder) && void 0 !== e && e.canDecreaseNestingLevel() && (null === (i = this.responder) || void 0 === i || i.decreaseNestingLevel(), this.requestRender(), t.preventDefault());
    },
    left: function left(t) {
      if (this.selectionIsInCursorTarget()) return t.preventDefault(), this.expandSelectionInDirection("backward");
    },
    right: function right(t) {
      if (this.selectionIsInCursorTarget()) return t.preventDefault(), this.expandSelectionInDirection("forward");
    }
  },
  alt: {
    backspace: function backspace(t) {
      var e;
      return this.setInputSummary({
        preferDocument: !1
      }), null === (e = this.delegate) || void 0 === e ? void 0 : e.inputControllerWillPerformTyping();
    }
  },
  meta: {
    backspace: function backspace(t) {
      var e;
      return this.setInputSummary({
        preferDocument: !1
      }), null === (e = this.delegate) || void 0 === e ? void 0 : e.inputControllerWillPerformTyping();
    }
  }
}), gr.proxyMethod("responder?.getSelectedRange"), gr.proxyMethod("responder?.setSelectedRange"), gr.proxyMethod("responder?.expandSelectionInDirection"), gr.proxyMethod("responder?.selectionIsInCursorTarget"), gr.proxyMethod("responder?.selectionIsExpanded");
var mr = function mr(t) {
    var e;
    return null === (e = t.type) || void 0 === e || null === (e = e.match(/\/(\w+)$/)) || void 0 === e ? void 0 : e[1];
  },
  pr = !(null === (cr = " ".codePointAt) || void 0 === cr || !cr.call(" ", 0)),
  fr = function fr(t) {
    if (t.key && pr && t.key.codePointAt(0) === t.keyCode) return t.key;
    {
      var _e50;
      if (null === t.which ? _e50 = t.keyCode : 0 !== t.which && 0 !== t.charCode && (_e50 = t.charCode), null != _e50 && "escape" !== hr[_e50]) return X.fromCodepoints([_e50]).toString();
    }
  },
  br = function br(t) {
    var e = t.clipboardData;
    if (e) {
      if (e.types.includes("text/html")) {
        var _iterator8 = _createForOfIteratorHelper(e.types),
          _step8;
        try {
          for (_iterator8.s(); !(_step8 = _iterator8.n()).done;) {
            var _t54 = _step8.value;
            var _i44 = /^CorePasteboardFlavorType/.test(_t54),
              _n29 = /^dyn\./.test(_t54) && e.getData(_t54);
            if (_i44 || _n29) return !0;
          }
        } catch (err) {
          _iterator8.e(err);
        } finally {
          _iterator8.f();
        }
        return !1;
      }
      {
        var _t55 = e.types.includes("com.apple.webarchive"),
          _i45 = e.types.includes("com.apple.flat-rtfd");
        return _t55 || _i45;
      }
    }
  };
var vr = /*#__PURE__*/function (_q17) {
  function vr(t) {
    var _this63;
    _classCallCheck(this, vr);
    _this63 = _callSuper(this, vr, arguments), _this63.inputController = t, _this63.responder = _this63.inputController.responder, _this63.delegate = _this63.inputController.delegate, _this63.inputSummary = _this63.inputController.inputSummary, _this63.data = {};
    return _this63;
  }
  _inherits(vr, _q17);
  return _createClass(vr, [{
    key: "start",
    value: function start(t) {
      if (this.data.start = t, this.isSignificant()) {
        var e, i;
        if ("keypress" === this.inputSummary.eventName && this.inputSummary.textAdded) null === (i = this.responder) || void 0 === i || i.deleteInDirection("left");
        this.selectionIsExpanded() || (this.insertPlaceholder(), this.requestRender()), this.range = null === (e = this.responder) || void 0 === e ? void 0 : e.getSelectedRange();
      }
    }
  }, {
    key: "update",
    value: function update(t) {
      if (this.data.update = t, this.isSignificant()) {
        var _t56 = this.selectPlaceholder();
        _t56 && (this.forgetPlaceholder(), this.range = _t56);
      }
    }
  }, {
    key: "end",
    value: function end(t) {
      return this.data.end = t, this.isSignificant() ? (this.forgetPlaceholder(), this.canApplyToDocument() ? (this.setInputSummary({
        preferDocument: !0,
        didInput: !1
      }), null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), null === (i = this.responder) || void 0 === i || i.setSelectedRange(this.range), null === (n = this.responder) || void 0 === n || n.insertString(this.data.end), null === (r = this.responder) || void 0 === r ? void 0 : r.setSelectedRange(this.range[0] + this.data.end.length)) : null != this.data.start || null != this.data.update ? (this.requestReparse(), this.inputController.reset()) : void 0) : this.inputController.reset();
      var e, i, n, r;
    }
  }, {
    key: "getEndData",
    value: function getEndData() {
      return this.data.end;
    }
  }, {
    key: "isEnded",
    value: function isEnded() {
      return null != this.getEndData();
    }
  }, {
    key: "isSignificant",
    value: function isSignificant() {
      return !ur.composesExistingText || this.inputSummary.didInput;
    }
  }, {
    key: "canApplyToDocument",
    value: function canApplyToDocument() {
      var t, e;
      return 0 === (null === (t = this.data.start) || void 0 === t ? void 0 : t.length) && (null === (e = this.data.end) || void 0 === e ? void 0 : e.length) > 0 && this.range;
    }
  }]);
}(q);
vr.proxyMethod("inputController.setInputSummary"), vr.proxyMethod("inputController.requestRender"), vr.proxyMethod("inputController.requestReparse"), vr.proxyMethod("responder?.selectionIsExpanded"), vr.proxyMethod("responder?.insertPlaceholder"), vr.proxyMethod("responder?.selectPlaceholder"), vr.proxyMethod("responder?.forgetPlaceholder");
var Ar = /*#__PURE__*/function (_lr2) {
  function Ar() {
    var _this64;
    _classCallCheck(this, Ar);
    _this64 = _callSuper(this, Ar, arguments), _this64.render = _this64.render.bind(_assertThisInitialized(_this64));
    return _this64;
  }
  _inherits(Ar, _lr2);
  return _createClass(Ar, [{
    key: "elementDidMutate",
    value: function elementDidMutate() {
      return this.scheduledRender ? this.composing ? null === (t = this.delegate) || void 0 === t || null === (e = t.inputControllerDidAllowUnhandledInput) || void 0 === e ? void 0 : e.call(t) : void 0 : this.reparse();
      var t, e;
    }
  }, {
    key: "scheduleRender",
    value: function scheduleRender() {
      return this.scheduledRender ? this.scheduledRender : this.scheduledRender = requestAnimationFrame(this.render);
    }
  }, {
    key: "render",
    value: function render() {
      var t, e;
      (cancelAnimationFrame(this.scheduledRender), this.scheduledRender = null, this.composing) || null === (e = this.delegate) || void 0 === e || e.render();
      null === (t = this.afterRender) || void 0 === t || t.call(this), this.afterRender = null;
    }
  }, {
    key: "reparse",
    value: function reparse() {
      var t;
      return null === (t = this.delegate) || void 0 === t ? void 0 : t.reparse();
    }
  }, {
    key: "insertString",
    value: function insertString() {
      var t;
      var e = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : "",
        i = arguments.length > 1 ? arguments[1] : void 0;
      return null === (t = this.delegate) || void 0 === t || t.inputControllerWillPerformTyping(), this.withTargetDOMRange(function () {
        var t;
        return null === (t = this.responder) || void 0 === t ? void 0 : t.insertString(e, i);
      });
    }
  }, {
    key: "toggleAttributeIfSupported",
    value: function toggleAttributeIfSupported(t) {
      var e;
      if (gt().includes(t)) return null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformFormatting(t), this.withTargetDOMRange(function () {
        var e;
        return null === (e = this.responder) || void 0 === e ? void 0 : e.toggleCurrentAttribute(t);
      });
    }
  }, {
    key: "activateAttributeIfSupported",
    value: function activateAttributeIfSupported(t, e) {
      var i;
      if (gt().includes(t)) return null === (i = this.delegate) || void 0 === i || i.inputControllerWillPerformFormatting(t), this.withTargetDOMRange(function () {
        var i;
        return null === (i = this.responder) || void 0 === i ? void 0 : i.setCurrentAttribute(t, e);
      });
    }
  }, {
    key: "deleteInDirection",
    value: function deleteInDirection(t) {
      var _this65 = this;
      var _ref22 = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {
          recordUndoEntry: !0
        },
        e = _ref22.recordUndoEntry;
      var i;
      e && (null === (i = this.delegate) || void 0 === i || i.inputControllerWillPerformTyping());
      var n = function n() {
          var e;
          return null === (e = _this65.responder) || void 0 === e ? void 0 : e.deleteInDirection(t);
        },
        r = this.getTargetDOMRange({
          minLength: this.composing ? 1 : 2
        });
      return r ? this.withTargetDOMRange(r, n) : n();
    }
  }, {
    key: "withTargetDOMRange",
    value: function withTargetDOMRange(t, e) {
      var i;
      return "function" == typeof t && (e = t, t = this.getTargetDOMRange()), t ? null === (i = this.responder) || void 0 === i ? void 0 : i.withTargetDOMRange(t, e.bind(this)) : (Ft.reset(), e.call(this));
    }
  }, {
    key: "getTargetDOMRange",
    value: function getTargetDOMRange() {
      var t, e;
      var _ref23 = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {
          minLength: 0
        },
        i = _ref23.minLength;
      var n = null === (t = (e = this.event).getTargetRanges) || void 0 === t ? void 0 : t.call(e);
      if (n && n.length) {
        var _t57 = yr(n[0]);
        if (0 === i || _t57.toString().length >= i) return _t57;
      }
    }
  }, {
    key: "withEvent",
    value: function withEvent(t, e) {
      var i;
      this.event = t;
      try {
        i = e.call(this);
      } finally {
        this.event = null;
      }
      return i;
    }
  }]);
}(lr);
Di(Ar, "events", {
  keydown: function keydown(t) {
    if (St(t)) {
      var e;
      var _i46 = Rr(t);
      null !== (e = this.delegate) && void 0 !== e && e.inputControllerDidReceiveKeyboardCommand(_i46) && t.preventDefault();
    } else {
      var _e51 = t.key;
      t.altKey && (_e51 += "+Alt"), t.shiftKey && (_e51 += "+Shift");
      var _i47 = this.constructor.keys[_e51];
      if (_i47) return this.withEvent(t, _i47);
    }
  },
  paste: function paste(t) {
    var e;
    var i;
    var n = null === (e = t.clipboardData) || void 0 === e ? void 0 : e.getData("URL");
    return Er(t) ? (t.preventDefault(), this.attachFiles(t.clipboardData.files)) : Sr(t) ? (t.preventDefault(), i = {
      type: "text/plain",
      string: t.clipboardData.getData("text/plain")
    }, null === (r = this.delegate) || void 0 === r || r.inputControllerWillPaste(i), null === (o = this.responder) || void 0 === o || o.insertString(i.string), this.render(), null === (s = this.delegate) || void 0 === s ? void 0 : s.inputControllerDidPaste(i)) : n ? (t.preventDefault(), i = {
      type: "text/html",
      html: this.createLinkHTML(n)
    }, null === (a = this.delegate) || void 0 === a || a.inputControllerWillPaste(i), null === (l = this.responder) || void 0 === l || l.insertHTML(i.html), this.render(), null === (c = this.delegate) || void 0 === c ? void 0 : c.inputControllerDidPaste(i)) : void 0;
    var r, o, s, a, l, c;
  },
  beforeinput: function beforeinput(t) {
    var e = this.constructor.inputTypes[t.inputType],
      i = (n = t, !(!/iPhone|iPad/.test(navigator.userAgent) || n.inputType && "insertParagraph" !== n.inputType));
    var n;
    e && (this.withEvent(t, e), i || this.scheduleRender()), i && this.render();
  },
  input: function input(t) {
    Ft.reset();
  },
  dragstart: function dragstart(t) {
    var e, i;
    null !== (e = this.responder) && void 0 !== e && e.selectionContainsAttachments() && (t.dataTransfer.setData("application/x-trix-dragging", !0), this.dragging = {
      range: null === (i = this.responder) || void 0 === i ? void 0 : i.getSelectedRange(),
      point: kr(t)
    });
  },
  dragenter: function dragenter(t) {
    xr(t) && t.preventDefault();
  },
  dragover: function dragover(t) {
    if (this.dragging) {
      t.preventDefault();
      var _i48 = kr(t);
      var e;
      if (!Tt(_i48, this.dragging.point)) return this.dragging.point = _i48, null === (e = this.responder) || void 0 === e ? void 0 : e.setLocationRangeFromPointRange(_i48);
    } else xr(t) && t.preventDefault();
  },
  drop: function drop(t) {
    var e, i;
    if (this.dragging) return t.preventDefault(), null === (e = this.delegate) || void 0 === e || e.inputControllerWillMoveText(), null === (i = this.responder) || void 0 === i || i.moveTextFromRange(this.dragging.range), this.dragging = null, this.scheduleRender();
    if (xr(t)) {
      var n;
      t.preventDefault();
      var _e52 = kr(t);
      return null === (n = this.responder) || void 0 === n || n.setLocationRangeFromPointRange(_e52), this.attachFiles(t.dataTransfer.files);
    }
  },
  dragend: function dragend() {
    var t;
    this.dragging && (null === (t = this.responder) || void 0 === t || t.setSelectedRange(this.dragging.range), this.dragging = null);
  },
  compositionend: function compositionend(t) {
    this.composing && (this.composing = !1, a.recentAndroid || this.scheduleRender());
  }
}), Di(Ar, "keys", {
  ArrowLeft: function ArrowLeft() {
    var t, e;
    if (null !== (t = this.responder) && void 0 !== t && t.shouldManageMovingCursorInDirection("backward")) return this.event.preventDefault(), null === (e = this.responder) || void 0 === e ? void 0 : e.moveCursorInDirection("backward");
  },
  ArrowRight: function ArrowRight() {
    var t, e;
    if (null !== (t = this.responder) && void 0 !== t && t.shouldManageMovingCursorInDirection("forward")) return this.event.preventDefault(), null === (e = this.responder) || void 0 === e ? void 0 : e.moveCursorInDirection("forward");
  },
  Backspace: function Backspace() {
    var t, e, i;
    if (null !== (t = this.responder) && void 0 !== t && t.shouldManageDeletingInDirection("backward")) return this.event.preventDefault(), null === (e = this.delegate) || void 0 === e || e.inputControllerWillPerformTyping(), null === (i = this.responder) || void 0 === i || i.deleteInDirection("backward"), this.render();
  },
  Tab: function Tab() {
    var t, e;
    if (null !== (t = this.responder) && void 0 !== t && t.canIncreaseNestingLevel()) return this.event.preventDefault(), null === (e = this.responder) || void 0 === e || e.increaseNestingLevel(), this.render();
  },
  "Tab+Shift": function TabShift() {
    var t, e;
    if (null !== (t = this.responder) && void 0 !== t && t.canDecreaseNestingLevel()) return this.event.preventDefault(), null === (e = this.responder) || void 0 === e || e.decreaseNestingLevel(), this.render();
  }
}), Di(Ar, "inputTypes", {
  deleteByComposition: function deleteByComposition() {
    return this.deleteInDirection("backward", {
      recordUndoEntry: !1
    });
  },
  deleteByCut: function deleteByCut() {
    return this.deleteInDirection("backward");
  },
  deleteByDrag: function deleteByDrag() {
    return this.event.preventDefault(), this.withTargetDOMRange(function () {
      var t;
      this.deleteByDragRange = null === (t = this.responder) || void 0 === t ? void 0 : t.getSelectedRange();
    });
  },
  deleteCompositionText: function deleteCompositionText() {
    return this.deleteInDirection("backward", {
      recordUndoEntry: !1
    });
  },
  deleteContent: function deleteContent() {
    return this.deleteInDirection("backward");
  },
  deleteContentBackward: function deleteContentBackward() {
    return this.deleteInDirection("backward");
  },
  deleteContentForward: function deleteContentForward() {
    return this.deleteInDirection("forward");
  },
  deleteEntireSoftLine: function deleteEntireSoftLine() {
    return this.deleteInDirection("forward");
  },
  deleteHardLineBackward: function deleteHardLineBackward() {
    return this.deleteInDirection("backward");
  },
  deleteHardLineForward: function deleteHardLineForward() {
    return this.deleteInDirection("forward");
  },
  deleteSoftLineBackward: function deleteSoftLineBackward() {
    return this.deleteInDirection("backward");
  },
  deleteSoftLineForward: function deleteSoftLineForward() {
    return this.deleteInDirection("forward");
  },
  deleteWordBackward: function deleteWordBackward() {
    return this.deleteInDirection("backward");
  },
  deleteWordForward: function deleteWordForward() {
    return this.deleteInDirection("forward");
  },
  formatBackColor: function formatBackColor() {
    return this.activateAttributeIfSupported("backgroundColor", this.event.data);
  },
  formatBold: function formatBold() {
    return this.toggleAttributeIfSupported("bold");
  },
  formatFontColor: function formatFontColor() {
    return this.activateAttributeIfSupported("color", this.event.data);
  },
  formatFontName: function formatFontName() {
    return this.activateAttributeIfSupported("font", this.event.data);
  },
  formatIndent: function formatIndent() {
    var t;
    if (null !== (t = this.responder) && void 0 !== t && t.canIncreaseNestingLevel()) return this.withTargetDOMRange(function () {
      var t;
      return null === (t = this.responder) || void 0 === t ? void 0 : t.increaseNestingLevel();
    });
  },
  formatItalic: function formatItalic() {
    return this.toggleAttributeIfSupported("italic");
  },
  formatJustifyCenter: function formatJustifyCenter() {
    return this.toggleAttributeIfSupported("justifyCenter");
  },
  formatJustifyFull: function formatJustifyFull() {
    return this.toggleAttributeIfSupported("justifyFull");
  },
  formatJustifyLeft: function formatJustifyLeft() {
    return this.toggleAttributeIfSupported("justifyLeft");
  },
  formatJustifyRight: function formatJustifyRight() {
    return this.toggleAttributeIfSupported("justifyRight");
  },
  formatOutdent: function formatOutdent() {
    var t;
    if (null !== (t = this.responder) && void 0 !== t && t.canDecreaseNestingLevel()) return this.withTargetDOMRange(function () {
      var t;
      return null === (t = this.responder) || void 0 === t ? void 0 : t.decreaseNestingLevel();
    });
  },
  formatRemove: function formatRemove() {
    this.withTargetDOMRange(function () {
      for (var _i49 in null === (t = this.responder) || void 0 === t ? void 0 : t.getCurrentAttributes()) {
        var t, e;
        null === (e = this.responder) || void 0 === e || e.removeCurrentAttribute(_i49);
      }
    });
  },
  formatSetBlockTextDirection: function formatSetBlockTextDirection() {
    return this.activateAttributeIfSupported("blockDir", this.event.data);
  },
  formatSetInlineTextDirection: function formatSetInlineTextDirection() {
    return this.activateAttributeIfSupported("textDir", this.event.data);
  },
  formatStrikeThrough: function formatStrikeThrough() {
    return this.toggleAttributeIfSupported("strike");
  },
  formatSubscript: function formatSubscript() {
    return this.toggleAttributeIfSupported("sub");
  },
  formatSuperscript: function formatSuperscript() {
    return this.toggleAttributeIfSupported("sup");
  },
  formatUnderline: function formatUnderline() {
    return this.toggleAttributeIfSupported("underline");
  },
  historyRedo: function historyRedo() {
    var t;
    return null === (t = this.delegate) || void 0 === t ? void 0 : t.inputControllerWillPerformRedo();
  },
  historyUndo: function historyUndo() {
    var t;
    return null === (t = this.delegate) || void 0 === t ? void 0 : t.inputControllerWillPerformUndo();
  },
  insertCompositionText: function insertCompositionText() {
    return this.composing = !0, this.insertString(this.event.data);
  },
  insertFromComposition: function insertFromComposition() {
    return this.composing = !1, this.insertString(this.event.data);
  },
  insertFromDrop: function insertFromDrop() {
    var t = this.deleteByDragRange;
    var e;
    if (t) return this.deleteByDragRange = null, null === (e = this.delegate) || void 0 === e || e.inputControllerWillMoveText(), this.withTargetDOMRange(function () {
      var e;
      return null === (e = this.responder) || void 0 === e ? void 0 : e.moveTextFromRange(t);
    });
  },
  insertFromPaste: function insertFromPaste() {
    var _this66 = this;
    var t = this.event.dataTransfer,
      e = {
        dataTransfer: t
      },
      i = t.getData("URL"),
      n = t.getData("text/html");
    if (i) {
      var r;
      var _n30;
      this.event.preventDefault(), e.type = "text/html";
      var _o1 = t.getData("public.url-name");
      _n30 = _o1 ? Vt(_o1).trim() : i, e.html = this.createLinkHTML(i, _n30), null === (r = this.delegate) || void 0 === r || r.inputControllerWillPaste(e), this.withTargetDOMRange(function () {
        var t;
        return null === (t = this.responder) || void 0 === t ? void 0 : t.insertHTML(e.html);
      }), this.afterRender = function () {
        var t;
        return null === (t = _this66.delegate) || void 0 === t ? void 0 : t.inputControllerDidPaste(e);
      };
    } else if (Et(t)) {
      var o;
      e.type = "text/plain", e.string = t.getData("text/plain"), null === (o = this.delegate) || void 0 === o || o.inputControllerWillPaste(e), this.withTargetDOMRange(function () {
        var t;
        return null === (t = this.responder) || void 0 === t ? void 0 : t.insertString(e.string);
      }), this.afterRender = function () {
        var t;
        return null === (t = _this66.delegate) || void 0 === t ? void 0 : t.inputControllerDidPaste(e);
      };
    } else if (Cr(this.event)) {
      var s;
      e.type = "File", e.file = t.files[0], null === (s = this.delegate) || void 0 === s || s.inputControllerWillPaste(e), this.withTargetDOMRange(function () {
        var t;
        return null === (t = this.responder) || void 0 === t ? void 0 : t.insertFile(e.file);
      }), this.afterRender = function () {
        var t;
        return null === (t = _this66.delegate) || void 0 === t ? void 0 : t.inputControllerDidPaste(e);
      };
    } else if (n) {
      var a;
      this.event.preventDefault(), e.type = "text/html", e.html = n, null === (a = this.delegate) || void 0 === a || a.inputControllerWillPaste(e), this.withTargetDOMRange(function () {
        var t;
        return null === (t = this.responder) || void 0 === t ? void 0 : t.insertHTML(e.html);
      }), this.afterRender = function () {
        var t;
        return null === (t = _this66.delegate) || void 0 === t ? void 0 : t.inputControllerDidPaste(e);
      };
    }
  },
  insertFromYank: function insertFromYank() {
    return this.insertString(this.event.data);
  },
  insertLineBreak: function insertLineBreak() {
    return this.insertString("\n");
  },
  insertLink: function insertLink() {
    return this.activateAttributeIfSupported("href", this.event.data);
  },
  insertOrderedList: function insertOrderedList() {
    return this.toggleAttributeIfSupported("number");
  },
  insertParagraph: function insertParagraph() {
    var t;
    return null === (t = this.delegate) || void 0 === t || t.inputControllerWillPerformTyping(), this.withTargetDOMRange(function () {
      var t;
      return null === (t = this.responder) || void 0 === t ? void 0 : t.insertLineBreak();
    });
  },
  insertReplacementText: function insertReplacementText() {
    var _this67 = this;
    var t = this.event.dataTransfer.getData("text/plain"),
      e = this.event.getTargetRanges()[0];
    this.withTargetDOMRange(e, function () {
      _this67.insertString(t, {
        updatePosition: !1
      });
    });
  },
  insertText: function insertText() {
    var t;
    return this.insertString(this.event.data || (null === (t = this.event.dataTransfer) || void 0 === t ? void 0 : t.getData("text/plain")));
  },
  insertTranspose: function insertTranspose() {
    return this.insertString(this.event.data);
  },
  insertUnorderedList: function insertUnorderedList() {
    return this.toggleAttributeIfSupported("bullet");
  }
});
var yr = function yr(t) {
    var e = document.createRange();
    return e.setStart(t.startContainer, t.startOffset), e.setEnd(t.endContainer, t.endOffset), e;
  },
  xr = function xr(t) {
    var e;
    return Array.from((null === (e = t.dataTransfer) || void 0 === e ? void 0 : e.types) || []).includes("Files");
  },
  Cr = function Cr(t) {
    var e;
    return (null === (e = t.dataTransfer.files) || void 0 === e ? void 0 : e[0]) && !Er(t) && !function (t) {
      var e = t.dataTransfer;
      return e.types.includes("Files") && e.types.includes("text/html") && e.getData("text/html").includes("urn:schemas-microsoft-com:office:office");
    }(t);
  },
  Er = function Er(t) {
    var e = t.clipboardData;
    if (e) {
      return Array.from(e.types).filter(function (t) {
        return t.match(/file/i);
      }).length === e.types.length && e.files.length >= 1;
    }
  },
  Sr = function Sr(t) {
    var e = t.clipboardData;
    if (e) return e.types.includes("text/plain") && 1 === e.types.length;
  },
  Rr = function Rr(t) {
    var e = [];
    return t.altKey && e.push("alt"), t.shiftKey && e.push("shift"), e.push(t.key), e;
  },
  kr = function kr(t) {
    return {
      x: t.clientX,
      y: t.clientY
    };
  },
  Tr = "[data-trix-attribute]",
  wr = "[data-trix-action]",
  Lr = "".concat(Tr, ", ").concat(wr),
  Dr = "[data-trix-dialog]",
  Nr = "".concat(Dr, "[data-trix-active]"),
  Ir = "".concat(Dr, " [data-trix-method]"),
  Or = "".concat(Dr, " [data-trix-input]"),
  Fr = function Fr(t, e) {
    return e || (e = Mr(t)), t.querySelector("[data-trix-input][name='".concat(e, "']"));
  },
  Pr = function Pr(t) {
    return t.getAttribute("data-trix-action");
  },
  Mr = function Mr(t) {
    return t.getAttribute("data-trix-attribute") || t.getAttribute("data-trix-dialog-attribute");
  };
var Br = /*#__PURE__*/function (_q18) {
  function Br(t) {
    var _this68;
    _classCallCheck(this, Br);
    _this68 = _callSuper(this, Br, [t]), _this68.didClickActionButton = _this68.didClickActionButton.bind(_assertThisInitialized(_this68)), _this68.didClickAttributeButton = _this68.didClickAttributeButton.bind(_assertThisInitialized(_this68)), _this68.didClickDialogButton = _this68.didClickDialogButton.bind(_assertThisInitialized(_this68)), _this68.didKeyDownDialogInput = _this68.didKeyDownDialogInput.bind(_assertThisInitialized(_this68)), _this68.element = t, _this68.attributes = {}, _this68.actions = {}, _this68.resetDialogInputs(), b("mousedown", {
      onElement: _this68.element,
      matchingSelector: wr,
      withCallback: _this68.didClickActionButton
    }), b("mousedown", {
      onElement: _this68.element,
      matchingSelector: Tr,
      withCallback: _this68.didClickAttributeButton
    }), b("click", {
      onElement: _this68.element,
      matchingSelector: Lr,
      preventDefault: !0
    }), b("click", {
      onElement: _this68.element,
      matchingSelector: Ir,
      withCallback: _this68.didClickDialogButton
    }), b("keydown", {
      onElement: _this68.element,
      matchingSelector: Or,
      withCallback: _this68.didKeyDownDialogInput
    });
    return _this68;
  }
  _inherits(Br, _q18);
  return _createClass(Br, [{
    key: "didClickActionButton",
    value: function didClickActionButton(t, e) {
      var i;
      null === (i = this.delegate) || void 0 === i || i.toolbarDidClickButton(), t.preventDefault();
      var n = Pr(e);
      return this.getDialog(n) ? this.toggleDialog(n) : null === (r = this.delegate) || void 0 === r ? void 0 : r.toolbarDidInvokeAction(n, e);
      var r;
    }
  }, {
    key: "didClickAttributeButton",
    value: function didClickAttributeButton(t, e) {
      var i;
      null === (i = this.delegate) || void 0 === i || i.toolbarDidClickButton(), t.preventDefault();
      var n = Mr(e);
      var r;
      this.getDialog(n) ? this.toggleDialog(n) : null === (r = this.delegate) || void 0 === r || r.toolbarDidToggleAttribute(n);
      return this.refreshAttributeButtons();
    }
  }, {
    key: "didClickDialogButton",
    value: function didClickDialogButton(t, e) {
      var i = y(e, {
        matchingSelector: Dr
      });
      return this[e.getAttribute("data-trix-method")].call(this, i);
    }
  }, {
    key: "didKeyDownDialogInput",
    value: function didKeyDownDialogInput(t, e) {
      if (13 === t.keyCode) {
        t.preventDefault();
        var _i50 = e.getAttribute("name"),
          _n31 = this.getDialog(_i50);
        this.setAttribute(_n31);
      }
      if (27 === t.keyCode) return t.preventDefault(), this.hideDialog();
    }
  }, {
    key: "updateActions",
    value: function updateActions(t) {
      return this.actions = t, this.refreshActionButtons();
    }
  }, {
    key: "refreshActionButtons",
    value: function refreshActionButtons() {
      var _this69 = this;
      return this.eachActionButton(function (t, e) {
        t.disabled = !1 === _this69.actions[e];
      });
    }
  }, {
    key: "eachActionButton",
    value: function eachActionButton(t) {
      return Array.from(this.element.querySelectorAll(wr)).map(function (e) {
        return t(e, Pr(e));
      });
    }
  }, {
    key: "updateAttributes",
    value: function updateAttributes(t) {
      return this.attributes = t, this.refreshAttributeButtons();
    }
  }, {
    key: "refreshAttributeButtons",
    value: function refreshAttributeButtons() {
      var _this70 = this;
      return this.eachAttributeButton(function (t, e) {
        return t.disabled = !1 === _this70.attributes[e], _this70.attributes[e] || _this70.dialogIsVisible(e) ? (t.setAttribute("data-trix-active", ""), t.classList.add("trix-active")) : (t.removeAttribute("data-trix-active"), t.classList.remove("trix-active"));
      });
    }
  }, {
    key: "eachAttributeButton",
    value: function eachAttributeButton(t) {
      return Array.from(this.element.querySelectorAll(Tr)).map(function (e) {
        return t(e, Mr(e));
      });
    }
  }, {
    key: "applyKeyboardCommand",
    value: function applyKeyboardCommand(t) {
      var e = JSON.stringify(t.sort());
      for (var _i51 = 0, _Array$from20 = Array.from(this.element.querySelectorAll("[data-trix-key]")); _i51 < _Array$from20.length; _i51++) {
        var _t58 = _Array$from20[_i51];
        var _i52 = _t58.getAttribute("data-trix-key").split("+");
        if (JSON.stringify(_i52.sort()) === e) return v("mousedown", {
          onElement: _t58
        }), !0;
      }
      return !1;
    }
  }, {
    key: "dialogIsVisible",
    value: function dialogIsVisible(t) {
      var e = this.getDialog(t);
      if (e) return e.hasAttribute("data-trix-active");
    }
  }, {
    key: "toggleDialog",
    value: function toggleDialog(t) {
      return this.dialogIsVisible(t) ? this.hideDialog() : this.showDialog(t);
    }
  }, {
    key: "showDialog",
    value: function showDialog(t) {
      var e, i;
      this.hideDialog(), null === (e = this.delegate) || void 0 === e || e.toolbarWillShowDialog();
      var n = this.getDialog(t);
      n.setAttribute("data-trix-active", ""), n.classList.add("trix-active"), Array.from(n.querySelectorAll("input[disabled]")).forEach(function (t) {
        t.removeAttribute("disabled");
      });
      var r = Mr(n);
      if (r) {
        var _e53 = Fr(n, t);
        _e53 && (_e53.value = this.attributes[r] || "", _e53.select());
      }
      return null === (i = this.delegate) || void 0 === i ? void 0 : i.toolbarDidShowDialog(t);
    }
  }, {
    key: "setAttribute",
    value: function setAttribute(t) {
      var e;
      var i = Mr(t),
        n = Fr(t, i);
      return !n.willValidate || (n.setCustomValidity(""), n.checkValidity() && this.isSafeAttribute(n)) ? (null === (e = this.delegate) || void 0 === e || e.toolbarDidUpdateAttribute(i, n.value), this.hideDialog()) : (n.setCustomValidity("Invalid value"), n.setAttribute("data-trix-validate", ""), n.classList.add("trix-validate"), n.focus());
    }
  }, {
    key: "isSafeAttribute",
    value: function isSafeAttribute(t) {
      return !t.hasAttribute("data-trix-validate-href") || li.isValidAttribute("a", "href", t.value);
    }
  }, {
    key: "removeAttribute",
    value: function removeAttribute(t) {
      var e;
      var i = Mr(t);
      return null === (e = this.delegate) || void 0 === e || e.toolbarDidRemoveAttribute(i), this.hideDialog();
    }
  }, {
    key: "hideDialog",
    value: function hideDialog() {
      var t = this.element.querySelector(Nr);
      var e;
      if (t) return t.removeAttribute("data-trix-active"), t.classList.remove("trix-active"), this.resetDialogInputs(), null === (e = this.delegate) || void 0 === e ? void 0 : e.toolbarDidHideDialog(function (t) {
        return t.getAttribute("data-trix-dialog");
      }(t));
    }
  }, {
    key: "resetDialogInputs",
    value: function resetDialogInputs() {
      Array.from(this.element.querySelectorAll(Or)).forEach(function (t) {
        t.setAttribute("disabled", "disabled"), t.removeAttribute("data-trix-validate"), t.classList.remove("trix-validate");
      });
    }
  }, {
    key: "getDialog",
    value: function getDialog(t) {
      return this.element.querySelector("[data-trix-dialog=".concat(t, "]"));
    }
  }]);
}(q);
var _r = /*#__PURE__*/function (_Xn) {
  function _r(t) {
    var _this71;
    _classCallCheck(this, _r);
    var e = t.editorElement,
      i = t.document,
      n = t.html;
    _this71 = _callSuper(this, _r, arguments), _this71.editorElement = e, _this71.selectionManager = new Vn(_this71.editorElement), _this71.selectionManager.delegate = _assertThisInitialized(_this71), _this71.composition = new wn(), _this71.composition.delegate = _assertThisInitialized(_this71), _this71.attachmentManager = new kn(_this71.composition.getAttachments()), _this71.attachmentManager.delegate = _assertThisInitialized(_this71), _this71.inputController = 2 === _.getLevel() ? new Ar(_this71.editorElement) : new gr(_this71.editorElement), _this71.inputController.delegate = _assertThisInitialized(_this71), _this71.inputController.responder = _this71.composition, _this71.compositionController = new $n(_this71.editorElement, _this71.composition), _this71.compositionController.delegate = _assertThisInitialized(_this71), _this71.toolbarController = new Br(_this71.editorElement.toolbarElement), _this71.toolbarController.delegate = _assertThisInitialized(_this71), _this71.editor = new Pn(_this71.composition, _this71.selectionManager, _this71.editorElement), i ? _this71.editor.loadDocument(i) : _this71.editor.loadHTML(n);
    return _this71;
  }
  _inherits(_r, _Xn);
  return _createClass(_r, [{
    key: "registerSelectionManager",
    value: function registerSelectionManager() {
      return Ft.registerSelectionManager(this.selectionManager);
    }
  }, {
    key: "unregisterSelectionManager",
    value: function unregisterSelectionManager() {
      return Ft.unregisterSelectionManager(this.selectionManager);
    }
  }, {
    key: "render",
    value: function render() {
      return this.compositionController.render();
    }
  }, {
    key: "reparse",
    value: function reparse() {
      return this.composition.replaceHTML(this.editorElement.innerHTML);
    }
  }, {
    key: "compositionDidChangeDocument",
    value: function compositionDidChangeDocument(t) {
      if (this.notifyEditorElement("document-change"), !this.handlingInput) return this.render();
    }
  }, {
    key: "compositionDidChangeCurrentAttributes",
    value: function compositionDidChangeCurrentAttributes(t) {
      return this.currentAttributes = t, this.toolbarController.updateAttributes(this.currentAttributes), this.updateCurrentActions(), this.notifyEditorElement("attributes-change", {
        attributes: this.currentAttributes
      });
    }
  }, {
    key: "compositionDidPerformInsertionAtRange",
    value: function compositionDidPerformInsertionAtRange(t) {
      this.pasting && (this.pastedRange = t);
    }
  }, {
    key: "compositionShouldAcceptFile",
    value: function compositionShouldAcceptFile(t) {
      return this.notifyEditorElement("file-accept", {
        file: t
      });
    }
  }, {
    key: "compositionDidAddAttachment",
    value: function compositionDidAddAttachment(t) {
      var e = this.attachmentManager.manageAttachment(t);
      return this.notifyEditorElement("attachment-add", {
        attachment: e
      });
    }
  }, {
    key: "compositionDidEditAttachment",
    value: function compositionDidEditAttachment(t) {
      this.compositionController.rerenderViewForObject(t);
      var e = this.attachmentManager.manageAttachment(t);
      return this.notifyEditorElement("attachment-edit", {
        attachment: e
      }), this.notifyEditorElement("change");
    }
  }, {
    key: "compositionDidChangeAttachmentPreviewURL",
    value: function compositionDidChangeAttachmentPreviewURL(t) {
      return this.compositionController.invalidateViewForObject(t), this.notifyEditorElement("change");
    }
  }, {
    key: "compositionDidRemoveAttachment",
    value: function compositionDidRemoveAttachment(t) {
      var e = this.attachmentManager.unmanageAttachment(t);
      return this.notifyEditorElement("attachment-remove", {
        attachment: e
      });
    }
  }, {
    key: "compositionDidStartEditingAttachment",
    value: function compositionDidStartEditingAttachment(t, e) {
      return this.attachmentLocationRange = this.composition.document.getLocationRangeOfAttachment(t), this.compositionController.installAttachmentEditorForAttachment(t, e), this.selectionManager.setLocationRange(this.attachmentLocationRange);
    }
  }, {
    key: "compositionDidStopEditingAttachment",
    value: function compositionDidStopEditingAttachment(t) {
      this.compositionController.uninstallAttachmentEditor(), this.attachmentLocationRange = null;
    }
  }, {
    key: "compositionDidRequestChangingSelectionToLocationRange",
    value: function compositionDidRequestChangingSelectionToLocationRange(t) {
      if (!this.loadingSnapshot || this.isFocused()) return this.requestedLocationRange = t, this.compositionRevisionWhenLocationRangeRequested = this.composition.revision, this.handlingInput ? void 0 : this.render();
    }
  }, {
    key: "compositionWillLoadSnapshot",
    value: function compositionWillLoadSnapshot() {
      this.loadingSnapshot = !0;
    }
  }, {
    key: "compositionDidLoadSnapshot",
    value: function compositionDidLoadSnapshot() {
      this.compositionController.refreshViewCache(), this.render(), this.loadingSnapshot = !1;
    }
  }, {
    key: "getSelectionManager",
    value: function getSelectionManager() {
      return this.selectionManager;
    }
  }, {
    key: "attachmentManagerDidRequestRemovalOfAttachment",
    value: function attachmentManagerDidRequestRemovalOfAttachment(t) {
      return this.removeAttachment(t);
    }
  }, {
    key: "compositionControllerWillSyncDocumentView",
    value: function compositionControllerWillSyncDocumentView() {
      return this.inputController.editorWillSyncDocumentView(), this.selectionManager.lock(), this.selectionManager.clearSelection();
    }
  }, {
    key: "compositionControllerDidSyncDocumentView",
    value: function compositionControllerDidSyncDocumentView() {
      return this.inputController.editorDidSyncDocumentView(), this.selectionManager.unlock(), this.updateCurrentActions(), this.notifyEditorElement("sync");
    }
  }, {
    key: "compositionControllerDidRender",
    value: function compositionControllerDidRender() {
      this.requestedLocationRange && (this.compositionRevisionWhenLocationRangeRequested === this.composition.revision && this.selectionManager.setLocationRange(this.requestedLocationRange), this.requestedLocationRange = null, this.compositionRevisionWhenLocationRangeRequested = null), this.renderedCompositionRevision !== this.composition.revision && (this.runEditorFilters(), this.composition.updateCurrentAttributes(), this.notifyEditorElement("render")), this.renderedCompositionRevision = this.composition.revision;
    }
  }, {
    key: "compositionControllerDidFocus",
    value: function compositionControllerDidFocus() {
      return this.isFocusedInvisibly() && this.setLocationRange({
        index: 0,
        offset: 0
      }), this.toolbarController.hideDialog(), this.notifyEditorElement("focus");
    }
  }, {
    key: "compositionControllerDidBlur",
    value: function compositionControllerDidBlur() {
      return this.notifyEditorElement("blur");
    }
  }, {
    key: "compositionControllerDidSelectAttachment",
    value: function compositionControllerDidSelectAttachment(t, e) {
      return this.toolbarController.hideDialog(), this.composition.editAttachment(t, e);
    }
  }, {
    key: "compositionControllerDidRequestDeselectingAttachment",
    value: function compositionControllerDidRequestDeselectingAttachment(t) {
      var e = this.attachmentLocationRange || this.composition.document.getLocationRangeOfAttachment(t);
      return this.selectionManager.setLocationRange(e[1]);
    }
  }, {
    key: "compositionControllerWillUpdateAttachment",
    value: function compositionControllerWillUpdateAttachment(t) {
      return this.editor.recordUndoEntry("Edit Attachment", {
        context: t.id,
        consolidatable: !0
      });
    }
  }, {
    key: "compositionControllerDidRequestRemovalOfAttachment",
    value: function compositionControllerDidRequestRemovalOfAttachment(t) {
      return this.removeAttachment(t);
    }
  }, {
    key: "inputControllerWillHandleInput",
    value: function inputControllerWillHandleInput() {
      this.handlingInput = !0, this.requestedRender = !1;
    }
  }, {
    key: "inputControllerDidRequestRender",
    value: function inputControllerDidRequestRender() {
      this.requestedRender = !0;
    }
  }, {
    key: "inputControllerDidHandleInput",
    value: function inputControllerDidHandleInput() {
      if (this.handlingInput = !1, this.requestedRender) return this.requestedRender = !1, this.render();
    }
  }, {
    key: "inputControllerDidAllowUnhandledInput",
    value: function inputControllerDidAllowUnhandledInput() {
      return this.notifyEditorElement("change");
    }
  }, {
    key: "inputControllerDidRequestReparse",
    value: function inputControllerDidRequestReparse() {
      return this.reparse();
    }
  }, {
    key: "inputControllerWillPerformTyping",
    value: function inputControllerWillPerformTyping() {
      return this.recordTypingUndoEntry();
    }
  }, {
    key: "inputControllerWillPerformFormatting",
    value: function inputControllerWillPerformFormatting(t) {
      return this.recordFormattingUndoEntry(t);
    }
  }, {
    key: "inputControllerWillCutText",
    value: function inputControllerWillCutText() {
      return this.editor.recordUndoEntry("Cut");
    }
  }, {
    key: "inputControllerWillPaste",
    value: function inputControllerWillPaste(t) {
      return this.editor.recordUndoEntry("Paste"), this.pasting = !0, this.notifyEditorElement("before-paste", {
        paste: t
      });
    }
  }, {
    key: "inputControllerDidPaste",
    value: function inputControllerDidPaste(t) {
      return t.range = this.pastedRange, this.pastedRange = null, this.pasting = null, this.notifyEditorElement("paste", {
        paste: t
      });
    }
  }, {
    key: "inputControllerWillMoveText",
    value: function inputControllerWillMoveText() {
      return this.editor.recordUndoEntry("Move");
    }
  }, {
    key: "inputControllerWillAttachFiles",
    value: function inputControllerWillAttachFiles() {
      return this.editor.recordUndoEntry("Drop Files");
    }
  }, {
    key: "inputControllerWillPerformUndo",
    value: function inputControllerWillPerformUndo() {
      return this.editor.undo();
    }
  }, {
    key: "inputControllerWillPerformRedo",
    value: function inputControllerWillPerformRedo() {
      return this.editor.redo();
    }
  }, {
    key: "inputControllerDidReceiveKeyboardCommand",
    value: function inputControllerDidReceiveKeyboardCommand(t) {
      return this.toolbarController.applyKeyboardCommand(t);
    }
  }, {
    key: "inputControllerDidStartDrag",
    value: function inputControllerDidStartDrag() {
      this.locationRangeBeforeDrag = this.selectionManager.getLocationRange();
    }
  }, {
    key: "inputControllerDidReceiveDragOverPoint",
    value: function inputControllerDidReceiveDragOverPoint(t) {
      return this.selectionManager.setLocationRangeFromPointRange(t);
    }
  }, {
    key: "inputControllerDidCancelDrag",
    value: function inputControllerDidCancelDrag() {
      this.selectionManager.setLocationRange(this.locationRangeBeforeDrag), this.locationRangeBeforeDrag = null;
    }
  }, {
    key: "locationRangeDidChange",
    value: function locationRangeDidChange(t) {
      return this.composition.updateCurrentAttributes(), this.updateCurrentActions(), this.attachmentLocationRange && !Dt(this.attachmentLocationRange, t) && this.composition.stopEditingAttachment(), this.notifyEditorElement("selection-change");
    }
  }, {
    key: "toolbarDidClickButton",
    value: function toolbarDidClickButton() {
      if (!this.getLocationRange()) return this.setLocationRange({
        index: 0,
        offset: 0
      });
    }
  }, {
    key: "toolbarDidInvokeAction",
    value: function toolbarDidInvokeAction(t, e) {
      return this.invokeAction(t, e);
    }
  }, {
    key: "toolbarDidToggleAttribute",
    value: function toolbarDidToggleAttribute(t) {
      if (this.recordFormattingUndoEntry(t), this.composition.toggleCurrentAttribute(t), this.render(), !this.selectionFrozen) return this.editorElement.focus();
    }
  }, {
    key: "toolbarDidUpdateAttribute",
    value: function toolbarDidUpdateAttribute(t, e) {
      if (this.recordFormattingUndoEntry(t), this.composition.setCurrentAttribute(t, e), this.render(), !this.selectionFrozen) return this.editorElement.focus();
    }
  }, {
    key: "toolbarDidRemoveAttribute",
    value: function toolbarDidRemoveAttribute(t) {
      if (this.recordFormattingUndoEntry(t), this.composition.removeCurrentAttribute(t), this.render(), !this.selectionFrozen) return this.editorElement.focus();
    }
  }, {
    key: "toolbarWillShowDialog",
    value: function toolbarWillShowDialog(t) {
      return this.composition.expandSelectionForEditing(), this.freezeSelection();
    }
  }, {
    key: "toolbarDidShowDialog",
    value: function toolbarDidShowDialog(t) {
      return this.notifyEditorElement("toolbar-dialog-show", {
        dialogName: t
      });
    }
  }, {
    key: "toolbarDidHideDialog",
    value: function toolbarDidHideDialog(t) {
      return this.thawSelection(), this.editorElement.focus(), this.notifyEditorElement("toolbar-dialog-hide", {
        dialogName: t
      });
    }
  }, {
    key: "freezeSelection",
    value: function freezeSelection() {
      if (!this.selectionFrozen) return this.selectionManager.lock(), this.composition.freezeSelection(), this.selectionFrozen = !0, this.render();
    }
  }, {
    key: "thawSelection",
    value: function thawSelection() {
      if (this.selectionFrozen) return this.composition.thawSelection(), this.selectionManager.unlock(), this.selectionFrozen = !1, this.render();
    }
  }, {
    key: "canInvokeAction",
    value: function canInvokeAction(t) {
      return !!this.actionIsExternal(t) || !(null === (e = this.actions[t]) || void 0 === e || null === (e = e.test) || void 0 === e || !e.call(this));
      var e;
    }
  }, {
    key: "invokeAction",
    value: function invokeAction(t, e) {
      return this.actionIsExternal(t) ? this.notifyEditorElement("action-invoke", {
        actionName: t,
        invokingElement: e
      }) : null === (i = this.actions[t]) || void 0 === i || null === (i = i.perform) || void 0 === i ? void 0 : i.call(this);
      var i;
    }
  }, {
    key: "actionIsExternal",
    value: function actionIsExternal(t) {
      return /^x-./.test(t);
    }
  }, {
    key: "getCurrentActions",
    value: function getCurrentActions() {
      var t = {};
      for (var _e54 in this.actions) t[_e54] = this.canInvokeAction(_e54);
      return t;
    }
  }, {
    key: "updateCurrentActions",
    value: function updateCurrentActions() {
      var t = this.getCurrentActions();
      if (!Tt(t, this.currentActions)) return this.currentActions = t, this.toolbarController.updateActions(this.currentActions), this.notifyEditorElement("actions-change", {
        actions: this.currentActions
      });
    }
  }, {
    key: "runEditorFilters",
    value: function runEditorFilters() {
      var _this72 = this;
      var t = this.composition.getSnapshot();
      if (Array.from(this.editor.filters).forEach(function (e) {
        var _t59 = t,
          i = _t59.document,
          n = _t59.selectedRange;
        t = e.call(_this72.editor, t) || {}, t.document || (t.document = i), t.selectedRange || (t.selectedRange = n);
      }), e = t, i = this.composition.getSnapshot(), !Dt(e.selectedRange, i.selectedRange) || !e.document.isEqualTo(i.document)) return this.composition.loadSnapshot(t);
      var e, i;
    }
  }, {
    key: "updateInputElement",
    value: function updateInputElement() {
      var t = function (t, e) {
        var i = En[e];
        if (i) return i(t);
        throw new Error("unknown content type: ".concat(e));
      }(this.compositionController.getSerializableElement(), "text/html");
      return this.editorElement.setFormValue(t);
    }
  }, {
    key: "notifyEditorElement",
    value: function notifyEditorElement(t, e) {
      switch (t) {
        case "document-change":
          this.documentChangedSinceLastRender = !0;
          break;
        case "render":
          this.documentChangedSinceLastRender && (this.documentChangedSinceLastRender = !1, this.notifyEditorElement("change"));
          break;
        case "change":
        case "attachment-add":
        case "attachment-edit":
        case "attachment-remove":
          this.updateInputElement();
      }
      return this.editorElement.notify(t, e);
    }
  }, {
    key: "removeAttachment",
    value: function removeAttachment(t) {
      return this.editor.recordUndoEntry("Delete Attachment"), this.composition.removeAttachment(t), this.render();
    }
  }, {
    key: "recordFormattingUndoEntry",
    value: function recordFormattingUndoEntry(t) {
      var e = mt(t),
        i = this.selectionManager.getLocationRange();
      if (e || !Lt(i)) return this.editor.recordUndoEntry("Formatting", {
        context: this.getUndoContext(),
        consolidatable: !0
      });
    }
  }, {
    key: "recordTypingUndoEntry",
    value: function recordTypingUndoEntry() {
      return this.editor.recordUndoEntry("Typing", {
        context: this.getUndoContext(this.currentAttributes),
        consolidatable: !0
      });
    }
  }, {
    key: "getUndoContext",
    value: function getUndoContext() {
      for (var t = arguments.length, e = new Array(t), i = 0; i < t; i++) e[i] = arguments[i];
      return [this.getLocationContext(), this.getTimeContext()].concat(_toConsumableArray(Array.from(e)));
    }
  }, {
    key: "getLocationContext",
    value: function getLocationContext() {
      var t = this.selectionManager.getLocationRange();
      return Lt(t) ? t[0].index : t;
    }
  }, {
    key: "getTimeContext",
    value: function getTimeContext() {
      return V.interval > 0 ? Math.floor(new Date().getTime() / V.interval) : 0;
    }
  }, {
    key: "isFocused",
    value: function isFocused() {
      var t;
      return this.editorElement === (null === (t = this.editorElement.ownerDocument) || void 0 === t ? void 0 : t.activeElement);
    }
  }, {
    key: "isFocusedInvisibly",
    value: function isFocusedInvisibly() {
      return this.isFocused() && !this.getLocationRange();
    }
  }, {
    key: "actions",
    get: function get() {
      return this.constructor.actions;
    }
  }]);
}(Xn);
Di(_r, "actions", {
  undo: {
    test: function test() {
      return this.editor.canUndo();
    },
    perform: function perform() {
      return this.editor.undo();
    }
  },
  redo: {
    test: function test() {
      return this.editor.canRedo();
    },
    perform: function perform() {
      return this.editor.redo();
    }
  },
  link: {
    test: function test() {
      return this.editor.canActivateAttribute("href");
    }
  },
  increaseNestingLevel: {
    test: function test() {
      return this.editor.canIncreaseNestingLevel();
    },
    perform: function perform() {
      return this.editor.increaseNestingLevel() && this.render();
    }
  },
  decreaseNestingLevel: {
    test: function test() {
      return this.editor.canDecreaseNestingLevel();
    },
    perform: function perform() {
      return this.editor.decreaseNestingLevel() && this.render();
    }
  },
  attachFiles: {
    test: function test() {
      return !0;
    },
    perform: function perform() {
      return _.pickFiles(this.editor.insertFiles);
    }
  }
}), _r.proxyMethod("getSelectionManager().setLocationRange"), _r.proxyMethod("getSelectionManager().getLocationRange");
var jr = Object.freeze({
    __proto__: null,
    AttachmentEditorController: Yn,
    CompositionController: $n,
    Controller: Xn,
    EditorController: _r,
    InputController: lr,
    Level0InputController: gr,
    Level2InputController: Ar,
    ToolbarController: Br
  }),
  Wr = Object.freeze({
    __proto__: null,
    MutationObserver: er,
    SelectionChangeObserver: Ot
  }),
  Ur = Object.freeze({
    __proto__: null,
    FileVerificationOperation: nr,
    ImagePreloadOperation: Ui
  });
vt("trix-toolbar", "%t {\n  display: block;\n}\n\n%t {\n  white-space: nowrap;\n}\n\n%t [data-trix-dialog] {\n  display: none;\n}\n\n%t [data-trix-dialog][data-trix-active] {\n  display: block;\n}\n\n%t [data-trix-dialog] [data-trix-validate]:invalid {\n  background-color: #ffdddd;\n}");
var Vr = /*#__PURE__*/function (_HTMLElement) {
  function Vr() {
    _classCallCheck(this, Vr);
    return _callSuper(this, Vr, arguments);
  }
  _inherits(Vr, _HTMLElement);
  return _createClass(Vr, [{
    key: "connectedCallback",
    value: function connectedCallback() {
      "" === this.innerHTML && (this.innerHTML = U.getDefaultHTML());
    }
  }]);
}(/*#__PURE__*/_wrapNativeSuper(HTMLElement));
var zr = 0;
var qr = function qr(t) {
    if (!t.hasAttribute("contenteditable")) return t.setAttribute("contenteditable", ""), function (t) {
      var e = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : {};
      return e.times = 1, b(t, e);
    }("focus", {
      onElement: t,
      withCallback: function withCallback() {
        return Hr(t);
      }
    });
  },
  Hr = function Hr(t) {
    return Jr(t), Kr(t);
  },
  Jr = function Jr(t) {
    var e, i;
    if (null !== (e = (i = document).queryCommandSupported) && void 0 !== e && e.call(i, "enableObjectResizing")) return document.execCommand("enableObjectResizing", !1, !1), b("mscontrolselect", {
      onElement: t,
      preventDefault: !0
    });
  },
  Kr = function Kr(t) {
    var e, i;
    if (null !== (e = (i = document).queryCommandSupported) && void 0 !== e && e.call(i, "DefaultParagraphSeparator")) {
      var _t60 = n["default"].tagName;
      if (["div", "p"].includes(_t60)) return document.execCommand("DefaultParagraphSeparator", !1, _t60);
    }
  },
  Gr = a.forcesObjectResizing ? {
    display: "inline",
    width: "auto"
  } : {
    display: "inline-block",
    width: "1px"
  };
vt("trix-editor", "%t {\n    display: block;\n}\n\n%t:empty::before {\n    content: attr(placeholder);\n    color: graytext;\n    cursor: text;\n    pointer-events: none;\n    white-space: pre-line;\n}\n\n%t a[contenteditable=false] {\n    cursor: text;\n}\n\n%t img {\n    max-width: 100%;\n    height: auto;\n}\n\n%t ".concat(e, " figcaption textarea {\n    resize: none;\n}\n\n%t ").concat(e, " figcaption textarea.trix-autoresize-clone {\n    position: absolute;\n    left: -9999px;\n    max-height: 0px;\n}\n\n%t ").concat(e, " figcaption[data-trix-placeholder]:empty::before {\n    content: attr(data-trix-placeholder);\n    color: graytext;\n}\n\n%t [data-trix-cursor-target] {\n    display: ").concat(Gr.display, " !important;\n    width: ").concat(Gr.width, " !important;\n    padding: 0 !important;\n    margin: 0 !important;\n    border: none !important;\n}\n\n%t [data-trix-cursor-target=left] {\n    vertical-align: top !important;\n    margin-left: -1px !important;\n}\n\n%t [data-trix-cursor-target=right] {\n    vertical-align: bottom !important;\n    margin-right: -1px !important;\n}"));
var Yr = new WeakMap(),
  $r = new WeakSet();
var Xr = /*#__PURE__*/function () {
  function Xr(t) {
    _classCallCheck(this, Xr);
    var e, i;
    _i(e = this, i = $r), i.add(e), ji(this, Yr, {
      writable: !0,
      value: void 0
    }), this.element = t, Oi(this, Yr, t.attachInternals());
  }
  return _createClass(Xr, [{
    key: "connectedCallback",
    value: function connectedCallback() {
      Bi(this, $r, Zr).call(this);
    }
  }, {
    key: "disconnectedCallback",
    value: function disconnectedCallback() {}
  }, {
    key: "labels",
    get: function get() {
      return Ii(this, Yr).labels;
    }
  }, {
    key: "disabled",
    get: function get() {
      var t;
      return null === (t = this.element.inputElement) || void 0 === t ? void 0 : t.disabled;
    },
    set: function set(t) {
      this.element.toggleAttribute("disabled", t);
    }
  }, {
    key: "required",
    get: function get() {
      return this.element.hasAttribute("required");
    },
    set: function set(t) {
      this.element.toggleAttribute("required", t), Bi(this, $r, Zr).call(this);
    }
  }, {
    key: "validity",
    get: function get() {
      return Ii(this, Yr).validity;
    }
  }, {
    key: "validationMessage",
    get: function get() {
      return Ii(this, Yr).validationMessage;
    }
  }, {
    key: "willValidate",
    get: function get() {
      return Ii(this, Yr).willValidate;
    }
  }, {
    key: "setFormValue",
    value: function setFormValue(t) {
      Bi(this, $r, Zr).call(this);
    }
  }, {
    key: "checkValidity",
    value: function checkValidity() {
      return Ii(this, Yr).checkValidity();
    }
  }, {
    key: "reportValidity",
    value: function reportValidity() {
      return Ii(this, Yr).reportValidity();
    }
  }, {
    key: "setCustomValidity",
    value: function setCustomValidity(t) {
      Bi(this, $r, Zr).call(this, t);
    }
  }]);
}();
function Zr() {
  var t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : "";
  var _this$element = this.element,
    e = _this$element.required,
    i = _this$element.value,
    n = e && !i,
    r = !!t,
    o = T("input", {
      required: e
    }),
    s = t || o.validationMessage;
  Ii(this, Yr).setValidity({
    valueMissing: n,
    customError: r
  }, s);
}
var Qr = new WeakMap(),
  to = new WeakMap(),
  eo = new WeakMap();
var io = /*#__PURE__*/function () {
  function io(t) {
    var _this73 = this;
    _classCallCheck(this, io);
    ji(this, Qr, {
      writable: !0,
      value: void 0
    }), ji(this, to, {
      writable: !0,
      value: function value(t) {
        t.defaultPrevented || t.target === _this73.element.form && _this73.element.reset();
      }
    }), ji(this, eo, {
      writable: !0,
      value: function value(t) {
        if (t.defaultPrevented) return;
        if (_this73.element.contains(t.target)) return;
        var e = y(t.target, {
          matchingSelector: "label"
        });
        e && Array.from(_this73.labels).includes(e) && _this73.element.focus();
      }
    }), this.element = t;
  }
  return _createClass(io, [{
    key: "connectedCallback",
    value: function connectedCallback() {
      Oi(this, Qr, function (t) {
        if (t.hasAttribute("aria-label") || t.hasAttribute("aria-labelledby")) return;
        var e = function e() {
          var e = Array.from(t.labels).map(function (e) {
              if (!e.contains(t)) return e.textContent;
            }).filter(function (t) {
              return t;
            }),
            i = e.join(" ");
          return i ? t.setAttribute("aria-label", i) : t.removeAttribute("aria-label");
        };
        return e(), b("focus", {
          onElement: t,
          withCallback: e
        });
      }(this.element)), window.addEventListener("reset", Ii(this, to), !1), window.addEventListener("click", Ii(this, eo), !1);
    }
  }, {
    key: "disconnectedCallback",
    value: function disconnectedCallback() {
      var t;
      null === (t = Ii(this, Qr)) || void 0 === t || t.destroy(), window.removeEventListener("reset", Ii(this, to), !1), window.removeEventListener("click", Ii(this, eo), !1);
    }
  }, {
    key: "labels",
    get: function get() {
      var t = [];
      this.element.id && this.element.ownerDocument && t.push.apply(t, _toConsumableArray(Array.from(this.element.ownerDocument.querySelectorAll("label[for='".concat(this.element.id, "']")) || [])));
      var e = y(this.element, {
        matchingSelector: "label"
      });
      return e && [this.element, null].includes(e.control) && t.push(e), t;
    }
  }, {
    key: "disabled",
    get: function get() {
      return console.warn("This browser does not support the [disabled] attribute for trix-editor elements."), !1;
    },
    set: function set(t) {
      console.warn("This browser does not support the [disabled] attribute for trix-editor elements.");
    }
  }, {
    key: "required",
    get: function get() {
      return console.warn("This browser does not support the [required] attribute for trix-editor elements."), !1;
    },
    set: function set(t) {
      console.warn("This browser does not support the [required] attribute for trix-editor elements.");
    }
  }, {
    key: "validity",
    get: function get() {
      return console.warn("This browser does not support the validity property for trix-editor elements."), null;
    }
  }, {
    key: "validationMessage",
    get: function get() {
      return console.warn("This browser does not support the validationMessage property for trix-editor elements."), "";
    }
  }, {
    key: "willValidate",
    get: function get() {
      return console.warn("This browser does not support the willValidate property for trix-editor elements."), !1;
    }
  }, {
    key: "setFormValue",
    value: function setFormValue(t) {}
  }, {
    key: "checkValidity",
    value: function checkValidity() {
      return console.warn("This browser does not support checkValidity() for trix-editor elements."), !0;
    }
  }, {
    key: "reportValidity",
    value: function reportValidity() {
      return console.warn("This browser does not support reportValidity() for trix-editor elements."), !0;
    }
  }, {
    key: "setCustomValidity",
    value: function setCustomValidity(t) {
      console.warn("This browser does not support setCustomValidity(validationMessage) for trix-editor elements.");
    }
  }]);
}();
var no = new WeakMap();
var ro = /*#__PURE__*/function (_HTMLElement2) {
  function ro() {
    var _this74;
    _classCallCheck(this, ro);
    _this74 = _callSuper(this, ro), ji(_assertThisInitialized(_this74), no, {
      writable: !0,
      value: void 0
    }), Oi(_assertThisInitialized(_this74), no, _this74.constructor.formAssociated ? new Xr(_assertThisInitialized(_this74)) : new io(_assertThisInitialized(_this74)));
    return _this74;
  }
  _inherits(ro, _HTMLElement2);
  return _createClass(ro, [{
    key: "trixId",
    get: function get() {
      return this.hasAttribute("trix-id") ? this.getAttribute("trix-id") : (this.setAttribute("trix-id", ++zr), this.trixId);
    }
  }, {
    key: "labels",
    get: function get() {
      return Ii(this, no).labels;
    }
  }, {
    key: "disabled",
    get: function get() {
      return Ii(this, no).disabled;
    },
    set: function set(t) {
      Ii(this, no).disabled = t;
    }
  }, {
    key: "required",
    get: function get() {
      return Ii(this, no).required;
    },
    set: function set(t) {
      Ii(this, no).required = t;
    }
  }, {
    key: "validity",
    get: function get() {
      return Ii(this, no).validity;
    }
  }, {
    key: "validationMessage",
    get: function get() {
      return Ii(this, no).validationMessage;
    }
  }, {
    key: "willValidate",
    get: function get() {
      return Ii(this, no).willValidate;
    }
  }, {
    key: "type",
    get: function get() {
      return this.localName;
    }
  }, {
    key: "toolbarElement",
    get: function get() {
      var t;
      if (this.hasAttribute("toolbar")) return null === (t = this.ownerDocument) || void 0 === t ? void 0 : t.getElementById(this.getAttribute("toolbar"));
      if (this.parentNode) {
        var _t61 = "trix-toolbar-".concat(this.trixId);
        return this.setAttribute("toolbar", _t61), this.internalToolbar = T("trix-toolbar", {
          id: _t61
        }), this.parentNode.insertBefore(this.internalToolbar, this), this.internalToolbar;
      }
    }
  }, {
    key: "form",
    get: function get() {
      var t;
      return null === (t = this.inputElement) || void 0 === t ? void 0 : t.form;
    }
  }, {
    key: "inputElement",
    get: function get() {
      var t;
      if (this.hasAttribute("input")) return null === (t = this.ownerDocument) || void 0 === t ? void 0 : t.getElementById(this.getAttribute("input"));
      if (this.parentNode) {
        var _t62 = "trix-input-".concat(this.trixId);
        this.setAttribute("input", _t62);
        var _e55 = T("input", {
          type: "hidden",
          id: _t62
        });
        return this.parentNode.insertBefore(_e55, this.nextElementSibling), _e55;
      }
    }
  }, {
    key: "editor",
    get: function get() {
      var t;
      return null === (t = this.editorController) || void 0 === t ? void 0 : t.editor;
    }
  }, {
    key: "name",
    get: function get() {
      var t;
      return null === (t = this.inputElement) || void 0 === t ? void 0 : t.name;
    }
  }, {
    key: "value",
    get: function get() {
      var t;
      return null === (t = this.inputElement) || void 0 === t ? void 0 : t.value;
    },
    set: function set(t) {
      var e;
      this.defaultValue = t, null === (e = this.editor) || void 0 === e || e.loadHTML(this.defaultValue);
    }
  }, {
    key: "attributeChangedCallback",
    value: function attributeChangedCallback(t, e, i) {
      var _this75 = this;
      "connected" === t && this.isConnected && null != e && e !== i && requestAnimationFrame(function () {
        return _this75.reconnect();
      });
    }
  }, {
    key: "notify",
    value: function notify(t, e) {
      if (this.editorController) return v("trix-".concat(t), {
        onElement: this,
        attributes: e
      });
    }
  }, {
    key: "setFormValue",
    value: function setFormValue(t) {
      this.inputElement && (this.inputElement.value = t, Ii(this, no).setFormValue(t));
    }
  }, {
    key: "connectedCallback",
    value: function connectedCallback() {
      var _this76 = this;
      this.hasAttribute("data-trix-internal") || (qr(this), function (t) {
        if (!t.hasAttribute("role")) t.setAttribute("role", "textbox");
      }(this), this.editorController || (v("trix-before-initialize", {
        onElement: this
      }), this.editorController = new _r({
        editorElement: this,
        html: this.defaultValue = this.value
      }), requestAnimationFrame(function () {
        return v("trix-initialize", {
          onElement: _this76
        });
      })), this.editorController.registerSelectionManager(), Ii(this, no).connectedCallback(), this.toggleAttribute("connected", !0), function (t) {
        if (!document.querySelector(":focus") && t.hasAttribute("autofocus") && document.querySelector("[autofocus]") === t) t.focus();
      }(this));
    }
  }, {
    key: "disconnectedCallback",
    value: function disconnectedCallback() {
      var t;
      null === (t = this.editorController) || void 0 === t || t.unregisterSelectionManager(), Ii(this, no).disconnectedCallback(), this.toggleAttribute("connected", !1);
    }
  }, {
    key: "reconnect",
    value: function reconnect() {
      this.removeInternalToolbar(), this.disconnectedCallback(), this.connectedCallback();
    }
  }, {
    key: "removeInternalToolbar",
    value: function removeInternalToolbar() {
      var t;
      null === (t = this.internalToolbar) || void 0 === t || t.remove(), this.internalToolbar = null;
    }
  }, {
    key: "checkValidity",
    value: function checkValidity() {
      return Ii(this, no).checkValidity();
    }
  }, {
    key: "reportValidity",
    value: function reportValidity() {
      return Ii(this, no).reportValidity();
    }
  }, {
    key: "setCustomValidity",
    value: function setCustomValidity(t) {
      Ii(this, no).setCustomValidity(t);
    }
  }, {
    key: "formDisabledCallback",
    value: function formDisabledCallback(t) {
      this.inputElement && (this.inputElement.disabled = t), this.toggleAttribute("contenteditable", !t);
    }
  }, {
    key: "formResetCallback",
    value: function formResetCallback() {
      this.reset();
    }
  }, {
    key: "reset",
    value: function reset() {
      this.value = this.defaultValue;
    }
  }]);
}(/*#__PURE__*/_wrapNativeSuper(HTMLElement));
Di(ro, "formAssociated", "ElementInternals" in window), Di(ro, "observedAttributes", ["connected"]);
var oo = {
  VERSION: t,
  config: z,
  core: Sn,
  models: zn,
  views: qn,
  controllers: jr,
  observers: Wr,
  operations: Ur,
  elements: Object.freeze({
    __proto__: null,
    TrixEditorElement: ro,
    TrixToolbarElement: Vr
  }),
  filters: Object.freeze({
    __proto__: null,
    Filter: In,
    attachmentGalleryFilter: On
  })
};
Object.assign(oo, zn), window.Trix = oo, setTimeout(function () {
  customElements.get("trix-toolbar") || customElements.define("trix-toolbar", Vr), customElements.get("trix-editor") || customElements.define("trix-editor", ro);
}, 0);


/***/ })

/******/ });
//# sourceMappingURL=application-c0834fb9e65eb5c363a2.js.map