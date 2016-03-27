# language: ja
フィーチャ: all クラスメソッド
  @wip
  シナリオ: all クラスメソッドですべてのフローエントリを読み込む
    前提 Open vSwitch (dpid = 0x1) が起動している
    かつ 次のテーブルを定義:
      """
      class RoutingTable < ActiveFlow::Base
        table_id 3
      end
      """
    かつ 次のテーブルを定義:
      """
      class Classifier < ActiveFlow::Base
        table_id 1
      end
      """
    かつ 次のコードを実行:
      """
      Classifier.create(0x1,
                        priority: 100,
                        ether_type: IPV4,
                        instructions: GotoTable.new(RoutingTable))
      """
    もし 次のコードを実行:
      """
      Classifier.all.first
      """
    ならば Open vSwitch (dpid = 0x1) から次のフローエントリが取得できる
      | field      | value        |
      | table_id   | 1            |
      | priority   | 100          |
      | ether_type | ARP          |
      | actions    | GotoTable(3) |
