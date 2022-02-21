const SFR = @import("../std/sfr.zig").SFR;
const mcu = @import("../atmega328p.zig");

const UDR = SFR(0xc6, u8, packed union {
    RXB: u8,
    TXB: u8,
});

const UCSRA = SFR(0xc0, u8, packed struct {
    MPCM: u1 = 0, // D0
    U2X: u1 = 0, // D1
    PE: u1 = 0, // D2
    DOR: u1 = 0, // D3
    FE: u1 = 0, // D4
    UDRE: u1 = 0, // D5
    TXC: u1 = 0, // D6
    RXC: u1 = 0, // D7
});

const UCSRB = SFR(0xc1, u8, packed struct {
    TXB8: u1 = 0, // D0
    RXB8: u1 = 0, // D1
    UCSZ2: u1 = 0, // D2
    TXEN: u1 = 0, // D3
    RXEN: u1 = 0, // D4
    UDREIE: u1 = 0, // D5
    TXCIE: u1 = 0, // D6
    RXCIE: u1 = 0, // D7
});

const UCSRC = SFR(0xc2, u8, packed struct {
    UCPOL: u1 = 0, // D0
    UCSZ0: u1 = 0, // D1 1
    UCSZ1: u1 = 0, // D2 1
    USBS: u1 = 0, // D3
    UPM0: u1 = 0, // D4
    UPM1: u1 = 0, // D5
    UMSEL: u1 = 0, // D6
    URSEL: u1 = 0, // D7
});

const UBRRL = SFR(0xc4, u8, packed struct {
    USART: u8 = 0, // UBRR[7:0]
});

const UBRRH = SFR(0xc5, u8, packed struct {
    USART: u4 = 0, // D11:D8 - UBRR[11:8]
    reserved: u3 = 0, // D14:D12
    URSEL: u1 = 0, // D15
});

pub fn init(comptime baud: comptime_int) void {
    // given 9600 baud rate and 16MHz CPU frequency we get UBRR of
    // 103 = 0b000001100111 first 8 bits of which should go to UBRRL
    // other 4 bits go to UBRRH
    // 8 - async doublle speed mode
    const ubrr: u12 = mcu.cpu_freq / (8 * baud) - 1;

    UBRRL.write(.{ .USART = ubrr });
    UBRRH.write(.{ .USART = ubrr >> 8 });

    // we have initiallized zeroed UCSRA, so we need to enable U2X
    UCSRA.write(.{
        .U2X = 1,
    });

    // allow receive and transmit
    UCSRB.write(.{ // 0b00011000
        .TXEN = 1,
        .RXEN = 1,
    });

    UCSRC.write(.{ // 0b10000110
        .UCSZ0 = 1,
        .UCSZ1 = 1,
        .URSEL = 1,
    });
}

pub fn receiveChar() u8 {
    while (UCSRA.read().RXC != 1) {}
    return UDR.read().RXB;
}

pub fn receiveString() []u8 {
    var res: [0x40]u8 = undefined;

    const first_ch: u8 = receiveChar();
    var next_ch: u8 = first_ch;
    var counter: u8 = 0;

    while (next_ch != '\r') {
        sendChar(next_ch);
        res[counter] = next_ch;
        counter += 1;
        next_ch = receiveChar();
    }

    sendString("\r\n");
    return res[0..counter];
}

pub fn sendChar(ch: u8) void {
    while (UCSRA.read().UDRE != 1) {}
    UDR.write(.{ .TXB = ch });
}

pub fn sendString(str: []const u8) void {
    for (str) |ch| {
        if (ch != 0) {
            sendChar(ch);
        } else {
            break;
        }
    }
}

pub fn sendStringLn(str: []const u8) void {
    sendString(str);
    sendString("\r\n");
}
