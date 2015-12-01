package Test;
import FIFO::*;
import FIFOF::*;
import DefaultValue::*;
import SpecialFIFOs::*;
import Vector::*;
import BuildVector::*;
import GetPut::*;
import ClientServer::*;
import Connectable::*;
import HostInterface::*;

import Pipe::*;
import MemTypes::*;
import Ethernet::*;
import PacketBuffer::*;
import BlockSync::*;

interface TestIndication;
   method Action done(Bit#(32) matchCount);
endinterface

interface TestRequest;
   method Action writePacketData(Vector#(2, Bit#(64)) data, Bit#(1) sop, Bit#(1) eop);
endinterface

interface Test;
   interface TestRequest request;
endinterface

module mkTest#(TestIndication indication) (Test);
   let verbose = True;
   Reg#(Bit#(32)) cycle <- mkReg(0);
   FIFOF#(Bit#(66)) write_data <- mkFIFOF;
   PacketBuffer buff <- mkPacketBuffer();
   BlockSync bsync <- mkBlockSync;
   mkConnection(toPipeOut(write_data), bsync.blockSyncIn);

   rule every1;
      cycle <= cycle + 1;
      bsync.rx_ready(True);
   endrule

   rule readDataStart;
      let pktLen <- buff.readServer.readLen.get;
      if (verbose) $display(fshow(" read packt ") + fshow(pktLen));
      buff.readServer.readReq.put(EtherReq{len: truncate(pktLen)});
   endrule

   rule readDataInProgress;
      let v <- buff.readServer.readData.get;
      if(verbose) $display("%d: mkTest.write_data v=%h", cycle, v);
      write_data.enq(v.data[65:0]);
      if (v.eop) begin
         indication.done(0);
      end
   endrule

   rule out;
      let v = bsync.dataOut.first();
      bsync.dataOut.deq;
      if(verbose) $display("%d: blocksync in v=%h", cycle, v);
   endrule

   interface TestRequest request;
      method Action writePacketData(Vector#(2, Bit#(64)) data, Bit#(1) sop, Bit#(1) eop);
         EtherData beat = defaultValue;
         beat.data = pack(reverse(data));
         beat.sop = unpack(sop);
         beat.eop = unpack(eop);
         buff.writeServer.writeData.put(beat);
      endmethod
   endinterface
endmodule
endpackage: Test
