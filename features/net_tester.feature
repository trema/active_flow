# language: ja
フィーチャ: 最低限の NetTester 機能

  ActiveFlow に必要な機能を洗い出すためのフィーチャ。
  最小構成で NetTester を動かすのに必要な機能をテストする。
  うまく動いたらこのフィーチャとステップを trema/net_tester に移動すべし。

  シナリオ: テスト用ホストを 2 台、NetTester 用スイッチを 2 台起動する
    前提 次の仮想ネットワーク設定ファイルで phut を起動する
      """ruby
      # ホスト接続用の Open vSwitch
      vswitch('host_sw') { datapath_id 0x1 }
      # 物理 Open vSwitch
      vswitch('physical_sw') { datapath_id 0x2 }
      # テスト対象のスイッチ
      # WIP: このスイッチは普通のイーサネットスイッチとして動かす必要あり
      vswitch('testee_sw') { datapath_id 0x3 }

      vhost ('host1') { ip '192.168.0.1' }
      vhost ('host2') { ip '192.168.0.2' }
      
      link 'host_sw', 'physical_sw'
      link 'host_sw', 'host1'
      link 'host_sw', 'host2'
      link 'physical_sw', 'testee_sw'
      link 'physical_sw', 'testee_sw'
      """
