#!/usr/bin/perl

use strict;
use warnings;

use constant {
	STATE_SPECIFY => 0,
	STATE_REG_RW  => 1,
};

use constant {
	FLAG_READ => 15,
};

my $state = STATE_SPECIFY;

foreach(<ARGV>) {
	chomp;
	my ($rw, $bytes) = split(/ \| /);
	my @bytes = split(/:/, $bytes);

	if ($state == STATE_SPECIFY) {
		@bytes = map { hex } @bytes;
		if (scalar(@bytes) == 12) {
			my $addr = $bytes[0] | ($bytes[1] << 8);
			my $page = $bytes[2] | ($bytes[3] << 8);
			my $dlen = $bytes[4] | ($bytes[5] << 8);
			my $flag = $bytes[6] | ($bytes[7] << 8);
			printf "%04x/%04x[%04x] %04x ", $addr, $page, $dlen, $flag;
			print(($flag & (1 << FLAG_READ)) ? "R" : "W");
			$state = STATE_REG_RW;
		}
		else {
			print "\t// UNK\n";
		}
	}
	elsif ($state == STATE_REG_RW) {
		print " " . join(':', reverse(@bytes)) . "\n";
		$state = STATE_SPECIFY;
	}
}
