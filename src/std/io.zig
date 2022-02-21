const SFR = @import("sfr.zig").SFR;

const DDRB = SFR(0x24, u8, packed struct {
    DDB0: u1 = 0,
    DDB1: u1 = 0,
    DDB2: u1 = 0,
    DDB3: u1 = 0,
    DDB4: u1 = 0,
    DDB5: u1 = 0,
    DDB6: u1 = 0,
    DDB7: u1 = 0,
});

const PORTB = SFR(0x25, u8, packed struct {
    PORTB0: u1 = 0,
    PORTB1: u1 = 0,
    PORTB2: u1 = 0,
    PORTB3: u1 = 0,
    PORTB4: u1 = 0,
    PORTB5: u1 = 0,
    PORTB6: u1 = 0,
    PORTB7: u1 = 0,
});

const DDRC = SFR(0x27, u8, packed struct {
    DDC0: u1 = 0,
    DDC1: u1 = 0,
    DDC2: u1 = 0,
    DDC3: u1 = 0,
    DDC4: u1 = 0,
    DDC5: u1 = 0,
    DDC6: u1 = 0,
    DDC7: u1 = 0,
});

const PORTC = SFR(0x28, u8, packed struct {
    PORTC0: u1 = 0,
    PORTC1: u1 = 0,
    PORTC2: u1 = 0,
    PORTC3: u1 = 0,
    PORTC4: u1 = 0,
    PORTC5: u1 = 0,
    PORTC6: u1 = 0,
    PORTC7: u1 = 0,
});

const DDRD = SFR(0x2A, u8, packed struct {
    DDD0: u1 = 0,
    DDD1: u1 = 0,
    DDD2: u1 = 0,
    DDD3: u1 = 0,
    DDD4: u1 = 0,
    DDD5: u1 = 0,
    DDD6: u1 = 0,
    DDD7: u1 = 0,
});

const PORTD = SFR(0x2B, u8, packed struct {
    PORTD0: u1 = 0,
    PORTD1: u1 = 0,
    PORTD2: u1 = 0,
    PORTD3: u1 = 0,
    PORTD4: u1 = 0,
    PORTD5: u1 = 0,
    PORTD6: u1 = 0,
    PORTD7: u1 = 0,
});

pub fn init(comptime pin: u8, comptime ddrx: enum(u8) { b = 0, c, d }, comptime mode: enum(u1) { input = 0, output }) void {
    const pins = switch (ddrx) {
        .b => DDRB,
        .c => DDRC,
        .d => DDRD,
    };
    pins.write_int(@as(u8, @enumToInt(mode)) << pin);
}

pub fn set(comptime portx: enum(u3) { b = 0, c, d }, comptime pin: u8, mode: enum(u1) { low, high }) void {
    const pins = switch (portx) {
        .b => PORTB,
        .c => PORTC,
        .d => PORTD,
    };
    pins.write_int(mode << pin);
}

pub fn toggle(comptime pin: u8, comptime portx: enum(u3) { b = 0, c, d }) void {
    const port = switch (portx) {
        .b => PORTB,
        .c => PORTC,
        .d => PORTD,
    };

    var val = port.read_int();
    val ^= 1 << pin;
    port.write_int(val);
}
