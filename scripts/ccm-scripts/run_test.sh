#!/bin/bash

echo "Doing full reset"
flx-reset ALL; flx-init; flx-reset GTH; flx-info LINK
echo "enabling single readout link 0:"
sleep 1
flx-config -d 0 set DECODING_LINK00_EGROUP0_CTRL_EPATH_ENA=1
sleep 1
echo "loading pattern: FixedHits_A_emuconfig"
sleep 1
flx-config -d 0 load dtp-patterns/EMUInput/FixedHits_A_emuconfig
sleep 1

echo "Runnning flxlibs_test_tp_elinkhandler"
flxlibs_test_tp_elinkhandler > test_result.log &

echo "Run hit finding:"
hfButler.py flx-0-p2-hf init
hfButler.py flx-0-p2-hf cr-if --on --drop-empty
hfButler.py flx-0-p2-hf flowmaster --src-sel gbt --sink-sel hits
hfButler.py flx-0-p2-hf link hitfinder -t 20
hfButler.py flx-0-p2-hf link mask enable -c 1-63
hfButler.py flx-0-p2-hf link config --dr-on --dpr-mux passthrough --drop-empty

sleep 4
echo "Enabling readout link on SLR 0:"
femu -d 0 -e

wait
echo "Test complete, output file: test_result.log"
echo "quick summary: "
tail -n 4 test_result.log