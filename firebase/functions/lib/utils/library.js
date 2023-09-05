"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Library = void 0;
/**
 * @file utils.ts
 */
class Library {
    /**
     *
     * @param min
     * @param max
     * @returns
     */
    static getRandomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }
    // static uuid() {
    //   return uuidv4();
    // }
    /**
     * Wait for milliseconds.
     *
     * @param ms milliseconds
     * @return Promise
     *
     * @example
     *  await Utils.delay(3000);
     */
    static async delay(ms) {
        return new Promise((res) => {
            setTimeout(res, ms);
        });
    }
    /**
     * Convert html entities into code.
     *
     * @param content string with HTML string.
     * @return string without html tags.
     */
    static removeHtmlTags(content) {
        if (content) {
            return content.replace(/<[^>]+>/g, "");
        }
        else {
            return content;
        }
    }
    /**
     * Convert html entities into code.
     *
     * @param {*} text HTML string
     */
    static decodeHTMLEntities(text) {
        const entities = {
            "amp": "&",
            "apos": "'",
            "#x27": "'",
            "#x2F": "/",
            "#39": "'",
            "#47": "/",
            "lt": "<",
            "gt": ">",
            "nbsp": " ",
            "quot": "\"",
            "bull": "•",
        };
        return text.replace(/&([^;]+);/gm, function (match, entity) {
            return entities[entity] || match;
        });
    }
    /**
     * Divide an array into many
     *
     * @param {*} arr array
     * @param {*} chunkSize chunk size
     */
    static chunk(arr, chunkSize) {
        if (chunkSize <= 0)
            return [];
        const chunks = [];
        for (let i = 0, len = arr.length; i < len; i += chunkSize) {
            chunks.push(arr.slice(i, i + chunkSize));
        }
        return chunks;
    }
    static commentOrder(order, depth, noOfComments) {
        // 코멘트 트리 구조를 표현하기 위한 정렬 문자열 생성
        //
        // 참고, `맨 처음 코멘트`란, 글에 최초로 작성되는 첫 번째 코멘트. 맨 처음 코멘트는 1개만 존재한다.
        // 참고, `첫번째 레벨 코멘트`란, 글 바로 아래에 작성되는 코멘트로,
        // 부모 코멘트가 없는 코멘트이다. 여러개의 코멘트가 있다.
        // 참고, `부모 코멘트`란, 자식 코멘트가 있는 코멘트 또는 자식을 만들 코멘트.
        // 참고, `자식 코멘트`란, 부모 코멘트 아래에 작성되는 코멘트 또는 부모 코멘트가 있는 코멘트.
        //
        // [order] 는
        //   - `첫 번째 레벨 코멘트(부모가 없는 코멘트)` 에는 빈 문자열 또는 null,
        //   - `자식 코멘트`를 생성 할 때, 부모 코멘트의 order 값을 그대로 전달하면 된다.
        //
        // [depth] 는
        //   - `첫 번째 레벨 코멘트(부모가 없는 코멘트)`에서는 0(또는 null),
        //   - `자식 코멘트(부모가 있는 코멘트)`의 경우, 부모 코멘트의 depth + 1 값을 전달하면 된다.
        //
        // [noOfComment] 는 항상 **글의 noOfComments 값**을 전달하면 된다.
        //   원래는 코멘트마다 noOfComment 값을 가지고 있고,
        // 이 함수에서 글 또는 부모 코멘트의 noOfComments 를 받아서,
        //   처리를 했는데, 이 함수가 문제가 아니라,
        // 부모 코멘트마다 noOfComments 를 유지하는 것이, 플러터플로의 복잡도를 높이는
        //   것이되어, 그냥 글의 noOfComments 를 사용하도록 변경했다.
        //
        //
        // 참고, 이 함수는 depth 의 값을 0(또는 null)으로 입력 받지만,
        // 실제 코멘트 DB(문서)에 저장하는 값은 1부터 시작하는 것을
        //   원칙으로 한다. 예를 들면, depth 값을 1 증가 시키기 위해서,
        // +1 증가시키는 함수(IncreaseInteger)를 써야 하는데,
        //   첫번째 레벨의 경우(부모 코멘트가 없는 경우),
        // IncreaseInteger 함수에 0(NULL)을 지정하면 +1을 해서, 1 값이 리턴된다.
        //   그 값을 코멘트 DB(문서)의 depth 에 저장하므로, 자연스럽게 1 부터 시작하는 것이다.
        //   또는 첫번째 레벨의 코멘트는 그냥 depth=1 로 지정하면 된다.
        //   그리고 DB(문서)의 depth 는 사실,
        // 0으로 시작하든 1로 시작하던, UI 랜더링 할 때, depth 만 잘 표현하면 된다.
        //
        // 참고, [depth] 가 16 단계 이상으로 깊어지면,
        // 16 단계 이상의 코멘트는 순서가 뒤죽 박죽이 될 수 있다.
        //   이 때, 전체가 다 뒤죽 박죽이 되는 것이 아니라,
        // 16단계 이내에서는 잘 정렬되어 보이고, 17단계 이상의 코멘트 들만
        //   정렬이 안되, 17단계, 18단계, 19단계...
        // 등 모두 16단계 부모의 [order] 를 가지므로 16단계 (들여쓰기)아래애서만
        //   어떤 것이 먼저 쓰였는지 구분하기 어렵게 된다.
        //
        // 참고, 총 90만개의 코멘트를 지원한다.
        order !== null && order !== void 0 ? order : (order = Array(16).fill("100000").join("."));
        depth !== null && depth !== void 0 ? depth : (depth = 0);
        noOfComments !== null && noOfComments !== void 0 ? noOfComments : (noOfComments = 0);
        if (depth >= 16)
            return order;
        // print("order(in): $order, depth: $depth");
        if (noOfComments == 0) {
            return order;
        }
        else {
            const parts = order.split(".");
            const no = parts[depth];
            // print('no=$no, depth=$depth, parts=$parts');
            const computed = parseInt(no) + noOfComments;
            // print("computed: $computed, depth: $depth");
            parts[depth] = computed.toString();
            order = parts.join(".");
            // print("order(out): $order");
            return order;
        }
    }
    /**
     * Returns the file path in the storage from the given [url].
     * @param url the URL of firebase storage image(or file)
     * @return the path of the image(or file) in firebase storage.
     */
    static getPathFromUrl(url) {
        // console.log("deleting url: ", url);
        const token = url.split("?");
        const parts = token[0].split("/");
        const path = parts[parts.length - 1].replace(/%2F/gi, "/");
        // console.log("path: ", path);
        return path;
    }
}
exports.Library = Library;
//# sourceMappingURL=library.js.map