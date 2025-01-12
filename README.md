<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# A Bazel/skylark rule for embedding source files as a `cc_library` rule.

This take a files from the build environment a puts it directly into the
data section of a binary, making them accessible as a library.

This allows large test or binary artifacts to come from files (or other build
artifacts) rather than deal with escaping them into string literals.

## `MODULE.bazel`

```
bazel_dep(
    name = "com_github_bcsgh_cc_embed_data",
    version = ...,
)
```

## Example usage:

### `src/BUILD`
```
load("//cc_embed_data:cc_embed_data.bzl", "cc_embed_data")

cc_embed_data(
    name = "cc_embed_example",
    srcs = [
      "foo.bin",
      #...
    ],
    namespace = "my_namespace",
)


cc_test(
    name = "cc_embed_example_usage",
    srcs = ["cc_embed_example_usage.cc"],
    data = SRCS,
    deps = [
        ":cc_embed_example",
        "@com_google_googletest//:gtest_main",
    ],
)

```

### `src/cc_embed_example_usage.cc`

```
#include <string_view>

#include "cc_embed_example_data.h"

void Use(std::string_view);
void Use(std::string_view, std::string_view);

int main() {
  // find one
  Use(my_namespace::src_foo_bin());

  // find all
  for (const auto& i : my_namespace::EmbedIndex()) {
    Use(i.first, i.second);
  }

  return 0;
}

```

<a id="cc_embed_data"></a>

## cc_embed_data

<pre>
load("@com_github_bcsgh_cc_embed_data//cc_embed_data:cc_embed_data.bzl", "cc_embed_data")

cc_embed_data(<a href="#cc_embed_data-name">name</a>, <a href="#cc_embed_data-deps">deps</a>, <a href="#cc_embed_data-srcs">srcs</a>, <a href="#cc_embed_data-a">a</a>, <a href="#cc_embed_data-cc">cc</a>, <a href="#cc_embed_data-h">h</a>, <a href="#cc_embed_data-json">json</a>, <a href="#cc_embed_data-namespace">namespace</a>)
</pre>

Generate a library containing the contents of srcs.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="cc_embed_data-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="cc_embed_data-deps"></a>deps |  A map from build rules to embed to a path (e.g. "files") on the Target object that yeilds a depset of files. (Figuring out what this path should be more or less requiers mucking around with rule implementations. Sorry.)   | <a href="https://bazel.build/rules/lib/dict">Dictionary: Label -> String</a> | optional |  `{}`  |
| <a id="cc_embed_data-srcs"></a>srcs |  The files to embed.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="cc_embed_data-a"></a>a |  The generated cc_library archive. (This must be set for other rules to depend on individual output files.)   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="cc_embed_data-cc"></a>cc |  The generated C++ source file. (This must be set for other rules to depend on individual output files.)   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="cc_embed_data-h"></a>h |  The generated C++ header file. (This must be set for other rules to depend on individual output files.)   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="cc_embed_data-json"></a>json |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="cc_embed_data-namespace"></a>namespace |  If given, the C++ namespace to generate in.   | String | optional |  `""`  |


## Setup (for development)
To configure the git hooks, run `./.git_hooks/setup.sh`
