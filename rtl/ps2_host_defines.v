/* ps2_host_defines.v */
 
`ifndef SYS_CLOCK_HZ
`define SYS_CLOCK_HZ 100_000_000
`endif
 
`define T_100_MICROSECONDS (`SYS_CLOCK_HZ / 10_000)
`define T_200_MICROSECONDS (`SYS_CLOCK_HZ /  5_000)
`define T_100_MICROSECONDS_SIZE 14
`define T_200_MICROSECONDS_SIZE 15