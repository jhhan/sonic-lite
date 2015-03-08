
CONNECTALDIR?=../connectal
DTOP?=../sonic-lite
INTERFACES=Simple
BSVFILES=bsv/LedTop.bsv SimpleIF.bsv Top.bsv
CPPFILES=testsimple.cpp
NUMBER_OF_MASTERS =0
#PIN_TYPE = NetTopIfc
CONNECTALFLAGS += --xci=$(IPDIR)/$(BOARD)/synthesis/altera_mac.qip
CONNECTALFLAGS += --xci=$(IPDIR)/$(BOARD)/synthesis/altera_xcvr_reset_control_wrapper.qip
CONNECTALFLAGS += --xci=$(IPDIR)/$(BOARD)/synthesis/altera_xcvr_native_sv_wrapper.qip
CONNECTALFLAGS += --xci=$(IPDIR)/$(BOARD)/synthesis/altera_xgbe_pma_reconfig_wrapper.qip
CONNECTALFLAGS += --xci=$(DTOP)/verilog/pll/altera_clkctrl/synthesis/altera_clkctrl.qip
#CONNECTALFLAGS += --verilog=$(DTOP)/verilog/enc_dec/
#CONNECTALFLAGS += --verilog=$(DTOP)/verilog/gearbox/
#CONNECTALFLAGS += --verilog=$(DTOP)/verilog/port/
#CONNECTALFLAGS += --verilog=$(DTOP)/verilog/scramble/
#CONNECTALFLAGS += --verilog=$(DTOP)/verilog/si570/
#CONNECTALFLAGS += --verilog=$(DTOP)/verilog/timestamp/
#CONNECTALFLAGS += --verilog=$(DTOP)/verilog/traffic_controller/
#CONNECTALFLAGS += --tcl=$(DTOP)/verilog/add_sv.tcl
CONNECTALFLAGS += --chipscope=$(DTOP)/avalon.stp

# Supported Platforms:
# {vendor}_{platform}=1
ALTERA_SIM_vsim=1
ALTERA_SYNTH_de5=1

.PHONY: vsim

ifeq ($(ALTERA_SIM_$(BOARD)), 1)
CONNECTALFLAGS += --pinfo=./sim.json
CONNECTALFLAGS += --bscflags="+RTS -K46777216 -RTS -demote-errors G0066:G0045 -suppress-warnings G0046:G0020:S0015:S0080:S0039"
endif
ifeq ($(ALTERA_SYNTH_$(BOARD)), 1)
CONNECTALFLAGS += --pinfo=./synth.json
endif

PIN_BINDINGS?=-b PCIE:PCIE -b LED:LED -b OSC:OSC -b SFPA:SFPA -b SFPB:SFPB -b SFPC:SFPC -b SFPD:SFPD -b SFP:SFP -b DDR3A:DDR3A -b RZQ:RZQ

PORTAL_DUMP_MAP="Simple"

gentarget:: $(BOARD)/sources/sonic.qsf

prebuild::
ifeq ($(ALTERA_SIM_$(BOARD)), 1)
#	(cd $(BOARD); BUILDCACHE_CACHEDIR=$(BUILDCACHE_CACHEDIR) $(BUILDCACHE) quartus_sh -t ../scripts/connectal-synth-pll.tcl)
	(cd $(BOARD); BUILDCACHE_CACHEDIR=$(BUILDCACHE_CACHEDIR) $(BUILDCACHE) quartus_sh -t ../scripts/connectal-simu-pcietb.tcl)
endif
ifeq ($(ALTERA_SYNTH_$(BOARD)), 1)
	#(cd $(BOARD); BUILDCACHE_CACHEDIR=$(BUILDCACHE_CACHEDIR) $(BUILDCACHE) quartus_sh -t $(CONNECTALDIR)/scripts/connectal-synth-pll.tcl)
	#(cd $(BOARD); BUILDCACHE_CACHEDIR=$(BUILDCACHE_CACHEDIR) $(BUILDCACHE) quartus_sh -t ../scripts/connectal-synth-mac.tcl)
endif

$(BOARD)/sources/sonic.qsf: sonic.json $(CONNECTALDIR)/boardinfo/$(BOARD).json
ifeq ($(ALTERA_SYNTH_$(BOARD)), 1)
	mkdir -p $(BOARD)/sources
	$(CONNECTALDIR)/scripts/generate-constraints.py -f altera $(PIN_BINDINGS) -o $(BOARD)/sources/$(BOARD).qsf $(CONNECTALDIR)/boardinfo/$(BOARD).json sonic.json
endif

BSV_VERILOG_FILES+=$(PCIE_TBED_VERILOG_FILES)

vsim: gen.vsim prebuild
	make -C $@ vsim

include $(CONNECTALDIR)/Makefile.connectal
