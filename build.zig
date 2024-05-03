const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const storm = b.addStaticLibrary(.{
        .name = "storm",
        .optimize = optimize,
        .target = target,
    });
    storm.addCSourceFiles(.{ .files = &.{
        "src/adpcm/adpcm.cpp",
        "src/huffman/huff.cpp",
        "src/jenkins/lookup3.c",
        "src/lzma/C/LzFind.c",
        "src/lzma/C/LzmaDec.c",
        "src/lzma/C/LzmaEnc.c",
        "src/pklib/explode.c",
        "src/pklib/implode.c",
        "src/sparse/sparse.cpp",
        "src/FileStream.cpp",
        "src/SBaseCommon.cpp",
        "src/SBaseDumpData.cpp",
        "src/SBaseFileTable.cpp",
        "src/SBaseSubTypes.cpp",
        "src/SCompression.cpp",
        "src/SFileAddFile.cpp",
        "src/SFileAttributes.cpp",
        "src/SFileCompactArchive.cpp",
        "src/SFileCreateArchive.cpp",
        "src/SFileExtractFile.cpp",
        "src/SFileFindFile.cpp",
        "src/SFileGetFileInfo.cpp",
        "src/SFileListFile.cpp",
        "src/SFileOpenArchive.cpp",
        "src/SFileOpenFileEx.cpp",
        "src/SFilePatchArchives.cpp",
        "src/SFileReadFile.cpp",
        "src/SFileVerify.cpp",
    }, .flags = &.{ "-D_7ZIP_ST", "-DUSE_LTM", "-DLTM_DESC" } });

    if (b.systemIntegrationOption("bz2", .{})) {
        storm.linkSystemLibrary("bz2");
    } else {
        const bzip2 = b.dependency("bzip2", .{
            .target = target,
            .optimize = optimize,
            .static = true,
        });
        storm.linkLibrary(bzip2.artifact("bz2"));
    }

    if (b.systemIntegrationOption("z", .{})) {
        storm.linkSystemLibrary("z");
    } else {
        const z_dep = b.dependency("z", .{});
        const z = b.addStaticLibrary(.{
            .name = "z",
            .target = target,
            .optimize = optimize,
        });
        z.addCSourceFiles(.{
            .root = z_dep.path(""),
            .files = &.{
                "adler32.c", "compress.c", "crc32.c",    "deflate.c",
                "gzclose.c", "gzlib.c",    "gzread.c",   "gzwrite.c",
                "inflate.c", "infback.c",  "inftrees.c", "inffast.c",
                "trees.c",   "uncompr.c",  "zutil.c",
            },
            .flags = &.{
                "-DHAVE_SYS_TYPES_H", "-DHAVE_STDINT_H", "-DHAVE_STDDEF_H",
                "-DZ_HAVE_UNISTD_H",
            },
        });
        z.linkLibC();
        storm.addIncludePath(z_dep.path(""));
        storm.linkLibrary(z);
    }

    if (b.systemIntegrationOption("tomcrypt", .{})) {
        storm.linkSystemLibrary("tomcrypt");
    } else {
        const tomcrypt_dep = b.dependency("tomcrypt", .{});
        const tomcrypt = b.addStaticLibrary(.{
            .name = "tomcrypt",
            .target = target,
            .optimize = optimize,
        });
        tomcrypt.addCSourceFiles(.{
            .root = tomcrypt_dep.path(""),
            .files = @import("./tomcrypt_src.zig").files,
            .flags = &.{
                "-DUSE_LTM",                     "-DLTM_DESC",           "-DLTC_SOURCE",
                "-Wall",                         "-Wsign-compare",       "-Wshadow",
                "-Wextra",                       "-Wsystem-headers",     "-Wbad-function-cast",
                "-Wcast-align",                  "-Wstrict-prototypes",  "-Wpointer-arith",
                "-Wdeclaration-after-statement", "-Wwrite-strings",      "-Wno-type-limits",
                "-funroll-loops",                "-fomit-frame-pointer",
            },
        });
        if (b.systemIntegrationOption("tommath", .{})) {
            tomcrypt.linkSystemLibrary("tommath");
        } else {
            const tommath_dep = b.dependency("tommath", .{});

            const tommath = b.addStaticLibrary(.{
                .name = "tommath",
                .target = target,
                .optimize = optimize,
            });
            tommath.addCSourceFiles(.{
                .root = tommath_dep.path(""),
                .files = @import("./tommath_src.zig").files,
                .flags = &.{
                    "-Wall",                         "-Wsign-compare",
                    "-Wextra",                       "-Wshadow",
                    "-Wdeclaration-after-statement", "-Wbad-function-cast",
                    "-Wcast-align",                  "-Wstrict-prototypes",
                    "-Wpointer-arith",               "-Wsystem-headers",
                    "-funroll-loops",                "-fomit-frame-pointer",
                },
            });
            tommath.linkLibC();
            tomcrypt.linkLibrary(tommath);
            tomcrypt.addIncludePath(tommath_dep.path(""));
        }
        tomcrypt.addIncludePath(tomcrypt_dep.path("src/headers"));
        tomcrypt.linkLibC();

        storm.addIncludePath(tomcrypt_dep.path("src/headers"));
        storm.linkLibrary(tomcrypt);
    }

    storm.linkLibCpp();
    storm.installHeadersDirectory(.{ .path = "src" }, ".", .{});
    b.installArtifact(storm);
}
