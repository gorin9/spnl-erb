require 'tmpdir'
require 'open3'
require_relative '../lib/spnl_erb'
Dir.mktmpdir do |dir|
  src = SpnlErb.compile_class('<% @items.each do |item| %><%= item %>:<%= "@literal" %>;<% end %>',class_name:'View',attrs:['items'],mode: :instance)
  file=File.join(dir,'view.rb')
  File.write(file,src+"puts View.new([\"雪\",\"Alice\"]).render\n")
  expected,status=Open3.capture2('ruby',file);raise 'CRuby failed' unless status.success?
  raise 'compile failed' unless system(ENV.fetch('SPINEL','spinel'),file,'-o',dir+'/view')
  actual,status=Open3.capture2(dir+'/view');raise 'ERB AOT parity failed' unless status.success? && actual==expected
  puts 'Generated ERB compiles and matches CRuby'
end
