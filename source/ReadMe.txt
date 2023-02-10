2021年01月30日

・「IPLセレクター Ver.0.9b」について

１．ソフト説明
　mz-80B/2000(2200)のテープからIPL起動するソフトを 「ファイル・コンバータ」や「Filing CMT」で
ディスクに セーブしておき、それらを選択し起動できます。
　１ディスク最大26ファイルまで選択可能です。27ファイル目からは無視します。
　分割ロードのプログラムには対応していません。(1ファイル化すればOK)

２．IPLセレクターの使用方法
　(1) 解凍後、次のどれかで起動ディスクを作成して下さい。
　　　(a) DITTなどで IPLS_0_9.D88 をブランクディスクに書き込みます。
　　　(b) IPL-SEL-MAKER.mzt をモニタに(何とか)読み込ませ、フォーマット済みのスレイブディスクにBOOTプログラムを書き込みます。
　　　　　この方法は、旧バージョンのIPLセレクターのバージョンアップにも使用できます。

　(2) 「Filing CMT」などでカセットテープからファイルを (1)で作成したディスクにセーブします。

　(3) 出来上がったディスクをセットし、IPLリセットします。

　(4) 画面に表示されたファイルから起動したいものに該当するキー（Ａ～Ｚ）を押します。

３．配布内容
　IPLS_0_9.D88      : IPLセレクターVer0.9b BOOTディスク・イメージ
　IPL-SEL-MAKER.mzt : IPLセレクター・メーカー テープイメージ
　IPLSEL09.ASM      : IPLセレクターVer0.9b ソース
　IPL-SEL-MAKER.ASM : IPLセレクター・メーカー ソース
　Make.bat          : コンパイル用バッチファイル(参考)

※コンパイラは、紅茶羊羹(@youkan700)さんの Z80ASを使っています。

４．作者への連絡方法
　Twitter にてご連絡下さい。
　@junk_suga

５．ライセンスについて

======================================================================
Copyright 2021 Hideki Suga (@junk_suga)

ソースコード形式かバイナリ形式か、変更するかしないかを問わず、以下の条件を満たす場合に限り、再頒布および使用が許可されます。

1. ソースコードを再頒布する場合、上記の著作権表示、本条件一覧、および下記免責条項を含めること。

2. バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の著作権表示、本条件一覧、および下記免責条項を含めること。

本ソフトウェアは、著作権者およびコントリビューターによって「現状のまま」提供されており、明示黙示を問わず、商業的な使用可能性、および特定の目的に対する適合性に関する暗黙の保証も含め、またそれに限定されない、いかなる保証もありません。著作権者もコントリビューターも、事由のいかんを問わず、 損害発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知らされていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそれに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、または結果損害について、一切責任を負わないものとします。


======================================================================
Copyright 2021 Hideki Suga (@junk_suga)


Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


以上
