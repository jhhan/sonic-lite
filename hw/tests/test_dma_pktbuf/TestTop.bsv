// Copyright (c) 2015 Cornell University.

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

import Arith ::*;
import BuildVector::*;
import ClientServer::*;
import Clocks::*;
import ConfigCounter::*;
import Connectable::*;
import DefaultValue::*;
import FIFO ::*;
import FIFOF ::*;
import GetPut ::*;
import Gearbox ::*;
import Pipe ::*;
import SpecialFIFOs ::*;
import Vector ::*;
import ConnectalConfig::*;
import StoreAndForward::*;

import Ethernet::*;
import EthMac::*;
import DmaEth::*;
import TestAPI::*;
import MemTypes::*;
import MemReadEngine::*;
import MemWriteEngine::*;
import PacketBuffer::*;
import HostInterface::*;
import `PinTypeInclude::*;
import ConnectalClocks::*;
`ifdef SYNTHESIS
import ALTERA_SI570_WRAPPER::*;
import AlteraExtra::*;
`else
import Sims::*;
`endif

interface TestTop;
   interface TestRequest request1;
   interface DmaRequest request2;
   interface Vector#(1, MemReadClient#(DataBusWidth)) readClient;
   interface Vector#(1, MemWriteClient#(DataBusWidth)) writeClient;
   interface `PinType pins;
endinterface

module mkTestTop#(TestIndication indication1, DmaIndication indication2)(TestTop);
   Clock defaultClock <- exposeCurrentClock();
   Reset defaultReset <- exposeCurrentReset();

`ifdef SYNTHESIS
   Wire#(Bit#(1)) clk_644_wire <- mkDWire(0);
   Wire#(Bit#(1)) clk_50_wire <- mkDWire(0);

   De5Clocks clocks <- mkDe5Clocks(clk_50_wire, clk_644_wire);
   De5SfpCtrl#(4) sfpctrl <- mkDe5SfpCtrl();
`else
   SimClocks clocks <- mkSimClocks();
`endif
   Clock txClock = clocks.clock_156_25;
   Clock phyClock = clocks.clock_644_53;
   Clock mgmtClock = clocks.clock_50;

   Reset txReset <- mkAsyncReset(2, defaultReset, txClock);

   Vector#(2, PacketBuffer) pkt_buff <- replicateM(mkPacketBuffer(clocked_by txClock, reset_by txReset));
   Vector#(1, StoreAndFwdFromRingToMac) ringToMac; //<- replicateM(mkStoreAndFwdFromRingToMac(txClock, txReset, clocked_by txClock, reset_by txReset));
   Vector#(1, StoreAndFwdFromMacToRing) macToRing; //<- replicateM(mkStoreAndFwdFromMacToRing(txClock, txReset, clocked_by txClock, reset_by txReset));

   for (Integer i = 0 ; i < 1 ; i = i +1) begin
      ringToMac[i] <- mkStoreAndFwdFromRingToMac(txClock, txReset, clocked_by txClock, reset_by txReset);
      macToRing[i] <- mkStoreAndFwdFromMacToRing(txClock, txReset, clocked_by txClock, reset_by txReset);
   end

   DmaController#(1) dmaController <- mkDmaController(vec(indication2), txClock, txReset);

   Reg#(Bit#(16)) iter <- mkReg(0);
   // Connect DMA controller and pkt_buff[0]
   mkConnection(dmaController.networkWriteClient[0], pkt_buff[0].writeServer);
   mkConnection(ringToMac[0].readClient, pkt_buff[0].readServer);
   mkConnection(ringToMac[0].macTx, macToRing[0].macRx);
   mkConnection(macToRing[0].writeClient, pkt_buff[1].writeServer);
   // Connect pkt_buff[1] and DMA controller
   mkConnection(dmaController.networkReadClient[0], pkt_buff[1].readServer);

   TestAPI api <- mkTestAPI(indication1, pkt_buff, ringToMac, macToRing, txClock, txReset);

   interface request1 = api.request;
   interface request2 = dmaController.request[0];
   interface readClient = dmaController.readClient;
   interface writeClient = dmaController.writeClient;
`ifdef SYNTHESIS
   interface `PinType pins;
      // Clocks
      method Action osc_50(Bit#(1) b3d, Bit#(1) b4a, Bit#(1) b4d, Bit#(1) b7a, Bit#(1) b7d, Bit#(1) b8a, Bit#(1) b8d);
         clk_50_wire <= b4a;
      endmethod
      method Action sfp(Bit#(1) refclk);
         clk_644_wire <= refclk;
      endmethod
      interface i2c = clocks.i2c;
//      interface sfpctrl = sfpctrl;
      interface deleteme_unused_clock = defaultClock;
      interface deleteme_unused_clock2 = mgmtClock;
      interface deleteme_unused_clock3 = defaultClock;
      interface deleteme_unused_reset = defaultReset;
   endinterface
`endif

endmodule
