// Copyright (c) 2018, Benjamin Shropshire,
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <cstdlib>
#include <fstream>
#include <string>
#include <vector>

#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include "tests/cc_embed_data_short_emebed_data.h"

namespace {

std::string ReadFile(const std::string& path) {
  const static auto ms = test_ns::OriginMap();
  const static std::map<std::string, std::string> m{ms.begin(), ms.end()};

  auto mapped_path = m.find(path)->second;

  std::string r = "external/";
  if (mapped_path.find(r) == 0) mapped_path.replace(0, r.size(), "../");

  std::ifstream ifs{mapped_path,
                    std::ios::in | std::ios::binary | std::ios::ate};
  if (ifs.fail() || !ifs.is_open()) {
    std::cerr << "Failed to open [" << mapped_path << "]\n";
    return "@@@ FAILED TO OPEN @@@";
  }

  std::string::size_type size = ifs.tellg();
  ifs.seekg(0, std::ios::beg);

  std::string ret(size, '\0');
  ifs.read(&*ret.begin(), size);
  return ret;
}

TEST(CcEmbedData, Basic) {
  // Check that all files match.
  std::set<std::string> idx;
  for (const auto& i : test_ns::EmbedIndex()) {
    idx.emplace(std::string{i.first});

    auto f = ReadFile(std::string{i.first});
    ASSERT_NE(f, "@@@ FAILED TO OPEN @@@") << i.first;
    EXPECT_EQ(f, i.second) << i.first;
  }

  // Check for the expected files.
  using ::testing::Contains;
  using ::testing::Key;

  EXPECT_THAT(idx, Contains("tests/cc_embed_data_test.bzl"));
  EXPECT_THAT(idx, Contains("tests/generated.txt"));
}

}  // namespace
