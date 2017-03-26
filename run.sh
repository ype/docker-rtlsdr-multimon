#!/usr/bin/env bash

export OUTDIR=/var/www/pager
export FREQ="153.35M"
export DATETIMESTAMP="$(date '+%F_%H%M%S')"

rtl_fm -f "$FREQ" -s 22050 2>/var/www/pager/"$DATETIMESTAMP"_rtl_fm-multimon_stderr.log \
    | multimon-ng -t raw \
		  -a POCSAG512 -a POCSAG1200 -a POCSAG2400 -a FLEX \
		  -a DUMPCSV -f alpha /dev/stdin \
	          1>>"$OUTDIR/$DATETIMESTAMP"_POCSAG-512_1200_2400-FLEX_"$FREQ".csv \
		  1>>"$OUTDIR"/latest.csv \
		  2>>"$OUTDIR"/"$DATETIMESTAMP"_rtl_fm-multimon_stderr.log &

/etc/init.d/lighttpd restart
