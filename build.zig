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
        "src/libtomcrypt/src/pk/rsa/rsa_verify_simple.c",
        "src/libtomcrypt/src/misc/crypt_libc.c",
    }, .flags = &.{"-D_7ZIP_ST"} });

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
        // const z = b.dependency("z", .{
        //     .target = target,
        //     .optimize = optimize,
        // });
        // storm.linkLibrary(z);
        // storm.linkLibrary(z.artifact("z"));
    }
    if (b.systemIntegrationOption("tommath", .{})) {
        storm.linkSystemLibrary("tommath");
    } else {
        // const tommath = b.dependency("tommath", .{
        //     .target = target,
        //     .optimize = optimize,
        // });
        // storm.linkLibrary(tommath);
        // storm.linkLibrary(tommath.artifact("tommath"));
    }

    if (b.systemIntegrationOption("tomcrypt", .{})) {
        storm.linkSystemLibrary("tomcrypt");
    } else {
        // const tomcrypt = b.dependency("tomcrypt", .{
        //     .target = target,
        //     .optimize = optimize,
        // });
        // storm.linkLibrary(tomcrypt);
        // storm.linkLibrary(tomcrypt.artifact("tomcrypt"));
    }
    // storm.addIncludePath(.{ .path = "src" });
    storm.linkLibCpp();
    b.installArtifact(storm);
}
