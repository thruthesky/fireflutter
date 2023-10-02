"use strict";
// The MIT License (MIT)
//
// Copyright (c) 2018 Firebase
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
Object.defineProperty(exports, "__esModule", { value: true });
exports.wrapV2 = void 0;
const generate_1 = require("./cloudevent/generate");
/**
 * Takes a v2 cloud function to be tested, and returns a {@link WrappedV2Function}
 * which can be called in test code.
 */
function wrapV2(cloudFunction) {
    var _a, _b;
    if ((_a = cloudFunction === null || cloudFunction === void 0 ? void 0 : cloudFunction.__endpoint) === null || _a === void 0 ? void 0 : _a.callableTrigger) {
        throw new Error('Wrap function is not available for callableTriggers functions.');
    }
    if (!cloudFunction.run) {
        throw new Error('This library can only be used with functions written with firebase-functions v3.20.0 and above');
    }
    if (((_b = cloudFunction === null || cloudFunction === void 0 ? void 0 : cloudFunction.__endpoint) === null || _b === void 0 ? void 0 : _b.platform) !== 'gcfv2') {
        throw new Error('This function can only wrap V2 CloudFunctions.');
    }
    return (cloudEventPartial) => {
        const cloudEvent = (0, generate_1.generateCombinedCloudEvent)(cloudFunction, cloudEventPartial);
        return cloudFunction.run(cloudEvent);
    };
}
exports.wrapV2 = wrapV2;
