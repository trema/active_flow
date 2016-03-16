After do
  system "sudo ovs-vsctl del-br br0x#{@dpid}" if @dpid
end
