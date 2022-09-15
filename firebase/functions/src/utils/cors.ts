import * as functions from "firebase-functions";
import * as express from "express";

/**
 * 입력된 값 e 가 에러 문자열이면, 에러 객체 { code: e } 와 같이 리턴, 아니면 입력된 값을 드래도 리턴.
 *
 * @param e e 가 만약 에러 문자열이이면
 * @returns 에러 object 또는 입력된 object.
 */
export function sanitizeError(e: any): any {
  if (typeof e === "string" && e.startsWith("ERROR_")) {
    return { code: e };
  } else {
    // Firebase error and other error might come here.
    return e;
  }
}

/**
 * 모든 HTTP request 는 preflight 과 실제 호출, 두 번 발생한다.
 *
 * preflight 호출에서는 관련 옵션을 출력하고 callback() 을 호출 하지 않는다. 즉, 옵션만 출력하고 종료하는 것이다.
 * 실제 호출에서는 callback() 을 호출하고 종료한다.
 *
 *
 * @param options Call function via HTTP request 의 입력 값
 * @param callback cors 해결 후 호출해야 하는 callback 함수
 */
export async function cors(
    options: {
    req: functions.https.Request;
    res: express.Response;
    auth?: boolean;
  },
    callback: (data: any) => Promise<void>
) {
  const req = options.req;
  const res = options.res;
  res.set("Access-Control-Allow-Origin", "*");

  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "GET");
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Methods", "DELETE");
    res.set("Access-Control-Allow-Methods", "PUT");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.set("Access-Control-Max-Age", "3600");
    res.status(204).send("");
  } else {
    const data = Object.assign({}, req.body, req.query);

    callback(data).catch((e) => {
      res.status(200).send(sanitizeError(e));
    });
  }
}
