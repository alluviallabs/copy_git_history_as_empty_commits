#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), 'boot.rb'))

@options = {}

def show_help_and_exit!
  puts HELP_MESSAGE

  # Using non-zero signal to notify any outer script, that action didn't happened,
  # because when the `--help` option is passed,
  # it will interrupt any other actions 
  exit(-1)
end

OptionParser.new do |parser|
  parser.on('-h', '--help') { show_help_and_exit! }
  parser.on('-c', '--command=command') { |command| @options[:command] = command }
  parser.on('--src_prj_dir=src_prj_dir') { |src_prj_dir| @options[:src_prj_dir] = File.expand_path(src_prj_dir) }
  parser.on('--dst_prj_dir=dst_prj_dir') { |dst_prj_dir| @options[:dst_prj_dir] = File.expand_path(dst_prj_dir) }
  parser.on('--index_dir=index_dir') { |index_dir| @options[:index_dir] = File.expand_path(index_dir) }
  parser.on('--msg_prefix=msg_prefix') { |msg_prefix| @options[:msg_prefix] = msg_prefix }
  parser.on('--msg_postfix=msg_postfix') { |msg_postfix| @options[:msg_postfix] = msg_postfix }
  parser.on('--skip_merge_commits') { |skip_merge_commits| @options[:skip_merge_commits] = skip_merge_commits }
end.parse!

show_help_and_exit! if @options.blank?

MainClass.new(@options).perform
