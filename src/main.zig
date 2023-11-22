const std = @import("std");
const microzig = @import("microzig");

const rp2040 = microzig.hal;
const time = rp2040.time;
const gpio = rp2040.gpio;
const clocks = rp2040.clocks;

const led_r = gpio.num(18);
const led_g = gpio.num(19);
const led_b = gpio.num(20);

const uart = rp2040.uart.num(0);
const baud_rate = 115200;

const uart_tx_pin = gpio.num(0);
const uart_rx_pin = gpio.num(1);

pub fn panic(message: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    std.log.err("panic: {s}", .{message});
    @breakpoint();
    while (true) {}
}

pub const std_options = struct {
    pub const log_level = .debug;
    pub const logFn = rp2040.uart.log;
};

pub fn main() !void {
    led_r.set_function(.sio);
    led_r.set_direction(.out);
    led_r.put(1);

    led_g.set_function(.sio);
    led_g.set_direction(.out);
    led_g.put(1);

    led_b.set_function(.sio);
    led_b.set_direction(.out);
    led_b.put(1);

    uart.apply(.{
        .baud_rate = baud_rate,
        .tx_pin = uart_tx_pin,
        .rx_pin = uart_rx_pin,
        .clock_config = rp2040.clock_config,
    });

    rp2040.uart.init_logger(uart);

    var i: u32 = 0;
    while (true) : (i += 1) {
        led_b.put(0);
        std.log.info("Hello world! ({})", .{i});
        time.sleep_ms(1_000);

        led_b.put(1);
        time.sleep_ms(1_000);
    }
}