/**
 * Config
 *
 * 기본적으로 설정을 하는 클래스
 */
export class Config {
    static typesenseCollection = "momcafeSearch";


    // token 을 저장하는 경로
    // 테스트를 할 때에는 "user-fcm-tokens-test" 경로를 사용한다.
    static userFcmTokensPath = "user-fcm-tokens";

    static postsSubscriptionPath = "posts-subscription";
}

