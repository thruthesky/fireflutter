

/**
 * Config
 *
 * 기본적으로 설정을 하는 클래스
 */
export class Config {
    // debug = true 이면, 함수에 로그를 남긴다.
    static debug = true;

    // Cloud Functions Server Resion
    static region = "asia-southeast1";

    static typesenseCollection = "silversSearch";
    // testing
    // static typesenseCollection = "testSearch";

    // User paths
    static users = "users";
    static whoLikeMe = "who-like-me";
    static whoILike = "who-i-like";

    // Path to save tokens
    // 테스트를 할 때에는 "user-fcm-tokens-test" 경로를 사용한다.
    static userFcmTokens = "user-fcm-tokens";
    static pushNotificationLogs = "push-notification-logs";

    // 푸시 알림 기록을 기록할 것인지 여부.
    // 이 값을 true 로 하면, 푸시 알림을 한 후, 그 결과를 DB 에 기록한다. 로그를 기록하면 DB 용량이 커 질 수 있으므로 주의해야 한다.
    // 개발 및 테스트 할 때에는 이 값을 true 로 해서, 확인을 해 볼 필요가 있다.
    static logPushNotificationLogs = true;

    // user settings
    static userSettings = "user-settings";


    // Forum paths
    static posts = "posts";
    static postSummaries = "post-summaries";
    static postAllSummaries = "post-all-summaries";
    static postSubscriptions = "post-subscriptions";

    static comments = "comments";


    // Command paths
    static commands = "commands";

    /**
     * debug 가 true 일 때만 로그를 남긴다.
     * @param message message to log
     * @param optionalParams optinal parameters to log
     */
    static log(message: string,
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        ...optionalParams: any[]) {
        if (Config.debug) {
            console.log(message, ...optionalParams);
        }
    }


    /**
     * 푸시 알림을 보낼 때, 잘못된 토큰이 있으면 삭제를 할 것인지 여부.
     *
     * 주의 할 점은 올바른 토큰임에도 불구하고 Network 에러나 기타 설정, 서버 등의 에러로 인해서 푸시 알림 전송시 에러(잘못된 토큰)로 인식될 수 있다.
     * 그래서, 가능한 이 값을 false 로 하여, 푸시 알림을 할 때 잘못된 토큰을 삭제하지 않을 것을 권장한다. 잘못된 토큰을 DB 에 계속 남겨 두고, 반복적으로 푸시 알림 에러가 떠도 큰 문제가 없다.
     * 이 값이 true 로 지정되면, 잘못된 토큰을 삭제한다.
     */
    static removeBadTokens = false;

    /**
     * 푸시 알림을 보낼 때, dry run 을 할 것인지 여부.
     *
     * dry run 을 true 로 하면, 실제로 메시지가 전달되지 않는다. 즉, 테스트 할 때에만 true 로 한다.
     */
    static messagingDryRun = false;

    /**
     * Typsense Api Key
     *
     */
    // static typesenseApiKey = typesenseApiKey;
    // static typesenseHost = typesenseHost;
    // static typesensePort = 8080;
    // static typesenseProtocol = typesenseProtocol;
}
