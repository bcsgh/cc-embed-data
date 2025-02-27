# Copyright (c) 2022, Benjamin Shropshire,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

load("@bazel_skylib//lib:sets.bzl", "sets")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@com_github_bcsgh_build_test//build_test:build.bzl", "build_test")
load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_test.bzl", "cc_test")
load("//cc_embed_data:cc_embed_data.bzl", "cc_embed_data")

##### SUCCESS case

def _cc_embed_data_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    asserts.set_equals(
        env,
        sets.make([
            "cc_embed_data_example_emebed_data.cc",
            "cc_embed_data_example_emebed_data.h",
            "libcc_embed_data_example.a",
        ]),
        sets.make([
            f.basename
            for f in target_under_test[DefaultInfo].files.to_list()
        ]),
    )
    return analysistest.end(env)

cc_embed_data_contents_test = analysistest.make(_cc_embed_data_contents_test_impl)

##### Go

def cc_embed_data_suite(name):
    # Success

    SRCS = native.glob(["*"])

    cc_embed_data(
        name = "cc_embed_data_example",
        srcs = SRCS,
        namespace = "test_ns",
        cc = "cc_embed_data_example_emebed_data.cc",
        h = "cc_embed_data_example_emebed_data.h",
        a = "libcc_embed_data_example.a",
    )

    build_test(
        name = "cc_embed_data_example_build_test",
        targets = [":cc_embed_data_example"],
    )

    cc_test(
        name = "cc_embed_data_example_live_test",
        srcs = ["cc_embed_data_example_test.cc"],
        data = SRCS,
        deps = [
            ":cc_embed_data_example",
            "@googletest//:gtest_main",
        ],
    )

    cc_embed_data_contents_test(
        name = "cc_embed_data_contents_test",
        target_under_test = ":cc_embed_data_example",
    )

    native.genrule(
        name = "generated",
        outs = ["generated.txt"],
        cmd = "touch $@",
    )

    SHORT_SRC = [
        "cc_embed_data_test.bzl",  # local static
        ":generated.txt",  #       # local generated
        ":testdata/nested.txt",  # # dir inside a package

        # extern static
        "@bazel_skylib//:LICENSE",
        "@bazel_tools//tools/genrule:genrule-setup.sh",
        # extern generated (TODO)
    ]

    cc_embed_data(
        name = "cc_embed_data_short",
        srcs = SHORT_SRC,
        namespace = "test_ns",
        cc = "cc_embed_data_short_emebed_data.cc",
        h = "cc_embed_data_short_emebed_data.h",
        a = "libcc_embed_data_short.a",
        json = "cc_embed_data_short_emebed_data.json",  # export for debugging
    )

    EXT = ["cc", "h"]
    gt = [diff_test(
        name = "diff_%s_test" % e,
        file1 = "cc_embed_data_short_emebed_data." + e,
        file2 = "cc_embed_data_short_emebed_data.gold." + e,
    ) for e in EXT]

    build_test(
        name = "cc_embed_data_short_build_test",
        targets = [":cc_embed_data_short"],
    )

    cc_test(
        name = "cc_embed_data_short_live_test",
        srcs = ["cc_embed_data_short_test.cc"],
        data = SHORT_SRC,
        deps = [
            ":cc_embed_data_short",
            "@googletest//:gtest_main",
        ],
    )

    cc_embed_data(
        name = "cc_embed_data_deps",
        deps = {":cc_embed_data_example": "files"},
        namespace = "test_ns",
        cc = "cc_embed_data_deps_emebed_data.cc",
        h = "cc_embed_data_deps_emebed_data.h",
        a = "libcc_embed_data_deps.a",
    )

    build_test(
        name = "cc_embed_data_deps_build_test",
        targets = [":cc_embed_data_deps"],
    )

    cc_test(
        name = "cc_embed_data_deps_live_test",
        srcs = ["cc_embed_data_deps_test.cc"],
        deps = [
            ":cc_embed_data_deps",
            "@googletest//:gtest_main",
        ],
    )

    cc_embed_data(
        name = "cc_embed_data_names",
        srcs = ["//tests/testdata2:nametest_group"],
        namespace = "test_ns",
        cc = "cc_embed_data_names.cc",
        h = "cc_embed_data_names.h",
        a = "cc_embed_data_names.a",
    )

    cc_binary(
        name = "names_main",
        srcs = ["names_main.cc"],
        deps = [":cc_embed_data_names"],
    )

    build_test(
        name = "cc_embed_data_names_build_test",
        targets = [":names_main", ":cc_embed_data_names"],
    )

    # Suit
    native.test_suite(
        name = name,
        tests = [
            ":cc_embed_data_example_build_test",
            ":cc_embed_data_example_live_test",
            ":cc_embed_data_short_build_test",
            ":cc_embed_data_short_live_test",
            ":cc_embed_data_contents_test",
            ":cc_embed_data_deps_build_test",
            ":cc_embed_data_deps_live_test",
            ":cc_embed_data_names_build_test",
        ] + [
            ":diff_%s_test" % e
            for e in EXT
        ],
    )
