
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const chunk = (arr: any[], size: number) =>
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    Array.from({ length: Math.ceil(arr.length / size) }, (_: any, i: number) =>
        arr.slice(i * size, i * size + size)
    );
