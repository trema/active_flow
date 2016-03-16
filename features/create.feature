# language: ja
フィーチャ: create クラスメソッド

  シナリオ: Classifier.create でフローエントリを追加
    前提 Open vSwitch (dpid = 0x1) が起動している
    かつ 次のテーブルを定義:
      """
      class ArpResponder < ActiveFlow::Base
        table_id 2
      end
      """
    かつ 次のテーブルを定義:
      """
      class RoutingTable < ActiveFlow::Base
        table_id 3
      end
      """
    もし 次のテーブルを定義:
      """
      class Classifier < ActiveFlow::Base
        table_id 1
      end
      """
    かつ 次のコードを実行:
      """
      Classifier.create(0x1,
                        priority: 100,
                        ether_type: ARP,
                        instructions: GotoTable.new(ArpResponder))

      Classifier.create(0x1,
                        priority: 100,
                        ether_type: IPV4,
                        instructions: GotoTable.new(RoutingTable))
      """
    ならば Open vSwitch (dpid = 0x1) に次の 2 つのフローエントリができる
      | table_id | priority | ether_type | actions      |
      |        1 |      100 | ARP        | GotoTable(2) |
      |        1 |      100 | IPV4       | GotoTable(3) |
