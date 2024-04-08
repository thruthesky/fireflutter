export interface LinkCredential {
    value: string;
}

export interface AndroidCredential {
    [key: string]: Array<string>;
}

export interface AppleCredential {
    [key: string]: string;
}
