require_relative "../lib/spnl_erb"
require "erb"
def assert(value, message); raise message unless value; end
samples = ['hello', '<%= name %>', '<%= "@email" %>', "before\n  <%- x = 1 -%>\nafter <%= x %>", '<%%= literal %>', '<% [1,2].each do |n| %><%= n %><% end %>', '日本語 <%= "雪" %>']
name = 'Alice'
samples.each do |template|
  expected = ERB.new(template, trim_mode: '-').result(binding)
  actual = eval(SpnlErb.compile_body(template), binding)
  assert(actual == expected, "ERB parity: #{template}")
end
src = SpnlErb.compile_class('<%= "@email" %>:<%= @name %>', class_name: 'View', attrs: ['name'])
eval(src)
assert(View.render('Alice') == '@email:Alice', 'stateless token rewrite')
assert(SpnlErb.attributes('<%= "@fake" %><%= @real %>') == ['real'], 'attribute detection')
eval(SpnlErb.compile_class('<%= @name %>', class_name: 'InstanceView', attrs: ['name'], mode: :instance))
assert(InstanceView.new('雪').render == '雪', 'instance mode')
eval(SpnlErb.compile_class('<%= @name %>', class_name: 'Unused', target_class: 'Controller', mode: :controller))
c = Controller.new;c.instance_variable_set(:@name, 'C');assert(c.render == 'C', 'controller mode')
puts 'ERB parity, modes, UTF-8 and lexical rewriting passed'

template = "<% message = <<TEXT\n日本語\nTEXT\n%><%= message %>"
eval(SpnlErb.compile_class(template,class_name:'HeredocView'))
assert(HeredocView.render == ERB.new(template,trim_mode:'-').result,'heredoc whitespace and source encoding')
