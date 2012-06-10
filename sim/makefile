MODULE=terminal
SRCS=testbench.v $(wildcard ../rtl/*.v)

$(MODULE): $(MODULE).vvp
	vvp -n $(MODULE).vvp -lxt2

$(MODULE).vvp: $(SRCS)
	iverilog -DSYS_CLOCK_HZ=100000 -o $@ -I ../rtl $(SRCS)

clean:
	rm -f $(MODULE).vvp *.lxt
