#!/usr/bin/env bash
# Copyright 2019 The Jetstack cert-manager contributors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

if [[ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then # Running inside bazel
  echo "Regenerate API reference documentation..." >&2
elif ! command -v bazel &>/dev/null; then
  echo "Install bazel at https://bazel.build" >&2
  exit 1
else
  (
    set -o xtrace
    bazel run @com_github_jetstack_cert_manager//hack:update-reference-docs
  )
  exit 0
fi

generated_tarball=$(realpath "$1")

cd "$BUILD_WORKSPACE_DIRECTORY"
output_path="docs/generated/reference/output/reference/api-docs"
# The final directory path to store the generated output data
output_dir="$BUILD_WORKSPACE_DIRECTORY/$output_path"

# create a temporary directory to extract the generated reference docs tarball to
tmp_output="$(mktemp -d)"
# extract the generated docs tarball
tar -C "${tmp_output}" -xf "$generated_tarball"

# clean up the output directory
rm -Rf "${output_dir}"

# recreate the output directory and move extracted content to it
mkdir -p "${output_dir}"
mv "${tmp_output}"/* "${output_dir}"
