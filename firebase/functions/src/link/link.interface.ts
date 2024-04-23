export interface LinkCredential {
    value: string;
}

export interface AndroidCredential {
    [key: string]: Array<string>;
}

export interface AppleCredential {
    apps: Array<string>;
}

