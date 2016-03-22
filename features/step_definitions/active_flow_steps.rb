# coding: utf-8

# rubocop:disable LineLength
Given(/^Open vSwitch \(dpid = 0x(.+)\) が起動している$/) do |dpid|
  @dpid = dpid
  system "sudo ovs-vsctl add-br br0x#{dpid}"
  system "sudo /sbin/sysctl -w net.ipv6.conf.br0x#{dpid}.disable_ipv6=1 -q"
  system "sudo ovs-vsctl set bridge br0x#{dpid} protocols=OpenFlow13 other-config:datapath-id=#{'0' * (16 - dpid.length)}#{dpid}"
  system "sudo ovs-vsctl set-controller br0x#{dpid} ptcp:6633:127.0.0.1"
  system "sudo ovs-vsctl set-fail-mode br0x#{dpid} secure"
end
# rubocop:enable LineLength

Given(/^次の仮想ネットワーク設定ファイルで phut を起動する$/) do |config|
  @config_file = 'phut.conf'
  step %(a file named "#{@config_file}" with:), config
  step %(I successfully run `phut run -L. -P. -S. #{@config_file}`)
end

Given(/^次のテーブルを定義:$/) do |code|
  ActiveFlow.module_eval code
end

When(/^次のコードを実行:$/) do |code|
  ActiveFlow.module_eval code
end

# rubocop:disable LineLength
Then(/^Open vSwitch \(dpid = 0x(.+)\) に次の (\d+) つのフローエントリができる$/) do |dpid, nflows, table|
  output = `sudo ovs-ofctl dump-flows br0x#{dpid} -O #{Pio::OpenFlow.version} --flow-format OXM-OpenFlow13`
  expect(output.lines.size - 1).to eq(nflows.to_i)

  (0..nflows.to_i - 1).each do |each|
    key_value = output.lines[1 + each].strip.gsub(/,\s*/, ',').gsub(/\s/, ',').split(',')

    table.hashes[each].each_pair do |field, value|
      ovs_field = case field
                  when 'table_id'
                    'table'
                  when 'destination_mac_address'
                    'dl_dst'
                  else
                    field
                  end
      key_value.find { |item| /#{ovs_field}=([^,\s]+)/ =~ item }
      expected_value = case field
                       when 'ether_type'
                         case key_value.find { |item| !item.include?('=') }
                         when 'arp'
                           'ARP'
                         when 'ip'
                           'IPV4'
                         else
                           raise
                         end
                       when 'dl_dst'
                         Regexp.last_match[1].upcase
                       when 'actions'
                         "GotoTable(#{Regexp.last_match[1].split(':').last})"
                       else
                         Regexp.last_match[1]
                       end
      expect(expected_value).to eq(value)
    end
  end
end
# rubocop:enable LineLength

Then(/^phut を停止する$/) do
  if @config_file
    step %(I successfully run `phut -v stop -L. -P. -S. #{@config_file}`)
  end
end
