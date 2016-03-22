require 'pio'
require 'socket'

Pio::OpenFlow.switch_version :OpenFlow13

# Base module
module ActiveFlow
  include Pio
  include Pio::EthernetHeader::EtherType

  # Monkey patched GotoTable class that takes a table as its argument
  class GotoTable
    def initialize(table)
      @goto = Pio::GotoTable.new(table.class_variable_get(:@@table_id))
    end

    def method_missing(name, *args)
      @goto.__send__(name, *args)
    end
  end

  # Base class for flow table classes
  class Base
    include Pio

    OPENFLOW_HEADER_LENGTH = 8

    def self.table_id(table_id)
      class_variable_set :@@table_id, table_id
    end

    # rubocop:disable MethodLength
    # rubocop:disable AbcSize
    def self.create(_dpid, args)
      @socket = TCPSocket.new('localhost', 6633)
      read
      @socket.write Hello.new.to_binary
      read
      @socket.write Echo::Reply.new.to_binary

      flow_mod_args = {}.tap do |field|
        field[:table_id] = class_variable_get(:@@table_id)
        field[:priority] = args[:priority]
        field[:match] = Match.new(ether_type: args[:ether_type])
        field[:instructions] = [args[:instructions]]
      end
      flow_mod = FlowMod.new(flow_mod_args)
      @socket.write flow_mod.to_binary
    end
    # rubocop:enable MethodLength
    # rubocop:enable AbcSize

    def self.read
      header_binary = drain(OPENFLOW_HEADER_LENGTH)
      header = OpenFlowHeaderParser.read(header_binary)
      body_binary = drain(header.message_length - OPENFLOW_HEADER_LENGTH)
      raise if (header_binary + body_binary).length != header.message_length
      OpenFlow.read(header_binary + body_binary)
    end

    def self.drain(length)
      buffer = ''
      loop do
        buffer += @socket.readpartial(length - buffer.length)
        break if buffer.length == length
      end
      buffer
    end
  end
end
