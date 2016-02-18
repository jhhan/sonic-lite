typedef struct {
    Bit#(8) in_port;
} CpuHeaderT deriving (Bits, Eq);

instance DefaultValue#(CpuHeaderT);
defaultValue=
CpuHeaderT {
    in_port: 0
};
endinstance

instance FShow#(CpuHeaderT);
    function Fmt fshow(CpuHeaderT p);
        return $format("CpuHeaderT: in_port=%h" , p.in_port);
    endfunction
endinstance

function CpuHeaderT extract_cpu_header(Bit#(8) data);
    Vector#(8, Bit#(1)) dataVec=unpack(data);
    Vector#(8, Bit#(1)) in_port = takeAt(0, dataVec);
    CpuHeaderT cpu_header_t = defaultValue;
    cpu_header_t.in_port = pack(in_port);
    return cpu_header_t;
endfunction

typedef struct {
    Bit#(16) srcPort;
    Bit#(16) dstPort;
    Bit#(16) length_;
    Bit#(16) checksum;
} UdpT deriving (Bits, Eq);

instance DefaultValue#(UdpT);
defaultValue=
UdpT {
    srcPort: 0,
    dstPort: 0,
    length_: 0,
    checksum: 0
};
endinstance

instance FShow#(UdpT);
    function Fmt fshow(UdpT p);
        return $format("UdpT: srcPort=%h, dstPort=%h, length_=%h, checksum=%h" , p.srcPort, p.dstPort, p.length_, p.checksum);
    endfunction
endinstance

function UdpT extract_udp(Bit#(64) data);
    Vector#(64, Bit#(1)) dataVec=unpack(data);
    Vector#(16, Bit#(1)) srcPort = takeAt(0, dataVec);
    Vector#(16, Bit#(1)) dstPort = takeAt(16, dataVec);
    Vector#(16, Bit#(1)) length_ = takeAt(32, dataVec);
    Vector#(16, Bit#(1)) checksum = takeAt(48, dataVec);
    UdpT udp_t = defaultValue;
    udp_t.srcPort = pack(srcPort);
    udp_t.dstPort = pack(dstPort);
    udp_t.length_ = pack(length_);
    udp_t.checksum = pack(checksum);
    return udp_t;
endfunction

typedef struct {
    Bit#(4) mcast_grp;
    Bit#(4) egress_rid;
    Bit#(16) mcast_hash;
    Bit#(32) lf_field_list;
} IntrinsicMetadataT deriving (Bits, Eq);

instance DefaultValue#(IntrinsicMetadataT);
defaultValue=
IntrinsicMetadataT {
    mcast_grp: 0,
    egress_rid: 0,
    mcast_hash: 0,
    lf_field_list: 0
};
endinstance

instance FShow#(IntrinsicMetadataT);
    function Fmt fshow(IntrinsicMetadataT p);
        return $format("IntrinsicMetadataT: mcast_grp=%h, egress_rid=%h, mcast_hash=%h, lf_field_list=%h" , p.mcast_grp, p.egress_rid, p.mcast_hash, p.lf_field_list);
    endfunction
endinstance

function IntrinsicMetadataT extract_intrinsic_metadata(Bit#(56) data);
    Vector#(56, Bit#(1)) dataVec=unpack(data);
    Vector#(4, Bit#(1)) mcast_grp = takeAt(0, dataVec);
    Vector#(4, Bit#(1)) egress_rid = takeAt(4, dataVec);
    Vector#(16, Bit#(1)) mcast_hash = takeAt(8, dataVec);
    Vector#(32, Bit#(1)) lf_field_list = takeAt(24, dataVec);
    IntrinsicMetadataT intrinsic_metadata_t = defaultValue;
    intrinsic_metadata_t.mcast_grp = pack(mcast_grp);
    intrinsic_metadata_t.egress_rid = pack(egress_rid);
    intrinsic_metadata_t.mcast_hash = pack(mcast_hash);
    intrinsic_metadata_t.lf_field_list = pack(lf_field_list);
    return intrinsic_metadata_t;
endfunction

typedef struct {
    Bit#(8) msgtype;
    Bit#(16) inst;
    Bit#(8) round;
    Bit#(8) vround;
    Bit#(64) acceptor;
    Bit#(512) value;
} PaxosT deriving (Bits, Eq);

instance DefaultValue#(PaxosT);
defaultValue=
PaxosT {
    msgtype: 0,
    inst: 0,
    round: 0,
    vround: 0,
    acceptor: 0,
    value: 0
};
endinstance

instance FShow#(PaxosT);
    function Fmt fshow(PaxosT p);
        return $format("PaxosT: msgtype=%h, inst=%h, round=%h, vround=%h, acceptor=%h, value=%h" , p.msgtype, p.inst, p.round, p.vround, p.acceptor, p.value);
    endfunction
endinstance

function PaxosT extract_paxos(Bit#(616) data);
    Vector#(616, Bit#(1)) dataVec=unpack(data);
    Vector#(8, Bit#(1)) msgtype = takeAt(0, dataVec);
    Vector#(16, Bit#(1)) inst = takeAt(8, dataVec);
    Vector#(8, Bit#(1)) round = takeAt(24, dataVec);
    Vector#(8, Bit#(1)) vround = takeAt(32, dataVec);
    Vector#(64, Bit#(1)) acceptor = takeAt(40, dataVec);
    Vector#(512, Bit#(1)) value = takeAt(104, dataVec);
    PaxosT paxos_t = defaultValue;
    paxos_t.msgtype = pack(msgtype);
    paxos_t.inst = pack(inst);
    paxos_t.round = pack(round);
    paxos_t.vround = pack(vround);
    paxos_t.acceptor = pack(acceptor);
    paxos_t.value = pack(value);
    return paxos_t;
endfunction

typedef struct {
    Bit#(16) hrd;
    Bit#(16) pro;
    Bit#(8) hln;
    Bit#(8) pln;
    Bit#(16) op;
    Bit#(48) sha;
    Bit#(32) spa;
    Bit#(48) tha;
    Bit#(32) tpa;
} ArpT deriving (Bits, Eq);

instance DefaultValue#(ArpT);
defaultValue=
ArpT {
    hrd: 0,
    pro: 0,
    hln: 0,
    pln: 0,
    op: 0,
    sha: 0,
    spa: 0,
    tha: 0,
    tpa: 0
};
endinstance

instance FShow#(ArpT);
    function Fmt fshow(ArpT p);
        return $format("ArpT: hrd=%h, pro=%h, hln=%h, pln=%h, op=%h, sha=%h, spa=%h, tha=%h, tpa=%h" , p.hrd, p.pro, p.hln, p.pln, p.op, p.sha, p.spa, p.tha, p.tpa);
    endfunction
endinstance

function ArpT extract_arp(Bit#(224) data);
    Vector#(224, Bit#(1)) dataVec=unpack(data);
    Vector#(16, Bit#(1)) hrd = takeAt(0, dataVec);
    Vector#(16, Bit#(1)) pro = takeAt(16, dataVec);
    Vector#(8, Bit#(1)) hln = takeAt(32, dataVec);
    Vector#(8, Bit#(1)) pln = takeAt(40, dataVec);
    Vector#(16, Bit#(1)) op = takeAt(48, dataVec);
    Vector#(48, Bit#(1)) sha = takeAt(64, dataVec);
    Vector#(32, Bit#(1)) spa = takeAt(112, dataVec);
    Vector#(48, Bit#(1)) tha = takeAt(144, dataVec);
    Vector#(32, Bit#(1)) tpa = takeAt(192, dataVec);
    ArpT arp_t = defaultValue;
    arp_t.hrd = pack(hrd);
    arp_t.pro = pack(pro);
    arp_t.hln = pack(hln);
    arp_t.pln = pack(pln);
    arp_t.op = pack(op);
    arp_t.sha = pack(sha);
    arp_t.spa = pack(spa);
    arp_t.tha = pack(tha);
    arp_t.tpa = pack(tpa);
    return arp_t;
endfunction

typedef struct {
    Bit#(4) version;
    Bit#(4) ihl;
    Bit#(8) diffserv;
    Bit#(16) totalLen;
    Bit#(16) identification;
    Bit#(3) flags;
    Bit#(13) fragOffset;
    Bit#(8) ttl;
    Bit#(8) protocol;
    Bit#(16) hdrChecksum;
    Bit#(32) srcAddr;
    Bit#(32) dstAddr;
} Ipv4T deriving (Bits, Eq);

instance DefaultValue#(Ipv4T);
defaultValue=
Ipv4T {
    version: 0,
    ihl: 0,
    diffserv: 0,
    totalLen: 0,
    identification: 0,
    flags: 0,
    fragOffset: 0,
    ttl: 0,
    protocol: 0,
    hdrChecksum: 0,
    srcAddr: 0,
    dstAddr: 0
};
endinstance

instance FShow#(Ipv4T);
    function Fmt fshow(Ipv4T p);
        return $format("Ipv4T: version=%h, ihl=%h, diffserv=%h, totalLen=%h, identification=%h, flags=%h, fragOffset=%h, ttl=%h, protocol=%h, hdrChecksum=%h, srcAddr=%h, dstAddr=%h" , p.version, p.ihl, p.diffserv, p.totalLen, p.identification, p.flags, p.fragOffset, p.ttl, p.protocol, p.hdrChecksum, p.srcAddr, p.dstAddr);
    endfunction
endinstance

function Ipv4T extract_ipv4(Bit#(160) data);
    Vector#(160, Bit#(1)) dataVec=unpack(data);
    Vector#(4, Bit#(1)) version = takeAt(0, dataVec);
    Vector#(4, Bit#(1)) ihl = takeAt(4, dataVec);
    Vector#(8, Bit#(1)) diffserv = takeAt(8, dataVec);
    Vector#(16, Bit#(1)) totalLen = takeAt(16, dataVec);
    Vector#(16, Bit#(1)) identification = takeAt(32, dataVec);
    Vector#(3, Bit#(1)) flags = takeAt(48, dataVec);
    Vector#(13, Bit#(1)) fragOffset = takeAt(51, dataVec);
    Vector#(8, Bit#(1)) ttl = takeAt(64, dataVec);
    Vector#(8, Bit#(1)) protocol = takeAt(72, dataVec);
    Vector#(16, Bit#(1)) hdrChecksum = takeAt(80, dataVec);
    Vector#(32, Bit#(1)) srcAddr = takeAt(96, dataVec);
    Vector#(32, Bit#(1)) dstAddr = takeAt(128, dataVec);
    Ipv4T ipv4_t = defaultValue;
    ipv4_t.version = pack(version);
    ipv4_t.ihl = pack(ihl);
    ipv4_t.diffserv = pack(diffserv);
    ipv4_t.totalLen = pack(totalLen);
    ipv4_t.identification = pack(identification);
    ipv4_t.flags = pack(flags);
    ipv4_t.fragOffset = pack(fragOffset);
    ipv4_t.ttl = pack(ttl);
    ipv4_t.protocol = pack(protocol);
    ipv4_t.hdrChecksum = pack(hdrChecksum);
    ipv4_t.srcAddr = pack(srcAddr);
    ipv4_t.dstAddr = pack(dstAddr);
    return ipv4_t;
endfunction

typedef struct {
    Bit#(8) round;
} IngressMetadataT deriving (Bits, Eq);

instance DefaultValue#(IngressMetadataT);
defaultValue=
IngressMetadataT {
    round: 0
};
endinstance

instance FShow#(IngressMetadataT);
    function Fmt fshow(IngressMetadataT p);
        return $format("IngressMetadataT: round=%h" , p.round);
    endfunction
endinstance

function IngressMetadataT extract_ingress_metadata(Bit#(8) data);
    Vector#(8, Bit#(1)) dataVec=unpack(data);
    Vector#(8, Bit#(1)) round = takeAt(0, dataVec);
    IngressMetadataT ingress_metadata_t = defaultValue;
    ingress_metadata_t.round = pack(round);
    return ingress_metadata_t;
endfunction

typedef struct {
    Bit#(48) dstAddr;
    Bit#(48) srcAddr;
    Bit#(16) etherType;
} EthernetT deriving (Bits, Eq);

instance DefaultValue#(EthernetT);
defaultValue=
EthernetT {
    dstAddr: 0,
    srcAddr: 0,
    etherType: 0
};
endinstance

instance FShow#(EthernetT);
    function Fmt fshow(EthernetT p);
        return $format("EthernetT: dstAddr=%h, srcAddr=%h, etherType=%h" , p.dstAddr, p.srcAddr, p.etherType);
    endfunction
endinstance

function EthernetT extract_ethernet(Bit#(112) data);
    Vector#(112, Bit#(1)) dataVec=unpack(data);
    Vector#(48, Bit#(1)) dstAddr = takeAt(0, dataVec);
    Vector#(48, Bit#(1)) srcAddr = takeAt(48, dataVec);
    Vector#(16, Bit#(1)) etherType = takeAt(96, dataVec);
    EthernetT ethernet_t = defaultValue;
    ethernet_t.dstAddr = pack(dstAddr);
    ethernet_t.srcAddr = pack(srcAddr);
    ethernet_t.etherType = pack(etherType);
    return ethernet_t;
endfunction

typedef struct {
    Bit#(9) ingress_port;
    Bit#(32) packet_length;
    Bit#(9) egress_spec;
    Bit#(9) egress_port;
    Bit#(32) egress_instance;
    Bit#(32) instance_type;
    Bit#(32) clone_spec;
    Bit#(5) _padding;
} StandardMetadataT deriving (Bits, Eq);

instance DefaultValue#(StandardMetadataT);
defaultValue=
StandardMetadataT {
    ingress_port: 0,
    packet_length: 0,
    egress_spec: 0,
    egress_port: 0,
    egress_instance: 0,
    instance_type: 0,
    clone_spec: 0,
    _padding: 0
};
endinstance

instance FShow#(StandardMetadataT);
    function Fmt fshow(StandardMetadataT p);
        return $format("StandardMetadataT: ingress_port=%h, packet_length=%h, egress_spec=%h, egress_port=%h, egress_instance=%h, instance_type=%h, clone_spec=%h, _padding=%h" , p.ingress_port, p.packet_length, p.egress_spec, p.egress_port, p.egress_instance, p.instance_type, p.clone_spec, p._padding);
    endfunction
endinstance

function StandardMetadataT extract_standard_metadata(Bit#(160) data);
    Vector#(160, Bit#(1)) dataVec=unpack(data);
    Vector#(9, Bit#(1)) ingress_port = takeAt(0, dataVec);
    Vector#(32, Bit#(1)) packet_length = takeAt(9, dataVec);
    Vector#(9, Bit#(1)) egress_spec = takeAt(41, dataVec);
    Vector#(9, Bit#(1)) egress_port = takeAt(50, dataVec);
    Vector#(32, Bit#(1)) egress_instance = takeAt(59, dataVec);
    Vector#(32, Bit#(1)) instance_type = takeAt(91, dataVec);
    Vector#(32, Bit#(1)) clone_spec = takeAt(123, dataVec);
    Vector#(5, Bit#(1)) _padding = takeAt(155, dataVec);
    StandardMetadataT standard_metadata_t = defaultValue;
    standard_metadata_t.ingress_port = pack(ingress_port);
    standard_metadata_t.packet_length = pack(packet_length);
    standard_metadata_t.egress_spec = pack(egress_spec);
    standard_metadata_t.egress_port = pack(egress_port);
    standard_metadata_t.egress_instance = pack(egress_instance);
    standard_metadata_t.instance_type = pack(instance_type);
    standard_metadata_t.clone_spec = pack(clone_spec);
    standard_metadata_t._padding = pack(_padding);
    return standard_metadata_t;
endfunction

typedef struct {
    Bit#(8) role;
} SwitchMetadataT deriving (Bits, Eq);

instance DefaultValue#(SwitchMetadataT);
defaultValue=
SwitchMetadataT {
    role: 0
};
endinstance

instance FShow#(SwitchMetadataT);
    function Fmt fshow(SwitchMetadataT p);
        return $format("SwitchMetadataT: role=%h" , p.role);
    endfunction
endinstance

function SwitchMetadataT extract_switch_metadata(Bit#(8) data);
    Vector#(8, Bit#(1)) dataVec=unpack(data);
    Vector#(8, Bit#(1)) role = takeAt(0, dataVec);
    SwitchMetadataT switch_metadata_t = defaultValue;
    switch_metadata_t.role = pack(role);
    return switch_metadata_t;
endfunction

import Connectable::*;
import DefaultValue::*;
import FIFO::*;
import FIFOF::*;
import FShow::*;
import GetPut::*;
import List::*;
import StmtFSM::*;
import SpecialFIFOs::*;
import Vector::*;

import Pipe::*;
import Ethernet::*;
import P4Types::*;
typedef enum {StateStart,StateParseEthernet,StateParseArp,StateParseIpv4,StateParseCpuHeader,StateParseUdp,StateParsePaxos} ParserState deriving (Bits, Eq);
instance FShow#(ParserState);
    function Fmt fshow (ParserState state);
        return $format(" State %x", state);
    endfunction
endinstance
    
module mkStateStart#(Reg#(ParserState) state, FIFOF#(EtherData) datain, Wire#(Bool) start_fsm)(Empty);

    rule load_packet if (state==StateStart);
        let v = datain.first;
        if (v.sop) begin
            state <= StateParseEthernet;
            start_fsm <= True;
        end
        else begin
            datain.deq;
            start_fsm <= False;
        end
    endrule
endmodule
interface ParseEthernet;
    interface Get#(Bit#(16)) parse_arp;
    interface Get#(Bit#(16)) parse_ipv4;
    method Action start;
    method Action clear;
endinterface
module mkStateParseEthernet#(Reg#(ParserState) state, FIFOF#(EtherData) datain)(ParseEthernet);
    FIFOF#(Bit#(16)) unparsed_parse_arp_fifo <- mkSizedFIFOF(1);
    FIFOF#(Bit#(16)) unparsed_parse_ipv4_fifo <- mkSizedFIFOF(1);
    Wire#(Bit#(128)) packet_in_wire <- mkDWire(0);
    Vector#(3, Wire#(Maybe#(ParserState))) next_state_wire <- replicateM(mkDWire(tagged Invalid));
    PulseWire start_wire <- mkPulseWire();
    PulseWire clear_wire <- mkPulseWire();
    (* fire_when_enabled *)
    rule arbitrate_outgoing_state if (state == StateParseEthernet);
        Vector#(3, Bool) next_state_valid = replicate(False);
        Bool stateSet = False;
        for (Integer port=0; port<3; port=port+1) begin
            next_state_valid[port] = isValid(next_state_wire[port]);
            if (!stateSet && next_state_valid[port]) begin
                stateSet = True;
                ParserState next_state = fromMaybe(?, next_state_wire[port]);
                state <= next_state;
            end
        end
    endrule
    function ParserState compute_next_state(Bit#(16) etherType);
        ParserState nextState = StateStart;
        case (byteSwap(etherType)) matches
            'h806: begin
                nextState=StateParseArp;
            end
            'h800: begin
                nextState=StateParseIpv4;
            end
            default: begin
                nextState=StateStart;
            end
        endcase
        return nextState;
    endfunction
    rule load_packet if (state == StateParseEthernet);
        let data_current <- toGet(datain).get;
        packet_in_wire <= data_current.data;
    endrule
    Stmt parse_ethernet =
    seq
    action
        let data = packet_in_wire;
        Vector#(128, Bit#(1)) dataVec = unpack(data);
        let ethernet = extract_ethernet(pack(takeAt(0, dataVec)));
        $display(fshow(ethernet));
        Vector#(16, Bit#(1)) unparsed = takeAt(112, dataVec);
        let nextState = compute_next_state(ethernet.etherType);
        $display("Goto state %h", nextState);
        if (nextState == StateParseArp) begin
            unparsed_parse_arp_fifo.enq(pack(unparsed));
        end
        if (nextState == StateParseIpv4) begin
            unparsed_parse_ipv4_fifo.enq(pack(unparsed));
        end
        next_state_wire[0] <= tagged Valid nextState;
    endaction
    endseq;
    FSM fsm_parse_ethernet <- mkFSM(parse_ethernet);
    rule start_fsm if (start_wire);
        fsm_parse_ethernet.start;
    endrule
    rule clear_fsm if (clear_wire);
        fsm_parse_ethernet.abort;
    endrule
    method Action start();
        start_wire.send();
    endmethod
    method Action clear();
        clear_wire.send();
    endmethod
    interface parse_arp = toGet(unparsed_parse_arp_fifo);
    interface parse_ipv4 = toGet(unparsed_parse_ipv4_fifo);
endmodule
interface ParseArp;
    interface Put#(Bit#(16)) parse_ethernet;
    method Action start;
    method Action clear;
endinterface
module mkStateParseArp#(Reg#(ParserState) state, FIFOF#(EtherData) datain)(ParseArp);
    FIFOF#(Bit#(144)) internal_fifo <- mkSizedFIFOF(1);
    FIFOF#(Bit#(16)) unparsed_parse_ethernet_fifo <- mkBypassFIFOF;
    Wire#(Bit#(128)) packet_in_wire <- mkDWire(0);
    Vector#(1, Wire#(Maybe#(ParserState))) next_state_wire <- replicateM(mkDWire(tagged Invalid));
    PulseWire start_wire <- mkPulseWire();
    PulseWire clear_wire <- mkPulseWire();
    (* fire_when_enabled *)
    rule arbitrate_outgoing_state if (state == StateParseArp);
        Vector#(1, Bool) next_state_valid = replicate(False);
        Bool stateSet = False;
        for (Integer port=0; port<1; port=port+1) begin
            next_state_valid[port] = isValid(next_state_wire[port]);
            if (!stateSet && next_state_valid[port]) begin
                stateSet = True;
                ParserState next_state = fromMaybe(?, next_state_wire[port]);
                state <= next_state;
            end
        end
    endrule
    
    rule load_packet if (state == StateParseArp);
        let data_current <- toGet(datain).get;
        packet_in_wire <= data_current.data;
    endrule
    Stmt parse_arp =
    seq
    action
        let data_current = packet_in_wire;
        let unparsed <- toGet(unparsed_parse_ethernet_fifo).get;
        Bit#(144) data = {data_current, unparsed};
        Vector#(144, Bit#(1)) dataVec = unpack(data);
        internal_fifo.enq(data);
    endaction
    action
        let data_current = packet_in_wire;
        let data_delayed <- toGet(internal_fifo).get;
        Bit#(272) data = {data_current, data_delayed};
        Vector#(272, Bit#(1)) dataVec = unpack(data);
        let arp = extract_arp(pack(takeAt(0, dataVec)));
        $display(fshow(arp));
        next_state_wire[0] <= tagged Valid StateStart;
    endaction
    endseq;
    FSM fsm_parse_arp <- mkFSM(parse_arp);
    rule start_fsm if (start_wire);
        fsm_parse_arp.start;
    endrule
    rule clear_fsm if (clear_wire);
        fsm_parse_arp.abort;
    endrule
    method Action start();
        start_wire.send();
    endmethod
    method Action clear();
        clear_wire.send();
    endmethod
    interface parse_ethernet = toPut(unparsed_parse_ethernet_fifo);
endmodule
interface ParseIpv4;
    interface Put#(Bit#(16)) parse_ethernet;
    interface Get#(Bit#(112)) parse_cpu_header;
    interface Get#(Bit#(112)) parse_udp;
    method Action start;
    method Action clear;
endinterface
module mkStateParseIpv4#(Reg#(ParserState) state, FIFOF#(EtherData) datain)(ParseIpv4);
    FIFOF#(Bit#(16)) unparsed_parse_ethernet_fifo <- mkBypassFIFOF;
    FIFOF#(Bit#(112)) unparsed_parse_cpu_header_fifo <- mkSizedFIFOF(1);
    FIFOF#(Bit#(112)) unparsed_parse_udp_fifo <- mkSizedFIFOF(1);
    FIFOF#(Bit#(144)) internal_fifo <- mkSizedFIFOF(1);
    Wire#(Bit#(128)) packet_in_wire <- mkDWire(0);
    Vector#(3, Wire#(Maybe#(ParserState))) next_state_wire <- replicateM(mkDWire(tagged Invalid));
    PulseWire start_wire <- mkPulseWire();
    PulseWire clear_wire <- mkPulseWire();
    (* fire_when_enabled *)
    rule arbitrate_outgoing_state if (state == StateParseIpv4);
        Vector#(3, Bool) next_state_valid = replicate(False);
        Bool stateSet = False;
        for (Integer port=0; port<3; port=port+1) begin
            next_state_valid[port] = isValid(next_state_wire[port]);
            if (!stateSet && next_state_valid[port]) begin
                stateSet = True;
                ParserState next_state = fromMaybe(?, next_state_wire[port]);
                state <= next_state;
            end
        end
    endrule
    function ParserState compute_next_state(Bit#(8) protocol);
        ParserState nextState = StateStart;
        case (byteSwap(protocol)) matches
            'h39: begin //FIXME
                nextState=StateParseCpuHeader;
            end
            'h11: begin
                nextState=StateParseUdp;
            end
            default: begin
                nextState=StateStart;
            end
        endcase
        return nextState;
    endfunction
    rule load_packet if (state == StateParseIpv4);
        let data_current <- toGet(datain).get;
        packet_in_wire <= data_current.data;
    endrule
    Stmt parse_ipv4 =
    seq
    action
        let data_current = packet_in_wire;
        let unparsed <- toGet(unparsed_parse_ethernet_fifo).get;
        Bit#(144) data = {data_current, unparsed};
        Vector#(144, Bit#(1)) dataVec = unpack(data);
        internal_fifo.enq(data);
    endaction
    action
        let data_current = packet_in_wire;
        let data_delayed <- toGet(internal_fifo).get;
        Bit#(272) data = {data_current, data_delayed};
        Vector#(272, Bit#(1)) dataVec = unpack(data);
        let ipv4 = extract_ipv4(pack(takeAt(0, dataVec)));
        $display(fshow(ipv4));
        Vector#(112, Bit#(1)) unparsed = takeAt(160, dataVec);
        let nextState = compute_next_state(ipv4.protocol);
        $display("Goto state %h", nextState);
        if (nextState == StateParseCpuHeader) begin
            unparsed_parse_cpu_header_fifo.enq(pack(unparsed));
        end
        if (nextState == StateParseUdp) begin
            unparsed_parse_udp_fifo.enq(pack(unparsed));
        end
        next_state_wire[0] <= tagged Valid nextState;
    endaction
    endseq;
    FSM fsm_parse_ipv4 <- mkFSM(parse_ipv4);
    rule start_fsm if (start_wire);
        fsm_parse_ipv4.start;
    endrule
    rule clear_fsm if (clear_wire);
        fsm_parse_ipv4.abort;
    endrule
    method Action start();
        start_wire.send();
    endmethod
    method Action clear();
        clear_wire.send();
    endmethod
    interface parse_ethernet = toPut(unparsed_parse_ethernet_fifo);
    interface parse_cpu_header = toGet(unparsed_parse_cpu_header_fifo);
    interface parse_udp = toGet(unparsed_parse_udp_fifo);
endmodule
interface ParseCpuHeader;
    interface Put#(Bit#(112)) parse_ipv4;
    method Action start;
    method Action clear;
endinterface
module mkStateParseCpuHeader#(Reg#(ParserState) state, FIFOF#(EtherData) datain)(ParseCpuHeader);
    FIFOF#(Bit#(112)) unparsed_parse_ipv4_fifo <- mkBypassFIFOF;
    Wire#(Bit#(128)) packet_in_wire <- mkDWire(0);
    Vector#(1, Wire#(Maybe#(ParserState))) next_state_wire <- replicateM(mkDWire(tagged Invalid));
    PulseWire start_wire <- mkPulseWire();
    PulseWire clear_wire <- mkPulseWire();
    (* fire_when_enabled *)
    rule arbitrate_outgoing_state if (state == StateParseCpuHeader);
        Vector#(1, Bool) next_state_valid = replicate(False);
        Bool stateSet = False;
        for (Integer port=0; port<1; port=port+1) begin
            next_state_valid[port] = isValid(next_state_wire[port]);
            if (!stateSet && next_state_valid[port]) begin
                stateSet = True;
                ParserState next_state = fromMaybe(?, next_state_wire[port]);
                state <= next_state;
            end
        end
    endrule
    
    rule load_packet if (state == StateParseCpuHeader);
        let data_current <- toGet(datain).get;
        packet_in_wire <= data_current.data;
    endrule
    Stmt parse_cpu_header =
    seq
    action
        let data = packet_in_wire;
        Vector#(128, Bit#(1)) dataVec = unpack(data);
        let nextState = StateStart; 
        next_state_wire[0] <= tagged Valid nextState;
    endaction
    endseq;
    FSM fsm_parse_cpu_header <- mkFSM(parse_cpu_header);
    rule start_fsm if (start_wire);
        fsm_parse_cpu_header.start;
    endrule
    rule clear_fsm if (clear_wire);
        fsm_parse_cpu_header.abort;
    endrule
    method Action start();
        start_wire.send();
    endmethod
    method Action clear();
        clear_wire.send();
    endmethod
    interface parse_ipv4 = toPut(unparsed_parse_ipv4_fifo);
endmodule
interface ParseUdp;
    interface Put#(Bit#(112)) parse_ipv4;
    interface Get#(Bit#(176)) parse_paxos;
    method Action start;
    method Action clear;
endinterface
module mkStateParseUdp#(Reg#(ParserState) state, FIFOF#(EtherData) datain)(ParseUdp);
    FIFOF#(Bit#(112)) unparsed_parse_ipv4_fifo <- mkBypassFIFOF;
    FIFOF#(Bit#(176)) unparsed_parse_paxos_fifo <- mkSizedFIFOF(1);
    Wire#(Bit#(128)) packet_in_wire <- mkDWire(0);
    Vector#(2, Wire#(Maybe#(ParserState))) next_state_wire <- replicateM(mkDWire(tagged Invalid));
    PulseWire start_wire <- mkPulseWire();
    PulseWire clear_wire <- mkPulseWire();
    (* fire_when_enabled *)
    rule arbitrate_outgoing_state if (state == StateParseUdp);
        Vector#(2, Bool) next_state_valid = replicate(False);
        Bool stateSet = False;
        for (Integer port=0; port<2; port=port+1) begin
            next_state_valid[port] = isValid(next_state_wire[port]);
            if (!stateSet && next_state_valid[port]) begin
                stateSet = True;
                ParserState next_state = fromMaybe(?, next_state_wire[port]);
                state <= next_state;
            end
        end
    endrule
    function ParserState compute_next_state(Bit#(16) dstPort);
        ParserState nextState = StateStart;
        case (byteSwap(dstPort)) matches
            'h8888: begin
                nextState=StateParsePaxos;
            end
            default: begin
                nextState=StateStart;
            end
        endcase
        return nextState;
    endfunction
    rule load_packet if (state == StateParseUdp);
        let data_current <- toGet(datain).get;
        packet_in_wire <= data_current.data;
    endrule
    Stmt parse_udp =
    seq
    action
        let data_current = packet_in_wire;
        let unparsed_delayed <- toGet(unparsed_parse_ipv4_fifo).get;
        Bit#(240) data = {data_current, unparsed_delayed};
        Vector#(240, Bit#(1)) dataVec = unpack(data);
        let udp = extract_udp(pack(takeAt(0, dataVec)));
        $display(fshow(udp));
        Vector#(176, Bit#(1)) unparsed = takeAt(64, dataVec);
        let nextState = compute_next_state(udp.dstPort);
        $display("Goto state %h", nextState);
        if (nextState == StateParsePaxos) begin
            unparsed_parse_paxos_fifo.enq(pack(unparsed));
        end
        next_state_wire[0] <= tagged Valid nextState;
    endaction
    endseq;
    FSM fsm_parse_udp <- mkFSM(parse_udp);
    rule start_fsm if (start_wire);
        fsm_parse_udp.start;
    endrule
    rule clear_fsm if (clear_wire);
        fsm_parse_udp.abort;
    endrule
    method Action start();
        start_wire.send();
    endmethod
    method Action clear();
        clear_wire.send();
    endmethod
    interface parse_ipv4 = toPut(unparsed_parse_ipv4_fifo);
    interface parse_paxos = toGet(unparsed_parse_paxos_fifo);
endmodule
interface ParsePaxos;
    interface Put#(Bit#(176)) parse_udp;
    method Action start;
    method Action clear;
endinterface
module mkStateParsePaxos#(Reg#(ParserState) state, FIFOF#(EtherData) datain)(ParsePaxos);
    FIFOF#(Bit#(304)) internal_fifo1 <- mkSizedFIFOF(1);
    FIFOF#(Bit#(432)) internal_fifo2 <- mkSizedFIFOF(1);
    FIFOF#(Bit#(560)) internal_fifo3 <- mkSizedFIFOF(1);
    FIFOF#(Bit#(176)) unparsed_parse_udp_fifo <- mkBypassFIFOF;
    Wire#(Bit#(128)) packet_in_wire <- mkDWire(0);
    Vector#(1, Wire#(Maybe#(ParserState))) next_state_wire <- replicateM(mkDWire(tagged Invalid));
    PulseWire start_wire <- mkPulseWire();
    PulseWire clear_wire <- mkPulseWire();
    (* fire_when_enabled *)
    rule arbitrate_outgoing_state if (state == StateParsePaxos);
        Vector#(1, Bool) next_state_valid = replicate(False);
        Bool stateSet = False;
        for (Integer port=0; port<1; port=port+1) begin
            next_state_valid[port] = isValid(next_state_wire[port]);
            if (!stateSet && next_state_valid[port]) begin
                stateSet = True;
                ParserState next_state = fromMaybe(?, next_state_wire[port]);
                state <= next_state;
            end
        end
    endrule
    
    rule load_packet if (state == StateParsePaxos);
        let data_current <- toGet(datain).get;
        packet_in_wire <= data_current.data;
    endrule
    Stmt parse_paxos =
    seq
    action
        let data_current = packet_in_wire;
        let unparsed <- toGet(unparsed_parse_udp_fifo).get;
        Bit#(304) data = {data_current, unparsed};
        internal_fifo1.enq(data);
    endaction
    action
        let data_current = packet_in_wire;
        let data_delayed <- toGet(internal_fifo1).get;
        Bit#(432) data = {data_current, data_delayed};
        internal_fifo2.enq(data);
    endaction
    action
        let data_current = packet_in_wire;
        let data_delayed <- toGet(internal_fifo2).get;
        Bit#(560) data = {data_current, data_delayed};
        internal_fifo3.enq(data);
    endaction
    action
        let data_current = packet_in_wire;
        let data_delayed <- toGet(internal_fifo3).get;
        Bit#(688) data = {data_current, data_delayed};
        Vector#(688, Bit#(1)) dataVec = unpack(data);
        let paxos = extract_paxos(pack(takeAt(0, dataVec)));
        $display(fshow(paxos));
        next_state_wire[0] <= tagged Valid StateStart;
    endaction
    endseq;
    FSM fsm_parse_paxos <- mkFSM(parse_paxos);
    rule start_fsm if (start_wire);
        fsm_parse_paxos.start;
    endrule
    rule clear_fsm if (clear_wire);
        fsm_parse_paxos.abort;
    endrule
    method Action start();
        start_wire.send();
    endmethod
    method Action clear();
        clear_wire.send();
    endmethod
    interface parse_udp = toPut(unparsed_parse_udp_fifo);
endmodule
interface Parser;
    interface Put#(EtherData) frameIn;
endinterface

(* synthesize *)
module mkParser(Parser);

    Reg#(ParserState) curr_state <- mkReg(StateStart);
    Reg#(Bool) started <- mkReg(False);
    FIFOF#(EtherData) data_in_fifo <- mkFIFOF;
    Wire#(Bool) start_fsm <- mkDWire(False);

    Empty init_state <- mkStateStart(curr_state, data_in_fifo, start_fsm);
    ParseEthernet parse_ethernet <- mkStateParseEthernet(curr_state, data_in_fifo);
    ParseArp parse_arp <- mkStateParseArp(curr_state, data_in_fifo);
    ParseIpv4 parse_ipv4 <- mkStateParseIpv4(curr_state, data_in_fifo);
    ParseCpuHeader parse_cpu_header <- mkStateParseCpuHeader(curr_state, data_in_fifo);
    ParseUdp parse_udp <- mkStateParseUdp(curr_state, data_in_fifo);
    ParsePaxos parse_paxos <- mkStateParsePaxos(curr_state, data_in_fifo);
    mkConnection(parse_arp.parse_ethernet, parse_ethernet.parse_arp);
    mkConnection(parse_ipv4.parse_ethernet, parse_ethernet.parse_ipv4);
    mkConnection(parse_cpu_header.parse_ipv4, parse_ipv4.parse_cpu_header);
    mkConnection(parse_udp.parse_ipv4, parse_ipv4.parse_udp);
    mkConnection(parse_paxos.parse_udp, parse_udp.parse_paxos);
    rule start if (start_fsm);
        if (!started) begin
            parse_ethernet.start;
            parse_arp.start;
            parse_ipv4.start;
            parse_cpu_header.start;
            parse_udp.start;
            parse_paxos.start;
            started <= True;
        end
    endrule
    rule clear if (!start_fsm && curr_state == StateStart);
        if (started) begin
            parse_ethernet.clear;
            parse_arp.clear;
            parse_ipv4.clear;
            parse_cpu_header.clear;
            parse_udp.clear;
            parse_paxos.clear;
            started <= False;
        end
    endrule
    interface frameIn = toPut(data_in_fifo);
endmodule
