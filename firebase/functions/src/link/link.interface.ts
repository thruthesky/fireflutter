export interface LinkCredential {
    value: string;
}

export interface AndroidCredential {
    [key: string]: Array<string>;
}

export interface AppleCredential {
    apps: Array<string>;
}

export interface HtmlDeepLink {
    html?: string;
    appStoreUrl?: string;
    playStoreUrl?: string;
    webUrl?: string;
    deepLinkUrl?: string;
    // TODO title, content, image
}
