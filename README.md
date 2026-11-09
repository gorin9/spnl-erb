# spnl-erb

Compile ERB **on the build host** to ordinary Ruby methods that Spinel can compile.
The generator uses CRuby's ERB compiler; generated code needs no runtime eval or binding.
Spinel's bundled runtime ERB still does not replace this tool for templates with loops
or arbitrary Ruby expressions.

```sh
ruby bin/spnl-erb views/index.html.erb -c IndexView -a name,items --mode instance -o index.generated.rb
ruby bin/spnl-erb views/index.html.erb --mode controller --target Controller -m render_index -o index.generated.rb
ruby bin/spnl-erb --batch views/  # stateless modules; call ModuleName.render(args...)
```

Modes: stateless (default module class method with positional locals), instance
(initialize + render), controller (reopen target class, render method reads its ivars).
Batch output matches the selected mode. Explicit class/method/attribute names are validated.
Ripper rewrites only actual ivar tokens in stateless mode; strings/comments/regexps stay intact.
Standard trim_mode '-' and literal `<%%` are supported by ERB itself.

Standard ERB does **not** HTML-escape `<%=`. Use `ERB::Util.html_escape(value)` (and
`require "erb"` in the runtime entry), or a helper, for untrusted HTML values. Layout
content intentionally contains rendered HTML. Templates are trusted executable build inputs.
The generated source marker points diagnostics to the original template; it is a coarse
file/start-line map, not an exact per-expression mapping of standard ERB's generated source.

Use gems/gemspec or a pinned checkout for this CRuby build tool. It does not need to be
compiled or distributed as a runtime spin package. Check generated files into source
control and have CI regenerate and reject unexpected differences.

## Compatibility and verification

Supported baseline: Spinel `2026.10.25` (Linux) and CRuby 3.1+. CI also checks the
reference master commit `60c0273261415d2b5edd6480667a705a68addbd2`; this is a pinned
comparison, not an assertion about every future master build. Check CHANGELOG before upgrading.
No performance or binary-size claim is inherited from the May prototype.

Run `rake test`. Runtime packages additionally use `spin test`; generator repositories
use `ruby scripts/verify_runtime.rb` to compile their generated code and compare with CRuby.
See CONTRIBUTING.md. Original notes are in `docs/historical-readme-may-2026.md`.

MIT licensed. Development version; no gem or package-index release is published automatically.
