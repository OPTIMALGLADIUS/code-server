let macAddress: string | undefined;

export function getMac(): string {
    // Generate a completely random, valid MAC address once per session
    if (!macAddress) {
        const hex = () => Math.floor(Math.random() * 256).toString(16).padStart(2, '0');
        macAddress = `${hex()}:${hex()}:${hex()}:${hex()}:${hex()}:${hex()}`;
    }
    return macAddress;
}
