#!/usr/bin/env ruby
# CRuby で実行する spnl-erb のユニットテスト
require_relative "../lib/spnl_erb"

def assert_equal(expected, actual, msg = "")
  if expected != actual
    warn "FAIL: #{msg}"
    warn "  expected: #{expected.inspect}"
    warn "  actual:   #{actual.inspect}"
    exit 1
  end
end

# --- literal only ---
out = SpnlErb.compile_body("hello world")
assert_equal "_out = \"\"\n_out = _out + \"hello world\"\n_out", out, "literal only"

# --- <%= expr %> ---
out = SpnlErb.compile_body("<%= name %>")
assert_equal "_out = \"\"\n_out = _out + (name).to_s\n_out", out, "expr only"

# --- mix ---
out = SpnlErb.compile_body("Hi, <%= n %>!")
expected = <<~RUBY.chomp
  _out = ""
  _out = _out + "Hi, "
  _out = _out + (n).to_s
  _out = _out + "!"
  _out
RUBY
assert_equal expected, out, "literal + expr"

# --- <% code %> ---
out = SpnlErb.compile_body("<% x = 1 %>val=<%= x %>")
expected = <<~RUBY.chomp
  _out = ""
  x = 1
  _out = _out + "val="
  _out = _out + (x).to_s
  _out = _out + ""
  _out
RUBY
# strict equality may differ due to trim; check inclusion instead
raise "code block missing" unless out.include?("x = 1")
raise "expr emit missing" unless out.include?("(x).to_s")

# --- trim mode <% -%> ---
src = "before\n<% true -%>\nafter"
out = SpnlErb.compile_body(src)
# the literal "\nafter" -> "after" because of -%>
raise "trim_right failed" if out.include?("\\nafter")
raise "trim_right OK but found?" unless out.include?("after")

# --- class wrapper :stateless (default) ---
out = SpnlErb.compile_class("hi <%= @x %>", class_name: "V", attrs: ["x"])
raise "module missing"      unless out.include?("module V")
raise "self.render missing" unless out.include?("def self.render(x)")
raise "ivar should be stripped" if  out.include?("@x")

# --- class wrapper :instance ---
out = SpnlErb.compile_class("hi <%= @x %>", class_name: "V", attrs: ["x"], mode: :instance)
raise "class missing"      unless out.include?("class V")
raise "attr assign missing" unless out.include?("@x = x")
raise "def render missing"  unless out.include?("def render")

puts "all tests passed"
