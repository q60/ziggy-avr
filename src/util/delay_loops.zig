pub fn delayLoop1(count: u16) void {
    _ = asm volatile (
        \\1: DEC %[count]
        \\   BRNE 1b
        : [ret] "=r" (-> u8),
        : [count] "0" (count),
    );
}

pub fn delayLoop2(count: u16) void {
    _ = asm volatile (
        \\1: SBIW %[count], 1
        \\   BRNE 1b
        : [ret] "=w" (-> u16),
        : [count] "0" (count),
    );
}
