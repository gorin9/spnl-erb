#!/bin/bash
# Compile all *.erb templates in this blog example to *.generated.rb
# Run from the example directory.
set -euo pipefail
cd "$(dirname "$0")"

SPNL_ERB=${SPNL_ERB:-../../bin/spnl-erb}
RUBY=${RUBY:-ruby}

echo "Compiling templates with $SPNL_ERB ..."

# layout: takes title + content + meta
$RUBY $SPNL_ERB views/layout.html.erb \
  -c LayoutView \
  -a page_title,site_name,site_tagline,active_nav,content,year,generated_at,render_count \
  -o views/layout.html.generated.rb

# posts index: list of Post objects
$RUBY $SPNL_ERB views/posts/index.html.erb \
  -c PostsIndexView \
  -a posts,total_count \
  -o views/posts/index.html.generated.rb

# posts show: single Post + comments
$RUBY $SPNL_ERB views/posts/show.html.erb \
  -c PostsShowView \
  -a post,comments \
  -o views/posts/show.html.generated.rb

# about page
$RUBY $SPNL_ERB views/about.html.erb \
  -c AboutView \
  -a site_name,site_tagline,stats_posts,stats_comments,founded,tech,template_size_bytes,binary_size_kb \
  -o views/about.html.generated.rb

echo "Done."
ls -la views/*.generated.rb views/posts/*.generated.rb

# Spinel の Dir.mkdir が動かないため出力先 dir を build.sh で用意
mkdir -p out/posts
