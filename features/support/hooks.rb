# coding: utf-8

After do
  step %(phut を停止する)
  system "sudo ovs-vsctl del-br br0x#{@dpid}" if @dpid
end
