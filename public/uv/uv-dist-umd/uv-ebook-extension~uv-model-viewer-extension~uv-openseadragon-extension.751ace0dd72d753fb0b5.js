(window["webpackJsonpUV"] = window["webpackJsonpUV"] || []).push([["uv-ebook-extension~uv-model-viewer-extension~uv-openseadragon-extension"],{

/***/ "./src/modules/uv-dialogues-module/DownloadDialogue.ts":
/*!*************************************************************!*\
  !*** ./src/modules/uv-dialogues-module/DownloadDialogue.ts ***!
  \*************************************************************/
/*! exports provided: DownloadDialogue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "DownloadDialogue", function() { return DownloadDialogue; });
/* harmony import */ var _uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../uv-shared-module/BaseEvents */ "./src/modules/uv-shared-module/BaseEvents.ts");
/* harmony import */ var _uv_shared_module_Dialogue__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../uv-shared-module/Dialogue */ "./src/modules/uv-shared-module/Dialogue.ts");
/* harmony import */ var _uv_shared_module_DownloadOption__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../uv-shared-module/DownloadOption */ "./src/modules/uv-shared-module/DownloadOption.ts");
/* harmony import */ var _edsilv_utils__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @edsilv/utils */ "./node_modules/@edsilv/utils/dist-esmodule/index.js");
/* harmony import */ var manifesto_js__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! manifesto.js */ "./node_modules/manifesto.js/dist-umd/manifesto.js");
/* harmony import */ var manifesto_js__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(manifesto_js__WEBPACK_IMPORTED_MODULE_4__);
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
        var _this = this;
        this.setConfig("downloadDialogue");
        _super.prototype.create.call(this);
        this.openCommand = _uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].SHOW_DOWNLOAD_DIALOGUE;
        this.closeCommand = _uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].HIDE_DOWNLOAD_DIALOGUE;
        this.component.subscribe(this.openCommand, function (triggerButton) {
            _this.open(triggerButton);
        });
        this.component.subscribe(this.closeCommand, function () {
            _this.close();
        });
        // create ui.
        this.$title = $("<h1>" + this.content.title + "</h1>");
        this.$content.append(this.$title);
        this.$noneAvailable = $('<div class="noneAvailable">' + this.content.noneAvailable + "</div>");
        this.$content.append(this.$noneAvailable);
        this.$downloadOptions = $('<ol class="options"></ol>');
        this.$content.append(this.$downloadOptions);
        this.$footer = $('<div class="footer"></div>');
        this.$content.append(this.$footer);
        this.$termsOfUseButton = $('<a href="#">' + this.extension.data.config.content.termsOfUse + "</a>");
        this.$footer.append(this.$termsOfUseButton);
        this.$termsOfUseButton.onPressed(function () {
            _this.component.publish(_uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].SHOW_TERMS_OF_USE);
        });
        // hide
        this.$element.hide();
        this.updateTermsOfUseButton();
    };
    DownloadDialogue.prototype.addEntireFileDownloadOptions = function () {
        if (this.isDownloadOptionAvailable(_uv_shared_module_DownloadOption__WEBPACK_IMPORTED_MODULE_2__["DownloadOption"].ENTIRE_FILE_AS_ORIGINAL)) {
            this.$downloadOptions.empty();
            //
            // add each file src
            var canvas = this.extension.helper.getCurrentCanvas();
            var renderingFound = false;
            var renderings = canvas.getRenderings();
            for (var i = 0; i < renderings.length; i++) {
                var rendering = renderings[i];
                var renderingFormat = rendering.getFormat();
                var format = "";
                if (renderingFormat) {
                    format = renderingFormat.toString();
                }
                this.addEntireFileDownloadOption(rendering.id, manifesto_js__WEBPACK_IMPORTED_MODULE_4__["LanguageMap"].getValue(rendering.getLabel()), format);
                renderingFound = true;
            }
            if (!renderingFound) {
                var annotationFound = false;
                var annotations = canvas.getContent();
                for (var i = 0; i < annotations.length; i++) {
                    var annotation = annotations[i];
                    var body = annotation.getBody();
                    if (body.length) {
                        var format = body[0].getFormat();
                        if (format) {
                            this.addEntireFileDownloadOption(body[0].id, "", format.toString());
                            annotationFound = true;
                        }
                    }
                }
                if (!annotationFound) {
                    this.addEntireFileDownloadOption(canvas.id, "", "");
                }
            }
        }
    };
    DownloadDialogue.prototype.addEntireFileDownloadOption = function (uri, label, format) {
        var fileType;
        if (format) {
            fileType = _edsilv_utils__WEBPACK_IMPORTED_MODULE_3__["Files"].simplifyMimeType(format);
        }
        else {
            fileType = this.getFileExtension(uri);
        }
        if (!label) {
            label = this.content.entireFileAsOriginal;
        }
        if (fileType) {
            label += " (" + fileType + ")";
        }
        this.$downloadOptions.append('<li><a href="' +
            uri +
            '" target="_blank" download tabindex="0">' +
            label +
            "</li>");
    };
    DownloadDialogue.prototype.resetDynamicDownloadOptions = function () {
        this.renderingUrls = [];
        this.renderingUrlsCount = 0;
        this.$downloadOptions.find("li.dynamic").remove();
    };
    DownloadDialogue.prototype.getDownloadOptionsForRenderings = function (resource, defaultLabel, type) {
        var renderings = resource.getRenderings();
        var downloadOptions = [];
        for (var i = 0; i < renderings.length; i++) {
            var rendering = renderings[i];
            if (rendering) {
                var label = manifesto_js__WEBPACK_IMPORTED_MODULE_4__["LanguageMap"].getValue(rendering.getLabel(), this.extension.getLocale());
                var currentId = "downloadOption" + ++this.renderingUrlsCount;
                if (label) {
                    label += " ({0})";
                }
                else {
                    label = defaultLabel;
                }
                var mime = _edsilv_utils__WEBPACK_IMPORTED_MODULE_3__["Files"].simplifyMimeType(rendering.getFormat().toString());
                label = _edsilv_utils__WEBPACK_IMPORTED_MODULE_3__["Strings"].format(label, mime);
                this.renderingUrls[currentId] = rendering.id;
                var $button = $('<li class="option dynamic"><input id="' +
                    currentId +
                    '" data-mime="' +
                    mime +
                    '" title="' +
                    label +
                    '" type="radio" name="downloadOptions" tabindex="0" /><label for="' +
                    currentId +
                    '">' +
                    label +
                    "</label></li>");
                downloadOptions.push({
                    type: type,
                    button: $button
                });
            }
        }
        return downloadOptions;
    };
    DownloadDialogue.prototype.getSelectedOption = function () {
        return this.$downloadOptions.find("li.option input:checked");
    };
    DownloadDialogue.prototype.getCurrentResourceId = function () {
        var canvas = this.extension.helper.getCurrentCanvas();
        return canvas.externalResource.data.id;
    };
    DownloadDialogue.prototype.getCurrentResourceFormat = function () {
        var id = this.getCurrentResourceId();
        return id.substr(id.lastIndexOf(".") + 1).toLowerCase();
    };
    DownloadDialogue.prototype.updateNoneAvailable = function () {
        if (!this.$downloadOptions.find("li:visible").length) {
            this.$noneAvailable.show();
        }
        else {
            // select first option.
            this.$noneAvailable.hide();
        }
    };
    DownloadDialogue.prototype.updateTermsOfUseButton = function () {
        var requiredStatement = this.extension.helper.getRequiredStatement();
        if (_edsilv_utils__WEBPACK_IMPORTED_MODULE_3__["Bools"].getBool(this.extension.data.config.options.termsOfUseEnabled, false) &&
            requiredStatement &&
            requiredStatement.value) {
            this.$termsOfUseButton.show();
        }
        else {
            this.$termsOfUseButton.hide();
        }
    };
    DownloadDialogue.prototype.getFileExtension = function (fileUri) {
        var extension = fileUri.split(".").pop();
        // if it's not a valid file extension
        if (extension.length > 5 || extension.indexOf("/") !== -1) {
            return null;
        }
        return extension;
    };
    DownloadDialogue.prototype.isMediaDownloadEnabled = function () {
        return this.extension.helper.isUIEnabled("mediaDownload");
    };
    DownloadDialogue.prototype.isDownloadOptionAvailable = function (option) {
        switch (option) {
            case _uv_shared_module_DownloadOption__WEBPACK_IMPORTED_MODULE_2__["DownloadOption"].ENTIRE_FILE_AS_ORIGINAL:
                return this.isMediaDownloadEnabled();
        }
        return true;
    };
    DownloadDialogue.prototype.close = function () {
        _super.prototype.close.call(this);
    };
    DownloadDialogue.prototype.resize = function () {
        this.setDockedPosition();
    };
    return DownloadDialogue;
}(_uv_shared_module_Dialogue__WEBPACK_IMPORTED_MODULE_1__["Dialogue"]));



/***/ }),

/***/ "./src/modules/uv-dialogues-module/MoreInfoDialogue.ts":
/*!*************************************************************!*\
  !*** ./src/modules/uv-dialogues-module/MoreInfoDialogue.ts ***!
  \*************************************************************/
/*! exports provided: MoreInfoDialogue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "MoreInfoDialogue", function() { return MoreInfoDialogue; });
/* harmony import */ var _uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../uv-shared-module/BaseEvents */ "./src/modules/uv-shared-module/BaseEvents.ts");
/* harmony import */ var _uv_shared_module_Dialogue__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../uv-shared-module/Dialogue */ "./src/modules/uv-shared-module/Dialogue.ts");
/* harmony import */ var _Utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../Utils */ "./src/Utils.ts");
/* harmony import */ var _edsilv_utils__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @edsilv/utils */ "./node_modules/@edsilv/utils/dist-esmodule/index.js");
/* harmony import */ var _iiif_iiif_metadata_component__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! @iiif/iiif-metadata-component */ "./node_modules/@iiif/iiif-metadata-component/dist-umd/IIIFMetadataComponent.js");
/* harmony import */ var _iiif_iiif_metadata_component__WEBPACK_IMPORTED_MODULE_4___default = /*#__PURE__*/__webpack_require__.n(_iiif_iiif_metadata_component__WEBPACK_IMPORTED_MODULE_4__);
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





var MoreInfoDialogue = /** @class */ (function (_super) {
    __extends(MoreInfoDialogue, _super);
    function MoreInfoDialogue($element) {
        return _super.call(this, $element) || this;
    }
    MoreInfoDialogue.prototype.create = function () {
        var _this = this;
        this.setConfig("moreInfoDialogue");
        _super.prototype.create.call(this);
        this.openCommand = _uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].SHOW_MOREINFO_DIALOGUE;
        this.closeCommand = _uv_shared_module_BaseEvents__WEBPACK_IMPORTED_MODULE_0__["BaseEvents"].HIDE_MOREINFO_DIALOGUE;
        this.component.subscribe(this.openCommand, function (triggerButton) {
            _this.open(triggerButton);
        });
        this.component.subscribe(this.closeCommand, function () {
            _this.close();
        });
        this.config.content = this.extension.data.config.modules.moreInfoRightPanel.content;
        this.config.options = this.extension.data.config.modules.moreInfoRightPanel.options;
        // create ui
        this.$title = $("<h1>" + this.config.content.title + "</h1>");
        this.$content.append(this.$title);
        this.$metadata = $('<div class="iiif-metadata-component"></div>');
        this.$content.append(this.$metadata);
        this.metadataComponent = new _iiif_iiif_metadata_component__WEBPACK_IMPORTED_MODULE_4__["MetadataComponent"]({
            target: this.$metadata[0]
        });
        // hide
        this.$element.hide();
    };
    MoreInfoDialogue.prototype.open = function (triggerButton) {
        _super.prototype.open.call(this, triggerButton);
        this.metadataComponent.set(this._getData());
    };
    MoreInfoDialogue.prototype._getData = function () {
        return {
            canvasDisplayOrder: this.config.options.canvasDisplayOrder,
            canvases: this.extension.getCurrentCanvases(),
            canvasExclude: this.config.options.canvasExclude,
            canvasLabels: this.extension.getCanvasLabels(this.content.page),
            content: this.config.content,
            copiedMessageDuration: 2000,
            copyToClipboardEnabled: _edsilv_utils__WEBPACK_IMPORTED_MODULE_3__["Bools"].getBool(this.config.options.copyToClipboardEnabled, false),
            helper: this.extension.helper,
            licenseFormatter: null,
            limit: this.config.options.textLimit || 4,
            limitType: _iiif_iiif_metadata_component__WEBPACK_IMPORTED_MODULE_4__["LimitType"].LINES,
            manifestDisplayOrder: this.config.options.manifestDisplayOrder,
            manifestExclude: this.config.options.manifestExclude,
            range: this.extension.getCurrentCanvasRange(),
            rtlLanguageCodes: this.config.options.rtlLanguageCodes,
            sanitizer: function (html) {
                return Object(_Utils__WEBPACK_IMPORTED_MODULE_2__["sanitize"])(html);
            },
            showAllLanguages: this.config.options.showAllLanguages
        };
    };
    MoreInfoDialogue.prototype.close = function () {
        _super.prototype.close.call(this);
    };
    MoreInfoDialogue.prototype.resize = function () {
        this.setDockedPosition();
    };
    return MoreInfoDialogue;
}(_uv_shared_module_Dialogue__WEBPACK_IMPORTED_MODULE_1__["Dialogue"]));



/***/ }),

/***/ "./src/modules/uv-shared-module/DownloadOption.ts":
/*!********************************************************!*\
  !*** ./src/modules/uv-shared-module/DownloadOption.ts ***!
  \********************************************************/
/*! exports provided: DownloadOption */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "DownloadOption", function() { return DownloadOption; });
var DownloadOption;
(function (DownloadOption) {
    DownloadOption["CANVAS_RENDERINGS"] = "canvasRenderings";
    DownloadOption["CURRENT_VIEW"] = "currentView";
    DownloadOption["ENTIRE_DOCUMENT_AS_PDF"] = "entireDocumentAsPdf";
    DownloadOption["ENTIRE_DOCUMENT_AS_TEXT"] = "entireDocumentAsText";
    DownloadOption["ENTIRE_FILE_AS_ORIGINAL"] = "entireFileAsOriginal";
    DownloadOption["IMAGE_RENDERINGS"] = "imageRenderings";
    DownloadOption["MANIFEST_RENDERINGS"] = "manifestRenderings";
    DownloadOption["RANGE_RENDERINGS"] = "rangeRenderings";
    DownloadOption["SELECTION"] = "selection";
    //SEQUENCE_RENDERINGS = "sequenceRenderings",
    DownloadOption["UNKNOWN"] = "unknown";
    DownloadOption["WHOLE_IMAGE_HIGH_RES"] = "wholeImageHighRes";
    DownloadOption["WHOLE_IMAGE_LOW_RES"] = "wholeImageLowRes";
    DownloadOption["WHOLE_IMAGES_HIGH_RES"] = "wholeImagesHighRes";
})(DownloadOption || (DownloadOption = {}));


/***/ })

}]);
//# sourceMappingURL=uv-ebook-extension~uv-model-viewer-extension~uv-openseadragon-extension.751ace0dd72d753fb0b5.js.map