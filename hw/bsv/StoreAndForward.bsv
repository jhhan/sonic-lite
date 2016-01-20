// Copyright (c) 2016 Cornell University.

// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// NOTE:
// Implement a store-and-forward mechanism between ring-buffer and 
// main packet memory. Packets are buffered completely in ring buffer
// before it is sent to main memory and vice versa.

import BuildVector::*;
import Connectable::*;
import Clocks::*;
import Cntrs::*;
import ClientServer::*;
import DefaultValue::*;
import Ethernet::*;
import EthMac::*;
import FIFO::*;
import FIFOF::*;
import GetPut::*;
import Gearbox::*;
import MemTypes::*;
import MemServer::*;
import MemServerInternal::*;
import MemMgmt::*;
import PacketBuffer::*;
import SharedBuff::*;
import SpecialFIFOs::*;
import Vector::*;
import Pipe::*;

typedef struct {
   Bit#(32) id;
   Bit#(EtherLen) size;
} PacketInstance deriving(Bits, Eq);

interface StoreAndFwdFromRingToMem;
   interface PktReadClient readClient;
   interface Get#(Bit#(EtherLen)) mallocReq;
   interface Put#(Maybe#(Bit#(32))) mallocDone;
   interface MemWriteClient#(`DataBusWidth) writeClient;
   interface Get#(PacketInstance) eventPktCommitted;
endinterface

module mkStoreAndFwdFromRingToMem#(MemMgmtIndication memTestInd)(StoreAndFwdFromRingToMem)
   provisos (Div#(`DataBusWidth, 8, bytesPerBeat)
            ,Log#(bytesPerBeat, beatShift));

   let verbose = True;

   // RingBuffer Read Client
   FIFO#(EtherData) readDataFifo <- mkFIFO;
   FIFO#(Bit#(EtherLen)) readLenFifo <- mkFIFO;
   FIFO#(EtherReq) readReqFifo <- mkFIFO;

   // Memory Client
   FIFO#(MemRequest) writeReqFifo <- mkSizedFIFO(4);
   FIFO#(MemData#(`DataBusWidth)) writeDataFifo <- mkSizedFIFO(16);
   FIFO#(Bit#(MemTagSize)) writeDoneFifo <- mkSizedFIFO(4);
   MemWriteClient#(`DataBusWidth) dmaWriteClient = (interface MemWriteClient;
   interface Get writeReq = toGet(writeReqFifo);
   interface Get writeData = toGet(writeDataFifo);
   interface Put writeDone = toPut(writeDoneFifo);
   endinterface);

   FIFO#(Bit#(EtherLen)) mallocReqFifo <- mkFIFO;
   FIFO#(Bit#(EtherLen)) pktLenFifo <- mkFIFO;
   FIFO#(Maybe#(Bit#(32))) mallocDoneFifo <- mkFIFO;
   Reg#(Bool) readStarted <- mkReg(False);
   Reg#(Bool) mallocd <- mkReg(False);

   FIFO#(PacketInstance) eventPktReceivedFifo <- mkFIFO;
   FIFO#(PacketInstance) eventPktCommittedFifo <- mkFIFO;

   Reg#(Bit#(32)) cycle <- mkReg(0);
   rule every1 if (verbose);
      cycle <= cycle + 1;
   endrule

   rule packetReadStart if (!readStarted);
      let pktLen <- toGet(readLenFifo).get;
      if (verbose) $display("StoreAndForward::packetReadStart %d: ReadLen %d", cycle, pktLen);
      mallocReqFifo.enq(pktLen);
      pktLenFifo.enq(pktLen);
      readStarted <= True;
   endrule

   rule allocMemory;
      let pktLen <- toGet(pktLenFifo).get;
      let allocId <- toGet(mallocDoneFifo).get;
      let bytesPerBeatMinusOne = fromInteger(valueOf(bytesPerBeat))-1;
      // roundup to 16 byte boundary
      let burstLen = ((pktLen + bytesPerBeatMinusOne) & ~(bytesPerBeatMinusOne));
      let mask = (1<< (pktLen % fromInteger(valueOf(bytesPerBeat))))-1;
      if (isValid(allocId)) begin
         mallocd <= True;
         readReqFifo.enq(EtherReq{len: truncate(pktLen)});
         //FIXME use correct sglId
         writeReqFifo.enq(MemRequest {sglId: fromMaybe(?, allocId), offset: 0,
                                      burstLen: truncate(burstLen), tag:0
`ifdef BYTE_ENABLES
                                      , firstbe: 'hffff, lastbe: mask
`endif
                                     });
         if (verbose) $display("StoreAndForward::allocMemory %d: alloc done", cycle);
         eventPktReceivedFifo.enq(PacketInstance {id: fromMaybe(?, allocId), size: pktLen});
      end
   endrule

   rule packetReadInProgress if (readStarted && mallocd);
      let v <- toGet(readDataFifo).get;
      if (v.eop) begin
         readStarted <= False;
         mallocd <= False;
         $display("StoreAndForward:: %d: packet finished", cycle);
      end
      $display("StoreAndForward::writeData: %d: data:%h, tag:%h, last:%h", cycle, v.data, 0, v.eop);
      writeDataFifo.enq(MemData {data: v.data, tag: 0, last: v.eop});
   endrule

   rule packetReadDone;
      let v <- toGet(writeDoneFifo).get;
      let recvd <- toGet(eventPktReceivedFifo).get;
      memTestInd.packet_committed(recvd.id);
      eventPktCommittedFifo.enq(recvd);
      $display("StoreAndForward::packetReadDone %d: packet written to memory %h", cycle, v);
   endrule

   interface PktReadClient readClient;
      interface readData = toPut(readDataFifo);
      interface readLen = toPut(readLenFifo);
      interface readReq = toGet(readReqFifo);
   endinterface

   interface Get mallocReq = toGet(mallocReqFifo);
   interface Put mallocDone = toPut(mallocDoneFifo);
   interface writeClient = dmaWriteClient;
   interface Get eventPktCommitted = toGet(eventPktCommittedFifo);
endmodule

interface StoreAndFwdFromMemToRing;
   interface PktWriteClient writeClient;
   interface MemReadClient#(`DataBusWidth) readClient;
   interface Put#(PacketInstance) eventPktSend;
endinterface

module mkStoreAndFwdFromMemToRing(StoreAndFwdFromMemToRing)
   provisos (Div#(`DataBusWidth, 8, bytesPerBeat)
            ,Log#(bytesPerBeat, beatShift));

   let verbose = True;

   // Ring Buffer Write Client
   FIFO#(EtherData) writeDataFifo <- mkFIFO;

   // read client interface
   FIFO#(MemRequest) readReqFifo <-mkSizedFIFO(4);
   FIFO#(MemData#(`DataBusWidth)) readDataFifo <- mkSizedFIFO(32);
   MemReadClient#(`DataBusWidth) dmaReadClient = (interface MemReadClient;
   interface Get readReq = toGet(readReqFifo);
   interface Put readData = toPut(readDataFifo);
   endinterface);

   FIFO#(PacketInstance) eventPktSendFifo <- mkFIFO;

   Reg#(Bool)                 outPacket <- mkReg(False);
   Reg#(Bit#(EtherLen))   readBurstCount <- mkReg(0);
   Reg#(Bit#(EtherLen))   readBurstLen <- mkReg(0);

   Reg#(Bit#(32)) cycle <- mkReg(0);
   rule every1 if (verbose);
      cycle <= cycle + 1;
   endrule

   rule packetReadStart (!outPacket);
      let pkt <- toGet(eventPktSendFifo).get;
      let bytesPerBeatMinusOne = fromInteger(valueOf(bytesPerBeat))-1;
      // roundup to 16 byte boundary
      let burstLen = ((pkt.size + bytesPerBeatMinusOne) & ~(bytesPerBeatMinusOne));
      $display("StoreAndForward:: packetReadStart: %h, burstLen = %h", pkt.size, burstLen);
      let mask = (1<< (pkt.size % fromInteger(valueOf(bytesPerBeat))))-1;
      readReqFifo.enq(MemRequest{sglId: pkt.id, offset: 0,
                                 burstLen: truncate(burstLen), tag: 0
`ifdef BYTE_ENABLES
                                 , firstbe: 'hffff, lastbe: mask
`endif
                                });
      $display("StoreAndForward::packetReadStart %d: send a new packet with size %h %h", cycle, burstLen, pack(mask));
      outPacket <= True;
      readBurstLen <= pkt.size;
      readBurstCount <= pkt.size;
   endrule

   rule packetReadInProgress (outPacket);
      let d <- toGet(readDataFifo).get;
      let _bytesPerBeat= fromInteger(valueOf(bytesPerBeat));

      let sop = (readBurstLen == readBurstCount) ? True : False;
      let eop = (readBurstCount <= _bytesPerBeat) ? True : False;

      Bit#(bytesPerBeat) mask;
      if (readBurstCount <= _bytesPerBeat)
         mask = (1<<readBurstCount)-1;
      else
         mask = (1<<_bytesPerBeat)-1;

      writeDataFifo.enq(EtherData{data: d.data, mask: mask, sop: sop, eop: eop});

      if (verbose) $display("StoreAndForward::readdata %d: %h %h %h %h %h", cycle, readBurstCount, d.data, pack(mask), sop, eop);

      if (readBurstCount > _bytesPerBeat)
         readBurstCount <= readBurstCount - _bytesPerBeat;

      if (eop)
         outPacket <= False;
   endrule

   interface PktWriteClient writeClient;
      interface writeData = toGet(writeDataFifo);
   endinterface
   interface readClient = dmaReadClient;
   interface Put eventPktSend = toPut(eventPktSendFifo);
endmodule

interface StoreAndFwdFromRingToMac;
   interface PktReadClient readClient;
   interface Get#(PacketDataT#(64)) macTx;
endinterface

module mkStoreAndFwdFromRingToMac#(Clock txClock, Reset txReset)(StoreAndFwdFromRingToMac);
   let verbose = True;
   Clock defaultClock <- exposeCurrentClock();
   Reset defaultReset <- exposeCurrentReset();

   // RingBuffer Read Client
   FIFO#(EtherData) readDataFifo <- mkFIFO;
   FIFO#(Bit#(EtherLen)) readLenFifo <- mkFIFO;
   FIFO#(EtherReq) readReqFifo <- mkFIFO;

   // Mac Facing Fifo
   FIFO#(PacketDataT#(64)) writeMacFifo <- mkFIFO(clocked_by txClock, reset_by txReset);
   Gearbox#(2, 1, PacketDataT#(64)) fifoTxData <- mkNto1Gearbox(txClock, txReset, txClock, txReset);
   SyncFIFOIfc#(EtherData) tx_fifo <- mkSyncFIFO(5, defaultClock, defaultReset, txClock);

   rule readDataStart;
      let pktLen <- toGet(readLenFifo).get;
      if (verbose) $display(fshow(" read packt ") + fshow(pktLen));
      readReqFifo.enq(EtherReq{len: pktLen});
   endrule

   function Vector#(2, PacketDataT#(64)) split(EtherData in);
      Vector#(2, PacketDataT#(64)) v = defaultValue;
      Vector#(8, Bit#(8)) v0_data = unpack(in.data[63:0]);
      Vector#(8, Bit#(8)) v1_data = unpack(in.data[127:64]);
      v[0].sop = pack(in.sop);
      v[0].data = pack(reverse(v0_data));
      v[0].eop = (in.mask[15:8] == 0) ? pack(in.eop) : 0;
      v[0].mask = in.mask[7:0];
      v[1].sop = 0;
      v[1].data = pack(reverse(v1_data));
      v[1].eop = pack(in.eop);
      v[1].mask = in.mask[15:8];
      return v;
   endfunction

   rule cross_clocking;
      let v <- toGet(readDataFifo).get;
      tx_fifo.enq(v);
   endrule

   rule process_incoming_packet;
      let v <- toGet(tx_fifo).get;
      fifoTxData.enq(split(v));
   endrule

   rule process_outgoing_packet;
      let data = fifoTxData.first; fifoTxData.deq;
      let temp = head(data);
      if (temp.mask != 0) begin
         if (verbose) $display("StoreAndForward:: tx data %h", temp.data);
         writeMacFifo.enq(temp);
      end
   endrule

   interface PktReadClient readClient;
      interface readData = toPut(readDataFifo);
      interface readLen = toPut(readLenFifo);
      interface readReq = toGet(readReqFifo);
   endinterface
   interface Get macTx = toGet(writeMacFifo);
endmodule

interface StoreAndFwdFromMacToRing;
   interface PktWriteClient writeClient;
   interface Put#(PacketDataT#(64)) macRx;
endinterface

module mkStoreAndFwdFromMacToRing#(Clock rxClock, Reset rxReset)(StoreAndFwdFromMacToRing);
   let verbose = False;
   Clock defaultClock <- exposeCurrentClock();
   Reset defaultReset <- exposeCurrentReset();

   // Ring Buffer WriteClient
   FIFO#(EtherData) writeDataFifo <- mkFIFO;

   // Mac facing fifos
   Reg#(Bool) inProgress <- mkReg(False, clocked_by rxClock, reset_by rxReset);
   Reg#(Bool) oddBeat    <- mkReg(True, clocked_by rxClock, reset_by rxReset);
   Reg#(PacketDataT#(64)) v_prev <- mkReg(defaultValue, clocked_by rxClock, reset_by rxReset);

   FIFO#(PacketDataT#(64)) readMacFifo <- mkFIFO(clocked_by rxClock, reset_by rxReset);
   SyncFIFOIfc#(EtherData) rx_fifo <- mkSyncFIFO(5, rxClock, rxReset, defaultClock);

   function EtherData combine(Vector#(2, PacketDataT#(64)) v);
      EtherData data = defaultValue;
      Vector#(8, Bit#(8)) v0_data = unpack(v[0].data);
      Vector#(8, Bit#(8)) v1_data = unpack(v[1].data);
      data.data = {pack(reverse(v1_data)), pack(reverse(v0_data))};
      data.mask = {v[1].mask, v[0].mask};
      data.sop = unpack(v[0].sop);
      data.eop = unpack(v[0].eop) || unpack(v[1].eop);
      return data;
   endfunction

   rule startOfPacket if (!inProgress);
      let v = readMacFifo.first;
      inProgress <= unpack(v.sop);
      if (v.sop == 0)
         readMacFifo.deq;
      if (verbose) $display("macToRing:: start");
   endrule

   rule readPacketOdd if (inProgress && oddBeat);
      let v <- toGet(readMacFifo).get;
      if (verbose) $display("macToRing:: read odd beat %h", v.data);
      if (unpack(v.eop)) begin
         PacketDataT#(64) vo = defaultValue;
         rx_fifo.enq(combine(vec(v, vo)));
         if (verbose) $display("macToRing:: odd eop %h %h", v.data, v.mask);
         inProgress <= False;
      end
      v_prev <= v;
      oddBeat <= !oddBeat;
   endrule

   rule readPacketEven if (inProgress && !oddBeat);
      let v <- toGet(readMacFifo).get;
      rx_fifo.enq(combine(vec(v_prev, v)));
      if (verbose) $display("macToRing:: read even beat %h", v.data);
      if (unpack(v.eop)) begin
         inProgress <= False;
         if (verbose) $display("macToRing:: even eop %h %h %h %h", v.data, v.mask, v_prev.data, v_prev.mask);
      end
      oddBeat <= !oddBeat;
   endrule

   rule write_data;
      let v <- toGet(rx_fifo).get;
      writeDataFifo.enq(v);
      if (verbose) $display("macToRing:: writeToFifo");
   endrule

   interface PktWriteClient writeClient;
      interface writeData = toGet(writeDataFifo);
   endinterface
   interface Put macRx = toPut(readMacFifo);
endmodule