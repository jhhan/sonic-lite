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

import Vector            :: *;
import Clocks            :: *;
import GetPut            :: *;
import FIFO              :: *;
import BRAMFIFO          :: *;
import Connectable       :: *;
import ClientServer      :: *;
import DefaultValue      :: *;
import PcieSplitter      :: *;
import Xilinx            :: *;
import Portal            :: *;
import Top               :: *;
import Leds              :: *;
import MemSlaveEngine    :: *;
import MemMasterEngine   :: *;
import PcieCsr           :: *;
import MemTypes          :: *;
import Bscan             :: *;
import PcieEndpointS5    :: *;
import PcieHost           :: *;
import NetTop             :: *;
import HostInterface      :: *;
import ConnectalClocks    :: *;
import ALTERA_PLL_156     :: *;
import EthPorts           :: *;
import Ethernet           :: *;
import PinsTop            :: *;
import AlteraExtra        :: *;
import ConfigCounter      :: *;
import ALTERA_SI570_WRAPPER          ::*;
import ALTERA_EDGE_DETECTOR_WRAPPER  ::*;
import ALTERA_ETH_SONIC_PMA :: *;
import EthSonicPma :: *;
import SonicUser::*;
import Pipe::*;
import LedController::*;

`ifndef DataBusWidth
`define DataBusWidth 64
`endif

`ifndef PinType
`define PinType Empty
`endif

`define ENABLE_PCIE

typedef `PinType PinType;

(* always_ready, always_enabled *)
interface SonicPinsTopIfc;
   (* prefix="" *)
   //interface NetExportIfc eth;
   (* prefix="i2c" *)
   interface Si570wrapI2c i2c;
   interface Bit#(1) led0;
//   interface Bit#(1) led1;
//   interface Bit#(1) led2;
   interface Bit#(1) led3;
//   interface Bit#(4) led_bracket;
   (* prefix="" *)
   interface ButtonInIfc buttons;
   interface Clock clk_b4a;
endinterface

(* synthesize, no_default_clock, no_default_reset *)
(* clock_prefix="", reset_prefix="" *)
module mkSonicTop #(Clock pcie_refclk_p,
                    Clock osc_50_b3b,
                    Clock osc_50_b3d,
                    Clock osc_50_b4a,
                    Clock osc_50_b4d,
                    Clock osc_50_b7a,
                    Clock osc_50_b7d,
                    Clock osc_50_b8a,
                    Clock osc_50_b8d,
                    Clock sfp_refclk,
                    Reset pcie_perst_n,
                    Reset user_reset_n) (PcieTop#(SonicPinsTopIfc));

   // ===================================
   // PLL:
   // Input:    50MHz
   // Output0: 156.25MHz
   //
   // NOTE: input clock must be dedicated to PLL to avoid error:
   // Error (175020): Illegal constraint of fractional PLL to the region (x-coordinate, y- coordinate) to (x-coordinate, y-coordinate): no valid locations in region
   // ===================================
`ifdef ENABLE_PCIE
   PcieHostTop host <- mkPcieHostTop(pcie_refclk_p, osc_50_b3b, pcie_perst_n);

`ifdef IMPORT_HOSTIF
   ConnectalTop#(PhysAddrWidth, DataBusWidth, PinType, NumberOfMasters) portalTop <- mkConnectalTop(host, clocked_by host.portalClock, reset_by host.portalReset);
`else
   ConnectalTop#(PhysAddrWidth, DataBusWidth, PinType, NumberOfMasters) portalTop <- mkConnectalTop(clocked_by host.portalClock, reset_by host.portalReset);
`endif //IMPORT_HOSTIF
`endif //ENABLE_PCIE

   AltClkCtrl clk_50_b4a_buf <- mkAltClkCtrl(osc_50_b4a);
   Reset rst_50   <- mkResetInverter(user_reset_n, clocked_by clk_50_b4a_buf.outclk);
   Reset rst_50_n <- mkAsyncReset(2, user_reset_n, clk_50_b4a_buf.outclk);
   Reset rst_644   <- mkResetInverter(user_reset_n, clocked_by sfp_refclk);
   Reset rst_644_n <- mkAsyncReset(2, user_reset_n, sfp_refclk);

   // ==============
   // Button 0 is wired at top level to user_reset_n
   // Button 1 is used to reset si570.
   ButtonIfc   btns <- mkButton(clocked_by clk_50_b4a_buf.outclk, reset_by rst_50_n);

   // ===================================
   // PLL:
   // Input:   SFP REFCLK from SI570
   // Output:  156.25MHz
   // Reset: Active High, must invert default Reset
   PLL156 pll156 <- mkPLL156(sfp_refclk, rst_644, clocked_by sfp_refclk, reset_by rst_644);
   Clock clk_156_25 = pll156.outclk0;
   Reset rst_156   <- mkResetInverter(user_reset_n, clocked_by clk_156_25);
   Reset rst_156_n <- mkAsyncReset(1, user_reset_n, clk_156_25, clocked_by clk_156_25);

   // ===================================
   // PLL: SI570 configurable clock
   // Input:
   // Output:
   // Reset: Active Low, use default Reset
   Si570Wrap            si570 <- mkSi570Wrap(clk_50_b4a_buf.outclk, rst_50_n, clocked_by clk_50_b4a_buf.outclk, reset_by rst_50_n);
   EdgeDetectorWrap     edgedetect <- mkEdgeDetectorWrap(clk_50_b4a_buf.outclk, rst_50_n, clocked_by clk_50_b4a_buf.outclk, reset_by rst_50_n);

   //NetTopIfc   eth <- mkNetTop(clk_50_b4a_buf.outclk, clk_156_25, sfp_refclk, clocked_by clk_156_25, reset_by rst_156_n);

   rule si570_connections;
      //ifreq_mode = 3'b000;  //100.0 MHZ
      //ifreq_mode = 3'b001;  //125.0 MHZ
      //ifreq_mode = 3'b010;  //156.25.0 MHZ
      //ifreq_mode = 3'b011;  //250 MHZ
      //ifreq_mode = 3'b100;  //312.5 MHZ
      //ifreq_mode = 3'b101;  //322.26 MHZ
      let ifreq_mode = 3'b110;  //644.53125 MHZ
      si570.ifreq.mode(ifreq_mode);
      si570.istart.go(edgedetect.odebounce.out);
   endrule

   rule button_to_si570;
      edgedetect.itrigger.in(btns.out.getButton1());
   endrule

   Reset sfp_reset_n <- mkAsyncReset(2, user_reset_n, sfp_refclk);
   //Reset xcvr_reset_n <- mkAsyncReset(2, user_reset_n, eth.ifcs.clk_xcvr[0]);

   LedController pci_led <- mkLedController(False, clocked_by pcie_refclk_p, reset_by pcie_perst_n);
   LedController eth_tx_led <- mkLedController(False, clocked_by clk_156_25, reset_by rst_156_n);
   //LedController eth_rx_led <- mkLedController(False, clocked_by eth.ifcs.clk_xcvr[0], reset_by xcvr_reset_n);
   LedController sfp_led <- mkLedController(False, clocked_by sfp_refclk, reset_by sfp_reset_n);

   rule led_pcie;
      pci_led.setPeriod(led_off, 500, led_on_max, 500);
   endrule
   rule led_eth_tx;
      eth_tx_led.setPeriod(led_off, 500, led_on_max, 500);
   endrule
   //rule led_eth_rx;
   //   eth_rx_led.setPeriod(led_off, 500, led_on_max, 500);
   //endrule
   rule led_sfp;
      sfp_led.setPeriod(led_off, 500, led_on_max, 500);
   endrule

 //  Vector#(4, LedController) led_xcvr_ <- replicateM(mkLedController(False, clocked_by clk_50_b4a_buf.outclk, reset_by rst_50_n));
 //  Led#(4) led_xcvr = combineLeds(led_xcvr_);

 //  rule led_xcvr_ready;
 //     for (Integer i = 0; i<4; i=i+1) begin
 //        led_xcvr_[i].setPeriod(led_off, 500, led_on_max, 500);
 //     end
 //  endrule

`ifdef ENABLE_PCIE
   mkConnection(host.tpciehost.master, portalTop.slave, clocked_by host.portalClock, reset_by host.portalReset);
   if (valueOf(NumberOfMasters) > 0) begin
      mapM(uncurry(mkConnection),zip(portalTop.masters, host.tpciehost.slave));
   end

   // going from level to edge-triggered interrupt
   Vector#(16, Reg#(Bool)) interruptRequested <- replicateM(mkReg(False, clocked_by host.portalClock, reset_by host.portalReset));
   rule interrupt_rule;
     Maybe#(Bit#(4)) intr = tagged Invalid;
     for (Integer i = 0; i < 16; i = i + 1) begin
	 if (portalTop.interrupt[i] && !interruptRequested[i])
             intr = tagged Valid fromInteger(i);
	 interruptRequested[i] <= portalTop.interrupt[i];
     end
     if (intr matches tagged Valid .intr_num) begin
        ReadOnly_MSIX_Entry msixEntry = host.tpciehost.msixEntry[intr_num];
        host.tpciehost.interruptRequest.put(tuple2({msixEntry.addr_hi, msixEntry.addr_lo}, msixEntry.msg_data));
     end
   endrule
`endif //ENABLE_PCIE

`ifndef BSIM
`ifdef ENABLE_PCIE
   interface pcie = host.tep7.pcie;
`endif
   interface pins = (interface SonicPinsTopIfc;
//      interface eth  = eth.ifcs;
      interface i2c  = si570.i2c;
      interface led0 = pci_led.ifc.out;
//      interface led1 = eth_tx_led.ifc.out;
//      interface led2 = eth_rx_led.ifc.out;
      interface led3 = sfp_led.ifc.out;
//      interface led_bracket = led_xcvr.out;
      interface buttons  = btns.in;
      interface Clock clk_b4a = clk_50_b4a_buf.outclk;
   endinterface);
//`endif
endmodule
