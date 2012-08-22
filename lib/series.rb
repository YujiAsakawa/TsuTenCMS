# -*- coding: utf-8 -*-
require 'fileutils'
require 'util'
require 'content'

class Series
   include Util

   PAGE_SIZE = 10

   def initialize(dname, navi)
      puts dname if MAIN_PROGRAM_NAME == $PROGRAM_NAME
      @dname = dname
      @navi = navi
      @date = @navi.date_text
      @name = File.basename(dname)
      @fname = "#{@dname}#{@name}_top.txt"
      raise RuntimeError, "#{@fname} がありません。(series)".encode(TEXT_CODE) unless FileTest.exist? @fname
      @category = @dname.split('/').first.to_sym
      @text = File.read(@fname)
      @info_path = "#{@name}_0000.html"
      @footer_name = "#{@dname}#{@name}_top_footer.html"
      @page_size = PAGE_SIZE
      @title = ''
      @new_content = false
      @contents = []
      @color = get_color
      parse(@text)
      @author_fname = "#{@dname}#{@author}.txt"
      raise RuntimeError, "#{@author_fname} がありません。(series)".encode(TEXT_CODE) unless FileTest.exist? @author_fname
      @author_text = File.read(@author_fname)
      @author_html_fname = "#{@dname}#{@author}.html"
      put_author_html #TODO: NaviMenu で出力したい。
      put_info_html #TODO: NaviMenu で出力したい。
   end

   attr_accessor :page_size
   attr_reader :navi, :date, :dname, :info_path, :name, :title, :contents, :author_name

   def ==(other)
      self.dname == other.dname and self.date == other.date
   end

   def to_s
      result = ''
      result << "□#@title:#@author\n"
      @contents.each do |ct|
         result << ct.heading + "\n"
      end
      result
   end

   def new_content?
      @new_content
   end

   def put_source
      FileUtils.cp @fname, @fname + '.bk'
      open(@fname, 'w') do |f|
         f.puts self
      end
   end

   def put_html
      to_htmls.each_with_index do |html, idx|
         no = idx.zero? ? '' : idx + 1
         open("#{@dname}#{@name}_top#{no}.html", 'w') do |f|
            f.puts html
         end
      end
   end

   def to_htmls
      current_page = 1
      count = page_count(@contents.size)
      result = []
      @contents.each_slice(@page_size) do |cts|
         html = MENU_HEADER.gsub('〓title〓', @title).gsub('〓info_path〓', info_path).gsub('〓author〓', @author)
         html << content_links(cts)
         html << page_links(current_page, count)
         html << MENU_FOOTER
         html << @navi.to_html(@category, '../../') unless $ARCIVE
         html << FOOTER
         current_page += 1
         result << html
      end
      result
   end

   def put_contents
      @contents.each do |ct|
         ct.put_html
      end
   end

   def put_info_html
      Content.new("#{@dname}#{@name}_0000.txt", self, false).put_html
   end

   def put_author_html
      open(@author_html_fname, 'w') do |html|
         html.puts mk_author_html(@author_text)
      end
   end

   def add_content
      new_number = @contents.empty? ? 1 : @contents.first.number + 1
      new_fname = "#{@dname}#{@name}_%04d.txt" % [new_number]
      if FileTest.exist? new_fname
         @contents.unshift Content.new(new_fname, self, false)
         @new_content = true
      else
         @contents.first.after = false
         @new_content = false
      end
   end

   private
   def parse(text)
      normalize(text).each_line do |lin|
         case lin
         when /^□(.+)/
            @title, @author = $1.split(':')
         when /^■No\.\s*(\d+).+\((\d+\/\d+)\)$/
            no = $1.to_i
            date = $2
            @contents << Content.new("#{@dname}#{@name}_%04d.txt" % [no], self, true, date)
         when /^\s*$/
            next
         else
            raise  RuntimeError, "#{@fname} : #{lin.encode(TEXT_CODE)}"
         end
      end
   end

   def mk_author_html(text)
      body = ''
      normalize(text).each_line do |line|
         case line
         when /^■(.+)/
            @author_name = $1
         when /^◆(.+)/
            body << include_file($1)
         when /^§(.+)/
            body << %(<div class="content_caption orange">#{$1}</div><br />)
         when /\[\[([^\]|]+)\|?([^\]]+)?\]\]/
            body << inline_link(Regexp.last_match)
         else
            body << line.sub(/$/, '<br />')
         end
      end
      html = ''
      html << AUTHOR_HEADER.gsub('〓author_name〓', author_name).gsub('〓author_header〓', author_header)
      html << body
      html << AUTHOR_FOOTER
      html << FOOTER
      html.gsub('((*', %!<em>!).gsub('*))', '</em>')
   end

   def author_header
      %(<div id="content_title" class="gradient_bar_orange caption clearfix"><span class="left">#{author_name}</span>) +
        %(<a class="right" href="#{@dname}#{@name}_top.html">) +
        %(<img src="../../images/content.png" alt="記事一覧へ" width="55px" height="24px" />) +
        %(</a></div><br />\n)
   end

   def inline_link(match_data)
      text = match_data[1]
      uri = match_data[2] || match_data[1]
      %(#{match_data.pre_match}<a href="#{uri}">#{text}</a>#{match_data.post_match}<br />\n)
   end

   def content_links(cts)
      html = %|<section id="content_menu">\n|
      cts.each do |ct|
         html << ct.link
      end
      html + "</section>\n"
   end

   def page_count(size = @contents.size)
      count = size / @page_size
      count += 1 unless (size % @page_size).zero?
      count
   end

   def simple_template(current, st, ed)
      template = ''
      numbers = []
      (st..ed).each do |page|
         unless page == current
            template << "%s\n"
            numbers << page
         else
            template << %{<span class="round_box">#{current}</span>\n}
         end
      end
      [template, numbers]
   end

   def page_template(current, count)
      template = ''
      numbers = []
      case count
      when 1
         template = "%d\n"
         numbers = [1]
      when 2..4
         template, numbers = simple_template(current, 1, count)
      else
         case current
         when 1..3
            template, numbers = simple_template(current, 1, [current + 1, 3].max)
            template << "..%s\n"
            numbers << count
         when (count - 2)..count
            template, numbers = simple_template(current, [count -2, current - 1].min, count)
            template = "%s\n.." + template
            numbers.unshift 1
         else
            template = %{%s\n..%s\n<span class="round_box">#{current}</span>\n%s\n..%s\n}
            numbers = [1, current - 1, current + 1, count]
         end
      end
      [template, numbers]
   end

   def mk_page_link(page)
      %!<a href="#{@name}_top#{page == 1 ? '' : page}.html"><span class="round_box">#{page}</span></a>!
   end

   def page_links(current, count)
      links = ''
      if 1 < count
         template, numbers = page_template(current, count)
         links << %{<section id="pages">\n}
         links << template % numbers.map{|pg| mk_page_link(pg) }
         links << %{<span class="mini">page</span>\n}
         links << %{</section>\n}
      end
      links
   end
end
