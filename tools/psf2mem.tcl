#!/usr/bin/tclsh
set filename "lat0-12.psfu"
set f [open $filename rb]
binary scan [read $f 2] H4 magic

if {$magic ne "3604"} {
	exit 1
}

binary scan [read $f 2] H2c* mode charsize

for {set i 0} {$i < 256} {incr i} {
	for {set j 0} {$j < $charsize} {incr j} {
		binary scan [read $f 1] H2 hex
		puts $hex
	}
}
close $f
