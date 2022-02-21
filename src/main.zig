const io = @import("std/io.zig");
const delay = @import("util/delay.zig").delayMs;
const uart = @import("serial/uart.zig");

pub fn main() void {
    io.init(5, .b, .output);
    uart.init(115200);
    uart.sendStringLn("hello world!");

    while (true) {
        io.toggle(5, .b);

        var str = uart.receiveString();
        uart.sendString("done. received: ");
        uart.sendStringLn(str);

        delay(200);
    }
}
