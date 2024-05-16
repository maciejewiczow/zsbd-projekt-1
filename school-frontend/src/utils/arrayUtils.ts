export const ascendingBy =
    <T>(selector: (val: T) => number) =>
    (a: T, b: T) =>
        selector(a) - selector(b);

export const descendingBy =
    <T>(selector: (val: T) => number) =>
    (a: T, b: T) =>
        selector(b) - selector(a);
