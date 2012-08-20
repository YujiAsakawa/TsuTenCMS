# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'util'

describe Util do
   include Util
   #TODO: 半角カナを全角にするメソッドに置き換えたい。
#   describe '全角文字を半角に変換できる' do
#      it do
#         z2h(ZEN.join('')).should == HAN.join('')
#      end
#      describe '全角スペースだけは変換しない' do
#         it do
#            z2h('　').should == '　'
#         end
#      end
#   end
   describe '標準化できる' do
      describe 'HTML escape する' do
         it do
            normalize('<&">').should == '&lt;&amp;&quot;&gt;'
         end
      end
      describe '二重 escape はしない' do
         it do
            normalize('&lt;&amp;&quot;&gt;').should == '&lt;&amp;&quot;&gt;'
         end
      end
   end
end

