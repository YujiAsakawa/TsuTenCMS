# -*- coding: utf-8 -*-
require 'date'
require 'navi_menu'
require 'util'
require 'parts'

class Content
   include Comparable
   include Util

   def initialize(fname, series, after_content = true, date_text = nil)
      raise RuntimeError, "#{fname} がありません。(content)".encode(TEXT_CODE) unless FileTest.exist? fname
      #      puts fname if MAIN_PROGRAM_NAME == $PROGRAM_NAME
      @fname = fname
      @parent = series
      @navi = series.navi
      @info_flag = /_0000\.txt/ =~ @fname
      @dname = File.dirname(@fname) + '/'
      @category = @dname.split('/').first.to_sym
      @file_header = File.basename(@fname).slice(/\A(.+)_/, 1)
      @number = @fname.slice(/(\d{4})\..+\Z/, 1).to_i
      @top_file = @dname + @file_header + '_top.txt'
      @top_path = @file_header + '_top.html'
      @info_path = @file_header + '_0000.html'
      @footer_name = @dname + @file_header + '_footer.html'
      @date = date_text ? date_text : @navi.date_text
      @after = after_content
      @series = ''
      @title = ''
      @body = parse(trim_null_line File.read(@fname))
      @color = get_color
   end

   attr_reader :dname, :fname, :category, :file_header, :footer_name, :number, :top_file, :top_path, :info_path, :title, :body, :series, :date, :color
   attr_accessor :after

   def inspect
      "#{fname}, #{date}, #{after}"
   end

   def ==(other)
      fname == other.fname and date == other.date and after == other.after
   end

   def <=>(other)
      number <=> other.number
   end

   def to_html
      html = ''
      html << header(CONTENT_HEADER)
      html << body
      html << footer
      html << CONTENT_FOOTER.gsub('〓navigation〓', navigation).gsub('〓author〓', author).gsub('〓author_name〓', author_name)
      html << @navi.to_html('../../') unless @info_flag or $ARCIVE
      html << FOOTER.gsub('〓color〓', color)
   end

   def put_html
      if ($OVER_WRITE or not FileTest.exist? html_path) or @info_flag or MAIN_PROGRAM_NAME != $PROGRAM_NAME
         open(html_path, 'w') do |html|
            html.puts self.to_html
         end
         puts "made #{html_path}" if MAIN_PROGRAM_NAME == $PROGRAM_NAME
      end
   end

   def html_path
      fname.sub(/\.txt$/, '.html')
   end

   def heading
      %!■No.%d %s(%s)! % [number, title, date]
   end

   def link
      %{<h3 class="link_caption clearfix"><a href="#{File.split(html_path).last}">} +
        %{<span class="mini orange">#{number}</span>} +
        %{&nbsp;&nbsp;<span>#{/<br \/>/ === title ? title.sub('<br />', '<br />　　') : title}</span>} +
        %{<span class="mini">(#{date})</span></a></h3>\n}
   end

   #TODO: いらないかも
   def newly_series
      %!【%s(%d)】! % [series, number]
   end

   def author
      unless @author
         open top_file do |f|
            @author = f.readline.chomp.split(':').last
         end
      end
      @author
   end

   def author_name
      @parent.author_name.split(/[(（]/).first
   end

   private
   def trim_null_line(text)
      text.sub(/(^§.+\n)\n*/, '\1')
   end

   def parse(text)
      html = ''
      normalize(text).each_line do |line|
         line.chomp!
         case line
         when /^《(.+)》/, /^■(.+)/
            @series = $1
         when /^§(.+)/
            @title = $1.gsub('((/))', '<br />')
         when /^◆(.+)/
            html << include_file($1)
         else
            html << line + "<br />\n"
         end
      end
      html.gsub('((*', %!<em>!).gsub('*))', '</em>')
   end

   def headline_link
      unless @info_flag
         %(<a href="#{info_path}"><img src="../../images/explain.png" alt="コンテンツの詳細を見る" width="55px" height="24px" /></a>)
      else
         %(<a href="#{top_path}"><img src="../../images/content.png" alt="記事一覧へ" width="55px" height="24px" /></a>)
      end
   end

   def footer
      html = ''
      if FileTest.exist? footer_name
         html << "</td></tr>\n"
         html << "<tr><td>&nbsp;</td></tr>\n<tr><td class=script>\n"
         html << File.read(footer_name)
      end
      html
   end

   def header(text)
      result = text.dup
      result.gsub!('〓title〓', title)
      result.gsub!('〓series〓', series)
      result.gsub!('〓top_path〓', top_path)
      result.gsub!('〓author_name〓', author_name)
      result.gsub!('〓keywords〓', "#{series},#{title},#{author_name}")
      result.gsub!('〓description〓', title)
      result.gsub!('〓headline_link〓', headline_link)
      result
   end

   def navigation
      before = nil
      coming = nil

      if number > 1
         before = %!<a href = "%s_%04d.html"><img src="../../images/previous.png" alt="前へ" width="55px" height="24px" /></a>! % [file_header, number - 1]
      end
      if after
         coming = %!<a href = "%s_%04d.html"><img src="../../images/next.png" alt="次へ" width="55px" height="24px" /></a>! % [file_header, number + 1]
      end

      <<-EOB
<div>
#{[before, coming].compact.join("\n&nbsp;\n")}
</div>
      EOB
   end
end