
import { typesenseApiKey, typesenseHost, typesenseProtocol } from "./key";

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
    static userFcmTokensPath = "user-fcm-tokens";


    // Forum paths
    static posts = "posts";
    static postSummaries = "post-summaries";
    static postAllSummaries = "post-all-summaries";
    static postSubscriptions = "post-subscriptions";


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
     * 푸시 알림을 보낼 때, dry run 을 할 것인지 여부.
     *
     * dry run 을 true 로 하면, 실제로 메시지가 전달되지 않는다. 즉, 테스트 할 때에만 true 로 한다.
     */
    static messagingDryRun = false;

    /**
     * Typsense Api Key
     *
     */
    static typesenseApiKey = typesenseApiKey;
    static typesenseHost = typesenseHost;
    static typesensePort = 8080;
    static typesenseProtocol = typesenseProtocol;


    /**
     * Link setup
     */
    static appleTeamId = "S367SCV66A";
    static iosBundleId = "com.withcenter.roha";
    static iosLinkId = "id6478899497";
    static androidBundleId = "com.withcenter.roha";
}
