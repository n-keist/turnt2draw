const chars = 'ABCDEF123456789';

export default (length: number = 6): string => {
    let out = '';
    for (let i = 0; i < length; i++) {
        out += chars[Math.floor(Math.random() * chars.length)];
    }
    return out;
}