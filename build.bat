sjasmplus.exe ./src/main.asm --lst=l2scroller.lst --sym=l2scroller.sym --zxnext=cspect

Z:/zxenv/emulator/cspect -r -w3 -brk -zxnext -rewind -nextrom -map=l2scroller.map l2scroller.nex

copy l2scroller.nex h:\