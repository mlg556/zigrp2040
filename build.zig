const std = @import("std");
const rp2040 = @import("rp2040");

pub fn build(b: *std.Build) void {
    const microzig = @import("microzig").init(b, "microzig");
    const optimize = b.standardOptimizeOption(.{});
    const main = .{ .name = "main", .target = rp2040.boards.raspberry_pi.pico, .file = "src/main.zig" };

    const firmware = microzig.addFirmware(b, .{
        .name = main.name,
        .target = main.target,
        .optimize = optimize,
        .source_file = .{ .path = main.file },
    });

    microzig.installFirmware(b, firmware, .{});
    microzig.installFirmware(b, firmware, .{ .format = .elf });

    // // flash it using picoprobe/openocd
    // const elf_path = "zig-out/firmware/main.elf";
    // _ = elf_path;

    // zig fmt: off
    const flash_cmd = b.addSystemCommand(&[_][]const u8{
        "openocd",
        "-f", "interface/cmsis-dap.cfg",
        "-f", "target/rp2040.cfg",
        "-c", "adapter speed 5000",
        "-c", "program zig-out/firmware/main.elf verify reset exit"
    });
    // zig fmt: on
    flash_cmd.step.dependOn(b.default_step);

    const flash_step = b.step("flash", "flash firmware using OpenOCD");
    flash_step.dependOn(&flash_cmd.step);

    // openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c "adapter speed 5000" -c "program zig-out/firmware/main.elf verify reset exit"

    // b.default_step.dependOn(&cmd.step);

    // std.debug.print("{s}", elf_path);
    // // flash_cmd.addArgs();

    // flash_step.dependOn(b.default_step);
}
