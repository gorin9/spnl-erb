#!/bin/bash
# *.erb -> *.generated.rb (spnl-erb)
# blog_controller.rb -> router.generated.rb (spnl-router)
set -euo pipefail
cd "$(dirname "$0")"

SPNL_ERB=${SPNL_ERB:-../../bin/spnl-erb}
SPNL_ROUTER=${SPNL_ROUTER:-../../../spnl-router-repo/bin/spnl-router}
RUBY=${RUBY:-ruby}

echo "==> spnl-erb (view templates)"

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

echo "==> spnl-router (controller -> dispatcher)"

$RUBY $SPNL_ROUTER blog_controller.rb -o router.generated.rb

echo "==> Done."
ls -la views/*.generated.rb views/posts/*.generated.rb router.generated.rb

mkdir -p out/posts
