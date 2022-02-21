const loops = @import("delay_loops.zig");
const freq = @import("../atmega328p.zig").cpu_freq;

pub fn delayMs(comptime ms: f64) void {
    var ticks: u16 = undefined;
    var tmp: f64 = ((freq) / 4e3) * ms;

    if (tmp < 1) {
        ticks = 1;
    } else if (tmp > 65535) {
        ticks = @floatToInt(u16, ms * 10);
        while (ticks > 0) {
            // wait 1/10 ms
            loops.delayLoop2((freq / 4e3) / 10.0);
            ticks -= 1;
        }
        return;
    } else {
        ticks = @floatToInt(u16, tmp);
        loops.delayLoop2(ticks);
    }
}

pub fn delayUs(comptime us: f64) void {
    var ticks: u16 = undefined;
    var tmp2: f64 = undefined;

    var tmp: f64 = ((freq) / 3e6) * us;
    tmp2 = ((freq) / 4e6) * us;

    if (tmp < 1.0) {
        ticks = 1;
    } else if (tmp2 > 65535) {
        delayMs(us / 1000);
    } else if (tmp > 255) {
        ticks = @floatToInt(u16, tmp2);
        loops.delayLoop2(ticks);
        return;
    } else {
        ticks = @floatToInt(u16, tmp);
        loops.delayLoop1(ticks);
    }
}
