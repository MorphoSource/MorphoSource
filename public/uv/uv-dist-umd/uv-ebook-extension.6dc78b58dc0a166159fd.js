(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([["uv-ebook-extension"],{

/***/ "./node_modules/@universalviewer/uv-ebook-components/dist/esm-es5 lazy recursive ^\\.\\/.*\\.entry\\.js$ include: \\.entry\\.js$ exclude: \\.system\\.entry\\.js$":
/*!**********************************************************************************************************************************************************************!*\
  !*** ./node_modules/@universalviewer/uv-ebook-components/dist/esm-es5 lazy ^\.\/.*\.entry\.js$ include: \.entry\.js$ exclude: \.system\.entry\.js$ namespace object ***!
  \**********************************************************************************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

var map = {
	"./uv-ebook-reader_2.entry.js": [
		"./node_modules/@universalviewer/uv-ebook-components/dist/esm-es5/uv-ebook-reader_2.entry.js",
		5,
		7,
		16
	]
};
function webpackAsyncContext(req) {
	if(!__webpack_require__.o(map, req)) {
		return Promise.resolve().then(function() {
			var e = new Error("Cannot find module '" + req + "'");
			e.code = 'MODULE_NOT_FOUND';
			throw e;
		});
	}

	var ids = map[req], id = ids[0];
	return Promise.all(ids.slice(1).map(__webpack_require__.e)).then(function() {
		return __webpack_require__(id);
	});
}
webpackAsyncContext.keys = function webpackAsyncContextKeys() {
	return Object.keys(map);
};
webpackAsyncContext.id = "./node_modules/@universalviewer/uv-ebook-components/dist/esm-es5 lazy recursive ^\\.\\/.*\\.entry\\.js$ include: \\.entry\\.js$ exclude: \\.system\\.entry\\.js$";
module.exports = webpackAsyncContext;

/***/ }),

/***/ "./src/extensions/uv-ebook-extension/DownloadDialogue.ts":
/*!***************************************************************!*\
  !*** ./src/extensions/uv-ebook-extension/DownloadDialogue.ts ***!
  \***************************************************************/
/*! exports provided: DownloadDialogue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "DownloadDialogue", function() { return DownloadDialogue; });
/* harmony import */ var _modules_uv_dialogues_module_DownloadDialogue__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../modules/uv-dialogues-module/DownloadDialogue */ "./src/modules/uv-dialogues-module/DownloadDialogue.ts");
var __extends = (undefined && undefined.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();

var DownloadDialogue = /** @class */ (function (_super) {
    __extends(DownloadDialogue, _super);
    function DownloadDialogue($element) {
        return _super.call(this, $element) || this;
    }
    DownloadDialogue.prototype.create = function () {
        this.setConfig("downloadDialogue");
        _super.prototype.create.call(this);
    };
    DownloadDialogue.prototype.open = function ($triggerButton) {
        _super.prototype.open.call(this, $triggerButton);
        this.addEntireFileDownloadOptions();
        this.updateNoneAvailable();
        this.resize();
    };
    DownloadDialogue.prototype.isDownloadOptionAvailable = function (option) {
        return _super.prototype.isDownloadOptionAvailable.call(this, option);
    };
    return DownloadDialogue;
}(_modules_uv_dialogues_module_DownloadDialogue__WEBPACK_IMPORTED_MODULE_0__["DownloadDialogue"]));



/***/ }),

/***/ "./src/extensions/uv-ebook-extension/Events.ts":
/*!*****************************************************!*\
  !*** ./src/extensions/uv-ebook-extension/Events.ts ***!
  \*****************************************************/
/*! exports provided: Events */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Events", function() { return Events; });
var Events = /** @class */ (function () {
    function Events() {
    }
    Events.namespace = "ebookExtension.";
    Events.CFI_FRAGMENT_CHANGE = Events.namespace + "cfiFragmentChange";
    Events.ITEM_CLICKED = Events.namespace + "itemClicked";
    Events.LOADED_NAVIGATION = Events.namespace + "loadedNavigation";
    Events.RELOCATED = Events.namespace + "relocated";
    Events.RENDITION_ATTACHED = Events.namespace + "renditionAttached";
    Events.TOC_READY = Events.namespace + "tocReady";
    return Events;
}());



/***/ }),

/***/ "./src/extensions/uv-ebook-extension/Extension.ts":
/*!********************************************************!*\
  !*** ./src/extensions/uv-ebook-extension/Extension.ts ***!
  \********************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _modules_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../modules/uv-shared-module/BaseEvents */ "./src/modules/uv-shared-module/BaseEvents.ts");
/* harmony import */ var _modules_uv_shared_module_BaseExtension__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../../modules/uv-shared-module/BaseExtension */ "./src/modules/uv-shared-module/BaseExtension.ts");
/* harmony import */ var _modules_uv_ebookleftpanel_module_EbookLeftPanel__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../modules/uv-ebookleftpanel-module/EbookLeftPanel */ "./src/modules/uv-ebookleftpanel-module/EbookLeftPanel.ts");
/* harmony import */ var _Events__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./Events */ "./src/extensions/uv-ebook-extension/Events.ts");
/* harmony import */ var _DownloadDialogue__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./DownloadDialogue */ "./src/extensions/uv-ebook-extension/DownloadDialogue.ts");
/* harmony import */ var _modules_uv_ebookcenterpanel_module_EbookCenterPanel__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ../../modules/uv-ebookcenterpanel-module/EbookCenterPanel */ "./src/modules/uv-ebookcenterpanel-module/EbookCenterPanel.ts");
/* harmony import */ var _modules_uv_shared_module_FooterPanel__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ../../modules/uv-shared-module/FooterPanel */ "./src/modules/uv-shared-module/FooterPanel.ts");
/* harmony import */ var _modules_uv_ebookmobilefooterpanel_module_MobileFooter__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ../../modules/uv-ebookmobilefooterpanel-module/MobileFooter */ "./src/modules/uv-ebookmobilefooterpanel-module/MobileFooter.ts");
/* harmony import */ var _modules_uv_shared_module_HeaderPanel__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ../../modules/uv-shared-module/HeaderPanel */ "./src/modules/uv-shared-module/HeaderPanel.ts");
/* harmony import */ var _modules_uv_dialogues_module_MoreInfoDialogue__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! ../../modules/uv-dialogues-module/MoreInfoDialogue */ "./src/modules/uv-dialogues-module/MoreInfoDialogue.ts");
/* harmony import */ var _modules_uv_moreinforightpanel_module_MoreInfoRightPanel__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! ../../modules/uv-moreinforightpanel-module/MoreInfoRightPanel */ "./src/modules/uv-moreinforightpanel-module/MoreInfoRightPanel.ts");
/* harmony import */ var _SettingsDialogue__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! ./SettingsDialogue */ "./src/extensions/uv-ebook-extension/SettingsDialogue.ts");
/* harmony import */ var _ShareDialogue__WEBPACK_IMPORTED_MODULE_12__ = __webpack_require__(/*! ./ShareDialogue */ "./src/extensions/uv-ebook-extension/ShareDialogue.ts");
/* harmony import */ var _edsilv_utils__WEBPACK_IMPORTED_MODULE_13__ = __webpack_require__(/*! @edsilv/utils */ "./node_modules/@edsilv/utils/dist-esmodule/index.js");
var __extends = (undefined && undefined.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();














var Extension = /** @class */ (function (_super) {
    __extends(Extension, _super);
    function Extension() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    Extension.prototype.create = function () {
        var _this = this;
        _super.prototype.create.call(this);
        this.component.subscribe(_modules_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].CANVAS_INDEX_CHANGE, function (canvasIndex) {
            _this.viewCanvas(canvasIndex);
        });
        this.component.subscribe(_Events__WEBPACK_IMPORTED_MODULE_3__["Events"].CFI_FRAGMENT_CHANGE, function (cfi) {
            _this.cfiFragement = cfi;
            _this.fire(_Events__WEBPACK_IMPORTED_MODULE_3__["Events"].CFI_FRAGMENT_CHANGE, _this.cfiFragement);
        });
    };
    Extension.prototype.createModules = function () {
        _super.prototype.createModules.call(this);
        if (this.isHeaderPanelEnabled()) {
            this.headerPanel = new _modules_uv_shared_module_HeaderPanel__WEBPACK_IMPORTED_MODULE_8__["HeaderPanel"](this.shell.$headerPanel);
        }
        else {
            this.shell.$headerPanel.hide();
        }
        if (this.isLeftPanelEnabled()) {
            this.leftPanel = new _modules_uv_ebookleftpanel_module_EbookLeftPanel__WEBPACK_IMPORTED_MODULE_2__["EbookLeftPanel"](this.shell.$leftPanel);
        }
        else {
            this.shell.$leftPanel.hide();
        }
        this.centerPanel = new _modules_uv_ebookcenterpanel_module_EbookCenterPanel__WEBPACK_IMPORTED_MODULE_5__["EbookCenterPanel"](this.shell.$centerPanel);
        if (this.isRightPanelEnabled()) {
            this.rightPanel = new _modules_uv_moreinforightpanel_module_MoreInfoRightPanel__WEBPACK_IMPORTED_MODULE_10__["MoreInfoRightPanel"](this.shell.$rightPanel);
        }
        else {
            this.shell.$rightPanel.hide();
        }
        if (this.isFooterPanelEnabled()) {
            this.footerPanel = new _modules_uv_shared_module_FooterPanel__WEBPACK_IMPORTED_MODULE_6__["FooterPanel"](this.shell.$footerPanel);
            this.mobileFooterPanel = new _modules_uv_ebookmobilefooterpanel_module_MobileFooter__WEBPACK_IMPORTED_MODULE_7__["FooterPanel"](this.shell.$mobileFooterPanel);
        }
        else {
            this.shell.$footerPanel.hide();
        }
        this.$moreInfoDialogue = $('<div class="overlay moreInfo" aria-hidden="true"></div>');
        this.shell.$overlays.append(this.$moreInfoDialogue);
        this.moreInfoDialogue = new _modules_uv_dialogues_module_MoreInfoDialogue__WEBPACK_IMPORTED_MODULE_9__["MoreInfoDialogue"](this.$moreInfoDialogue);
        this.$shareDialogue = $('<div class="overlay share" aria-hidden="true"></div>');
        this.shell.$overlays.append(this.$shareDialogue);
        this.shareDialogue = new _ShareDialogue__WEBPACK_IMPORTED_MODULE_12__["ShareDialogue"](this.$shareDialogue);
        this.$downloadDialogue = $('<div class="overlay download" aria-hidden="true"></div>');
        this.shell.$overlays.append(this.$downloadDialogue);
        this.downloadDialogue = new _DownloadDialogue__WEBPACK_IMPORTED_MODULE_4__["DownloadDialogue"](this.$downloadDialogue);
        this.$settingsDialogue = $('<div class="overlay settings" aria-hidden="true"></div>');
        this.shell.$overlays.append(this.$settingsDialogue);
        this.settingsDialogue = new _SettingsDialogue__WEBPACK_IMPORTED_MODULE_11__["SettingsDialogue"](this.$settingsDialogue);
        if (this.isHeaderPanelEnabled()) {
            this.headerPanel.init();
        }
        if (this.isLeftPanelEnabled()) {
            this.leftPanel.init();
        }
        if (this.isRightPanelEnabled()) {
            this.rightPanel.init();
        }
        if (this.isFooterPanelEnabled()) {
            this.footerPanel.init();
        }
    };
    Extension.prototype.isLeftPanelEnabled = function () {
        return true;
    };
    Extension.prototype.render = function () {
        _super.prototype.render.call(this);
        this.checkForCFIParam();
    };
    Extension.prototype.getEmbedScript = function (template, width, height) {
        var appUri = this.getAppUri();
        var iframeSrc = appUri + "#?manifest=" + this.helper.manifestUri + "&cfi=" + this.cfiFragement;
        var script = _edsilv_utils__WEBPACK_IMPORTED_MODULE_13__["Strings"].format(template, iframeSrc, width.toString(), height.toString());
        return script;
    };
    Extension.prototype.checkForCFIParam = function () {
        var cfi = this.data.cfi;
        if (cfi) {
            this.component.publish(_Events__WEBPACK_IMPORTED_MODULE_3__["Events"].CFI_FRAGMENT_CHANGE, cfi);
        }
    };
    return Extension;
}(_modules_uv_shared_module_BaseExtension__WEBPACK_IMPORTED_MODULE_1__["BaseExtension"]));
/* harmony default export */ __webpack_exports__["default"] = (Extension);


/***/ }),

/***/ "./src/extensions/uv-ebook-extension/SettingsDialogue.ts":
/*!***************************************************************!*\
  !*** ./src/extensions/uv-ebook-extension/SettingsDialogue.ts ***!
  \***************************************************************/
/*! exports provided: SettingsDialogue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SettingsDialogue", function() { return SettingsDialogue; });
/* harmony import */ var _modules_uv_dialogues_module_SettingsDialogue__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../modules/uv-dialogues-module/SettingsDialogue */ "./src/modules/uv-dialogues-module/SettingsDialogue.ts");
var __extends = (undefined && undefined.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();

var SettingsDialogue = /** @class */ (function (_super) {
    __extends(SettingsDialogue, _super);
    function SettingsDialogue($element) {
        return _super.call(this, $element) || this;
    }
    SettingsDialogue.prototype.create = function () {
        this.setConfig("settingsDialogue");
        _super.prototype.create.call(this);
    };
    return SettingsDialogue;
}(_modules_uv_dialogues_module_SettingsDialogue__WEBPACK_IMPORTED_MODULE_0__["SettingsDialogue"]));



/***/ }),

/***/ "./src/extensions/uv-ebook-extension/ShareDialogue.ts":
/*!************************************************************!*\
  !*** ./src/extensions/uv-ebook-extension/ShareDialogue.ts ***!
  \************************************************************/
/*! exports provided: ShareDialogue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ShareDialogue", function() { return ShareDialogue; });
/* harmony import */ var _modules_uv_dialogues_module_ShareDialogue__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../../modules/uv-dialogues-module/ShareDialogue */ "./src/modules/uv-dialogues-module/ShareDialogue.ts");
var __extends = (undefined && undefined.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();

var ShareDialogue = /** @class */ (function (_super) {
    __extends(ShareDialogue, _super);
    function ShareDialogue($element) {
        return _super.call(this, $element) || this;
    }
    ShareDialogue.prototype.create = function () {
        this.setConfig("shareDialogue");
        _super.prototype.create.call(this);
    };
    ShareDialogue.prototype.update = function () {
        _super.prototype.update.call(this);
        this.code = this.extension.getEmbedScript(this.options.embedTemplate, this.currentWidth, this.currentHeight);
        this.$code.val(this.code);
    };
    ShareDialogue.prototype.resize = function () {
        _super.prototype.resize.call(this);
    };
    return ShareDialogue;
}(_modules_uv_dialogues_module_ShareDialogue__WEBPACK_IMPORTED_MODULE_0__["ShareDialogue"]));



/***/ }),

/***/ "./src/modules/uv-ebookcenterpanel-module/EbookCenterPanel.ts":
/*!********************************************************************!*\
  !*** ./src/modules/uv-ebookcenterpanel-module/EbookCenterPanel.ts ***!
  \********************************************************************/
/*! exports provided: EbookCenterPanel */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "EbookCenterPanel", function() { return EbookCenterPanel; });
/* harmony import */ var _edsilv_utils__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @edsilv/utils */ "./node_modules/@edsilv/utils/dist-esmodule/index.js");
/* harmony import */ var _uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../uv-shared-module/BaseEvents */ "./src/modules/uv-shared-module/BaseEvents.ts");
/* harmony import */ var _uv_shared_module_CenterPanel__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../uv-shared-module/CenterPanel */ "./src/modules/uv-shared-module/CenterPanel.ts");
/* harmony import */ var _extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../../extensions/uv-ebook-extension/Events */ "./src/extensions/uv-ebook-extension/Events.ts");
/* harmony import */ var _uv_shared_module_Position__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../uv-shared-module/Position */ "./src/modules/uv-shared-module/Position.ts");
/* harmony import */ var _universalviewer_uv_ebook_components_loader__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! @universalviewer/uv-ebook-components/loader */ "./node_modules/@universalviewer/uv-ebook-components/loader/index.mjs");
var __extends = (undefined && undefined.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __awaiter = (undefined && undefined.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
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






var EbookCenterPanel = /** @class */ (function (_super) {
    __extends(EbookCenterPanel, _super);
    function EbookCenterPanel($element) {
        var _this = _super.call(this, $element) || this;
        _this._ebookReaderReady = false;
        _this._state = {};
        _this._prevState = {};
        _this.attributionPosition = _uv_shared_module_Position__WEBPACK_IMPORTED_MODULE_4__["Position"].BOTTOM_RIGHT;
        return _this;
    }
    EbookCenterPanel.prototype.create = function () {
        return __awaiter(this, void 0, void 0, function () {
            var that;
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        this.setConfig("ebookCenterPanel");
                        _super.prototype.create.call(this);
                        return [4 /*yield*/, Object(_universalviewer_uv_ebook_components_loader__WEBPACK_IMPORTED_MODULE_5__["applyPolyfills"])()];
                    case 1:
                        _a.sent();
                        Object(_universalviewer_uv_ebook_components_loader__WEBPACK_IMPORTED_MODULE_5__["defineCustomElements"])(window);
                        this._ebookReader = document.createElement("uv-ebook-reader");
                        this.$content.prepend(this._ebookReader);
                        this._ebookReader.setAttribute("width", "100%");
                        this._ebookReader.setAttribute("height", "100%");
                        this._ebookReader.addEventListener("loadedNavigation", function (e) {
                            _this.component.publish(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_3__["Events"].LOADED_NAVIGATION, e.detail);
                        }, false);
                        this._ebookReader.addEventListener("relocated", function (e) {
                            _this.component.publish(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_3__["Events"].RELOCATED, e.detail);
                            _this._cfi = e.detail.start.cfi;
                            _this.component.publish(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_3__["Events"].CFI_FRAGMENT_CHANGE, _this._cfi);
                        }, false);
                        _edsilv_utils__WEBPACK_IMPORTED_MODULE_0__["Async"].waitFor(function () {
                            return window.customElements !== undefined;
                        }, function () {
                            customElements.whenDefined("uv-ebook-reader").then(function () {
                                _this._ebookReaderReady = true;
                            });
                        });
                        that = this;
                        this.component.subscribe(_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_1__["BaseEvents"].OPEN_EXTERNAL_RESOURCE, function (e, resources) {
                            that.openMedia(resources);
                        });
                        this.component.subscribe(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_3__["Events"].ITEM_CLICKED, function (href) {
                            _this._nextState({
                                cfi: href
                            });
                        });
                        this.component.subscribe(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_3__["Events"].CFI_FRAGMENT_CHANGE, function (cfi) {
                            _edsilv_utils__WEBPACK_IMPORTED_MODULE_0__["Async"].waitFor(function () {
                                return _this._ebookReaderReady;
                            }, function () {
                                if (cfi !== _this._cfi) {
                                    _this._nextState({
                                        cfi: cfi
                                    });
                                }
                            });
                        });
                        return [2 /*return*/];
                }
            });
        });
    };
    EbookCenterPanel.prototype.openMedia = function (resources) {
        var _this = this;
        this.extension.getExternalResources(resources).then(function () {
            var canvas = _this.extension.helper.getCurrentCanvas();
            var annotations = canvas.getContent();
            if (annotations.length) {
                var annotation = annotations[0];
                var body = annotation.getBody();
                if (body.length) {
                    var media = body[0];
                    //const format: MediaType | null = media.getFormat();
                    _this._nextState({
                        bookPath: media.id
                    });
                }
            }
            _this.component.publish(_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_1__["BaseEvents"].EXTERNAL_RESOURCE_OPENED);
            _this.component.publish(_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_1__["BaseEvents"].LOAD);
        });
    };
    EbookCenterPanel.prototype._nextState = function (s) {
        var _this = this;
        this._state = Object.assign({}, this._state, s);
        _edsilv_utils__WEBPACK_IMPORTED_MODULE_0__["Async"].waitFor(function () {
            return _this._ebookReaderReady;
        }, function () {
            if (_this._state.bookPath &&
                _this._state.bookPath !== _this._prevState.bookPath) {
                _this._ebookReader.load(_this._state.bookPath);
            }
            if (_this._state.cfi && _this._state.cfi !== _this._prevState.cfi) {
                _this._ebookReader.display(_this._state.cfi);
            }
            _this._prevState = Object.assign({}, _this._state);
        });
    };
    EbookCenterPanel.prototype.resize = function () {
        var _this = this;
        _super.prototype.resize.call(this);
        if (this._ebookReaderReady) {
            setTimeout(function () {
                _this._ebookReader.resize();
            }, 10);
        }
    };
    return EbookCenterPanel;
}(_uv_shared_module_CenterPanel__WEBPACK_IMPORTED_MODULE_2__["CenterPanel"]));



/***/ }),

/***/ "./src/modules/uv-ebookleftpanel-module/EbookLeftPanel.ts":
/*!****************************************************************!*\
  !*** ./src/modules/uv-ebookleftpanel-module/EbookLeftPanel.ts ***!
  \****************************************************************/
/*! exports provided: EbookLeftPanel */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "EbookLeftPanel", function() { return EbookLeftPanel; });
/* harmony import */ var _uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../uv-shared-module/BaseEvents */ "./src/modules/uv-shared-module/BaseEvents.ts");
/* harmony import */ var _uv_shared_module_LeftPanel__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../uv-shared-module/LeftPanel */ "./src/modules/uv-shared-module/LeftPanel.ts");
/* harmony import */ var _extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../extensions/uv-ebook-extension/Events */ "./src/extensions/uv-ebook-extension/Events.ts");
/* harmony import */ var _edsilv_utils__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @edsilv/utils */ "./node_modules/@edsilv/utils/dist-esmodule/index.js");
/* harmony import */ var _universalviewer_uv_ebook_components_loader__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @universalviewer/uv-ebook-components/loader */ "./node_modules/@universalviewer/uv-ebook-components/loader/index.mjs");
var __extends = (undefined && undefined.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __awaiter = (undefined && undefined.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
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





var EbookLeftPanel = /** @class */ (function (_super) {
    __extends(EbookLeftPanel, _super);
    function EbookLeftPanel($element) {
        return _super.call(this, $element) || this;
    }
    EbookLeftPanel.prototype.create = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        this.setConfig("ebookLeftPanel");
                        _super.prototype.create.call(this);
                        this._$container = $('<div class="container"></div>');
                        return [4 /*yield*/, Object(_universalviewer_uv_ebook_components_loader__WEBPACK_IMPORTED_MODULE_4__["applyPolyfills"])()];
                    case 1:
                        _a.sent();
                        Object(_universalviewer_uv_ebook_components_loader__WEBPACK_IMPORTED_MODULE_4__["defineCustomElements"])(window);
                        this._ebookTOC = document.createElement("uv-ebook-toc");
                        this._$ebookTOC = $(this._ebookTOC);
                        //this._ebookTOC.setAttribute("src-tab-enabled", this.config.options.srcTabEnabled);
                        this.$main.addClass("disabled");
                        this.$main.append(this._$container);
                        this._$container.append(this._$ebookTOC);
                        this.setTitle(this.content.title);
                        this.component.subscribe(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_2__["Events"].LOADED_NAVIGATION, function (navigation) {
                            _this.$main.removeClass("disabled");
                            _this._ebookTOC.toc = navigation.toc;
                        });
                        this.component.subscribe(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_2__["Events"].RELOCATED, function (location) {
                            _this._ebookTOC.selected = location.start.href;
                        });
                        this._ebookTOC.addEventListener("itemClicked", function (e) {
                            _this.component.publish(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_2__["Events"].ITEM_CLICKED, e.detail);
                        }, false);
                        _edsilv_utils__WEBPACK_IMPORTED_MODULE_3__["Async"].waitFor(function () {
                            return window.customElements !== undefined;
                        }, function () {
                            customElements.whenDefined("uv-ebook-toc").then(function () {
                                _this.component.publish(_extensions_uv_ebook_extension_Events__WEBPACK_IMPORTED_MODULE_2__["Events"].TOC_READY);
                            });
                        });
                        return [2 /*return*/];
                }
            });
        });
    };
    EbookLeftPanel.prototype.expandFullStart = function () {
        _super.prototype.expandFullStart.call(this);
        this.component.publish(_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].LEFTPANEL_EXPAND_FULL_START);
    };
    EbookLeftPanel.prototype.expandFullFinish = function () {
        _super.prototype.expandFullFinish.call(this);
        this.component.publish(_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].LEFTPANEL_EXPAND_FULL_FINISH);
    };
    EbookLeftPanel.prototype.collapseFullStart = function () {
        _super.prototype.collapseFullStart.call(this);
        this.component.publish(_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].LEFTPANEL_COLLAPSE_FULL_START);
    };
    EbookLeftPanel.prototype.collapseFullFinish = function () {
        _super.prototype.collapseFullFinish.call(this);
        this.component.publish(_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].LEFTPANEL_COLLAPSE_FULL_FINISH);
    };
    EbookLeftPanel.prototype.resize = function () {
        _super.prototype.resize.call(this);
        this._$container.height(this.$main.height() - this._$container.verticalPadding());
    };
    return EbookLeftPanel;
}(_uv_shared_module_LeftPanel__WEBPACK_IMPORTED_MODULE_1__["LeftPanel"]));



/***/ }),

/***/ "./src/modules/uv-ebookmobilefooterpanel-module/MobileFooter.ts":
/*!**********************************************************************!*\
  !*** ./src/modules/uv-ebookmobilefooterpanel-module/MobileFooter.ts ***!
  \**********************************************************************/
/*! exports provided: FooterPanel */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "FooterPanel", function() { return FooterPanel; });
/* harmony import */ var _uv_shared_module_FooterPanel__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../uv-shared-module/FooterPanel */ "./src/modules/uv-shared-module/FooterPanel.ts");
var __extends = (undefined && undefined.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();

var FooterPanel = /** @class */ (function (_super) {
    __extends(FooterPanel, _super);
    function FooterPanel($element) {
        return _super.call(this, $element) || this;
    }
    FooterPanel.prototype.create = function () {
        this.setConfig("mobileFooterPanel");
        _super.prototype.create.call(this);
    };
    FooterPanel.prototype.resize = function () {
        _super.prototype.resize.call(this);
        this.$options.css("left", Math.floor(this.$element.width() / 2 - this.$options.width() / 2));
    };
    return FooterPanel;
}(_uv_shared_module_FooterPanel__WEBPACK_IMPORTED_MODULE_0__["FooterPanel"]));



/***/ })

}]);
//# sourceMappingURL=uv-ebook-extension.6dc78b58dc0a166159fd.js.map