#!/bin/bash
# views/*.erb -> views/*.generated.rb (reopen BlogController)
# 各 template は `def render_xxx; ...; end` メソッドを BlogController に足す.
set -euo pipefail
cd "$(dirname "$0")"

SPNL_ERB=${SPNL_ERB:-../../bin/spnl-erb}
RUBY=${RUBY:-ruby}

echo "Compiling templates with $SPNL_ERB (mode: controller, target: BlogController)..."

$RUBY $SPNL_ERB views/layout.html.erb \
  --mode controller --target BlogController \
  -m render_layout \
  -o views/layout.html.generated.rb

$RUBY $SPNL_ERB views/posts/index.html.erb \
  --mode controller --target BlogController \
  -m render_posts_index \
  -o views/posts/index.html.generated.rb

$RUBY $SPNL_ERB views/posts/show.html.erb \
  --mode controller --target BlogController \
  -m render_posts_show \
  -o views/posts/show.html.generated.rb

$RUBY $SPNL_ERB views/about.html.erb \
  --mode controller --target BlogController \
  -m render_about \
  -o views/about.html.generated.rb

echo "Done."
ls -la views/*.generated.rb views/posts/*.generated.rb

# Spinel の Dir.mkdir が動かないため出力先 dir を build.sh で用意
mkdir -p out/posts
