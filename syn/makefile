export LM_LICENSE_FILE=Xilinx.lic

SRCS=$(wildcard ../rtl/*.v)
MODULE=terminal
INTSTYLE=-intstyle silent

BITGENFLAGS=$(INTSTYLE) 
MAPFLAGS=$(INTSTYLE) -p $(PART) -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off 
PARFLAGS=$(INTSTYLE) -w -ol high -mt off 
TRCEFLAGS=$(INTSTYLE) -v 3 -s 3 -n 3 -fastpaths
XSTFLAGS=$(INTSTYLE)

PART_TYPE=xc6slx16
PART_PACKAGE=csg324
PART_SPEED_GRADE=3
PART=$(PART_TYPE)-$(PART_PACKAGE)-$(PART_SPEED_GRADE)

$(MODULE).bit: $(MODULE).ncd $(MODULE).ut
	bitgen $(BITGENFLAGS) -f $(MODULE).ut $(MODULE).ncd

$(MODULE).ngd: $(MODULE).ngc 
	ngdbuild $(INTSTYLE) -dd _ngo -nt timestamp -uc $(MODULE).ucf -p $(PART) $(MODULE).ngc $(MODULE).ngd

$(MODULE).ngc $(MODULE).syr: $(MODULE).xst $(MODULE).prj
	xst $(XSTFLAGS) -ifn $(MODULE).xst -ofn $(MODULE).syr

$(MODULE)_map.ncd $(MODULE).pcf: $(MODULE).ngd
	map $(MAPFLAGS) -o $(MODULE)_map.ncd $(MODULE).ngd $(MODULE).pcf

# place and route
$(MODULE).ncd: $(MODULE)_map.ncd $(MODULE).pcf
	par $(PARFLAGS) $(MODULE)_map.ncd $(MODULE).ncd $(MODULE).pcf

$(MODULE).twr: $(MODULE).pcf $(MODULE).ucf $(MODULE).ncd
	trce $(TRCEFLAGS) $(MODULE).ncd -o $(MODULE).twr $(MODULE).pcf -ucf $(MODULE).ucf

$(MODULE).prj: $(SRCS)
	(for i in ../rtl/*.v; do echo verilog work "\"$$i\""; done) > $(MODULE).prj

prog: $(MODULE).bit
	djtgcfg -d Nexys3 -i 0 -f $(MODULE).bit prog

clean:
	rm -f $(MODULE).bld # NGDBUILD log file
	rm -f $(MODULE)_map.map # Map log file
	rm -f $(MODULE)_map.mrp # Mapping Report File
	rm -f $(MODULE).prj
	rm -f *.par # Place and route
	rm -f *.unroutes
	rm -f *.ngd *.ncd *.log *.twr *.ngc *.bgn *.pcf *.syr *.xrpt *.ngr *.lso *.ngm *.xpi *.pad *.drc *.ptwx *.xwbt
	rm -f *_pad.csv *_pad.txt
	rm -f *_summary.xml *_usage.xml
	rm -f usage_statistics_webtalk.html par_usage_statistics.html
	rm -fr xst _ngo _xmsgs xlnx_auto_0_xdb

.PHONY: prog clean
