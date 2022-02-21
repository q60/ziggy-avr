const main = @import("main.zig");
const vectors = @import("vectors.zig");
const uart = @import("serial/uart.zig");

pub export fn _start() callconv(.Naked) noreturn {
    // At startup the stack pointer is at the end of RAM
    // so, no need to set it manually!

    // Reference this such that the file is analyzed and the vectors
    // are added.
    _ = vectors;

    copyDataToRAM();
    clearBSS();

    main.main();
    while (true) {}
}

fn copyDataToRAM() void {
    asm volatile (
        \\     ; load Z register with the address of the data in flash
        \\     LDI  R30, lo8(__data_load_start)
        \\     LDI  R31, hi8(__data_load_start)
        \\     ; load X register with address of the data in ram
        \\     LDI  R26, lo8(__data_start)
        \\     LDI  R27, hi8(__data_start)
        \\     ; load address of end of the data in ram
        \\     LDI  R24, lo8(__data_end)
        \\     LDI  R25, hi8(__data_end)
        \\     RJMP .L2
        \\
        \\.L1: lpm  R18, Z+ ; copy from Z into r18 and increment Z
        \\     ST   X+,  R18  ; store r18 at location X and increment X
        \\
        \\.L2: CP   R26, R24
        \\     CPC  R27, R25 ; check and branch if we are at the end of data
        \\     BRNE .L1
    );
    // Probably a good idea to add clobbers here, but compiler doesn't seem to care
}

fn clearBSS() void {
    asm volatile (
        \\     ; load X register with the beginning of bss section
        \\     LDI  R26, lo8(__bss_start)
        \\     LDI  R27, hi8(__bss_start)
        \\     ; load end of the bss in registers
        \\     LDI  R24, lo8(__bss_end)
        \\     LDI  R25, hi8(__bss_end)
        \\     LDI  R18, 0x00
        \\     RJMP .L4
        \\
        \\.L3: ST   X+,  R18
        \\
        \\.L4: CP   R26, R24
        \\     CPC  R27, R25 ; check and branch if we are at the end of bss
        \\     BRNE .L3
    );
    // Probably a good idea to add clobbers here, but compiler doesn't seem to care
}

pub fn panic(msg: []const u8, error_return_trace: ?*@import("std").builtin.StackTrace) noreturn {
    // Currently assumes that the uart is initialized in main().
    uart.sendString("PANIC: ");
    uart.sendString(msg);

    // TODO: print stack trace (addresses), which can than be turned into actual source line
    //       numbers on the connected machine.
    _ = error_return_trace;
    while (true) {}
}
