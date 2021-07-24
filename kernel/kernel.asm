
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	17c78793          	addi	a5,a5,380 # 800061e0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dbe78793          	addi	a5,a5,-578 # 80000e6c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	7fe080e7          	jalr	2046(ra) # 8000291c <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77a080e7          	jalr	1914(ra) # 800008a8 <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8aaa                	mv	s5,a0
    80000174:	8a2e                	mv	s4,a1
    80000176:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a3e080e7          	jalr	-1474(ra) # 80000bc2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000194:	00011917          	auipc	s2,0x11
    80000198:	08490913          	addi	s2,s2,132 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019c:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000019e:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a0:	4ca9                	li	s9,10
  while(n > 0){
    800001a2:	07305863          	blez	s3,80000212 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71463          	bne	a4,a5,800001d6 <consoleread+0x80>
      if(myproc()->killed){
    800001b2:	00001097          	auipc	ra,0x1
    800001b6:	7e4080e7          	jalr	2020(ra) # 80001996 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	e7b5                	bnez	a5,80000228 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001be:	85a6                	mv	a1,s1
    800001c0:	854a                	mv	a0,s2
    800001c2:	00002097          	auipc	ra,0x2
    800001c6:	08c080e7          	jalr	140(ra) # 8000224e <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef700e3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d6:	0017871b          	addiw	a4,a5,1
    800001da:	08e4ac23          	sw	a4,152(s1)
    800001de:	07f7f713          	andi	a4,a5,127
    800001e2:	9726                	add	a4,a4,s1
    800001e4:	01874703          	lbu	a4,24(a4)
    800001e8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ec:	077d0563          	beq	s10,s7,80000256 <consoleread+0x100>
    cbuf = c;
    800001f0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f4:	4685                	li	a3,1
    800001f6:	f9f40613          	addi	a2,s0,-97
    800001fa:	85d2                	mv	a1,s4
    800001fc:	8556                	mv	a0,s5
    800001fe:	00002097          	auipc	ra,0x2
    80000202:	6c8080e7          	jalr	1736(ra) # 800028c6 <either_copyout>
    80000206:	01850663          	beq	a0,s8,80000212 <consoleread+0xbc>
    dst++;
    8000020a:	0a05                	addi	s4,s4,1
    --n;
    8000020c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000020e:	f99d1ae3          	bne	s10,s9,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000212:	00011517          	auipc	a0,0x11
    80000216:	f6e50513          	addi	a0,a0,-146 # 80011180 <cons>
    8000021a:	00001097          	auipc	ra,0x1
    8000021e:	a5c080e7          	jalr	-1444(ra) # 80000c76 <release>

  return target - n;
    80000222:	413b053b          	subw	a0,s6,s3
    80000226:	a811                	j	8000023a <consoleread+0xe4>
        release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	f5850513          	addi	a0,a0,-168 # 80011180 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a46080e7          	jalr	-1466(ra) # 80000c76 <release>
        return -1;
    80000238:	557d                	li	a0,-1
}
    8000023a:	70a6                	ld	ra,104(sp)
    8000023c:	7406                	ld	s0,96(sp)
    8000023e:	64e6                	ld	s1,88(sp)
    80000240:	6946                	ld	s2,80(sp)
    80000242:	69a6                	ld	s3,72(sp)
    80000244:	6a06                	ld	s4,64(sp)
    80000246:	7ae2                	ld	s5,56(sp)
    80000248:	7b42                	ld	s6,48(sp)
    8000024a:	7ba2                	ld	s7,40(sp)
    8000024c:	7c02                	ld	s8,32(sp)
    8000024e:	6ce2                	ld	s9,24(sp)
    80000250:	6d42                	ld	s10,16(sp)
    80000252:	6165                	addi	sp,sp,112
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	fb677ce3          	bgeu	a4,s6,80000212 <consoleread+0xbc>
        cons.r--;
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	b775                	j	80000212 <consoleread+0xbc>

0000000080000268 <consputc>:
{
    80000268:	1141                	addi	sp,sp,-16
    8000026a:	e406                	sd	ra,8(sp)
    8000026c:	e022                	sd	s0,0(sp)
    8000026e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000270:	10000793          	li	a5,256
    80000274:	00f50a63          	beq	a0,a5,80000288 <consputc+0x20>
    uartputc_sync(c);
    80000278:	00000097          	auipc	ra,0x0
    8000027c:	55e080e7          	jalr	1374(ra) # 800007d6 <uartputc_sync>
}
    80000280:	60a2                	ld	ra,8(sp)
    80000282:	6402                	ld	s0,0(sp)
    80000284:	0141                	addi	sp,sp,16
    80000286:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000288:	4521                	li	a0,8
    8000028a:	00000097          	auipc	ra,0x0
    8000028e:	54c080e7          	jalr	1356(ra) # 800007d6 <uartputc_sync>
    80000292:	02000513          	li	a0,32
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	540080e7          	jalr	1344(ra) # 800007d6 <uartputc_sync>
    8000029e:	4521                	li	a0,8
    800002a0:	00000097          	auipc	ra,0x0
    800002a4:	536080e7          	jalr	1334(ra) # 800007d6 <uartputc_sync>
    800002a8:	bfe1                	j	80000280 <consputc+0x18>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	e04a                	sd	s2,0(sp)
    800002b4:	1000                	addi	s0,sp,32
    800002b6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b8:	00011517          	auipc	a0,0x11
    800002bc:	ec850513          	addi	a0,a0,-312 # 80011180 <cons>
    800002c0:	00001097          	auipc	ra,0x1
    800002c4:	902080e7          	jalr	-1790(ra) # 80000bc2 <acquire>

  switch(c){
    800002c8:	47d5                	li	a5,21
    800002ca:	0af48663          	beq	s1,a5,80000376 <consoleintr+0xcc>
    800002ce:	0297ca63          	blt	a5,s1,80000302 <consoleintr+0x58>
    800002d2:	47a1                	li	a5,8
    800002d4:	0ef48763          	beq	s1,a5,800003c2 <consoleintr+0x118>
    800002d8:	47c1                	li	a5,16
    800002da:	10f49a63          	bne	s1,a5,800003ee <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002de:	00002097          	auipc	ra,0x2
    800002e2:	694080e7          	jalr	1684(ra) # 80002972 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002e6:	00011517          	auipc	a0,0x11
    800002ea:	e9a50513          	addi	a0,a0,-358 # 80011180 <cons>
    800002ee:	00001097          	auipc	ra,0x1
    800002f2:	988080e7          	jalr	-1656(ra) # 80000c76 <release>
}
    800002f6:	60e2                	ld	ra,24(sp)
    800002f8:	6442                	ld	s0,16(sp)
    800002fa:	64a2                	ld	s1,8(sp)
    800002fc:	6902                	ld	s2,0(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch(c){
    80000302:	07f00793          	li	a5,127
    80000306:	0af48e63          	beq	s1,a5,800003c2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	e7670713          	addi	a4,a4,-394 # 80011180 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf763e3          	bltu	a4,a5,800002e6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x14a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f3c080e7          	jalr	-196(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000334:	00011797          	auipc	a5,0x11
    80000338:	e4c78793          	addi	a5,a5,-436 # 80011180 <cons>
    8000033c:	0a07a703          	lw	a4,160(a5)
    80000340:	0017069b          	addiw	a3,a4,1
    80000344:	0006861b          	sext.w	a2,a3
    80000348:	0ad7a023          	sw	a3,160(a5)
    8000034c:	07f77713          	andi	a4,a4,127
    80000350:	97ba                	add	a5,a5,a4
    80000352:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000356:	47a9                	li	a5,10
    80000358:	0cf48563          	beq	s1,a5,80000422 <consoleintr+0x178>
    8000035c:	4791                	li	a5,4
    8000035e:	0cf48263          	beq	s1,a5,80000422 <consoleintr+0x178>
    80000362:	00011797          	auipc	a5,0x11
    80000366:	eb67a783          	lw	a5,-330(a5) # 80011218 <cons+0x98>
    8000036a:	0807879b          	addiw	a5,a5,128
    8000036e:	f6f61ce3          	bne	a2,a5,800002e6 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000372:	863e                	mv	a2,a5
    80000374:	a07d                	j	80000422 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000376:	00011717          	auipc	a4,0x11
    8000037a:	e0a70713          	addi	a4,a4,-502 # 80011180 <cons>
    8000037e:	0a072783          	lw	a5,160(a4)
    80000382:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000386:	00011497          	auipc	s1,0x11
    8000038a:	dfa48493          	addi	s1,s1,-518 # 80011180 <cons>
    while(cons.e != cons.w &&
    8000038e:	4929                	li	s2,10
    80000390:	f4f70be3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	37fd                	addiw	a5,a5,-1
    80000396:	07f7f713          	andi	a4,a5,127
    8000039a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000039c:	01874703          	lbu	a4,24(a4)
    800003a0:	f52703e3          	beq	a4,s2,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003a4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a8:	10000513          	li	a0,256
    800003ac:	00000097          	auipc	ra,0x0
    800003b0:	ebc080e7          	jalr	-324(ra) # 80000268 <consputc>
    while(cons.e != cons.w &&
    800003b4:	0a04a783          	lw	a5,160(s1)
    800003b8:	09c4a703          	lw	a4,156(s1)
    800003bc:	fcf71ce3          	bne	a4,a5,80000394 <consoleintr+0xea>
    800003c0:	b71d                	j	800002e6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c2:	00011717          	auipc	a4,0x11
    800003c6:	dbe70713          	addi	a4,a4,-578 # 80011180 <cons>
    800003ca:	0a072783          	lw	a5,160(a4)
    800003ce:	09c72703          	lw	a4,156(a4)
    800003d2:	f0f70ae3          	beq	a4,a5,800002e6 <consoleintr+0x3c>
      cons.e--;
    800003d6:	37fd                	addiw	a5,a5,-1
    800003d8:	00011717          	auipc	a4,0x11
    800003dc:	e4f72423          	sw	a5,-440(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e0:	10000513          	li	a0,256
    800003e4:	00000097          	auipc	ra,0x0
    800003e8:	e84080e7          	jalr	-380(ra) # 80000268 <consputc>
    800003ec:	bded                	j	800002e6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003ee:	ee048ce3          	beqz	s1,800002e6 <consoleintr+0x3c>
    800003f2:	bf21                	j	8000030a <consoleintr+0x60>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	e72080e7          	jalr	-398(ra) # 80000268 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    800003fe:	00011797          	auipc	a5,0x11
    80000402:	d8278793          	addi	a5,a5,-638 # 80011180 <cons>
    80000406:	0a07a703          	lw	a4,160(a5)
    8000040a:	0017069b          	addiw	a3,a4,1
    8000040e:	0006861b          	sext.w	a2,a3
    80000412:	0ad7a023          	sw	a3,160(a5)
    80000416:	07f77713          	andi	a4,a4,127
    8000041a:	97ba                	add	a5,a5,a4
    8000041c:	4729                	li	a4,10
    8000041e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000422:	00011797          	auipc	a5,0x11
    80000426:	dec7ad23          	sw	a2,-518(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042a:	00011517          	auipc	a0,0x11
    8000042e:	dee50513          	addi	a0,a0,-530 # 80011218 <cons+0x98>
    80000432:	00002097          	auipc	ra,0x2
    80000436:	fa8080e7          	jalr	-88(ra) # 800023da <wakeup>
    8000043a:	b575                	j	800002e6 <consoleintr+0x3c>

000000008000043c <consoleinit>:

void
consoleinit(void)
{
    8000043c:	1141                	addi	sp,sp,-16
    8000043e:	e406                	sd	ra,8(sp)
    80000440:	e022                	sd	s0,0(sp)
    80000442:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000444:	00008597          	auipc	a1,0x8
    80000448:	bcc58593          	addi	a1,a1,-1076 # 80008010 <etext+0x10>
    8000044c:	00011517          	auipc	a0,0x11
    80000450:	d3450513          	addi	a0,a0,-716 # 80011180 <cons>
    80000454:	00000097          	auipc	ra,0x0
    80000458:	6de080e7          	jalr	1758(ra) # 80000b32 <initlock>

  uartinit();
    8000045c:	00000097          	auipc	ra,0x0
    80000460:	32a080e7          	jalr	810(ra) # 80000786 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000464:	00022797          	auipc	a5,0x22
    80000468:	8cc78793          	addi	a5,a5,-1844 # 80021d30 <devsw>
    8000046c:	00000717          	auipc	a4,0x0
    80000470:	cea70713          	addi	a4,a4,-790 # 80000156 <consoleread>
    80000474:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000476:	00000717          	auipc	a4,0x0
    8000047a:	c7e70713          	addi	a4,a4,-898 # 800000f4 <consolewrite>
    8000047e:	ef98                	sd	a4,24(a5)
}
    80000480:	60a2                	ld	ra,8(sp)
    80000482:	6402                	ld	s0,0(sp)
    80000484:	0141                	addi	sp,sp,16
    80000486:	8082                	ret

0000000080000488 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000488:	7179                	addi	sp,sp,-48
    8000048a:	f406                	sd	ra,40(sp)
    8000048c:	f022                	sd	s0,32(sp)
    8000048e:	ec26                	sd	s1,24(sp)
    80000490:	e84a                	sd	s2,16(sp)
    80000492:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000494:	c219                	beqz	a2,8000049a <printint+0x12>
    80000496:	08054663          	bltz	a0,80000522 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049a:	2501                	sext.w	a0,a0
    8000049c:	4881                	li	a7,0
    8000049e:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a4:	2581                	sext.w	a1,a1
    800004a6:	00008617          	auipc	a2,0x8
    800004aa:	b9a60613          	addi	a2,a2,-1126 # 80008040 <digits>
    800004ae:	883a                	mv	a6,a4
    800004b0:	2705                	addiw	a4,a4,1
    800004b2:	02b577bb          	remuw	a5,a0,a1
    800004b6:	1782                	slli	a5,a5,0x20
    800004b8:	9381                	srli	a5,a5,0x20
    800004ba:	97b2                	add	a5,a5,a2
    800004bc:	0007c783          	lbu	a5,0(a5)
    800004c0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c4:	0005079b          	sext.w	a5,a0
    800004c8:	02b5553b          	divuw	a0,a0,a1
    800004cc:	0685                	addi	a3,a3,1
    800004ce:	feb7f0e3          	bgeu	a5,a1,800004ae <printint+0x26>

  if(sign)
    800004d2:	00088b63          	beqz	a7,800004e8 <printint+0x60>
    buf[i++] = '-';
    800004d6:	fe040793          	addi	a5,s0,-32
    800004da:	973e                	add	a4,a4,a5
    800004dc:	02d00793          	li	a5,45
    800004e0:	fef70823          	sb	a5,-16(a4)
    800004e4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004e8:	02e05763          	blez	a4,80000516 <printint+0x8e>
    800004ec:	fd040793          	addi	a5,s0,-48
    800004f0:	00e784b3          	add	s1,a5,a4
    800004f4:	fff78913          	addi	s2,a5,-1
    800004f8:	993a                	add	s2,s2,a4
    800004fa:	377d                	addiw	a4,a4,-1
    800004fc:	1702                	slli	a4,a4,0x20
    800004fe:	9301                	srli	a4,a4,0x20
    80000500:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000504:	fff4c503          	lbu	a0,-1(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d60080e7          	jalr	-672(ra) # 80000268 <consputc>
  while(--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x7c>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
    x = -xx;
    80000522:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000526:	4885                	li	a7,1
    x = -xx;
    80000528:	bf9d                	j	8000049e <printint+0x16>

000000008000052a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052a:	1101                	addi	sp,sp,-32
    8000052c:	ec06                	sd	ra,24(sp)
    8000052e:	e822                	sd	s0,16(sp)
    80000530:	e426                	sd	s1,8(sp)
    80000532:	1000                	addi	s0,sp,32
    80000534:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000536:	00011797          	auipc	a5,0x11
    8000053a:	d007a523          	sw	zero,-758(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000053e:	00008517          	auipc	a0,0x8
    80000542:	ada50513          	addi	a0,a0,-1318 # 80008018 <etext+0x18>
    80000546:	00000097          	auipc	ra,0x0
    8000054a:	02e080e7          	jalr	46(ra) # 80000574 <printf>
  printf(s);
    8000054e:	8526                	mv	a0,s1
    80000550:	00000097          	auipc	ra,0x0
    80000554:	024080e7          	jalr	36(ra) # 80000574 <printf>
  printf("\n");
    80000558:	00008517          	auipc	a0,0x8
    8000055c:	b7050513          	addi	a0,a0,-1168 # 800080c8 <digits+0x88>
    80000560:	00000097          	auipc	ra,0x0
    80000564:	014080e7          	jalr	20(ra) # 80000574 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000568:	4785                	li	a5,1
    8000056a:	00009717          	auipc	a4,0x9
    8000056e:	a8f72b23          	sw	a5,-1386(a4) # 80009000 <panicked>
  for(;;)
    80000572:	a001                	j	80000572 <panic+0x48>

0000000080000574 <printf>:
{
    80000574:	7131                	addi	sp,sp,-192
    80000576:	fc86                	sd	ra,120(sp)
    80000578:	f8a2                	sd	s0,112(sp)
    8000057a:	f4a6                	sd	s1,104(sp)
    8000057c:	f0ca                	sd	s2,96(sp)
    8000057e:	ecce                	sd	s3,88(sp)
    80000580:	e8d2                	sd	s4,80(sp)
    80000582:	e4d6                	sd	s5,72(sp)
    80000584:	e0da                	sd	s6,64(sp)
    80000586:	fc5e                	sd	s7,56(sp)
    80000588:	f862                	sd	s8,48(sp)
    8000058a:	f466                	sd	s9,40(sp)
    8000058c:	f06a                	sd	s10,32(sp)
    8000058e:	ec6e                	sd	s11,24(sp)
    80000590:	0100                	addi	s0,sp,128
    80000592:	8a2a                	mv	s4,a0
    80000594:	e40c                	sd	a1,8(s0)
    80000596:	e810                	sd	a2,16(s0)
    80000598:	ec14                	sd	a3,24(s0)
    8000059a:	f018                	sd	a4,32(s0)
    8000059c:	f41c                	sd	a5,40(s0)
    8000059e:	03043823          	sd	a6,48(s0)
    800005a2:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005a6:	00011d97          	auipc	s11,0x11
    800005aa:	c9adad83          	lw	s11,-870(s11) # 80011240 <pr+0x18>
  if(locking)
    800005ae:	020d9b63          	bnez	s11,800005e4 <printf+0x70>
  if (fmt == 0)
    800005b2:	040a0263          	beqz	s4,800005f6 <printf+0x82>
  va_start(ap, fmt);
    800005b6:	00840793          	addi	a5,s0,8
    800005ba:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005be:	000a4503          	lbu	a0,0(s4)
    800005c2:	14050f63          	beqz	a0,80000720 <printf+0x1ac>
    800005c6:	4981                	li	s3,0
    if(c != '%'){
    800005c8:	02500a93          	li	s5,37
    switch(c){
    800005cc:	07000b93          	li	s7,112
  consputc('x');
    800005d0:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d2:	00008b17          	auipc	s6,0x8
    800005d6:	a6eb0b13          	addi	s6,s6,-1426 # 80008040 <digits>
    switch(c){
    800005da:	07300c93          	li	s9,115
    800005de:	06400c13          	li	s8,100
    800005e2:	a82d                	j	8000061c <printf+0xa8>
    acquire(&pr.lock);
    800005e4:	00011517          	auipc	a0,0x11
    800005e8:	c4450513          	addi	a0,a0,-956 # 80011228 <pr>
    800005ec:	00000097          	auipc	ra,0x0
    800005f0:	5d6080e7          	jalr	1494(ra) # 80000bc2 <acquire>
    800005f4:	bf7d                	j	800005b2 <printf+0x3e>
    panic("null fmt");
    800005f6:	00008517          	auipc	a0,0x8
    800005fa:	a3250513          	addi	a0,a0,-1486 # 80008028 <etext+0x28>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	f2c080e7          	jalr	-212(ra) # 8000052a <panic>
      consputc(c);
    80000606:	00000097          	auipc	ra,0x0
    8000060a:	c62080e7          	jalr	-926(ra) # 80000268 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000060e:	2985                	addiw	s3,s3,1
    80000610:	013a07b3          	add	a5,s4,s3
    80000614:	0007c503          	lbu	a0,0(a5)
    80000618:	10050463          	beqz	a0,80000720 <printf+0x1ac>
    if(c != '%'){
    8000061c:	ff5515e3          	bne	a0,s5,80000606 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c783          	lbu	a5,0(a5)
    8000062a:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000062e:	cbed                	beqz	a5,80000720 <printf+0x1ac>
    switch(c){
    80000630:	05778a63          	beq	a5,s7,80000684 <printf+0x110>
    80000634:	02fbf663          	bgeu	s7,a5,80000660 <printf+0xec>
    80000638:	09978863          	beq	a5,s9,800006c8 <printf+0x154>
    8000063c:	07800713          	li	a4,120
    80000640:	0ce79563          	bne	a5,a4,8000070a <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	85ea                	mv	a1,s10
    80000654:	4388                	lw	a0,0(a5)
    80000656:	00000097          	auipc	ra,0x0
    8000065a:	e32080e7          	jalr	-462(ra) # 80000488 <printint>
      break;
    8000065e:	bf45                	j	8000060e <printf+0x9a>
    switch(c){
    80000660:	09578f63          	beq	a5,s5,800006fe <printf+0x18a>
    80000664:	0b879363          	bne	a5,s8,8000070a <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000668:	f8843783          	ld	a5,-120(s0)
    8000066c:	00878713          	addi	a4,a5,8
    80000670:	f8e43423          	sd	a4,-120(s0)
    80000674:	4605                	li	a2,1
    80000676:	45a9                	li	a1,10
    80000678:	4388                	lw	a0,0(a5)
    8000067a:	00000097          	auipc	ra,0x0
    8000067e:	e0e080e7          	jalr	-498(ra) # 80000488 <printint>
      break;
    80000682:	b771                	j	8000060e <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000694:	03000513          	li	a0,48
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	bd0080e7          	jalr	-1072(ra) # 80000268 <consputc>
  consputc('x');
    800006a0:	07800513          	li	a0,120
    800006a4:	00000097          	auipc	ra,0x0
    800006a8:	bc4080e7          	jalr	-1084(ra) # 80000268 <consputc>
    800006ac:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ae:	03c95793          	srli	a5,s2,0x3c
    800006b2:	97da                	add	a5,a5,s6
    800006b4:	0007c503          	lbu	a0,0(a5)
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bb0080e7          	jalr	-1104(ra) # 80000268 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c0:	0912                	slli	s2,s2,0x4
    800006c2:	34fd                	addiw	s1,s1,-1
    800006c4:	f4ed                	bnez	s1,800006ae <printf+0x13a>
    800006c6:	b7a1                	j	8000060e <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	6384                	ld	s1,0(a5)
    800006d6:	cc89                	beqz	s1,800006f0 <printf+0x17c>
      for(; *s; s++)
    800006d8:	0004c503          	lbu	a0,0(s1)
    800006dc:	d90d                	beqz	a0,8000060e <printf+0x9a>
        consputc(*s);
    800006de:	00000097          	auipc	ra,0x0
    800006e2:	b8a080e7          	jalr	-1142(ra) # 80000268 <consputc>
      for(; *s; s++)
    800006e6:	0485                	addi	s1,s1,1
    800006e8:	0004c503          	lbu	a0,0(s1)
    800006ec:	f96d                	bnez	a0,800006de <printf+0x16a>
    800006ee:	b705                	j	8000060e <printf+0x9a>
        s = "(null)";
    800006f0:	00008497          	auipc	s1,0x8
    800006f4:	93048493          	addi	s1,s1,-1744 # 80008020 <etext+0x20>
      for(; *s; s++)
    800006f8:	02800513          	li	a0,40
    800006fc:	b7cd                	j	800006de <printf+0x16a>
      consputc('%');
    800006fe:	8556                	mv	a0,s5
    80000700:	00000097          	auipc	ra,0x0
    80000704:	b68080e7          	jalr	-1176(ra) # 80000268 <consputc>
      break;
    80000708:	b719                	j	8000060e <printf+0x9a>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b5c080e7          	jalr	-1188(ra) # 80000268 <consputc>
      consputc(c);
    80000714:	8526                	mv	a0,s1
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b52080e7          	jalr	-1198(ra) # 80000268 <consputc>
      break;
    8000071e:	bdc5                	j	8000060e <printf+0x9a>
  if(locking)
    80000720:	020d9163          	bnez	s11,80000742 <printf+0x1ce>
}
    80000724:	70e6                	ld	ra,120(sp)
    80000726:	7446                	ld	s0,112(sp)
    80000728:	74a6                	ld	s1,104(sp)
    8000072a:	7906                	ld	s2,96(sp)
    8000072c:	69e6                	ld	s3,88(sp)
    8000072e:	6a46                	ld	s4,80(sp)
    80000730:	6aa6                	ld	s5,72(sp)
    80000732:	6b06                	ld	s6,64(sp)
    80000734:	7be2                	ld	s7,56(sp)
    80000736:	7c42                	ld	s8,48(sp)
    80000738:	7ca2                	ld	s9,40(sp)
    8000073a:	7d02                	ld	s10,32(sp)
    8000073c:	6de2                	ld	s11,24(sp)
    8000073e:	6129                	addi	sp,sp,192
    80000740:	8082                	ret
    release(&pr.lock);
    80000742:	00011517          	auipc	a0,0x11
    80000746:	ae650513          	addi	a0,a0,-1306 # 80011228 <pr>
    8000074a:	00000097          	auipc	ra,0x0
    8000074e:	52c080e7          	jalr	1324(ra) # 80000c76 <release>
}
    80000752:	bfc9                	j	80000724 <printf+0x1b0>

0000000080000754 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000754:	1101                	addi	sp,sp,-32
    80000756:	ec06                	sd	ra,24(sp)
    80000758:	e822                	sd	s0,16(sp)
    8000075a:	e426                	sd	s1,8(sp)
    8000075c:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000075e:	00011497          	auipc	s1,0x11
    80000762:	aca48493          	addi	s1,s1,-1334 # 80011228 <pr>
    80000766:	00008597          	auipc	a1,0x8
    8000076a:	8d258593          	addi	a1,a1,-1838 # 80008038 <etext+0x38>
    8000076e:	8526                	mv	a0,s1
    80000770:	00000097          	auipc	ra,0x0
    80000774:	3c2080e7          	jalr	962(ra) # 80000b32 <initlock>
  pr.locking = 1;
    80000778:	4785                	li	a5,1
    8000077a:	cc9c                	sw	a5,24(s1)
}
    8000077c:	60e2                	ld	ra,24(sp)
    8000077e:	6442                	ld	s0,16(sp)
    80000780:	64a2                	ld	s1,8(sp)
    80000782:	6105                	addi	sp,sp,32
    80000784:	8082                	ret

0000000080000786 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000786:	1141                	addi	sp,sp,-16
    80000788:	e406                	sd	ra,8(sp)
    8000078a:	e022                	sd	s0,0(sp)
    8000078c:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000078e:	100007b7          	lui	a5,0x10000
    80000792:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000796:	f8000713          	li	a4,-128
    8000079a:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000079e:	470d                	li	a4,3
    800007a0:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a4:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007a8:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ac:	469d                	li	a3,7
    800007ae:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b2:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007b6:	00008597          	auipc	a1,0x8
    800007ba:	8a258593          	addi	a1,a1,-1886 # 80008058 <digits+0x18>
    800007be:	00011517          	auipc	a0,0x11
    800007c2:	a8a50513          	addi	a0,a0,-1398 # 80011248 <uart_tx_lock>
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	36c080e7          	jalr	876(ra) # 80000b32 <initlock>
}
    800007ce:	60a2                	ld	ra,8(sp)
    800007d0:	6402                	ld	s0,0(sp)
    800007d2:	0141                	addi	sp,sp,16
    800007d4:	8082                	ret

00000000800007d6 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007d6:	1101                	addi	sp,sp,-32
    800007d8:	ec06                	sd	ra,24(sp)
    800007da:	e822                	sd	s0,16(sp)
    800007dc:	e426                	sd	s1,8(sp)
    800007de:	1000                	addi	s0,sp,32
    800007e0:	84aa                	mv	s1,a0
  push_off();
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	394080e7          	jalr	916(ra) # 80000b76 <push_off>

  if(panicked){
    800007ea:	00009797          	auipc	a5,0x9
    800007ee:	8167a783          	lw	a5,-2026(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f2:	10000737          	lui	a4,0x10000
  if(panicked){
    800007f6:	c391                	beqz	a5,800007fa <uartputc_sync+0x24>
    for(;;)
    800007f8:	a001                	j	800007f8 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fa:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007fe:	0207f793          	andi	a5,a5,32
    80000802:	dfe5                	beqz	a5,800007fa <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000804:	0ff4f513          	andi	a0,s1,255
    80000808:	100007b7          	lui	a5,0x10000
    8000080c:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000810:	00000097          	auipc	ra,0x0
    80000814:	406080e7          	jalr	1030(ra) # 80000c16 <pop_off>
}
    80000818:	60e2                	ld	ra,24(sp)
    8000081a:	6442                	ld	s0,16(sp)
    8000081c:	64a2                	ld	s1,8(sp)
    8000081e:	6105                	addi	sp,sp,32
    80000820:	8082                	ret

0000000080000822 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000822:	00008797          	auipc	a5,0x8
    80000826:	7e67b783          	ld	a5,2022(a5) # 80009008 <uart_tx_r>
    8000082a:	00008717          	auipc	a4,0x8
    8000082e:	7e673703          	ld	a4,2022(a4) # 80009010 <uart_tx_w>
    80000832:	06f70a63          	beq	a4,a5,800008a6 <uartstart+0x84>
{
    80000836:	7139                	addi	sp,sp,-64
    80000838:	fc06                	sd	ra,56(sp)
    8000083a:	f822                	sd	s0,48(sp)
    8000083c:	f426                	sd	s1,40(sp)
    8000083e:	f04a                	sd	s2,32(sp)
    80000840:	ec4e                	sd	s3,24(sp)
    80000842:	e852                	sd	s4,16(sp)
    80000844:	e456                	sd	s5,8(sp)
    80000846:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000848:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000084c:	00011a17          	auipc	s4,0x11
    80000850:	9fca0a13          	addi	s4,s4,-1540 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000854:	00008497          	auipc	s1,0x8
    80000858:	7b448493          	addi	s1,s1,1972 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000085c:	00008997          	auipc	s3,0x8
    80000860:	7b498993          	addi	s3,s3,1972 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000868:	02077713          	andi	a4,a4,32
    8000086c:	c705                	beqz	a4,80000894 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000086e:	01f7f713          	andi	a4,a5,31
    80000872:	9752                	add	a4,a4,s4
    80000874:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000878:	0785                	addi	a5,a5,1
    8000087a:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000087c:	8526                	mv	a0,s1
    8000087e:	00002097          	auipc	ra,0x2
    80000882:	b5c080e7          	jalr	-1188(ra) # 800023da <wakeup>
    
    WriteReg(THR, c);
    80000886:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088a:	609c                	ld	a5,0(s1)
    8000088c:	0009b703          	ld	a4,0(s3)
    80000890:	fcf71ae3          	bne	a4,a5,80000864 <uartstart+0x42>
  }
}
    80000894:	70e2                	ld	ra,56(sp)
    80000896:	7442                	ld	s0,48(sp)
    80000898:	74a2                	ld	s1,40(sp)
    8000089a:	7902                	ld	s2,32(sp)
    8000089c:	69e2                	ld	s3,24(sp)
    8000089e:	6a42                	ld	s4,16(sp)
    800008a0:	6aa2                	ld	s5,8(sp)
    800008a2:	6121                	addi	sp,sp,64
    800008a4:	8082                	ret
    800008a6:	8082                	ret

00000000800008a8 <uartputc>:
{
    800008a8:	7179                	addi	sp,sp,-48
    800008aa:	f406                	sd	ra,40(sp)
    800008ac:	f022                	sd	s0,32(sp)
    800008ae:	ec26                	sd	s1,24(sp)
    800008b0:	e84a                	sd	s2,16(sp)
    800008b2:	e44e                	sd	s3,8(sp)
    800008b4:	e052                	sd	s4,0(sp)
    800008b6:	1800                	addi	s0,sp,48
    800008b8:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ba:	00011517          	auipc	a0,0x11
    800008be:	98e50513          	addi	a0,a0,-1650 # 80011248 <uart_tx_lock>
    800008c2:	00000097          	auipc	ra,0x0
    800008c6:	300080e7          	jalr	768(ra) # 80000bc2 <acquire>
  if(panicked){
    800008ca:	00008797          	auipc	a5,0x8
    800008ce:	7367a783          	lw	a5,1846(a5) # 80009000 <panicked>
    800008d2:	c391                	beqz	a5,800008d6 <uartputc+0x2e>
    for(;;)
    800008d4:	a001                	j	800008d4 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008d6:	00008717          	auipc	a4,0x8
    800008da:	73a73703          	ld	a4,1850(a4) # 80009010 <uart_tx_w>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	72a7b783          	ld	a5,1834(a5) # 80009008 <uart_tx_r>
    800008e6:	02078793          	addi	a5,a5,32
    800008ea:	02e79b63          	bne	a5,a4,80000920 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008ee:	00011997          	auipc	s3,0x11
    800008f2:	95a98993          	addi	s3,s3,-1702 # 80011248 <uart_tx_lock>
    800008f6:	00008497          	auipc	s1,0x8
    800008fa:	71248493          	addi	s1,s1,1810 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fe:	00008917          	auipc	s2,0x8
    80000902:	71290913          	addi	s2,s2,1810 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	85ce                	mv	a1,s3
    80000908:	8526                	mv	a0,s1
    8000090a:	00002097          	auipc	ra,0x2
    8000090e:	944080e7          	jalr	-1724(ra) # 8000224e <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00093703          	ld	a4,0(s2)
    80000916:	609c                	ld	a5,0(s1)
    80000918:	02078793          	addi	a5,a5,32
    8000091c:	fee785e3          	beq	a5,a4,80000906 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000920:	00011497          	auipc	s1,0x11
    80000924:	92848493          	addi	s1,s1,-1752 # 80011248 <uart_tx_lock>
    80000928:	01f77793          	andi	a5,a4,31
    8000092c:	97a6                	add	a5,a5,s1
    8000092e:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000932:	0705                	addi	a4,a4,1
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6ce7be23          	sd	a4,1756(a5) # 80009010 <uart_tx_w>
      uartstart();
    8000093c:	00000097          	auipc	ra,0x0
    80000940:	ee6080e7          	jalr	-282(ra) # 80000822 <uartstart>
      release(&uart_tx_lock);
    80000944:	8526                	mv	a0,s1
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	330080e7          	jalr	816(ra) # 80000c76 <release>
}
    8000094e:	70a2                	ld	ra,40(sp)
    80000950:	7402                	ld	s0,32(sp)
    80000952:	64e2                	ld	s1,24(sp)
    80000954:	6942                	ld	s2,16(sp)
    80000956:	69a2                	ld	s3,8(sp)
    80000958:	6a02                	ld	s4,0(sp)
    8000095a:	6145                	addi	sp,sp,48
    8000095c:	8082                	ret

000000008000095e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000095e:	1141                	addi	sp,sp,-16
    80000960:	e422                	sd	s0,8(sp)
    80000962:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000964:	100007b7          	lui	a5,0x10000
    80000968:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000096c:	8b85                	andi	a5,a5,1
    8000096e:	cb91                	beqz	a5,80000982 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000970:	100007b7          	lui	a5,0x10000
    80000974:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000978:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000097c:	6422                	ld	s0,8(sp)
    8000097e:	0141                	addi	sp,sp,16
    80000980:	8082                	ret
    return -1;
    80000982:	557d                	li	a0,-1
    80000984:	bfe5                	j	8000097c <uartgetc+0x1e>

0000000080000986 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000986:	1101                	addi	sp,sp,-32
    80000988:	ec06                	sd	ra,24(sp)
    8000098a:	e822                	sd	s0,16(sp)
    8000098c:	e426                	sd	s1,8(sp)
    8000098e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000990:	54fd                	li	s1,-1
    80000992:	a029                	j	8000099c <uartintr+0x16>
      break;
    consoleintr(c);
    80000994:	00000097          	auipc	ra,0x0
    80000998:	916080e7          	jalr	-1770(ra) # 800002aa <consoleintr>
    int c = uartgetc();
    8000099c:	00000097          	auipc	ra,0x0
    800009a0:	fc2080e7          	jalr	-62(ra) # 8000095e <uartgetc>
    if(c == -1)
    800009a4:	fe9518e3          	bne	a0,s1,80000994 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009a8:	00011497          	auipc	s1,0x11
    800009ac:	8a048493          	addi	s1,s1,-1888 # 80011248 <uart_tx_lock>
    800009b0:	8526                	mv	a0,s1
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	210080e7          	jalr	528(ra) # 80000bc2 <acquire>
  uartstart();
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	e68080e7          	jalr	-408(ra) # 80000822 <uartstart>
  release(&uart_tx_lock);
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	2b2080e7          	jalr	690(ra) # 80000c76 <release>
}
    800009cc:	60e2                	ld	ra,24(sp)
    800009ce:	6442                	ld	s0,16(sp)
    800009d0:	64a2                	ld	s1,8(sp)
    800009d2:	6105                	addi	sp,sp,32
    800009d4:	8082                	ret

00000000800009d6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	e04a                	sd	s2,0(sp)
    800009e0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e2:	03451793          	slli	a5,a0,0x34
    800009e6:	ebb9                	bnez	a5,80000a3c <kfree+0x66>
    800009e8:	84aa                	mv	s1,a0
    800009ea:	00025797          	auipc	a5,0x25
    800009ee:	61678793          	addi	a5,a5,1558 # 80026000 <end>
    800009f2:	04f56563          	bltu	a0,a5,80000a3c <kfree+0x66>
    800009f6:	47c5                	li	a5,17
    800009f8:	07ee                	slli	a5,a5,0x1b
    800009fa:	04f57163          	bgeu	a0,a5,80000a3c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800009fe:	6605                	lui	a2,0x1
    80000a00:	4585                	li	a1,1
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	2bc080e7          	jalr	700(ra) # 80000cbe <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0a:	00011917          	auipc	s2,0x11
    80000a0e:	87690913          	addi	s2,s2,-1930 # 80011280 <kmem>
    80000a12:	854a                	mv	a0,s2
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1ae080e7          	jalr	430(ra) # 80000bc2 <acquire>
  r->next = kmem.freelist;
    80000a1c:	01893783          	ld	a5,24(s2)
    80000a20:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a22:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	24e080e7          	jalr	590(ra) # 80000c76 <release>
}
    80000a30:	60e2                	ld	ra,24(sp)
    80000a32:	6442                	ld	s0,16(sp)
    80000a34:	64a2                	ld	s1,8(sp)
    80000a36:	6902                	ld	s2,0(sp)
    80000a38:	6105                	addi	sp,sp,32
    80000a3a:	8082                	ret
    panic("kfree");
    80000a3c:	00007517          	auipc	a0,0x7
    80000a40:	62450513          	addi	a0,a0,1572 # 80008060 <digits+0x20>
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	ae6080e7          	jalr	-1306(ra) # 8000052a <panic>

0000000080000a4c <freerange>:
{
    80000a4c:	7179                	addi	sp,sp,-48
    80000a4e:	f406                	sd	ra,40(sp)
    80000a50:	f022                	sd	s0,32(sp)
    80000a52:	ec26                	sd	s1,24(sp)
    80000a54:	e84a                	sd	s2,16(sp)
    80000a56:	e44e                	sd	s3,8(sp)
    80000a58:	e052                	sd	s4,0(sp)
    80000a5a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a5c:	6785                	lui	a5,0x1
    80000a5e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a62:	94aa                	add	s1,s1,a0
    80000a64:	757d                	lui	a0,0xfffff
    80000a66:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a68:	94be                	add	s1,s1,a5
    80000a6a:	0095ee63          	bltu	a1,s1,80000a86 <freerange+0x3a>
    80000a6e:	892e                	mv	s2,a1
    kfree(p);
    80000a70:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a72:	6985                	lui	s3,0x1
    kfree(p);
    80000a74:	01448533          	add	a0,s1,s4
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	f5e080e7          	jalr	-162(ra) # 800009d6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe9979e3          	bgeu	s2,s1,80000a74 <freerange+0x28>
}
    80000a86:	70a2                	ld	ra,40(sp)
    80000a88:	7402                	ld	s0,32(sp)
    80000a8a:	64e2                	ld	s1,24(sp)
    80000a8c:	6942                	ld	s2,16(sp)
    80000a8e:	69a2                	ld	s3,8(sp)
    80000a90:	6a02                	ld	s4,0(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00007597          	auipc	a1,0x7
    80000aa2:	5ca58593          	addi	a1,a1,1482 # 80008068 <digits+0x28>
    80000aa6:	00010517          	auipc	a0,0x10
    80000aaa:	7da50513          	addi	a0,a0,2010 # 80011280 <kmem>
    80000aae:	00000097          	auipc	ra,0x0
    80000ab2:	084080e7          	jalr	132(ra) # 80000b32 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ab6:	45c5                	li	a1,17
    80000ab8:	05ee                	slli	a1,a1,0x1b
    80000aba:	00025517          	auipc	a0,0x25
    80000abe:	54650513          	addi	a0,a0,1350 # 80026000 <end>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	f8a080e7          	jalr	-118(ra) # 80000a4c <freerange>
}
    80000aca:	60a2                	ld	ra,8(sp)
    80000acc:	6402                	ld	s0,0(sp)
    80000ace:	0141                	addi	sp,sp,16
    80000ad0:	8082                	ret

0000000080000ad2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad2:	1101                	addi	sp,sp,-32
    80000ad4:	ec06                	sd	ra,24(sp)
    80000ad6:	e822                	sd	s0,16(sp)
    80000ad8:	e426                	sd	s1,8(sp)
    80000ada:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000adc:	00010497          	auipc	s1,0x10
    80000ae0:	7a448493          	addi	s1,s1,1956 # 80011280 <kmem>
    80000ae4:	8526                	mv	a0,s1
    80000ae6:	00000097          	auipc	ra,0x0
    80000aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  r = kmem.freelist;
    80000aee:	6c84                	ld	s1,24(s1)
  if(r)
    80000af0:	c885                	beqz	s1,80000b20 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af2:	609c                	ld	a5,0(s1)
    80000af4:	00010517          	auipc	a0,0x10
    80000af8:	78c50513          	addi	a0,a0,1932 # 80011280 <kmem>
    80000afc:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	178080e7          	jalr	376(ra) # 80000c76 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b06:	6605                	lui	a2,0x1
    80000b08:	4595                	li	a1,5
    80000b0a:	8526                	mv	a0,s1
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	1b2080e7          	jalr	434(ra) # 80000cbe <memset>
  return (void*)r;
}
    80000b14:	8526                	mv	a0,s1
    80000b16:	60e2                	ld	ra,24(sp)
    80000b18:	6442                	ld	s0,16(sp)
    80000b1a:	64a2                	ld	s1,8(sp)
    80000b1c:	6105                	addi	sp,sp,32
    80000b1e:	8082                	ret
  release(&kmem.lock);
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	76050513          	addi	a0,a0,1888 # 80011280 <kmem>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	14e080e7          	jalr	334(ra) # 80000c76 <release>
  if(r)
    80000b30:	b7d5                	j	80000b14 <kalloc+0x42>

0000000080000b32 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b32:	1141                	addi	sp,sp,-16
    80000b34:	e422                	sd	s0,8(sp)
    80000b36:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b38:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b3e:	00053823          	sd	zero,16(a0)
}
    80000b42:	6422                	ld	s0,8(sp)
    80000b44:	0141                	addi	sp,sp,16
    80000b46:	8082                	ret

0000000080000b48 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b48:	411c                	lw	a5,0(a0)
    80000b4a:	e399                	bnez	a5,80000b50 <holding+0x8>
    80000b4c:	4501                	li	a0,0
  return r;
}
    80000b4e:	8082                	ret
{
    80000b50:	1101                	addi	sp,sp,-32
    80000b52:	ec06                	sd	ra,24(sp)
    80000b54:	e822                	sd	s0,16(sp)
    80000b56:	e426                	sd	s1,8(sp)
    80000b58:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5a:	6904                	ld	s1,16(a0)
    80000b5c:	00001097          	auipc	ra,0x1
    80000b60:	e1e080e7          	jalr	-482(ra) # 8000197a <mycpu>
    80000b64:	40a48533          	sub	a0,s1,a0
    80000b68:	00153513          	seqz	a0,a0
}
    80000b6c:	60e2                	ld	ra,24(sp)
    80000b6e:	6442                	ld	s0,16(sp)
    80000b70:	64a2                	ld	s1,8(sp)
    80000b72:	6105                	addi	sp,sp,32
    80000b74:	8082                	ret

0000000080000b76 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b80:	100024f3          	csrr	s1,sstatus
    80000b84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b88:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b8e:	00001097          	auipc	ra,0x1
    80000b92:	dec080e7          	jalr	-532(ra) # 8000197a <mycpu>
    80000b96:	5d3c                	lw	a5,120(a0)
    80000b98:	cf89                	beqz	a5,80000bb2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9a:	00001097          	auipc	ra,0x1
    80000b9e:	de0080e7          	jalr	-544(ra) # 8000197a <mycpu>
    80000ba2:	5d3c                	lw	a5,120(a0)
    80000ba4:	2785                	addiw	a5,a5,1
    80000ba6:	dd3c                	sw	a5,120(a0)
}
    80000ba8:	60e2                	ld	ra,24(sp)
    80000baa:	6442                	ld	s0,16(sp)
    80000bac:	64a2                	ld	s1,8(sp)
    80000bae:	6105                	addi	sp,sp,32
    80000bb0:	8082                	ret
    mycpu()->intena = old;
    80000bb2:	00001097          	auipc	ra,0x1
    80000bb6:	dc8080e7          	jalr	-568(ra) # 8000197a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bba:	8085                	srli	s1,s1,0x1
    80000bbc:	8885                	andi	s1,s1,1
    80000bbe:	dd64                	sw	s1,124(a0)
    80000bc0:	bfe9                	j	80000b9a <push_off+0x24>

0000000080000bc2 <acquire>:
{
    80000bc2:	1101                	addi	sp,sp,-32
    80000bc4:	ec06                	sd	ra,24(sp)
    80000bc6:	e822                	sd	s0,16(sp)
    80000bc8:	e426                	sd	s1,8(sp)
    80000bca:	1000                	addi	s0,sp,32
    80000bcc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bce:	00000097          	auipc	ra,0x0
    80000bd2:	fa8080e7          	jalr	-88(ra) # 80000b76 <push_off>
  if(holding(lk))
    80000bd6:	8526                	mv	a0,s1
    80000bd8:	00000097          	auipc	ra,0x0
    80000bdc:	f70080e7          	jalr	-144(ra) # 80000b48 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be0:	4705                	li	a4,1
  if(holding(lk))
    80000be2:	e115                	bnez	a0,80000c06 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	87ba                	mv	a5,a4
    80000be6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bea:	2781                	sext.w	a5,a5
    80000bec:	ffe5                	bnez	a5,80000be4 <acquire+0x22>
  __sync_synchronize();
    80000bee:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf2:	00001097          	auipc	ra,0x1
    80000bf6:	d88080e7          	jalr	-632(ra) # 8000197a <mycpu>
    80000bfa:	e888                	sd	a0,16(s1)
}
    80000bfc:	60e2                	ld	ra,24(sp)
    80000bfe:	6442                	ld	s0,16(sp)
    80000c00:	64a2                	ld	s1,8(sp)
    80000c02:	6105                	addi	sp,sp,32
    80000c04:	8082                	ret
    panic("acquire");
    80000c06:	00007517          	auipc	a0,0x7
    80000c0a:	46a50513          	addi	a0,a0,1130 # 80008070 <digits+0x30>
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	91c080e7          	jalr	-1764(ra) # 8000052a <panic>

0000000080000c16 <pop_off>:

void
pop_off(void)
{
    80000c16:	1141                	addi	sp,sp,-16
    80000c18:	e406                	sd	ra,8(sp)
    80000c1a:	e022                	sd	s0,0(sp)
    80000c1c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c1e:	00001097          	auipc	ra,0x1
    80000c22:	d5c080e7          	jalr	-676(ra) # 8000197a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c26:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c2c:	e78d                	bnez	a5,80000c56 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c2e:	5d3c                	lw	a5,120(a0)
    80000c30:	02f05b63          	blez	a5,80000c66 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c34:	37fd                	addiw	a5,a5,-1
    80000c36:	0007871b          	sext.w	a4,a5
    80000c3a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c3c:	eb09                	bnez	a4,80000c4e <pop_off+0x38>
    80000c3e:	5d7c                	lw	a5,124(a0)
    80000c40:	c799                	beqz	a5,80000c4e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c42:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c46:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c4a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c4e:	60a2                	ld	ra,8(sp)
    80000c50:	6402                	ld	s0,0(sp)
    80000c52:	0141                	addi	sp,sp,16
    80000c54:	8082                	ret
    panic("pop_off - interruptible");
    80000c56:	00007517          	auipc	a0,0x7
    80000c5a:	42250513          	addi	a0,a0,1058 # 80008078 <digits+0x38>
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8cc080e7          	jalr	-1844(ra) # 8000052a <panic>
    panic("pop_off");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	42a50513          	addi	a0,a0,1066 # 80008090 <digits+0x50>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8bc080e7          	jalr	-1860(ra) # 8000052a <panic>

0000000080000c76 <release>:
{
    80000c76:	1101                	addi	sp,sp,-32
    80000c78:	ec06                	sd	ra,24(sp)
    80000c7a:	e822                	sd	s0,16(sp)
    80000c7c:	e426                	sd	s1,8(sp)
    80000c7e:	1000                	addi	s0,sp,32
    80000c80:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	ec6080e7          	jalr	-314(ra) # 80000b48 <holding>
    80000c8a:	c115                	beqz	a0,80000cae <release+0x38>
  lk->cpu = 0;
    80000c8c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c90:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c94:	0f50000f          	fence	iorw,ow
    80000c98:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	f7a080e7          	jalr	-134(ra) # 80000c16 <pop_off>
}
    80000ca4:	60e2                	ld	ra,24(sp)
    80000ca6:	6442                	ld	s0,16(sp)
    80000ca8:	64a2                	ld	s1,8(sp)
    80000caa:	6105                	addi	sp,sp,32
    80000cac:	8082                	ret
    panic("release");
    80000cae:	00007517          	auipc	a0,0x7
    80000cb2:	3ea50513          	addi	a0,a0,1002 # 80008098 <digits+0x58>
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	874080e7          	jalr	-1932(ra) # 8000052a <panic>

0000000080000cbe <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cbe:	1141                	addi	sp,sp,-16
    80000cc0:	e422                	sd	s0,8(sp)
    80000cc2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cc4:	ca19                	beqz	a2,80000cda <memset+0x1c>
    80000cc6:	87aa                	mv	a5,a0
    80000cc8:	1602                	slli	a2,a2,0x20
    80000cca:	9201                	srli	a2,a2,0x20
    80000ccc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cd0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cd4:	0785                	addi	a5,a5,1
    80000cd6:	fee79de3          	bne	a5,a4,80000cd0 <memset+0x12>
  }
  return dst;
}
    80000cda:	6422                	ld	s0,8(sp)
    80000cdc:	0141                	addi	sp,sp,16
    80000cde:	8082                	ret

0000000080000ce0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ce0:	1141                	addi	sp,sp,-16
    80000ce2:	e422                	sd	s0,8(sp)
    80000ce4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ce6:	ca05                	beqz	a2,80000d16 <memcmp+0x36>
    80000ce8:	fff6069b          	addiw	a3,a2,-1
    80000cec:	1682                	slli	a3,a3,0x20
    80000cee:	9281                	srli	a3,a3,0x20
    80000cf0:	0685                	addi	a3,a3,1
    80000cf2:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cf4:	00054783          	lbu	a5,0(a0)
    80000cf8:	0005c703          	lbu	a4,0(a1)
    80000cfc:	00e79863          	bne	a5,a4,80000d0c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d00:	0505                	addi	a0,a0,1
    80000d02:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d04:	fed518e3          	bne	a0,a3,80000cf4 <memcmp+0x14>
  }

  return 0;
    80000d08:	4501                	li	a0,0
    80000d0a:	a019                	j	80000d10 <memcmp+0x30>
      return *s1 - *s2;
    80000d0c:	40e7853b          	subw	a0,a5,a4
}
    80000d10:	6422                	ld	s0,8(sp)
    80000d12:	0141                	addi	sp,sp,16
    80000d14:	8082                	ret
  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	bfe5                	j	80000d10 <memcmp+0x30>

0000000080000d1a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d1a:	1141                	addi	sp,sp,-16
    80000d1c:	e422                	sd	s0,8(sp)
    80000d1e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d20:	02a5e563          	bltu	a1,a0,80000d4a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d24:	fff6069b          	addiw	a3,a2,-1
    80000d28:	ce11                	beqz	a2,80000d44 <memmove+0x2a>
    80000d2a:	1682                	slli	a3,a3,0x20
    80000d2c:	9281                	srli	a3,a3,0x20
    80000d2e:	0685                	addi	a3,a3,1
    80000d30:	96ae                	add	a3,a3,a1
    80000d32:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d34:	0585                	addi	a1,a1,1
    80000d36:	0785                	addi	a5,a5,1
    80000d38:	fff5c703          	lbu	a4,-1(a1)
    80000d3c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d40:	fed59ae3          	bne	a1,a3,80000d34 <memmove+0x1a>

  return dst;
}
    80000d44:	6422                	ld	s0,8(sp)
    80000d46:	0141                	addi	sp,sp,16
    80000d48:	8082                	ret
  if(s < d && s + n > d){
    80000d4a:	02061713          	slli	a4,a2,0x20
    80000d4e:	9301                	srli	a4,a4,0x20
    80000d50:	00e587b3          	add	a5,a1,a4
    80000d54:	fcf578e3          	bgeu	a0,a5,80000d24 <memmove+0xa>
    d += n;
    80000d58:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d5a:	fff6069b          	addiw	a3,a2,-1
    80000d5e:	d27d                	beqz	a2,80000d44 <memmove+0x2a>
    80000d60:	02069613          	slli	a2,a3,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	fff64613          	not	a2,a2
    80000d6a:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d6c:	17fd                	addi	a5,a5,-1
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	0007c683          	lbu	a3,0(a5)
    80000d74:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d78:	fef61ae3          	bne	a2,a5,80000d6c <memmove+0x52>
    80000d7c:	b7e1                	j	80000d44 <memmove+0x2a>

0000000080000d7e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d7e:	1141                	addi	sp,sp,-16
    80000d80:	e406                	sd	ra,8(sp)
    80000d82:	e022                	sd	s0,0(sp)
    80000d84:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d86:	00000097          	auipc	ra,0x0
    80000d8a:	f94080e7          	jalr	-108(ra) # 80000d1a <memmove>
}
    80000d8e:	60a2                	ld	ra,8(sp)
    80000d90:	6402                	ld	s0,0(sp)
    80000d92:	0141                	addi	sp,sp,16
    80000d94:	8082                	ret

0000000080000d96 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d96:	1141                	addi	sp,sp,-16
    80000d98:	e422                	sd	s0,8(sp)
    80000d9a:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9c:	ce11                	beqz	a2,80000db8 <strncmp+0x22>
    80000d9e:	00054783          	lbu	a5,0(a0)
    80000da2:	cf89                	beqz	a5,80000dbc <strncmp+0x26>
    80000da4:	0005c703          	lbu	a4,0(a1)
    80000da8:	00f71a63          	bne	a4,a5,80000dbc <strncmp+0x26>
    n--, p++, q++;
    80000dac:	367d                	addiw	a2,a2,-1
    80000dae:	0505                	addi	a0,a0,1
    80000db0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db2:	f675                	bnez	a2,80000d9e <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db4:	4501                	li	a0,0
    80000db6:	a809                	j	80000dc8 <strncmp+0x32>
    80000db8:	4501                	li	a0,0
    80000dba:	a039                	j	80000dc8 <strncmp+0x32>
  if(n == 0)
    80000dbc:	ca09                	beqz	a2,80000dce <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dbe:	00054503          	lbu	a0,0(a0)
    80000dc2:	0005c783          	lbu	a5,0(a1)
    80000dc6:	9d1d                	subw	a0,a0,a5
}
    80000dc8:	6422                	ld	s0,8(sp)
    80000dca:	0141                	addi	sp,sp,16
    80000dcc:	8082                	ret
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	bfe5                	j	80000dc8 <strncmp+0x32>

0000000080000dd2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd2:	1141                	addi	sp,sp,-16
    80000dd4:	e422                	sd	s0,8(sp)
    80000dd6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd8:	872a                	mv	a4,a0
    80000dda:	8832                	mv	a6,a2
    80000ddc:	367d                	addiw	a2,a2,-1
    80000dde:	01005963          	blez	a6,80000df0 <strncpy+0x1e>
    80000de2:	0705                	addi	a4,a4,1
    80000de4:	0005c783          	lbu	a5,0(a1)
    80000de8:	fef70fa3          	sb	a5,-1(a4)
    80000dec:	0585                	addi	a1,a1,1
    80000dee:	f7f5                	bnez	a5,80000dda <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df0:	86ba                	mv	a3,a4
    80000df2:	00c05c63          	blez	a2,80000e0a <strncpy+0x38>
    *s++ = 0;
    80000df6:	0685                	addi	a3,a3,1
    80000df8:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000dfc:	fff6c793          	not	a5,a3
    80000e00:	9fb9                	addw	a5,a5,a4
    80000e02:	010787bb          	addw	a5,a5,a6
    80000e06:	fef048e3          	bgtz	a5,80000df6 <strncpy+0x24>
  return os;
}
    80000e0a:	6422                	ld	s0,8(sp)
    80000e0c:	0141                	addi	sp,sp,16
    80000e0e:	8082                	ret

0000000080000e10 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e10:	1141                	addi	sp,sp,-16
    80000e12:	e422                	sd	s0,8(sp)
    80000e14:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e16:	02c05363          	blez	a2,80000e3c <safestrcpy+0x2c>
    80000e1a:	fff6069b          	addiw	a3,a2,-1
    80000e1e:	1682                	slli	a3,a3,0x20
    80000e20:	9281                	srli	a3,a3,0x20
    80000e22:	96ae                	add	a3,a3,a1
    80000e24:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e26:	00d58963          	beq	a1,a3,80000e38 <safestrcpy+0x28>
    80000e2a:	0585                	addi	a1,a1,1
    80000e2c:	0785                	addi	a5,a5,1
    80000e2e:	fff5c703          	lbu	a4,-1(a1)
    80000e32:	fee78fa3          	sb	a4,-1(a5)
    80000e36:	fb65                	bnez	a4,80000e26 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e38:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e3c:	6422                	ld	s0,8(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret

0000000080000e42 <strlen>:

int
strlen(const char *s)
{
    80000e42:	1141                	addi	sp,sp,-16
    80000e44:	e422                	sd	s0,8(sp)
    80000e46:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e48:	00054783          	lbu	a5,0(a0)
    80000e4c:	cf91                	beqz	a5,80000e68 <strlen+0x26>
    80000e4e:	0505                	addi	a0,a0,1
    80000e50:	87aa                	mv	a5,a0
    80000e52:	4685                	li	a3,1
    80000e54:	9e89                	subw	a3,a3,a0
    80000e56:	00f6853b          	addw	a0,a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	fb7d                	bnez	a4,80000e56 <strlen+0x14>
    ;
  return n;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strlen+0x20>

0000000080000e6c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e406                	sd	ra,8(sp)
    80000e70:	e022                	sd	s0,0(sp)
    80000e72:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e74:	00001097          	auipc	ra,0x1
    80000e78:	af6080e7          	jalr	-1290(ra) # 8000196a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e7c:	00008717          	auipc	a4,0x8
    80000e80:	19c70713          	addi	a4,a4,412 # 80009018 <started>
  if(cpuid() == 0){
    80000e84:	c139                	beqz	a0,80000eca <main+0x5e>
    while(started == 0)
    80000e86:	431c                	lw	a5,0(a4)
    80000e88:	2781                	sext.w	a5,a5
    80000e8a:	dff5                	beqz	a5,80000e86 <main+0x1a>
      ;
    __sync_synchronize();
    80000e8c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e90:	00001097          	auipc	ra,0x1
    80000e94:	ada080e7          	jalr	-1318(ra) # 8000196a <cpuid>
    80000e98:	85aa                	mv	a1,a0
    80000e9a:	00007517          	auipc	a0,0x7
    80000e9e:	21e50513          	addi	a0,a0,542 # 800080b8 <digits+0x78>
    80000ea2:	fffff097          	auipc	ra,0xfffff
    80000ea6:	6d2080e7          	jalr	1746(ra) # 80000574 <printf>
    kvminithart();    // turn on paging
    80000eaa:	00000097          	auipc	ra,0x0
    80000eae:	0d8080e7          	jalr	216(ra) # 80000f82 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb2:	00002097          	auipc	ra,0x2
    80000eb6:	c94080e7          	jalr	-876(ra) # 80002b46 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000eba:	00005097          	auipc	ra,0x5
    80000ebe:	366080e7          	jalr	870(ra) # 80006220 <plicinithart>
  }

  scheduler();        
    80000ec2:	00001097          	auipc	ra,0x1
    80000ec6:	0f2080e7          	jalr	242(ra) # 80001fb4 <scheduler>
    consoleinit();
    80000eca:	fffff097          	auipc	ra,0xfffff
    80000ece:	572080e7          	jalr	1394(ra) # 8000043c <consoleinit>
    printfinit();
    80000ed2:	00000097          	auipc	ra,0x0
    80000ed6:	882080e7          	jalr	-1918(ra) # 80000754 <printfinit>
    printf("\n");
    80000eda:	00007517          	auipc	a0,0x7
    80000ede:	1ee50513          	addi	a0,a0,494 # 800080c8 <digits+0x88>
    80000ee2:	fffff097          	auipc	ra,0xfffff
    80000ee6:	692080e7          	jalr	1682(ra) # 80000574 <printf>
    printf("xv6 kernel is booting\n");
    80000eea:	00007517          	auipc	a0,0x7
    80000eee:	1b650513          	addi	a0,a0,438 # 800080a0 <digits+0x60>
    80000ef2:	fffff097          	auipc	ra,0xfffff
    80000ef6:	682080e7          	jalr	1666(ra) # 80000574 <printf>
    printf("\n");
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	1ce50513          	addi	a0,a0,462 # 800080c8 <digits+0x88>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	672080e7          	jalr	1650(ra) # 80000574 <printf>
    kinit();         // physical page allocator
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	b8c080e7          	jalr	-1140(ra) # 80000a96 <kinit>
    kvminit();       // create kernel page table
    80000f12:	00000097          	auipc	ra,0x0
    80000f16:	310080e7          	jalr	784(ra) # 80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f1a:	00000097          	auipc	ra,0x0
    80000f1e:	068080e7          	jalr	104(ra) # 80000f82 <kvminithart>
    procinit();      // process table
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	980080e7          	jalr	-1664(ra) # 800018a2 <procinit>
    trapinit();      // trap vectors
    80000f2a:	00002097          	auipc	ra,0x2
    80000f2e:	bf4080e7          	jalr	-1036(ra) # 80002b1e <trapinit>
    trapinithart();  // install kernel trap vector
    80000f32:	00002097          	auipc	ra,0x2
    80000f36:	c14080e7          	jalr	-1004(ra) # 80002b46 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f3a:	00005097          	auipc	ra,0x5
    80000f3e:	2d0080e7          	jalr	720(ra) # 8000620a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	2de080e7          	jalr	734(ra) # 80006220 <plicinithart>
    binit();         // buffer cache
    80000f4a:	00002097          	auipc	ra,0x2
    80000f4e:	4a6080e7          	jalr	1190(ra) # 800033f0 <binit>
    iinit();         // inode cache
    80000f52:	00003097          	auipc	ra,0x3
    80000f56:	b38080e7          	jalr	-1224(ra) # 80003a8a <iinit>
    fileinit();      // file table
    80000f5a:	00004097          	auipc	ra,0x4
    80000f5e:	ae6080e7          	jalr	-1306(ra) # 80004a40 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f62:	00005097          	auipc	ra,0x5
    80000f66:	3e0080e7          	jalr	992(ra) # 80006342 <virtio_disk_init>
    userinit();      // first user process
    80000f6a:	00001097          	auipc	ra,0x1
    80000f6e:	e00080e7          	jalr	-512(ra) # 80001d6a <userinit>
    __sync_synchronize();
    80000f72:	0ff0000f          	fence
    started = 1;
    80000f76:	4785                	li	a5,1
    80000f78:	00008717          	auipc	a4,0x8
    80000f7c:	0af72023          	sw	a5,160(a4) # 80009018 <started>
    80000f80:	b789                	j	80000ec2 <main+0x56>

0000000080000f82 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f82:	1141                	addi	sp,sp,-16
    80000f84:	e422                	sd	s0,8(sp)
    80000f86:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f88:	00008797          	auipc	a5,0x8
    80000f8c:	0987b783          	ld	a5,152(a5) # 80009020 <kernel_pagetable>
    80000f90:	83b1                	srli	a5,a5,0xc
    80000f92:	577d                	li	a4,-1
    80000f94:	177e                	slli	a4,a4,0x3f
    80000f96:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f98:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9c:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret

0000000080000fa6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fa6:	7139                	addi	sp,sp,-64
    80000fa8:	fc06                	sd	ra,56(sp)
    80000faa:	f822                	sd	s0,48(sp)
    80000fac:	f426                	sd	s1,40(sp)
    80000fae:	f04a                	sd	s2,32(sp)
    80000fb0:	ec4e                	sd	s3,24(sp)
    80000fb2:	e852                	sd	s4,16(sp)
    80000fb4:	e456                	sd	s5,8(sp)
    80000fb6:	e05a                	sd	s6,0(sp)
    80000fb8:	0080                	addi	s0,sp,64
    80000fba:	84aa                	mv	s1,a0
    80000fbc:	89ae                	mv	s3,a1
    80000fbe:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc0:	57fd                	li	a5,-1
    80000fc2:	83e9                	srli	a5,a5,0x1a
    80000fc4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fc6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fc8:	04b7f263          	bgeu	a5,a1,8000100c <walk+0x66>
    panic("walk");
    80000fcc:	00007517          	auipc	a0,0x7
    80000fd0:	10450513          	addi	a0,a0,260 # 800080d0 <digits+0x90>
    80000fd4:	fffff097          	auipc	ra,0xfffff
    80000fd8:	556080e7          	jalr	1366(ra) # 8000052a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fdc:	060a8663          	beqz	s5,80001048 <walk+0xa2>
    80000fe0:	00000097          	auipc	ra,0x0
    80000fe4:	af2080e7          	jalr	-1294(ra) # 80000ad2 <kalloc>
    80000fe8:	84aa                	mv	s1,a0
    80000fea:	c529                	beqz	a0,80001034 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fec:	6605                	lui	a2,0x1
    80000fee:	4581                	li	a1,0
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	cce080e7          	jalr	-818(ra) # 80000cbe <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ff8:	00c4d793          	srli	a5,s1,0xc
    80000ffc:	07aa                	slli	a5,a5,0xa
    80000ffe:	0017e793          	ori	a5,a5,1
    80001002:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	036a0063          	beq	s4,s6,80001028 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000100c:	0149d933          	srl	s2,s3,s4
    80001010:	1ff97913          	andi	s2,s2,511
    80001014:	090e                	slli	s2,s2,0x3
    80001016:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001018:	00093483          	ld	s1,0(s2)
    8000101c:	0014f793          	andi	a5,s1,1
    80001020:	dfd5                	beqz	a5,80000fdc <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001022:	80a9                	srli	s1,s1,0xa
    80001024:	04b2                	slli	s1,s1,0xc
    80001026:	b7c5                	j	80001006 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001028:	00c9d513          	srli	a0,s3,0xc
    8000102c:	1ff57513          	andi	a0,a0,511
    80001030:	050e                	slli	a0,a0,0x3
    80001032:	9526                	add	a0,a0,s1
}
    80001034:	70e2                	ld	ra,56(sp)
    80001036:	7442                	ld	s0,48(sp)
    80001038:	74a2                	ld	s1,40(sp)
    8000103a:	7902                	ld	s2,32(sp)
    8000103c:	69e2                	ld	s3,24(sp)
    8000103e:	6a42                	ld	s4,16(sp)
    80001040:	6aa2                	ld	s5,8(sp)
    80001042:	6b02                	ld	s6,0(sp)
    80001044:	6121                	addi	sp,sp,64
    80001046:	8082                	ret
        return 0;
    80001048:	4501                	li	a0,0
    8000104a:	b7ed                	j	80001034 <walk+0x8e>

000000008000104c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000104c:	57fd                	li	a5,-1
    8000104e:	83e9                	srli	a5,a5,0x1a
    80001050:	00b7f463          	bgeu	a5,a1,80001058 <walkaddr+0xc>
    return 0;
    80001054:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001056:	8082                	ret
{
    80001058:	1141                	addi	sp,sp,-16
    8000105a:	e406                	sd	ra,8(sp)
    8000105c:	e022                	sd	s0,0(sp)
    8000105e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001060:	4601                	li	a2,0
    80001062:	00000097          	auipc	ra,0x0
    80001066:	f44080e7          	jalr	-188(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000106a:	c105                	beqz	a0,8000108a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000106c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000106e:	0117f693          	andi	a3,a5,17
    80001072:	4745                	li	a4,17
    return 0;
    80001074:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001076:	00e68663          	beq	a3,a4,80001082 <walkaddr+0x36>
}
    8000107a:	60a2                	ld	ra,8(sp)
    8000107c:	6402                	ld	s0,0(sp)
    8000107e:	0141                	addi	sp,sp,16
    80001080:	8082                	ret
  pa = PTE2PA(*pte);
    80001082:	00a7d513          	srli	a0,a5,0xa
    80001086:	0532                	slli	a0,a0,0xc
  return pa;
    80001088:	bfcd                	j	8000107a <walkaddr+0x2e>
    return 0;
    8000108a:	4501                	li	a0,0
    8000108c:	b7fd                	j	8000107a <walkaddr+0x2e>

000000008000108e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000108e:	715d                	addi	sp,sp,-80
    80001090:	e486                	sd	ra,72(sp)
    80001092:	e0a2                	sd	s0,64(sp)
    80001094:	fc26                	sd	s1,56(sp)
    80001096:	f84a                	sd	s2,48(sp)
    80001098:	f44e                	sd	s3,40(sp)
    8000109a:	f052                	sd	s4,32(sp)
    8000109c:	ec56                	sd	s5,24(sp)
    8000109e:	e85a                	sd	s6,16(sp)
    800010a0:	e45e                	sd	s7,8(sp)
    800010a2:	0880                	addi	s0,sp,80
    800010a4:	8aaa                	mv	s5,a0
    800010a6:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010a8:	777d                	lui	a4,0xfffff
    800010aa:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ae:	167d                	addi	a2,a2,-1
    800010b0:	00b609b3          	add	s3,a2,a1
    800010b4:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010b8:	893e                	mv	s2,a5
    800010ba:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010be:	6b85                	lui	s7,0x1
    800010c0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010c4:	4605                	li	a2,1
    800010c6:	85ca                	mv	a1,s2
    800010c8:	8556                	mv	a0,s5
    800010ca:	00000097          	auipc	ra,0x0
    800010ce:	edc080e7          	jalr	-292(ra) # 80000fa6 <walk>
    800010d2:	c51d                	beqz	a0,80001100 <mappages+0x72>
    if(*pte & PTE_V)
    800010d4:	611c                	ld	a5,0(a0)
    800010d6:	8b85                	andi	a5,a5,1
    800010d8:	ef81                	bnez	a5,800010f0 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010da:	80b1                	srli	s1,s1,0xc
    800010dc:	04aa                	slli	s1,s1,0xa
    800010de:	0164e4b3          	or	s1,s1,s6
    800010e2:	0014e493          	ori	s1,s1,1
    800010e6:	e104                	sd	s1,0(a0)
    if(a == last)
    800010e8:	03390863          	beq	s2,s3,80001118 <mappages+0x8a>
    a += PGSIZE;
    800010ec:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	bfc9                	j	800010c0 <mappages+0x32>
      panic("remap");
    800010f0:	00007517          	auipc	a0,0x7
    800010f4:	fe850513          	addi	a0,a0,-24 # 800080d8 <digits+0x98>
    800010f8:	fffff097          	auipc	ra,0xfffff
    800010fc:	432080e7          	jalr	1074(ra) # 8000052a <panic>
      return -1;
    80001100:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001102:	60a6                	ld	ra,72(sp)
    80001104:	6406                	ld	s0,64(sp)
    80001106:	74e2                	ld	s1,56(sp)
    80001108:	7942                	ld	s2,48(sp)
    8000110a:	79a2                	ld	s3,40(sp)
    8000110c:	7a02                	ld	s4,32(sp)
    8000110e:	6ae2                	ld	s5,24(sp)
    80001110:	6b42                	ld	s6,16(sp)
    80001112:	6ba2                	ld	s7,8(sp)
    80001114:	6161                	addi	sp,sp,80
    80001116:	8082                	ret
  return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7e5                	j	80001102 <mappages+0x74>

000000008000111c <kvmmap>:
{
    8000111c:	1141                	addi	sp,sp,-16
    8000111e:	e406                	sd	ra,8(sp)
    80001120:	e022                	sd	s0,0(sp)
    80001122:	0800                	addi	s0,sp,16
    80001124:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001126:	86b2                	mv	a3,a2
    80001128:	863e                	mv	a2,a5
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	f64080e7          	jalr	-156(ra) # 8000108e <mappages>
    80001132:	e509                	bnez	a0,8000113c <kvmmap+0x20>
}
    80001134:	60a2                	ld	ra,8(sp)
    80001136:	6402                	ld	s0,0(sp)
    80001138:	0141                	addi	sp,sp,16
    8000113a:	8082                	ret
    panic("kvmmap");
    8000113c:	00007517          	auipc	a0,0x7
    80001140:	fa450513          	addi	a0,a0,-92 # 800080e0 <digits+0xa0>
    80001144:	fffff097          	auipc	ra,0xfffff
    80001148:	3e6080e7          	jalr	998(ra) # 8000052a <panic>

000000008000114c <kvmmake>:
{
    8000114c:	1101                	addi	sp,sp,-32
    8000114e:	ec06                	sd	ra,24(sp)
    80001150:	e822                	sd	s0,16(sp)
    80001152:	e426                	sd	s1,8(sp)
    80001154:	e04a                	sd	s2,0(sp)
    80001156:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001158:	00000097          	auipc	ra,0x0
    8000115c:	97a080e7          	jalr	-1670(ra) # 80000ad2 <kalloc>
    80001160:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001162:	6605                	lui	a2,0x1
    80001164:	4581                	li	a1,0
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	b58080e7          	jalr	-1192(ra) # 80000cbe <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000116e:	4719                	li	a4,6
    80001170:	6685                	lui	a3,0x1
    80001172:	10000637          	lui	a2,0x10000
    80001176:	100005b7          	lui	a1,0x10000
    8000117a:	8526                	mv	a0,s1
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	fa0080e7          	jalr	-96(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001184:	4719                	li	a4,6
    80001186:	6685                	lui	a3,0x1
    80001188:	10001637          	lui	a2,0x10001
    8000118c:	100015b7          	lui	a1,0x10001
    80001190:	8526                	mv	a0,s1
    80001192:	00000097          	auipc	ra,0x0
    80001196:	f8a080e7          	jalr	-118(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000119a:	4719                	li	a4,6
    8000119c:	004006b7          	lui	a3,0x400
    800011a0:	0c000637          	lui	a2,0xc000
    800011a4:	0c0005b7          	lui	a1,0xc000
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f72080e7          	jalr	-142(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011b2:	00007917          	auipc	s2,0x7
    800011b6:	e4e90913          	addi	s2,s2,-434 # 80008000 <etext>
    800011ba:	4729                	li	a4,10
    800011bc:	80007697          	auipc	a3,0x80007
    800011c0:	e4468693          	addi	a3,a3,-444 # 8000 <_entry-0x7fff8000>
    800011c4:	4605                	li	a2,1
    800011c6:	067e                	slli	a2,a2,0x1f
    800011c8:	85b2                	mv	a1,a2
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f50080e7          	jalr	-176(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	46c5                	li	a3,17
    800011d8:	06ee                	slli	a3,a3,0x1b
    800011da:	412686b3          	sub	a3,a3,s2
    800011de:	864a                	mv	a2,s2
    800011e0:	85ca                	mv	a1,s2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f38080e7          	jalr	-200(ra) # 8000111c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011ec:	4729                	li	a4,10
    800011ee:	6685                	lui	a3,0x1
    800011f0:	00006617          	auipc	a2,0x6
    800011f4:	e1060613          	addi	a2,a2,-496 # 80007000 <_trampoline>
    800011f8:	040005b7          	lui	a1,0x4000
    800011fc:	15fd                	addi	a1,a1,-1
    800011fe:	05b2                	slli	a1,a1,0xc
    80001200:	8526                	mv	a0,s1
    80001202:	00000097          	auipc	ra,0x0
    80001206:	f1a080e7          	jalr	-230(ra) # 8000111c <kvmmap>
  proc_mapstacks(kpgtbl);
    8000120a:	8526                	mv	a0,s1
    8000120c:	00000097          	auipc	ra,0x0
    80001210:	600080e7          	jalr	1536(ra) # 8000180c <proc_mapstacks>
}
    80001214:	8526                	mv	a0,s1
    80001216:	60e2                	ld	ra,24(sp)
    80001218:	6442                	ld	s0,16(sp)
    8000121a:	64a2                	ld	s1,8(sp)
    8000121c:	6902                	ld	s2,0(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f22080e7          	jalr	-222(ra) # 8000114c <kvmmake>
    80001232:	00008797          	auipc	a5,0x8
    80001236:	dea7b723          	sd	a0,-530(a5) # 80009020 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001242:	715d                	addi	sp,sp,-80
    80001244:	e486                	sd	ra,72(sp)
    80001246:	e0a2                	sd	s0,64(sp)
    80001248:	fc26                	sd	s1,56(sp)
    8000124a:	f84a                	sd	s2,48(sp)
    8000124c:	f44e                	sd	s3,40(sp)
    8000124e:	f052                	sd	s4,32(sp)
    80001250:	ec56                	sd	s5,24(sp)
    80001252:	e85a                	sd	s6,16(sp)
    80001254:	e45e                	sd	s7,8(sp)
    80001256:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001258:	03459793          	slli	a5,a1,0x34
    8000125c:	e795                	bnez	a5,80001288 <uvmunmap+0x46>
    8000125e:	8a2a                	mv	s4,a0
    80001260:	892e                	mv	s2,a1
    80001262:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001264:	0632                	slli	a2,a2,0xc
    80001266:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000126a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000126c:	6b05                	lui	s6,0x1
    8000126e:	0735e263          	bltu	a1,s3,800012d2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001272:	60a6                	ld	ra,72(sp)
    80001274:	6406                	ld	s0,64(sp)
    80001276:	74e2                	ld	s1,56(sp)
    80001278:	7942                	ld	s2,48(sp)
    8000127a:	79a2                	ld	s3,40(sp)
    8000127c:	7a02                	ld	s4,32(sp)
    8000127e:	6ae2                	ld	s5,24(sp)
    80001280:	6b42                	ld	s6,16(sp)
    80001282:	6ba2                	ld	s7,8(sp)
    80001284:	6161                	addi	sp,sp,80
    80001286:	8082                	ret
    panic("uvmunmap: not aligned");
    80001288:	00007517          	auipc	a0,0x7
    8000128c:	e6050513          	addi	a0,a0,-416 # 800080e8 <digits+0xa8>
    80001290:	fffff097          	auipc	ra,0xfffff
    80001294:	29a080e7          	jalr	666(ra) # 8000052a <panic>
      panic("uvmunmap: walk");
    80001298:	00007517          	auipc	a0,0x7
    8000129c:	e6850513          	addi	a0,a0,-408 # 80008100 <digits+0xc0>
    800012a0:	fffff097          	auipc	ra,0xfffff
    800012a4:	28a080e7          	jalr	650(ra) # 8000052a <panic>
      panic("uvmunmap: not mapped");
    800012a8:	00007517          	auipc	a0,0x7
    800012ac:	e6850513          	addi	a0,a0,-408 # 80008110 <digits+0xd0>
    800012b0:	fffff097          	auipc	ra,0xfffff
    800012b4:	27a080e7          	jalr	634(ra) # 8000052a <panic>
      panic("uvmunmap: not a leaf");
    800012b8:	00007517          	auipc	a0,0x7
    800012bc:	e7050513          	addi	a0,a0,-400 # 80008128 <digits+0xe8>
    800012c0:	fffff097          	auipc	ra,0xfffff
    800012c4:	26a080e7          	jalr	618(ra) # 8000052a <panic>
    *pte = 0;
    800012c8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012cc:	995a                	add	s2,s2,s6
    800012ce:	fb3972e3          	bgeu	s2,s3,80001272 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012d2:	4601                	li	a2,0
    800012d4:	85ca                	mv	a1,s2
    800012d6:	8552                	mv	a0,s4
    800012d8:	00000097          	auipc	ra,0x0
    800012dc:	cce080e7          	jalr	-818(ra) # 80000fa6 <walk>
    800012e0:	84aa                	mv	s1,a0
    800012e2:	d95d                	beqz	a0,80001298 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012e4:	6108                	ld	a0,0(a0)
    800012e6:	00157793          	andi	a5,a0,1
    800012ea:	dfdd                	beqz	a5,800012a8 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800012ec:	3ff57793          	andi	a5,a0,1023
    800012f0:	fd7784e3          	beq	a5,s7,800012b8 <uvmunmap+0x76>
    if(do_free){
    800012f4:	fc0a8ae3          	beqz	s5,800012c8 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800012f8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012fa:	0532                	slli	a0,a0,0xc
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	6da080e7          	jalr	1754(ra) # 800009d6 <kfree>
    80001304:	b7d1                	j	800012c8 <uvmunmap+0x86>

0000000080001306 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001306:	1101                	addi	sp,sp,-32
    80001308:	ec06                	sd	ra,24(sp)
    8000130a:	e822                	sd	s0,16(sp)
    8000130c:	e426                	sd	s1,8(sp)
    8000130e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001310:	fffff097          	auipc	ra,0xfffff
    80001314:	7c2080e7          	jalr	1986(ra) # 80000ad2 <kalloc>
    80001318:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000131a:	c519                	beqz	a0,80001328 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000131c:	6605                	lui	a2,0x1
    8000131e:	4581                	li	a1,0
    80001320:	00000097          	auipc	ra,0x0
    80001324:	99e080e7          	jalr	-1634(ra) # 80000cbe <memset>
  return pagetable;
}
    80001328:	8526                	mv	a0,s1
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	64a2                	ld	s1,8(sp)
    80001330:	6105                	addi	sp,sp,32
    80001332:	8082                	ret

0000000080001334 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001334:	7179                	addi	sp,sp,-48
    80001336:	f406                	sd	ra,40(sp)
    80001338:	f022                	sd	s0,32(sp)
    8000133a:	ec26                	sd	s1,24(sp)
    8000133c:	e84a                	sd	s2,16(sp)
    8000133e:	e44e                	sd	s3,8(sp)
    80001340:	e052                	sd	s4,0(sp)
    80001342:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001344:	6785                	lui	a5,0x1
    80001346:	04f67863          	bgeu	a2,a5,80001396 <uvminit+0x62>
    8000134a:	8a2a                	mv	s4,a0
    8000134c:	89ae                	mv	s3,a1
    8000134e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001350:	fffff097          	auipc	ra,0xfffff
    80001354:	782080e7          	jalr	1922(ra) # 80000ad2 <kalloc>
    80001358:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000135a:	6605                	lui	a2,0x1
    8000135c:	4581                	li	a1,0
    8000135e:	00000097          	auipc	ra,0x0
    80001362:	960080e7          	jalr	-1696(ra) # 80000cbe <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001366:	4779                	li	a4,30
    80001368:	86ca                	mv	a3,s2
    8000136a:	6605                	lui	a2,0x1
    8000136c:	4581                	li	a1,0
    8000136e:	8552                	mv	a0,s4
    80001370:	00000097          	auipc	ra,0x0
    80001374:	d1e080e7          	jalr	-738(ra) # 8000108e <mappages>
  memmove(mem, src, sz);
    80001378:	8626                	mv	a2,s1
    8000137a:	85ce                	mv	a1,s3
    8000137c:	854a                	mv	a0,s2
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	99c080e7          	jalr	-1636(ra) # 80000d1a <memmove>
}
    80001386:	70a2                	ld	ra,40(sp)
    80001388:	7402                	ld	s0,32(sp)
    8000138a:	64e2                	ld	s1,24(sp)
    8000138c:	6942                	ld	s2,16(sp)
    8000138e:	69a2                	ld	s3,8(sp)
    80001390:	6a02                	ld	s4,0(sp)
    80001392:	6145                	addi	sp,sp,48
    80001394:	8082                	ret
    panic("inituvm: more than a page");
    80001396:	00007517          	auipc	a0,0x7
    8000139a:	daa50513          	addi	a0,a0,-598 # 80008140 <digits+0x100>
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	18c080e7          	jalr	396(ra) # 8000052a <panic>

00000000800013a6 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013a6:	1101                	addi	sp,sp,-32
    800013a8:	ec06                	sd	ra,24(sp)
    800013aa:	e822                	sd	s0,16(sp)
    800013ac:	e426                	sd	s1,8(sp)
    800013ae:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013b0:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013b2:	00b67d63          	bgeu	a2,a1,800013cc <uvmdealloc+0x26>
    800013b6:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013b8:	6785                	lui	a5,0x1
    800013ba:	17fd                	addi	a5,a5,-1
    800013bc:	00f60733          	add	a4,a2,a5
    800013c0:	767d                	lui	a2,0xfffff
    800013c2:	8f71                	and	a4,a4,a2
    800013c4:	97ae                	add	a5,a5,a1
    800013c6:	8ff1                	and	a5,a5,a2
    800013c8:	00f76863          	bltu	a4,a5,800013d8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013cc:	8526                	mv	a0,s1
    800013ce:	60e2                	ld	ra,24(sp)
    800013d0:	6442                	ld	s0,16(sp)
    800013d2:	64a2                	ld	s1,8(sp)
    800013d4:	6105                	addi	sp,sp,32
    800013d6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013d8:	8f99                	sub	a5,a5,a4
    800013da:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013dc:	4685                	li	a3,1
    800013de:	0007861b          	sext.w	a2,a5
    800013e2:	85ba                	mv	a1,a4
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	e5e080e7          	jalr	-418(ra) # 80001242 <uvmunmap>
    800013ec:	b7c5                	j	800013cc <uvmdealloc+0x26>

00000000800013ee <uvmalloc>:
  if(newsz < oldsz)
    800013ee:	0ab66163          	bltu	a2,a1,80001490 <uvmalloc+0xa2>
{
    800013f2:	7139                	addi	sp,sp,-64
    800013f4:	fc06                	sd	ra,56(sp)
    800013f6:	f822                	sd	s0,48(sp)
    800013f8:	f426                	sd	s1,40(sp)
    800013fa:	f04a                	sd	s2,32(sp)
    800013fc:	ec4e                	sd	s3,24(sp)
    800013fe:	e852                	sd	s4,16(sp)
    80001400:	e456                	sd	s5,8(sp)
    80001402:	0080                	addi	s0,sp,64
    80001404:	8aaa                	mv	s5,a0
    80001406:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001408:	6985                	lui	s3,0x1
    8000140a:	19fd                	addi	s3,s3,-1
    8000140c:	95ce                	add	a1,a1,s3
    8000140e:	79fd                	lui	s3,0xfffff
    80001410:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001414:	08c9f063          	bgeu	s3,a2,80001494 <uvmalloc+0xa6>
    80001418:	894e                	mv	s2,s3
    mem = kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6b8080e7          	jalr	1720(ra) # 80000ad2 <kalloc>
    80001422:	84aa                	mv	s1,a0
    if(mem == 0){
    80001424:	c51d                	beqz	a0,80001452 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001426:	6605                	lui	a2,0x1
    80001428:	4581                	li	a1,0
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	894080e7          	jalr	-1900(ra) # 80000cbe <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001432:	4779                	li	a4,30
    80001434:	86a6                	mv	a3,s1
    80001436:	6605                	lui	a2,0x1
    80001438:	85ca                	mv	a1,s2
    8000143a:	8556                	mv	a0,s5
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	c52080e7          	jalr	-942(ra) # 8000108e <mappages>
    80001444:	e905                	bnez	a0,80001474 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001446:	6785                	lui	a5,0x1
    80001448:	993e                	add	s2,s2,a5
    8000144a:	fd4968e3          	bltu	s2,s4,8000141a <uvmalloc+0x2c>
  return newsz;
    8000144e:	8552                	mv	a0,s4
    80001450:	a809                	j	80001462 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001452:	864e                	mv	a2,s3
    80001454:	85ca                	mv	a1,s2
    80001456:	8556                	mv	a0,s5
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	f4e080e7          	jalr	-178(ra) # 800013a6 <uvmdealloc>
      return 0;
    80001460:	4501                	li	a0,0
}
    80001462:	70e2                	ld	ra,56(sp)
    80001464:	7442                	ld	s0,48(sp)
    80001466:	74a2                	ld	s1,40(sp)
    80001468:	7902                	ld	s2,32(sp)
    8000146a:	69e2                	ld	s3,24(sp)
    8000146c:	6a42                	ld	s4,16(sp)
    8000146e:	6aa2                	ld	s5,8(sp)
    80001470:	6121                	addi	sp,sp,64
    80001472:	8082                	ret
      kfree(mem);
    80001474:	8526                	mv	a0,s1
    80001476:	fffff097          	auipc	ra,0xfffff
    8000147a:	560080e7          	jalr	1376(ra) # 800009d6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000147e:	864e                	mv	a2,s3
    80001480:	85ca                	mv	a1,s2
    80001482:	8556                	mv	a0,s5
    80001484:	00000097          	auipc	ra,0x0
    80001488:	f22080e7          	jalr	-222(ra) # 800013a6 <uvmdealloc>
      return 0;
    8000148c:	4501                	li	a0,0
    8000148e:	bfd1                	j	80001462 <uvmalloc+0x74>
    return oldsz;
    80001490:	852e                	mv	a0,a1
}
    80001492:	8082                	ret
  return newsz;
    80001494:	8532                	mv	a0,a2
    80001496:	b7f1                	j	80001462 <uvmalloc+0x74>

0000000080001498 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001498:	7179                	addi	sp,sp,-48
    8000149a:	f406                	sd	ra,40(sp)
    8000149c:	f022                	sd	s0,32(sp)
    8000149e:	ec26                	sd	s1,24(sp)
    800014a0:	e84a                	sd	s2,16(sp)
    800014a2:	e44e                	sd	s3,8(sp)
    800014a4:	e052                	sd	s4,0(sp)
    800014a6:	1800                	addi	s0,sp,48
    800014a8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014aa:	84aa                	mv	s1,a0
    800014ac:	6905                	lui	s2,0x1
    800014ae:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014b0:	4985                	li	s3,1
    800014b2:	a821                	j	800014ca <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014b4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014b6:	0532                	slli	a0,a0,0xc
    800014b8:	00000097          	auipc	ra,0x0
    800014bc:	fe0080e7          	jalr	-32(ra) # 80001498 <freewalk>
      pagetable[i] = 0;
    800014c0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014c4:	04a1                	addi	s1,s1,8
    800014c6:	03248163          	beq	s1,s2,800014e8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014ca:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014cc:	00f57793          	andi	a5,a0,15
    800014d0:	ff3782e3          	beq	a5,s3,800014b4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014d4:	8905                	andi	a0,a0,1
    800014d6:	d57d                	beqz	a0,800014c4 <freewalk+0x2c>
      panic("freewalk: leaf");
    800014d8:	00007517          	auipc	a0,0x7
    800014dc:	c8850513          	addi	a0,a0,-888 # 80008160 <digits+0x120>
    800014e0:	fffff097          	auipc	ra,0xfffff
    800014e4:	04a080e7          	jalr	74(ra) # 8000052a <panic>
    }
  }
  kfree((void*)pagetable);
    800014e8:	8552                	mv	a0,s4
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	4ec080e7          	jalr	1260(ra) # 800009d6 <kfree>
}
    800014f2:	70a2                	ld	ra,40(sp)
    800014f4:	7402                	ld	s0,32(sp)
    800014f6:	64e2                	ld	s1,24(sp)
    800014f8:	6942                	ld	s2,16(sp)
    800014fa:	69a2                	ld	s3,8(sp)
    800014fc:	6a02                	ld	s4,0(sp)
    800014fe:	6145                	addi	sp,sp,48
    80001500:	8082                	ret

0000000080001502 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001502:	1101                	addi	sp,sp,-32
    80001504:	ec06                	sd	ra,24(sp)
    80001506:	e822                	sd	s0,16(sp)
    80001508:	e426                	sd	s1,8(sp)
    8000150a:	1000                	addi	s0,sp,32
    8000150c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000150e:	e999                	bnez	a1,80001524 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001510:	8526                	mv	a0,s1
    80001512:	00000097          	auipc	ra,0x0
    80001516:	f86080e7          	jalr	-122(ra) # 80001498 <freewalk>
}
    8000151a:	60e2                	ld	ra,24(sp)
    8000151c:	6442                	ld	s0,16(sp)
    8000151e:	64a2                	ld	s1,8(sp)
    80001520:	6105                	addi	sp,sp,32
    80001522:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001524:	6605                	lui	a2,0x1
    80001526:	167d                	addi	a2,a2,-1
    80001528:	962e                	add	a2,a2,a1
    8000152a:	4685                	li	a3,1
    8000152c:	8231                	srli	a2,a2,0xc
    8000152e:	4581                	li	a1,0
    80001530:	00000097          	auipc	ra,0x0
    80001534:	d12080e7          	jalr	-750(ra) # 80001242 <uvmunmap>
    80001538:	bfe1                	j	80001510 <uvmfree+0xe>

000000008000153a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000153a:	c679                	beqz	a2,80001608 <uvmcopy+0xce>
{
    8000153c:	715d                	addi	sp,sp,-80
    8000153e:	e486                	sd	ra,72(sp)
    80001540:	e0a2                	sd	s0,64(sp)
    80001542:	fc26                	sd	s1,56(sp)
    80001544:	f84a                	sd	s2,48(sp)
    80001546:	f44e                	sd	s3,40(sp)
    80001548:	f052                	sd	s4,32(sp)
    8000154a:	ec56                	sd	s5,24(sp)
    8000154c:	e85a                	sd	s6,16(sp)
    8000154e:	e45e                	sd	s7,8(sp)
    80001550:	0880                	addi	s0,sp,80
    80001552:	8b2a                	mv	s6,a0
    80001554:	8aae                	mv	s5,a1
    80001556:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001558:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000155a:	4601                	li	a2,0
    8000155c:	85ce                	mv	a1,s3
    8000155e:	855a                	mv	a0,s6
    80001560:	00000097          	auipc	ra,0x0
    80001564:	a46080e7          	jalr	-1466(ra) # 80000fa6 <walk>
    80001568:	c531                	beqz	a0,800015b4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000156a:	6118                	ld	a4,0(a0)
    8000156c:	00177793          	andi	a5,a4,1
    80001570:	cbb1                	beqz	a5,800015c4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001572:	00a75593          	srli	a1,a4,0xa
    80001576:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000157a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000157e:	fffff097          	auipc	ra,0xfffff
    80001582:	554080e7          	jalr	1364(ra) # 80000ad2 <kalloc>
    80001586:	892a                	mv	s2,a0
    80001588:	c939                	beqz	a0,800015de <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000158a:	6605                	lui	a2,0x1
    8000158c:	85de                	mv	a1,s7
    8000158e:	fffff097          	auipc	ra,0xfffff
    80001592:	78c080e7          	jalr	1932(ra) # 80000d1a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001596:	8726                	mv	a4,s1
    80001598:	86ca                	mv	a3,s2
    8000159a:	6605                	lui	a2,0x1
    8000159c:	85ce                	mv	a1,s3
    8000159e:	8556                	mv	a0,s5
    800015a0:	00000097          	auipc	ra,0x0
    800015a4:	aee080e7          	jalr	-1298(ra) # 8000108e <mappages>
    800015a8:	e515                	bnez	a0,800015d4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015aa:	6785                	lui	a5,0x1
    800015ac:	99be                	add	s3,s3,a5
    800015ae:	fb49e6e3          	bltu	s3,s4,8000155a <uvmcopy+0x20>
    800015b2:	a081                	j	800015f2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015b4:	00007517          	auipc	a0,0x7
    800015b8:	bbc50513          	addi	a0,a0,-1092 # 80008170 <digits+0x130>
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	f6e080e7          	jalr	-146(ra) # 8000052a <panic>
      panic("uvmcopy: page not present");
    800015c4:	00007517          	auipc	a0,0x7
    800015c8:	bcc50513          	addi	a0,a0,-1076 # 80008190 <digits+0x150>
    800015cc:	fffff097          	auipc	ra,0xfffff
    800015d0:	f5e080e7          	jalr	-162(ra) # 8000052a <panic>
      kfree(mem);
    800015d4:	854a                	mv	a0,s2
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	400080e7          	jalr	1024(ra) # 800009d6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015de:	4685                	li	a3,1
    800015e0:	00c9d613          	srli	a2,s3,0xc
    800015e4:	4581                	li	a1,0
    800015e6:	8556                	mv	a0,s5
    800015e8:	00000097          	auipc	ra,0x0
    800015ec:	c5a080e7          	jalr	-934(ra) # 80001242 <uvmunmap>
  return -1;
    800015f0:	557d                	li	a0,-1
}
    800015f2:	60a6                	ld	ra,72(sp)
    800015f4:	6406                	ld	s0,64(sp)
    800015f6:	74e2                	ld	s1,56(sp)
    800015f8:	7942                	ld	s2,48(sp)
    800015fa:	79a2                	ld	s3,40(sp)
    800015fc:	7a02                	ld	s4,32(sp)
    800015fe:	6ae2                	ld	s5,24(sp)
    80001600:	6b42                	ld	s6,16(sp)
    80001602:	6ba2                	ld	s7,8(sp)
    80001604:	6161                	addi	sp,sp,80
    80001606:	8082                	ret
  return 0;
    80001608:	4501                	li	a0,0
}
    8000160a:	8082                	ret

000000008000160c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000160c:	1141                	addi	sp,sp,-16
    8000160e:	e406                	sd	ra,8(sp)
    80001610:	e022                	sd	s0,0(sp)
    80001612:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001614:	4601                	li	a2,0
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	990080e7          	jalr	-1648(ra) # 80000fa6 <walk>
  if(pte == 0)
    8000161e:	c901                	beqz	a0,8000162e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001620:	611c                	ld	a5,0(a0)
    80001622:	9bbd                	andi	a5,a5,-17
    80001624:	e11c                	sd	a5,0(a0)
}
    80001626:	60a2                	ld	ra,8(sp)
    80001628:	6402                	ld	s0,0(sp)
    8000162a:	0141                	addi	sp,sp,16
    8000162c:	8082                	ret
    panic("uvmclear");
    8000162e:	00007517          	auipc	a0,0x7
    80001632:	b8250513          	addi	a0,a0,-1150 # 800081b0 <digits+0x170>
    80001636:	fffff097          	auipc	ra,0xfffff
    8000163a:	ef4080e7          	jalr	-268(ra) # 8000052a <panic>

000000008000163e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000163e:	c6bd                	beqz	a3,800016ac <copyout+0x6e>
{
    80001640:	715d                	addi	sp,sp,-80
    80001642:	e486                	sd	ra,72(sp)
    80001644:	e0a2                	sd	s0,64(sp)
    80001646:	fc26                	sd	s1,56(sp)
    80001648:	f84a                	sd	s2,48(sp)
    8000164a:	f44e                	sd	s3,40(sp)
    8000164c:	f052                	sd	s4,32(sp)
    8000164e:	ec56                	sd	s5,24(sp)
    80001650:	e85a                	sd	s6,16(sp)
    80001652:	e45e                	sd	s7,8(sp)
    80001654:	e062                	sd	s8,0(sp)
    80001656:	0880                	addi	s0,sp,80
    80001658:	8b2a                	mv	s6,a0
    8000165a:	8c2e                	mv	s8,a1
    8000165c:	8a32                	mv	s4,a2
    8000165e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001660:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001662:	6a85                	lui	s5,0x1
    80001664:	a015                	j	80001688 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001666:	9562                	add	a0,a0,s8
    80001668:	0004861b          	sext.w	a2,s1
    8000166c:	85d2                	mv	a1,s4
    8000166e:	41250533          	sub	a0,a0,s2
    80001672:	fffff097          	auipc	ra,0xfffff
    80001676:	6a8080e7          	jalr	1704(ra) # 80000d1a <memmove>

    len -= n;
    8000167a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000167e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001680:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001684:	02098263          	beqz	s3,800016a8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001688:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000168c:	85ca                	mv	a1,s2
    8000168e:	855a                	mv	a0,s6
    80001690:	00000097          	auipc	ra,0x0
    80001694:	9bc080e7          	jalr	-1604(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001698:	cd01                	beqz	a0,800016b0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000169a:	418904b3          	sub	s1,s2,s8
    8000169e:	94d6                	add	s1,s1,s5
    if(n > len)
    800016a0:	fc99f3e3          	bgeu	s3,s1,80001666 <copyout+0x28>
    800016a4:	84ce                	mv	s1,s3
    800016a6:	b7c1                	j	80001666 <copyout+0x28>
  }
  return 0;
    800016a8:	4501                	li	a0,0
    800016aa:	a021                	j	800016b2 <copyout+0x74>
    800016ac:	4501                	li	a0,0
}
    800016ae:	8082                	ret
      return -1;
    800016b0:	557d                	li	a0,-1
}
    800016b2:	60a6                	ld	ra,72(sp)
    800016b4:	6406                	ld	s0,64(sp)
    800016b6:	74e2                	ld	s1,56(sp)
    800016b8:	7942                	ld	s2,48(sp)
    800016ba:	79a2                	ld	s3,40(sp)
    800016bc:	7a02                	ld	s4,32(sp)
    800016be:	6ae2                	ld	s5,24(sp)
    800016c0:	6b42                	ld	s6,16(sp)
    800016c2:	6ba2                	ld	s7,8(sp)
    800016c4:	6c02                	ld	s8,0(sp)
    800016c6:	6161                	addi	sp,sp,80
    800016c8:	8082                	ret

00000000800016ca <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016ca:	caa5                	beqz	a3,8000173a <copyin+0x70>
{
    800016cc:	715d                	addi	sp,sp,-80
    800016ce:	e486                	sd	ra,72(sp)
    800016d0:	e0a2                	sd	s0,64(sp)
    800016d2:	fc26                	sd	s1,56(sp)
    800016d4:	f84a                	sd	s2,48(sp)
    800016d6:	f44e                	sd	s3,40(sp)
    800016d8:	f052                	sd	s4,32(sp)
    800016da:	ec56                	sd	s5,24(sp)
    800016dc:	e85a                	sd	s6,16(sp)
    800016de:	e45e                	sd	s7,8(sp)
    800016e0:	e062                	sd	s8,0(sp)
    800016e2:	0880                	addi	s0,sp,80
    800016e4:	8b2a                	mv	s6,a0
    800016e6:	8a2e                	mv	s4,a1
    800016e8:	8c32                	mv	s8,a2
    800016ea:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800016ec:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016ee:	6a85                	lui	s5,0x1
    800016f0:	a01d                	j	80001716 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800016f2:	018505b3          	add	a1,a0,s8
    800016f6:	0004861b          	sext.w	a2,s1
    800016fa:	412585b3          	sub	a1,a1,s2
    800016fe:	8552                	mv	a0,s4
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	61a080e7          	jalr	1562(ra) # 80000d1a <memmove>

    len -= n;
    80001708:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000170c:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000170e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001712:	02098263          	beqz	s3,80001736 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001716:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000171a:	85ca                	mv	a1,s2
    8000171c:	855a                	mv	a0,s6
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	92e080e7          	jalr	-1746(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    80001726:	cd01                	beqz	a0,8000173e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001728:	418904b3          	sub	s1,s2,s8
    8000172c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000172e:	fc99f2e3          	bgeu	s3,s1,800016f2 <copyin+0x28>
    80001732:	84ce                	mv	s1,s3
    80001734:	bf7d                	j	800016f2 <copyin+0x28>
  }
  return 0;
    80001736:	4501                	li	a0,0
    80001738:	a021                	j	80001740 <copyin+0x76>
    8000173a:	4501                	li	a0,0
}
    8000173c:	8082                	ret
      return -1;
    8000173e:	557d                	li	a0,-1
}
    80001740:	60a6                	ld	ra,72(sp)
    80001742:	6406                	ld	s0,64(sp)
    80001744:	74e2                	ld	s1,56(sp)
    80001746:	7942                	ld	s2,48(sp)
    80001748:	79a2                	ld	s3,40(sp)
    8000174a:	7a02                	ld	s4,32(sp)
    8000174c:	6ae2                	ld	s5,24(sp)
    8000174e:	6b42                	ld	s6,16(sp)
    80001750:	6ba2                	ld	s7,8(sp)
    80001752:	6c02                	ld	s8,0(sp)
    80001754:	6161                	addi	sp,sp,80
    80001756:	8082                	ret

0000000080001758 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001758:	c6c5                	beqz	a3,80001800 <copyinstr+0xa8>
{
    8000175a:	715d                	addi	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	0880                	addi	s0,sp,80
    80001770:	8a2a                	mv	s4,a0
    80001772:	8b2e                	mv	s6,a1
    80001774:	8bb2                	mv	s7,a2
    80001776:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001778:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177a:	6985                	lui	s3,0x1
    8000177c:	a035                	j	800017a8 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000177e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001782:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001784:	0017b793          	seqz	a5,a5
    80001788:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000178c:	60a6                	ld	ra,72(sp)
    8000178e:	6406                	ld	s0,64(sp)
    80001790:	74e2                	ld	s1,56(sp)
    80001792:	7942                	ld	s2,48(sp)
    80001794:	79a2                	ld	s3,40(sp)
    80001796:	7a02                	ld	s4,32(sp)
    80001798:	6ae2                	ld	s5,24(sp)
    8000179a:	6b42                	ld	s6,16(sp)
    8000179c:	6ba2                	ld	s7,8(sp)
    8000179e:	6161                	addi	sp,sp,80
    800017a0:	8082                	ret
    srcva = va0 + PGSIZE;
    800017a2:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017a6:	c8a9                	beqz	s1,800017f8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017a8:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ac:	85ca                	mv	a1,s2
    800017ae:	8552                	mv	a0,s4
    800017b0:	00000097          	auipc	ra,0x0
    800017b4:	89c080e7          	jalr	-1892(ra) # 8000104c <walkaddr>
    if(pa0 == 0)
    800017b8:	c131                	beqz	a0,800017fc <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017ba:	41790833          	sub	a6,s2,s7
    800017be:	984e                	add	a6,a6,s3
    if(n > max)
    800017c0:	0104f363          	bgeu	s1,a6,800017c6 <copyinstr+0x6e>
    800017c4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017c6:	955e                	add	a0,a0,s7
    800017c8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017cc:	fc080be3          	beqz	a6,800017a2 <copyinstr+0x4a>
    800017d0:	985a                	add	a6,a6,s6
    800017d2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017d4:	41650633          	sub	a2,a0,s6
    800017d8:	14fd                	addi	s1,s1,-1
    800017da:	9b26                	add	s6,s6,s1
    800017dc:	00f60733          	add	a4,a2,a5
    800017e0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800017e4:	df49                	beqz	a4,8000177e <copyinstr+0x26>
        *dst = *p;
    800017e6:	00e78023          	sb	a4,0(a5)
      --max;
    800017ea:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800017ee:	0785                	addi	a5,a5,1
    while(n > 0){
    800017f0:	ff0796e3          	bne	a5,a6,800017dc <copyinstr+0x84>
      dst++;
    800017f4:	8b42                	mv	s6,a6
    800017f6:	b775                	j	800017a2 <copyinstr+0x4a>
    800017f8:	4781                	li	a5,0
    800017fa:	b769                	j	80001784 <copyinstr+0x2c>
      return -1;
    800017fc:	557d                	li	a0,-1
    800017fe:	b779                	j	8000178c <copyinstr+0x34>
  int got_null = 0;
    80001800:	4781                	li	a5,0
  if(got_null){
    80001802:	0017b793          	seqz	a5,a5
    80001806:	40f00533          	neg	a0,a5
}
    8000180a:	8082                	ret

000000008000180c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000180c:	7139                	addi	sp,sp,-64
    8000180e:	fc06                	sd	ra,56(sp)
    80001810:	f822                	sd	s0,48(sp)
    80001812:	f426                	sd	s1,40(sp)
    80001814:	f04a                	sd	s2,32(sp)
    80001816:	ec4e                	sd	s3,24(sp)
    80001818:	e852                	sd	s4,16(sp)
    8000181a:	e456                	sd	s5,8(sp)
    8000181c:	e05a                	sd	s6,0(sp)
    8000181e:	0080                	addi	s0,sp,64
    80001820:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001822:	00010497          	auipc	s1,0x10
    80001826:	ec648493          	addi	s1,s1,-314 # 800116e8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000182a:	8b26                	mv	s6,s1
    8000182c:	00006a97          	auipc	s5,0x6
    80001830:	7d4a8a93          	addi	s5,s5,2004 # 80008000 <etext>
    80001834:	04000937          	lui	s2,0x4000
    80001838:	197d                	addi	s2,s2,-1
    8000183a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183c:	00016a17          	auipc	s4,0x16
    80001840:	2aca0a13          	addi	s4,s4,684 # 80017ae8 <tickslock>
    char *pa = kalloc();
    80001844:	fffff097          	auipc	ra,0xfffff
    80001848:	28e080e7          	jalr	654(ra) # 80000ad2 <kalloc>
    8000184c:	862a                	mv	a2,a0
    if(pa == 0)
    8000184e:	c131                	beqz	a0,80001892 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001850:	416485b3          	sub	a1,s1,s6
    80001854:	8591                	srai	a1,a1,0x4
    80001856:	000ab783          	ld	a5,0(s5)
    8000185a:	02f585b3          	mul	a1,a1,a5
    8000185e:	2585                	addiw	a1,a1,1
    80001860:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001864:	4719                	li	a4,6
    80001866:	6685                	lui	a3,0x1
    80001868:	40b905b3          	sub	a1,s2,a1
    8000186c:	854e                	mv	a0,s3
    8000186e:	00000097          	auipc	ra,0x0
    80001872:	8ae080e7          	jalr	-1874(ra) # 8000111c <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001876:	19048493          	addi	s1,s1,400
    8000187a:	fd4495e3          	bne	s1,s4,80001844 <proc_mapstacks+0x38>
  }
}
    8000187e:	70e2                	ld	ra,56(sp)
    80001880:	7442                	ld	s0,48(sp)
    80001882:	74a2                	ld	s1,40(sp)
    80001884:	7902                	ld	s2,32(sp)
    80001886:	69e2                	ld	s3,24(sp)
    80001888:	6a42                	ld	s4,16(sp)
    8000188a:	6aa2                	ld	s5,8(sp)
    8000188c:	6b02                	ld	s6,0(sp)
    8000188e:	6121                	addi	sp,sp,64
    80001890:	8082                	ret
      panic("kalloc");
    80001892:	00007517          	auipc	a0,0x7
    80001896:	92e50513          	addi	a0,a0,-1746 # 800081c0 <digits+0x180>
    8000189a:	fffff097          	auipc	ra,0xfffff
    8000189e:	c90080e7          	jalr	-880(ra) # 8000052a <panic>

00000000800018a2 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018a2:	7139                	addi	sp,sp,-64
    800018a4:	fc06                	sd	ra,56(sp)
    800018a6:	f822                	sd	s0,48(sp)
    800018a8:	f426                	sd	s1,40(sp)
    800018aa:	f04a                	sd	s2,32(sp)
    800018ac:	ec4e                	sd	s3,24(sp)
    800018ae:	e852                	sd	s4,16(sp)
    800018b0:	e456                	sd	s5,8(sp)
    800018b2:	e05a                	sd	s6,0(sp)
    800018b4:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018b6:	00007597          	auipc	a1,0x7
    800018ba:	91258593          	addi	a1,a1,-1774 # 800081c8 <digits+0x188>
    800018be:	00010517          	auipc	a0,0x10
    800018c2:	9e250513          	addi	a0,a0,-1566 # 800112a0 <pid_lock>
    800018c6:	fffff097          	auipc	ra,0xfffff
    800018ca:	26c080e7          	jalr	620(ra) # 80000b32 <initlock>
  initlock(&place_lock, "placepid"); // our code
    800018ce:	00007597          	auipc	a1,0x7
    800018d2:	90258593          	addi	a1,a1,-1790 # 800081d0 <digits+0x190>
    800018d6:	00010517          	auipc	a0,0x10
    800018da:	9e250513          	addi	a0,a0,-1566 # 800112b8 <place_lock>
    800018de:	fffff097          	auipc	ra,0xfffff
    800018e2:	254080e7          	jalr	596(ra) # 80000b32 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018e6:	00007597          	auipc	a1,0x7
    800018ea:	8fa58593          	addi	a1,a1,-1798 # 800081e0 <digits+0x1a0>
    800018ee:	00010517          	auipc	a0,0x10
    800018f2:	9e250513          	addi	a0,a0,-1566 # 800112d0 <wait_lock>
    800018f6:	fffff097          	auipc	ra,0xfffff
    800018fa:	23c080e7          	jalr	572(ra) # 80000b32 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018fe:	00010497          	auipc	s1,0x10
    80001902:	dea48493          	addi	s1,s1,-534 # 800116e8 <proc>
      initlock(&p->lock, "proc");
    80001906:	00007b17          	auipc	s6,0x7
    8000190a:	8eab0b13          	addi	s6,s6,-1814 # 800081f0 <digits+0x1b0>
      p->kstack = KSTACK((int) (p - proc));
    8000190e:	8aa6                	mv	s5,s1
    80001910:	00006a17          	auipc	s4,0x6
    80001914:	6f0a0a13          	addi	s4,s4,1776 # 80008000 <etext>
    80001918:	04000937          	lui	s2,0x4000
    8000191c:	197d                	addi	s2,s2,-1
    8000191e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001920:	00016997          	auipc	s3,0x16
    80001924:	1c898993          	addi	s3,s3,456 # 80017ae8 <tickslock>
      initlock(&p->lock, "proc");
    80001928:	85da                	mv	a1,s6
    8000192a:	8526                	mv	a0,s1
    8000192c:	fffff097          	auipc	ra,0xfffff
    80001930:	206080e7          	jalr	518(ra) # 80000b32 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001934:	415487b3          	sub	a5,s1,s5
    80001938:	8791                	srai	a5,a5,0x4
    8000193a:	000a3703          	ld	a4,0(s4)
    8000193e:	02e787b3          	mul	a5,a5,a4
    80001942:	2785                	addiw	a5,a5,1
    80001944:	00d7979b          	slliw	a5,a5,0xd
    80001948:	40f907b3          	sub	a5,s2,a5
    8000194c:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	19048493          	addi	s1,s1,400
    80001952:	fd349be3          	bne	s1,s3,80001928 <procinit+0x86>
  }
}
    80001956:	70e2                	ld	ra,56(sp)
    80001958:	7442                	ld	s0,48(sp)
    8000195a:	74a2                	ld	s1,40(sp)
    8000195c:	7902                	ld	s2,32(sp)
    8000195e:	69e2                	ld	s3,24(sp)
    80001960:	6a42                	ld	s4,16(sp)
    80001962:	6aa2                	ld	s5,8(sp)
    80001964:	6b02                	ld	s6,0(sp)
    80001966:	6121                	addi	sp,sp,64
    80001968:	8082                	ret

000000008000196a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000196a:	1141                	addi	sp,sp,-16
    8000196c:	e422                	sd	s0,8(sp)
    8000196e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001970:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001972:	2501                	sext.w	a0,a0
    80001974:	6422                	ld	s0,8(sp)
    80001976:	0141                	addi	sp,sp,16
    80001978:	8082                	ret

000000008000197a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
    80001980:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001982:	2781                	sext.w	a5,a5
    80001984:	079e                	slli	a5,a5,0x7
  return c;
}
    80001986:	00010517          	auipc	a0,0x10
    8000198a:	96250513          	addi	a0,a0,-1694 # 800112e8 <cpus>
    8000198e:	953e                	add	a0,a0,a5
    80001990:	6422                	ld	s0,8(sp)
    80001992:	0141                	addi	sp,sp,16
    80001994:	8082                	ret

0000000080001996 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001996:	1101                	addi	sp,sp,-32
    80001998:	ec06                	sd	ra,24(sp)
    8000199a:	e822                	sd	s0,16(sp)
    8000199c:	e426                	sd	s1,8(sp)
    8000199e:	1000                	addi	s0,sp,32
  push_off();
    800019a0:	fffff097          	auipc	ra,0xfffff
    800019a4:	1d6080e7          	jalr	470(ra) # 80000b76 <push_off>
    800019a8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019aa:	2781                	sext.w	a5,a5
    800019ac:	079e                	slli	a5,a5,0x7
    800019ae:	00010717          	auipc	a4,0x10
    800019b2:	8f270713          	addi	a4,a4,-1806 # 800112a0 <pid_lock>
    800019b6:	97ba                	add	a5,a5,a4
    800019b8:	67a4                	ld	s1,72(a5)
  pop_off();
    800019ba:	fffff097          	auipc	ra,0xfffff
    800019be:	25c080e7          	jalr	604(ra) # 80000c16 <pop_off>
  return p;
}
    800019c2:	8526                	mv	a0,s1
    800019c4:	60e2                	ld	ra,24(sp)
    800019c6:	6442                	ld	s0,16(sp)
    800019c8:	64a2                	ld	s1,8(sp)
    800019ca:	6105                	addi	sp,sp,32
    800019cc:	8082                	ret

00000000800019ce <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019ce:	1141                	addi	sp,sp,-16
    800019d0:	e406                	sd	ra,8(sp)
    800019d2:	e022                	sd	s0,0(sp)
    800019d4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019d6:	00000097          	auipc	ra,0x0
    800019da:	fc0080e7          	jalr	-64(ra) # 80001996 <myproc>
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	298080e7          	jalr	664(ra) # 80000c76 <release>

  if (first) {
    800019e6:	00007797          	auipc	a5,0x7
    800019ea:	01a7a783          	lw	a5,26(a5) # 80008a00 <first.1>
    800019ee:	eb89                	bnez	a5,80001a00 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f0:	00001097          	auipc	ra,0x1
    800019f4:	16e080e7          	jalr	366(ra) # 80002b5e <usertrapret>
}
    800019f8:	60a2                	ld	ra,8(sp)
    800019fa:	6402                	ld	s0,0(sp)
    800019fc:	0141                	addi	sp,sp,16
    800019fe:	8082                	ret
    first = 0;
    80001a00:	00007797          	auipc	a5,0x7
    80001a04:	0007a023          	sw	zero,0(a5) # 80008a00 <first.1>
    fsinit(ROOTDEV);
    80001a08:	4505                	li	a0,1
    80001a0a:	00002097          	auipc	ra,0x2
    80001a0e:	000080e7          	jalr	ra # 80003a0a <fsinit>
    80001a12:	bff9                	j	800019f0 <forkret+0x22>

0000000080001a14 <allocpid>:
allocpid() {
    80001a14:	1101                	addi	sp,sp,-32
    80001a16:	ec06                	sd	ra,24(sp)
    80001a18:	e822                	sd	s0,16(sp)
    80001a1a:	e426                	sd	s1,8(sp)
    80001a1c:	e04a                	sd	s2,0(sp)
    80001a1e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a20:	00010917          	auipc	s2,0x10
    80001a24:	88090913          	addi	s2,s2,-1920 # 800112a0 <pid_lock>
    80001a28:	854a                	mv	a0,s2
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	198080e7          	jalr	408(ra) # 80000bc2 <acquire>
  pid = nextpid;
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	fd678793          	addi	a5,a5,-42 # 80008a08 <nextpid>
    80001a3a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3c:	0014871b          	addiw	a4,s1,1
    80001a40:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a42:	854a                	mv	a0,s2
    80001a44:	fffff097          	auipc	ra,0xfffff
    80001a48:	232080e7          	jalr	562(ra) # 80000c76 <release>
}
    80001a4c:	8526                	mv	a0,s1
    80001a4e:	60e2                	ld	ra,24(sp)
    80001a50:	6442                	ld	s0,16(sp)
    80001a52:	64a2                	ld	s1,8(sp)
    80001a54:	6902                	ld	s2,0(sp)
    80001a56:	6105                	addi	sp,sp,32
    80001a58:	8082                	ret

0000000080001a5a <allocplace>:
allocplace() { 
    80001a5a:	1101                	addi	sp,sp,-32
    80001a5c:	ec06                	sd	ra,24(sp)
    80001a5e:	e822                	sd	s0,16(sp)
    80001a60:	e426                	sd	s1,8(sp)
    80001a62:	e04a                	sd	s2,0(sp)
    80001a64:	1000                	addi	s0,sp,32
  acquire(&place_lock);
    80001a66:	00010917          	auipc	s2,0x10
    80001a6a:	85290913          	addi	s2,s2,-1966 # 800112b8 <place_lock>
    80001a6e:	854a                	mv	a0,s2
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	152080e7          	jalr	338(ra) # 80000bc2 <acquire>
  place = nextplace;
    80001a78:	00007797          	auipc	a5,0x7
    80001a7c:	f8c78793          	addi	a5,a5,-116 # 80008a04 <nextplace>
    80001a80:	4384                	lw	s1,0(a5)
  nextplace = nextplace + 1;
    80001a82:	0014871b          	addiw	a4,s1,1
    80001a86:	c398                	sw	a4,0(a5)
  release(&place_lock);
    80001a88:	854a                	mv	a0,s2
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	1ec080e7          	jalr	492(ra) # 80000c76 <release>
}
    80001a92:	8526                	mv	a0,s1
    80001a94:	60e2                	ld	ra,24(sp)
    80001a96:	6442                	ld	s0,16(sp)
    80001a98:	64a2                	ld	s1,8(sp)
    80001a9a:	6902                	ld	s2,0(sp)
    80001a9c:	6105                	addi	sp,sp,32
    80001a9e:	8082                	ret

0000000080001aa0 <proc_pagetable>:
{
    80001aa0:	1101                	addi	sp,sp,-32
    80001aa2:	ec06                	sd	ra,24(sp)
    80001aa4:	e822                	sd	s0,16(sp)
    80001aa6:	e426                	sd	s1,8(sp)
    80001aa8:	e04a                	sd	s2,0(sp)
    80001aaa:	1000                	addi	s0,sp,32
    80001aac:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aae:	00000097          	auipc	ra,0x0
    80001ab2:	858080e7          	jalr	-1960(ra) # 80001306 <uvmcreate>
    80001ab6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ab8:	c121                	beqz	a0,80001af8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001aba:	4729                	li	a4,10
    80001abc:	00005697          	auipc	a3,0x5
    80001ac0:	54468693          	addi	a3,a3,1348 # 80007000 <_trampoline>
    80001ac4:	6605                	lui	a2,0x1
    80001ac6:	040005b7          	lui	a1,0x4000
    80001aca:	15fd                	addi	a1,a1,-1
    80001acc:	05b2                	slli	a1,a1,0xc
    80001ace:	fffff097          	auipc	ra,0xfffff
    80001ad2:	5c0080e7          	jalr	1472(ra) # 8000108e <mappages>
    80001ad6:	02054863          	bltz	a0,80001b06 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ada:	4719                	li	a4,6
    80001adc:	06093683          	ld	a3,96(s2)
    80001ae0:	6605                	lui	a2,0x1
    80001ae2:	020005b7          	lui	a1,0x2000
    80001ae6:	15fd                	addi	a1,a1,-1
    80001ae8:	05b6                	slli	a1,a1,0xd
    80001aea:	8526                	mv	a0,s1
    80001aec:	fffff097          	auipc	ra,0xfffff
    80001af0:	5a2080e7          	jalr	1442(ra) # 8000108e <mappages>
    80001af4:	02054163          	bltz	a0,80001b16 <proc_pagetable+0x76>
}
    80001af8:	8526                	mv	a0,s1
    80001afa:	60e2                	ld	ra,24(sp)
    80001afc:	6442                	ld	s0,16(sp)
    80001afe:	64a2                	ld	s1,8(sp)
    80001b00:	6902                	ld	s2,0(sp)
    80001b02:	6105                	addi	sp,sp,32
    80001b04:	8082                	ret
    uvmfree(pagetable, 0);
    80001b06:	4581                	li	a1,0
    80001b08:	8526                	mv	a0,s1
    80001b0a:	00000097          	auipc	ra,0x0
    80001b0e:	9f8080e7          	jalr	-1544(ra) # 80001502 <uvmfree>
    return 0;
    80001b12:	4481                	li	s1,0
    80001b14:	b7d5                	j	80001af8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	addi	a1,a1,-1
    80001b20:	05b2                	slli	a1,a1,0xc
    80001b22:	8526                	mv	a0,s1
    80001b24:	fffff097          	auipc	ra,0xfffff
    80001b28:	71e080e7          	jalr	1822(ra) # 80001242 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b2c:	4581                	li	a1,0
    80001b2e:	8526                	mv	a0,s1
    80001b30:	00000097          	auipc	ra,0x0
    80001b34:	9d2080e7          	jalr	-1582(ra) # 80001502 <uvmfree>
    return 0;
    80001b38:	4481                	li	s1,0
    80001b3a:	bf7d                	j	80001af8 <proc_pagetable+0x58>

0000000080001b3c <proc_freepagetable>:
{
    80001b3c:	1101                	addi	sp,sp,-32
    80001b3e:	ec06                	sd	ra,24(sp)
    80001b40:	e822                	sd	s0,16(sp)
    80001b42:	e426                	sd	s1,8(sp)
    80001b44:	e04a                	sd	s2,0(sp)
    80001b46:	1000                	addi	s0,sp,32
    80001b48:	84aa                	mv	s1,a0
    80001b4a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b4c:	4681                	li	a3,0
    80001b4e:	4605                	li	a2,1
    80001b50:	040005b7          	lui	a1,0x4000
    80001b54:	15fd                	addi	a1,a1,-1
    80001b56:	05b2                	slli	a1,a1,0xc
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	6ea080e7          	jalr	1770(ra) # 80001242 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b60:	4681                	li	a3,0
    80001b62:	4605                	li	a2,1
    80001b64:	020005b7          	lui	a1,0x2000
    80001b68:	15fd                	addi	a1,a1,-1
    80001b6a:	05b6                	slli	a1,a1,0xd
    80001b6c:	8526                	mv	a0,s1
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	6d4080e7          	jalr	1748(ra) # 80001242 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b76:	85ca                	mv	a1,s2
    80001b78:	8526                	mv	a0,s1
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	988080e7          	jalr	-1656(ra) # 80001502 <uvmfree>
}
    80001b82:	60e2                	ld	ra,24(sp)
    80001b84:	6442                	ld	s0,16(sp)
    80001b86:	64a2                	ld	s1,8(sp)
    80001b88:	6902                	ld	s2,0(sp)
    80001b8a:	6105                	addi	sp,sp,32
    80001b8c:	8082                	ret

0000000080001b8e <freeproc>:
{
    80001b8e:	1101                	addi	sp,sp,-32
    80001b90:	ec06                	sd	ra,24(sp)
    80001b92:	e822                	sd	s0,16(sp)
    80001b94:	e426                	sd	s1,8(sp)
    80001b96:	1000                	addi	s0,sp,32
    80001b98:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b9a:	7128                	ld	a0,96(a0)
    80001b9c:	c509                	beqz	a0,80001ba6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	e38080e7          	jalr	-456(ra) # 800009d6 <kfree>
  p->trapframe = 0;
    80001ba6:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001baa:	6ca8                	ld	a0,88(s1)
    80001bac:	c511                	beqz	a0,80001bb8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bae:	68ac                	ld	a1,80(s1)
    80001bb0:	00000097          	auipc	ra,0x0
    80001bb4:	f8c080e7          	jalr	-116(ra) # 80001b3c <proc_freepagetable>
  p->pagetable = 0;
    80001bb8:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001bbc:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001bc0:	0204a823          	sw	zero,48(s1)
  p->place = 0;
    80001bc4:	1804a623          	sw	zero,396(s1)
  p->parent = 0;
    80001bc8:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001bcc:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001bd0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bd4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bd8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bdc:	0004ac23          	sw	zero,24(s1)
  if(p->ttime==-1){ //the process termination time is still the same as in the creation (was never changed)
    80001be0:	1744a703          	lw	a4,372(s1)
    80001be4:	57fd                	li	a5,-1
    80001be6:	00f70763          	beq	a4,a5,80001bf4 <freeproc+0x66>
}
    80001bea:	60e2                	ld	ra,24(sp)
    80001bec:	6442                	ld	s0,16(sp)
    80001bee:	64a2                	ld	s1,8(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret
    acquire(&tickslock);
    80001bf4:	00016517          	auipc	a0,0x16
    80001bf8:	ef450513          	addi	a0,a0,-268 # 80017ae8 <tickslock>
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	fc6080e7          	jalr	-58(ra) # 80000bc2 <acquire>
    p->ttime=ticks;
    80001c04:	00007797          	auipc	a5,0x7
    80001c08:	42c7a783          	lw	a5,1068(a5) # 80009030 <ticks>
    80001c0c:	16f4aa23          	sw	a5,372(s1)
    p->average_bursttime= ALPHA*p->B_current_burst_length+(100-ALPHA)*p->average_bursttime/100;
    80001c10:	1884a703          	lw	a4,392(s1)
    80001c14:	03200793          	li	a5,50
    80001c18:	02e787bb          	mulw	a5,a5,a4
    80001c1c:	1844a683          	lw	a3,388(s1)
    80001c20:	01f6d71b          	srliw	a4,a3,0x1f
    80001c24:	9f35                	addw	a4,a4,a3
    80001c26:	4017571b          	sraiw	a4,a4,0x1
    80001c2a:	9fb9                	addw	a5,a5,a4
    80001c2c:	18f4a223          	sw	a5,388(s1)
    p->B_current_burst_length=0;
    80001c30:	1804a423          	sw	zero,392(s1)
    release(&tickslock);
    80001c34:	00016517          	auipc	a0,0x16
    80001c38:	eb450513          	addi	a0,a0,-332 # 80017ae8 <tickslock>
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	03a080e7          	jalr	58(ra) # 80000c76 <release>
}
    80001c44:	b75d                	j	80001bea <freeproc+0x5c>

0000000080001c46 <allocproc>:
{
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	e04a                	sd	s2,0(sp)
    80001c50:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c52:	00010497          	auipc	s1,0x10
    80001c56:	a9648493          	addi	s1,s1,-1386 # 800116e8 <proc>
    80001c5a:	00016917          	auipc	s2,0x16
    80001c5e:	e8e90913          	addi	s2,s2,-370 # 80017ae8 <tickslock>
    acquire(&p->lock);
    80001c62:	8526                	mv	a0,s1
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	f5e080e7          	jalr	-162(ra) # 80000bc2 <acquire>
    if(p->state == UNUSED) {
    80001c6c:	4c9c                	lw	a5,24(s1)
    80001c6e:	cf81                	beqz	a5,80001c86 <allocproc+0x40>
      release(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	004080e7          	jalr	4(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c7a:	19048493          	addi	s1,s1,400
    80001c7e:	ff2492e3          	bne	s1,s2,80001c62 <allocproc+0x1c>
  return 0;
    80001c82:	4481                	li	s1,0
    80001c84:	a065                	j	80001d2c <allocproc+0xe6>
  p->pid = allocpid();
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	d8e080e7          	jalr	-626(ra) # 80001a14 <allocpid>
    80001c8e:	d888                	sw	a0,48(s1)
  p->place = allocplace(); 
    80001c90:	00000097          	auipc	ra,0x0
    80001c94:	dca080e7          	jalr	-566(ra) # 80001a5a <allocplace>
    80001c98:	18a4a623          	sw	a0,396(s1)
  p->state = USED;
    80001c9c:	4785                	li	a5,1
    80001c9e:	cc9c                	sw	a5,24(s1)
  acquire(&tickslock);
    80001ca0:	00016517          	auipc	a0,0x16
    80001ca4:	e4850513          	addi	a0,a0,-440 # 80017ae8 <tickslock>
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	f1a080e7          	jalr	-230(ra) # 80000bc2 <acquire>
  p->ctime=ticks; 
    80001cb0:	00007797          	auipc	a5,0x7
    80001cb4:	3807a783          	lw	a5,896(a5) # 80009030 <ticks>
    80001cb8:	16f4a823          	sw	a5,368(s1)
  release(&tickslock);
    80001cbc:	00016517          	auipc	a0,0x16
    80001cc0:	e2c50513          	addi	a0,a0,-468 # 80017ae8 <tickslock>
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	fb2080e7          	jalr	-78(ra) # 80000c76 <release>
  p->stime=0;
    80001ccc:	1604ac23          	sw	zero,376(s1)
  p->retime=0;
    80001cd0:	1604ae23          	sw	zero,380(s1)
  p->rutime=0;
    80001cd4:	1804a023          	sw	zero,384(s1)
  p->ttime=-1;
    80001cd8:	57fd                	li	a5,-1
    80001cda:	16f4aa23          	sw	a5,372(s1)
  p->B_current_burst_length=0;
    80001cde:	1804a423          	sw	zero,392(s1)
  p->average_bursttime= QUANTUM*100;
    80001ce2:	1f400793          	li	a5,500
    80001ce6:	18f4a223          	sw	a5,388(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	de8080e7          	jalr	-536(ra) # 80000ad2 <kalloc>
    80001cf2:	892a                	mv	s2,a0
    80001cf4:	f0a8                	sd	a0,96(s1)
    80001cf6:	c131                	beqz	a0,80001d3a <allocproc+0xf4>
  p->pagetable = proc_pagetable(p);
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	00000097          	auipc	ra,0x0
    80001cfe:	da6080e7          	jalr	-602(ra) # 80001aa0 <proc_pagetable>
    80001d02:	892a                	mv	s2,a0
    80001d04:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001d06:	c531                	beqz	a0,80001d52 <allocproc+0x10c>
  memset(&p->context, 0, sizeof(p->context));
    80001d08:	07000613          	li	a2,112
    80001d0c:	4581                	li	a1,0
    80001d0e:	06848513          	addi	a0,s1,104
    80001d12:	fffff097          	auipc	ra,0xfffff
    80001d16:	fac080e7          	jalr	-84(ra) # 80000cbe <memset>
  p->context.ra = (uint64)forkret;
    80001d1a:	00000797          	auipc	a5,0x0
    80001d1e:	cb478793          	addi	a5,a5,-844 # 800019ce <forkret>
    80001d22:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d24:	64bc                	ld	a5,72(s1)
    80001d26:	6705                	lui	a4,0x1
    80001d28:	97ba                	add	a5,a5,a4
    80001d2a:	f8bc                	sd	a5,112(s1)
}
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	60e2                	ld	ra,24(sp)
    80001d30:	6442                	ld	s0,16(sp)
    80001d32:	64a2                	ld	s1,8(sp)
    80001d34:	6902                	ld	s2,0(sp)
    80001d36:	6105                	addi	sp,sp,32
    80001d38:	8082                	ret
    freeproc(p);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	00000097          	auipc	ra,0x0
    80001d40:	e52080e7          	jalr	-430(ra) # 80001b8e <freeproc>
    release(&p->lock);
    80001d44:	8526                	mv	a0,s1
    80001d46:	fffff097          	auipc	ra,0xfffff
    80001d4a:	f30080e7          	jalr	-208(ra) # 80000c76 <release>
    return 0;
    80001d4e:	84ca                	mv	s1,s2
    80001d50:	bff1                	j	80001d2c <allocproc+0xe6>
    freeproc(p);
    80001d52:	8526                	mv	a0,s1
    80001d54:	00000097          	auipc	ra,0x0
    80001d58:	e3a080e7          	jalr	-454(ra) # 80001b8e <freeproc>
    release(&p->lock);
    80001d5c:	8526                	mv	a0,s1
    80001d5e:	fffff097          	auipc	ra,0xfffff
    80001d62:	f18080e7          	jalr	-232(ra) # 80000c76 <release>
    return 0;
    80001d66:	84ca                	mv	s1,s2
    80001d68:	b7d1                	j	80001d2c <allocproc+0xe6>

0000000080001d6a <userinit>:
{
    80001d6a:	1101                	addi	sp,sp,-32
    80001d6c:	ec06                	sd	ra,24(sp)
    80001d6e:	e822                	sd	s0,16(sp)
    80001d70:	e426                	sd	s1,8(sp)
    80001d72:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	ed2080e7          	jalr	-302(ra) # 80001c46 <allocproc>
    80001d7c:	84aa                	mv	s1,a0
  initproc = p;
    80001d7e:	00007797          	auipc	a5,0x7
    80001d82:	2aa7b523          	sd	a0,682(a5) # 80009028 <initproc>
  p->decay_factor=5;
    80001d86:	4795                	li	a5,5
    80001d88:	dd1c                	sw	a5,56(a0)
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d8a:	03400613          	li	a2,52
    80001d8e:	00007597          	auipc	a1,0x7
    80001d92:	c8258593          	addi	a1,a1,-894 # 80008a10 <initcode>
    80001d96:	6d28                	ld	a0,88(a0)
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	59c080e7          	jalr	1436(ra) # 80001334 <uvminit>
  p->sz = PGSIZE;
    80001da0:	6785                	lui	a5,0x1
    80001da2:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001da4:	70b8                	ld	a4,96(s1)
    80001da6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001daa:	70b8                	ld	a4,96(s1)
    80001dac:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001dae:	4641                	li	a2,16
    80001db0:	00006597          	auipc	a1,0x6
    80001db4:	44858593          	addi	a1,a1,1096 # 800081f8 <digits+0x1b8>
    80001db8:	16048513          	addi	a0,s1,352
    80001dbc:	fffff097          	auipc	ra,0xfffff
    80001dc0:	054080e7          	jalr	84(ra) # 80000e10 <safestrcpy>
  p->cwd = namei("/");
    80001dc4:	00006517          	auipc	a0,0x6
    80001dc8:	44450513          	addi	a0,a0,1092 # 80008208 <digits+0x1c8>
    80001dcc:	00002097          	auipc	ra,0x2
    80001dd0:	66c080e7          	jalr	1644(ra) # 80004438 <namei>
    80001dd4:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001dd8:	478d                	li	a5,3
    80001dda:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ddc:	8526                	mv	a0,s1
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	e98080e7          	jalr	-360(ra) # 80000c76 <release>
}
    80001de6:	60e2                	ld	ra,24(sp)
    80001de8:	6442                	ld	s0,16(sp)
    80001dea:	64a2                	ld	s1,8(sp)
    80001dec:	6105                	addi	sp,sp,32
    80001dee:	8082                	ret

0000000080001df0 <growproc>:
{
    80001df0:	1101                	addi	sp,sp,-32
    80001df2:	ec06                	sd	ra,24(sp)
    80001df4:	e822                	sd	s0,16(sp)
    80001df6:	e426                	sd	s1,8(sp)
    80001df8:	e04a                	sd	s2,0(sp)
    80001dfa:	1000                	addi	s0,sp,32
    80001dfc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dfe:	00000097          	auipc	ra,0x0
    80001e02:	b98080e7          	jalr	-1128(ra) # 80001996 <myproc>
    80001e06:	892a                	mv	s2,a0
  sz = p->sz;
    80001e08:	692c                	ld	a1,80(a0)
    80001e0a:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e0e:	00904f63          	bgtz	s1,80001e2c <growproc+0x3c>
  } else if(n < 0){
    80001e12:	0204cc63          	bltz	s1,80001e4a <growproc+0x5a>
  p->sz = sz;
    80001e16:	1602                	slli	a2,a2,0x20
    80001e18:	9201                	srli	a2,a2,0x20
    80001e1a:	04c93823          	sd	a2,80(s2)
  return 0;
    80001e1e:	4501                	li	a0,0
}
    80001e20:	60e2                	ld	ra,24(sp)
    80001e22:	6442                	ld	s0,16(sp)
    80001e24:	64a2                	ld	s1,8(sp)
    80001e26:	6902                	ld	s2,0(sp)
    80001e28:	6105                	addi	sp,sp,32
    80001e2a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e2c:	9e25                	addw	a2,a2,s1
    80001e2e:	1602                	slli	a2,a2,0x20
    80001e30:	9201                	srli	a2,a2,0x20
    80001e32:	1582                	slli	a1,a1,0x20
    80001e34:	9181                	srli	a1,a1,0x20
    80001e36:	6d28                	ld	a0,88(a0)
    80001e38:	fffff097          	auipc	ra,0xfffff
    80001e3c:	5b6080e7          	jalr	1462(ra) # 800013ee <uvmalloc>
    80001e40:	0005061b          	sext.w	a2,a0
    80001e44:	fa69                	bnez	a2,80001e16 <growproc+0x26>
      return -1;
    80001e46:	557d                	li	a0,-1
    80001e48:	bfe1                	j	80001e20 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e4a:	9e25                	addw	a2,a2,s1
    80001e4c:	1602                	slli	a2,a2,0x20
    80001e4e:	9201                	srli	a2,a2,0x20
    80001e50:	1582                	slli	a1,a1,0x20
    80001e52:	9181                	srli	a1,a1,0x20
    80001e54:	6d28                	ld	a0,88(a0)
    80001e56:	fffff097          	auipc	ra,0xfffff
    80001e5a:	550080e7          	jalr	1360(ra) # 800013a6 <uvmdealloc>
    80001e5e:	0005061b          	sext.w	a2,a0
    80001e62:	bf55                	j	80001e16 <growproc+0x26>

0000000080001e64 <fork>:
{
    80001e64:	7139                	addi	sp,sp,-64
    80001e66:	fc06                	sd	ra,56(sp)
    80001e68:	f822                	sd	s0,48(sp)
    80001e6a:	f426                	sd	s1,40(sp)
    80001e6c:	f04a                	sd	s2,32(sp)
    80001e6e:	ec4e                	sd	s3,24(sp)
    80001e70:	e852                	sd	s4,16(sp)
    80001e72:	e456                	sd	s5,8(sp)
    80001e74:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e76:	00000097          	auipc	ra,0x0
    80001e7a:	b20080e7          	jalr	-1248(ra) # 80001996 <myproc>
    80001e7e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e80:	00000097          	auipc	ra,0x0
    80001e84:	dc6080e7          	jalr	-570(ra) # 80001c46 <allocproc>
    80001e88:	12050463          	beqz	a0,80001fb0 <fork+0x14c>
    80001e8c:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e8e:	050ab603          	ld	a2,80(s5)
    80001e92:	6d2c                	ld	a1,88(a0)
    80001e94:	058ab503          	ld	a0,88(s5)
    80001e98:	fffff097          	auipc	ra,0xfffff
    80001e9c:	6a2080e7          	jalr	1698(ra) # 8000153a <uvmcopy>
    80001ea0:	06054063          	bltz	a0,80001f00 <fork+0x9c>
  np->sz = p->sz;
    80001ea4:	050ab783          	ld	a5,80(s5)
    80001ea8:	04f9b823          	sd	a5,80(s3)
  *(np->trapframe) = *(p->trapframe);
    80001eac:	060ab683          	ld	a3,96(s5)
    80001eb0:	87b6                	mv	a5,a3
    80001eb2:	0609b703          	ld	a4,96(s3)
    80001eb6:	12068693          	addi	a3,a3,288
    80001eba:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001ebe:	6788                	ld	a0,8(a5)
    80001ec0:	6b8c                	ld	a1,16(a5)
    80001ec2:	6f90                	ld	a2,24(a5)
    80001ec4:	01073023          	sd	a6,0(a4)
    80001ec8:	e708                	sd	a0,8(a4)
    80001eca:	eb0c                	sd	a1,16(a4)
    80001ecc:	ef10                	sd	a2,24(a4)
    80001ece:	02078793          	addi	a5,a5,32
    80001ed2:	02070713          	addi	a4,a4,32
    80001ed6:	fed792e3          	bne	a5,a3,80001eba <fork+0x56>
  np->trapframe->a0 = 0;
    80001eda:	0609b783          	ld	a5,96(s3)
    80001ede:	0607b823          	sd	zero,112(a5)
  np->trace_mask = p->trace_mask; // our code - making child inherit the parrent trace mask
    80001ee2:	034aa783          	lw	a5,52(s5)
    80001ee6:	02f9aa23          	sw	a5,52(s3)
  np->decay_factor=p->decay_factor;// our code
    80001eea:	038aa783          	lw	a5,56(s5)
    80001eee:	02f9ac23          	sw	a5,56(s3)
  for(i = 0; i < NOFILE; i++)
    80001ef2:	0d8a8493          	addi	s1,s5,216
    80001ef6:	0d898913          	addi	s2,s3,216
    80001efa:	158a8a13          	addi	s4,s5,344
    80001efe:	a00d                	j	80001f20 <fork+0xbc>
    freeproc(np);
    80001f00:	854e                	mv	a0,s3
    80001f02:	00000097          	auipc	ra,0x0
    80001f06:	c8c080e7          	jalr	-884(ra) # 80001b8e <freeproc>
    release(&np->lock);
    80001f0a:	854e                	mv	a0,s3
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	d6a080e7          	jalr	-662(ra) # 80000c76 <release>
    return -1;
    80001f14:	597d                	li	s2,-1
    80001f16:	a059                	j	80001f9c <fork+0x138>
  for(i = 0; i < NOFILE; i++)
    80001f18:	04a1                	addi	s1,s1,8
    80001f1a:	0921                	addi	s2,s2,8
    80001f1c:	01448b63          	beq	s1,s4,80001f32 <fork+0xce>
    if(p->ofile[i])
    80001f20:	6088                	ld	a0,0(s1)
    80001f22:	d97d                	beqz	a0,80001f18 <fork+0xb4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f24:	00003097          	auipc	ra,0x3
    80001f28:	bae080e7          	jalr	-1106(ra) # 80004ad2 <filedup>
    80001f2c:	00a93023          	sd	a0,0(s2)
    80001f30:	b7e5                	j	80001f18 <fork+0xb4>
  np->cwd = idup(p->cwd);
    80001f32:	158ab503          	ld	a0,344(s5)
    80001f36:	00002097          	auipc	ra,0x2
    80001f3a:	d0e080e7          	jalr	-754(ra) # 80003c44 <idup>
    80001f3e:	14a9bc23          	sd	a0,344(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f42:	4641                	li	a2,16
    80001f44:	160a8593          	addi	a1,s5,352
    80001f48:	16098513          	addi	a0,s3,352
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	ec4080e7          	jalr	-316(ra) # 80000e10 <safestrcpy>
  pid = np->pid;
    80001f54:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f58:	854e                	mv	a0,s3
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	d1c080e7          	jalr	-740(ra) # 80000c76 <release>
  acquire(&wait_lock);
    80001f62:	0000f497          	auipc	s1,0xf
    80001f66:	36e48493          	addi	s1,s1,878 # 800112d0 <wait_lock>
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	fffff097          	auipc	ra,0xfffff
    80001f70:	c56080e7          	jalr	-938(ra) # 80000bc2 <acquire>
  np->parent = p;
    80001f74:	0559b023          	sd	s5,64(s3)
  release(&wait_lock);
    80001f78:	8526                	mv	a0,s1
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	cfc080e7          	jalr	-772(ra) # 80000c76 <release>
  acquire(&np->lock);
    80001f82:	854e                	mv	a0,s3
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	c3e080e7          	jalr	-962(ra) # 80000bc2 <acquire>
  np->state = RUNNABLE;
    80001f8c:	478d                	li	a5,3
    80001f8e:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f92:	854e                	mv	a0,s3
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	ce2080e7          	jalr	-798(ra) # 80000c76 <release>
}
    80001f9c:	854a                	mv	a0,s2
    80001f9e:	70e2                	ld	ra,56(sp)
    80001fa0:	7442                	ld	s0,48(sp)
    80001fa2:	74a2                	ld	s1,40(sp)
    80001fa4:	7902                	ld	s2,32(sp)
    80001fa6:	69e2                	ld	s3,24(sp)
    80001fa8:	6a42                	ld	s4,16(sp)
    80001faa:	6aa2                	ld	s5,8(sp)
    80001fac:	6121                	addi	sp,sp,64
    80001fae:	8082                	ret
    return -1;
    80001fb0:	597d                	li	s2,-1
    80001fb2:	b7ed                	j	80001f9c <fork+0x138>

0000000080001fb4 <scheduler>:
{
    80001fb4:	7159                	addi	sp,sp,-112
    80001fb6:	f486                	sd	ra,104(sp)
    80001fb8:	f0a2                	sd	s0,96(sp)
    80001fba:	eca6                	sd	s1,88(sp)
    80001fbc:	e8ca                	sd	s2,80(sp)
    80001fbe:	e4ce                	sd	s3,72(sp)
    80001fc0:	e0d2                	sd	s4,64(sp)
    80001fc2:	fc56                	sd	s5,56(sp)
    80001fc4:	f85a                	sd	s6,48(sp)
    80001fc6:	f45e                	sd	s7,40(sp)
    80001fc8:	f062                	sd	s8,32(sp)
    80001fca:	ec66                	sd	s9,24(sp)
    80001fcc:	e86a                	sd	s10,16(sp)
    80001fce:	e46e                	sd	s11,8(sp)
    80001fd0:	1880                	addi	s0,sp,112
    80001fd2:	8792                	mv	a5,tp
  int id = r_tp();
    80001fd4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fd6:	00779d13          	slli	s10,a5,0x7
    80001fda:	0000f717          	auipc	a4,0xf
    80001fde:	2c670713          	addi	a4,a4,710 # 800112a0 <pid_lock>
    80001fe2:	976a                	add	a4,a4,s10
    80001fe4:	04073423          	sd	zero,72(a4)
        swtch(&c->context, &first_in_line->context);
    80001fe8:	0000f717          	auipc	a4,0xf
    80001fec:	30870713          	addi	a4,a4,776 # 800112f0 <cpus+0x8>
    80001ff0:	9d3a                	add	s10,s10,a4
      struct proc *first_in_line =0;
    80001ff2:	4c81                	li	s9,0
        if(p->state == RUNNABLE) {
    80001ff4:	4b8d                	li	s7,3
      for(p = proc; p < &proc[NPROC]; p++) {
    80001ff6:	00016b17          	auipc	s6,0x16
    80001ffa:	af2b0b13          	addi	s6,s6,-1294 # 80017ae8 <tickslock>
        first_in_line->state = RUNNING;
    80001ffe:	4d91                	li	s11,4
        c->proc = first_in_line;
    80002000:	079e                	slli	a5,a5,0x7
    80002002:	0000fc17          	auipc	s8,0xf
    80002006:	29ec0c13          	addi	s8,s8,670 # 800112a0 <pid_lock>
    8000200a:	9c3e                	add	s8,s8,a5
    8000200c:	a889                	j	8000205e <scheduler+0xaa>
              release(&first_in_line->lock);
    8000200e:	8552                	mv	a0,s4
    80002010:	fffff097          	auipc	ra,0xfffff
    80002014:	c66080e7          	jalr	-922(ra) # 80000c76 <release>
              first_in_line=p;
    80002018:	8a26                	mv	s4,s1
    8000201a:	a09d                	j	80002080 <scheduler+0xcc>
              release(&p->lock);
    8000201c:	8556                	mv	a0,s5
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	c58080e7          	jalr	-936(ra) # 80000c76 <release>
    80002026:	a8a9                	j	80002080 <scheduler+0xcc>
          release(&p->lock);
    80002028:	8526                	mv	a0,s1
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	c4c080e7          	jalr	-948(ra) # 80000c76 <release>
      for(p = proc; p < &proc[NPROC]; p++) {
    80002032:	05696963          	bltu	s2,s6,80002084 <scheduler+0xd0>
      if(first_in_line!=0){
    80002036:	020a0463          	beqz	s4,8000205e <scheduler+0xaa>
        first_in_line->state = RUNNING;
    8000203a:	01ba2c23          	sw	s11,24(s4)
        c->proc = first_in_line;
    8000203e:	054c3423          	sd	s4,72(s8)
        swtch(&c->context, &first_in_line->context);
    80002042:	068a0593          	addi	a1,s4,104
    80002046:	856a                	mv	a0,s10
    80002048:	00001097          	auipc	ra,0x1
    8000204c:	a6c080e7          	jalr	-1428(ra) # 80002ab4 <swtch>
        c->proc = 0;
    80002050:	040c3423          	sd	zero,72(s8)
        release(&first_in_line->lock);
    80002054:	8552                	mv	a0,s4
    80002056:	fffff097          	auipc	ra,0xfffff
    8000205a:	c20080e7          	jalr	-992(ra) # 80000c76 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000205e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002062:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002066:	10079073          	csrw	sstatus,a5
      for(p = proc; p < &proc[NPROC]; p++) {
    8000206a:	0000f497          	auipc	s1,0xf
    8000206e:	67e48493          	addi	s1,s1,1662 # 800116e8 <proc>
    80002072:	00010917          	auipc	s2,0x10
    80002076:	80690913          	addi	s2,s2,-2042 # 80011878 <proc+0x190>
      struct proc *first_in_line =0;
    8000207a:	8a66                	mv	s4,s9
    8000207c:	a801                	j	8000208c <scheduler+0xd8>
    8000207e:	8a26                	mv	s4,s1
      for(p = proc; p < &proc[NPROC]; p++) {
    80002080:	fb69fde3          	bgeu	s3,s6,8000203a <scheduler+0x86>
    80002084:	19048493          	addi	s1,s1,400
    80002088:	19090913          	addi	s2,s2,400
    8000208c:	8aa6                	mv	s5,s1
        acquire(&p->lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	b32080e7          	jalr	-1230(ra) # 80000bc2 <acquire>
        if(p->state == RUNNABLE) {
    80002098:	89ca                	mv	s3,s2
    8000209a:	e8892783          	lw	a5,-376(s2)
    8000209e:	f97795e3          	bne	a5,s7,80002028 <scheduler+0x74>
          if (first_in_line==0){
    800020a2:	fc0a0ee3          	beqz	s4,8000207e <scheduler+0xca>
            if((p->rutime==0) & (p->stime==0) & (first_in_line->rutime!=0)){
    800020a6:	ff092783          	lw	a5,-16(s2)
    800020aa:	fe892503          	lw	a0,-24(s2)
    800020ae:	180a2603          	lw	a2,384(s4)
    800020b2:	00a7e733          	or	a4,a5,a0
    800020b6:	e311                	bnez	a4,800020ba <scheduler+0x106>
    800020b8:	fa39                	bnez	a2,8000200e <scheduler+0x5a>
            else if ((p->rutime*p->decay_factor*(first_in_line->rutime + first_in_line->stime)) < (first_in_line->rutime*first_in_line->decay_factor*(p->rutime + p->stime))){
    800020ba:	ea89a683          	lw	a3,-344(s3)
    800020be:	02f686bb          	mulw	a3,a3,a5
    800020c2:	178a2583          	lw	a1,376(s4)
    800020c6:	9db1                	addw	a1,a1,a2
    800020c8:	038a2703          	lw	a4,56(s4)
    800020cc:	02c7073b          	mulw	a4,a4,a2
    800020d0:	9fa9                	addw	a5,a5,a0
    800020d2:	02b686bb          	mulw	a3,a3,a1
    800020d6:	02f707bb          	mulw	a5,a4,a5
    800020da:	f4f6d1e3          	bge	a3,a5,8000201c <scheduler+0x68>
              release(&first_in_line->lock);
    800020de:	8552                	mv	a0,s4
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	b96080e7          	jalr	-1130(ra) # 80000c76 <release>
              first_in_line=p;
    800020e8:	8a56                	mv	s4,s5
    800020ea:	bf59                	j	80002080 <scheduler+0xcc>

00000000800020ec <sched>:
{
    800020ec:	7179                	addi	sp,sp,-48
    800020ee:	f406                	sd	ra,40(sp)
    800020f0:	f022                	sd	s0,32(sp)
    800020f2:	ec26                	sd	s1,24(sp)
    800020f4:	e84a                	sd	s2,16(sp)
    800020f6:	e44e                	sd	s3,8(sp)
    800020f8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020fa:	00000097          	auipc	ra,0x0
    800020fe:	89c080e7          	jalr	-1892(ra) # 80001996 <myproc>
    80002102:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	a44080e7          	jalr	-1468(ra) # 80000b48 <holding>
    8000210c:	c179                	beqz	a0,800021d2 <sched+0xe6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000210e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002110:	2781                	sext.w	a5,a5
    80002112:	079e                	slli	a5,a5,0x7
    80002114:	0000f717          	auipc	a4,0xf
    80002118:	18c70713          	addi	a4,a4,396 # 800112a0 <pid_lock>
    8000211c:	97ba                	add	a5,a5,a4
    8000211e:	0c07a703          	lw	a4,192(a5)
    80002122:	4785                	li	a5,1
    80002124:	0af71f63          	bne	a4,a5,800021e2 <sched+0xf6>
  if(p->state == RUNNING)
    80002128:	4c98                	lw	a4,24(s1)
    8000212a:	4791                	li	a5,4
    8000212c:	0cf70363          	beq	a4,a5,800021f2 <sched+0x106>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002130:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002134:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002136:	e7f1                	bnez	a5,80002202 <sched+0x116>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002138:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000213a:	0000f917          	auipc	s2,0xf
    8000213e:	16690913          	addi	s2,s2,358 # 800112a0 <pid_lock>
    80002142:	2781                	sext.w	a5,a5
    80002144:	079e                	slli	a5,a5,0x7
    80002146:	97ca                	add	a5,a5,s2
    80002148:	0c47a983          	lw	s3,196(a5)
  p->place = allocplace(); // update the process place for the FCFS policy
    8000214c:	00000097          	auipc	ra,0x0
    80002150:	90e080e7          	jalr	-1778(ra) # 80001a5a <allocplace>
    80002154:	18a4a623          	sw	a0,396(s1)
  acquire(&tickslock);
    80002158:	00016517          	auipc	a0,0x16
    8000215c:	99050513          	addi	a0,a0,-1648 # 80017ae8 <tickslock>
    80002160:	fffff097          	auipc	ra,0xfffff
    80002164:	a62080e7          	jalr	-1438(ra) # 80000bc2 <acquire>
  p->average_bursttime= ALPHA*p->B_current_burst_length+(100-ALPHA)*p->average_bursttime/100;
    80002168:	1884a703          	lw	a4,392(s1)
    8000216c:	03200793          	li	a5,50
    80002170:	02e787bb          	mulw	a5,a5,a4
    80002174:	1844a683          	lw	a3,388(s1)
    80002178:	01f6d71b          	srliw	a4,a3,0x1f
    8000217c:	9f35                	addw	a4,a4,a3
    8000217e:	4017571b          	sraiw	a4,a4,0x1
    80002182:	9fb9                	addw	a5,a5,a4
    80002184:	18f4a223          	sw	a5,388(s1)
  p->B_current_burst_length=0;
    80002188:	1804a423          	sw	zero,392(s1)
  release(&tickslock);
    8000218c:	00016517          	auipc	a0,0x16
    80002190:	95c50513          	addi	a0,a0,-1700 # 80017ae8 <tickslock>
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	ae2080e7          	jalr	-1310(ra) # 80000c76 <release>
    8000219c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000219e:	2781                	sext.w	a5,a5
    800021a0:	079e                	slli	a5,a5,0x7
    800021a2:	0000f597          	auipc	a1,0xf
    800021a6:	14e58593          	addi	a1,a1,334 # 800112f0 <cpus+0x8>
    800021aa:	95be                	add	a1,a1,a5
    800021ac:	06848513          	addi	a0,s1,104
    800021b0:	00001097          	auipc	ra,0x1
    800021b4:	904080e7          	jalr	-1788(ra) # 80002ab4 <swtch>
    800021b8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021ba:	2781                	sext.w	a5,a5
    800021bc:	079e                	slli	a5,a5,0x7
    800021be:	97ca                	add	a5,a5,s2
    800021c0:	0d37a223          	sw	s3,196(a5)
}
    800021c4:	70a2                	ld	ra,40(sp)
    800021c6:	7402                	ld	s0,32(sp)
    800021c8:	64e2                	ld	s1,24(sp)
    800021ca:	6942                	ld	s2,16(sp)
    800021cc:	69a2                	ld	s3,8(sp)
    800021ce:	6145                	addi	sp,sp,48
    800021d0:	8082                	ret
    panic("sched p->lock");
    800021d2:	00006517          	auipc	a0,0x6
    800021d6:	03e50513          	addi	a0,a0,62 # 80008210 <digits+0x1d0>
    800021da:	ffffe097          	auipc	ra,0xffffe
    800021de:	350080e7          	jalr	848(ra) # 8000052a <panic>
    panic("sched locks");
    800021e2:	00006517          	auipc	a0,0x6
    800021e6:	03e50513          	addi	a0,a0,62 # 80008220 <digits+0x1e0>
    800021ea:	ffffe097          	auipc	ra,0xffffe
    800021ee:	340080e7          	jalr	832(ra) # 8000052a <panic>
    panic("sched running");
    800021f2:	00006517          	auipc	a0,0x6
    800021f6:	03e50513          	addi	a0,a0,62 # 80008230 <digits+0x1f0>
    800021fa:	ffffe097          	auipc	ra,0xffffe
    800021fe:	330080e7          	jalr	816(ra) # 8000052a <panic>
    panic("sched interruptible");
    80002202:	00006517          	auipc	a0,0x6
    80002206:	03e50513          	addi	a0,a0,62 # 80008240 <digits+0x200>
    8000220a:	ffffe097          	auipc	ra,0xffffe
    8000220e:	320080e7          	jalr	800(ra) # 8000052a <panic>

0000000080002212 <yield>:
{
    80002212:	1101                	addi	sp,sp,-32
    80002214:	ec06                	sd	ra,24(sp)
    80002216:	e822                	sd	s0,16(sp)
    80002218:	e426                	sd	s1,8(sp)
    8000221a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	77a080e7          	jalr	1914(ra) # 80001996 <myproc>
    80002224:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	99c080e7          	jalr	-1636(ra) # 80000bc2 <acquire>
  p->state = RUNNABLE;
    8000222e:	478d                	li	a5,3
    80002230:	cc9c                	sw	a5,24(s1)
  sched();
    80002232:	00000097          	auipc	ra,0x0
    80002236:	eba080e7          	jalr	-326(ra) # 800020ec <sched>
  release(&p->lock);
    8000223a:	8526                	mv	a0,s1
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	a3a080e7          	jalr	-1478(ra) # 80000c76 <release>
}
    80002244:	60e2                	ld	ra,24(sp)
    80002246:	6442                	ld	s0,16(sp)
    80002248:	64a2                	ld	s1,8(sp)
    8000224a:	6105                	addi	sp,sp,32
    8000224c:	8082                	ret

000000008000224e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000224e:	7179                	addi	sp,sp,-48
    80002250:	f406                	sd	ra,40(sp)
    80002252:	f022                	sd	s0,32(sp)
    80002254:	ec26                	sd	s1,24(sp)
    80002256:	e84a                	sd	s2,16(sp)
    80002258:	e44e                	sd	s3,8(sp)
    8000225a:	1800                	addi	s0,sp,48
    8000225c:	89aa                	mv	s3,a0
    8000225e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	736080e7          	jalr	1846(ra) # 80001996 <myproc>
    80002268:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000226a:	fffff097          	auipc	ra,0xfffff
    8000226e:	958080e7          	jalr	-1704(ra) # 80000bc2 <acquire>
  release(lk);
    80002272:	854a                	mv	a0,s2
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	a02080e7          	jalr	-1534(ra) # 80000c76 <release>

  // Go to sleep.
  p->chan = chan;
    8000227c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002280:	4789                	li	a5,2
    80002282:	cc9c                	sw	a5,24(s1)


  sched();
    80002284:	00000097          	auipc	ra,0x0
    80002288:	e68080e7          	jalr	-408(ra) # 800020ec <sched>

  // Tidy up.
  p->chan = 0;
    8000228c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002290:	8526                	mv	a0,s1
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	9e4080e7          	jalr	-1564(ra) # 80000c76 <release>
  acquire(lk);
    8000229a:	854a                	mv	a0,s2
    8000229c:	fffff097          	auipc	ra,0xfffff
    800022a0:	926080e7          	jalr	-1754(ra) # 80000bc2 <acquire>
}
    800022a4:	70a2                	ld	ra,40(sp)
    800022a6:	7402                	ld	s0,32(sp)
    800022a8:	64e2                	ld	s1,24(sp)
    800022aa:	6942                	ld	s2,16(sp)
    800022ac:	69a2                	ld	s3,8(sp)
    800022ae:	6145                	addi	sp,sp,48
    800022b0:	8082                	ret

00000000800022b2 <wait>:
{
    800022b2:	715d                	addi	sp,sp,-80
    800022b4:	e486                	sd	ra,72(sp)
    800022b6:	e0a2                	sd	s0,64(sp)
    800022b8:	fc26                	sd	s1,56(sp)
    800022ba:	f84a                	sd	s2,48(sp)
    800022bc:	f44e                	sd	s3,40(sp)
    800022be:	f052                	sd	s4,32(sp)
    800022c0:	ec56                	sd	s5,24(sp)
    800022c2:	e85a                	sd	s6,16(sp)
    800022c4:	e45e                	sd	s7,8(sp)
    800022c6:	e062                	sd	s8,0(sp)
    800022c8:	0880                	addi	s0,sp,80
    800022ca:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	6ca080e7          	jalr	1738(ra) # 80001996 <myproc>
    800022d4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800022d6:	0000f517          	auipc	a0,0xf
    800022da:	ffa50513          	addi	a0,a0,-6 # 800112d0 <wait_lock>
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	8e4080e7          	jalr	-1820(ra) # 80000bc2 <acquire>
    havekids = 0;
    800022e6:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022e8:	4a15                	li	s4,5
        havekids = 1;
    800022ea:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800022ec:	00015997          	auipc	s3,0x15
    800022f0:	7fc98993          	addi	s3,s3,2044 # 80017ae8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800022f4:	0000fc17          	auipc	s8,0xf
    800022f8:	fdcc0c13          	addi	s8,s8,-36 # 800112d0 <wait_lock>
    havekids = 0;
    800022fc:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022fe:	0000f497          	auipc	s1,0xf
    80002302:	3ea48493          	addi	s1,s1,1002 # 800116e8 <proc>
    80002306:	a0bd                	j	80002374 <wait+0xc2>
          pid = np->pid;
    80002308:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000230c:	000b0e63          	beqz	s6,80002328 <wait+0x76>
    80002310:	4691                	li	a3,4
    80002312:	02c48613          	addi	a2,s1,44
    80002316:	85da                	mv	a1,s6
    80002318:	05893503          	ld	a0,88(s2)
    8000231c:	fffff097          	auipc	ra,0xfffff
    80002320:	322080e7          	jalr	802(ra) # 8000163e <copyout>
    80002324:	02054563          	bltz	a0,8000234e <wait+0x9c>
          freeproc(np);
    80002328:	8526                	mv	a0,s1
    8000232a:	00000097          	auipc	ra,0x0
    8000232e:	864080e7          	jalr	-1948(ra) # 80001b8e <freeproc>
          release(&np->lock);
    80002332:	8526                	mv	a0,s1
    80002334:	fffff097          	auipc	ra,0xfffff
    80002338:	942080e7          	jalr	-1726(ra) # 80000c76 <release>
          release(&wait_lock);
    8000233c:	0000f517          	auipc	a0,0xf
    80002340:	f9450513          	addi	a0,a0,-108 # 800112d0 <wait_lock>
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	932080e7          	jalr	-1742(ra) # 80000c76 <release>
          return pid;
    8000234c:	a09d                	j	800023b2 <wait+0x100>
            release(&np->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	926080e7          	jalr	-1754(ra) # 80000c76 <release>
            release(&wait_lock);
    80002358:	0000f517          	auipc	a0,0xf
    8000235c:	f7850513          	addi	a0,a0,-136 # 800112d0 <wait_lock>
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	916080e7          	jalr	-1770(ra) # 80000c76 <release>
            return -1;
    80002368:	59fd                	li	s3,-1
    8000236a:	a0a1                	j	800023b2 <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    8000236c:	19048493          	addi	s1,s1,400
    80002370:	03348463          	beq	s1,s3,80002398 <wait+0xe6>
      if(np->parent == p){
    80002374:	60bc                	ld	a5,64(s1)
    80002376:	ff279be3          	bne	a5,s2,8000236c <wait+0xba>
        acquire(&np->lock);
    8000237a:	8526                	mv	a0,s1
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	846080e7          	jalr	-1978(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    80002384:	4c9c                	lw	a5,24(s1)
    80002386:	f94781e3          	beq	a5,s4,80002308 <wait+0x56>
        release(&np->lock);
    8000238a:	8526                	mv	a0,s1
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	8ea080e7          	jalr	-1814(ra) # 80000c76 <release>
        havekids = 1;
    80002394:	8756                	mv	a4,s5
    80002396:	bfd9                	j	8000236c <wait+0xba>
    if(!havekids || p->killed){
    80002398:	c701                	beqz	a4,800023a0 <wait+0xee>
    8000239a:	02892783          	lw	a5,40(s2)
    8000239e:	c79d                	beqz	a5,800023cc <wait+0x11a>
      release(&wait_lock);
    800023a0:	0000f517          	auipc	a0,0xf
    800023a4:	f3050513          	addi	a0,a0,-208 # 800112d0 <wait_lock>
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	8ce080e7          	jalr	-1842(ra) # 80000c76 <release>
      return -1;
    800023b0:	59fd                	li	s3,-1
}
    800023b2:	854e                	mv	a0,s3
    800023b4:	60a6                	ld	ra,72(sp)
    800023b6:	6406                	ld	s0,64(sp)
    800023b8:	74e2                	ld	s1,56(sp)
    800023ba:	7942                	ld	s2,48(sp)
    800023bc:	79a2                	ld	s3,40(sp)
    800023be:	7a02                	ld	s4,32(sp)
    800023c0:	6ae2                	ld	s5,24(sp)
    800023c2:	6b42                	ld	s6,16(sp)
    800023c4:	6ba2                	ld	s7,8(sp)
    800023c6:	6c02                	ld	s8,0(sp)
    800023c8:	6161                	addi	sp,sp,80
    800023ca:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023cc:	85e2                	mv	a1,s8
    800023ce:	854a                	mv	a0,s2
    800023d0:	00000097          	auipc	ra,0x0
    800023d4:	e7e080e7          	jalr	-386(ra) # 8000224e <sleep>
    havekids = 0;
    800023d8:	b715                	j	800022fc <wait+0x4a>

00000000800023da <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800023da:	7139                	addi	sp,sp,-64
    800023dc:	fc06                	sd	ra,56(sp)
    800023de:	f822                	sd	s0,48(sp)
    800023e0:	f426                	sd	s1,40(sp)
    800023e2:	f04a                	sd	s2,32(sp)
    800023e4:	ec4e                	sd	s3,24(sp)
    800023e6:	e852                	sd	s4,16(sp)
    800023e8:	e456                	sd	s5,8(sp)
    800023ea:	0080                	addi	s0,sp,64
    800023ec:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800023ee:	0000f497          	auipc	s1,0xf
    800023f2:	2fa48493          	addi	s1,s1,762 # 800116e8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800023f6:	4989                	li	s3,2
        p->state = RUNNABLE;
    800023f8:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800023fa:	00015917          	auipc	s2,0x15
    800023fe:	6ee90913          	addi	s2,s2,1774 # 80017ae8 <tickslock>
    80002402:	a811                	j	80002416 <wakeup+0x3c>
      }
      release(&p->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	870080e7          	jalr	-1936(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000240e:	19048493          	addi	s1,s1,400
    80002412:	03248663          	beq	s1,s2,8000243e <wakeup+0x64>
    if(p != myproc()){
    80002416:	fffff097          	auipc	ra,0xfffff
    8000241a:	580080e7          	jalr	1408(ra) # 80001996 <myproc>
    8000241e:	fea488e3          	beq	s1,a0,8000240e <wakeup+0x34>
      acquire(&p->lock);
    80002422:	8526                	mv	a0,s1
    80002424:	ffffe097          	auipc	ra,0xffffe
    80002428:	79e080e7          	jalr	1950(ra) # 80000bc2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000242c:	4c9c                	lw	a5,24(s1)
    8000242e:	fd379be3          	bne	a5,s3,80002404 <wakeup+0x2a>
    80002432:	709c                	ld	a5,32(s1)
    80002434:	fd4798e3          	bne	a5,s4,80002404 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002438:	0154ac23          	sw	s5,24(s1)
    8000243c:	b7e1                	j	80002404 <wakeup+0x2a>
    }
  }
}
    8000243e:	70e2                	ld	ra,56(sp)
    80002440:	7442                	ld	s0,48(sp)
    80002442:	74a2                	ld	s1,40(sp)
    80002444:	7902                	ld	s2,32(sp)
    80002446:	69e2                	ld	s3,24(sp)
    80002448:	6a42                	ld	s4,16(sp)
    8000244a:	6aa2                	ld	s5,8(sp)
    8000244c:	6121                	addi	sp,sp,64
    8000244e:	8082                	ret

0000000080002450 <reparent>:
{
    80002450:	7179                	addi	sp,sp,-48
    80002452:	f406                	sd	ra,40(sp)
    80002454:	f022                	sd	s0,32(sp)
    80002456:	ec26                	sd	s1,24(sp)
    80002458:	e84a                	sd	s2,16(sp)
    8000245a:	e44e                	sd	s3,8(sp)
    8000245c:	e052                	sd	s4,0(sp)
    8000245e:	1800                	addi	s0,sp,48
    80002460:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002462:	0000f497          	auipc	s1,0xf
    80002466:	28648493          	addi	s1,s1,646 # 800116e8 <proc>
      pp->parent = initproc;
    8000246a:	00007a17          	auipc	s4,0x7
    8000246e:	bbea0a13          	addi	s4,s4,-1090 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002472:	00015997          	auipc	s3,0x15
    80002476:	67698993          	addi	s3,s3,1654 # 80017ae8 <tickslock>
    8000247a:	a029                	j	80002484 <reparent+0x34>
    8000247c:	19048493          	addi	s1,s1,400
    80002480:	01348d63          	beq	s1,s3,8000249a <reparent+0x4a>
    if(pp->parent == p){
    80002484:	60bc                	ld	a5,64(s1)
    80002486:	ff279be3          	bne	a5,s2,8000247c <reparent+0x2c>
      pp->parent = initproc;
    8000248a:	000a3503          	ld	a0,0(s4)
    8000248e:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002490:	00000097          	auipc	ra,0x0
    80002494:	f4a080e7          	jalr	-182(ra) # 800023da <wakeup>
    80002498:	b7d5                	j	8000247c <reparent+0x2c>
}
    8000249a:	70a2                	ld	ra,40(sp)
    8000249c:	7402                	ld	s0,32(sp)
    8000249e:	64e2                	ld	s1,24(sp)
    800024a0:	6942                	ld	s2,16(sp)
    800024a2:	69a2                	ld	s3,8(sp)
    800024a4:	6a02                	ld	s4,0(sp)
    800024a6:	6145                	addi	sp,sp,48
    800024a8:	8082                	ret

00000000800024aa <exit>:
{
    800024aa:	7179                	addi	sp,sp,-48
    800024ac:	f406                	sd	ra,40(sp)
    800024ae:	f022                	sd	s0,32(sp)
    800024b0:	ec26                	sd	s1,24(sp)
    800024b2:	e84a                	sd	s2,16(sp)
    800024b4:	e44e                	sd	s3,8(sp)
    800024b6:	e052                	sd	s4,0(sp)
    800024b8:	1800                	addi	s0,sp,48
    800024ba:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800024bc:	fffff097          	auipc	ra,0xfffff
    800024c0:	4da080e7          	jalr	1242(ra) # 80001996 <myproc>
    800024c4:	89aa                	mv	s3,a0
  if(p == initproc)
    800024c6:	00007797          	auipc	a5,0x7
    800024ca:	b627b783          	ld	a5,-1182(a5) # 80009028 <initproc>
    800024ce:	0d850493          	addi	s1,a0,216
    800024d2:	15850913          	addi	s2,a0,344
    800024d6:	02a79363          	bne	a5,a0,800024fc <exit+0x52>
    panic("init exiting");
    800024da:	00006517          	auipc	a0,0x6
    800024de:	d7e50513          	addi	a0,a0,-642 # 80008258 <digits+0x218>
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	048080e7          	jalr	72(ra) # 8000052a <panic>
      fileclose(f);
    800024ea:	00002097          	auipc	ra,0x2
    800024ee:	63a080e7          	jalr	1594(ra) # 80004b24 <fileclose>
      p->ofile[fd] = 0;
    800024f2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800024f6:	04a1                	addi	s1,s1,8
    800024f8:	01248563          	beq	s1,s2,80002502 <exit+0x58>
    if(p->ofile[fd]){
    800024fc:	6088                	ld	a0,0(s1)
    800024fe:	f575                	bnez	a0,800024ea <exit+0x40>
    80002500:	bfdd                	j	800024f6 <exit+0x4c>
  begin_op();
    80002502:	00002097          	auipc	ra,0x2
    80002506:	156080e7          	jalr	342(ra) # 80004658 <begin_op>
  iput(p->cwd);
    8000250a:	1589b503          	ld	a0,344(s3)
    8000250e:	00002097          	auipc	ra,0x2
    80002512:	92e080e7          	jalr	-1746(ra) # 80003e3c <iput>
  end_op();
    80002516:	00002097          	auipc	ra,0x2
    8000251a:	1c2080e7          	jalr	450(ra) # 800046d8 <end_op>
  p->cwd = 0;
    8000251e:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    80002522:	0000f497          	auipc	s1,0xf
    80002526:	dae48493          	addi	s1,s1,-594 # 800112d0 <wait_lock>
    8000252a:	8526                	mv	a0,s1
    8000252c:	ffffe097          	auipc	ra,0xffffe
    80002530:	696080e7          	jalr	1686(ra) # 80000bc2 <acquire>
  reparent(p);
    80002534:	854e                	mv	a0,s3
    80002536:	00000097          	auipc	ra,0x0
    8000253a:	f1a080e7          	jalr	-230(ra) # 80002450 <reparent>
  wakeup(p->parent);
    8000253e:	0409b503          	ld	a0,64(s3)
    80002542:	00000097          	auipc	ra,0x0
    80002546:	e98080e7          	jalr	-360(ra) # 800023da <wakeup>
  acquire(&p->lock);
    8000254a:	854e                	mv	a0,s3
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	676080e7          	jalr	1654(ra) # 80000bc2 <acquire>
  p->xstate = status;
    80002554:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002558:	4795                	li	a5,5
    8000255a:	00f9ac23          	sw	a5,24(s3)
  acquire(&tickslock);
    8000255e:	00015517          	auipc	a0,0x15
    80002562:	58a50513          	addi	a0,a0,1418 # 80017ae8 <tickslock>
    80002566:	ffffe097          	auipc	ra,0xffffe
    8000256a:	65c080e7          	jalr	1628(ra) # 80000bc2 <acquire>
  p->ttime=ticks;//our code
    8000256e:	00007797          	auipc	a5,0x7
    80002572:	ac27a783          	lw	a5,-1342(a5) # 80009030 <ticks>
    80002576:	16f9aa23          	sw	a5,372(s3)
  release(&tickslock);
    8000257a:	00015517          	auipc	a0,0x15
    8000257e:	56e50513          	addi	a0,a0,1390 # 80017ae8 <tickslock>
    80002582:	ffffe097          	auipc	ra,0xffffe
    80002586:	6f4080e7          	jalr	1780(ra) # 80000c76 <release>
  release(&wait_lock);
    8000258a:	8526                	mv	a0,s1
    8000258c:	ffffe097          	auipc	ra,0xffffe
    80002590:	6ea080e7          	jalr	1770(ra) # 80000c76 <release>
  sched();
    80002594:	00000097          	auipc	ra,0x0
    80002598:	b58080e7          	jalr	-1192(ra) # 800020ec <sched>
  panic("zombie exit");
    8000259c:	00006517          	auipc	a0,0x6
    800025a0:	ccc50513          	addi	a0,a0,-820 # 80008268 <digits+0x228>
    800025a4:	ffffe097          	auipc	ra,0xffffe
    800025a8:	f86080e7          	jalr	-122(ra) # 8000052a <panic>

00000000800025ac <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800025ac:	7179                	addi	sp,sp,-48
    800025ae:	f406                	sd	ra,40(sp)
    800025b0:	f022                	sd	s0,32(sp)
    800025b2:	ec26                	sd	s1,24(sp)
    800025b4:	e84a                	sd	s2,16(sp)
    800025b6:	e44e                	sd	s3,8(sp)
    800025b8:	1800                	addi	s0,sp,48
    800025ba:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025bc:	0000f497          	auipc	s1,0xf
    800025c0:	12c48493          	addi	s1,s1,300 # 800116e8 <proc>
    800025c4:	00015997          	auipc	s3,0x15
    800025c8:	52498993          	addi	s3,s3,1316 # 80017ae8 <tickslock>
    acquire(&p->lock);
    800025cc:	8526                	mv	a0,s1
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	5f4080e7          	jalr	1524(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    800025d6:	589c                	lw	a5,48(s1)
    800025d8:	01278d63          	beq	a5,s2,800025f2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025dc:	8526                	mv	a0,s1
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	698080e7          	jalr	1688(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800025e6:	19048493          	addi	s1,s1,400
    800025ea:	ff3491e3          	bne	s1,s3,800025cc <kill+0x20>
  }
  return -1;
    800025ee:	557d                	li	a0,-1
    800025f0:	a829                	j	8000260a <kill+0x5e>
      p->killed = 1;
    800025f2:	4785                	li	a5,1
    800025f4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800025f6:	4c98                	lw	a4,24(s1)
    800025f8:	4789                	li	a5,2
    800025fa:	00f70f63          	beq	a4,a5,80002618 <kill+0x6c>
      release(&p->lock);
    800025fe:	8526                	mv	a0,s1
    80002600:	ffffe097          	auipc	ra,0xffffe
    80002604:	676080e7          	jalr	1654(ra) # 80000c76 <release>
      return 0;
    80002608:	4501                	li	a0,0
}
    8000260a:	70a2                	ld	ra,40(sp)
    8000260c:	7402                	ld	s0,32(sp)
    8000260e:	64e2                	ld	s1,24(sp)
    80002610:	6942                	ld	s2,16(sp)
    80002612:	69a2                	ld	s3,8(sp)
    80002614:	6145                	addi	sp,sp,48
    80002616:	8082                	ret
        p->state = RUNNABLE;
    80002618:	478d                	li	a5,3
    8000261a:	cc9c                	sw	a5,24(s1)
    8000261c:	b7cd                	j	800025fe <kill+0x52>

000000008000261e <trace>:
//our code
// trace implementation
// update process mask for getting trace command
int
trace(int mask,int pid)
{
    8000261e:	7179                	addi	sp,sp,-48
    80002620:	f406                	sd	ra,40(sp)
    80002622:	f022                	sd	s0,32(sp)
    80002624:	ec26                	sd	s1,24(sp)
    80002626:	e84a                	sd	s2,16(sp)
    80002628:	e44e                	sd	s3,8(sp)
    8000262a:	e052                	sd	s4,0(sp)
    8000262c:	1800                	addi	s0,sp,48
    8000262e:	8a2a                	mv	s4,a0
    80002630:	892e                	mv	s2,a1
  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++){
    80002632:	0000f497          	auipc	s1,0xf
    80002636:	0b648493          	addi	s1,s1,182 # 800116e8 <proc>
    8000263a:	00015997          	auipc	s3,0x15
    8000263e:	4ae98993          	addi	s3,s3,1198 # 80017ae8 <tickslock>
    acquire(&p->lock);
    80002642:	8526                	mv	a0,s1
    80002644:	ffffe097          	auipc	ra,0xffffe
    80002648:	57e080e7          	jalr	1406(ra) # 80000bc2 <acquire>
    if(p->pid == pid){
    8000264c:	589c                	lw	a5,48(s1)
    8000264e:	01278d63          	beq	a5,s2,80002668 <trace+0x4a>
      p->trace_mask=mask;  
      release(&p->lock);
      return 0;
    }    
    release(&p->lock);
    80002652:	8526                	mv	a0,s1
    80002654:	ffffe097          	auipc	ra,0xffffe
    80002658:	622080e7          	jalr	1570(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000265c:	19048493          	addi	s1,s1,400
    80002660:	ff3491e3          	bne	s1,s3,80002642 <trace+0x24>
  }
  return -1;
    80002664:	557d                	li	a0,-1
    80002666:	a809                	j	80002678 <trace+0x5a>
      p->trace_mask=mask;  
    80002668:	0344aa23          	sw	s4,52(s1)
      release(&p->lock);
    8000266c:	8526                	mv	a0,s1
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	608080e7          	jalr	1544(ra) # 80000c76 <release>
      return 0;
    80002676:	4501                	li	a0,0
}
    80002678:	70a2                	ld	ra,40(sp)
    8000267a:	7402                	ld	s0,32(sp)
    8000267c:	64e2                	ld	s1,24(sp)
    8000267e:	6942                	ld	s2,16(sp)
    80002680:	69a2                	ld	s3,8(sp)
    80002682:	6a02                	ld	s4,0(sp)
    80002684:	6145                	addi	sp,sp,48
    80002686:	8082                	ret

0000000080002688 <wait_stat>:

//our code
// wait_stat implementation
int
wait_stat(uint64 status, uint64 performance)
{
    80002688:	711d                	addi	sp,sp,-96
    8000268a:	ec86                	sd	ra,88(sp)
    8000268c:	e8a2                	sd	s0,80(sp)
    8000268e:	e4a6                	sd	s1,72(sp)
    80002690:	e0ca                	sd	s2,64(sp)
    80002692:	fc4e                	sd	s3,56(sp)
    80002694:	f852                	sd	s4,48(sp)
    80002696:	f456                	sd	s5,40(sp)
    80002698:	f05a                	sd	s6,32(sp)
    8000269a:	ec5e                	sd	s7,24(sp)
    8000269c:	e862                	sd	s8,16(sp)
    8000269e:	e466                	sd	s9,8(sp)
    800026a0:	1080                	addi	s0,sp,96
    800026a2:	8baa                	mv	s7,a0
    800026a4:	8b2e                	mv	s6,a1

  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    800026a6:	fffff097          	auipc	ra,0xfffff
    800026aa:	2f0080e7          	jalr	752(ra) # 80001996 <myproc>
    800026ae:	892a                	mv	s2,a0

  acquire(&wait_lock);
    800026b0:	0000f517          	auipc	a0,0xf
    800026b4:	c2050513          	addi	a0,a0,-992 # 800112d0 <wait_lock>
    800026b8:	ffffe097          	auipc	ra,0xffffe
    800026bc:	50a080e7          	jalr	1290(ra) # 80000bc2 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    800026c0:	4c01                	li	s8,0
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if(np->state == ZOMBIE){
    800026c2:	4a15                	li	s4,5
        havekids = 1;
    800026c4:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800026c6:	00015997          	auipc	s3,0x15
    800026ca:	42298993          	addi	s3,s3,1058 # 80017ae8 <tickslock>
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800026ce:	0000fc97          	auipc	s9,0xf
    800026d2:	c02c8c93          	addi	s9,s9,-1022 # 800112d0 <wait_lock>
    havekids = 0;
    800026d6:	8762                	mv	a4,s8
    for(np = proc; np < &proc[NPROC]; np++){
    800026d8:	0000f497          	auipc	s1,0xf
    800026dc:	01048493          	addi	s1,s1,16 # 800116e8 <proc>
    800026e0:	a8c5                	j	800027d0 <wait_stat+0x148>
          pid = np->pid;
    800026e2:	0304a983          	lw	s3,48(s1)
          if(status != 0 && copyout(p->pagetable, status, (char *)&np->xstate,
    800026e6:	000b8e63          	beqz	s7,80002702 <wait_stat+0x7a>
    800026ea:	4691                	li	a3,4
    800026ec:	02c48613          	addi	a2,s1,44
    800026f0:	85de                	mv	a1,s7
    800026f2:	05893503          	ld	a0,88(s2)
    800026f6:	fffff097          	auipc	ra,0xfffff
    800026fa:	f48080e7          	jalr	-184(ra) # 8000163e <copyout>
    800026fe:	0a054663          	bltz	a0,800027aa <wait_stat+0x122>
          copyout(p->pagetable, (uint64)performance, (char *)&np->ctime, sizeof(np->ctime));
    80002702:	4691                	li	a3,4
    80002704:	17048613          	addi	a2,s1,368
    80002708:	85da                	mv	a1,s6
    8000270a:	05893503          	ld	a0,88(s2)
    8000270e:	fffff097          	auipc	ra,0xfffff
    80002712:	f30080e7          	jalr	-208(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)performance+sizeof(np->ctime), (char *)&np->ttime, sizeof(np->ttime));
    80002716:	4691                	li	a3,4
    80002718:	17448613          	addi	a2,s1,372
    8000271c:	004b0593          	addi	a1,s6,4
    80002720:	05893503          	ld	a0,88(s2)
    80002724:	fffff097          	auipc	ra,0xfffff
    80002728:	f1a080e7          	jalr	-230(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)performance+2*sizeof(np->ctime), (char *)&np->stime, sizeof(np->stime));
    8000272c:	4691                	li	a3,4
    8000272e:	17848613          	addi	a2,s1,376
    80002732:	008b0593          	addi	a1,s6,8
    80002736:	05893503          	ld	a0,88(s2)
    8000273a:	fffff097          	auipc	ra,0xfffff
    8000273e:	f04080e7          	jalr	-252(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)performance+3*sizeof(np->ctime), (char *)&np->retime, sizeof(np->retime));
    80002742:	4691                	li	a3,4
    80002744:	17c48613          	addi	a2,s1,380
    80002748:	00cb0593          	addi	a1,s6,12
    8000274c:	05893503          	ld	a0,88(s2)
    80002750:	fffff097          	auipc	ra,0xfffff
    80002754:	eee080e7          	jalr	-274(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)performance+4*sizeof(np->ctime), (char *)&np->rutime, sizeof(np->rutime));
    80002758:	4691                	li	a3,4
    8000275a:	18048613          	addi	a2,s1,384
    8000275e:	010b0593          	addi	a1,s6,16
    80002762:	05893503          	ld	a0,88(s2)
    80002766:	fffff097          	auipc	ra,0xfffff
    8000276a:	ed8080e7          	jalr	-296(ra) # 8000163e <copyout>
          copyout(p->pagetable, (uint64)performance+5*sizeof(np->ctime), (char *)&np->average_bursttime, sizeof(np->average_bursttime));
    8000276e:	4691                	li	a3,4
    80002770:	18448613          	addi	a2,s1,388
    80002774:	014b0593          	addi	a1,s6,20
    80002778:	05893503          	ld	a0,88(s2)
    8000277c:	fffff097          	auipc	ra,0xfffff
    80002780:	ec2080e7          	jalr	-318(ra) # 8000163e <copyout>
          freeproc(np);
    80002784:	8526                	mv	a0,s1
    80002786:	fffff097          	auipc	ra,0xfffff
    8000278a:	408080e7          	jalr	1032(ra) # 80001b8e <freeproc>
          release(&np->lock);
    8000278e:	8526                	mv	a0,s1
    80002790:	ffffe097          	auipc	ra,0xffffe
    80002794:	4e6080e7          	jalr	1254(ra) # 80000c76 <release>
          release(&wait_lock);
    80002798:	0000f517          	auipc	a0,0xf
    8000279c:	b3850513          	addi	a0,a0,-1224 # 800112d0 <wait_lock>
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	4d6080e7          	jalr	1238(ra) # 80000c76 <release>
          return pid;
    800027a8:	a09d                	j	8000280e <wait_stat+0x186>
            release(&np->lock);
    800027aa:	8526                	mv	a0,s1
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	4ca080e7          	jalr	1226(ra) # 80000c76 <release>
            release(&wait_lock);
    800027b4:	0000f517          	auipc	a0,0xf
    800027b8:	b1c50513          	addi	a0,a0,-1252 # 800112d0 <wait_lock>
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	4ba080e7          	jalr	1210(ra) # 80000c76 <release>
            return -1;
    800027c4:	59fd                	li	s3,-1
    800027c6:	a0a1                	j	8000280e <wait_stat+0x186>
    for(np = proc; np < &proc[NPROC]; np++){
    800027c8:	19048493          	addi	s1,s1,400
    800027cc:	03348463          	beq	s1,s3,800027f4 <wait_stat+0x16c>
      if(np->parent == p){
    800027d0:	60bc                	ld	a5,64(s1)
    800027d2:	ff279be3          	bne	a5,s2,800027c8 <wait_stat+0x140>
        acquire(&np->lock);
    800027d6:	8526                	mv	a0,s1
    800027d8:	ffffe097          	auipc	ra,0xffffe
    800027dc:	3ea080e7          	jalr	1002(ra) # 80000bc2 <acquire>
        if(np->state == ZOMBIE){
    800027e0:	4c9c                	lw	a5,24(s1)
    800027e2:	f14780e3          	beq	a5,s4,800026e2 <wait_stat+0x5a>
        release(&np->lock);
    800027e6:	8526                	mv	a0,s1
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	48e080e7          	jalr	1166(ra) # 80000c76 <release>
        havekids = 1;
    800027f0:	8756                	mv	a4,s5
    800027f2:	bfd9                	j	800027c8 <wait_stat+0x140>
    if(!havekids || p->killed){
    800027f4:	c701                	beqz	a4,800027fc <wait_stat+0x174>
    800027f6:	02892783          	lw	a5,40(s2)
    800027fa:	cb85                	beqz	a5,8000282a <wait_stat+0x1a2>
      release(&wait_lock);
    800027fc:	0000f517          	auipc	a0,0xf
    80002800:	ad450513          	addi	a0,a0,-1324 # 800112d0 <wait_lock>
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	472080e7          	jalr	1138(ra) # 80000c76 <release>
      return -1;
    8000280c:	59fd                	li	s3,-1
  }
}
    8000280e:	854e                	mv	a0,s3
    80002810:	60e6                	ld	ra,88(sp)
    80002812:	6446                	ld	s0,80(sp)
    80002814:	64a6                	ld	s1,72(sp)
    80002816:	6906                	ld	s2,64(sp)
    80002818:	79e2                	ld	s3,56(sp)
    8000281a:	7a42                	ld	s4,48(sp)
    8000281c:	7aa2                	ld	s5,40(sp)
    8000281e:	7b02                	ld	s6,32(sp)
    80002820:	6be2                	ld	s7,24(sp)
    80002822:	6c42                	ld	s8,16(sp)
    80002824:	6ca2                	ld	s9,8(sp)
    80002826:	6125                	addi	sp,sp,96
    80002828:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000282a:	85e6                	mv	a1,s9
    8000282c:	854a                	mv	a0,s2
    8000282e:	00000097          	auipc	ra,0x0
    80002832:	a20080e7          	jalr	-1504(ra) # 8000224e <sleep>
    havekids = 0;
    80002836:	b545                	j	800026d6 <wait_stat+0x4e>

0000000080002838 <find_decay_by_priority>:
}    

  
int
find_decay_by_priority(int priority)
{
    80002838:	1141                	addi	sp,sp,-16
    8000283a:	e422                	sd	s0,8(sp)
    8000283c:	0800                	addi	s0,sp,16
  int decay=1;
  switch(priority)
    8000283e:	4711                	li	a4,4
    80002840:	02e50663          	beq	a0,a4,8000286c <find_decay_by_priority+0x34>
    80002844:	87aa                	mv	a5,a0
    80002846:	00a74d63          	blt	a4,a0,80002860 <find_decay_by_priority+0x28>
    8000284a:	4709                	li	a4,2
    8000284c:	450d                	li	a0,3
    8000284e:	00e78663          	beq	a5,a4,8000285a <find_decay_by_priority+0x22>
    80002852:	470d                	li	a4,3
    80002854:	00e79e63          	bne	a5,a4,80002870 <find_decay_by_priority+0x38>
      case 2:
          decay=3;
          break;

      case 3:
          decay=5;
    80002858:	4515                	li	a0,5
      case 5:
          decay=25;
          break;
  }
  return decay;
}
    8000285a:	6422                	ld	s0,8(sp)
    8000285c:	0141                	addi	sp,sp,16
    8000285e:	8082                	ret
  switch(priority)
    80002860:	4715                	li	a4,5
  int decay=1;
    80002862:	4505                	li	a0,1
  switch(priority)
    80002864:	fee79be3          	bne	a5,a4,8000285a <find_decay_by_priority+0x22>
          decay=25;
    80002868:	4565                	li	a0,25
    8000286a:	bfc5                	j	8000285a <find_decay_by_priority+0x22>
          decay=7;
    8000286c:	451d                	li	a0,7
    8000286e:	b7f5                	j	8000285a <find_decay_by_priority+0x22>
  int decay=1;
    80002870:	4505                	li	a0,1
    80002872:	b7e5                	j	8000285a <find_decay_by_priority+0x22>

0000000080002874 <set_priority>:
  if((priority>5) | (priority<1)){
    80002874:	fff5071b          	addiw	a4,a0,-1
    80002878:	4791                	li	a5,4
    8000287a:	04e7e463          	bltu	a5,a4,800028c2 <set_priority+0x4e>
{
    8000287e:	1101                	addi	sp,sp,-32
    80002880:	ec06                	sd	ra,24(sp)
    80002882:	e822                	sd	s0,16(sp)
    80002884:	e426                	sd	s1,8(sp)
    80002886:	e04a                	sd	s2,0(sp)
    80002888:	1000                	addi	s0,sp,32
  int decay= find_decay_by_priority(priority);
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	fae080e7          	jalr	-82(ra) # 80002838 <find_decay_by_priority>
    80002892:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002894:	fffff097          	auipc	ra,0xfffff
    80002898:	102080e7          	jalr	258(ra) # 80001996 <myproc>
    8000289c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000289e:	ffffe097          	auipc	ra,0xffffe
    800028a2:	324080e7          	jalr	804(ra) # 80000bc2 <acquire>
  p->decay_factor=decay;  
    800028a6:	0324ac23          	sw	s2,56(s1)
  release(&p->lock);
    800028aa:	8526                	mv	a0,s1
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	3ca080e7          	jalr	970(ra) # 80000c76 <release>
  return 0;
    800028b4:	4501                	li	a0,0
}    
    800028b6:	60e2                	ld	ra,24(sp)
    800028b8:	6442                	ld	s0,16(sp)
    800028ba:	64a2                	ld	s1,8(sp)
    800028bc:	6902                	ld	s2,0(sp)
    800028be:	6105                	addi	sp,sp,32
    800028c0:	8082                	ret
    return -1;
    800028c2:	557d                	li	a0,-1
}    
    800028c4:	8082                	ret

00000000800028c6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800028c6:	7179                	addi	sp,sp,-48
    800028c8:	f406                	sd	ra,40(sp)
    800028ca:	f022                	sd	s0,32(sp)
    800028cc:	ec26                	sd	s1,24(sp)
    800028ce:	e84a                	sd	s2,16(sp)
    800028d0:	e44e                	sd	s3,8(sp)
    800028d2:	e052                	sd	s4,0(sp)
    800028d4:	1800                	addi	s0,sp,48
    800028d6:	84aa                	mv	s1,a0
    800028d8:	892e                	mv	s2,a1
    800028da:	89b2                	mv	s3,a2
    800028dc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028de:	fffff097          	auipc	ra,0xfffff
    800028e2:	0b8080e7          	jalr	184(ra) # 80001996 <myproc>
  if(user_dst){
    800028e6:	c08d                	beqz	s1,80002908 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800028e8:	86d2                	mv	a3,s4
    800028ea:	864e                	mv	a2,s3
    800028ec:	85ca                	mv	a1,s2
    800028ee:	6d28                	ld	a0,88(a0)
    800028f0:	fffff097          	auipc	ra,0xfffff
    800028f4:	d4e080e7          	jalr	-690(ra) # 8000163e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028f8:	70a2                	ld	ra,40(sp)
    800028fa:	7402                	ld	s0,32(sp)
    800028fc:	64e2                	ld	s1,24(sp)
    800028fe:	6942                	ld	s2,16(sp)
    80002900:	69a2                	ld	s3,8(sp)
    80002902:	6a02                	ld	s4,0(sp)
    80002904:	6145                	addi	sp,sp,48
    80002906:	8082                	ret
    memmove((char *)dst, src, len);
    80002908:	000a061b          	sext.w	a2,s4
    8000290c:	85ce                	mv	a1,s3
    8000290e:	854a                	mv	a0,s2
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	40a080e7          	jalr	1034(ra) # 80000d1a <memmove>
    return 0;
    80002918:	8526                	mv	a0,s1
    8000291a:	bff9                	j	800028f8 <either_copyout+0x32>

000000008000291c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000291c:	7179                	addi	sp,sp,-48
    8000291e:	f406                	sd	ra,40(sp)
    80002920:	f022                	sd	s0,32(sp)
    80002922:	ec26                	sd	s1,24(sp)
    80002924:	e84a                	sd	s2,16(sp)
    80002926:	e44e                	sd	s3,8(sp)
    80002928:	e052                	sd	s4,0(sp)
    8000292a:	1800                	addi	s0,sp,48
    8000292c:	892a                	mv	s2,a0
    8000292e:	84ae                	mv	s1,a1
    80002930:	89b2                	mv	s3,a2
    80002932:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002934:	fffff097          	auipc	ra,0xfffff
    80002938:	062080e7          	jalr	98(ra) # 80001996 <myproc>
  if(user_src){
    8000293c:	c08d                	beqz	s1,8000295e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000293e:	86d2                	mv	a3,s4
    80002940:	864e                	mv	a2,s3
    80002942:	85ca                	mv	a1,s2
    80002944:	6d28                	ld	a0,88(a0)
    80002946:	fffff097          	auipc	ra,0xfffff
    8000294a:	d84080e7          	jalr	-636(ra) # 800016ca <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000294e:	70a2                	ld	ra,40(sp)
    80002950:	7402                	ld	s0,32(sp)
    80002952:	64e2                	ld	s1,24(sp)
    80002954:	6942                	ld	s2,16(sp)
    80002956:	69a2                	ld	s3,8(sp)
    80002958:	6a02                	ld	s4,0(sp)
    8000295a:	6145                	addi	sp,sp,48
    8000295c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000295e:	000a061b          	sext.w	a2,s4
    80002962:	85ce                	mv	a1,s3
    80002964:	854a                	mv	a0,s2
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	3b4080e7          	jalr	948(ra) # 80000d1a <memmove>
    return 0;
    8000296e:	8526                	mv	a0,s1
    80002970:	bff9                	j	8000294e <either_copyin+0x32>

0000000080002972 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002972:	715d                	addi	sp,sp,-80
    80002974:	e486                	sd	ra,72(sp)
    80002976:	e0a2                	sd	s0,64(sp)
    80002978:	fc26                	sd	s1,56(sp)
    8000297a:	f84a                	sd	s2,48(sp)
    8000297c:	f44e                	sd	s3,40(sp)
    8000297e:	f052                	sd	s4,32(sp)
    80002980:	ec56                	sd	s5,24(sp)
    80002982:	e85a                	sd	s6,16(sp)
    80002984:	e45e                	sd	s7,8(sp)
    80002986:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002988:	00005517          	auipc	a0,0x5
    8000298c:	74050513          	addi	a0,a0,1856 # 800080c8 <digits+0x88>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	be4080e7          	jalr	-1052(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002998:	0000f497          	auipc	s1,0xf
    8000299c:	eb048493          	addi	s1,s1,-336 # 80011848 <proc+0x160>
    800029a0:	00015917          	auipc	s2,0x15
    800029a4:	2a890913          	addi	s2,s2,680 # 80017c48 <bcache+0x148>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029a8:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800029aa:	00006997          	auipc	s3,0x6
    800029ae:	8ce98993          	addi	s3,s3,-1842 # 80008278 <digits+0x238>
    printf("%d %s %s", p->pid, state, p->name);
    800029b2:	00006a97          	auipc	s5,0x6
    800029b6:	8cea8a93          	addi	s5,s5,-1842 # 80008280 <digits+0x240>
    printf("\n");
    800029ba:	00005a17          	auipc	s4,0x5
    800029be:	70ea0a13          	addi	s4,s4,1806 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029c2:	00006b97          	auipc	s7,0x6
    800029c6:	8f6b8b93          	addi	s7,s7,-1802 # 800082b8 <states.0>
    800029ca:	a00d                	j	800029ec <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800029cc:	ed06a583          	lw	a1,-304(a3)
    800029d0:	8556                	mv	a0,s5
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	ba2080e7          	jalr	-1118(ra) # 80000574 <printf>
    printf("\n");
    800029da:	8552                	mv	a0,s4
    800029dc:	ffffe097          	auipc	ra,0xffffe
    800029e0:	b98080e7          	jalr	-1128(ra) # 80000574 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800029e4:	19048493          	addi	s1,s1,400
    800029e8:	03248263          	beq	s1,s2,80002a0c <procdump+0x9a>
    if(p->state == UNUSED)
    800029ec:	86a6                	mv	a3,s1
    800029ee:	eb84a783          	lw	a5,-328(s1)
    800029f2:	dbed                	beqz	a5,800029e4 <procdump+0x72>
      state = "???";
    800029f4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029f6:	fcfb6be3          	bltu	s6,a5,800029cc <procdump+0x5a>
    800029fa:	02079713          	slli	a4,a5,0x20
    800029fe:	01d75793          	srli	a5,a4,0x1d
    80002a02:	97de                	add	a5,a5,s7
    80002a04:	6390                	ld	a2,0(a5)
    80002a06:	f279                	bnez	a2,800029cc <procdump+0x5a>
      state = "???";
    80002a08:	864e                	mv	a2,s3
    80002a0a:	b7c9                	j	800029cc <procdump+0x5a>
  }
}
    80002a0c:	60a6                	ld	ra,72(sp)
    80002a0e:	6406                	ld	s0,64(sp)
    80002a10:	74e2                	ld	s1,56(sp)
    80002a12:	7942                	ld	s2,48(sp)
    80002a14:	79a2                	ld	s3,40(sp)
    80002a16:	7a02                	ld	s4,32(sp)
    80002a18:	6ae2                	ld	s5,24(sp)
    80002a1a:	6b42                	ld	s6,16(sp)
    80002a1c:	6ba2                	ld	s7,8(sp)
    80002a1e:	6161                	addi	sp,sp,80
    80002a20:	8082                	ret

0000000080002a22 <proc_state_time_update>:

//our code
void proc_state_time_update(){
    80002a22:	7139                	addi	sp,sp,-64
    80002a24:	fc06                	sd	ra,56(sp)
    80002a26:	f822                	sd	s0,48(sp)
    80002a28:	f426                	sd	s1,40(sp)
    80002a2a:	f04a                	sd	s2,32(sp)
    80002a2c:	ec4e                	sd	s3,24(sp)
    80002a2e:	e852                	sd	s4,16(sp)
    80002a30:	e456                	sd	s5,8(sp)
    80002a32:	0080                	addi	s0,sp,64
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002a34:	0000f497          	auipc	s1,0xf
    80002a38:	cb448493          	addi	s1,s1,-844 # 800116e8 <proc>
    acquire(&p->lock);
    if(p->state == SLEEPING){
    80002a3c:	4989                	li	s3,2
      p->stime++;
    }
    else if(p->state == RUNNABLE){
    80002a3e:	4a0d                	li	s4,3
      p->retime++;
    }
    else if(p->state == RUNNING){
    80002a40:	4a91                	li	s5,4
  for(p = proc; p < &proc[NPROC]; p++){
    80002a42:	00015917          	auipc	s2,0x15
    80002a46:	0a690913          	addi	s2,s2,166 # 80017ae8 <tickslock>
    80002a4a:	a839                	j	80002a68 <proc_state_time_update+0x46>
      p->stime++;
    80002a4c:	1784a783          	lw	a5,376(s1)
    80002a50:	2785                	addiw	a5,a5,1
    80002a52:	16f4ac23          	sw	a5,376(s1)
      p->rutime++;
      p->B_current_burst_length++;
    }
    release(&p->lock);
    80002a56:	8526                	mv	a0,s1
    80002a58:	ffffe097          	auipc	ra,0xffffe
    80002a5c:	21e080e7          	jalr	542(ra) # 80000c76 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a60:	19048493          	addi	s1,s1,400
    80002a64:	03248f63          	beq	s1,s2,80002aa2 <proc_state_time_update+0x80>
    acquire(&p->lock);
    80002a68:	8526                	mv	a0,s1
    80002a6a:	ffffe097          	auipc	ra,0xffffe
    80002a6e:	158080e7          	jalr	344(ra) # 80000bc2 <acquire>
    if(p->state == SLEEPING){
    80002a72:	4c9c                	lw	a5,24(s1)
    80002a74:	fd378ce3          	beq	a5,s3,80002a4c <proc_state_time_update+0x2a>
    else if(p->state == RUNNABLE){
    80002a78:	01478f63          	beq	a5,s4,80002a96 <proc_state_time_update+0x74>
    else if(p->state == RUNNING){
    80002a7c:	fd579de3          	bne	a5,s5,80002a56 <proc_state_time_update+0x34>
      p->rutime++;
    80002a80:	1804a783          	lw	a5,384(s1)
    80002a84:	2785                	addiw	a5,a5,1
    80002a86:	18f4a023          	sw	a5,384(s1)
      p->B_current_burst_length++;
    80002a8a:	1884a783          	lw	a5,392(s1)
    80002a8e:	2785                	addiw	a5,a5,1
    80002a90:	18f4a423          	sw	a5,392(s1)
    80002a94:	b7c9                	j	80002a56 <proc_state_time_update+0x34>
      p->retime++;
    80002a96:	17c4a783          	lw	a5,380(s1)
    80002a9a:	2785                	addiw	a5,a5,1
    80002a9c:	16f4ae23          	sw	a5,380(s1)
    80002aa0:	bf5d                	j	80002a56 <proc_state_time_update+0x34>
  }
}
    80002aa2:	70e2                	ld	ra,56(sp)
    80002aa4:	7442                	ld	s0,48(sp)
    80002aa6:	74a2                	ld	s1,40(sp)
    80002aa8:	7902                	ld	s2,32(sp)
    80002aaa:	69e2                	ld	s3,24(sp)
    80002aac:	6a42                	ld	s4,16(sp)
    80002aae:	6aa2                	ld	s5,8(sp)
    80002ab0:	6121                	addi	sp,sp,64
    80002ab2:	8082                	ret

0000000080002ab4 <swtch>:
    80002ab4:	00153023          	sd	ra,0(a0)
    80002ab8:	00253423          	sd	sp,8(a0)
    80002abc:	e900                	sd	s0,16(a0)
    80002abe:	ed04                	sd	s1,24(a0)
    80002ac0:	03253023          	sd	s2,32(a0)
    80002ac4:	03353423          	sd	s3,40(a0)
    80002ac8:	03453823          	sd	s4,48(a0)
    80002acc:	03553c23          	sd	s5,56(a0)
    80002ad0:	05653023          	sd	s6,64(a0)
    80002ad4:	05753423          	sd	s7,72(a0)
    80002ad8:	05853823          	sd	s8,80(a0)
    80002adc:	05953c23          	sd	s9,88(a0)
    80002ae0:	07a53023          	sd	s10,96(a0)
    80002ae4:	07b53423          	sd	s11,104(a0)
    80002ae8:	0005b083          	ld	ra,0(a1)
    80002aec:	0085b103          	ld	sp,8(a1)
    80002af0:	6980                	ld	s0,16(a1)
    80002af2:	6d84                	ld	s1,24(a1)
    80002af4:	0205b903          	ld	s2,32(a1)
    80002af8:	0285b983          	ld	s3,40(a1)
    80002afc:	0305ba03          	ld	s4,48(a1)
    80002b00:	0385ba83          	ld	s5,56(a1)
    80002b04:	0405bb03          	ld	s6,64(a1)
    80002b08:	0485bb83          	ld	s7,72(a1)
    80002b0c:	0505bc03          	ld	s8,80(a1)
    80002b10:	0585bc83          	ld	s9,88(a1)
    80002b14:	0605bd03          	ld	s10,96(a1)
    80002b18:	0685bd83          	ld	s11,104(a1)
    80002b1c:	8082                	ret

0000000080002b1e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002b1e:	1141                	addi	sp,sp,-16
    80002b20:	e406                	sd	ra,8(sp)
    80002b22:	e022                	sd	s0,0(sp)
    80002b24:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b26:	00005597          	auipc	a1,0x5
    80002b2a:	7c258593          	addi	a1,a1,1986 # 800082e8 <states.0+0x30>
    80002b2e:	00015517          	auipc	a0,0x15
    80002b32:	fba50513          	addi	a0,a0,-70 # 80017ae8 <tickslock>
    80002b36:	ffffe097          	auipc	ra,0xffffe
    80002b3a:	ffc080e7          	jalr	-4(ra) # 80000b32 <initlock>
}
    80002b3e:	60a2                	ld	ra,8(sp)
    80002b40:	6402                	ld	s0,0(sp)
    80002b42:	0141                	addi	sp,sp,16
    80002b44:	8082                	ret

0000000080002b46 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b46:	1141                	addi	sp,sp,-16
    80002b48:	e422                	sd	s0,8(sp)
    80002b4a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b4c:	00003797          	auipc	a5,0x3
    80002b50:	60478793          	addi	a5,a5,1540 # 80006150 <kernelvec>
    80002b54:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b58:	6422                	ld	s0,8(sp)
    80002b5a:	0141                	addi	sp,sp,16
    80002b5c:	8082                	ret

0000000080002b5e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b5e:	1141                	addi	sp,sp,-16
    80002b60:	e406                	sd	ra,8(sp)
    80002b62:	e022                	sd	s0,0(sp)
    80002b64:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b66:	fffff097          	auipc	ra,0xfffff
    80002b6a:	e30080e7          	jalr	-464(ra) # 80001996 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b6e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b72:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b74:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002b78:	00004617          	auipc	a2,0x4
    80002b7c:	48860613          	addi	a2,a2,1160 # 80007000 <_trampoline>
    80002b80:	00004697          	auipc	a3,0x4
    80002b84:	48068693          	addi	a3,a3,1152 # 80007000 <_trampoline>
    80002b88:	8e91                	sub	a3,a3,a2
    80002b8a:	040007b7          	lui	a5,0x4000
    80002b8e:	17fd                	addi	a5,a5,-1
    80002b90:	07b2                	slli	a5,a5,0xc
    80002b92:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b94:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b98:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b9a:	180026f3          	csrr	a3,satp
    80002b9e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ba0:	7138                	ld	a4,96(a0)
    80002ba2:	6534                	ld	a3,72(a0)
    80002ba4:	6585                	lui	a1,0x1
    80002ba6:	96ae                	add	a3,a3,a1
    80002ba8:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002baa:	7138                	ld	a4,96(a0)
    80002bac:	00000697          	auipc	a3,0x0
    80002bb0:	14668693          	addi	a3,a3,326 # 80002cf2 <usertrap>
    80002bb4:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002bb6:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002bb8:	8692                	mv	a3,tp
    80002bba:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbc:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002bc0:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002bc4:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bc8:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002bcc:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bce:	6f18                	ld	a4,24(a4)
    80002bd0:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bd4:	6d2c                	ld	a1,88(a0)
    80002bd6:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002bd8:	00004717          	auipc	a4,0x4
    80002bdc:	4b870713          	addi	a4,a4,1208 # 80007090 <userret>
    80002be0:	8f11                	sub	a4,a4,a2
    80002be2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002be4:	577d                	li	a4,-1
    80002be6:	177e                	slli	a4,a4,0x3f
    80002be8:	8dd9                	or	a1,a1,a4
    80002bea:	02000537          	lui	a0,0x2000
    80002bee:	157d                	addi	a0,a0,-1
    80002bf0:	0536                	slli	a0,a0,0xd
    80002bf2:	9782                	jalr	a5
}
    80002bf4:	60a2                	ld	ra,8(sp)
    80002bf6:	6402                	ld	s0,0(sp)
    80002bf8:	0141                	addi	sp,sp,16
    80002bfa:	8082                	ret

0000000080002bfc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bfc:	1101                	addi	sp,sp,-32
    80002bfe:	ec06                	sd	ra,24(sp)
    80002c00:	e822                	sd	s0,16(sp)
    80002c02:	e426                	sd	s1,8(sp)
    80002c04:	e04a                	sd	s2,0(sp)
    80002c06:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002c08:	00015917          	auipc	s2,0x15
    80002c0c:	ee090913          	addi	s2,s2,-288 # 80017ae8 <tickslock>
    80002c10:	854a                	mv	a0,s2
    80002c12:	ffffe097          	auipc	ra,0xffffe
    80002c16:	fb0080e7          	jalr	-80(ra) # 80000bc2 <acquire>
  ticks++;
    80002c1a:	00006497          	auipc	s1,0x6
    80002c1e:	41648493          	addi	s1,s1,1046 # 80009030 <ticks>
    80002c22:	409c                	lw	a5,0(s1)
    80002c24:	2785                	addiw	a5,a5,1
    80002c26:	c09c                	sw	a5,0(s1)
  proc_state_time_update(); // our code
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	dfa080e7          	jalr	-518(ra) # 80002a22 <proc_state_time_update>
  wakeup(&ticks);
    80002c30:	8526                	mv	a0,s1
    80002c32:	fffff097          	auipc	ra,0xfffff
    80002c36:	7a8080e7          	jalr	1960(ra) # 800023da <wakeup>
  release(&tickslock);
    80002c3a:	854a                	mv	a0,s2
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	03a080e7          	jalr	58(ra) # 80000c76 <release>
}
    80002c44:	60e2                	ld	ra,24(sp)
    80002c46:	6442                	ld	s0,16(sp)
    80002c48:	64a2                	ld	s1,8(sp)
    80002c4a:	6902                	ld	s2,0(sp)
    80002c4c:	6105                	addi	sp,sp,32
    80002c4e:	8082                	ret

0000000080002c50 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c50:	1101                	addi	sp,sp,-32
    80002c52:	ec06                	sd	ra,24(sp)
    80002c54:	e822                	sd	s0,16(sp)
    80002c56:	e426                	sd	s1,8(sp)
    80002c58:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c5a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c5e:	00074d63          	bltz	a4,80002c78 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c62:	57fd                	li	a5,-1
    80002c64:	17fe                	slli	a5,a5,0x3f
    80002c66:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c68:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c6a:	06f70363          	beq	a4,a5,80002cd0 <devintr+0x80>
  }
}
    80002c6e:	60e2                	ld	ra,24(sp)
    80002c70:	6442                	ld	s0,16(sp)
    80002c72:	64a2                	ld	s1,8(sp)
    80002c74:	6105                	addi	sp,sp,32
    80002c76:	8082                	ret
     (scause & 0xff) == 9){
    80002c78:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c7c:	46a5                	li	a3,9
    80002c7e:	fed792e3          	bne	a5,a3,80002c62 <devintr+0x12>
    int irq = plic_claim();
    80002c82:	00003097          	auipc	ra,0x3
    80002c86:	5d6080e7          	jalr	1494(ra) # 80006258 <plic_claim>
    80002c8a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c8c:	47a9                	li	a5,10
    80002c8e:	02f50763          	beq	a0,a5,80002cbc <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c92:	4785                	li	a5,1
    80002c94:	02f50963          	beq	a0,a5,80002cc6 <devintr+0x76>
    return 1;
    80002c98:	4505                	li	a0,1
    } else if(irq){
    80002c9a:	d8f1                	beqz	s1,80002c6e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c9c:	85a6                	mv	a1,s1
    80002c9e:	00005517          	auipc	a0,0x5
    80002ca2:	65250513          	addi	a0,a0,1618 # 800082f0 <states.0+0x38>
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	8ce080e7          	jalr	-1842(ra) # 80000574 <printf>
      plic_complete(irq);
    80002cae:	8526                	mv	a0,s1
    80002cb0:	00003097          	auipc	ra,0x3
    80002cb4:	5cc080e7          	jalr	1484(ra) # 8000627c <plic_complete>
    return 1;
    80002cb8:	4505                	li	a0,1
    80002cba:	bf55                	j	80002c6e <devintr+0x1e>
      uartintr();
    80002cbc:	ffffe097          	auipc	ra,0xffffe
    80002cc0:	cca080e7          	jalr	-822(ra) # 80000986 <uartintr>
    80002cc4:	b7ed                	j	80002cae <devintr+0x5e>
      virtio_disk_intr();
    80002cc6:	00004097          	auipc	ra,0x4
    80002cca:	a48080e7          	jalr	-1464(ra) # 8000670e <virtio_disk_intr>
    80002cce:	b7c5                	j	80002cae <devintr+0x5e>
    if(cpuid() == 0){
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	c9a080e7          	jalr	-870(ra) # 8000196a <cpuid>
    80002cd8:	c901                	beqz	a0,80002ce8 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002cda:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002cde:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ce0:	14479073          	csrw	sip,a5
    return 2;
    80002ce4:	4509                	li	a0,2
    80002ce6:	b761                	j	80002c6e <devintr+0x1e>
      clockintr();
    80002ce8:	00000097          	auipc	ra,0x0
    80002cec:	f14080e7          	jalr	-236(ra) # 80002bfc <clockintr>
    80002cf0:	b7ed                	j	80002cda <devintr+0x8a>

0000000080002cf2 <usertrap>:
{
    80002cf2:	1101                	addi	sp,sp,-32
    80002cf4:	ec06                	sd	ra,24(sp)
    80002cf6:	e822                	sd	s0,16(sp)
    80002cf8:	e426                	sd	s1,8(sp)
    80002cfa:	e04a                	sd	s2,0(sp)
    80002cfc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cfe:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002d02:	1007f793          	andi	a5,a5,256
    80002d06:	e3ad                	bnez	a5,80002d68 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d08:	00003797          	auipc	a5,0x3
    80002d0c:	44878793          	addi	a5,a5,1096 # 80006150 <kernelvec>
    80002d10:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002d14:	fffff097          	auipc	ra,0xfffff
    80002d18:	c82080e7          	jalr	-894(ra) # 80001996 <myproc>
    80002d1c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002d1e:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d20:	14102773          	csrr	a4,sepc
    80002d24:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d26:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002d2a:	47a1                	li	a5,8
    80002d2c:	04f71c63          	bne	a4,a5,80002d84 <usertrap+0x92>
    if(p->killed)
    80002d30:	551c                	lw	a5,40(a0)
    80002d32:	e3b9                	bnez	a5,80002d78 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002d34:	70b8                	ld	a4,96(s1)
    80002d36:	6f1c                	ld	a5,24(a4)
    80002d38:	0791                	addi	a5,a5,4
    80002d3a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d3c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d40:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d44:	10079073          	csrw	sstatus,a5
    syscall();
    80002d48:	00000097          	auipc	ra,0x0
    80002d4c:	2f0080e7          	jalr	752(ra) # 80003038 <syscall>
  if(p->killed)
    80002d50:	549c                	lw	a5,40(s1)
    80002d52:	e3c5                	bnez	a5,80002df2 <usertrap+0x100>
  usertrapret();
    80002d54:	00000097          	auipc	ra,0x0
    80002d58:	e0a080e7          	jalr	-502(ra) # 80002b5e <usertrapret>
}
    80002d5c:	60e2                	ld	ra,24(sp)
    80002d5e:	6442                	ld	s0,16(sp)
    80002d60:	64a2                	ld	s1,8(sp)
    80002d62:	6902                	ld	s2,0(sp)
    80002d64:	6105                	addi	sp,sp,32
    80002d66:	8082                	ret
    panic("usertrap: not from user mode");
    80002d68:	00005517          	auipc	a0,0x5
    80002d6c:	5a850513          	addi	a0,a0,1448 # 80008310 <states.0+0x58>
    80002d70:	ffffd097          	auipc	ra,0xffffd
    80002d74:	7ba080e7          	jalr	1978(ra) # 8000052a <panic>
      exit(-1);
    80002d78:	557d                	li	a0,-1
    80002d7a:	fffff097          	auipc	ra,0xfffff
    80002d7e:	730080e7          	jalr	1840(ra) # 800024aa <exit>
    80002d82:	bf4d                	j	80002d34 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002d84:	00000097          	auipc	ra,0x0
    80002d88:	ecc080e7          	jalr	-308(ra) # 80002c50 <devintr>
    80002d8c:	892a                	mv	s2,a0
    80002d8e:	c501                	beqz	a0,80002d96 <usertrap+0xa4>
  if(p->killed)
    80002d90:	549c                	lw	a5,40(s1)
    80002d92:	c3a1                	beqz	a5,80002dd2 <usertrap+0xe0>
    80002d94:	a815                	j	80002dc8 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d96:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d9a:	5890                	lw	a2,48(s1)
    80002d9c:	00005517          	auipc	a0,0x5
    80002da0:	59450513          	addi	a0,a0,1428 # 80008330 <states.0+0x78>
    80002da4:	ffffd097          	auipc	ra,0xffffd
    80002da8:	7d0080e7          	jalr	2000(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dac:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002db0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002db4:	00005517          	auipc	a0,0x5
    80002db8:	5ac50513          	addi	a0,a0,1452 # 80008360 <states.0+0xa8>
    80002dbc:	ffffd097          	auipc	ra,0xffffd
    80002dc0:	7b8080e7          	jalr	1976(ra) # 80000574 <printf>
    p->killed = 1;
    80002dc4:	4785                	li	a5,1
    80002dc6:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002dc8:	557d                	li	a0,-1
    80002dca:	fffff097          	auipc	ra,0xfffff
    80002dce:	6e0080e7          	jalr	1760(ra) # 800024aa <exit>
  if(which_dev == 2){
    80002dd2:	4789                	li	a5,2
    80002dd4:	f8f910e3          	bne	s2,a5,80002d54 <usertrap+0x62>
    if(ticks % QUANTUM == 0){
    80002dd8:	00006797          	auipc	a5,0x6
    80002ddc:	2587a783          	lw	a5,600(a5) # 80009030 <ticks>
    80002de0:	4715                	li	a4,5
    80002de2:	02e7f7bb          	remuw	a5,a5,a4
    80002de6:	f7bd                	bnez	a5,80002d54 <usertrap+0x62>
      yield();
    80002de8:	fffff097          	auipc	ra,0xfffff
    80002dec:	42a080e7          	jalr	1066(ra) # 80002212 <yield>
    80002df0:	b795                	j	80002d54 <usertrap+0x62>
  int which_dev = 0;
    80002df2:	4901                	li	s2,0
    80002df4:	bfd1                	j	80002dc8 <usertrap+0xd6>

0000000080002df6 <kerneltrap>:
{
    80002df6:	7179                	addi	sp,sp,-48
    80002df8:	f406                	sd	ra,40(sp)
    80002dfa:	f022                	sd	s0,32(sp)
    80002dfc:	ec26                	sd	s1,24(sp)
    80002dfe:	e84a                	sd	s2,16(sp)
    80002e00:	e44e                	sd	s3,8(sp)
    80002e02:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e04:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e08:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e0c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002e10:	1004f793          	andi	a5,s1,256
    80002e14:	cb85                	beqz	a5,80002e44 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002e16:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002e1a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002e1c:	ef85                	bnez	a5,80002e54 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002e1e:	00000097          	auipc	ra,0x0
    80002e22:	e32080e7          	jalr	-462(ra) # 80002c50 <devintr>
    80002e26:	cd1d                	beqz	a0,80002e64 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e28:	4789                	li	a5,2
    80002e2a:	06f50a63          	beq	a0,a5,80002e9e <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e2e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e32:	10049073          	csrw	sstatus,s1
}
    80002e36:	70a2                	ld	ra,40(sp)
    80002e38:	7402                	ld	s0,32(sp)
    80002e3a:	64e2                	ld	s1,24(sp)
    80002e3c:	6942                	ld	s2,16(sp)
    80002e3e:	69a2                	ld	s3,8(sp)
    80002e40:	6145                	addi	sp,sp,48
    80002e42:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e44:	00005517          	auipc	a0,0x5
    80002e48:	53c50513          	addi	a0,a0,1340 # 80008380 <states.0+0xc8>
    80002e4c:	ffffd097          	auipc	ra,0xffffd
    80002e50:	6de080e7          	jalr	1758(ra) # 8000052a <panic>
    panic("kerneltrap: interrupts enabled");
    80002e54:	00005517          	auipc	a0,0x5
    80002e58:	55450513          	addi	a0,a0,1364 # 800083a8 <states.0+0xf0>
    80002e5c:	ffffd097          	auipc	ra,0xffffd
    80002e60:	6ce080e7          	jalr	1742(ra) # 8000052a <panic>
    printf("scause %p\n", scause);
    80002e64:	85ce                	mv	a1,s3
    80002e66:	00005517          	auipc	a0,0x5
    80002e6a:	56250513          	addi	a0,a0,1378 # 800083c8 <states.0+0x110>
    80002e6e:	ffffd097          	auipc	ra,0xffffd
    80002e72:	706080e7          	jalr	1798(ra) # 80000574 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e76:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e7a:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e7e:	00005517          	auipc	a0,0x5
    80002e82:	55a50513          	addi	a0,a0,1370 # 800083d8 <states.0+0x120>
    80002e86:	ffffd097          	auipc	ra,0xffffd
    80002e8a:	6ee080e7          	jalr	1774(ra) # 80000574 <printf>
    panic("kerneltrap");
    80002e8e:	00005517          	auipc	a0,0x5
    80002e92:	56250513          	addi	a0,a0,1378 # 800083f0 <states.0+0x138>
    80002e96:	ffffd097          	auipc	ra,0xffffd
    80002e9a:	694080e7          	jalr	1684(ra) # 8000052a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e9e:	fffff097          	auipc	ra,0xfffff
    80002ea2:	af8080e7          	jalr	-1288(ra) # 80001996 <myproc>
    80002ea6:	d541                	beqz	a0,80002e2e <kerneltrap+0x38>
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	aee080e7          	jalr	-1298(ra) # 80001996 <myproc>
    80002eb0:	4d18                	lw	a4,24(a0)
    80002eb2:	4791                	li	a5,4
    80002eb4:	f6f71de3          	bne	a4,a5,80002e2e <kerneltrap+0x38>
    yield();
    80002eb8:	fffff097          	auipc	ra,0xfffff
    80002ebc:	35a080e7          	jalr	858(ra) # 80002212 <yield>
    80002ec0:	b7bd                	j	80002e2e <kerneltrap+0x38>

0000000080002ec2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ec2:	1101                	addi	sp,sp,-32
    80002ec4:	ec06                	sd	ra,24(sp)
    80002ec6:	e822                	sd	s0,16(sp)
    80002ec8:	e426                	sd	s1,8(sp)
    80002eca:	1000                	addi	s0,sp,32
    80002ecc:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ece:	fffff097          	auipc	ra,0xfffff
    80002ed2:	ac8080e7          	jalr	-1336(ra) # 80001996 <myproc>
  switch (n) {
    80002ed6:	4795                	li	a5,5
    80002ed8:	0497e163          	bltu	a5,s1,80002f1a <argraw+0x58>
    80002edc:	048a                	slli	s1,s1,0x2
    80002ede:	00005717          	auipc	a4,0x5
    80002ee2:	66a70713          	addi	a4,a4,1642 # 80008548 <states.0+0x290>
    80002ee6:	94ba                	add	s1,s1,a4
    80002ee8:	409c                	lw	a5,0(s1)
    80002eea:	97ba                	add	a5,a5,a4
    80002eec:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002eee:	713c                	ld	a5,96(a0)
    80002ef0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ef2:	60e2                	ld	ra,24(sp)
    80002ef4:	6442                	ld	s0,16(sp)
    80002ef6:	64a2                	ld	s1,8(sp)
    80002ef8:	6105                	addi	sp,sp,32
    80002efa:	8082                	ret
    return p->trapframe->a1;
    80002efc:	713c                	ld	a5,96(a0)
    80002efe:	7fa8                	ld	a0,120(a5)
    80002f00:	bfcd                	j	80002ef2 <argraw+0x30>
    return p->trapframe->a2;
    80002f02:	713c                	ld	a5,96(a0)
    80002f04:	63c8                	ld	a0,128(a5)
    80002f06:	b7f5                	j	80002ef2 <argraw+0x30>
    return p->trapframe->a3;
    80002f08:	713c                	ld	a5,96(a0)
    80002f0a:	67c8                	ld	a0,136(a5)
    80002f0c:	b7dd                	j	80002ef2 <argraw+0x30>
    return p->trapframe->a4;
    80002f0e:	713c                	ld	a5,96(a0)
    80002f10:	6bc8                	ld	a0,144(a5)
    80002f12:	b7c5                	j	80002ef2 <argraw+0x30>
    return p->trapframe->a5;
    80002f14:	713c                	ld	a5,96(a0)
    80002f16:	6fc8                	ld	a0,152(a5)
    80002f18:	bfe9                	j	80002ef2 <argraw+0x30>
  panic("argraw");
    80002f1a:	00005517          	auipc	a0,0x5
    80002f1e:	4e650513          	addi	a0,a0,1254 # 80008400 <states.0+0x148>
    80002f22:	ffffd097          	auipc	ra,0xffffd
    80002f26:	608080e7          	jalr	1544(ra) # 8000052a <panic>

0000000080002f2a <fetchaddr>:
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	e426                	sd	s1,8(sp)
    80002f32:	e04a                	sd	s2,0(sp)
    80002f34:	1000                	addi	s0,sp,32
    80002f36:	84aa                	mv	s1,a0
    80002f38:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002f3a:	fffff097          	auipc	ra,0xfffff
    80002f3e:	a5c080e7          	jalr	-1444(ra) # 80001996 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002f42:	693c                	ld	a5,80(a0)
    80002f44:	02f4f863          	bgeu	s1,a5,80002f74 <fetchaddr+0x4a>
    80002f48:	00848713          	addi	a4,s1,8
    80002f4c:	02e7e663          	bltu	a5,a4,80002f78 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f50:	46a1                	li	a3,8
    80002f52:	8626                	mv	a2,s1
    80002f54:	85ca                	mv	a1,s2
    80002f56:	6d28                	ld	a0,88(a0)
    80002f58:	ffffe097          	auipc	ra,0xffffe
    80002f5c:	772080e7          	jalr	1906(ra) # 800016ca <copyin>
    80002f60:	00a03533          	snez	a0,a0
    80002f64:	40a00533          	neg	a0,a0
}
    80002f68:	60e2                	ld	ra,24(sp)
    80002f6a:	6442                	ld	s0,16(sp)
    80002f6c:	64a2                	ld	s1,8(sp)
    80002f6e:	6902                	ld	s2,0(sp)
    80002f70:	6105                	addi	sp,sp,32
    80002f72:	8082                	ret
    return -1;
    80002f74:	557d                	li	a0,-1
    80002f76:	bfcd                	j	80002f68 <fetchaddr+0x3e>
    80002f78:	557d                	li	a0,-1
    80002f7a:	b7fd                	j	80002f68 <fetchaddr+0x3e>

0000000080002f7c <fetchstr>:
{
    80002f7c:	7179                	addi	sp,sp,-48
    80002f7e:	f406                	sd	ra,40(sp)
    80002f80:	f022                	sd	s0,32(sp)
    80002f82:	ec26                	sd	s1,24(sp)
    80002f84:	e84a                	sd	s2,16(sp)
    80002f86:	e44e                	sd	s3,8(sp)
    80002f88:	1800                	addi	s0,sp,48
    80002f8a:	892a                	mv	s2,a0
    80002f8c:	84ae                	mv	s1,a1
    80002f8e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f90:	fffff097          	auipc	ra,0xfffff
    80002f94:	a06080e7          	jalr	-1530(ra) # 80001996 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002f98:	86ce                	mv	a3,s3
    80002f9a:	864a                	mv	a2,s2
    80002f9c:	85a6                	mv	a1,s1
    80002f9e:	6d28                	ld	a0,88(a0)
    80002fa0:	ffffe097          	auipc	ra,0xffffe
    80002fa4:	7b8080e7          	jalr	1976(ra) # 80001758 <copyinstr>
  if(err < 0)
    80002fa8:	00054763          	bltz	a0,80002fb6 <fetchstr+0x3a>
  return strlen(buf);
    80002fac:	8526                	mv	a0,s1
    80002fae:	ffffe097          	auipc	ra,0xffffe
    80002fb2:	e94080e7          	jalr	-364(ra) # 80000e42 <strlen>
}
    80002fb6:	70a2                	ld	ra,40(sp)
    80002fb8:	7402                	ld	s0,32(sp)
    80002fba:	64e2                	ld	s1,24(sp)
    80002fbc:	6942                	ld	s2,16(sp)
    80002fbe:	69a2                	ld	s3,8(sp)
    80002fc0:	6145                	addi	sp,sp,48
    80002fc2:	8082                	ret

0000000080002fc4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002fc4:	1101                	addi	sp,sp,-32
    80002fc6:	ec06                	sd	ra,24(sp)
    80002fc8:	e822                	sd	s0,16(sp)
    80002fca:	e426                	sd	s1,8(sp)
    80002fcc:	1000                	addi	s0,sp,32
    80002fce:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fd0:	00000097          	auipc	ra,0x0
    80002fd4:	ef2080e7          	jalr	-270(ra) # 80002ec2 <argraw>
    80002fd8:	c088                	sw	a0,0(s1)
  return 0;
}
    80002fda:	4501                	li	a0,0
    80002fdc:	60e2                	ld	ra,24(sp)
    80002fde:	6442                	ld	s0,16(sp)
    80002fe0:	64a2                	ld	s1,8(sp)
    80002fe2:	6105                	addi	sp,sp,32
    80002fe4:	8082                	ret

0000000080002fe6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002fe6:	1101                	addi	sp,sp,-32
    80002fe8:	ec06                	sd	ra,24(sp)
    80002fea:	e822                	sd	s0,16(sp)
    80002fec:	e426                	sd	s1,8(sp)
    80002fee:	1000                	addi	s0,sp,32
    80002ff0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002ff2:	00000097          	auipc	ra,0x0
    80002ff6:	ed0080e7          	jalr	-304(ra) # 80002ec2 <argraw>
    80002ffa:	e088                	sd	a0,0(s1)
  return 0;
}
    80002ffc:	4501                	li	a0,0
    80002ffe:	60e2                	ld	ra,24(sp)
    80003000:	6442                	ld	s0,16(sp)
    80003002:	64a2                	ld	s1,8(sp)
    80003004:	6105                	addi	sp,sp,32
    80003006:	8082                	ret

0000000080003008 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003008:	1101                	addi	sp,sp,-32
    8000300a:	ec06                	sd	ra,24(sp)
    8000300c:	e822                	sd	s0,16(sp)
    8000300e:	e426                	sd	s1,8(sp)
    80003010:	e04a                	sd	s2,0(sp)
    80003012:	1000                	addi	s0,sp,32
    80003014:	84ae                	mv	s1,a1
    80003016:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003018:	00000097          	auipc	ra,0x0
    8000301c:	eaa080e7          	jalr	-342(ra) # 80002ec2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003020:	864a                	mv	a2,s2
    80003022:	85a6                	mv	a1,s1
    80003024:	00000097          	auipc	ra,0x0
    80003028:	f58080e7          	jalr	-168(ra) # 80002f7c <fetchstr>
}
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	64a2                	ld	s1,8(sp)
    80003032:	6902                	ld	s2,0(sp)
    80003034:	6105                	addi	sp,sp,32
    80003036:	8082                	ret

0000000080003038 <syscall>:



void
syscall(void) //our code - original code with our adittions
{
    80003038:	7179                	addi	sp,sp,-48
    8000303a:	f406                	sd	ra,40(sp)
    8000303c:	f022                	sd	s0,32(sp)
    8000303e:	ec26                	sd	s1,24(sp)
    80003040:	e84a                	sd	s2,16(sp)
    80003042:	e44e                	sd	s3,8(sp)
    80003044:	e052                	sd	s4,0(sp)
    80003046:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003048:	fffff097          	auipc	ra,0xfffff
    8000304c:	94e080e7          	jalr	-1714(ra) # 80001996 <myproc>
    80003050:	84aa                	mv	s1,a0
  static char* syscall_names_table[]={"ZERO", "fork", "exit", "wait", "pipe", "read", "kill", "exec",
                                     "fstat", "chdir", "dup", "getpid", "sbrk", "sleep", "uptime", "open",
                                      "write", "mknod", "unlink", "link", "mkdir", "close", "trace", "wait_stat", "set_priority"};


  num = p->trapframe->a7;//returns num of system call
    80003052:	06053903          	ld	s2,96(a0)
    80003056:	0a893783          	ld	a5,168(s2)
    8000305a:	0007899b          	sext.w	s3,a5

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000305e:	37fd                	addiw	a5,a5,-1
    80003060:	475d                	li	a4,23
    80003062:	08f76b63          	bltu	a4,a5,800030f8 <syscall+0xc0>
    80003066:	00399713          	slli	a4,s3,0x3
    8000306a:	00005797          	auipc	a5,0x5
    8000306e:	4f678793          	addi	a5,a5,1270 # 80008560 <syscalls>
    80003072:	97ba                	add	a5,a5,a4
    80003074:	639c                	ld	a5,0(a5)
    80003076:	c3c9                	beqz	a5,800030f8 <syscall+0xc0>
    int system_call_arguments = p->trapframe->a0;//get first system call argument
    80003078:	07093a03          	ld	s4,112(s2)
    p->trapframe->a0 = syscalls[num](); 
    8000307c:	9782                	jalr	a5
    8000307e:	06a93823          	sd	a0,112(s2)
    if(p->trace_mask & (1<<num)){ //in this case - num'th syscall is traced
    80003082:	58dc                	lw	a5,52(s1)
    80003084:	4137d7bb          	sraw	a5,a5,s3
    80003088:	8b85                	andi	a5,a5,1
    8000308a:	c7d1                	beqz	a5,80003116 <syscall+0xde>
      int process_ID = p->pid;
    8000308c:	588c                	lw	a1,48(s1)
      // char* system_call_name= should make an array for it but where to put it?
      char* system_call_name= syscall_names_table[num];
      int return_value = p->trapframe->a0;
    8000308e:	70bc                	ld	a5,96(s1)
    80003090:	5bb4                	lw	a3,112(a5)
      if (num==1){
    80003092:	4785                	li	a5,1
    80003094:	02f98963          	beq	s3,a5,800030c6 <syscall+0x8e>
      char* system_call_name= syscall_names_table[num];
    80003098:	00399713          	slli	a4,s3,0x3
    8000309c:	00005797          	auipc	a5,0x5
    800030a0:	4c478793          	addi	a5,a5,1220 # 80008560 <syscalls>
    800030a4:	97ba                	add	a5,a5,a4
    800030a6:	67f0                	ld	a2,200(a5)
        printf("%d: syscall %s NULL -> %d\n", process_ID, system_call_name, return_value);
      }
      else if((num==6) | (num==12)){ //in this case - print args
    800030a8:	ffa98793          	addi	a5,s3,-6
    800030ac:	cb95                	beqz	a5,800030e0 <syscall+0xa8>
    800030ae:	19d1                	addi	s3,s3,-12
    800030b0:	02098863          	beqz	s3,800030e0 <syscall+0xa8>
        printf("%d: syscall %s %d-> %d\n", process_ID, system_call_name, system_call_arguments, return_value);
      }  
      else{ //don't print args
        printf("%d: syscall %s -> %d\n", process_ID, system_call_name, return_value);
    800030b4:	00005517          	auipc	a0,0x5
    800030b8:	39450513          	addi	a0,a0,916 # 80008448 <states.0+0x190>
    800030bc:	ffffd097          	auipc	ra,0xffffd
    800030c0:	4b8080e7          	jalr	1208(ra) # 80000574 <printf>
    800030c4:	a889                	j	80003116 <syscall+0xde>
        printf("%d: syscall %s NULL -> %d\n", process_ID, system_call_name, return_value);
    800030c6:	00005617          	auipc	a2,0x5
    800030ca:	34260613          	addi	a2,a2,834 # 80008408 <states.0+0x150>
    800030ce:	00005517          	auipc	a0,0x5
    800030d2:	34250513          	addi	a0,a0,834 # 80008410 <states.0+0x158>
    800030d6:	ffffd097          	auipc	ra,0xffffd
    800030da:	49e080e7          	jalr	1182(ra) # 80000574 <printf>
    800030de:	a825                	j	80003116 <syscall+0xde>
        printf("%d: syscall %s %d-> %d\n", process_ID, system_call_name, system_call_arguments, return_value);
    800030e0:	8736                	mv	a4,a3
    800030e2:	000a069b          	sext.w	a3,s4
    800030e6:	00005517          	auipc	a0,0x5
    800030ea:	34a50513          	addi	a0,a0,842 # 80008430 <states.0+0x178>
    800030ee:	ffffd097          	auipc	ra,0xffffd
    800030f2:	486080e7          	jalr	1158(ra) # 80000574 <printf>
    800030f6:	a005                	j	80003116 <syscall+0xde>
      }
    }
  } 
  else {
    printf("%d %s: unknown sys call %d\n",
    800030f8:	86ce                	mv	a3,s3
    800030fa:	16048613          	addi	a2,s1,352
    800030fe:	588c                	lw	a1,48(s1)
    80003100:	00005517          	auipc	a0,0x5
    80003104:	36050513          	addi	a0,a0,864 # 80008460 <states.0+0x1a8>
    80003108:	ffffd097          	auipc	ra,0xffffd
    8000310c:	46c080e7          	jalr	1132(ra) # 80000574 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003110:	70bc                	ld	a5,96(s1)
    80003112:	577d                	li	a4,-1
    80003114:	fbb8                	sd	a4,112(a5)
  }
}
    80003116:	70a2                	ld	ra,40(sp)
    80003118:	7402                	ld	s0,32(sp)
    8000311a:	64e2                	ld	s1,24(sp)
    8000311c:	6942                	ld	s2,16(sp)
    8000311e:	69a2                	ld	s3,8(sp)
    80003120:	6a02                	ld	s4,0(sp)
    80003122:	6145                	addi	sp,sp,48
    80003124:	8082                	ret

0000000080003126 <sys_set_priority>:
#include "spinlock.h"
#include "proc.h"

uint64 //our code
sys_set_priority(void) 
{
    80003126:	1101                	addi	sp,sp,-32
    80003128:	ec06                	sd	ra,24(sp)
    8000312a:	e822                	sd	s0,16(sp)
    8000312c:	1000                	addi	s0,sp,32
  //first moving user argument to the kernel
  int priority;
  if(argint(0, &priority) < 0){ 
    8000312e:	fec40593          	addi	a1,s0,-20
    80003132:	4501                	li	a0,0
    80003134:	00000097          	auipc	ra,0x0
    80003138:	e90080e7          	jalr	-368(ra) # 80002fc4 <argint>
    8000313c:	87aa                	mv	a5,a0
    return -1;
    8000313e:	557d                	li	a0,-1
  if(argint(0, &priority) < 0){ 
    80003140:	0007c863          	bltz	a5,80003150 <sys_set_priority+0x2a>
  }
  //second - calling set_priority function
  return set_priority(priority);
    80003144:	fec42503          	lw	a0,-20(s0)
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	72c080e7          	jalr	1836(ra) # 80002874 <set_priority>
}
    80003150:	60e2                	ld	ra,24(sp)
    80003152:	6442                	ld	s0,16(sp)
    80003154:	6105                	addi	sp,sp,32
    80003156:	8082                	ret

0000000080003158 <sys_wait_stat>:


uint64 //our code
sys_wait_stat(void) 
{
    80003158:	1101                	addi	sp,sp,-32
    8000315a:	ec06                	sd	ra,24(sp)
    8000315c:	e822                	sd	s0,16(sp)
    8000315e:	1000                	addi	s0,sp,32
  //first moving user arguments to the kernel
  uint64 status;
  uint64 performance;
  if(argaddr(0, &status) < 0){ 
    80003160:	fe840593          	addi	a1,s0,-24
    80003164:	4501                	li	a0,0
    80003166:	00000097          	auipc	ra,0x0
    8000316a:	e80080e7          	jalr	-384(ra) # 80002fe6 <argaddr>
    return -1;
    8000316e:	57fd                	li	a5,-1
  if(argaddr(0, &status) < 0){ 
    80003170:	02054563          	bltz	a0,8000319a <sys_wait_stat+0x42>
  }
  if(argaddr(1, &performance) < 0){ 
    80003174:	fe040593          	addi	a1,s0,-32
    80003178:	4505                	li	a0,1
    8000317a:	00000097          	auipc	ra,0x0
    8000317e:	e6c080e7          	jalr	-404(ra) # 80002fe6 <argaddr>
    return -1; 
    80003182:	57fd                	li	a5,-1
  if(argaddr(1, &performance) < 0){ 
    80003184:	00054b63          	bltz	a0,8000319a <sys_wait_stat+0x42>
  }
  //second - calling wait_stat function
  return wait_stat(status, performance);
    80003188:	fe043583          	ld	a1,-32(s0)
    8000318c:	fe843503          	ld	a0,-24(s0)
    80003190:	fffff097          	auipc	ra,0xfffff
    80003194:	4f8080e7          	jalr	1272(ra) # 80002688 <wait_stat>
    80003198:	87aa                	mv	a5,a0
}
    8000319a:	853e                	mv	a0,a5
    8000319c:	60e2                	ld	ra,24(sp)
    8000319e:	6442                	ld	s0,16(sp)
    800031a0:	6105                	addi	sp,sp,32
    800031a2:	8082                	ret

00000000800031a4 <sys_trace>:

uint64 //our code
sys_trace(void) 
{
    800031a4:	1101                	addi	sp,sp,-32
    800031a6:	ec06                	sd	ra,24(sp)
    800031a8:	e822                	sd	s0,16(sp)
    800031aa:	1000                	addi	s0,sp,32
  //first moving user arguments - pid and mask- to the kernel
  int mask;
  int pid;
  if(argint(0, &mask) < 0){ 
    800031ac:	fec40593          	addi	a1,s0,-20
    800031b0:	4501                	li	a0,0
    800031b2:	00000097          	auipc	ra,0x0
    800031b6:	e12080e7          	jalr	-494(ra) # 80002fc4 <argint>
    return -1;
    800031ba:	57fd                	li	a5,-1
  if(argint(0, &mask) < 0){ 
    800031bc:	02054563          	bltz	a0,800031e6 <sys_trace+0x42>
  }
  if(argint(1, &pid) < 0){
    800031c0:	fe840593          	addi	a1,s0,-24
    800031c4:	4505                	li	a0,1
    800031c6:	00000097          	auipc	ra,0x0
    800031ca:	dfe080e7          	jalr	-514(ra) # 80002fc4 <argint>
    return -1; 
    800031ce:	57fd                	li	a5,-1
  if(argint(1, &pid) < 0){
    800031d0:	00054b63          	bltz	a0,800031e6 <sys_trace+0x42>
  }
  //second - calling trace function
  return trace(mask, pid);
    800031d4:	fe842583          	lw	a1,-24(s0)
    800031d8:	fec42503          	lw	a0,-20(s0)
    800031dc:	fffff097          	auipc	ra,0xfffff
    800031e0:	442080e7          	jalr	1090(ra) # 8000261e <trace>
    800031e4:	87aa                	mv	a5,a0
}
    800031e6:	853e                	mv	a0,a5
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	6105                	addi	sp,sp,32
    800031ee:	8082                	ret

00000000800031f0 <sys_exit>:

uint64
sys_exit(void)
{
    800031f0:	1101                	addi	sp,sp,-32
    800031f2:	ec06                	sd	ra,24(sp)
    800031f4:	e822                	sd	s0,16(sp)
    800031f6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800031f8:	fec40593          	addi	a1,s0,-20
    800031fc:	4501                	li	a0,0
    800031fe:	00000097          	auipc	ra,0x0
    80003202:	dc6080e7          	jalr	-570(ra) # 80002fc4 <argint>
    return -1;
    80003206:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003208:	00054963          	bltz	a0,8000321a <sys_exit+0x2a>
  exit(n);
    8000320c:	fec42503          	lw	a0,-20(s0)
    80003210:	fffff097          	auipc	ra,0xfffff
    80003214:	29a080e7          	jalr	666(ra) # 800024aa <exit>
  return 0;  // not reached
    80003218:	4781                	li	a5,0
}
    8000321a:	853e                	mv	a0,a5
    8000321c:	60e2                	ld	ra,24(sp)
    8000321e:	6442                	ld	s0,16(sp)
    80003220:	6105                	addi	sp,sp,32
    80003222:	8082                	ret

0000000080003224 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003224:	1141                	addi	sp,sp,-16
    80003226:	e406                	sd	ra,8(sp)
    80003228:	e022                	sd	s0,0(sp)
    8000322a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000322c:	ffffe097          	auipc	ra,0xffffe
    80003230:	76a080e7          	jalr	1898(ra) # 80001996 <myproc>
}
    80003234:	5908                	lw	a0,48(a0)
    80003236:	60a2                	ld	ra,8(sp)
    80003238:	6402                	ld	s0,0(sp)
    8000323a:	0141                	addi	sp,sp,16
    8000323c:	8082                	ret

000000008000323e <sys_fork>:

uint64
sys_fork(void)
{
    8000323e:	1141                	addi	sp,sp,-16
    80003240:	e406                	sd	ra,8(sp)
    80003242:	e022                	sd	s0,0(sp)
    80003244:	0800                	addi	s0,sp,16
  return fork();
    80003246:	fffff097          	auipc	ra,0xfffff
    8000324a:	c1e080e7          	jalr	-994(ra) # 80001e64 <fork>
}
    8000324e:	60a2                	ld	ra,8(sp)
    80003250:	6402                	ld	s0,0(sp)
    80003252:	0141                	addi	sp,sp,16
    80003254:	8082                	ret

0000000080003256 <sys_wait>:

uint64
sys_wait(void)
{
    80003256:	1101                	addi	sp,sp,-32
    80003258:	ec06                	sd	ra,24(sp)
    8000325a:	e822                	sd	s0,16(sp)
    8000325c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000325e:	fe840593          	addi	a1,s0,-24
    80003262:	4501                	li	a0,0
    80003264:	00000097          	auipc	ra,0x0
    80003268:	d82080e7          	jalr	-638(ra) # 80002fe6 <argaddr>
    8000326c:	87aa                	mv	a5,a0
    return -1;
    8000326e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003270:	0007c863          	bltz	a5,80003280 <sys_wait+0x2a>
  return wait(p);
    80003274:	fe843503          	ld	a0,-24(s0)
    80003278:	fffff097          	auipc	ra,0xfffff
    8000327c:	03a080e7          	jalr	58(ra) # 800022b2 <wait>
}
    80003280:	60e2                	ld	ra,24(sp)
    80003282:	6442                	ld	s0,16(sp)
    80003284:	6105                	addi	sp,sp,32
    80003286:	8082                	ret

0000000080003288 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003288:	7179                	addi	sp,sp,-48
    8000328a:	f406                	sd	ra,40(sp)
    8000328c:	f022                	sd	s0,32(sp)
    8000328e:	ec26                	sd	s1,24(sp)
    80003290:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003292:	fdc40593          	addi	a1,s0,-36
    80003296:	4501                	li	a0,0
    80003298:	00000097          	auipc	ra,0x0
    8000329c:	d2c080e7          	jalr	-724(ra) # 80002fc4 <argint>
    return -1;
    800032a0:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    800032a2:	00054f63          	bltz	a0,800032c0 <sys_sbrk+0x38>
  addr = myproc()->sz;
    800032a6:	ffffe097          	auipc	ra,0xffffe
    800032aa:	6f0080e7          	jalr	1776(ra) # 80001996 <myproc>
    800032ae:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    800032b0:	fdc42503          	lw	a0,-36(s0)
    800032b4:	fffff097          	auipc	ra,0xfffff
    800032b8:	b3c080e7          	jalr	-1220(ra) # 80001df0 <growproc>
    800032bc:	00054863          	bltz	a0,800032cc <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800032c0:	8526                	mv	a0,s1
    800032c2:	70a2                	ld	ra,40(sp)
    800032c4:	7402                	ld	s0,32(sp)
    800032c6:	64e2                	ld	s1,24(sp)
    800032c8:	6145                	addi	sp,sp,48
    800032ca:	8082                	ret
    return -1;
    800032cc:	54fd                	li	s1,-1
    800032ce:	bfcd                	j	800032c0 <sys_sbrk+0x38>

00000000800032d0 <sys_sleep>:

uint64
sys_sleep(void)
{
    800032d0:	7139                	addi	sp,sp,-64
    800032d2:	fc06                	sd	ra,56(sp)
    800032d4:	f822                	sd	s0,48(sp)
    800032d6:	f426                	sd	s1,40(sp)
    800032d8:	f04a                	sd	s2,32(sp)
    800032da:	ec4e                	sd	s3,24(sp)
    800032dc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800032de:	fcc40593          	addi	a1,s0,-52
    800032e2:	4501                	li	a0,0
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	ce0080e7          	jalr	-800(ra) # 80002fc4 <argint>
    return -1;
    800032ec:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800032ee:	06054563          	bltz	a0,80003358 <sys_sleep+0x88>
  acquire(&tickslock);
    800032f2:	00014517          	auipc	a0,0x14
    800032f6:	7f650513          	addi	a0,a0,2038 # 80017ae8 <tickslock>
    800032fa:	ffffe097          	auipc	ra,0xffffe
    800032fe:	8c8080e7          	jalr	-1848(ra) # 80000bc2 <acquire>
  ticks0 = ticks;
    80003302:	00006917          	auipc	s2,0x6
    80003306:	d2e92903          	lw	s2,-722(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    8000330a:	fcc42783          	lw	a5,-52(s0)
    8000330e:	cf85                	beqz	a5,80003346 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003310:	00014997          	auipc	s3,0x14
    80003314:	7d898993          	addi	s3,s3,2008 # 80017ae8 <tickslock>
    80003318:	00006497          	auipc	s1,0x6
    8000331c:	d1848493          	addi	s1,s1,-744 # 80009030 <ticks>
    if(myproc()->killed){
    80003320:	ffffe097          	auipc	ra,0xffffe
    80003324:	676080e7          	jalr	1654(ra) # 80001996 <myproc>
    80003328:	551c                	lw	a5,40(a0)
    8000332a:	ef9d                	bnez	a5,80003368 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    8000332c:	85ce                	mv	a1,s3
    8000332e:	8526                	mv	a0,s1
    80003330:	fffff097          	auipc	ra,0xfffff
    80003334:	f1e080e7          	jalr	-226(ra) # 8000224e <sleep>
  while(ticks - ticks0 < n){
    80003338:	409c                	lw	a5,0(s1)
    8000333a:	412787bb          	subw	a5,a5,s2
    8000333e:	fcc42703          	lw	a4,-52(s0)
    80003342:	fce7efe3          	bltu	a5,a4,80003320 <sys_sleep+0x50>
  }
  release(&tickslock);
    80003346:	00014517          	auipc	a0,0x14
    8000334a:	7a250513          	addi	a0,a0,1954 # 80017ae8 <tickslock>
    8000334e:	ffffe097          	auipc	ra,0xffffe
    80003352:	928080e7          	jalr	-1752(ra) # 80000c76 <release>
  return 0;
    80003356:	4781                	li	a5,0
}
    80003358:	853e                	mv	a0,a5
    8000335a:	70e2                	ld	ra,56(sp)
    8000335c:	7442                	ld	s0,48(sp)
    8000335e:	74a2                	ld	s1,40(sp)
    80003360:	7902                	ld	s2,32(sp)
    80003362:	69e2                	ld	s3,24(sp)
    80003364:	6121                	addi	sp,sp,64
    80003366:	8082                	ret
      release(&tickslock);
    80003368:	00014517          	auipc	a0,0x14
    8000336c:	78050513          	addi	a0,a0,1920 # 80017ae8 <tickslock>
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	906080e7          	jalr	-1786(ra) # 80000c76 <release>
      return -1;
    80003378:	57fd                	li	a5,-1
    8000337a:	bff9                	j	80003358 <sys_sleep+0x88>

000000008000337c <sys_kill>:

uint64
sys_kill(void)
{
    8000337c:	1101                	addi	sp,sp,-32
    8000337e:	ec06                	sd	ra,24(sp)
    80003380:	e822                	sd	s0,16(sp)
    80003382:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003384:	fec40593          	addi	a1,s0,-20
    80003388:	4501                	li	a0,0
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	c3a080e7          	jalr	-966(ra) # 80002fc4 <argint>
    80003392:	87aa                	mv	a5,a0
    return -1;
    80003394:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003396:	0007c863          	bltz	a5,800033a6 <sys_kill+0x2a>
  return kill(pid);
    8000339a:	fec42503          	lw	a0,-20(s0)
    8000339e:	fffff097          	auipc	ra,0xfffff
    800033a2:	20e080e7          	jalr	526(ra) # 800025ac <kill>
}
    800033a6:	60e2                	ld	ra,24(sp)
    800033a8:	6442                	ld	s0,16(sp)
    800033aa:	6105                	addi	sp,sp,32
    800033ac:	8082                	ret

00000000800033ae <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800033ae:	1101                	addi	sp,sp,-32
    800033b0:	ec06                	sd	ra,24(sp)
    800033b2:	e822                	sd	s0,16(sp)
    800033b4:	e426                	sd	s1,8(sp)
    800033b6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800033b8:	00014517          	auipc	a0,0x14
    800033bc:	73050513          	addi	a0,a0,1840 # 80017ae8 <tickslock>
    800033c0:	ffffe097          	auipc	ra,0xffffe
    800033c4:	802080e7          	jalr	-2046(ra) # 80000bc2 <acquire>
  xticks = ticks;
    800033c8:	00006497          	auipc	s1,0x6
    800033cc:	c684a483          	lw	s1,-920(s1) # 80009030 <ticks>
  release(&tickslock);
    800033d0:	00014517          	auipc	a0,0x14
    800033d4:	71850513          	addi	a0,a0,1816 # 80017ae8 <tickslock>
    800033d8:	ffffe097          	auipc	ra,0xffffe
    800033dc:	89e080e7          	jalr	-1890(ra) # 80000c76 <release>
  return xticks;
}
    800033e0:	02049513          	slli	a0,s1,0x20
    800033e4:	9101                	srli	a0,a0,0x20
    800033e6:	60e2                	ld	ra,24(sp)
    800033e8:	6442                	ld	s0,16(sp)
    800033ea:	64a2                	ld	s1,8(sp)
    800033ec:	6105                	addi	sp,sp,32
    800033ee:	8082                	ret

00000000800033f0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800033f0:	7179                	addi	sp,sp,-48
    800033f2:	f406                	sd	ra,40(sp)
    800033f4:	f022                	sd	s0,32(sp)
    800033f6:	ec26                	sd	s1,24(sp)
    800033f8:	e84a                	sd	s2,16(sp)
    800033fa:	e44e                	sd	s3,8(sp)
    800033fc:	e052                	sd	s4,0(sp)
    800033fe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003400:	00005597          	auipc	a1,0x5
    80003404:	2f058593          	addi	a1,a1,752 # 800086f0 <syscall_names_table.0+0xc8>
    80003408:	00014517          	auipc	a0,0x14
    8000340c:	6f850513          	addi	a0,a0,1784 # 80017b00 <bcache>
    80003410:	ffffd097          	auipc	ra,0xffffd
    80003414:	722080e7          	jalr	1826(ra) # 80000b32 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003418:	0001c797          	auipc	a5,0x1c
    8000341c:	6e878793          	addi	a5,a5,1768 # 8001fb00 <bcache+0x8000>
    80003420:	0001d717          	auipc	a4,0x1d
    80003424:	94870713          	addi	a4,a4,-1720 # 8001fd68 <bcache+0x8268>
    80003428:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000342c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003430:	00014497          	auipc	s1,0x14
    80003434:	6e848493          	addi	s1,s1,1768 # 80017b18 <bcache+0x18>
    b->next = bcache.head.next;
    80003438:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000343a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000343c:	00005a17          	auipc	s4,0x5
    80003440:	2bca0a13          	addi	s4,s4,700 # 800086f8 <syscall_names_table.0+0xd0>
    b->next = bcache.head.next;
    80003444:	2b893783          	ld	a5,696(s2)
    80003448:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000344a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000344e:	85d2                	mv	a1,s4
    80003450:	01048513          	addi	a0,s1,16
    80003454:	00001097          	auipc	ra,0x1
    80003458:	4c2080e7          	jalr	1218(ra) # 80004916 <initsleeplock>
    bcache.head.next->prev = b;
    8000345c:	2b893783          	ld	a5,696(s2)
    80003460:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003462:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003466:	45848493          	addi	s1,s1,1112
    8000346a:	fd349de3          	bne	s1,s3,80003444 <binit+0x54>
  }
}
    8000346e:	70a2                	ld	ra,40(sp)
    80003470:	7402                	ld	s0,32(sp)
    80003472:	64e2                	ld	s1,24(sp)
    80003474:	6942                	ld	s2,16(sp)
    80003476:	69a2                	ld	s3,8(sp)
    80003478:	6a02                	ld	s4,0(sp)
    8000347a:	6145                	addi	sp,sp,48
    8000347c:	8082                	ret

000000008000347e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000347e:	7179                	addi	sp,sp,-48
    80003480:	f406                	sd	ra,40(sp)
    80003482:	f022                	sd	s0,32(sp)
    80003484:	ec26                	sd	s1,24(sp)
    80003486:	e84a                	sd	s2,16(sp)
    80003488:	e44e                	sd	s3,8(sp)
    8000348a:	1800                	addi	s0,sp,48
    8000348c:	892a                	mv	s2,a0
    8000348e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003490:	00014517          	auipc	a0,0x14
    80003494:	67050513          	addi	a0,a0,1648 # 80017b00 <bcache>
    80003498:	ffffd097          	auipc	ra,0xffffd
    8000349c:	72a080e7          	jalr	1834(ra) # 80000bc2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800034a0:	0001d497          	auipc	s1,0x1d
    800034a4:	9184b483          	ld	s1,-1768(s1) # 8001fdb8 <bcache+0x82b8>
    800034a8:	0001d797          	auipc	a5,0x1d
    800034ac:	8c078793          	addi	a5,a5,-1856 # 8001fd68 <bcache+0x8268>
    800034b0:	02f48f63          	beq	s1,a5,800034ee <bread+0x70>
    800034b4:	873e                	mv	a4,a5
    800034b6:	a021                	j	800034be <bread+0x40>
    800034b8:	68a4                	ld	s1,80(s1)
    800034ba:	02e48a63          	beq	s1,a4,800034ee <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800034be:	449c                	lw	a5,8(s1)
    800034c0:	ff279ce3          	bne	a5,s2,800034b8 <bread+0x3a>
    800034c4:	44dc                	lw	a5,12(s1)
    800034c6:	ff3799e3          	bne	a5,s3,800034b8 <bread+0x3a>
      b->refcnt++;
    800034ca:	40bc                	lw	a5,64(s1)
    800034cc:	2785                	addiw	a5,a5,1
    800034ce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034d0:	00014517          	auipc	a0,0x14
    800034d4:	63050513          	addi	a0,a0,1584 # 80017b00 <bcache>
    800034d8:	ffffd097          	auipc	ra,0xffffd
    800034dc:	79e080e7          	jalr	1950(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    800034e0:	01048513          	addi	a0,s1,16
    800034e4:	00001097          	auipc	ra,0x1
    800034e8:	46c080e7          	jalr	1132(ra) # 80004950 <acquiresleep>
      return b;
    800034ec:	a8b9                	j	8000354a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034ee:	0001d497          	auipc	s1,0x1d
    800034f2:	8c24b483          	ld	s1,-1854(s1) # 8001fdb0 <bcache+0x82b0>
    800034f6:	0001d797          	auipc	a5,0x1d
    800034fa:	87278793          	addi	a5,a5,-1934 # 8001fd68 <bcache+0x8268>
    800034fe:	00f48863          	beq	s1,a5,8000350e <bread+0x90>
    80003502:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003504:	40bc                	lw	a5,64(s1)
    80003506:	cf81                	beqz	a5,8000351e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003508:	64a4                	ld	s1,72(s1)
    8000350a:	fee49de3          	bne	s1,a4,80003504 <bread+0x86>
  panic("bget: no buffers");
    8000350e:	00005517          	auipc	a0,0x5
    80003512:	1f250513          	addi	a0,a0,498 # 80008700 <syscall_names_table.0+0xd8>
    80003516:	ffffd097          	auipc	ra,0xffffd
    8000351a:	014080e7          	jalr	20(ra) # 8000052a <panic>
      b->dev = dev;
    8000351e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003522:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003526:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000352a:	4785                	li	a5,1
    8000352c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000352e:	00014517          	auipc	a0,0x14
    80003532:	5d250513          	addi	a0,a0,1490 # 80017b00 <bcache>
    80003536:	ffffd097          	auipc	ra,0xffffd
    8000353a:	740080e7          	jalr	1856(ra) # 80000c76 <release>
      acquiresleep(&b->lock);
    8000353e:	01048513          	addi	a0,s1,16
    80003542:	00001097          	auipc	ra,0x1
    80003546:	40e080e7          	jalr	1038(ra) # 80004950 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000354a:	409c                	lw	a5,0(s1)
    8000354c:	cb89                	beqz	a5,8000355e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000354e:	8526                	mv	a0,s1
    80003550:	70a2                	ld	ra,40(sp)
    80003552:	7402                	ld	s0,32(sp)
    80003554:	64e2                	ld	s1,24(sp)
    80003556:	6942                	ld	s2,16(sp)
    80003558:	69a2                	ld	s3,8(sp)
    8000355a:	6145                	addi	sp,sp,48
    8000355c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000355e:	4581                	li	a1,0
    80003560:	8526                	mv	a0,s1
    80003562:	00003097          	auipc	ra,0x3
    80003566:	f24080e7          	jalr	-220(ra) # 80006486 <virtio_disk_rw>
    b->valid = 1;
    8000356a:	4785                	li	a5,1
    8000356c:	c09c                	sw	a5,0(s1)
  return b;
    8000356e:	b7c5                	j	8000354e <bread+0xd0>

0000000080003570 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003570:	1101                	addi	sp,sp,-32
    80003572:	ec06                	sd	ra,24(sp)
    80003574:	e822                	sd	s0,16(sp)
    80003576:	e426                	sd	s1,8(sp)
    80003578:	1000                	addi	s0,sp,32
    8000357a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000357c:	0541                	addi	a0,a0,16
    8000357e:	00001097          	auipc	ra,0x1
    80003582:	46c080e7          	jalr	1132(ra) # 800049ea <holdingsleep>
    80003586:	cd01                	beqz	a0,8000359e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003588:	4585                	li	a1,1
    8000358a:	8526                	mv	a0,s1
    8000358c:	00003097          	auipc	ra,0x3
    80003590:	efa080e7          	jalr	-262(ra) # 80006486 <virtio_disk_rw>
}
    80003594:	60e2                	ld	ra,24(sp)
    80003596:	6442                	ld	s0,16(sp)
    80003598:	64a2                	ld	s1,8(sp)
    8000359a:	6105                	addi	sp,sp,32
    8000359c:	8082                	ret
    panic("bwrite");
    8000359e:	00005517          	auipc	a0,0x5
    800035a2:	17a50513          	addi	a0,a0,378 # 80008718 <syscall_names_table.0+0xf0>
    800035a6:	ffffd097          	auipc	ra,0xffffd
    800035aa:	f84080e7          	jalr	-124(ra) # 8000052a <panic>

00000000800035ae <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800035ae:	1101                	addi	sp,sp,-32
    800035b0:	ec06                	sd	ra,24(sp)
    800035b2:	e822                	sd	s0,16(sp)
    800035b4:	e426                	sd	s1,8(sp)
    800035b6:	e04a                	sd	s2,0(sp)
    800035b8:	1000                	addi	s0,sp,32
    800035ba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800035bc:	01050913          	addi	s2,a0,16
    800035c0:	854a                	mv	a0,s2
    800035c2:	00001097          	auipc	ra,0x1
    800035c6:	428080e7          	jalr	1064(ra) # 800049ea <holdingsleep>
    800035ca:	c92d                	beqz	a0,8000363c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800035cc:	854a                	mv	a0,s2
    800035ce:	00001097          	auipc	ra,0x1
    800035d2:	3d8080e7          	jalr	984(ra) # 800049a6 <releasesleep>

  acquire(&bcache.lock);
    800035d6:	00014517          	auipc	a0,0x14
    800035da:	52a50513          	addi	a0,a0,1322 # 80017b00 <bcache>
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	5e4080e7          	jalr	1508(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800035e6:	40bc                	lw	a5,64(s1)
    800035e8:	37fd                	addiw	a5,a5,-1
    800035ea:	0007871b          	sext.w	a4,a5
    800035ee:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800035f0:	eb05                	bnez	a4,80003620 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800035f2:	68bc                	ld	a5,80(s1)
    800035f4:	64b8                	ld	a4,72(s1)
    800035f6:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800035f8:	64bc                	ld	a5,72(s1)
    800035fa:	68b8                	ld	a4,80(s1)
    800035fc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035fe:	0001c797          	auipc	a5,0x1c
    80003602:	50278793          	addi	a5,a5,1282 # 8001fb00 <bcache+0x8000>
    80003606:	2b87b703          	ld	a4,696(a5)
    8000360a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000360c:	0001c717          	auipc	a4,0x1c
    80003610:	75c70713          	addi	a4,a4,1884 # 8001fd68 <bcache+0x8268>
    80003614:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003616:	2b87b703          	ld	a4,696(a5)
    8000361a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000361c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003620:	00014517          	auipc	a0,0x14
    80003624:	4e050513          	addi	a0,a0,1248 # 80017b00 <bcache>
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	64e080e7          	jalr	1614(ra) # 80000c76 <release>
}
    80003630:	60e2                	ld	ra,24(sp)
    80003632:	6442                	ld	s0,16(sp)
    80003634:	64a2                	ld	s1,8(sp)
    80003636:	6902                	ld	s2,0(sp)
    80003638:	6105                	addi	sp,sp,32
    8000363a:	8082                	ret
    panic("brelse");
    8000363c:	00005517          	auipc	a0,0x5
    80003640:	0e450513          	addi	a0,a0,228 # 80008720 <syscall_names_table.0+0xf8>
    80003644:	ffffd097          	auipc	ra,0xffffd
    80003648:	ee6080e7          	jalr	-282(ra) # 8000052a <panic>

000000008000364c <bpin>:

void
bpin(struct buf *b) {
    8000364c:	1101                	addi	sp,sp,-32
    8000364e:	ec06                	sd	ra,24(sp)
    80003650:	e822                	sd	s0,16(sp)
    80003652:	e426                	sd	s1,8(sp)
    80003654:	1000                	addi	s0,sp,32
    80003656:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003658:	00014517          	auipc	a0,0x14
    8000365c:	4a850513          	addi	a0,a0,1192 # 80017b00 <bcache>
    80003660:	ffffd097          	auipc	ra,0xffffd
    80003664:	562080e7          	jalr	1378(ra) # 80000bc2 <acquire>
  b->refcnt++;
    80003668:	40bc                	lw	a5,64(s1)
    8000366a:	2785                	addiw	a5,a5,1
    8000366c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000366e:	00014517          	auipc	a0,0x14
    80003672:	49250513          	addi	a0,a0,1170 # 80017b00 <bcache>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	600080e7          	jalr	1536(ra) # 80000c76 <release>
}
    8000367e:	60e2                	ld	ra,24(sp)
    80003680:	6442                	ld	s0,16(sp)
    80003682:	64a2                	ld	s1,8(sp)
    80003684:	6105                	addi	sp,sp,32
    80003686:	8082                	ret

0000000080003688 <bunpin>:

void
bunpin(struct buf *b) {
    80003688:	1101                	addi	sp,sp,-32
    8000368a:	ec06                	sd	ra,24(sp)
    8000368c:	e822                	sd	s0,16(sp)
    8000368e:	e426                	sd	s1,8(sp)
    80003690:	1000                	addi	s0,sp,32
    80003692:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003694:	00014517          	auipc	a0,0x14
    80003698:	46c50513          	addi	a0,a0,1132 # 80017b00 <bcache>
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	526080e7          	jalr	1318(ra) # 80000bc2 <acquire>
  b->refcnt--;
    800036a4:	40bc                	lw	a5,64(s1)
    800036a6:	37fd                	addiw	a5,a5,-1
    800036a8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800036aa:	00014517          	auipc	a0,0x14
    800036ae:	45650513          	addi	a0,a0,1110 # 80017b00 <bcache>
    800036b2:	ffffd097          	auipc	ra,0xffffd
    800036b6:	5c4080e7          	jalr	1476(ra) # 80000c76 <release>
}
    800036ba:	60e2                	ld	ra,24(sp)
    800036bc:	6442                	ld	s0,16(sp)
    800036be:	64a2                	ld	s1,8(sp)
    800036c0:	6105                	addi	sp,sp,32
    800036c2:	8082                	ret

00000000800036c4 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800036c4:	1101                	addi	sp,sp,-32
    800036c6:	ec06                	sd	ra,24(sp)
    800036c8:	e822                	sd	s0,16(sp)
    800036ca:	e426                	sd	s1,8(sp)
    800036cc:	e04a                	sd	s2,0(sp)
    800036ce:	1000                	addi	s0,sp,32
    800036d0:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800036d2:	00d5d59b          	srliw	a1,a1,0xd
    800036d6:	0001d797          	auipc	a5,0x1d
    800036da:	b067a783          	lw	a5,-1274(a5) # 800201dc <sb+0x1c>
    800036de:	9dbd                	addw	a1,a1,a5
    800036e0:	00000097          	auipc	ra,0x0
    800036e4:	d9e080e7          	jalr	-610(ra) # 8000347e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800036e8:	0074f713          	andi	a4,s1,7
    800036ec:	4785                	li	a5,1
    800036ee:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800036f2:	14ce                	slli	s1,s1,0x33
    800036f4:	90d9                	srli	s1,s1,0x36
    800036f6:	00950733          	add	a4,a0,s1
    800036fa:	05874703          	lbu	a4,88(a4)
    800036fe:	00e7f6b3          	and	a3,a5,a4
    80003702:	c69d                	beqz	a3,80003730 <bfree+0x6c>
    80003704:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003706:	94aa                	add	s1,s1,a0
    80003708:	fff7c793          	not	a5,a5
    8000370c:	8ff9                	and	a5,a5,a4
    8000370e:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003712:	00001097          	auipc	ra,0x1
    80003716:	11e080e7          	jalr	286(ra) # 80004830 <log_write>
  brelse(bp);
    8000371a:	854a                	mv	a0,s2
    8000371c:	00000097          	auipc	ra,0x0
    80003720:	e92080e7          	jalr	-366(ra) # 800035ae <brelse>
}
    80003724:	60e2                	ld	ra,24(sp)
    80003726:	6442                	ld	s0,16(sp)
    80003728:	64a2                	ld	s1,8(sp)
    8000372a:	6902                	ld	s2,0(sp)
    8000372c:	6105                	addi	sp,sp,32
    8000372e:	8082                	ret
    panic("freeing free block");
    80003730:	00005517          	auipc	a0,0x5
    80003734:	ff850513          	addi	a0,a0,-8 # 80008728 <syscall_names_table.0+0x100>
    80003738:	ffffd097          	auipc	ra,0xffffd
    8000373c:	df2080e7          	jalr	-526(ra) # 8000052a <panic>

0000000080003740 <balloc>:
{
    80003740:	711d                	addi	sp,sp,-96
    80003742:	ec86                	sd	ra,88(sp)
    80003744:	e8a2                	sd	s0,80(sp)
    80003746:	e4a6                	sd	s1,72(sp)
    80003748:	e0ca                	sd	s2,64(sp)
    8000374a:	fc4e                	sd	s3,56(sp)
    8000374c:	f852                	sd	s4,48(sp)
    8000374e:	f456                	sd	s5,40(sp)
    80003750:	f05a                	sd	s6,32(sp)
    80003752:	ec5e                	sd	s7,24(sp)
    80003754:	e862                	sd	s8,16(sp)
    80003756:	e466                	sd	s9,8(sp)
    80003758:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000375a:	0001d797          	auipc	a5,0x1d
    8000375e:	a6a7a783          	lw	a5,-1430(a5) # 800201c4 <sb+0x4>
    80003762:	cbd1                	beqz	a5,800037f6 <balloc+0xb6>
    80003764:	8baa                	mv	s7,a0
    80003766:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003768:	0001db17          	auipc	s6,0x1d
    8000376c:	a58b0b13          	addi	s6,s6,-1448 # 800201c0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003770:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003772:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003774:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003776:	6c89                	lui	s9,0x2
    80003778:	a831                	j	80003794 <balloc+0x54>
    brelse(bp);
    8000377a:	854a                	mv	a0,s2
    8000377c:	00000097          	auipc	ra,0x0
    80003780:	e32080e7          	jalr	-462(ra) # 800035ae <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003784:	015c87bb          	addw	a5,s9,s5
    80003788:	00078a9b          	sext.w	s5,a5
    8000378c:	004b2703          	lw	a4,4(s6)
    80003790:	06eaf363          	bgeu	s5,a4,800037f6 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80003794:	41fad79b          	sraiw	a5,s5,0x1f
    80003798:	0137d79b          	srliw	a5,a5,0x13
    8000379c:	015787bb          	addw	a5,a5,s5
    800037a0:	40d7d79b          	sraiw	a5,a5,0xd
    800037a4:	01cb2583          	lw	a1,28(s6)
    800037a8:	9dbd                	addw	a1,a1,a5
    800037aa:	855e                	mv	a0,s7
    800037ac:	00000097          	auipc	ra,0x0
    800037b0:	cd2080e7          	jalr	-814(ra) # 8000347e <bread>
    800037b4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037b6:	004b2503          	lw	a0,4(s6)
    800037ba:	000a849b          	sext.w	s1,s5
    800037be:	8662                	mv	a2,s8
    800037c0:	faa4fde3          	bgeu	s1,a0,8000377a <balloc+0x3a>
      m = 1 << (bi % 8);
    800037c4:	41f6579b          	sraiw	a5,a2,0x1f
    800037c8:	01d7d69b          	srliw	a3,a5,0x1d
    800037cc:	00c6873b          	addw	a4,a3,a2
    800037d0:	00777793          	andi	a5,a4,7
    800037d4:	9f95                	subw	a5,a5,a3
    800037d6:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037da:	4037571b          	sraiw	a4,a4,0x3
    800037de:	00e906b3          	add	a3,s2,a4
    800037e2:	0586c683          	lbu	a3,88(a3)
    800037e6:	00d7f5b3          	and	a1,a5,a3
    800037ea:	cd91                	beqz	a1,80003806 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037ec:	2605                	addiw	a2,a2,1
    800037ee:	2485                	addiw	s1,s1,1
    800037f0:	fd4618e3          	bne	a2,s4,800037c0 <balloc+0x80>
    800037f4:	b759                	j	8000377a <balloc+0x3a>
  panic("balloc: out of blocks");
    800037f6:	00005517          	auipc	a0,0x5
    800037fa:	f4a50513          	addi	a0,a0,-182 # 80008740 <syscall_names_table.0+0x118>
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	d2c080e7          	jalr	-724(ra) # 8000052a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003806:	974a                	add	a4,a4,s2
    80003808:	8fd5                	or	a5,a5,a3
    8000380a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000380e:	854a                	mv	a0,s2
    80003810:	00001097          	auipc	ra,0x1
    80003814:	020080e7          	jalr	32(ra) # 80004830 <log_write>
        brelse(bp);
    80003818:	854a                	mv	a0,s2
    8000381a:	00000097          	auipc	ra,0x0
    8000381e:	d94080e7          	jalr	-620(ra) # 800035ae <brelse>
  bp = bread(dev, bno);
    80003822:	85a6                	mv	a1,s1
    80003824:	855e                	mv	a0,s7
    80003826:	00000097          	auipc	ra,0x0
    8000382a:	c58080e7          	jalr	-936(ra) # 8000347e <bread>
    8000382e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003830:	40000613          	li	a2,1024
    80003834:	4581                	li	a1,0
    80003836:	05850513          	addi	a0,a0,88
    8000383a:	ffffd097          	auipc	ra,0xffffd
    8000383e:	484080e7          	jalr	1156(ra) # 80000cbe <memset>
  log_write(bp);
    80003842:	854a                	mv	a0,s2
    80003844:	00001097          	auipc	ra,0x1
    80003848:	fec080e7          	jalr	-20(ra) # 80004830 <log_write>
  brelse(bp);
    8000384c:	854a                	mv	a0,s2
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	d60080e7          	jalr	-672(ra) # 800035ae <brelse>
}
    80003856:	8526                	mv	a0,s1
    80003858:	60e6                	ld	ra,88(sp)
    8000385a:	6446                	ld	s0,80(sp)
    8000385c:	64a6                	ld	s1,72(sp)
    8000385e:	6906                	ld	s2,64(sp)
    80003860:	79e2                	ld	s3,56(sp)
    80003862:	7a42                	ld	s4,48(sp)
    80003864:	7aa2                	ld	s5,40(sp)
    80003866:	7b02                	ld	s6,32(sp)
    80003868:	6be2                	ld	s7,24(sp)
    8000386a:	6c42                	ld	s8,16(sp)
    8000386c:	6ca2                	ld	s9,8(sp)
    8000386e:	6125                	addi	sp,sp,96
    80003870:	8082                	ret

0000000080003872 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003872:	7179                	addi	sp,sp,-48
    80003874:	f406                	sd	ra,40(sp)
    80003876:	f022                	sd	s0,32(sp)
    80003878:	ec26                	sd	s1,24(sp)
    8000387a:	e84a                	sd	s2,16(sp)
    8000387c:	e44e                	sd	s3,8(sp)
    8000387e:	e052                	sd	s4,0(sp)
    80003880:	1800                	addi	s0,sp,48
    80003882:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003884:	47ad                	li	a5,11
    80003886:	04b7fe63          	bgeu	a5,a1,800038e2 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000388a:	ff45849b          	addiw	s1,a1,-12
    8000388e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003892:	0ff00793          	li	a5,255
    80003896:	0ae7e463          	bltu	a5,a4,8000393e <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000389a:	08052583          	lw	a1,128(a0)
    8000389e:	c5b5                	beqz	a1,8000390a <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800038a0:	00092503          	lw	a0,0(s2)
    800038a4:	00000097          	auipc	ra,0x0
    800038a8:	bda080e7          	jalr	-1062(ra) # 8000347e <bread>
    800038ac:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800038ae:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800038b2:	02049713          	slli	a4,s1,0x20
    800038b6:	01e75593          	srli	a1,a4,0x1e
    800038ba:	00b784b3          	add	s1,a5,a1
    800038be:	0004a983          	lw	s3,0(s1)
    800038c2:	04098e63          	beqz	s3,8000391e <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800038c6:	8552                	mv	a0,s4
    800038c8:	00000097          	auipc	ra,0x0
    800038cc:	ce6080e7          	jalr	-794(ra) # 800035ae <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800038d0:	854e                	mv	a0,s3
    800038d2:	70a2                	ld	ra,40(sp)
    800038d4:	7402                	ld	s0,32(sp)
    800038d6:	64e2                	ld	s1,24(sp)
    800038d8:	6942                	ld	s2,16(sp)
    800038da:	69a2                	ld	s3,8(sp)
    800038dc:	6a02                	ld	s4,0(sp)
    800038de:	6145                	addi	sp,sp,48
    800038e0:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800038e2:	02059793          	slli	a5,a1,0x20
    800038e6:	01e7d593          	srli	a1,a5,0x1e
    800038ea:	00b504b3          	add	s1,a0,a1
    800038ee:	0504a983          	lw	s3,80(s1)
    800038f2:	fc099fe3          	bnez	s3,800038d0 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800038f6:	4108                	lw	a0,0(a0)
    800038f8:	00000097          	auipc	ra,0x0
    800038fc:	e48080e7          	jalr	-440(ra) # 80003740 <balloc>
    80003900:	0005099b          	sext.w	s3,a0
    80003904:	0534a823          	sw	s3,80(s1)
    80003908:	b7e1                	j	800038d0 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000390a:	4108                	lw	a0,0(a0)
    8000390c:	00000097          	auipc	ra,0x0
    80003910:	e34080e7          	jalr	-460(ra) # 80003740 <balloc>
    80003914:	0005059b          	sext.w	a1,a0
    80003918:	08b92023          	sw	a1,128(s2)
    8000391c:	b751                	j	800038a0 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000391e:	00092503          	lw	a0,0(s2)
    80003922:	00000097          	auipc	ra,0x0
    80003926:	e1e080e7          	jalr	-482(ra) # 80003740 <balloc>
    8000392a:	0005099b          	sext.w	s3,a0
    8000392e:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003932:	8552                	mv	a0,s4
    80003934:	00001097          	auipc	ra,0x1
    80003938:	efc080e7          	jalr	-260(ra) # 80004830 <log_write>
    8000393c:	b769                	j	800038c6 <bmap+0x54>
  panic("bmap: out of range");
    8000393e:	00005517          	auipc	a0,0x5
    80003942:	e1a50513          	addi	a0,a0,-486 # 80008758 <syscall_names_table.0+0x130>
    80003946:	ffffd097          	auipc	ra,0xffffd
    8000394a:	be4080e7          	jalr	-1052(ra) # 8000052a <panic>

000000008000394e <iget>:
{
    8000394e:	7179                	addi	sp,sp,-48
    80003950:	f406                	sd	ra,40(sp)
    80003952:	f022                	sd	s0,32(sp)
    80003954:	ec26                	sd	s1,24(sp)
    80003956:	e84a                	sd	s2,16(sp)
    80003958:	e44e                	sd	s3,8(sp)
    8000395a:	e052                	sd	s4,0(sp)
    8000395c:	1800                	addi	s0,sp,48
    8000395e:	89aa                	mv	s3,a0
    80003960:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003962:	0001d517          	auipc	a0,0x1d
    80003966:	87e50513          	addi	a0,a0,-1922 # 800201e0 <itable>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	258080e7          	jalr	600(ra) # 80000bc2 <acquire>
  empty = 0;
    80003972:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003974:	0001d497          	auipc	s1,0x1d
    80003978:	88448493          	addi	s1,s1,-1916 # 800201f8 <itable+0x18>
    8000397c:	0001e697          	auipc	a3,0x1e
    80003980:	30c68693          	addi	a3,a3,780 # 80021c88 <log>
    80003984:	a039                	j	80003992 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003986:	02090b63          	beqz	s2,800039bc <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000398a:	08848493          	addi	s1,s1,136
    8000398e:	02d48a63          	beq	s1,a3,800039c2 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003992:	449c                	lw	a5,8(s1)
    80003994:	fef059e3          	blez	a5,80003986 <iget+0x38>
    80003998:	4098                	lw	a4,0(s1)
    8000399a:	ff3716e3          	bne	a4,s3,80003986 <iget+0x38>
    8000399e:	40d8                	lw	a4,4(s1)
    800039a0:	ff4713e3          	bne	a4,s4,80003986 <iget+0x38>
      ip->ref++;
    800039a4:	2785                	addiw	a5,a5,1
    800039a6:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800039a8:	0001d517          	auipc	a0,0x1d
    800039ac:	83850513          	addi	a0,a0,-1992 # 800201e0 <itable>
    800039b0:	ffffd097          	auipc	ra,0xffffd
    800039b4:	2c6080e7          	jalr	710(ra) # 80000c76 <release>
      return ip;
    800039b8:	8926                	mv	s2,s1
    800039ba:	a03d                	j	800039e8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800039bc:	f7f9                	bnez	a5,8000398a <iget+0x3c>
    800039be:	8926                	mv	s2,s1
    800039c0:	b7e9                	j	8000398a <iget+0x3c>
  if(empty == 0)
    800039c2:	02090c63          	beqz	s2,800039fa <iget+0xac>
  ip->dev = dev;
    800039c6:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800039ca:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800039ce:	4785                	li	a5,1
    800039d0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800039d4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800039d8:	0001d517          	auipc	a0,0x1d
    800039dc:	80850513          	addi	a0,a0,-2040 # 800201e0 <itable>
    800039e0:	ffffd097          	auipc	ra,0xffffd
    800039e4:	296080e7          	jalr	662(ra) # 80000c76 <release>
}
    800039e8:	854a                	mv	a0,s2
    800039ea:	70a2                	ld	ra,40(sp)
    800039ec:	7402                	ld	s0,32(sp)
    800039ee:	64e2                	ld	s1,24(sp)
    800039f0:	6942                	ld	s2,16(sp)
    800039f2:	69a2                	ld	s3,8(sp)
    800039f4:	6a02                	ld	s4,0(sp)
    800039f6:	6145                	addi	sp,sp,48
    800039f8:	8082                	ret
    panic("iget: no inodes");
    800039fa:	00005517          	auipc	a0,0x5
    800039fe:	d7650513          	addi	a0,a0,-650 # 80008770 <syscall_names_table.0+0x148>
    80003a02:	ffffd097          	auipc	ra,0xffffd
    80003a06:	b28080e7          	jalr	-1240(ra) # 8000052a <panic>

0000000080003a0a <fsinit>:
fsinit(int dev) {
    80003a0a:	7179                	addi	sp,sp,-48
    80003a0c:	f406                	sd	ra,40(sp)
    80003a0e:	f022                	sd	s0,32(sp)
    80003a10:	ec26                	sd	s1,24(sp)
    80003a12:	e84a                	sd	s2,16(sp)
    80003a14:	e44e                	sd	s3,8(sp)
    80003a16:	1800                	addi	s0,sp,48
    80003a18:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003a1a:	4585                	li	a1,1
    80003a1c:	00000097          	auipc	ra,0x0
    80003a20:	a62080e7          	jalr	-1438(ra) # 8000347e <bread>
    80003a24:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003a26:	0001c997          	auipc	s3,0x1c
    80003a2a:	79a98993          	addi	s3,s3,1946 # 800201c0 <sb>
    80003a2e:	02000613          	li	a2,32
    80003a32:	05850593          	addi	a1,a0,88
    80003a36:	854e                	mv	a0,s3
    80003a38:	ffffd097          	auipc	ra,0xffffd
    80003a3c:	2e2080e7          	jalr	738(ra) # 80000d1a <memmove>
  brelse(bp);
    80003a40:	8526                	mv	a0,s1
    80003a42:	00000097          	auipc	ra,0x0
    80003a46:	b6c080e7          	jalr	-1172(ra) # 800035ae <brelse>
  if(sb.magic != FSMAGIC)
    80003a4a:	0009a703          	lw	a4,0(s3)
    80003a4e:	102037b7          	lui	a5,0x10203
    80003a52:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003a56:	02f71263          	bne	a4,a5,80003a7a <fsinit+0x70>
  initlog(dev, &sb);
    80003a5a:	0001c597          	auipc	a1,0x1c
    80003a5e:	76658593          	addi	a1,a1,1894 # 800201c0 <sb>
    80003a62:	854a                	mv	a0,s2
    80003a64:	00001097          	auipc	ra,0x1
    80003a68:	b4e080e7          	jalr	-1202(ra) # 800045b2 <initlog>
}
    80003a6c:	70a2                	ld	ra,40(sp)
    80003a6e:	7402                	ld	s0,32(sp)
    80003a70:	64e2                	ld	s1,24(sp)
    80003a72:	6942                	ld	s2,16(sp)
    80003a74:	69a2                	ld	s3,8(sp)
    80003a76:	6145                	addi	sp,sp,48
    80003a78:	8082                	ret
    panic("invalid file system");
    80003a7a:	00005517          	auipc	a0,0x5
    80003a7e:	d0650513          	addi	a0,a0,-762 # 80008780 <syscall_names_table.0+0x158>
    80003a82:	ffffd097          	auipc	ra,0xffffd
    80003a86:	aa8080e7          	jalr	-1368(ra) # 8000052a <panic>

0000000080003a8a <iinit>:
{
    80003a8a:	7179                	addi	sp,sp,-48
    80003a8c:	f406                	sd	ra,40(sp)
    80003a8e:	f022                	sd	s0,32(sp)
    80003a90:	ec26                	sd	s1,24(sp)
    80003a92:	e84a                	sd	s2,16(sp)
    80003a94:	e44e                	sd	s3,8(sp)
    80003a96:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003a98:	00005597          	auipc	a1,0x5
    80003a9c:	d0058593          	addi	a1,a1,-768 # 80008798 <syscall_names_table.0+0x170>
    80003aa0:	0001c517          	auipc	a0,0x1c
    80003aa4:	74050513          	addi	a0,a0,1856 # 800201e0 <itable>
    80003aa8:	ffffd097          	auipc	ra,0xffffd
    80003aac:	08a080e7          	jalr	138(ra) # 80000b32 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003ab0:	0001c497          	auipc	s1,0x1c
    80003ab4:	75848493          	addi	s1,s1,1880 # 80020208 <itable+0x28>
    80003ab8:	0001e997          	auipc	s3,0x1e
    80003abc:	1e098993          	addi	s3,s3,480 # 80021c98 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003ac0:	00005917          	auipc	s2,0x5
    80003ac4:	ce090913          	addi	s2,s2,-800 # 800087a0 <syscall_names_table.0+0x178>
    80003ac8:	85ca                	mv	a1,s2
    80003aca:	8526                	mv	a0,s1
    80003acc:	00001097          	auipc	ra,0x1
    80003ad0:	e4a080e7          	jalr	-438(ra) # 80004916 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003ad4:	08848493          	addi	s1,s1,136
    80003ad8:	ff3498e3          	bne	s1,s3,80003ac8 <iinit+0x3e>
}
    80003adc:	70a2                	ld	ra,40(sp)
    80003ade:	7402                	ld	s0,32(sp)
    80003ae0:	64e2                	ld	s1,24(sp)
    80003ae2:	6942                	ld	s2,16(sp)
    80003ae4:	69a2                	ld	s3,8(sp)
    80003ae6:	6145                	addi	sp,sp,48
    80003ae8:	8082                	ret

0000000080003aea <ialloc>:
{
    80003aea:	715d                	addi	sp,sp,-80
    80003aec:	e486                	sd	ra,72(sp)
    80003aee:	e0a2                	sd	s0,64(sp)
    80003af0:	fc26                	sd	s1,56(sp)
    80003af2:	f84a                	sd	s2,48(sp)
    80003af4:	f44e                	sd	s3,40(sp)
    80003af6:	f052                	sd	s4,32(sp)
    80003af8:	ec56                	sd	s5,24(sp)
    80003afa:	e85a                	sd	s6,16(sp)
    80003afc:	e45e                	sd	s7,8(sp)
    80003afe:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b00:	0001c717          	auipc	a4,0x1c
    80003b04:	6cc72703          	lw	a4,1740(a4) # 800201cc <sb+0xc>
    80003b08:	4785                	li	a5,1
    80003b0a:	04e7fa63          	bgeu	a5,a4,80003b5e <ialloc+0x74>
    80003b0e:	8aaa                	mv	s5,a0
    80003b10:	8bae                	mv	s7,a1
    80003b12:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003b14:	0001ca17          	auipc	s4,0x1c
    80003b18:	6aca0a13          	addi	s4,s4,1708 # 800201c0 <sb>
    80003b1c:	00048b1b          	sext.w	s6,s1
    80003b20:	0044d793          	srli	a5,s1,0x4
    80003b24:	018a2583          	lw	a1,24(s4)
    80003b28:	9dbd                	addw	a1,a1,a5
    80003b2a:	8556                	mv	a0,s5
    80003b2c:	00000097          	auipc	ra,0x0
    80003b30:	952080e7          	jalr	-1710(ra) # 8000347e <bread>
    80003b34:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003b36:	05850993          	addi	s3,a0,88
    80003b3a:	00f4f793          	andi	a5,s1,15
    80003b3e:	079a                	slli	a5,a5,0x6
    80003b40:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003b42:	00099783          	lh	a5,0(s3)
    80003b46:	c785                	beqz	a5,80003b6e <ialloc+0x84>
    brelse(bp);
    80003b48:	00000097          	auipc	ra,0x0
    80003b4c:	a66080e7          	jalr	-1434(ra) # 800035ae <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003b50:	0485                	addi	s1,s1,1
    80003b52:	00ca2703          	lw	a4,12(s4)
    80003b56:	0004879b          	sext.w	a5,s1
    80003b5a:	fce7e1e3          	bltu	a5,a4,80003b1c <ialloc+0x32>
  panic("ialloc: no inodes");
    80003b5e:	00005517          	auipc	a0,0x5
    80003b62:	c4a50513          	addi	a0,a0,-950 # 800087a8 <syscall_names_table.0+0x180>
    80003b66:	ffffd097          	auipc	ra,0xffffd
    80003b6a:	9c4080e7          	jalr	-1596(ra) # 8000052a <panic>
      memset(dip, 0, sizeof(*dip));
    80003b6e:	04000613          	li	a2,64
    80003b72:	4581                	li	a1,0
    80003b74:	854e                	mv	a0,s3
    80003b76:	ffffd097          	auipc	ra,0xffffd
    80003b7a:	148080e7          	jalr	328(ra) # 80000cbe <memset>
      dip->type = type;
    80003b7e:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003b82:	854a                	mv	a0,s2
    80003b84:	00001097          	auipc	ra,0x1
    80003b88:	cac080e7          	jalr	-852(ra) # 80004830 <log_write>
      brelse(bp);
    80003b8c:	854a                	mv	a0,s2
    80003b8e:	00000097          	auipc	ra,0x0
    80003b92:	a20080e7          	jalr	-1504(ra) # 800035ae <brelse>
      return iget(dev, inum);
    80003b96:	85da                	mv	a1,s6
    80003b98:	8556                	mv	a0,s5
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	db4080e7          	jalr	-588(ra) # 8000394e <iget>
}
    80003ba2:	60a6                	ld	ra,72(sp)
    80003ba4:	6406                	ld	s0,64(sp)
    80003ba6:	74e2                	ld	s1,56(sp)
    80003ba8:	7942                	ld	s2,48(sp)
    80003baa:	79a2                	ld	s3,40(sp)
    80003bac:	7a02                	ld	s4,32(sp)
    80003bae:	6ae2                	ld	s5,24(sp)
    80003bb0:	6b42                	ld	s6,16(sp)
    80003bb2:	6ba2                	ld	s7,8(sp)
    80003bb4:	6161                	addi	sp,sp,80
    80003bb6:	8082                	ret

0000000080003bb8 <iupdate>:
{
    80003bb8:	1101                	addi	sp,sp,-32
    80003bba:	ec06                	sd	ra,24(sp)
    80003bbc:	e822                	sd	s0,16(sp)
    80003bbe:	e426                	sd	s1,8(sp)
    80003bc0:	e04a                	sd	s2,0(sp)
    80003bc2:	1000                	addi	s0,sp,32
    80003bc4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bc6:	415c                	lw	a5,4(a0)
    80003bc8:	0047d79b          	srliw	a5,a5,0x4
    80003bcc:	0001c597          	auipc	a1,0x1c
    80003bd0:	60c5a583          	lw	a1,1548(a1) # 800201d8 <sb+0x18>
    80003bd4:	9dbd                	addw	a1,a1,a5
    80003bd6:	4108                	lw	a0,0(a0)
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	8a6080e7          	jalr	-1882(ra) # 8000347e <bread>
    80003be0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003be2:	05850793          	addi	a5,a0,88
    80003be6:	40c8                	lw	a0,4(s1)
    80003be8:	893d                	andi	a0,a0,15
    80003bea:	051a                	slli	a0,a0,0x6
    80003bec:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003bee:	04449703          	lh	a4,68(s1)
    80003bf2:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003bf6:	04649703          	lh	a4,70(s1)
    80003bfa:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003bfe:	04849703          	lh	a4,72(s1)
    80003c02:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003c06:	04a49703          	lh	a4,74(s1)
    80003c0a:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003c0e:	44f8                	lw	a4,76(s1)
    80003c10:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003c12:	03400613          	li	a2,52
    80003c16:	05048593          	addi	a1,s1,80
    80003c1a:	0531                	addi	a0,a0,12
    80003c1c:	ffffd097          	auipc	ra,0xffffd
    80003c20:	0fe080e7          	jalr	254(ra) # 80000d1a <memmove>
  log_write(bp);
    80003c24:	854a                	mv	a0,s2
    80003c26:	00001097          	auipc	ra,0x1
    80003c2a:	c0a080e7          	jalr	-1014(ra) # 80004830 <log_write>
  brelse(bp);
    80003c2e:	854a                	mv	a0,s2
    80003c30:	00000097          	auipc	ra,0x0
    80003c34:	97e080e7          	jalr	-1666(ra) # 800035ae <brelse>
}
    80003c38:	60e2                	ld	ra,24(sp)
    80003c3a:	6442                	ld	s0,16(sp)
    80003c3c:	64a2                	ld	s1,8(sp)
    80003c3e:	6902                	ld	s2,0(sp)
    80003c40:	6105                	addi	sp,sp,32
    80003c42:	8082                	ret

0000000080003c44 <idup>:
{
    80003c44:	1101                	addi	sp,sp,-32
    80003c46:	ec06                	sd	ra,24(sp)
    80003c48:	e822                	sd	s0,16(sp)
    80003c4a:	e426                	sd	s1,8(sp)
    80003c4c:	1000                	addi	s0,sp,32
    80003c4e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c50:	0001c517          	auipc	a0,0x1c
    80003c54:	59050513          	addi	a0,a0,1424 # 800201e0 <itable>
    80003c58:	ffffd097          	auipc	ra,0xffffd
    80003c5c:	f6a080e7          	jalr	-150(ra) # 80000bc2 <acquire>
  ip->ref++;
    80003c60:	449c                	lw	a5,8(s1)
    80003c62:	2785                	addiw	a5,a5,1
    80003c64:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c66:	0001c517          	auipc	a0,0x1c
    80003c6a:	57a50513          	addi	a0,a0,1402 # 800201e0 <itable>
    80003c6e:	ffffd097          	auipc	ra,0xffffd
    80003c72:	008080e7          	jalr	8(ra) # 80000c76 <release>
}
    80003c76:	8526                	mv	a0,s1
    80003c78:	60e2                	ld	ra,24(sp)
    80003c7a:	6442                	ld	s0,16(sp)
    80003c7c:	64a2                	ld	s1,8(sp)
    80003c7e:	6105                	addi	sp,sp,32
    80003c80:	8082                	ret

0000000080003c82 <ilock>:
{
    80003c82:	1101                	addi	sp,sp,-32
    80003c84:	ec06                	sd	ra,24(sp)
    80003c86:	e822                	sd	s0,16(sp)
    80003c88:	e426                	sd	s1,8(sp)
    80003c8a:	e04a                	sd	s2,0(sp)
    80003c8c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003c8e:	c115                	beqz	a0,80003cb2 <ilock+0x30>
    80003c90:	84aa                	mv	s1,a0
    80003c92:	451c                	lw	a5,8(a0)
    80003c94:	00f05f63          	blez	a5,80003cb2 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003c98:	0541                	addi	a0,a0,16
    80003c9a:	00001097          	auipc	ra,0x1
    80003c9e:	cb6080e7          	jalr	-842(ra) # 80004950 <acquiresleep>
  if(ip->valid == 0){
    80003ca2:	40bc                	lw	a5,64(s1)
    80003ca4:	cf99                	beqz	a5,80003cc2 <ilock+0x40>
}
    80003ca6:	60e2                	ld	ra,24(sp)
    80003ca8:	6442                	ld	s0,16(sp)
    80003caa:	64a2                	ld	s1,8(sp)
    80003cac:	6902                	ld	s2,0(sp)
    80003cae:	6105                	addi	sp,sp,32
    80003cb0:	8082                	ret
    panic("ilock");
    80003cb2:	00005517          	auipc	a0,0x5
    80003cb6:	b0e50513          	addi	a0,a0,-1266 # 800087c0 <syscall_names_table.0+0x198>
    80003cba:	ffffd097          	auipc	ra,0xffffd
    80003cbe:	870080e7          	jalr	-1936(ra) # 8000052a <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003cc2:	40dc                	lw	a5,4(s1)
    80003cc4:	0047d79b          	srliw	a5,a5,0x4
    80003cc8:	0001c597          	auipc	a1,0x1c
    80003ccc:	5105a583          	lw	a1,1296(a1) # 800201d8 <sb+0x18>
    80003cd0:	9dbd                	addw	a1,a1,a5
    80003cd2:	4088                	lw	a0,0(s1)
    80003cd4:	fffff097          	auipc	ra,0xfffff
    80003cd8:	7aa080e7          	jalr	1962(ra) # 8000347e <bread>
    80003cdc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003cde:	05850593          	addi	a1,a0,88
    80003ce2:	40dc                	lw	a5,4(s1)
    80003ce4:	8bbd                	andi	a5,a5,15
    80003ce6:	079a                	slli	a5,a5,0x6
    80003ce8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003cea:	00059783          	lh	a5,0(a1)
    80003cee:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003cf2:	00259783          	lh	a5,2(a1)
    80003cf6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003cfa:	00459783          	lh	a5,4(a1)
    80003cfe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003d02:	00659783          	lh	a5,6(a1)
    80003d06:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003d0a:	459c                	lw	a5,8(a1)
    80003d0c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003d0e:	03400613          	li	a2,52
    80003d12:	05b1                	addi	a1,a1,12
    80003d14:	05048513          	addi	a0,s1,80
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	002080e7          	jalr	2(ra) # 80000d1a <memmove>
    brelse(bp);
    80003d20:	854a                	mv	a0,s2
    80003d22:	00000097          	auipc	ra,0x0
    80003d26:	88c080e7          	jalr	-1908(ra) # 800035ae <brelse>
    ip->valid = 1;
    80003d2a:	4785                	li	a5,1
    80003d2c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003d2e:	04449783          	lh	a5,68(s1)
    80003d32:	fbb5                	bnez	a5,80003ca6 <ilock+0x24>
      panic("ilock: no type");
    80003d34:	00005517          	auipc	a0,0x5
    80003d38:	a9450513          	addi	a0,a0,-1388 # 800087c8 <syscall_names_table.0+0x1a0>
    80003d3c:	ffffc097          	auipc	ra,0xffffc
    80003d40:	7ee080e7          	jalr	2030(ra) # 8000052a <panic>

0000000080003d44 <iunlock>:
{
    80003d44:	1101                	addi	sp,sp,-32
    80003d46:	ec06                	sd	ra,24(sp)
    80003d48:	e822                	sd	s0,16(sp)
    80003d4a:	e426                	sd	s1,8(sp)
    80003d4c:	e04a                	sd	s2,0(sp)
    80003d4e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003d50:	c905                	beqz	a0,80003d80 <iunlock+0x3c>
    80003d52:	84aa                	mv	s1,a0
    80003d54:	01050913          	addi	s2,a0,16
    80003d58:	854a                	mv	a0,s2
    80003d5a:	00001097          	auipc	ra,0x1
    80003d5e:	c90080e7          	jalr	-880(ra) # 800049ea <holdingsleep>
    80003d62:	cd19                	beqz	a0,80003d80 <iunlock+0x3c>
    80003d64:	449c                	lw	a5,8(s1)
    80003d66:	00f05d63          	blez	a5,80003d80 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003d6a:	854a                	mv	a0,s2
    80003d6c:	00001097          	auipc	ra,0x1
    80003d70:	c3a080e7          	jalr	-966(ra) # 800049a6 <releasesleep>
}
    80003d74:	60e2                	ld	ra,24(sp)
    80003d76:	6442                	ld	s0,16(sp)
    80003d78:	64a2                	ld	s1,8(sp)
    80003d7a:	6902                	ld	s2,0(sp)
    80003d7c:	6105                	addi	sp,sp,32
    80003d7e:	8082                	ret
    panic("iunlock");
    80003d80:	00005517          	auipc	a0,0x5
    80003d84:	a5850513          	addi	a0,a0,-1448 # 800087d8 <syscall_names_table.0+0x1b0>
    80003d88:	ffffc097          	auipc	ra,0xffffc
    80003d8c:	7a2080e7          	jalr	1954(ra) # 8000052a <panic>

0000000080003d90 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003d90:	7179                	addi	sp,sp,-48
    80003d92:	f406                	sd	ra,40(sp)
    80003d94:	f022                	sd	s0,32(sp)
    80003d96:	ec26                	sd	s1,24(sp)
    80003d98:	e84a                	sd	s2,16(sp)
    80003d9a:	e44e                	sd	s3,8(sp)
    80003d9c:	e052                	sd	s4,0(sp)
    80003d9e:	1800                	addi	s0,sp,48
    80003da0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003da2:	05050493          	addi	s1,a0,80
    80003da6:	08050913          	addi	s2,a0,128
    80003daa:	a021                	j	80003db2 <itrunc+0x22>
    80003dac:	0491                	addi	s1,s1,4
    80003dae:	01248d63          	beq	s1,s2,80003dc8 <itrunc+0x38>
    if(ip->addrs[i]){
    80003db2:	408c                	lw	a1,0(s1)
    80003db4:	dde5                	beqz	a1,80003dac <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003db6:	0009a503          	lw	a0,0(s3)
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	90a080e7          	jalr	-1782(ra) # 800036c4 <bfree>
      ip->addrs[i] = 0;
    80003dc2:	0004a023          	sw	zero,0(s1)
    80003dc6:	b7dd                	j	80003dac <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003dc8:	0809a583          	lw	a1,128(s3)
    80003dcc:	e185                	bnez	a1,80003dec <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003dce:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003dd2:	854e                	mv	a0,s3
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	de4080e7          	jalr	-540(ra) # 80003bb8 <iupdate>
}
    80003ddc:	70a2                	ld	ra,40(sp)
    80003dde:	7402                	ld	s0,32(sp)
    80003de0:	64e2                	ld	s1,24(sp)
    80003de2:	6942                	ld	s2,16(sp)
    80003de4:	69a2                	ld	s3,8(sp)
    80003de6:	6a02                	ld	s4,0(sp)
    80003de8:	6145                	addi	sp,sp,48
    80003dea:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003dec:	0009a503          	lw	a0,0(s3)
    80003df0:	fffff097          	auipc	ra,0xfffff
    80003df4:	68e080e7          	jalr	1678(ra) # 8000347e <bread>
    80003df8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003dfa:	05850493          	addi	s1,a0,88
    80003dfe:	45850913          	addi	s2,a0,1112
    80003e02:	a021                	j	80003e0a <itrunc+0x7a>
    80003e04:	0491                	addi	s1,s1,4
    80003e06:	01248b63          	beq	s1,s2,80003e1c <itrunc+0x8c>
      if(a[j])
    80003e0a:	408c                	lw	a1,0(s1)
    80003e0c:	dde5                	beqz	a1,80003e04 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003e0e:	0009a503          	lw	a0,0(s3)
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	8b2080e7          	jalr	-1870(ra) # 800036c4 <bfree>
    80003e1a:	b7ed                	j	80003e04 <itrunc+0x74>
    brelse(bp);
    80003e1c:	8552                	mv	a0,s4
    80003e1e:	fffff097          	auipc	ra,0xfffff
    80003e22:	790080e7          	jalr	1936(ra) # 800035ae <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003e26:	0809a583          	lw	a1,128(s3)
    80003e2a:	0009a503          	lw	a0,0(s3)
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	896080e7          	jalr	-1898(ra) # 800036c4 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003e36:	0809a023          	sw	zero,128(s3)
    80003e3a:	bf51                	j	80003dce <itrunc+0x3e>

0000000080003e3c <iput>:
{
    80003e3c:	1101                	addi	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	e04a                	sd	s2,0(sp)
    80003e46:	1000                	addi	s0,sp,32
    80003e48:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e4a:	0001c517          	auipc	a0,0x1c
    80003e4e:	39650513          	addi	a0,a0,918 # 800201e0 <itable>
    80003e52:	ffffd097          	auipc	ra,0xffffd
    80003e56:	d70080e7          	jalr	-656(ra) # 80000bc2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e5a:	4498                	lw	a4,8(s1)
    80003e5c:	4785                	li	a5,1
    80003e5e:	02f70363          	beq	a4,a5,80003e84 <iput+0x48>
  ip->ref--;
    80003e62:	449c                	lw	a5,8(s1)
    80003e64:	37fd                	addiw	a5,a5,-1
    80003e66:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e68:	0001c517          	auipc	a0,0x1c
    80003e6c:	37850513          	addi	a0,a0,888 # 800201e0 <itable>
    80003e70:	ffffd097          	auipc	ra,0xffffd
    80003e74:	e06080e7          	jalr	-506(ra) # 80000c76 <release>
}
    80003e78:	60e2                	ld	ra,24(sp)
    80003e7a:	6442                	ld	s0,16(sp)
    80003e7c:	64a2                	ld	s1,8(sp)
    80003e7e:	6902                	ld	s2,0(sp)
    80003e80:	6105                	addi	sp,sp,32
    80003e82:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003e84:	40bc                	lw	a5,64(s1)
    80003e86:	dff1                	beqz	a5,80003e62 <iput+0x26>
    80003e88:	04a49783          	lh	a5,74(s1)
    80003e8c:	fbf9                	bnez	a5,80003e62 <iput+0x26>
    acquiresleep(&ip->lock);
    80003e8e:	01048913          	addi	s2,s1,16
    80003e92:	854a                	mv	a0,s2
    80003e94:	00001097          	auipc	ra,0x1
    80003e98:	abc080e7          	jalr	-1348(ra) # 80004950 <acquiresleep>
    release(&itable.lock);
    80003e9c:	0001c517          	auipc	a0,0x1c
    80003ea0:	34450513          	addi	a0,a0,836 # 800201e0 <itable>
    80003ea4:	ffffd097          	auipc	ra,0xffffd
    80003ea8:	dd2080e7          	jalr	-558(ra) # 80000c76 <release>
    itrunc(ip);
    80003eac:	8526                	mv	a0,s1
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	ee2080e7          	jalr	-286(ra) # 80003d90 <itrunc>
    ip->type = 0;
    80003eb6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003eba:	8526                	mv	a0,s1
    80003ebc:	00000097          	auipc	ra,0x0
    80003ec0:	cfc080e7          	jalr	-772(ra) # 80003bb8 <iupdate>
    ip->valid = 0;
    80003ec4:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003ec8:	854a                	mv	a0,s2
    80003eca:	00001097          	auipc	ra,0x1
    80003ece:	adc080e7          	jalr	-1316(ra) # 800049a6 <releasesleep>
    acquire(&itable.lock);
    80003ed2:	0001c517          	auipc	a0,0x1c
    80003ed6:	30e50513          	addi	a0,a0,782 # 800201e0 <itable>
    80003eda:	ffffd097          	auipc	ra,0xffffd
    80003ede:	ce8080e7          	jalr	-792(ra) # 80000bc2 <acquire>
    80003ee2:	b741                	j	80003e62 <iput+0x26>

0000000080003ee4 <iunlockput>:
{
    80003ee4:	1101                	addi	sp,sp,-32
    80003ee6:	ec06                	sd	ra,24(sp)
    80003ee8:	e822                	sd	s0,16(sp)
    80003eea:	e426                	sd	s1,8(sp)
    80003eec:	1000                	addi	s0,sp,32
    80003eee:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	e54080e7          	jalr	-428(ra) # 80003d44 <iunlock>
  iput(ip);
    80003ef8:	8526                	mv	a0,s1
    80003efa:	00000097          	auipc	ra,0x0
    80003efe:	f42080e7          	jalr	-190(ra) # 80003e3c <iput>
}
    80003f02:	60e2                	ld	ra,24(sp)
    80003f04:	6442                	ld	s0,16(sp)
    80003f06:	64a2                	ld	s1,8(sp)
    80003f08:	6105                	addi	sp,sp,32
    80003f0a:	8082                	ret

0000000080003f0c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003f0c:	1141                	addi	sp,sp,-16
    80003f0e:	e422                	sd	s0,8(sp)
    80003f10:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003f12:	411c                	lw	a5,0(a0)
    80003f14:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003f16:	415c                	lw	a5,4(a0)
    80003f18:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003f1a:	04451783          	lh	a5,68(a0)
    80003f1e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003f22:	04a51783          	lh	a5,74(a0)
    80003f26:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003f2a:	04c56783          	lwu	a5,76(a0)
    80003f2e:	e99c                	sd	a5,16(a1)
}
    80003f30:	6422                	ld	s0,8(sp)
    80003f32:	0141                	addi	sp,sp,16
    80003f34:	8082                	ret

0000000080003f36 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f36:	457c                	lw	a5,76(a0)
    80003f38:	0ed7e963          	bltu	a5,a3,8000402a <readi+0xf4>
{
    80003f3c:	7159                	addi	sp,sp,-112
    80003f3e:	f486                	sd	ra,104(sp)
    80003f40:	f0a2                	sd	s0,96(sp)
    80003f42:	eca6                	sd	s1,88(sp)
    80003f44:	e8ca                	sd	s2,80(sp)
    80003f46:	e4ce                	sd	s3,72(sp)
    80003f48:	e0d2                	sd	s4,64(sp)
    80003f4a:	fc56                	sd	s5,56(sp)
    80003f4c:	f85a                	sd	s6,48(sp)
    80003f4e:	f45e                	sd	s7,40(sp)
    80003f50:	f062                	sd	s8,32(sp)
    80003f52:	ec66                	sd	s9,24(sp)
    80003f54:	e86a                	sd	s10,16(sp)
    80003f56:	e46e                	sd	s11,8(sp)
    80003f58:	1880                	addi	s0,sp,112
    80003f5a:	8baa                	mv	s7,a0
    80003f5c:	8c2e                	mv	s8,a1
    80003f5e:	8ab2                	mv	s5,a2
    80003f60:	84b6                	mv	s1,a3
    80003f62:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f64:	9f35                	addw	a4,a4,a3
    return 0;
    80003f66:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003f68:	0ad76063          	bltu	a4,a3,80004008 <readi+0xd2>
  if(off + n > ip->size)
    80003f6c:	00e7f463          	bgeu	a5,a4,80003f74 <readi+0x3e>
    n = ip->size - off;
    80003f70:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f74:	0a0b0963          	beqz	s6,80004026 <readi+0xf0>
    80003f78:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f7a:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f7e:	5cfd                	li	s9,-1
    80003f80:	a82d                	j	80003fba <readi+0x84>
    80003f82:	020a1d93          	slli	s11,s4,0x20
    80003f86:	020ddd93          	srli	s11,s11,0x20
    80003f8a:	05890793          	addi	a5,s2,88
    80003f8e:	86ee                	mv	a3,s11
    80003f90:	963e                	add	a2,a2,a5
    80003f92:	85d6                	mv	a1,s5
    80003f94:	8562                	mv	a0,s8
    80003f96:	fffff097          	auipc	ra,0xfffff
    80003f9a:	930080e7          	jalr	-1744(ra) # 800028c6 <either_copyout>
    80003f9e:	05950d63          	beq	a0,s9,80003ff8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003fa2:	854a                	mv	a0,s2
    80003fa4:	fffff097          	auipc	ra,0xfffff
    80003fa8:	60a080e7          	jalr	1546(ra) # 800035ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003fac:	013a09bb          	addw	s3,s4,s3
    80003fb0:	009a04bb          	addw	s1,s4,s1
    80003fb4:	9aee                	add	s5,s5,s11
    80003fb6:	0569f763          	bgeu	s3,s6,80004004 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003fba:	000ba903          	lw	s2,0(s7)
    80003fbe:	00a4d59b          	srliw	a1,s1,0xa
    80003fc2:	855e                	mv	a0,s7
    80003fc4:	00000097          	auipc	ra,0x0
    80003fc8:	8ae080e7          	jalr	-1874(ra) # 80003872 <bmap>
    80003fcc:	0005059b          	sext.w	a1,a0
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	fffff097          	auipc	ra,0xfffff
    80003fd6:	4ac080e7          	jalr	1196(ra) # 8000347e <bread>
    80003fda:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fdc:	3ff4f613          	andi	a2,s1,1023
    80003fe0:	40cd07bb          	subw	a5,s10,a2
    80003fe4:	413b073b          	subw	a4,s6,s3
    80003fe8:	8a3e                	mv	s4,a5
    80003fea:	2781                	sext.w	a5,a5
    80003fec:	0007069b          	sext.w	a3,a4
    80003ff0:	f8f6f9e3          	bgeu	a3,a5,80003f82 <readi+0x4c>
    80003ff4:	8a3a                	mv	s4,a4
    80003ff6:	b771                	j	80003f82 <readi+0x4c>
      brelse(bp);
    80003ff8:	854a                	mv	a0,s2
    80003ffa:	fffff097          	auipc	ra,0xfffff
    80003ffe:	5b4080e7          	jalr	1460(ra) # 800035ae <brelse>
      tot = -1;
    80004002:	59fd                	li	s3,-1
  }
  return tot;
    80004004:	0009851b          	sext.w	a0,s3
}
    80004008:	70a6                	ld	ra,104(sp)
    8000400a:	7406                	ld	s0,96(sp)
    8000400c:	64e6                	ld	s1,88(sp)
    8000400e:	6946                	ld	s2,80(sp)
    80004010:	69a6                	ld	s3,72(sp)
    80004012:	6a06                	ld	s4,64(sp)
    80004014:	7ae2                	ld	s5,56(sp)
    80004016:	7b42                	ld	s6,48(sp)
    80004018:	7ba2                	ld	s7,40(sp)
    8000401a:	7c02                	ld	s8,32(sp)
    8000401c:	6ce2                	ld	s9,24(sp)
    8000401e:	6d42                	ld	s10,16(sp)
    80004020:	6da2                	ld	s11,8(sp)
    80004022:	6165                	addi	sp,sp,112
    80004024:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004026:	89da                	mv	s3,s6
    80004028:	bff1                	j	80004004 <readi+0xce>
    return 0;
    8000402a:	4501                	li	a0,0
}
    8000402c:	8082                	ret

000000008000402e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000402e:	457c                	lw	a5,76(a0)
    80004030:	10d7e863          	bltu	a5,a3,80004140 <writei+0x112>
{
    80004034:	7159                	addi	sp,sp,-112
    80004036:	f486                	sd	ra,104(sp)
    80004038:	f0a2                	sd	s0,96(sp)
    8000403a:	eca6                	sd	s1,88(sp)
    8000403c:	e8ca                	sd	s2,80(sp)
    8000403e:	e4ce                	sd	s3,72(sp)
    80004040:	e0d2                	sd	s4,64(sp)
    80004042:	fc56                	sd	s5,56(sp)
    80004044:	f85a                	sd	s6,48(sp)
    80004046:	f45e                	sd	s7,40(sp)
    80004048:	f062                	sd	s8,32(sp)
    8000404a:	ec66                	sd	s9,24(sp)
    8000404c:	e86a                	sd	s10,16(sp)
    8000404e:	e46e                	sd	s11,8(sp)
    80004050:	1880                	addi	s0,sp,112
    80004052:	8b2a                	mv	s6,a0
    80004054:	8c2e                	mv	s8,a1
    80004056:	8ab2                	mv	s5,a2
    80004058:	8936                	mv	s2,a3
    8000405a:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    8000405c:	00e687bb          	addw	a5,a3,a4
    80004060:	0ed7e263          	bltu	a5,a3,80004144 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004064:	00043737          	lui	a4,0x43
    80004068:	0ef76063          	bltu	a4,a5,80004148 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000406c:	0c0b8863          	beqz	s7,8000413c <writei+0x10e>
    80004070:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004072:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004076:	5cfd                	li	s9,-1
    80004078:	a091                	j	800040bc <writei+0x8e>
    8000407a:	02099d93          	slli	s11,s3,0x20
    8000407e:	020ddd93          	srli	s11,s11,0x20
    80004082:	05848793          	addi	a5,s1,88
    80004086:	86ee                	mv	a3,s11
    80004088:	8656                	mv	a2,s5
    8000408a:	85e2                	mv	a1,s8
    8000408c:	953e                	add	a0,a0,a5
    8000408e:	fffff097          	auipc	ra,0xfffff
    80004092:	88e080e7          	jalr	-1906(ra) # 8000291c <either_copyin>
    80004096:	07950263          	beq	a0,s9,800040fa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000409a:	8526                	mv	a0,s1
    8000409c:	00000097          	auipc	ra,0x0
    800040a0:	794080e7          	jalr	1940(ra) # 80004830 <log_write>
    brelse(bp);
    800040a4:	8526                	mv	a0,s1
    800040a6:	fffff097          	auipc	ra,0xfffff
    800040aa:	508080e7          	jalr	1288(ra) # 800035ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040ae:	01498a3b          	addw	s4,s3,s4
    800040b2:	0129893b          	addw	s2,s3,s2
    800040b6:	9aee                	add	s5,s5,s11
    800040b8:	057a7663          	bgeu	s4,s7,80004104 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    800040bc:	000b2483          	lw	s1,0(s6)
    800040c0:	00a9559b          	srliw	a1,s2,0xa
    800040c4:	855a                	mv	a0,s6
    800040c6:	fffff097          	auipc	ra,0xfffff
    800040ca:	7ac080e7          	jalr	1964(ra) # 80003872 <bmap>
    800040ce:	0005059b          	sext.w	a1,a0
    800040d2:	8526                	mv	a0,s1
    800040d4:	fffff097          	auipc	ra,0xfffff
    800040d8:	3aa080e7          	jalr	938(ra) # 8000347e <bread>
    800040dc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800040de:	3ff97513          	andi	a0,s2,1023
    800040e2:	40ad07bb          	subw	a5,s10,a0
    800040e6:	414b873b          	subw	a4,s7,s4
    800040ea:	89be                	mv	s3,a5
    800040ec:	2781                	sext.w	a5,a5
    800040ee:	0007069b          	sext.w	a3,a4
    800040f2:	f8f6f4e3          	bgeu	a3,a5,8000407a <writei+0x4c>
    800040f6:	89ba                	mv	s3,a4
    800040f8:	b749                	j	8000407a <writei+0x4c>
      brelse(bp);
    800040fa:	8526                	mv	a0,s1
    800040fc:	fffff097          	auipc	ra,0xfffff
    80004100:	4b2080e7          	jalr	1202(ra) # 800035ae <brelse>
  }

  if(off > ip->size)
    80004104:	04cb2783          	lw	a5,76(s6)
    80004108:	0127f463          	bgeu	a5,s2,80004110 <writei+0xe2>
    ip->size = off;
    8000410c:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004110:	855a                	mv	a0,s6
    80004112:	00000097          	auipc	ra,0x0
    80004116:	aa6080e7          	jalr	-1370(ra) # 80003bb8 <iupdate>

  return tot;
    8000411a:	000a051b          	sext.w	a0,s4
}
    8000411e:	70a6                	ld	ra,104(sp)
    80004120:	7406                	ld	s0,96(sp)
    80004122:	64e6                	ld	s1,88(sp)
    80004124:	6946                	ld	s2,80(sp)
    80004126:	69a6                	ld	s3,72(sp)
    80004128:	6a06                	ld	s4,64(sp)
    8000412a:	7ae2                	ld	s5,56(sp)
    8000412c:	7b42                	ld	s6,48(sp)
    8000412e:	7ba2                	ld	s7,40(sp)
    80004130:	7c02                	ld	s8,32(sp)
    80004132:	6ce2                	ld	s9,24(sp)
    80004134:	6d42                	ld	s10,16(sp)
    80004136:	6da2                	ld	s11,8(sp)
    80004138:	6165                	addi	sp,sp,112
    8000413a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000413c:	8a5e                	mv	s4,s7
    8000413e:	bfc9                	j	80004110 <writei+0xe2>
    return -1;
    80004140:	557d                	li	a0,-1
}
    80004142:	8082                	ret
    return -1;
    80004144:	557d                	li	a0,-1
    80004146:	bfe1                	j	8000411e <writei+0xf0>
    return -1;
    80004148:	557d                	li	a0,-1
    8000414a:	bfd1                	j	8000411e <writei+0xf0>

000000008000414c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000414c:	1141                	addi	sp,sp,-16
    8000414e:	e406                	sd	ra,8(sp)
    80004150:	e022                	sd	s0,0(sp)
    80004152:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004154:	4639                	li	a2,14
    80004156:	ffffd097          	auipc	ra,0xffffd
    8000415a:	c40080e7          	jalr	-960(ra) # 80000d96 <strncmp>
}
    8000415e:	60a2                	ld	ra,8(sp)
    80004160:	6402                	ld	s0,0(sp)
    80004162:	0141                	addi	sp,sp,16
    80004164:	8082                	ret

0000000080004166 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004166:	7139                	addi	sp,sp,-64
    80004168:	fc06                	sd	ra,56(sp)
    8000416a:	f822                	sd	s0,48(sp)
    8000416c:	f426                	sd	s1,40(sp)
    8000416e:	f04a                	sd	s2,32(sp)
    80004170:	ec4e                	sd	s3,24(sp)
    80004172:	e852                	sd	s4,16(sp)
    80004174:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004176:	04451703          	lh	a4,68(a0)
    8000417a:	4785                	li	a5,1
    8000417c:	00f71a63          	bne	a4,a5,80004190 <dirlookup+0x2a>
    80004180:	892a                	mv	s2,a0
    80004182:	89ae                	mv	s3,a1
    80004184:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004186:	457c                	lw	a5,76(a0)
    80004188:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000418a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000418c:	e79d                	bnez	a5,800041ba <dirlookup+0x54>
    8000418e:	a8a5                	j	80004206 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004190:	00004517          	auipc	a0,0x4
    80004194:	65050513          	addi	a0,a0,1616 # 800087e0 <syscall_names_table.0+0x1b8>
    80004198:	ffffc097          	auipc	ra,0xffffc
    8000419c:	392080e7          	jalr	914(ra) # 8000052a <panic>
      panic("dirlookup read");
    800041a0:	00004517          	auipc	a0,0x4
    800041a4:	65850513          	addi	a0,a0,1624 # 800087f8 <syscall_names_table.0+0x1d0>
    800041a8:	ffffc097          	auipc	ra,0xffffc
    800041ac:	382080e7          	jalr	898(ra) # 8000052a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041b0:	24c1                	addiw	s1,s1,16
    800041b2:	04c92783          	lw	a5,76(s2)
    800041b6:	04f4f763          	bgeu	s1,a5,80004204 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041ba:	4741                	li	a4,16
    800041bc:	86a6                	mv	a3,s1
    800041be:	fc040613          	addi	a2,s0,-64
    800041c2:	4581                	li	a1,0
    800041c4:	854a                	mv	a0,s2
    800041c6:	00000097          	auipc	ra,0x0
    800041ca:	d70080e7          	jalr	-656(ra) # 80003f36 <readi>
    800041ce:	47c1                	li	a5,16
    800041d0:	fcf518e3          	bne	a0,a5,800041a0 <dirlookup+0x3a>
    if(de.inum == 0)
    800041d4:	fc045783          	lhu	a5,-64(s0)
    800041d8:	dfe1                	beqz	a5,800041b0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800041da:	fc240593          	addi	a1,s0,-62
    800041de:	854e                	mv	a0,s3
    800041e0:	00000097          	auipc	ra,0x0
    800041e4:	f6c080e7          	jalr	-148(ra) # 8000414c <namecmp>
    800041e8:	f561                	bnez	a0,800041b0 <dirlookup+0x4a>
      if(poff)
    800041ea:	000a0463          	beqz	s4,800041f2 <dirlookup+0x8c>
        *poff = off;
    800041ee:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800041f2:	fc045583          	lhu	a1,-64(s0)
    800041f6:	00092503          	lw	a0,0(s2)
    800041fa:	fffff097          	auipc	ra,0xfffff
    800041fe:	754080e7          	jalr	1876(ra) # 8000394e <iget>
    80004202:	a011                	j	80004206 <dirlookup+0xa0>
  return 0;
    80004204:	4501                	li	a0,0
}
    80004206:	70e2                	ld	ra,56(sp)
    80004208:	7442                	ld	s0,48(sp)
    8000420a:	74a2                	ld	s1,40(sp)
    8000420c:	7902                	ld	s2,32(sp)
    8000420e:	69e2                	ld	s3,24(sp)
    80004210:	6a42                	ld	s4,16(sp)
    80004212:	6121                	addi	sp,sp,64
    80004214:	8082                	ret

0000000080004216 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004216:	711d                	addi	sp,sp,-96
    80004218:	ec86                	sd	ra,88(sp)
    8000421a:	e8a2                	sd	s0,80(sp)
    8000421c:	e4a6                	sd	s1,72(sp)
    8000421e:	e0ca                	sd	s2,64(sp)
    80004220:	fc4e                	sd	s3,56(sp)
    80004222:	f852                	sd	s4,48(sp)
    80004224:	f456                	sd	s5,40(sp)
    80004226:	f05a                	sd	s6,32(sp)
    80004228:	ec5e                	sd	s7,24(sp)
    8000422a:	e862                	sd	s8,16(sp)
    8000422c:	e466                	sd	s9,8(sp)
    8000422e:	1080                	addi	s0,sp,96
    80004230:	84aa                	mv	s1,a0
    80004232:	8aae                	mv	s5,a1
    80004234:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004236:	00054703          	lbu	a4,0(a0)
    8000423a:	02f00793          	li	a5,47
    8000423e:	02f70363          	beq	a4,a5,80004264 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004242:	ffffd097          	auipc	ra,0xffffd
    80004246:	754080e7          	jalr	1876(ra) # 80001996 <myproc>
    8000424a:	15853503          	ld	a0,344(a0)
    8000424e:	00000097          	auipc	ra,0x0
    80004252:	9f6080e7          	jalr	-1546(ra) # 80003c44 <idup>
    80004256:	89aa                	mv	s3,a0
  while(*path == '/')
    80004258:	02f00913          	li	s2,47
  len = path - s;
    8000425c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000425e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004260:	4b85                	li	s7,1
    80004262:	a865                	j	8000431a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80004264:	4585                	li	a1,1
    80004266:	4505                	li	a0,1
    80004268:	fffff097          	auipc	ra,0xfffff
    8000426c:	6e6080e7          	jalr	1766(ra) # 8000394e <iget>
    80004270:	89aa                	mv	s3,a0
    80004272:	b7dd                	j	80004258 <namex+0x42>
      iunlockput(ip);
    80004274:	854e                	mv	a0,s3
    80004276:	00000097          	auipc	ra,0x0
    8000427a:	c6e080e7          	jalr	-914(ra) # 80003ee4 <iunlockput>
      return 0;
    8000427e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004280:	854e                	mv	a0,s3
    80004282:	60e6                	ld	ra,88(sp)
    80004284:	6446                	ld	s0,80(sp)
    80004286:	64a6                	ld	s1,72(sp)
    80004288:	6906                	ld	s2,64(sp)
    8000428a:	79e2                	ld	s3,56(sp)
    8000428c:	7a42                	ld	s4,48(sp)
    8000428e:	7aa2                	ld	s5,40(sp)
    80004290:	7b02                	ld	s6,32(sp)
    80004292:	6be2                	ld	s7,24(sp)
    80004294:	6c42                	ld	s8,16(sp)
    80004296:	6ca2                	ld	s9,8(sp)
    80004298:	6125                	addi	sp,sp,96
    8000429a:	8082                	ret
      iunlock(ip);
    8000429c:	854e                	mv	a0,s3
    8000429e:	00000097          	auipc	ra,0x0
    800042a2:	aa6080e7          	jalr	-1370(ra) # 80003d44 <iunlock>
      return ip;
    800042a6:	bfe9                	j	80004280 <namex+0x6a>
      iunlockput(ip);
    800042a8:	854e                	mv	a0,s3
    800042aa:	00000097          	auipc	ra,0x0
    800042ae:	c3a080e7          	jalr	-966(ra) # 80003ee4 <iunlockput>
      return 0;
    800042b2:	89e6                	mv	s3,s9
    800042b4:	b7f1                	j	80004280 <namex+0x6a>
  len = path - s;
    800042b6:	40b48633          	sub	a2,s1,a1
    800042ba:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800042be:	099c5463          	bge	s8,s9,80004346 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800042c2:	4639                	li	a2,14
    800042c4:	8552                	mv	a0,s4
    800042c6:	ffffd097          	auipc	ra,0xffffd
    800042ca:	a54080e7          	jalr	-1452(ra) # 80000d1a <memmove>
  while(*path == '/')
    800042ce:	0004c783          	lbu	a5,0(s1)
    800042d2:	01279763          	bne	a5,s2,800042e0 <namex+0xca>
    path++;
    800042d6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800042d8:	0004c783          	lbu	a5,0(s1)
    800042dc:	ff278de3          	beq	a5,s2,800042d6 <namex+0xc0>
    ilock(ip);
    800042e0:	854e                	mv	a0,s3
    800042e2:	00000097          	auipc	ra,0x0
    800042e6:	9a0080e7          	jalr	-1632(ra) # 80003c82 <ilock>
    if(ip->type != T_DIR){
    800042ea:	04499783          	lh	a5,68(s3)
    800042ee:	f97793e3          	bne	a5,s7,80004274 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800042f2:	000a8563          	beqz	s5,800042fc <namex+0xe6>
    800042f6:	0004c783          	lbu	a5,0(s1)
    800042fa:	d3cd                	beqz	a5,8000429c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800042fc:	865a                	mv	a2,s6
    800042fe:	85d2                	mv	a1,s4
    80004300:	854e                	mv	a0,s3
    80004302:	00000097          	auipc	ra,0x0
    80004306:	e64080e7          	jalr	-412(ra) # 80004166 <dirlookup>
    8000430a:	8caa                	mv	s9,a0
    8000430c:	dd51                	beqz	a0,800042a8 <namex+0x92>
    iunlockput(ip);
    8000430e:	854e                	mv	a0,s3
    80004310:	00000097          	auipc	ra,0x0
    80004314:	bd4080e7          	jalr	-1068(ra) # 80003ee4 <iunlockput>
    ip = next;
    80004318:	89e6                	mv	s3,s9
  while(*path == '/')
    8000431a:	0004c783          	lbu	a5,0(s1)
    8000431e:	05279763          	bne	a5,s2,8000436c <namex+0x156>
    path++;
    80004322:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004324:	0004c783          	lbu	a5,0(s1)
    80004328:	ff278de3          	beq	a5,s2,80004322 <namex+0x10c>
  if(*path == 0)
    8000432c:	c79d                	beqz	a5,8000435a <namex+0x144>
    path++;
    8000432e:	85a6                	mv	a1,s1
  len = path - s;
    80004330:	8cda                	mv	s9,s6
    80004332:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004334:	01278963          	beq	a5,s2,80004346 <namex+0x130>
    80004338:	dfbd                	beqz	a5,800042b6 <namex+0xa0>
    path++;
    8000433a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000433c:	0004c783          	lbu	a5,0(s1)
    80004340:	ff279ce3          	bne	a5,s2,80004338 <namex+0x122>
    80004344:	bf8d                	j	800042b6 <namex+0xa0>
    memmove(name, s, len);
    80004346:	2601                	sext.w	a2,a2
    80004348:	8552                	mv	a0,s4
    8000434a:	ffffd097          	auipc	ra,0xffffd
    8000434e:	9d0080e7          	jalr	-1584(ra) # 80000d1a <memmove>
    name[len] = 0;
    80004352:	9cd2                	add	s9,s9,s4
    80004354:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004358:	bf9d                	j	800042ce <namex+0xb8>
  if(nameiparent){
    8000435a:	f20a83e3          	beqz	s5,80004280 <namex+0x6a>
    iput(ip);
    8000435e:	854e                	mv	a0,s3
    80004360:	00000097          	auipc	ra,0x0
    80004364:	adc080e7          	jalr	-1316(ra) # 80003e3c <iput>
    return 0;
    80004368:	4981                	li	s3,0
    8000436a:	bf19                	j	80004280 <namex+0x6a>
  if(*path == 0)
    8000436c:	d7fd                	beqz	a5,8000435a <namex+0x144>
  while(*path != '/' && *path != 0)
    8000436e:	0004c783          	lbu	a5,0(s1)
    80004372:	85a6                	mv	a1,s1
    80004374:	b7d1                	j	80004338 <namex+0x122>

0000000080004376 <dirlink>:
{
    80004376:	7139                	addi	sp,sp,-64
    80004378:	fc06                	sd	ra,56(sp)
    8000437a:	f822                	sd	s0,48(sp)
    8000437c:	f426                	sd	s1,40(sp)
    8000437e:	f04a                	sd	s2,32(sp)
    80004380:	ec4e                	sd	s3,24(sp)
    80004382:	e852                	sd	s4,16(sp)
    80004384:	0080                	addi	s0,sp,64
    80004386:	892a                	mv	s2,a0
    80004388:	8a2e                	mv	s4,a1
    8000438a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000438c:	4601                	li	a2,0
    8000438e:	00000097          	auipc	ra,0x0
    80004392:	dd8080e7          	jalr	-552(ra) # 80004166 <dirlookup>
    80004396:	e93d                	bnez	a0,8000440c <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004398:	04c92483          	lw	s1,76(s2)
    8000439c:	c49d                	beqz	s1,800043ca <dirlink+0x54>
    8000439e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043a0:	4741                	li	a4,16
    800043a2:	86a6                	mv	a3,s1
    800043a4:	fc040613          	addi	a2,s0,-64
    800043a8:	4581                	li	a1,0
    800043aa:	854a                	mv	a0,s2
    800043ac:	00000097          	auipc	ra,0x0
    800043b0:	b8a080e7          	jalr	-1142(ra) # 80003f36 <readi>
    800043b4:	47c1                	li	a5,16
    800043b6:	06f51163          	bne	a0,a5,80004418 <dirlink+0xa2>
    if(de.inum == 0)
    800043ba:	fc045783          	lhu	a5,-64(s0)
    800043be:	c791                	beqz	a5,800043ca <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800043c0:	24c1                	addiw	s1,s1,16
    800043c2:	04c92783          	lw	a5,76(s2)
    800043c6:	fcf4ede3          	bltu	s1,a5,800043a0 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800043ca:	4639                	li	a2,14
    800043cc:	85d2                	mv	a1,s4
    800043ce:	fc240513          	addi	a0,s0,-62
    800043d2:	ffffd097          	auipc	ra,0xffffd
    800043d6:	a00080e7          	jalr	-1536(ra) # 80000dd2 <strncpy>
  de.inum = inum;
    800043da:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043de:	4741                	li	a4,16
    800043e0:	86a6                	mv	a3,s1
    800043e2:	fc040613          	addi	a2,s0,-64
    800043e6:	4581                	li	a1,0
    800043e8:	854a                	mv	a0,s2
    800043ea:	00000097          	auipc	ra,0x0
    800043ee:	c44080e7          	jalr	-956(ra) # 8000402e <writei>
    800043f2:	872a                	mv	a4,a0
    800043f4:	47c1                	li	a5,16
  return 0;
    800043f6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800043f8:	02f71863          	bne	a4,a5,80004428 <dirlink+0xb2>
}
    800043fc:	70e2                	ld	ra,56(sp)
    800043fe:	7442                	ld	s0,48(sp)
    80004400:	74a2                	ld	s1,40(sp)
    80004402:	7902                	ld	s2,32(sp)
    80004404:	69e2                	ld	s3,24(sp)
    80004406:	6a42                	ld	s4,16(sp)
    80004408:	6121                	addi	sp,sp,64
    8000440a:	8082                	ret
    iput(ip);
    8000440c:	00000097          	auipc	ra,0x0
    80004410:	a30080e7          	jalr	-1488(ra) # 80003e3c <iput>
    return -1;
    80004414:	557d                	li	a0,-1
    80004416:	b7dd                	j	800043fc <dirlink+0x86>
      panic("dirlink read");
    80004418:	00004517          	auipc	a0,0x4
    8000441c:	3f050513          	addi	a0,a0,1008 # 80008808 <syscall_names_table.0+0x1e0>
    80004420:	ffffc097          	auipc	ra,0xffffc
    80004424:	10a080e7          	jalr	266(ra) # 8000052a <panic>
    panic("dirlink");
    80004428:	00004517          	auipc	a0,0x4
    8000442c:	4e850513          	addi	a0,a0,1256 # 80008910 <syscall_names_table.0+0x2e8>
    80004430:	ffffc097          	auipc	ra,0xffffc
    80004434:	0fa080e7          	jalr	250(ra) # 8000052a <panic>

0000000080004438 <namei>:

struct inode*
namei(char *path)
{
    80004438:	1101                	addi	sp,sp,-32
    8000443a:	ec06                	sd	ra,24(sp)
    8000443c:	e822                	sd	s0,16(sp)
    8000443e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004440:	fe040613          	addi	a2,s0,-32
    80004444:	4581                	li	a1,0
    80004446:	00000097          	auipc	ra,0x0
    8000444a:	dd0080e7          	jalr	-560(ra) # 80004216 <namex>
}
    8000444e:	60e2                	ld	ra,24(sp)
    80004450:	6442                	ld	s0,16(sp)
    80004452:	6105                	addi	sp,sp,32
    80004454:	8082                	ret

0000000080004456 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004456:	1141                	addi	sp,sp,-16
    80004458:	e406                	sd	ra,8(sp)
    8000445a:	e022                	sd	s0,0(sp)
    8000445c:	0800                	addi	s0,sp,16
    8000445e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004460:	4585                	li	a1,1
    80004462:	00000097          	auipc	ra,0x0
    80004466:	db4080e7          	jalr	-588(ra) # 80004216 <namex>
}
    8000446a:	60a2                	ld	ra,8(sp)
    8000446c:	6402                	ld	s0,0(sp)
    8000446e:	0141                	addi	sp,sp,16
    80004470:	8082                	ret

0000000080004472 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004472:	1101                	addi	sp,sp,-32
    80004474:	ec06                	sd	ra,24(sp)
    80004476:	e822                	sd	s0,16(sp)
    80004478:	e426                	sd	s1,8(sp)
    8000447a:	e04a                	sd	s2,0(sp)
    8000447c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000447e:	0001e917          	auipc	s2,0x1e
    80004482:	80a90913          	addi	s2,s2,-2038 # 80021c88 <log>
    80004486:	01892583          	lw	a1,24(s2)
    8000448a:	02892503          	lw	a0,40(s2)
    8000448e:	fffff097          	auipc	ra,0xfffff
    80004492:	ff0080e7          	jalr	-16(ra) # 8000347e <bread>
    80004496:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004498:	02c92683          	lw	a3,44(s2)
    8000449c:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000449e:	02d05863          	blez	a3,800044ce <write_head+0x5c>
    800044a2:	0001e797          	auipc	a5,0x1e
    800044a6:	81678793          	addi	a5,a5,-2026 # 80021cb8 <log+0x30>
    800044aa:	05c50713          	addi	a4,a0,92
    800044ae:	36fd                	addiw	a3,a3,-1
    800044b0:	02069613          	slli	a2,a3,0x20
    800044b4:	01e65693          	srli	a3,a2,0x1e
    800044b8:	0001e617          	auipc	a2,0x1e
    800044bc:	80460613          	addi	a2,a2,-2044 # 80021cbc <log+0x34>
    800044c0:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800044c2:	4390                	lw	a2,0(a5)
    800044c4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044c6:	0791                	addi	a5,a5,4
    800044c8:	0711                	addi	a4,a4,4
    800044ca:	fed79ce3          	bne	a5,a3,800044c2 <write_head+0x50>
  }
  bwrite(buf);
    800044ce:	8526                	mv	a0,s1
    800044d0:	fffff097          	auipc	ra,0xfffff
    800044d4:	0a0080e7          	jalr	160(ra) # 80003570 <bwrite>
  brelse(buf);
    800044d8:	8526                	mv	a0,s1
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	0d4080e7          	jalr	212(ra) # 800035ae <brelse>
}
    800044e2:	60e2                	ld	ra,24(sp)
    800044e4:	6442                	ld	s0,16(sp)
    800044e6:	64a2                	ld	s1,8(sp)
    800044e8:	6902                	ld	s2,0(sp)
    800044ea:	6105                	addi	sp,sp,32
    800044ec:	8082                	ret

00000000800044ee <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800044ee:	0001d797          	auipc	a5,0x1d
    800044f2:	7c67a783          	lw	a5,1990(a5) # 80021cb4 <log+0x2c>
    800044f6:	0af05d63          	blez	a5,800045b0 <install_trans+0xc2>
{
    800044fa:	7139                	addi	sp,sp,-64
    800044fc:	fc06                	sd	ra,56(sp)
    800044fe:	f822                	sd	s0,48(sp)
    80004500:	f426                	sd	s1,40(sp)
    80004502:	f04a                	sd	s2,32(sp)
    80004504:	ec4e                	sd	s3,24(sp)
    80004506:	e852                	sd	s4,16(sp)
    80004508:	e456                	sd	s5,8(sp)
    8000450a:	e05a                	sd	s6,0(sp)
    8000450c:	0080                	addi	s0,sp,64
    8000450e:	8b2a                	mv	s6,a0
    80004510:	0001da97          	auipc	s5,0x1d
    80004514:	7a8a8a93          	addi	s5,s5,1960 # 80021cb8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004518:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000451a:	0001d997          	auipc	s3,0x1d
    8000451e:	76e98993          	addi	s3,s3,1902 # 80021c88 <log>
    80004522:	a00d                	j	80004544 <install_trans+0x56>
    brelse(lbuf);
    80004524:	854a                	mv	a0,s2
    80004526:	fffff097          	auipc	ra,0xfffff
    8000452a:	088080e7          	jalr	136(ra) # 800035ae <brelse>
    brelse(dbuf);
    8000452e:	8526                	mv	a0,s1
    80004530:	fffff097          	auipc	ra,0xfffff
    80004534:	07e080e7          	jalr	126(ra) # 800035ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004538:	2a05                	addiw	s4,s4,1
    8000453a:	0a91                	addi	s5,s5,4
    8000453c:	02c9a783          	lw	a5,44(s3)
    80004540:	04fa5e63          	bge	s4,a5,8000459c <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004544:	0189a583          	lw	a1,24(s3)
    80004548:	014585bb          	addw	a1,a1,s4
    8000454c:	2585                	addiw	a1,a1,1
    8000454e:	0289a503          	lw	a0,40(s3)
    80004552:	fffff097          	auipc	ra,0xfffff
    80004556:	f2c080e7          	jalr	-212(ra) # 8000347e <bread>
    8000455a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000455c:	000aa583          	lw	a1,0(s5)
    80004560:	0289a503          	lw	a0,40(s3)
    80004564:	fffff097          	auipc	ra,0xfffff
    80004568:	f1a080e7          	jalr	-230(ra) # 8000347e <bread>
    8000456c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000456e:	40000613          	li	a2,1024
    80004572:	05890593          	addi	a1,s2,88
    80004576:	05850513          	addi	a0,a0,88
    8000457a:	ffffc097          	auipc	ra,0xffffc
    8000457e:	7a0080e7          	jalr	1952(ra) # 80000d1a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004582:	8526                	mv	a0,s1
    80004584:	fffff097          	auipc	ra,0xfffff
    80004588:	fec080e7          	jalr	-20(ra) # 80003570 <bwrite>
    if(recovering == 0)
    8000458c:	f80b1ce3          	bnez	s6,80004524 <install_trans+0x36>
      bunpin(dbuf);
    80004590:	8526                	mv	a0,s1
    80004592:	fffff097          	auipc	ra,0xfffff
    80004596:	0f6080e7          	jalr	246(ra) # 80003688 <bunpin>
    8000459a:	b769                	j	80004524 <install_trans+0x36>
}
    8000459c:	70e2                	ld	ra,56(sp)
    8000459e:	7442                	ld	s0,48(sp)
    800045a0:	74a2                	ld	s1,40(sp)
    800045a2:	7902                	ld	s2,32(sp)
    800045a4:	69e2                	ld	s3,24(sp)
    800045a6:	6a42                	ld	s4,16(sp)
    800045a8:	6aa2                	ld	s5,8(sp)
    800045aa:	6b02                	ld	s6,0(sp)
    800045ac:	6121                	addi	sp,sp,64
    800045ae:	8082                	ret
    800045b0:	8082                	ret

00000000800045b2 <initlog>:
{
    800045b2:	7179                	addi	sp,sp,-48
    800045b4:	f406                	sd	ra,40(sp)
    800045b6:	f022                	sd	s0,32(sp)
    800045b8:	ec26                	sd	s1,24(sp)
    800045ba:	e84a                	sd	s2,16(sp)
    800045bc:	e44e                	sd	s3,8(sp)
    800045be:	1800                	addi	s0,sp,48
    800045c0:	892a                	mv	s2,a0
    800045c2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800045c4:	0001d497          	auipc	s1,0x1d
    800045c8:	6c448493          	addi	s1,s1,1732 # 80021c88 <log>
    800045cc:	00004597          	auipc	a1,0x4
    800045d0:	24c58593          	addi	a1,a1,588 # 80008818 <syscall_names_table.0+0x1f0>
    800045d4:	8526                	mv	a0,s1
    800045d6:	ffffc097          	auipc	ra,0xffffc
    800045da:	55c080e7          	jalr	1372(ra) # 80000b32 <initlock>
  log.start = sb->logstart;
    800045de:	0149a583          	lw	a1,20(s3)
    800045e2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800045e4:	0109a783          	lw	a5,16(s3)
    800045e8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800045ea:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800045ee:	854a                	mv	a0,s2
    800045f0:	fffff097          	auipc	ra,0xfffff
    800045f4:	e8e080e7          	jalr	-370(ra) # 8000347e <bread>
  log.lh.n = lh->n;
    800045f8:	4d34                	lw	a3,88(a0)
    800045fa:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800045fc:	02d05663          	blez	a3,80004628 <initlog+0x76>
    80004600:	05c50793          	addi	a5,a0,92
    80004604:	0001d717          	auipc	a4,0x1d
    80004608:	6b470713          	addi	a4,a4,1716 # 80021cb8 <log+0x30>
    8000460c:	36fd                	addiw	a3,a3,-1
    8000460e:	02069613          	slli	a2,a3,0x20
    80004612:	01e65693          	srli	a3,a2,0x1e
    80004616:	06050613          	addi	a2,a0,96
    8000461a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000461c:	4390                	lw	a2,0(a5)
    8000461e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004620:	0791                	addi	a5,a5,4
    80004622:	0711                	addi	a4,a4,4
    80004624:	fed79ce3          	bne	a5,a3,8000461c <initlog+0x6a>
  brelse(buf);
    80004628:	fffff097          	auipc	ra,0xfffff
    8000462c:	f86080e7          	jalr	-122(ra) # 800035ae <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004630:	4505                	li	a0,1
    80004632:	00000097          	auipc	ra,0x0
    80004636:	ebc080e7          	jalr	-324(ra) # 800044ee <install_trans>
  log.lh.n = 0;
    8000463a:	0001d797          	auipc	a5,0x1d
    8000463e:	6607ad23          	sw	zero,1658(a5) # 80021cb4 <log+0x2c>
  write_head(); // clear the log
    80004642:	00000097          	auipc	ra,0x0
    80004646:	e30080e7          	jalr	-464(ra) # 80004472 <write_head>
}
    8000464a:	70a2                	ld	ra,40(sp)
    8000464c:	7402                	ld	s0,32(sp)
    8000464e:	64e2                	ld	s1,24(sp)
    80004650:	6942                	ld	s2,16(sp)
    80004652:	69a2                	ld	s3,8(sp)
    80004654:	6145                	addi	sp,sp,48
    80004656:	8082                	ret

0000000080004658 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004658:	1101                	addi	sp,sp,-32
    8000465a:	ec06                	sd	ra,24(sp)
    8000465c:	e822                	sd	s0,16(sp)
    8000465e:	e426                	sd	s1,8(sp)
    80004660:	e04a                	sd	s2,0(sp)
    80004662:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004664:	0001d517          	auipc	a0,0x1d
    80004668:	62450513          	addi	a0,a0,1572 # 80021c88 <log>
    8000466c:	ffffc097          	auipc	ra,0xffffc
    80004670:	556080e7          	jalr	1366(ra) # 80000bc2 <acquire>
  while(1){
    if(log.committing){
    80004674:	0001d497          	auipc	s1,0x1d
    80004678:	61448493          	addi	s1,s1,1556 # 80021c88 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000467c:	4979                	li	s2,30
    8000467e:	a039                	j	8000468c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004680:	85a6                	mv	a1,s1
    80004682:	8526                	mv	a0,s1
    80004684:	ffffe097          	auipc	ra,0xffffe
    80004688:	bca080e7          	jalr	-1078(ra) # 8000224e <sleep>
    if(log.committing){
    8000468c:	50dc                	lw	a5,36(s1)
    8000468e:	fbed                	bnez	a5,80004680 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004690:	509c                	lw	a5,32(s1)
    80004692:	0017871b          	addiw	a4,a5,1
    80004696:	0007069b          	sext.w	a3,a4
    8000469a:	0027179b          	slliw	a5,a4,0x2
    8000469e:	9fb9                	addw	a5,a5,a4
    800046a0:	0017979b          	slliw	a5,a5,0x1
    800046a4:	54d8                	lw	a4,44(s1)
    800046a6:	9fb9                	addw	a5,a5,a4
    800046a8:	00f95963          	bge	s2,a5,800046ba <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800046ac:	85a6                	mv	a1,s1
    800046ae:	8526                	mv	a0,s1
    800046b0:	ffffe097          	auipc	ra,0xffffe
    800046b4:	b9e080e7          	jalr	-1122(ra) # 8000224e <sleep>
    800046b8:	bfd1                	j	8000468c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800046ba:	0001d517          	auipc	a0,0x1d
    800046be:	5ce50513          	addi	a0,a0,1486 # 80021c88 <log>
    800046c2:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800046c4:	ffffc097          	auipc	ra,0xffffc
    800046c8:	5b2080e7          	jalr	1458(ra) # 80000c76 <release>
      break;
    }
  }
}
    800046cc:	60e2                	ld	ra,24(sp)
    800046ce:	6442                	ld	s0,16(sp)
    800046d0:	64a2                	ld	s1,8(sp)
    800046d2:	6902                	ld	s2,0(sp)
    800046d4:	6105                	addi	sp,sp,32
    800046d6:	8082                	ret

00000000800046d8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800046d8:	7139                	addi	sp,sp,-64
    800046da:	fc06                	sd	ra,56(sp)
    800046dc:	f822                	sd	s0,48(sp)
    800046de:	f426                	sd	s1,40(sp)
    800046e0:	f04a                	sd	s2,32(sp)
    800046e2:	ec4e                	sd	s3,24(sp)
    800046e4:	e852                	sd	s4,16(sp)
    800046e6:	e456                	sd	s5,8(sp)
    800046e8:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800046ea:	0001d497          	auipc	s1,0x1d
    800046ee:	59e48493          	addi	s1,s1,1438 # 80021c88 <log>
    800046f2:	8526                	mv	a0,s1
    800046f4:	ffffc097          	auipc	ra,0xffffc
    800046f8:	4ce080e7          	jalr	1230(ra) # 80000bc2 <acquire>
  log.outstanding -= 1;
    800046fc:	509c                	lw	a5,32(s1)
    800046fe:	37fd                	addiw	a5,a5,-1
    80004700:	0007891b          	sext.w	s2,a5
    80004704:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004706:	50dc                	lw	a5,36(s1)
    80004708:	e7b9                	bnez	a5,80004756 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000470a:	04091e63          	bnez	s2,80004766 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000470e:	0001d497          	auipc	s1,0x1d
    80004712:	57a48493          	addi	s1,s1,1402 # 80021c88 <log>
    80004716:	4785                	li	a5,1
    80004718:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000471a:	8526                	mv	a0,s1
    8000471c:	ffffc097          	auipc	ra,0xffffc
    80004720:	55a080e7          	jalr	1370(ra) # 80000c76 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004724:	54dc                	lw	a5,44(s1)
    80004726:	06f04763          	bgtz	a5,80004794 <end_op+0xbc>
    acquire(&log.lock);
    8000472a:	0001d497          	auipc	s1,0x1d
    8000472e:	55e48493          	addi	s1,s1,1374 # 80021c88 <log>
    80004732:	8526                	mv	a0,s1
    80004734:	ffffc097          	auipc	ra,0xffffc
    80004738:	48e080e7          	jalr	1166(ra) # 80000bc2 <acquire>
    log.committing = 0;
    8000473c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004740:	8526                	mv	a0,s1
    80004742:	ffffe097          	auipc	ra,0xffffe
    80004746:	c98080e7          	jalr	-872(ra) # 800023da <wakeup>
    release(&log.lock);
    8000474a:	8526                	mv	a0,s1
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	52a080e7          	jalr	1322(ra) # 80000c76 <release>
}
    80004754:	a03d                	j	80004782 <end_op+0xaa>
    panic("log.committing");
    80004756:	00004517          	auipc	a0,0x4
    8000475a:	0ca50513          	addi	a0,a0,202 # 80008820 <syscall_names_table.0+0x1f8>
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	dcc080e7          	jalr	-564(ra) # 8000052a <panic>
    wakeup(&log);
    80004766:	0001d497          	auipc	s1,0x1d
    8000476a:	52248493          	addi	s1,s1,1314 # 80021c88 <log>
    8000476e:	8526                	mv	a0,s1
    80004770:	ffffe097          	auipc	ra,0xffffe
    80004774:	c6a080e7          	jalr	-918(ra) # 800023da <wakeup>
  release(&log.lock);
    80004778:	8526                	mv	a0,s1
    8000477a:	ffffc097          	auipc	ra,0xffffc
    8000477e:	4fc080e7          	jalr	1276(ra) # 80000c76 <release>
}
    80004782:	70e2                	ld	ra,56(sp)
    80004784:	7442                	ld	s0,48(sp)
    80004786:	74a2                	ld	s1,40(sp)
    80004788:	7902                	ld	s2,32(sp)
    8000478a:	69e2                	ld	s3,24(sp)
    8000478c:	6a42                	ld	s4,16(sp)
    8000478e:	6aa2                	ld	s5,8(sp)
    80004790:	6121                	addi	sp,sp,64
    80004792:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004794:	0001da97          	auipc	s5,0x1d
    80004798:	524a8a93          	addi	s5,s5,1316 # 80021cb8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000479c:	0001da17          	auipc	s4,0x1d
    800047a0:	4eca0a13          	addi	s4,s4,1260 # 80021c88 <log>
    800047a4:	018a2583          	lw	a1,24(s4)
    800047a8:	012585bb          	addw	a1,a1,s2
    800047ac:	2585                	addiw	a1,a1,1
    800047ae:	028a2503          	lw	a0,40(s4)
    800047b2:	fffff097          	auipc	ra,0xfffff
    800047b6:	ccc080e7          	jalr	-820(ra) # 8000347e <bread>
    800047ba:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800047bc:	000aa583          	lw	a1,0(s5)
    800047c0:	028a2503          	lw	a0,40(s4)
    800047c4:	fffff097          	auipc	ra,0xfffff
    800047c8:	cba080e7          	jalr	-838(ra) # 8000347e <bread>
    800047cc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800047ce:	40000613          	li	a2,1024
    800047d2:	05850593          	addi	a1,a0,88
    800047d6:	05848513          	addi	a0,s1,88
    800047da:	ffffc097          	auipc	ra,0xffffc
    800047de:	540080e7          	jalr	1344(ra) # 80000d1a <memmove>
    bwrite(to);  // write the log
    800047e2:	8526                	mv	a0,s1
    800047e4:	fffff097          	auipc	ra,0xfffff
    800047e8:	d8c080e7          	jalr	-628(ra) # 80003570 <bwrite>
    brelse(from);
    800047ec:	854e                	mv	a0,s3
    800047ee:	fffff097          	auipc	ra,0xfffff
    800047f2:	dc0080e7          	jalr	-576(ra) # 800035ae <brelse>
    brelse(to);
    800047f6:	8526                	mv	a0,s1
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	db6080e7          	jalr	-586(ra) # 800035ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004800:	2905                	addiw	s2,s2,1
    80004802:	0a91                	addi	s5,s5,4
    80004804:	02ca2783          	lw	a5,44(s4)
    80004808:	f8f94ee3          	blt	s2,a5,800047a4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000480c:	00000097          	auipc	ra,0x0
    80004810:	c66080e7          	jalr	-922(ra) # 80004472 <write_head>
    install_trans(0); // Now install writes to home locations
    80004814:	4501                	li	a0,0
    80004816:	00000097          	auipc	ra,0x0
    8000481a:	cd8080e7          	jalr	-808(ra) # 800044ee <install_trans>
    log.lh.n = 0;
    8000481e:	0001d797          	auipc	a5,0x1d
    80004822:	4807ab23          	sw	zero,1174(a5) # 80021cb4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004826:	00000097          	auipc	ra,0x0
    8000482a:	c4c080e7          	jalr	-948(ra) # 80004472 <write_head>
    8000482e:	bdf5                	j	8000472a <end_op+0x52>

0000000080004830 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004830:	1101                	addi	sp,sp,-32
    80004832:	ec06                	sd	ra,24(sp)
    80004834:	e822                	sd	s0,16(sp)
    80004836:	e426                	sd	s1,8(sp)
    80004838:	e04a                	sd	s2,0(sp)
    8000483a:	1000                	addi	s0,sp,32
    8000483c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000483e:	0001d917          	auipc	s2,0x1d
    80004842:	44a90913          	addi	s2,s2,1098 # 80021c88 <log>
    80004846:	854a                	mv	a0,s2
    80004848:	ffffc097          	auipc	ra,0xffffc
    8000484c:	37a080e7          	jalr	890(ra) # 80000bc2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004850:	02c92603          	lw	a2,44(s2)
    80004854:	47f5                	li	a5,29
    80004856:	06c7c563          	blt	a5,a2,800048c0 <log_write+0x90>
    8000485a:	0001d797          	auipc	a5,0x1d
    8000485e:	44a7a783          	lw	a5,1098(a5) # 80021ca4 <log+0x1c>
    80004862:	37fd                	addiw	a5,a5,-1
    80004864:	04f65e63          	bge	a2,a5,800048c0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004868:	0001d797          	auipc	a5,0x1d
    8000486c:	4407a783          	lw	a5,1088(a5) # 80021ca8 <log+0x20>
    80004870:	06f05063          	blez	a5,800048d0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004874:	4781                	li	a5,0
    80004876:	06c05563          	blez	a2,800048e0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000487a:	44cc                	lw	a1,12(s1)
    8000487c:	0001d717          	auipc	a4,0x1d
    80004880:	43c70713          	addi	a4,a4,1084 # 80021cb8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004884:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004886:	4314                	lw	a3,0(a4)
    80004888:	04b68c63          	beq	a3,a1,800048e0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000488c:	2785                	addiw	a5,a5,1
    8000488e:	0711                	addi	a4,a4,4
    80004890:	fef61be3          	bne	a2,a5,80004886 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004894:	0621                	addi	a2,a2,8
    80004896:	060a                	slli	a2,a2,0x2
    80004898:	0001d797          	auipc	a5,0x1d
    8000489c:	3f078793          	addi	a5,a5,1008 # 80021c88 <log>
    800048a0:	963e                	add	a2,a2,a5
    800048a2:	44dc                	lw	a5,12(s1)
    800048a4:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800048a6:	8526                	mv	a0,s1
    800048a8:	fffff097          	auipc	ra,0xfffff
    800048ac:	da4080e7          	jalr	-604(ra) # 8000364c <bpin>
    log.lh.n++;
    800048b0:	0001d717          	auipc	a4,0x1d
    800048b4:	3d870713          	addi	a4,a4,984 # 80021c88 <log>
    800048b8:	575c                	lw	a5,44(a4)
    800048ba:	2785                	addiw	a5,a5,1
    800048bc:	d75c                	sw	a5,44(a4)
    800048be:	a835                	j	800048fa <log_write+0xca>
    panic("too big a transaction");
    800048c0:	00004517          	auipc	a0,0x4
    800048c4:	f7050513          	addi	a0,a0,-144 # 80008830 <syscall_names_table.0+0x208>
    800048c8:	ffffc097          	auipc	ra,0xffffc
    800048cc:	c62080e7          	jalr	-926(ra) # 8000052a <panic>
    panic("log_write outside of trans");
    800048d0:	00004517          	auipc	a0,0x4
    800048d4:	f7850513          	addi	a0,a0,-136 # 80008848 <syscall_names_table.0+0x220>
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	c52080e7          	jalr	-942(ra) # 8000052a <panic>
  log.lh.block[i] = b->blockno;
    800048e0:	00878713          	addi	a4,a5,8
    800048e4:	00271693          	slli	a3,a4,0x2
    800048e8:	0001d717          	auipc	a4,0x1d
    800048ec:	3a070713          	addi	a4,a4,928 # 80021c88 <log>
    800048f0:	9736                	add	a4,a4,a3
    800048f2:	44d4                	lw	a3,12(s1)
    800048f4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800048f6:	faf608e3          	beq	a2,a5,800048a6 <log_write+0x76>
  }
  release(&log.lock);
    800048fa:	0001d517          	auipc	a0,0x1d
    800048fe:	38e50513          	addi	a0,a0,910 # 80021c88 <log>
    80004902:	ffffc097          	auipc	ra,0xffffc
    80004906:	374080e7          	jalr	884(ra) # 80000c76 <release>
}
    8000490a:	60e2                	ld	ra,24(sp)
    8000490c:	6442                	ld	s0,16(sp)
    8000490e:	64a2                	ld	s1,8(sp)
    80004910:	6902                	ld	s2,0(sp)
    80004912:	6105                	addi	sp,sp,32
    80004914:	8082                	ret

0000000080004916 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004916:	1101                	addi	sp,sp,-32
    80004918:	ec06                	sd	ra,24(sp)
    8000491a:	e822                	sd	s0,16(sp)
    8000491c:	e426                	sd	s1,8(sp)
    8000491e:	e04a                	sd	s2,0(sp)
    80004920:	1000                	addi	s0,sp,32
    80004922:	84aa                	mv	s1,a0
    80004924:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004926:	00004597          	auipc	a1,0x4
    8000492a:	f4258593          	addi	a1,a1,-190 # 80008868 <syscall_names_table.0+0x240>
    8000492e:	0521                	addi	a0,a0,8
    80004930:	ffffc097          	auipc	ra,0xffffc
    80004934:	202080e7          	jalr	514(ra) # 80000b32 <initlock>
  lk->name = name;
    80004938:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000493c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004940:	0204a423          	sw	zero,40(s1)
}
    80004944:	60e2                	ld	ra,24(sp)
    80004946:	6442                	ld	s0,16(sp)
    80004948:	64a2                	ld	s1,8(sp)
    8000494a:	6902                	ld	s2,0(sp)
    8000494c:	6105                	addi	sp,sp,32
    8000494e:	8082                	ret

0000000080004950 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004950:	1101                	addi	sp,sp,-32
    80004952:	ec06                	sd	ra,24(sp)
    80004954:	e822                	sd	s0,16(sp)
    80004956:	e426                	sd	s1,8(sp)
    80004958:	e04a                	sd	s2,0(sp)
    8000495a:	1000                	addi	s0,sp,32
    8000495c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000495e:	00850913          	addi	s2,a0,8
    80004962:	854a                	mv	a0,s2
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	25e080e7          	jalr	606(ra) # 80000bc2 <acquire>
  while (lk->locked) {
    8000496c:	409c                	lw	a5,0(s1)
    8000496e:	cb89                	beqz	a5,80004980 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004970:	85ca                	mv	a1,s2
    80004972:	8526                	mv	a0,s1
    80004974:	ffffe097          	auipc	ra,0xffffe
    80004978:	8da080e7          	jalr	-1830(ra) # 8000224e <sleep>
  while (lk->locked) {
    8000497c:	409c                	lw	a5,0(s1)
    8000497e:	fbed                	bnez	a5,80004970 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004980:	4785                	li	a5,1
    80004982:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004984:	ffffd097          	auipc	ra,0xffffd
    80004988:	012080e7          	jalr	18(ra) # 80001996 <myproc>
    8000498c:	591c                	lw	a5,48(a0)
    8000498e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004990:	854a                	mv	a0,s2
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	2e4080e7          	jalr	740(ra) # 80000c76 <release>
}
    8000499a:	60e2                	ld	ra,24(sp)
    8000499c:	6442                	ld	s0,16(sp)
    8000499e:	64a2                	ld	s1,8(sp)
    800049a0:	6902                	ld	s2,0(sp)
    800049a2:	6105                	addi	sp,sp,32
    800049a4:	8082                	ret

00000000800049a6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800049a6:	1101                	addi	sp,sp,-32
    800049a8:	ec06                	sd	ra,24(sp)
    800049aa:	e822                	sd	s0,16(sp)
    800049ac:	e426                	sd	s1,8(sp)
    800049ae:	e04a                	sd	s2,0(sp)
    800049b0:	1000                	addi	s0,sp,32
    800049b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800049b4:	00850913          	addi	s2,a0,8
    800049b8:	854a                	mv	a0,s2
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	208080e7          	jalr	520(ra) # 80000bc2 <acquire>
  lk->locked = 0;
    800049c2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800049c6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800049ca:	8526                	mv	a0,s1
    800049cc:	ffffe097          	auipc	ra,0xffffe
    800049d0:	a0e080e7          	jalr	-1522(ra) # 800023da <wakeup>
  release(&lk->lk);
    800049d4:	854a                	mv	a0,s2
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	2a0080e7          	jalr	672(ra) # 80000c76 <release>
}
    800049de:	60e2                	ld	ra,24(sp)
    800049e0:	6442                	ld	s0,16(sp)
    800049e2:	64a2                	ld	s1,8(sp)
    800049e4:	6902                	ld	s2,0(sp)
    800049e6:	6105                	addi	sp,sp,32
    800049e8:	8082                	ret

00000000800049ea <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800049ea:	7179                	addi	sp,sp,-48
    800049ec:	f406                	sd	ra,40(sp)
    800049ee:	f022                	sd	s0,32(sp)
    800049f0:	ec26                	sd	s1,24(sp)
    800049f2:	e84a                	sd	s2,16(sp)
    800049f4:	e44e                	sd	s3,8(sp)
    800049f6:	1800                	addi	s0,sp,48
    800049f8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800049fa:	00850913          	addi	s2,a0,8
    800049fe:	854a                	mv	a0,s2
    80004a00:	ffffc097          	auipc	ra,0xffffc
    80004a04:	1c2080e7          	jalr	450(ra) # 80000bc2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a08:	409c                	lw	a5,0(s1)
    80004a0a:	ef99                	bnez	a5,80004a28 <holdingsleep+0x3e>
    80004a0c:	4481                	li	s1,0
  release(&lk->lk);
    80004a0e:	854a                	mv	a0,s2
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	266080e7          	jalr	614(ra) # 80000c76 <release>
  return r;
}
    80004a18:	8526                	mv	a0,s1
    80004a1a:	70a2                	ld	ra,40(sp)
    80004a1c:	7402                	ld	s0,32(sp)
    80004a1e:	64e2                	ld	s1,24(sp)
    80004a20:	6942                	ld	s2,16(sp)
    80004a22:	69a2                	ld	s3,8(sp)
    80004a24:	6145                	addi	sp,sp,48
    80004a26:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004a28:	0284a983          	lw	s3,40(s1)
    80004a2c:	ffffd097          	auipc	ra,0xffffd
    80004a30:	f6a080e7          	jalr	-150(ra) # 80001996 <myproc>
    80004a34:	5904                	lw	s1,48(a0)
    80004a36:	413484b3          	sub	s1,s1,s3
    80004a3a:	0014b493          	seqz	s1,s1
    80004a3e:	bfc1                	j	80004a0e <holdingsleep+0x24>

0000000080004a40 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004a40:	1141                	addi	sp,sp,-16
    80004a42:	e406                	sd	ra,8(sp)
    80004a44:	e022                	sd	s0,0(sp)
    80004a46:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004a48:	00004597          	auipc	a1,0x4
    80004a4c:	e3058593          	addi	a1,a1,-464 # 80008878 <syscall_names_table.0+0x250>
    80004a50:	0001d517          	auipc	a0,0x1d
    80004a54:	38050513          	addi	a0,a0,896 # 80021dd0 <ftable>
    80004a58:	ffffc097          	auipc	ra,0xffffc
    80004a5c:	0da080e7          	jalr	218(ra) # 80000b32 <initlock>
}
    80004a60:	60a2                	ld	ra,8(sp)
    80004a62:	6402                	ld	s0,0(sp)
    80004a64:	0141                	addi	sp,sp,16
    80004a66:	8082                	ret

0000000080004a68 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004a68:	1101                	addi	sp,sp,-32
    80004a6a:	ec06                	sd	ra,24(sp)
    80004a6c:	e822                	sd	s0,16(sp)
    80004a6e:	e426                	sd	s1,8(sp)
    80004a70:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004a72:	0001d517          	auipc	a0,0x1d
    80004a76:	35e50513          	addi	a0,a0,862 # 80021dd0 <ftable>
    80004a7a:	ffffc097          	auipc	ra,0xffffc
    80004a7e:	148080e7          	jalr	328(ra) # 80000bc2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a82:	0001d497          	auipc	s1,0x1d
    80004a86:	36648493          	addi	s1,s1,870 # 80021de8 <ftable+0x18>
    80004a8a:	0001e717          	auipc	a4,0x1e
    80004a8e:	2fe70713          	addi	a4,a4,766 # 80022d88 <ftable+0xfb8>
    if(f->ref == 0){
    80004a92:	40dc                	lw	a5,4(s1)
    80004a94:	cf99                	beqz	a5,80004ab2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004a96:	02848493          	addi	s1,s1,40
    80004a9a:	fee49ce3          	bne	s1,a4,80004a92 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004a9e:	0001d517          	auipc	a0,0x1d
    80004aa2:	33250513          	addi	a0,a0,818 # 80021dd0 <ftable>
    80004aa6:	ffffc097          	auipc	ra,0xffffc
    80004aaa:	1d0080e7          	jalr	464(ra) # 80000c76 <release>
  return 0;
    80004aae:	4481                	li	s1,0
    80004ab0:	a819                	j	80004ac6 <filealloc+0x5e>
      f->ref = 1;
    80004ab2:	4785                	li	a5,1
    80004ab4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004ab6:	0001d517          	auipc	a0,0x1d
    80004aba:	31a50513          	addi	a0,a0,794 # 80021dd0 <ftable>
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	1b8080e7          	jalr	440(ra) # 80000c76 <release>
}
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	60e2                	ld	ra,24(sp)
    80004aca:	6442                	ld	s0,16(sp)
    80004acc:	64a2                	ld	s1,8(sp)
    80004ace:	6105                	addi	sp,sp,32
    80004ad0:	8082                	ret

0000000080004ad2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ad2:	1101                	addi	sp,sp,-32
    80004ad4:	ec06                	sd	ra,24(sp)
    80004ad6:	e822                	sd	s0,16(sp)
    80004ad8:	e426                	sd	s1,8(sp)
    80004ada:	1000                	addi	s0,sp,32
    80004adc:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004ade:	0001d517          	auipc	a0,0x1d
    80004ae2:	2f250513          	addi	a0,a0,754 # 80021dd0 <ftable>
    80004ae6:	ffffc097          	auipc	ra,0xffffc
    80004aea:	0dc080e7          	jalr	220(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004aee:	40dc                	lw	a5,4(s1)
    80004af0:	02f05263          	blez	a5,80004b14 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004af4:	2785                	addiw	a5,a5,1
    80004af6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004af8:	0001d517          	auipc	a0,0x1d
    80004afc:	2d850513          	addi	a0,a0,728 # 80021dd0 <ftable>
    80004b00:	ffffc097          	auipc	ra,0xffffc
    80004b04:	176080e7          	jalr	374(ra) # 80000c76 <release>
  return f;
}
    80004b08:	8526                	mv	a0,s1
    80004b0a:	60e2                	ld	ra,24(sp)
    80004b0c:	6442                	ld	s0,16(sp)
    80004b0e:	64a2                	ld	s1,8(sp)
    80004b10:	6105                	addi	sp,sp,32
    80004b12:	8082                	ret
    panic("filedup");
    80004b14:	00004517          	auipc	a0,0x4
    80004b18:	d6c50513          	addi	a0,a0,-660 # 80008880 <syscall_names_table.0+0x258>
    80004b1c:	ffffc097          	auipc	ra,0xffffc
    80004b20:	a0e080e7          	jalr	-1522(ra) # 8000052a <panic>

0000000080004b24 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004b24:	7139                	addi	sp,sp,-64
    80004b26:	fc06                	sd	ra,56(sp)
    80004b28:	f822                	sd	s0,48(sp)
    80004b2a:	f426                	sd	s1,40(sp)
    80004b2c:	f04a                	sd	s2,32(sp)
    80004b2e:	ec4e                	sd	s3,24(sp)
    80004b30:	e852                	sd	s4,16(sp)
    80004b32:	e456                	sd	s5,8(sp)
    80004b34:	0080                	addi	s0,sp,64
    80004b36:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004b38:	0001d517          	auipc	a0,0x1d
    80004b3c:	29850513          	addi	a0,a0,664 # 80021dd0 <ftable>
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	082080e7          	jalr	130(ra) # 80000bc2 <acquire>
  if(f->ref < 1)
    80004b48:	40dc                	lw	a5,4(s1)
    80004b4a:	06f05163          	blez	a5,80004bac <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004b4e:	37fd                	addiw	a5,a5,-1
    80004b50:	0007871b          	sext.w	a4,a5
    80004b54:	c0dc                	sw	a5,4(s1)
    80004b56:	06e04363          	bgtz	a4,80004bbc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004b5a:	0004a903          	lw	s2,0(s1)
    80004b5e:	0094ca83          	lbu	s5,9(s1)
    80004b62:	0104ba03          	ld	s4,16(s1)
    80004b66:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004b6a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004b6e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004b72:	0001d517          	auipc	a0,0x1d
    80004b76:	25e50513          	addi	a0,a0,606 # 80021dd0 <ftable>
    80004b7a:	ffffc097          	auipc	ra,0xffffc
    80004b7e:	0fc080e7          	jalr	252(ra) # 80000c76 <release>

  if(ff.type == FD_PIPE){
    80004b82:	4785                	li	a5,1
    80004b84:	04f90d63          	beq	s2,a5,80004bde <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004b88:	3979                	addiw	s2,s2,-2
    80004b8a:	4785                	li	a5,1
    80004b8c:	0527e063          	bltu	a5,s2,80004bcc <fileclose+0xa8>
    begin_op();
    80004b90:	00000097          	auipc	ra,0x0
    80004b94:	ac8080e7          	jalr	-1336(ra) # 80004658 <begin_op>
    iput(ff.ip);
    80004b98:	854e                	mv	a0,s3
    80004b9a:	fffff097          	auipc	ra,0xfffff
    80004b9e:	2a2080e7          	jalr	674(ra) # 80003e3c <iput>
    end_op();
    80004ba2:	00000097          	auipc	ra,0x0
    80004ba6:	b36080e7          	jalr	-1226(ra) # 800046d8 <end_op>
    80004baa:	a00d                	j	80004bcc <fileclose+0xa8>
    panic("fileclose");
    80004bac:	00004517          	auipc	a0,0x4
    80004bb0:	cdc50513          	addi	a0,a0,-804 # 80008888 <syscall_names_table.0+0x260>
    80004bb4:	ffffc097          	auipc	ra,0xffffc
    80004bb8:	976080e7          	jalr	-1674(ra) # 8000052a <panic>
    release(&ftable.lock);
    80004bbc:	0001d517          	auipc	a0,0x1d
    80004bc0:	21450513          	addi	a0,a0,532 # 80021dd0 <ftable>
    80004bc4:	ffffc097          	auipc	ra,0xffffc
    80004bc8:	0b2080e7          	jalr	178(ra) # 80000c76 <release>
  }
}
    80004bcc:	70e2                	ld	ra,56(sp)
    80004bce:	7442                	ld	s0,48(sp)
    80004bd0:	74a2                	ld	s1,40(sp)
    80004bd2:	7902                	ld	s2,32(sp)
    80004bd4:	69e2                	ld	s3,24(sp)
    80004bd6:	6a42                	ld	s4,16(sp)
    80004bd8:	6aa2                	ld	s5,8(sp)
    80004bda:	6121                	addi	sp,sp,64
    80004bdc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004bde:	85d6                	mv	a1,s5
    80004be0:	8552                	mv	a0,s4
    80004be2:	00000097          	auipc	ra,0x0
    80004be6:	34c080e7          	jalr	844(ra) # 80004f2e <pipeclose>
    80004bea:	b7cd                	j	80004bcc <fileclose+0xa8>

0000000080004bec <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004bec:	715d                	addi	sp,sp,-80
    80004bee:	e486                	sd	ra,72(sp)
    80004bf0:	e0a2                	sd	s0,64(sp)
    80004bf2:	fc26                	sd	s1,56(sp)
    80004bf4:	f84a                	sd	s2,48(sp)
    80004bf6:	f44e                	sd	s3,40(sp)
    80004bf8:	0880                	addi	s0,sp,80
    80004bfa:	84aa                	mv	s1,a0
    80004bfc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004bfe:	ffffd097          	auipc	ra,0xffffd
    80004c02:	d98080e7          	jalr	-616(ra) # 80001996 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004c06:	409c                	lw	a5,0(s1)
    80004c08:	37f9                	addiw	a5,a5,-2
    80004c0a:	4705                	li	a4,1
    80004c0c:	04f76763          	bltu	a4,a5,80004c5a <filestat+0x6e>
    80004c10:	892a                	mv	s2,a0
    ilock(f->ip);
    80004c12:	6c88                	ld	a0,24(s1)
    80004c14:	fffff097          	auipc	ra,0xfffff
    80004c18:	06e080e7          	jalr	110(ra) # 80003c82 <ilock>
    stati(f->ip, &st);
    80004c1c:	fb840593          	addi	a1,s0,-72
    80004c20:	6c88                	ld	a0,24(s1)
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	2ea080e7          	jalr	746(ra) # 80003f0c <stati>
    iunlock(f->ip);
    80004c2a:	6c88                	ld	a0,24(s1)
    80004c2c:	fffff097          	auipc	ra,0xfffff
    80004c30:	118080e7          	jalr	280(ra) # 80003d44 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004c34:	46e1                	li	a3,24
    80004c36:	fb840613          	addi	a2,s0,-72
    80004c3a:	85ce                	mv	a1,s3
    80004c3c:	05893503          	ld	a0,88(s2)
    80004c40:	ffffd097          	auipc	ra,0xffffd
    80004c44:	9fe080e7          	jalr	-1538(ra) # 8000163e <copyout>
    80004c48:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004c4c:	60a6                	ld	ra,72(sp)
    80004c4e:	6406                	ld	s0,64(sp)
    80004c50:	74e2                	ld	s1,56(sp)
    80004c52:	7942                	ld	s2,48(sp)
    80004c54:	79a2                	ld	s3,40(sp)
    80004c56:	6161                	addi	sp,sp,80
    80004c58:	8082                	ret
  return -1;
    80004c5a:	557d                	li	a0,-1
    80004c5c:	bfc5                	j	80004c4c <filestat+0x60>

0000000080004c5e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004c5e:	7179                	addi	sp,sp,-48
    80004c60:	f406                	sd	ra,40(sp)
    80004c62:	f022                	sd	s0,32(sp)
    80004c64:	ec26                	sd	s1,24(sp)
    80004c66:	e84a                	sd	s2,16(sp)
    80004c68:	e44e                	sd	s3,8(sp)
    80004c6a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004c6c:	00854783          	lbu	a5,8(a0)
    80004c70:	c3d5                	beqz	a5,80004d14 <fileread+0xb6>
    80004c72:	84aa                	mv	s1,a0
    80004c74:	89ae                	mv	s3,a1
    80004c76:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c78:	411c                	lw	a5,0(a0)
    80004c7a:	4705                	li	a4,1
    80004c7c:	04e78963          	beq	a5,a4,80004cce <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c80:	470d                	li	a4,3
    80004c82:	04e78d63          	beq	a5,a4,80004cdc <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c86:	4709                	li	a4,2
    80004c88:	06e79e63          	bne	a5,a4,80004d04 <fileread+0xa6>
    ilock(f->ip);
    80004c8c:	6d08                	ld	a0,24(a0)
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	ff4080e7          	jalr	-12(ra) # 80003c82 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004c96:	874a                	mv	a4,s2
    80004c98:	5094                	lw	a3,32(s1)
    80004c9a:	864e                	mv	a2,s3
    80004c9c:	4585                	li	a1,1
    80004c9e:	6c88                	ld	a0,24(s1)
    80004ca0:	fffff097          	auipc	ra,0xfffff
    80004ca4:	296080e7          	jalr	662(ra) # 80003f36 <readi>
    80004ca8:	892a                	mv	s2,a0
    80004caa:	00a05563          	blez	a0,80004cb4 <fileread+0x56>
      f->off += r;
    80004cae:	509c                	lw	a5,32(s1)
    80004cb0:	9fa9                	addw	a5,a5,a0
    80004cb2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004cb4:	6c88                	ld	a0,24(s1)
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	08e080e7          	jalr	142(ra) # 80003d44 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004cbe:	854a                	mv	a0,s2
    80004cc0:	70a2                	ld	ra,40(sp)
    80004cc2:	7402                	ld	s0,32(sp)
    80004cc4:	64e2                	ld	s1,24(sp)
    80004cc6:	6942                	ld	s2,16(sp)
    80004cc8:	69a2                	ld	s3,8(sp)
    80004cca:	6145                	addi	sp,sp,48
    80004ccc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004cce:	6908                	ld	a0,16(a0)
    80004cd0:	00000097          	auipc	ra,0x0
    80004cd4:	3c0080e7          	jalr	960(ra) # 80005090 <piperead>
    80004cd8:	892a                	mv	s2,a0
    80004cda:	b7d5                	j	80004cbe <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004cdc:	02451783          	lh	a5,36(a0)
    80004ce0:	03079693          	slli	a3,a5,0x30
    80004ce4:	92c1                	srli	a3,a3,0x30
    80004ce6:	4725                	li	a4,9
    80004ce8:	02d76863          	bltu	a4,a3,80004d18 <fileread+0xba>
    80004cec:	0792                	slli	a5,a5,0x4
    80004cee:	0001d717          	auipc	a4,0x1d
    80004cf2:	04270713          	addi	a4,a4,66 # 80021d30 <devsw>
    80004cf6:	97ba                	add	a5,a5,a4
    80004cf8:	639c                	ld	a5,0(a5)
    80004cfa:	c38d                	beqz	a5,80004d1c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004cfc:	4505                	li	a0,1
    80004cfe:	9782                	jalr	a5
    80004d00:	892a                	mv	s2,a0
    80004d02:	bf75                	j	80004cbe <fileread+0x60>
    panic("fileread");
    80004d04:	00004517          	auipc	a0,0x4
    80004d08:	b9450513          	addi	a0,a0,-1132 # 80008898 <syscall_names_table.0+0x270>
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	81e080e7          	jalr	-2018(ra) # 8000052a <panic>
    return -1;
    80004d14:	597d                	li	s2,-1
    80004d16:	b765                	j	80004cbe <fileread+0x60>
      return -1;
    80004d18:	597d                	li	s2,-1
    80004d1a:	b755                	j	80004cbe <fileread+0x60>
    80004d1c:	597d                	li	s2,-1
    80004d1e:	b745                	j	80004cbe <fileread+0x60>

0000000080004d20 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004d20:	715d                	addi	sp,sp,-80
    80004d22:	e486                	sd	ra,72(sp)
    80004d24:	e0a2                	sd	s0,64(sp)
    80004d26:	fc26                	sd	s1,56(sp)
    80004d28:	f84a                	sd	s2,48(sp)
    80004d2a:	f44e                	sd	s3,40(sp)
    80004d2c:	f052                	sd	s4,32(sp)
    80004d2e:	ec56                	sd	s5,24(sp)
    80004d30:	e85a                	sd	s6,16(sp)
    80004d32:	e45e                	sd	s7,8(sp)
    80004d34:	e062                	sd	s8,0(sp)
    80004d36:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004d38:	00954783          	lbu	a5,9(a0)
    80004d3c:	10078663          	beqz	a5,80004e48 <filewrite+0x128>
    80004d40:	892a                	mv	s2,a0
    80004d42:	8aae                	mv	s5,a1
    80004d44:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004d46:	411c                	lw	a5,0(a0)
    80004d48:	4705                	li	a4,1
    80004d4a:	02e78263          	beq	a5,a4,80004d6e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004d4e:	470d                	li	a4,3
    80004d50:	02e78663          	beq	a5,a4,80004d7c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004d54:	4709                	li	a4,2
    80004d56:	0ee79163          	bne	a5,a4,80004e38 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004d5a:	0ac05d63          	blez	a2,80004e14 <filewrite+0xf4>
    int i = 0;
    80004d5e:	4981                	li	s3,0
    80004d60:	6b05                	lui	s6,0x1
    80004d62:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004d66:	6b85                	lui	s7,0x1
    80004d68:	c00b8b9b          	addiw	s7,s7,-1024
    80004d6c:	a861                	j	80004e04 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004d6e:	6908                	ld	a0,16(a0)
    80004d70:	00000097          	auipc	ra,0x0
    80004d74:	22e080e7          	jalr	558(ra) # 80004f9e <pipewrite>
    80004d78:	8a2a                	mv	s4,a0
    80004d7a:	a045                	j	80004e1a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004d7c:	02451783          	lh	a5,36(a0)
    80004d80:	03079693          	slli	a3,a5,0x30
    80004d84:	92c1                	srli	a3,a3,0x30
    80004d86:	4725                	li	a4,9
    80004d88:	0cd76263          	bltu	a4,a3,80004e4c <filewrite+0x12c>
    80004d8c:	0792                	slli	a5,a5,0x4
    80004d8e:	0001d717          	auipc	a4,0x1d
    80004d92:	fa270713          	addi	a4,a4,-94 # 80021d30 <devsw>
    80004d96:	97ba                	add	a5,a5,a4
    80004d98:	679c                	ld	a5,8(a5)
    80004d9a:	cbdd                	beqz	a5,80004e50 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004d9c:	4505                	li	a0,1
    80004d9e:	9782                	jalr	a5
    80004da0:	8a2a                	mv	s4,a0
    80004da2:	a8a5                	j	80004e1a <filewrite+0xfa>
    80004da4:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004da8:	00000097          	auipc	ra,0x0
    80004dac:	8b0080e7          	jalr	-1872(ra) # 80004658 <begin_op>
      ilock(f->ip);
    80004db0:	01893503          	ld	a0,24(s2)
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	ece080e7          	jalr	-306(ra) # 80003c82 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004dbc:	8762                	mv	a4,s8
    80004dbe:	02092683          	lw	a3,32(s2)
    80004dc2:	01598633          	add	a2,s3,s5
    80004dc6:	4585                	li	a1,1
    80004dc8:	01893503          	ld	a0,24(s2)
    80004dcc:	fffff097          	auipc	ra,0xfffff
    80004dd0:	262080e7          	jalr	610(ra) # 8000402e <writei>
    80004dd4:	84aa                	mv	s1,a0
    80004dd6:	00a05763          	blez	a0,80004de4 <filewrite+0xc4>
        f->off += r;
    80004dda:	02092783          	lw	a5,32(s2)
    80004dde:	9fa9                	addw	a5,a5,a0
    80004de0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004de4:	01893503          	ld	a0,24(s2)
    80004de8:	fffff097          	auipc	ra,0xfffff
    80004dec:	f5c080e7          	jalr	-164(ra) # 80003d44 <iunlock>
      end_op();
    80004df0:	00000097          	auipc	ra,0x0
    80004df4:	8e8080e7          	jalr	-1816(ra) # 800046d8 <end_op>

      if(r != n1){
    80004df8:	009c1f63          	bne	s8,s1,80004e16 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004dfc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004e00:	0149db63          	bge	s3,s4,80004e16 <filewrite+0xf6>
      int n1 = n - i;
    80004e04:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004e08:	84be                	mv	s1,a5
    80004e0a:	2781                	sext.w	a5,a5
    80004e0c:	f8fb5ce3          	bge	s6,a5,80004da4 <filewrite+0x84>
    80004e10:	84de                	mv	s1,s7
    80004e12:	bf49                	j	80004da4 <filewrite+0x84>
    int i = 0;
    80004e14:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004e16:	013a1f63          	bne	s4,s3,80004e34 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004e1a:	8552                	mv	a0,s4
    80004e1c:	60a6                	ld	ra,72(sp)
    80004e1e:	6406                	ld	s0,64(sp)
    80004e20:	74e2                	ld	s1,56(sp)
    80004e22:	7942                	ld	s2,48(sp)
    80004e24:	79a2                	ld	s3,40(sp)
    80004e26:	7a02                	ld	s4,32(sp)
    80004e28:	6ae2                	ld	s5,24(sp)
    80004e2a:	6b42                	ld	s6,16(sp)
    80004e2c:	6ba2                	ld	s7,8(sp)
    80004e2e:	6c02                	ld	s8,0(sp)
    80004e30:	6161                	addi	sp,sp,80
    80004e32:	8082                	ret
    ret = (i == n ? n : -1);
    80004e34:	5a7d                	li	s4,-1
    80004e36:	b7d5                	j	80004e1a <filewrite+0xfa>
    panic("filewrite");
    80004e38:	00004517          	auipc	a0,0x4
    80004e3c:	a7050513          	addi	a0,a0,-1424 # 800088a8 <syscall_names_table.0+0x280>
    80004e40:	ffffb097          	auipc	ra,0xffffb
    80004e44:	6ea080e7          	jalr	1770(ra) # 8000052a <panic>
    return -1;
    80004e48:	5a7d                	li	s4,-1
    80004e4a:	bfc1                	j	80004e1a <filewrite+0xfa>
      return -1;
    80004e4c:	5a7d                	li	s4,-1
    80004e4e:	b7f1                	j	80004e1a <filewrite+0xfa>
    80004e50:	5a7d                	li	s4,-1
    80004e52:	b7e1                	j	80004e1a <filewrite+0xfa>

0000000080004e54 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004e54:	7179                	addi	sp,sp,-48
    80004e56:	f406                	sd	ra,40(sp)
    80004e58:	f022                	sd	s0,32(sp)
    80004e5a:	ec26                	sd	s1,24(sp)
    80004e5c:	e84a                	sd	s2,16(sp)
    80004e5e:	e44e                	sd	s3,8(sp)
    80004e60:	e052                	sd	s4,0(sp)
    80004e62:	1800                	addi	s0,sp,48
    80004e64:	84aa                	mv	s1,a0
    80004e66:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004e68:	0005b023          	sd	zero,0(a1)
    80004e6c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004e70:	00000097          	auipc	ra,0x0
    80004e74:	bf8080e7          	jalr	-1032(ra) # 80004a68 <filealloc>
    80004e78:	e088                	sd	a0,0(s1)
    80004e7a:	c551                	beqz	a0,80004f06 <pipealloc+0xb2>
    80004e7c:	00000097          	auipc	ra,0x0
    80004e80:	bec080e7          	jalr	-1044(ra) # 80004a68 <filealloc>
    80004e84:	00aa3023          	sd	a0,0(s4)
    80004e88:	c92d                	beqz	a0,80004efa <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004e8a:	ffffc097          	auipc	ra,0xffffc
    80004e8e:	c48080e7          	jalr	-952(ra) # 80000ad2 <kalloc>
    80004e92:	892a                	mv	s2,a0
    80004e94:	c125                	beqz	a0,80004ef4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004e96:	4985                	li	s3,1
    80004e98:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004e9c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ea0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ea4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ea8:	00003597          	auipc	a1,0x3
    80004eac:	5f058593          	addi	a1,a1,1520 # 80008498 <states.0+0x1e0>
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	c82080e7          	jalr	-894(ra) # 80000b32 <initlock>
  (*f0)->type = FD_PIPE;
    80004eb8:	609c                	ld	a5,0(s1)
    80004eba:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ebe:	609c                	ld	a5,0(s1)
    80004ec0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ec4:	609c                	ld	a5,0(s1)
    80004ec6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004eca:	609c                	ld	a5,0(s1)
    80004ecc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ed0:	000a3783          	ld	a5,0(s4)
    80004ed4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004ed8:	000a3783          	ld	a5,0(s4)
    80004edc:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004ee0:	000a3783          	ld	a5,0(s4)
    80004ee4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004ee8:	000a3783          	ld	a5,0(s4)
    80004eec:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ef0:	4501                	li	a0,0
    80004ef2:	a025                	j	80004f1a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ef4:	6088                	ld	a0,0(s1)
    80004ef6:	e501                	bnez	a0,80004efe <pipealloc+0xaa>
    80004ef8:	a039                	j	80004f06 <pipealloc+0xb2>
    80004efa:	6088                	ld	a0,0(s1)
    80004efc:	c51d                	beqz	a0,80004f2a <pipealloc+0xd6>
    fileclose(*f0);
    80004efe:	00000097          	auipc	ra,0x0
    80004f02:	c26080e7          	jalr	-986(ra) # 80004b24 <fileclose>
  if(*f1)
    80004f06:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004f0a:	557d                	li	a0,-1
  if(*f1)
    80004f0c:	c799                	beqz	a5,80004f1a <pipealloc+0xc6>
    fileclose(*f1);
    80004f0e:	853e                	mv	a0,a5
    80004f10:	00000097          	auipc	ra,0x0
    80004f14:	c14080e7          	jalr	-1004(ra) # 80004b24 <fileclose>
  return -1;
    80004f18:	557d                	li	a0,-1
}
    80004f1a:	70a2                	ld	ra,40(sp)
    80004f1c:	7402                	ld	s0,32(sp)
    80004f1e:	64e2                	ld	s1,24(sp)
    80004f20:	6942                	ld	s2,16(sp)
    80004f22:	69a2                	ld	s3,8(sp)
    80004f24:	6a02                	ld	s4,0(sp)
    80004f26:	6145                	addi	sp,sp,48
    80004f28:	8082                	ret
  return -1;
    80004f2a:	557d                	li	a0,-1
    80004f2c:	b7fd                	j	80004f1a <pipealloc+0xc6>

0000000080004f2e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004f2e:	1101                	addi	sp,sp,-32
    80004f30:	ec06                	sd	ra,24(sp)
    80004f32:	e822                	sd	s0,16(sp)
    80004f34:	e426                	sd	s1,8(sp)
    80004f36:	e04a                	sd	s2,0(sp)
    80004f38:	1000                	addi	s0,sp,32
    80004f3a:	84aa                	mv	s1,a0
    80004f3c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	c84080e7          	jalr	-892(ra) # 80000bc2 <acquire>
  if(writable){
    80004f46:	02090d63          	beqz	s2,80004f80 <pipeclose+0x52>
    pi->writeopen = 0;
    80004f4a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004f4e:	21848513          	addi	a0,s1,536
    80004f52:	ffffd097          	auipc	ra,0xffffd
    80004f56:	488080e7          	jalr	1160(ra) # 800023da <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004f5a:	2204b783          	ld	a5,544(s1)
    80004f5e:	eb95                	bnez	a5,80004f92 <pipeclose+0x64>
    release(&pi->lock);
    80004f60:	8526                	mv	a0,s1
    80004f62:	ffffc097          	auipc	ra,0xffffc
    80004f66:	d14080e7          	jalr	-748(ra) # 80000c76 <release>
    kfree((char*)pi);
    80004f6a:	8526                	mv	a0,s1
    80004f6c:	ffffc097          	auipc	ra,0xffffc
    80004f70:	a6a080e7          	jalr	-1430(ra) # 800009d6 <kfree>
  } else
    release(&pi->lock);
}
    80004f74:	60e2                	ld	ra,24(sp)
    80004f76:	6442                	ld	s0,16(sp)
    80004f78:	64a2                	ld	s1,8(sp)
    80004f7a:	6902                	ld	s2,0(sp)
    80004f7c:	6105                	addi	sp,sp,32
    80004f7e:	8082                	ret
    pi->readopen = 0;
    80004f80:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004f84:	21c48513          	addi	a0,s1,540
    80004f88:	ffffd097          	auipc	ra,0xffffd
    80004f8c:	452080e7          	jalr	1106(ra) # 800023da <wakeup>
    80004f90:	b7e9                	j	80004f5a <pipeclose+0x2c>
    release(&pi->lock);
    80004f92:	8526                	mv	a0,s1
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	ce2080e7          	jalr	-798(ra) # 80000c76 <release>
}
    80004f9c:	bfe1                	j	80004f74 <pipeclose+0x46>

0000000080004f9e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004f9e:	711d                	addi	sp,sp,-96
    80004fa0:	ec86                	sd	ra,88(sp)
    80004fa2:	e8a2                	sd	s0,80(sp)
    80004fa4:	e4a6                	sd	s1,72(sp)
    80004fa6:	e0ca                	sd	s2,64(sp)
    80004fa8:	fc4e                	sd	s3,56(sp)
    80004faa:	f852                	sd	s4,48(sp)
    80004fac:	f456                	sd	s5,40(sp)
    80004fae:	f05a                	sd	s6,32(sp)
    80004fb0:	ec5e                	sd	s7,24(sp)
    80004fb2:	e862                	sd	s8,16(sp)
    80004fb4:	1080                	addi	s0,sp,96
    80004fb6:	84aa                	mv	s1,a0
    80004fb8:	8aae                	mv	s5,a1
    80004fba:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004fbc:	ffffd097          	auipc	ra,0xffffd
    80004fc0:	9da080e7          	jalr	-1574(ra) # 80001996 <myproc>
    80004fc4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004fc6:	8526                	mv	a0,s1
    80004fc8:	ffffc097          	auipc	ra,0xffffc
    80004fcc:	bfa080e7          	jalr	-1030(ra) # 80000bc2 <acquire>
  while(i < n){
    80004fd0:	0b405363          	blez	s4,80005076 <pipewrite+0xd8>
  int i = 0;
    80004fd4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004fd6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004fd8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004fdc:	21c48b93          	addi	s7,s1,540
    80004fe0:	a089                	j	80005022 <pipewrite+0x84>
      release(&pi->lock);
    80004fe2:	8526                	mv	a0,s1
    80004fe4:	ffffc097          	auipc	ra,0xffffc
    80004fe8:	c92080e7          	jalr	-878(ra) # 80000c76 <release>
      return -1;
    80004fec:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004fee:	854a                	mv	a0,s2
    80004ff0:	60e6                	ld	ra,88(sp)
    80004ff2:	6446                	ld	s0,80(sp)
    80004ff4:	64a6                	ld	s1,72(sp)
    80004ff6:	6906                	ld	s2,64(sp)
    80004ff8:	79e2                	ld	s3,56(sp)
    80004ffa:	7a42                	ld	s4,48(sp)
    80004ffc:	7aa2                	ld	s5,40(sp)
    80004ffe:	7b02                	ld	s6,32(sp)
    80005000:	6be2                	ld	s7,24(sp)
    80005002:	6c42                	ld	s8,16(sp)
    80005004:	6125                	addi	sp,sp,96
    80005006:	8082                	ret
      wakeup(&pi->nread);
    80005008:	8562                	mv	a0,s8
    8000500a:	ffffd097          	auipc	ra,0xffffd
    8000500e:	3d0080e7          	jalr	976(ra) # 800023da <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005012:	85a6                	mv	a1,s1
    80005014:	855e                	mv	a0,s7
    80005016:	ffffd097          	auipc	ra,0xffffd
    8000501a:	238080e7          	jalr	568(ra) # 8000224e <sleep>
  while(i < n){
    8000501e:	05495d63          	bge	s2,s4,80005078 <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80005022:	2204a783          	lw	a5,544(s1)
    80005026:	dfd5                	beqz	a5,80004fe2 <pipewrite+0x44>
    80005028:	0289a783          	lw	a5,40(s3)
    8000502c:	fbdd                	bnez	a5,80004fe2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000502e:	2184a783          	lw	a5,536(s1)
    80005032:	21c4a703          	lw	a4,540(s1)
    80005036:	2007879b          	addiw	a5,a5,512
    8000503a:	fcf707e3          	beq	a4,a5,80005008 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000503e:	4685                	li	a3,1
    80005040:	01590633          	add	a2,s2,s5
    80005044:	faf40593          	addi	a1,s0,-81
    80005048:	0589b503          	ld	a0,88(s3)
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	67e080e7          	jalr	1662(ra) # 800016ca <copyin>
    80005054:	03650263          	beq	a0,s6,80005078 <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005058:	21c4a783          	lw	a5,540(s1)
    8000505c:	0017871b          	addiw	a4,a5,1
    80005060:	20e4ae23          	sw	a4,540(s1)
    80005064:	1ff7f793          	andi	a5,a5,511
    80005068:	97a6                	add	a5,a5,s1
    8000506a:	faf44703          	lbu	a4,-81(s0)
    8000506e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005072:	2905                	addiw	s2,s2,1
    80005074:	b76d                	j	8000501e <pipewrite+0x80>
  int i = 0;
    80005076:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005078:	21848513          	addi	a0,s1,536
    8000507c:	ffffd097          	auipc	ra,0xffffd
    80005080:	35e080e7          	jalr	862(ra) # 800023da <wakeup>
  release(&pi->lock);
    80005084:	8526                	mv	a0,s1
    80005086:	ffffc097          	auipc	ra,0xffffc
    8000508a:	bf0080e7          	jalr	-1040(ra) # 80000c76 <release>
  return i;
    8000508e:	b785                	j	80004fee <pipewrite+0x50>

0000000080005090 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005090:	715d                	addi	sp,sp,-80
    80005092:	e486                	sd	ra,72(sp)
    80005094:	e0a2                	sd	s0,64(sp)
    80005096:	fc26                	sd	s1,56(sp)
    80005098:	f84a                	sd	s2,48(sp)
    8000509a:	f44e                	sd	s3,40(sp)
    8000509c:	f052                	sd	s4,32(sp)
    8000509e:	ec56                	sd	s5,24(sp)
    800050a0:	e85a                	sd	s6,16(sp)
    800050a2:	0880                	addi	s0,sp,80
    800050a4:	84aa                	mv	s1,a0
    800050a6:	892e                	mv	s2,a1
    800050a8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800050aa:	ffffd097          	auipc	ra,0xffffd
    800050ae:	8ec080e7          	jalr	-1812(ra) # 80001996 <myproc>
    800050b2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800050b4:	8526                	mv	a0,s1
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	b0c080e7          	jalr	-1268(ra) # 80000bc2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050be:	2184a703          	lw	a4,536(s1)
    800050c2:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050c6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050ca:	02f71463          	bne	a4,a5,800050f2 <piperead+0x62>
    800050ce:	2244a783          	lw	a5,548(s1)
    800050d2:	c385                	beqz	a5,800050f2 <piperead+0x62>
    if(pr->killed){
    800050d4:	028a2783          	lw	a5,40(s4)
    800050d8:	ebc1                	bnez	a5,80005168 <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800050da:	85a6                	mv	a1,s1
    800050dc:	854e                	mv	a0,s3
    800050de:	ffffd097          	auipc	ra,0xffffd
    800050e2:	170080e7          	jalr	368(ra) # 8000224e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800050e6:	2184a703          	lw	a4,536(s1)
    800050ea:	21c4a783          	lw	a5,540(s1)
    800050ee:	fef700e3          	beq	a4,a5,800050ce <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050f2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800050f4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800050f6:	05505363          	blez	s5,8000513c <piperead+0xac>
    if(pi->nread == pi->nwrite)
    800050fa:	2184a783          	lw	a5,536(s1)
    800050fe:	21c4a703          	lw	a4,540(s1)
    80005102:	02f70d63          	beq	a4,a5,8000513c <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005106:	0017871b          	addiw	a4,a5,1
    8000510a:	20e4ac23          	sw	a4,536(s1)
    8000510e:	1ff7f793          	andi	a5,a5,511
    80005112:	97a6                	add	a5,a5,s1
    80005114:	0187c783          	lbu	a5,24(a5)
    80005118:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000511c:	4685                	li	a3,1
    8000511e:	fbf40613          	addi	a2,s0,-65
    80005122:	85ca                	mv	a1,s2
    80005124:	058a3503          	ld	a0,88(s4)
    80005128:	ffffc097          	auipc	ra,0xffffc
    8000512c:	516080e7          	jalr	1302(ra) # 8000163e <copyout>
    80005130:	01650663          	beq	a0,s6,8000513c <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005134:	2985                	addiw	s3,s3,1
    80005136:	0905                	addi	s2,s2,1
    80005138:	fd3a91e3          	bne	s5,s3,800050fa <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000513c:	21c48513          	addi	a0,s1,540
    80005140:	ffffd097          	auipc	ra,0xffffd
    80005144:	29a080e7          	jalr	666(ra) # 800023da <wakeup>
  release(&pi->lock);
    80005148:	8526                	mv	a0,s1
    8000514a:	ffffc097          	auipc	ra,0xffffc
    8000514e:	b2c080e7          	jalr	-1236(ra) # 80000c76 <release>
  return i;
}
    80005152:	854e                	mv	a0,s3
    80005154:	60a6                	ld	ra,72(sp)
    80005156:	6406                	ld	s0,64(sp)
    80005158:	74e2                	ld	s1,56(sp)
    8000515a:	7942                	ld	s2,48(sp)
    8000515c:	79a2                	ld	s3,40(sp)
    8000515e:	7a02                	ld	s4,32(sp)
    80005160:	6ae2                	ld	s5,24(sp)
    80005162:	6b42                	ld	s6,16(sp)
    80005164:	6161                	addi	sp,sp,80
    80005166:	8082                	ret
      release(&pi->lock);
    80005168:	8526                	mv	a0,s1
    8000516a:	ffffc097          	auipc	ra,0xffffc
    8000516e:	b0c080e7          	jalr	-1268(ra) # 80000c76 <release>
      return -1;
    80005172:	59fd                	li	s3,-1
    80005174:	bff9                	j	80005152 <piperead+0xc2>

0000000080005176 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005176:	de010113          	addi	sp,sp,-544
    8000517a:	20113c23          	sd	ra,536(sp)
    8000517e:	20813823          	sd	s0,528(sp)
    80005182:	20913423          	sd	s1,520(sp)
    80005186:	21213023          	sd	s2,512(sp)
    8000518a:	ffce                	sd	s3,504(sp)
    8000518c:	fbd2                	sd	s4,496(sp)
    8000518e:	f7d6                	sd	s5,488(sp)
    80005190:	f3da                	sd	s6,480(sp)
    80005192:	efde                	sd	s7,472(sp)
    80005194:	ebe2                	sd	s8,464(sp)
    80005196:	e7e6                	sd	s9,456(sp)
    80005198:	e3ea                	sd	s10,448(sp)
    8000519a:	ff6e                	sd	s11,440(sp)
    8000519c:	1400                	addi	s0,sp,544
    8000519e:	892a                	mv	s2,a0
    800051a0:	dea43423          	sd	a0,-536(s0)
    800051a4:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800051a8:	ffffc097          	auipc	ra,0xffffc
    800051ac:	7ee080e7          	jalr	2030(ra) # 80001996 <myproc>
    800051b0:	84aa                	mv	s1,a0

  begin_op();
    800051b2:	fffff097          	auipc	ra,0xfffff
    800051b6:	4a6080e7          	jalr	1190(ra) # 80004658 <begin_op>

  if((ip = namei(path)) == 0){
    800051ba:	854a                	mv	a0,s2
    800051bc:	fffff097          	auipc	ra,0xfffff
    800051c0:	27c080e7          	jalr	636(ra) # 80004438 <namei>
    800051c4:	c93d                	beqz	a0,8000523a <exec+0xc4>
    800051c6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800051c8:	fffff097          	auipc	ra,0xfffff
    800051cc:	aba080e7          	jalr	-1350(ra) # 80003c82 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800051d0:	04000713          	li	a4,64
    800051d4:	4681                	li	a3,0
    800051d6:	e4840613          	addi	a2,s0,-440
    800051da:	4581                	li	a1,0
    800051dc:	8556                	mv	a0,s5
    800051de:	fffff097          	auipc	ra,0xfffff
    800051e2:	d58080e7          	jalr	-680(ra) # 80003f36 <readi>
    800051e6:	04000793          	li	a5,64
    800051ea:	00f51a63          	bne	a0,a5,800051fe <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800051ee:	e4842703          	lw	a4,-440(s0)
    800051f2:	464c47b7          	lui	a5,0x464c4
    800051f6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800051fa:	04f70663          	beq	a4,a5,80005246 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800051fe:	8556                	mv	a0,s5
    80005200:	fffff097          	auipc	ra,0xfffff
    80005204:	ce4080e7          	jalr	-796(ra) # 80003ee4 <iunlockput>
    end_op();
    80005208:	fffff097          	auipc	ra,0xfffff
    8000520c:	4d0080e7          	jalr	1232(ra) # 800046d8 <end_op>
  }
  return -1;
    80005210:	557d                	li	a0,-1
}
    80005212:	21813083          	ld	ra,536(sp)
    80005216:	21013403          	ld	s0,528(sp)
    8000521a:	20813483          	ld	s1,520(sp)
    8000521e:	20013903          	ld	s2,512(sp)
    80005222:	79fe                	ld	s3,504(sp)
    80005224:	7a5e                	ld	s4,496(sp)
    80005226:	7abe                	ld	s5,488(sp)
    80005228:	7b1e                	ld	s6,480(sp)
    8000522a:	6bfe                	ld	s7,472(sp)
    8000522c:	6c5e                	ld	s8,464(sp)
    8000522e:	6cbe                	ld	s9,456(sp)
    80005230:	6d1e                	ld	s10,448(sp)
    80005232:	7dfa                	ld	s11,440(sp)
    80005234:	22010113          	addi	sp,sp,544
    80005238:	8082                	ret
    end_op();
    8000523a:	fffff097          	auipc	ra,0xfffff
    8000523e:	49e080e7          	jalr	1182(ra) # 800046d8 <end_op>
    return -1;
    80005242:	557d                	li	a0,-1
    80005244:	b7f9                	j	80005212 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005246:	8526                	mv	a0,s1
    80005248:	ffffd097          	auipc	ra,0xffffd
    8000524c:	858080e7          	jalr	-1960(ra) # 80001aa0 <proc_pagetable>
    80005250:	8b2a                	mv	s6,a0
    80005252:	d555                	beqz	a0,800051fe <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005254:	e6842783          	lw	a5,-408(s0)
    80005258:	e8045703          	lhu	a4,-384(s0)
    8000525c:	c735                	beqz	a4,800052c8 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000525e:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005260:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005264:	6a05                	lui	s4,0x1
    80005266:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000526a:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    8000526e:	6d85                	lui	s11,0x1
    80005270:	7d7d                	lui	s10,0xfffff
    80005272:	ac1d                	j	800054a8 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005274:	00003517          	auipc	a0,0x3
    80005278:	64450513          	addi	a0,a0,1604 # 800088b8 <syscall_names_table.0+0x290>
    8000527c:	ffffb097          	auipc	ra,0xffffb
    80005280:	2ae080e7          	jalr	686(ra) # 8000052a <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005284:	874a                	mv	a4,s2
    80005286:	009c86bb          	addw	a3,s9,s1
    8000528a:	4581                	li	a1,0
    8000528c:	8556                	mv	a0,s5
    8000528e:	fffff097          	auipc	ra,0xfffff
    80005292:	ca8080e7          	jalr	-856(ra) # 80003f36 <readi>
    80005296:	2501                	sext.w	a0,a0
    80005298:	1aa91863          	bne	s2,a0,80005448 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    8000529c:	009d84bb          	addw	s1,s11,s1
    800052a0:	013d09bb          	addw	s3,s10,s3
    800052a4:	1f74f263          	bgeu	s1,s7,80005488 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    800052a8:	02049593          	slli	a1,s1,0x20
    800052ac:	9181                	srli	a1,a1,0x20
    800052ae:	95e2                	add	a1,a1,s8
    800052b0:	855a                	mv	a0,s6
    800052b2:	ffffc097          	auipc	ra,0xffffc
    800052b6:	d9a080e7          	jalr	-614(ra) # 8000104c <walkaddr>
    800052ba:	862a                	mv	a2,a0
    if(pa == 0)
    800052bc:	dd45                	beqz	a0,80005274 <exec+0xfe>
      n = PGSIZE;
    800052be:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800052c0:	fd49f2e3          	bgeu	s3,s4,80005284 <exec+0x10e>
      n = sz - i;
    800052c4:	894e                	mv	s2,s3
    800052c6:	bf7d                	j	80005284 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800052c8:	4481                	li	s1,0
  iunlockput(ip);
    800052ca:	8556                	mv	a0,s5
    800052cc:	fffff097          	auipc	ra,0xfffff
    800052d0:	c18080e7          	jalr	-1000(ra) # 80003ee4 <iunlockput>
  end_op();
    800052d4:	fffff097          	auipc	ra,0xfffff
    800052d8:	404080e7          	jalr	1028(ra) # 800046d8 <end_op>
  p = myproc();
    800052dc:	ffffc097          	auipc	ra,0xffffc
    800052e0:	6ba080e7          	jalr	1722(ra) # 80001996 <myproc>
    800052e4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800052e6:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800052ea:	6785                	lui	a5,0x1
    800052ec:	17fd                	addi	a5,a5,-1
    800052ee:	94be                	add	s1,s1,a5
    800052f0:	77fd                	lui	a5,0xfffff
    800052f2:	8fe5                	and	a5,a5,s1
    800052f4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800052f8:	6609                	lui	a2,0x2
    800052fa:	963e                	add	a2,a2,a5
    800052fc:	85be                	mv	a1,a5
    800052fe:	855a                	mv	a0,s6
    80005300:	ffffc097          	auipc	ra,0xffffc
    80005304:	0ee080e7          	jalr	238(ra) # 800013ee <uvmalloc>
    80005308:	8c2a                	mv	s8,a0
  ip = 0;
    8000530a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000530c:	12050e63          	beqz	a0,80005448 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005310:	75f9                	lui	a1,0xffffe
    80005312:	95aa                	add	a1,a1,a0
    80005314:	855a                	mv	a0,s6
    80005316:	ffffc097          	auipc	ra,0xffffc
    8000531a:	2f6080e7          	jalr	758(ra) # 8000160c <uvmclear>
  stackbase = sp - PGSIZE;
    8000531e:	7afd                	lui	s5,0xfffff
    80005320:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005322:	df043783          	ld	a5,-528(s0)
    80005326:	6388                	ld	a0,0(a5)
    80005328:	c925                	beqz	a0,80005398 <exec+0x222>
    8000532a:	e8840993          	addi	s3,s0,-376
    8000532e:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005332:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005334:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005336:	ffffc097          	auipc	ra,0xffffc
    8000533a:	b0c080e7          	jalr	-1268(ra) # 80000e42 <strlen>
    8000533e:	0015079b          	addiw	a5,a0,1
    80005342:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005346:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000534a:	13596363          	bltu	s2,s5,80005470 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000534e:	df043d83          	ld	s11,-528(s0)
    80005352:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005356:	8552                	mv	a0,s4
    80005358:	ffffc097          	auipc	ra,0xffffc
    8000535c:	aea080e7          	jalr	-1302(ra) # 80000e42 <strlen>
    80005360:	0015069b          	addiw	a3,a0,1
    80005364:	8652                	mv	a2,s4
    80005366:	85ca                	mv	a1,s2
    80005368:	855a                	mv	a0,s6
    8000536a:	ffffc097          	auipc	ra,0xffffc
    8000536e:	2d4080e7          	jalr	724(ra) # 8000163e <copyout>
    80005372:	10054363          	bltz	a0,80005478 <exec+0x302>
    ustack[argc] = sp;
    80005376:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000537a:	0485                	addi	s1,s1,1
    8000537c:	008d8793          	addi	a5,s11,8
    80005380:	def43823          	sd	a5,-528(s0)
    80005384:	008db503          	ld	a0,8(s11)
    80005388:	c911                	beqz	a0,8000539c <exec+0x226>
    if(argc >= MAXARG)
    8000538a:	09a1                	addi	s3,s3,8
    8000538c:	fb3c95e3          	bne	s9,s3,80005336 <exec+0x1c0>
  sz = sz1;
    80005390:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005394:	4a81                	li	s5,0
    80005396:	a84d                	j	80005448 <exec+0x2d2>
  sp = sz;
    80005398:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000539a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000539c:	00349793          	slli	a5,s1,0x3
    800053a0:	f9040713          	addi	a4,s0,-112
    800053a4:	97ba                	add	a5,a5,a4
    800053a6:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    800053aa:	00148693          	addi	a3,s1,1
    800053ae:	068e                	slli	a3,a3,0x3
    800053b0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800053b4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800053b8:	01597663          	bgeu	s2,s5,800053c4 <exec+0x24e>
  sz = sz1;
    800053bc:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053c0:	4a81                	li	s5,0
    800053c2:	a059                	j	80005448 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800053c4:	e8840613          	addi	a2,s0,-376
    800053c8:	85ca                	mv	a1,s2
    800053ca:	855a                	mv	a0,s6
    800053cc:	ffffc097          	auipc	ra,0xffffc
    800053d0:	272080e7          	jalr	626(ra) # 8000163e <copyout>
    800053d4:	0a054663          	bltz	a0,80005480 <exec+0x30a>
  p->trapframe->a1 = sp;
    800053d8:	060bb783          	ld	a5,96(s7) # 1060 <_entry-0x7fffefa0>
    800053dc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800053e0:	de843783          	ld	a5,-536(s0)
    800053e4:	0007c703          	lbu	a4,0(a5)
    800053e8:	cf11                	beqz	a4,80005404 <exec+0x28e>
    800053ea:	0785                	addi	a5,a5,1
    if(*s == '/')
    800053ec:	02f00693          	li	a3,47
    800053f0:	a039                	j	800053fe <exec+0x288>
      last = s+1;
    800053f2:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800053f6:	0785                	addi	a5,a5,1
    800053f8:	fff7c703          	lbu	a4,-1(a5)
    800053fc:	c701                	beqz	a4,80005404 <exec+0x28e>
    if(*s == '/')
    800053fe:	fed71ce3          	bne	a4,a3,800053f6 <exec+0x280>
    80005402:	bfc5                	j	800053f2 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80005404:	4641                	li	a2,16
    80005406:	de843583          	ld	a1,-536(s0)
    8000540a:	160b8513          	addi	a0,s7,352
    8000540e:	ffffc097          	auipc	ra,0xffffc
    80005412:	a02080e7          	jalr	-1534(ra) # 80000e10 <safestrcpy>
  oldpagetable = p->pagetable;
    80005416:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    8000541a:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000541e:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005422:	060bb783          	ld	a5,96(s7)
    80005426:	e6043703          	ld	a4,-416(s0)
    8000542a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000542c:	060bb783          	ld	a5,96(s7)
    80005430:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005434:	85ea                	mv	a1,s10
    80005436:	ffffc097          	auipc	ra,0xffffc
    8000543a:	706080e7          	jalr	1798(ra) # 80001b3c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000543e:	0004851b          	sext.w	a0,s1
    80005442:	bbc1                	j	80005212 <exec+0x9c>
    80005444:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005448:	df843583          	ld	a1,-520(s0)
    8000544c:	855a                	mv	a0,s6
    8000544e:	ffffc097          	auipc	ra,0xffffc
    80005452:	6ee080e7          	jalr	1774(ra) # 80001b3c <proc_freepagetable>
  if(ip){
    80005456:	da0a94e3          	bnez	s5,800051fe <exec+0x88>
  return -1;
    8000545a:	557d                	li	a0,-1
    8000545c:	bb5d                	j	80005212 <exec+0x9c>
    8000545e:	de943c23          	sd	s1,-520(s0)
    80005462:	b7dd                	j	80005448 <exec+0x2d2>
    80005464:	de943c23          	sd	s1,-520(s0)
    80005468:	b7c5                	j	80005448 <exec+0x2d2>
    8000546a:	de943c23          	sd	s1,-520(s0)
    8000546e:	bfe9                	j	80005448 <exec+0x2d2>
  sz = sz1;
    80005470:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005474:	4a81                	li	s5,0
    80005476:	bfc9                	j	80005448 <exec+0x2d2>
  sz = sz1;
    80005478:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000547c:	4a81                	li	s5,0
    8000547e:	b7e9                	j	80005448 <exec+0x2d2>
  sz = sz1;
    80005480:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005484:	4a81                	li	s5,0
    80005486:	b7c9                	j	80005448 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005488:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000548c:	e0843783          	ld	a5,-504(s0)
    80005490:	0017869b          	addiw	a3,a5,1
    80005494:	e0d43423          	sd	a3,-504(s0)
    80005498:	e0043783          	ld	a5,-512(s0)
    8000549c:	0387879b          	addiw	a5,a5,56
    800054a0:	e8045703          	lhu	a4,-384(s0)
    800054a4:	e2e6d3e3          	bge	a3,a4,800052ca <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800054a8:	2781                	sext.w	a5,a5
    800054aa:	e0f43023          	sd	a5,-512(s0)
    800054ae:	03800713          	li	a4,56
    800054b2:	86be                	mv	a3,a5
    800054b4:	e1040613          	addi	a2,s0,-496
    800054b8:	4581                	li	a1,0
    800054ba:	8556                	mv	a0,s5
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	a7a080e7          	jalr	-1414(ra) # 80003f36 <readi>
    800054c4:	03800793          	li	a5,56
    800054c8:	f6f51ee3          	bne	a0,a5,80005444 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800054cc:	e1042783          	lw	a5,-496(s0)
    800054d0:	4705                	li	a4,1
    800054d2:	fae79de3          	bne	a5,a4,8000548c <exec+0x316>
    if(ph.memsz < ph.filesz)
    800054d6:	e3843603          	ld	a2,-456(s0)
    800054da:	e3043783          	ld	a5,-464(s0)
    800054de:	f8f660e3          	bltu	a2,a5,8000545e <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800054e2:	e2043783          	ld	a5,-480(s0)
    800054e6:	963e                	add	a2,a2,a5
    800054e8:	f6f66ee3          	bltu	a2,a5,80005464 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800054ec:	85a6                	mv	a1,s1
    800054ee:	855a                	mv	a0,s6
    800054f0:	ffffc097          	auipc	ra,0xffffc
    800054f4:	efe080e7          	jalr	-258(ra) # 800013ee <uvmalloc>
    800054f8:	dea43c23          	sd	a0,-520(s0)
    800054fc:	d53d                	beqz	a0,8000546a <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    800054fe:	e2043c03          	ld	s8,-480(s0)
    80005502:	de043783          	ld	a5,-544(s0)
    80005506:	00fc77b3          	and	a5,s8,a5
    8000550a:	ff9d                	bnez	a5,80005448 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000550c:	e1842c83          	lw	s9,-488(s0)
    80005510:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005514:	f60b8ae3          	beqz	s7,80005488 <exec+0x312>
    80005518:	89de                	mv	s3,s7
    8000551a:	4481                	li	s1,0
    8000551c:	b371                	j	800052a8 <exec+0x132>

000000008000551e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000551e:	7179                	addi	sp,sp,-48
    80005520:	f406                	sd	ra,40(sp)
    80005522:	f022                	sd	s0,32(sp)
    80005524:	ec26                	sd	s1,24(sp)
    80005526:	e84a                	sd	s2,16(sp)
    80005528:	1800                	addi	s0,sp,48
    8000552a:	892e                	mv	s2,a1
    8000552c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000552e:	fdc40593          	addi	a1,s0,-36
    80005532:	ffffe097          	auipc	ra,0xffffe
    80005536:	a92080e7          	jalr	-1390(ra) # 80002fc4 <argint>
    8000553a:	04054063          	bltz	a0,8000557a <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000553e:	fdc42703          	lw	a4,-36(s0)
    80005542:	47bd                	li	a5,15
    80005544:	02e7ed63          	bltu	a5,a4,8000557e <argfd+0x60>
    80005548:	ffffc097          	auipc	ra,0xffffc
    8000554c:	44e080e7          	jalr	1102(ra) # 80001996 <myproc>
    80005550:	fdc42703          	lw	a4,-36(s0)
    80005554:	01a70793          	addi	a5,a4,26
    80005558:	078e                	slli	a5,a5,0x3
    8000555a:	953e                	add	a0,a0,a5
    8000555c:	651c                	ld	a5,8(a0)
    8000555e:	c395                	beqz	a5,80005582 <argfd+0x64>
    return -1;
  if(pfd)
    80005560:	00090463          	beqz	s2,80005568 <argfd+0x4a>
    *pfd = fd;
    80005564:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005568:	4501                	li	a0,0
  if(pf)
    8000556a:	c091                	beqz	s1,8000556e <argfd+0x50>
    *pf = f;
    8000556c:	e09c                	sd	a5,0(s1)
}
    8000556e:	70a2                	ld	ra,40(sp)
    80005570:	7402                	ld	s0,32(sp)
    80005572:	64e2                	ld	s1,24(sp)
    80005574:	6942                	ld	s2,16(sp)
    80005576:	6145                	addi	sp,sp,48
    80005578:	8082                	ret
    return -1;
    8000557a:	557d                	li	a0,-1
    8000557c:	bfcd                	j	8000556e <argfd+0x50>
    return -1;
    8000557e:	557d                	li	a0,-1
    80005580:	b7fd                	j	8000556e <argfd+0x50>
    80005582:	557d                	li	a0,-1
    80005584:	b7ed                	j	8000556e <argfd+0x50>

0000000080005586 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005586:	1101                	addi	sp,sp,-32
    80005588:	ec06                	sd	ra,24(sp)
    8000558a:	e822                	sd	s0,16(sp)
    8000558c:	e426                	sd	s1,8(sp)
    8000558e:	1000                	addi	s0,sp,32
    80005590:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005592:	ffffc097          	auipc	ra,0xffffc
    80005596:	404080e7          	jalr	1028(ra) # 80001996 <myproc>
    8000559a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000559c:	0d850793          	addi	a5,a0,216
    800055a0:	4501                	li	a0,0
    800055a2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800055a4:	6398                	ld	a4,0(a5)
    800055a6:	cb19                	beqz	a4,800055bc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800055a8:	2505                	addiw	a0,a0,1
    800055aa:	07a1                	addi	a5,a5,8
    800055ac:	fed51ce3          	bne	a0,a3,800055a4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800055b0:	557d                	li	a0,-1
}
    800055b2:	60e2                	ld	ra,24(sp)
    800055b4:	6442                	ld	s0,16(sp)
    800055b6:	64a2                	ld	s1,8(sp)
    800055b8:	6105                	addi	sp,sp,32
    800055ba:	8082                	ret
      p->ofile[fd] = f;
    800055bc:	01a50793          	addi	a5,a0,26
    800055c0:	078e                	slli	a5,a5,0x3
    800055c2:	963e                	add	a2,a2,a5
    800055c4:	e604                	sd	s1,8(a2)
      return fd;
    800055c6:	b7f5                	j	800055b2 <fdalloc+0x2c>

00000000800055c8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800055c8:	715d                	addi	sp,sp,-80
    800055ca:	e486                	sd	ra,72(sp)
    800055cc:	e0a2                	sd	s0,64(sp)
    800055ce:	fc26                	sd	s1,56(sp)
    800055d0:	f84a                	sd	s2,48(sp)
    800055d2:	f44e                	sd	s3,40(sp)
    800055d4:	f052                	sd	s4,32(sp)
    800055d6:	ec56                	sd	s5,24(sp)
    800055d8:	0880                	addi	s0,sp,80
    800055da:	89ae                	mv	s3,a1
    800055dc:	8ab2                	mv	s5,a2
    800055de:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800055e0:	fb040593          	addi	a1,s0,-80
    800055e4:	fffff097          	auipc	ra,0xfffff
    800055e8:	e72080e7          	jalr	-398(ra) # 80004456 <nameiparent>
    800055ec:	892a                	mv	s2,a0
    800055ee:	12050e63          	beqz	a0,8000572a <create+0x162>
    return 0;

  ilock(dp);
    800055f2:	ffffe097          	auipc	ra,0xffffe
    800055f6:	690080e7          	jalr	1680(ra) # 80003c82 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800055fa:	4601                	li	a2,0
    800055fc:	fb040593          	addi	a1,s0,-80
    80005600:	854a                	mv	a0,s2
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	b64080e7          	jalr	-1180(ra) # 80004166 <dirlookup>
    8000560a:	84aa                	mv	s1,a0
    8000560c:	c921                	beqz	a0,8000565c <create+0x94>
    iunlockput(dp);
    8000560e:	854a                	mv	a0,s2
    80005610:	fffff097          	auipc	ra,0xfffff
    80005614:	8d4080e7          	jalr	-1836(ra) # 80003ee4 <iunlockput>
    ilock(ip);
    80005618:	8526                	mv	a0,s1
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	668080e7          	jalr	1640(ra) # 80003c82 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005622:	2981                	sext.w	s3,s3
    80005624:	4789                	li	a5,2
    80005626:	02f99463          	bne	s3,a5,8000564e <create+0x86>
    8000562a:	0444d783          	lhu	a5,68(s1)
    8000562e:	37f9                	addiw	a5,a5,-2
    80005630:	17c2                	slli	a5,a5,0x30
    80005632:	93c1                	srli	a5,a5,0x30
    80005634:	4705                	li	a4,1
    80005636:	00f76c63          	bltu	a4,a5,8000564e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000563a:	8526                	mv	a0,s1
    8000563c:	60a6                	ld	ra,72(sp)
    8000563e:	6406                	ld	s0,64(sp)
    80005640:	74e2                	ld	s1,56(sp)
    80005642:	7942                	ld	s2,48(sp)
    80005644:	79a2                	ld	s3,40(sp)
    80005646:	7a02                	ld	s4,32(sp)
    80005648:	6ae2                	ld	s5,24(sp)
    8000564a:	6161                	addi	sp,sp,80
    8000564c:	8082                	ret
    iunlockput(ip);
    8000564e:	8526                	mv	a0,s1
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	894080e7          	jalr	-1900(ra) # 80003ee4 <iunlockput>
    return 0;
    80005658:	4481                	li	s1,0
    8000565a:	b7c5                	j	8000563a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000565c:	85ce                	mv	a1,s3
    8000565e:	00092503          	lw	a0,0(s2)
    80005662:	ffffe097          	auipc	ra,0xffffe
    80005666:	488080e7          	jalr	1160(ra) # 80003aea <ialloc>
    8000566a:	84aa                	mv	s1,a0
    8000566c:	c521                	beqz	a0,800056b4 <create+0xec>
  ilock(ip);
    8000566e:	ffffe097          	auipc	ra,0xffffe
    80005672:	614080e7          	jalr	1556(ra) # 80003c82 <ilock>
  ip->major = major;
    80005676:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000567a:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000567e:	4a05                	li	s4,1
    80005680:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005684:	8526                	mv	a0,s1
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	532080e7          	jalr	1330(ra) # 80003bb8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000568e:	2981                	sext.w	s3,s3
    80005690:	03498a63          	beq	s3,s4,800056c4 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005694:	40d0                	lw	a2,4(s1)
    80005696:	fb040593          	addi	a1,s0,-80
    8000569a:	854a                	mv	a0,s2
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	cda080e7          	jalr	-806(ra) # 80004376 <dirlink>
    800056a4:	06054b63          	bltz	a0,8000571a <create+0x152>
  iunlockput(dp);
    800056a8:	854a                	mv	a0,s2
    800056aa:	fffff097          	auipc	ra,0xfffff
    800056ae:	83a080e7          	jalr	-1990(ra) # 80003ee4 <iunlockput>
  return ip;
    800056b2:	b761                	j	8000563a <create+0x72>
    panic("create: ialloc");
    800056b4:	00003517          	auipc	a0,0x3
    800056b8:	22450513          	addi	a0,a0,548 # 800088d8 <syscall_names_table.0+0x2b0>
    800056bc:	ffffb097          	auipc	ra,0xffffb
    800056c0:	e6e080e7          	jalr	-402(ra) # 8000052a <panic>
    dp->nlink++;  // for ".."
    800056c4:	04a95783          	lhu	a5,74(s2)
    800056c8:	2785                	addiw	a5,a5,1
    800056ca:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800056ce:	854a                	mv	a0,s2
    800056d0:	ffffe097          	auipc	ra,0xffffe
    800056d4:	4e8080e7          	jalr	1256(ra) # 80003bb8 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800056d8:	40d0                	lw	a2,4(s1)
    800056da:	00003597          	auipc	a1,0x3
    800056de:	20e58593          	addi	a1,a1,526 # 800088e8 <syscall_names_table.0+0x2c0>
    800056e2:	8526                	mv	a0,s1
    800056e4:	fffff097          	auipc	ra,0xfffff
    800056e8:	c92080e7          	jalr	-878(ra) # 80004376 <dirlink>
    800056ec:	00054f63          	bltz	a0,8000570a <create+0x142>
    800056f0:	00492603          	lw	a2,4(s2)
    800056f4:	00003597          	auipc	a1,0x3
    800056f8:	1fc58593          	addi	a1,a1,508 # 800088f0 <syscall_names_table.0+0x2c8>
    800056fc:	8526                	mv	a0,s1
    800056fe:	fffff097          	auipc	ra,0xfffff
    80005702:	c78080e7          	jalr	-904(ra) # 80004376 <dirlink>
    80005706:	f80557e3          	bgez	a0,80005694 <create+0xcc>
      panic("create dots");
    8000570a:	00003517          	auipc	a0,0x3
    8000570e:	1ee50513          	addi	a0,a0,494 # 800088f8 <syscall_names_table.0+0x2d0>
    80005712:	ffffb097          	auipc	ra,0xffffb
    80005716:	e18080e7          	jalr	-488(ra) # 8000052a <panic>
    panic("create: dirlink");
    8000571a:	00003517          	auipc	a0,0x3
    8000571e:	1ee50513          	addi	a0,a0,494 # 80008908 <syscall_names_table.0+0x2e0>
    80005722:	ffffb097          	auipc	ra,0xffffb
    80005726:	e08080e7          	jalr	-504(ra) # 8000052a <panic>
    return 0;
    8000572a:	84aa                	mv	s1,a0
    8000572c:	b739                	j	8000563a <create+0x72>

000000008000572e <sys_dup>:
{
    8000572e:	7179                	addi	sp,sp,-48
    80005730:	f406                	sd	ra,40(sp)
    80005732:	f022                	sd	s0,32(sp)
    80005734:	ec26                	sd	s1,24(sp)
    80005736:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005738:	fd840613          	addi	a2,s0,-40
    8000573c:	4581                	li	a1,0
    8000573e:	4501                	li	a0,0
    80005740:	00000097          	auipc	ra,0x0
    80005744:	dde080e7          	jalr	-546(ra) # 8000551e <argfd>
    return -1;
    80005748:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000574a:	02054363          	bltz	a0,80005770 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000574e:	fd843503          	ld	a0,-40(s0)
    80005752:	00000097          	auipc	ra,0x0
    80005756:	e34080e7          	jalr	-460(ra) # 80005586 <fdalloc>
    8000575a:	84aa                	mv	s1,a0
    return -1;
    8000575c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000575e:	00054963          	bltz	a0,80005770 <sys_dup+0x42>
  filedup(f);
    80005762:	fd843503          	ld	a0,-40(s0)
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	36c080e7          	jalr	876(ra) # 80004ad2 <filedup>
  return fd;
    8000576e:	87a6                	mv	a5,s1
}
    80005770:	853e                	mv	a0,a5
    80005772:	70a2                	ld	ra,40(sp)
    80005774:	7402                	ld	s0,32(sp)
    80005776:	64e2                	ld	s1,24(sp)
    80005778:	6145                	addi	sp,sp,48
    8000577a:	8082                	ret

000000008000577c <sys_read>:
{
    8000577c:	7179                	addi	sp,sp,-48
    8000577e:	f406                	sd	ra,40(sp)
    80005780:	f022                	sd	s0,32(sp)
    80005782:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005784:	fe840613          	addi	a2,s0,-24
    80005788:	4581                	li	a1,0
    8000578a:	4501                	li	a0,0
    8000578c:	00000097          	auipc	ra,0x0
    80005790:	d92080e7          	jalr	-622(ra) # 8000551e <argfd>
    return -1;
    80005794:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005796:	04054163          	bltz	a0,800057d8 <sys_read+0x5c>
    8000579a:	fe440593          	addi	a1,s0,-28
    8000579e:	4509                	li	a0,2
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	824080e7          	jalr	-2012(ra) # 80002fc4 <argint>
    return -1;
    800057a8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057aa:	02054763          	bltz	a0,800057d8 <sys_read+0x5c>
    800057ae:	fd840593          	addi	a1,s0,-40
    800057b2:	4505                	li	a0,1
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	832080e7          	jalr	-1998(ra) # 80002fe6 <argaddr>
    return -1;
    800057bc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057be:	00054d63          	bltz	a0,800057d8 <sys_read+0x5c>
  return fileread(f, p, n);
    800057c2:	fe442603          	lw	a2,-28(s0)
    800057c6:	fd843583          	ld	a1,-40(s0)
    800057ca:	fe843503          	ld	a0,-24(s0)
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	490080e7          	jalr	1168(ra) # 80004c5e <fileread>
    800057d6:	87aa                	mv	a5,a0
}
    800057d8:	853e                	mv	a0,a5
    800057da:	70a2                	ld	ra,40(sp)
    800057dc:	7402                	ld	s0,32(sp)
    800057de:	6145                	addi	sp,sp,48
    800057e0:	8082                	ret

00000000800057e2 <sys_write>:
{
    800057e2:	7179                	addi	sp,sp,-48
    800057e4:	f406                	sd	ra,40(sp)
    800057e6:	f022                	sd	s0,32(sp)
    800057e8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057ea:	fe840613          	addi	a2,s0,-24
    800057ee:	4581                	li	a1,0
    800057f0:	4501                	li	a0,0
    800057f2:	00000097          	auipc	ra,0x0
    800057f6:	d2c080e7          	jalr	-724(ra) # 8000551e <argfd>
    return -1;
    800057fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800057fc:	04054163          	bltz	a0,8000583e <sys_write+0x5c>
    80005800:	fe440593          	addi	a1,s0,-28
    80005804:	4509                	li	a0,2
    80005806:	ffffd097          	auipc	ra,0xffffd
    8000580a:	7be080e7          	jalr	1982(ra) # 80002fc4 <argint>
    return -1;
    8000580e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005810:	02054763          	bltz	a0,8000583e <sys_write+0x5c>
    80005814:	fd840593          	addi	a1,s0,-40
    80005818:	4505                	li	a0,1
    8000581a:	ffffd097          	auipc	ra,0xffffd
    8000581e:	7cc080e7          	jalr	1996(ra) # 80002fe6 <argaddr>
    return -1;
    80005822:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005824:	00054d63          	bltz	a0,8000583e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005828:	fe442603          	lw	a2,-28(s0)
    8000582c:	fd843583          	ld	a1,-40(s0)
    80005830:	fe843503          	ld	a0,-24(s0)
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	4ec080e7          	jalr	1260(ra) # 80004d20 <filewrite>
    8000583c:	87aa                	mv	a5,a0
}
    8000583e:	853e                	mv	a0,a5
    80005840:	70a2                	ld	ra,40(sp)
    80005842:	7402                	ld	s0,32(sp)
    80005844:	6145                	addi	sp,sp,48
    80005846:	8082                	ret

0000000080005848 <sys_close>:
{
    80005848:	1101                	addi	sp,sp,-32
    8000584a:	ec06                	sd	ra,24(sp)
    8000584c:	e822                	sd	s0,16(sp)
    8000584e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005850:	fe040613          	addi	a2,s0,-32
    80005854:	fec40593          	addi	a1,s0,-20
    80005858:	4501                	li	a0,0
    8000585a:	00000097          	auipc	ra,0x0
    8000585e:	cc4080e7          	jalr	-828(ra) # 8000551e <argfd>
    return -1;
    80005862:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005864:	02054463          	bltz	a0,8000588c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005868:	ffffc097          	auipc	ra,0xffffc
    8000586c:	12e080e7          	jalr	302(ra) # 80001996 <myproc>
    80005870:	fec42783          	lw	a5,-20(s0)
    80005874:	07e9                	addi	a5,a5,26
    80005876:	078e                	slli	a5,a5,0x3
    80005878:	97aa                	add	a5,a5,a0
    8000587a:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    8000587e:	fe043503          	ld	a0,-32(s0)
    80005882:	fffff097          	auipc	ra,0xfffff
    80005886:	2a2080e7          	jalr	674(ra) # 80004b24 <fileclose>
  return 0;
    8000588a:	4781                	li	a5,0
}
    8000588c:	853e                	mv	a0,a5
    8000588e:	60e2                	ld	ra,24(sp)
    80005890:	6442                	ld	s0,16(sp)
    80005892:	6105                	addi	sp,sp,32
    80005894:	8082                	ret

0000000080005896 <sys_fstat>:
{
    80005896:	1101                	addi	sp,sp,-32
    80005898:	ec06                	sd	ra,24(sp)
    8000589a:	e822                	sd	s0,16(sp)
    8000589c:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000589e:	fe840613          	addi	a2,s0,-24
    800058a2:	4581                	li	a1,0
    800058a4:	4501                	li	a0,0
    800058a6:	00000097          	auipc	ra,0x0
    800058aa:	c78080e7          	jalr	-904(ra) # 8000551e <argfd>
    return -1;
    800058ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058b0:	02054563          	bltz	a0,800058da <sys_fstat+0x44>
    800058b4:	fe040593          	addi	a1,s0,-32
    800058b8:	4505                	li	a0,1
    800058ba:	ffffd097          	auipc	ra,0xffffd
    800058be:	72c080e7          	jalr	1836(ra) # 80002fe6 <argaddr>
    return -1;
    800058c2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800058c4:	00054b63          	bltz	a0,800058da <sys_fstat+0x44>
  return filestat(f, st);
    800058c8:	fe043583          	ld	a1,-32(s0)
    800058cc:	fe843503          	ld	a0,-24(s0)
    800058d0:	fffff097          	auipc	ra,0xfffff
    800058d4:	31c080e7          	jalr	796(ra) # 80004bec <filestat>
    800058d8:	87aa                	mv	a5,a0
}
    800058da:	853e                	mv	a0,a5
    800058dc:	60e2                	ld	ra,24(sp)
    800058de:	6442                	ld	s0,16(sp)
    800058e0:	6105                	addi	sp,sp,32
    800058e2:	8082                	ret

00000000800058e4 <sys_link>:
{
    800058e4:	7169                	addi	sp,sp,-304
    800058e6:	f606                	sd	ra,296(sp)
    800058e8:	f222                	sd	s0,288(sp)
    800058ea:	ee26                	sd	s1,280(sp)
    800058ec:	ea4a                	sd	s2,272(sp)
    800058ee:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800058f0:	08000613          	li	a2,128
    800058f4:	ed040593          	addi	a1,s0,-304
    800058f8:	4501                	li	a0,0
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	70e080e7          	jalr	1806(ra) # 80003008 <argstr>
    return -1;
    80005902:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005904:	10054e63          	bltz	a0,80005a20 <sys_link+0x13c>
    80005908:	08000613          	li	a2,128
    8000590c:	f5040593          	addi	a1,s0,-176
    80005910:	4505                	li	a0,1
    80005912:	ffffd097          	auipc	ra,0xffffd
    80005916:	6f6080e7          	jalr	1782(ra) # 80003008 <argstr>
    return -1;
    8000591a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000591c:	10054263          	bltz	a0,80005a20 <sys_link+0x13c>
  begin_op();
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	d38080e7          	jalr	-712(ra) # 80004658 <begin_op>
  if((ip = namei(old)) == 0){
    80005928:	ed040513          	addi	a0,s0,-304
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	b0c080e7          	jalr	-1268(ra) # 80004438 <namei>
    80005934:	84aa                	mv	s1,a0
    80005936:	c551                	beqz	a0,800059c2 <sys_link+0xde>
  ilock(ip);
    80005938:	ffffe097          	auipc	ra,0xffffe
    8000593c:	34a080e7          	jalr	842(ra) # 80003c82 <ilock>
  if(ip->type == T_DIR){
    80005940:	04449703          	lh	a4,68(s1)
    80005944:	4785                	li	a5,1
    80005946:	08f70463          	beq	a4,a5,800059ce <sys_link+0xea>
  ip->nlink++;
    8000594a:	04a4d783          	lhu	a5,74(s1)
    8000594e:	2785                	addiw	a5,a5,1
    80005950:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005954:	8526                	mv	a0,s1
    80005956:	ffffe097          	auipc	ra,0xffffe
    8000595a:	262080e7          	jalr	610(ra) # 80003bb8 <iupdate>
  iunlock(ip);
    8000595e:	8526                	mv	a0,s1
    80005960:	ffffe097          	auipc	ra,0xffffe
    80005964:	3e4080e7          	jalr	996(ra) # 80003d44 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005968:	fd040593          	addi	a1,s0,-48
    8000596c:	f5040513          	addi	a0,s0,-176
    80005970:	fffff097          	auipc	ra,0xfffff
    80005974:	ae6080e7          	jalr	-1306(ra) # 80004456 <nameiparent>
    80005978:	892a                	mv	s2,a0
    8000597a:	c935                	beqz	a0,800059ee <sys_link+0x10a>
  ilock(dp);
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	306080e7          	jalr	774(ra) # 80003c82 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005984:	00092703          	lw	a4,0(s2)
    80005988:	409c                	lw	a5,0(s1)
    8000598a:	04f71d63          	bne	a4,a5,800059e4 <sys_link+0x100>
    8000598e:	40d0                	lw	a2,4(s1)
    80005990:	fd040593          	addi	a1,s0,-48
    80005994:	854a                	mv	a0,s2
    80005996:	fffff097          	auipc	ra,0xfffff
    8000599a:	9e0080e7          	jalr	-1568(ra) # 80004376 <dirlink>
    8000599e:	04054363          	bltz	a0,800059e4 <sys_link+0x100>
  iunlockput(dp);
    800059a2:	854a                	mv	a0,s2
    800059a4:	ffffe097          	auipc	ra,0xffffe
    800059a8:	540080e7          	jalr	1344(ra) # 80003ee4 <iunlockput>
  iput(ip);
    800059ac:	8526                	mv	a0,s1
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	48e080e7          	jalr	1166(ra) # 80003e3c <iput>
  end_op();
    800059b6:	fffff097          	auipc	ra,0xfffff
    800059ba:	d22080e7          	jalr	-734(ra) # 800046d8 <end_op>
  return 0;
    800059be:	4781                	li	a5,0
    800059c0:	a085                	j	80005a20 <sys_link+0x13c>
    end_op();
    800059c2:	fffff097          	auipc	ra,0xfffff
    800059c6:	d16080e7          	jalr	-746(ra) # 800046d8 <end_op>
    return -1;
    800059ca:	57fd                	li	a5,-1
    800059cc:	a891                	j	80005a20 <sys_link+0x13c>
    iunlockput(ip);
    800059ce:	8526                	mv	a0,s1
    800059d0:	ffffe097          	auipc	ra,0xffffe
    800059d4:	514080e7          	jalr	1300(ra) # 80003ee4 <iunlockput>
    end_op();
    800059d8:	fffff097          	auipc	ra,0xfffff
    800059dc:	d00080e7          	jalr	-768(ra) # 800046d8 <end_op>
    return -1;
    800059e0:	57fd                	li	a5,-1
    800059e2:	a83d                	j	80005a20 <sys_link+0x13c>
    iunlockput(dp);
    800059e4:	854a                	mv	a0,s2
    800059e6:	ffffe097          	auipc	ra,0xffffe
    800059ea:	4fe080e7          	jalr	1278(ra) # 80003ee4 <iunlockput>
  ilock(ip);
    800059ee:	8526                	mv	a0,s1
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	292080e7          	jalr	658(ra) # 80003c82 <ilock>
  ip->nlink--;
    800059f8:	04a4d783          	lhu	a5,74(s1)
    800059fc:	37fd                	addiw	a5,a5,-1
    800059fe:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005a02:	8526                	mv	a0,s1
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	1b4080e7          	jalr	436(ra) # 80003bb8 <iupdate>
  iunlockput(ip);
    80005a0c:	8526                	mv	a0,s1
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	4d6080e7          	jalr	1238(ra) # 80003ee4 <iunlockput>
  end_op();
    80005a16:	fffff097          	auipc	ra,0xfffff
    80005a1a:	cc2080e7          	jalr	-830(ra) # 800046d8 <end_op>
  return -1;
    80005a1e:	57fd                	li	a5,-1
}
    80005a20:	853e                	mv	a0,a5
    80005a22:	70b2                	ld	ra,296(sp)
    80005a24:	7412                	ld	s0,288(sp)
    80005a26:	64f2                	ld	s1,280(sp)
    80005a28:	6952                	ld	s2,272(sp)
    80005a2a:	6155                	addi	sp,sp,304
    80005a2c:	8082                	ret

0000000080005a2e <sys_unlink>:
{
    80005a2e:	7151                	addi	sp,sp,-240
    80005a30:	f586                	sd	ra,232(sp)
    80005a32:	f1a2                	sd	s0,224(sp)
    80005a34:	eda6                	sd	s1,216(sp)
    80005a36:	e9ca                	sd	s2,208(sp)
    80005a38:	e5ce                	sd	s3,200(sp)
    80005a3a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005a3c:	08000613          	li	a2,128
    80005a40:	f3040593          	addi	a1,s0,-208
    80005a44:	4501                	li	a0,0
    80005a46:	ffffd097          	auipc	ra,0xffffd
    80005a4a:	5c2080e7          	jalr	1474(ra) # 80003008 <argstr>
    80005a4e:	18054163          	bltz	a0,80005bd0 <sys_unlink+0x1a2>
  begin_op();
    80005a52:	fffff097          	auipc	ra,0xfffff
    80005a56:	c06080e7          	jalr	-1018(ra) # 80004658 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005a5a:	fb040593          	addi	a1,s0,-80
    80005a5e:	f3040513          	addi	a0,s0,-208
    80005a62:	fffff097          	auipc	ra,0xfffff
    80005a66:	9f4080e7          	jalr	-1548(ra) # 80004456 <nameiparent>
    80005a6a:	84aa                	mv	s1,a0
    80005a6c:	c979                	beqz	a0,80005b42 <sys_unlink+0x114>
  ilock(dp);
    80005a6e:	ffffe097          	auipc	ra,0xffffe
    80005a72:	214080e7          	jalr	532(ra) # 80003c82 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005a76:	00003597          	auipc	a1,0x3
    80005a7a:	e7258593          	addi	a1,a1,-398 # 800088e8 <syscall_names_table.0+0x2c0>
    80005a7e:	fb040513          	addi	a0,s0,-80
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	6ca080e7          	jalr	1738(ra) # 8000414c <namecmp>
    80005a8a:	14050a63          	beqz	a0,80005bde <sys_unlink+0x1b0>
    80005a8e:	00003597          	auipc	a1,0x3
    80005a92:	e6258593          	addi	a1,a1,-414 # 800088f0 <syscall_names_table.0+0x2c8>
    80005a96:	fb040513          	addi	a0,s0,-80
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	6b2080e7          	jalr	1714(ra) # 8000414c <namecmp>
    80005aa2:	12050e63          	beqz	a0,80005bde <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005aa6:	f2c40613          	addi	a2,s0,-212
    80005aaa:	fb040593          	addi	a1,s0,-80
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	6b6080e7          	jalr	1718(ra) # 80004166 <dirlookup>
    80005ab8:	892a                	mv	s2,a0
    80005aba:	12050263          	beqz	a0,80005bde <sys_unlink+0x1b0>
  ilock(ip);
    80005abe:	ffffe097          	auipc	ra,0xffffe
    80005ac2:	1c4080e7          	jalr	452(ra) # 80003c82 <ilock>
  if(ip->nlink < 1)
    80005ac6:	04a91783          	lh	a5,74(s2)
    80005aca:	08f05263          	blez	a5,80005b4e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005ace:	04491703          	lh	a4,68(s2)
    80005ad2:	4785                	li	a5,1
    80005ad4:	08f70563          	beq	a4,a5,80005b5e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005ad8:	4641                	li	a2,16
    80005ada:	4581                	li	a1,0
    80005adc:	fc040513          	addi	a0,s0,-64
    80005ae0:	ffffb097          	auipc	ra,0xffffb
    80005ae4:	1de080e7          	jalr	478(ra) # 80000cbe <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005ae8:	4741                	li	a4,16
    80005aea:	f2c42683          	lw	a3,-212(s0)
    80005aee:	fc040613          	addi	a2,s0,-64
    80005af2:	4581                	li	a1,0
    80005af4:	8526                	mv	a0,s1
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	538080e7          	jalr	1336(ra) # 8000402e <writei>
    80005afe:	47c1                	li	a5,16
    80005b00:	0af51563          	bne	a0,a5,80005baa <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005b04:	04491703          	lh	a4,68(s2)
    80005b08:	4785                	li	a5,1
    80005b0a:	0af70863          	beq	a4,a5,80005bba <sys_unlink+0x18c>
  iunlockput(dp);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	3d4080e7          	jalr	980(ra) # 80003ee4 <iunlockput>
  ip->nlink--;
    80005b18:	04a95783          	lhu	a5,74(s2)
    80005b1c:	37fd                	addiw	a5,a5,-1
    80005b1e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005b22:	854a                	mv	a0,s2
    80005b24:	ffffe097          	auipc	ra,0xffffe
    80005b28:	094080e7          	jalr	148(ra) # 80003bb8 <iupdate>
  iunlockput(ip);
    80005b2c:	854a                	mv	a0,s2
    80005b2e:	ffffe097          	auipc	ra,0xffffe
    80005b32:	3b6080e7          	jalr	950(ra) # 80003ee4 <iunlockput>
  end_op();
    80005b36:	fffff097          	auipc	ra,0xfffff
    80005b3a:	ba2080e7          	jalr	-1118(ra) # 800046d8 <end_op>
  return 0;
    80005b3e:	4501                	li	a0,0
    80005b40:	a84d                	j	80005bf2 <sys_unlink+0x1c4>
    end_op();
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	b96080e7          	jalr	-1130(ra) # 800046d8 <end_op>
    return -1;
    80005b4a:	557d                	li	a0,-1
    80005b4c:	a05d                	j	80005bf2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005b4e:	00003517          	auipc	a0,0x3
    80005b52:	dca50513          	addi	a0,a0,-566 # 80008918 <syscall_names_table.0+0x2f0>
    80005b56:	ffffb097          	auipc	ra,0xffffb
    80005b5a:	9d4080e7          	jalr	-1580(ra) # 8000052a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b5e:	04c92703          	lw	a4,76(s2)
    80005b62:	02000793          	li	a5,32
    80005b66:	f6e7f9e3          	bgeu	a5,a4,80005ad8 <sys_unlink+0xaa>
    80005b6a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005b6e:	4741                	li	a4,16
    80005b70:	86ce                	mv	a3,s3
    80005b72:	f1840613          	addi	a2,s0,-232
    80005b76:	4581                	li	a1,0
    80005b78:	854a                	mv	a0,s2
    80005b7a:	ffffe097          	auipc	ra,0xffffe
    80005b7e:	3bc080e7          	jalr	956(ra) # 80003f36 <readi>
    80005b82:	47c1                	li	a5,16
    80005b84:	00f51b63          	bne	a0,a5,80005b9a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b88:	f1845783          	lhu	a5,-232(s0)
    80005b8c:	e7a1                	bnez	a5,80005bd4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b8e:	29c1                	addiw	s3,s3,16
    80005b90:	04c92783          	lw	a5,76(s2)
    80005b94:	fcf9ede3          	bltu	s3,a5,80005b6e <sys_unlink+0x140>
    80005b98:	b781                	j	80005ad8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b9a:	00003517          	auipc	a0,0x3
    80005b9e:	d9650513          	addi	a0,a0,-618 # 80008930 <syscall_names_table.0+0x308>
    80005ba2:	ffffb097          	auipc	ra,0xffffb
    80005ba6:	988080e7          	jalr	-1656(ra) # 8000052a <panic>
    panic("unlink: writei");
    80005baa:	00003517          	auipc	a0,0x3
    80005bae:	d9e50513          	addi	a0,a0,-610 # 80008948 <syscall_names_table.0+0x320>
    80005bb2:	ffffb097          	auipc	ra,0xffffb
    80005bb6:	978080e7          	jalr	-1672(ra) # 8000052a <panic>
    dp->nlink--;
    80005bba:	04a4d783          	lhu	a5,74(s1)
    80005bbe:	37fd                	addiw	a5,a5,-1
    80005bc0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005bc4:	8526                	mv	a0,s1
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	ff2080e7          	jalr	-14(ra) # 80003bb8 <iupdate>
    80005bce:	b781                	j	80005b0e <sys_unlink+0xe0>
    return -1;
    80005bd0:	557d                	li	a0,-1
    80005bd2:	a005                	j	80005bf2 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005bd4:	854a                	mv	a0,s2
    80005bd6:	ffffe097          	auipc	ra,0xffffe
    80005bda:	30e080e7          	jalr	782(ra) # 80003ee4 <iunlockput>
  iunlockput(dp);
    80005bde:	8526                	mv	a0,s1
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	304080e7          	jalr	772(ra) # 80003ee4 <iunlockput>
  end_op();
    80005be8:	fffff097          	auipc	ra,0xfffff
    80005bec:	af0080e7          	jalr	-1296(ra) # 800046d8 <end_op>
  return -1;
    80005bf0:	557d                	li	a0,-1
}
    80005bf2:	70ae                	ld	ra,232(sp)
    80005bf4:	740e                	ld	s0,224(sp)
    80005bf6:	64ee                	ld	s1,216(sp)
    80005bf8:	694e                	ld	s2,208(sp)
    80005bfa:	69ae                	ld	s3,200(sp)
    80005bfc:	616d                	addi	sp,sp,240
    80005bfe:	8082                	ret

0000000080005c00 <sys_open>:

uint64
sys_open(void)
{
    80005c00:	7131                	addi	sp,sp,-192
    80005c02:	fd06                	sd	ra,184(sp)
    80005c04:	f922                	sd	s0,176(sp)
    80005c06:	f526                	sd	s1,168(sp)
    80005c08:	f14a                	sd	s2,160(sp)
    80005c0a:	ed4e                	sd	s3,152(sp)
    80005c0c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c0e:	08000613          	li	a2,128
    80005c12:	f5040593          	addi	a1,s0,-176
    80005c16:	4501                	li	a0,0
    80005c18:	ffffd097          	auipc	ra,0xffffd
    80005c1c:	3f0080e7          	jalr	1008(ra) # 80003008 <argstr>
    return -1;
    80005c20:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005c22:	0c054163          	bltz	a0,80005ce4 <sys_open+0xe4>
    80005c26:	f4c40593          	addi	a1,s0,-180
    80005c2a:	4505                	li	a0,1
    80005c2c:	ffffd097          	auipc	ra,0xffffd
    80005c30:	398080e7          	jalr	920(ra) # 80002fc4 <argint>
    80005c34:	0a054863          	bltz	a0,80005ce4 <sys_open+0xe4>

  begin_op();
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	a20080e7          	jalr	-1504(ra) # 80004658 <begin_op>

  if(omode & O_CREATE){
    80005c40:	f4c42783          	lw	a5,-180(s0)
    80005c44:	2007f793          	andi	a5,a5,512
    80005c48:	cbdd                	beqz	a5,80005cfe <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005c4a:	4681                	li	a3,0
    80005c4c:	4601                	li	a2,0
    80005c4e:	4589                	li	a1,2
    80005c50:	f5040513          	addi	a0,s0,-176
    80005c54:	00000097          	auipc	ra,0x0
    80005c58:	974080e7          	jalr	-1676(ra) # 800055c8 <create>
    80005c5c:	892a                	mv	s2,a0
    if(ip == 0){
    80005c5e:	c959                	beqz	a0,80005cf4 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005c60:	04491703          	lh	a4,68(s2)
    80005c64:	478d                	li	a5,3
    80005c66:	00f71763          	bne	a4,a5,80005c74 <sys_open+0x74>
    80005c6a:	04695703          	lhu	a4,70(s2)
    80005c6e:	47a5                	li	a5,9
    80005c70:	0ce7ec63          	bltu	a5,a4,80005d48 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	df4080e7          	jalr	-524(ra) # 80004a68 <filealloc>
    80005c7c:	89aa                	mv	s3,a0
    80005c7e:	10050263          	beqz	a0,80005d82 <sys_open+0x182>
    80005c82:	00000097          	auipc	ra,0x0
    80005c86:	904080e7          	jalr	-1788(ra) # 80005586 <fdalloc>
    80005c8a:	84aa                	mv	s1,a0
    80005c8c:	0e054663          	bltz	a0,80005d78 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c90:	04491703          	lh	a4,68(s2)
    80005c94:	478d                	li	a5,3
    80005c96:	0cf70463          	beq	a4,a5,80005d5e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c9a:	4789                	li	a5,2
    80005c9c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ca0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ca4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ca8:	f4c42783          	lw	a5,-180(s0)
    80005cac:	0017c713          	xori	a4,a5,1
    80005cb0:	8b05                	andi	a4,a4,1
    80005cb2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005cb6:	0037f713          	andi	a4,a5,3
    80005cba:	00e03733          	snez	a4,a4
    80005cbe:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005cc2:	4007f793          	andi	a5,a5,1024
    80005cc6:	c791                	beqz	a5,80005cd2 <sys_open+0xd2>
    80005cc8:	04491703          	lh	a4,68(s2)
    80005ccc:	4789                	li	a5,2
    80005cce:	08f70f63          	beq	a4,a5,80005d6c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005cd2:	854a                	mv	a0,s2
    80005cd4:	ffffe097          	auipc	ra,0xffffe
    80005cd8:	070080e7          	jalr	112(ra) # 80003d44 <iunlock>
  end_op();
    80005cdc:	fffff097          	auipc	ra,0xfffff
    80005ce0:	9fc080e7          	jalr	-1540(ra) # 800046d8 <end_op>

  return fd;
}
    80005ce4:	8526                	mv	a0,s1
    80005ce6:	70ea                	ld	ra,184(sp)
    80005ce8:	744a                	ld	s0,176(sp)
    80005cea:	74aa                	ld	s1,168(sp)
    80005cec:	790a                	ld	s2,160(sp)
    80005cee:	69ea                	ld	s3,152(sp)
    80005cf0:	6129                	addi	sp,sp,192
    80005cf2:	8082                	ret
      end_op();
    80005cf4:	fffff097          	auipc	ra,0xfffff
    80005cf8:	9e4080e7          	jalr	-1564(ra) # 800046d8 <end_op>
      return -1;
    80005cfc:	b7e5                	j	80005ce4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005cfe:	f5040513          	addi	a0,s0,-176
    80005d02:	ffffe097          	auipc	ra,0xffffe
    80005d06:	736080e7          	jalr	1846(ra) # 80004438 <namei>
    80005d0a:	892a                	mv	s2,a0
    80005d0c:	c905                	beqz	a0,80005d3c <sys_open+0x13c>
    ilock(ip);
    80005d0e:	ffffe097          	auipc	ra,0xffffe
    80005d12:	f74080e7          	jalr	-140(ra) # 80003c82 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005d16:	04491703          	lh	a4,68(s2)
    80005d1a:	4785                	li	a5,1
    80005d1c:	f4f712e3          	bne	a4,a5,80005c60 <sys_open+0x60>
    80005d20:	f4c42783          	lw	a5,-180(s0)
    80005d24:	dba1                	beqz	a5,80005c74 <sys_open+0x74>
      iunlockput(ip);
    80005d26:	854a                	mv	a0,s2
    80005d28:	ffffe097          	auipc	ra,0xffffe
    80005d2c:	1bc080e7          	jalr	444(ra) # 80003ee4 <iunlockput>
      end_op();
    80005d30:	fffff097          	auipc	ra,0xfffff
    80005d34:	9a8080e7          	jalr	-1624(ra) # 800046d8 <end_op>
      return -1;
    80005d38:	54fd                	li	s1,-1
    80005d3a:	b76d                	j	80005ce4 <sys_open+0xe4>
      end_op();
    80005d3c:	fffff097          	auipc	ra,0xfffff
    80005d40:	99c080e7          	jalr	-1636(ra) # 800046d8 <end_op>
      return -1;
    80005d44:	54fd                	li	s1,-1
    80005d46:	bf79                	j	80005ce4 <sys_open+0xe4>
    iunlockput(ip);
    80005d48:	854a                	mv	a0,s2
    80005d4a:	ffffe097          	auipc	ra,0xffffe
    80005d4e:	19a080e7          	jalr	410(ra) # 80003ee4 <iunlockput>
    end_op();
    80005d52:	fffff097          	auipc	ra,0xfffff
    80005d56:	986080e7          	jalr	-1658(ra) # 800046d8 <end_op>
    return -1;
    80005d5a:	54fd                	li	s1,-1
    80005d5c:	b761                	j	80005ce4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005d5e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005d62:	04691783          	lh	a5,70(s2)
    80005d66:	02f99223          	sh	a5,36(s3)
    80005d6a:	bf2d                	j	80005ca4 <sys_open+0xa4>
    itrunc(ip);
    80005d6c:	854a                	mv	a0,s2
    80005d6e:	ffffe097          	auipc	ra,0xffffe
    80005d72:	022080e7          	jalr	34(ra) # 80003d90 <itrunc>
    80005d76:	bfb1                	j	80005cd2 <sys_open+0xd2>
      fileclose(f);
    80005d78:	854e                	mv	a0,s3
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	daa080e7          	jalr	-598(ra) # 80004b24 <fileclose>
    iunlockput(ip);
    80005d82:	854a                	mv	a0,s2
    80005d84:	ffffe097          	auipc	ra,0xffffe
    80005d88:	160080e7          	jalr	352(ra) # 80003ee4 <iunlockput>
    end_op();
    80005d8c:	fffff097          	auipc	ra,0xfffff
    80005d90:	94c080e7          	jalr	-1716(ra) # 800046d8 <end_op>
    return -1;
    80005d94:	54fd                	li	s1,-1
    80005d96:	b7b9                	j	80005ce4 <sys_open+0xe4>

0000000080005d98 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d98:	7175                	addi	sp,sp,-144
    80005d9a:	e506                	sd	ra,136(sp)
    80005d9c:	e122                	sd	s0,128(sp)
    80005d9e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005da0:	fffff097          	auipc	ra,0xfffff
    80005da4:	8b8080e7          	jalr	-1864(ra) # 80004658 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005da8:	08000613          	li	a2,128
    80005dac:	f7040593          	addi	a1,s0,-144
    80005db0:	4501                	li	a0,0
    80005db2:	ffffd097          	auipc	ra,0xffffd
    80005db6:	256080e7          	jalr	598(ra) # 80003008 <argstr>
    80005dba:	02054963          	bltz	a0,80005dec <sys_mkdir+0x54>
    80005dbe:	4681                	li	a3,0
    80005dc0:	4601                	li	a2,0
    80005dc2:	4585                	li	a1,1
    80005dc4:	f7040513          	addi	a0,s0,-144
    80005dc8:	00000097          	auipc	ra,0x0
    80005dcc:	800080e7          	jalr	-2048(ra) # 800055c8 <create>
    80005dd0:	cd11                	beqz	a0,80005dec <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dd2:	ffffe097          	auipc	ra,0xffffe
    80005dd6:	112080e7          	jalr	274(ra) # 80003ee4 <iunlockput>
  end_op();
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	8fe080e7          	jalr	-1794(ra) # 800046d8 <end_op>
  return 0;
    80005de2:	4501                	li	a0,0
}
    80005de4:	60aa                	ld	ra,136(sp)
    80005de6:	640a                	ld	s0,128(sp)
    80005de8:	6149                	addi	sp,sp,144
    80005dea:	8082                	ret
    end_op();
    80005dec:	fffff097          	auipc	ra,0xfffff
    80005df0:	8ec080e7          	jalr	-1812(ra) # 800046d8 <end_op>
    return -1;
    80005df4:	557d                	li	a0,-1
    80005df6:	b7fd                	j	80005de4 <sys_mkdir+0x4c>

0000000080005df8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005df8:	7135                	addi	sp,sp,-160
    80005dfa:	ed06                	sd	ra,152(sp)
    80005dfc:	e922                	sd	s0,144(sp)
    80005dfe:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005e00:	fffff097          	auipc	ra,0xfffff
    80005e04:	858080e7          	jalr	-1960(ra) # 80004658 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e08:	08000613          	li	a2,128
    80005e0c:	f7040593          	addi	a1,s0,-144
    80005e10:	4501                	li	a0,0
    80005e12:	ffffd097          	auipc	ra,0xffffd
    80005e16:	1f6080e7          	jalr	502(ra) # 80003008 <argstr>
    80005e1a:	04054a63          	bltz	a0,80005e6e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005e1e:	f6c40593          	addi	a1,s0,-148
    80005e22:	4505                	li	a0,1
    80005e24:	ffffd097          	auipc	ra,0xffffd
    80005e28:	1a0080e7          	jalr	416(ra) # 80002fc4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005e2c:	04054163          	bltz	a0,80005e6e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005e30:	f6840593          	addi	a1,s0,-152
    80005e34:	4509                	li	a0,2
    80005e36:	ffffd097          	auipc	ra,0xffffd
    80005e3a:	18e080e7          	jalr	398(ra) # 80002fc4 <argint>
     argint(1, &major) < 0 ||
    80005e3e:	02054863          	bltz	a0,80005e6e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005e42:	f6841683          	lh	a3,-152(s0)
    80005e46:	f6c41603          	lh	a2,-148(s0)
    80005e4a:	458d                	li	a1,3
    80005e4c:	f7040513          	addi	a0,s0,-144
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	778080e7          	jalr	1912(ra) # 800055c8 <create>
     argint(2, &minor) < 0 ||
    80005e58:	c919                	beqz	a0,80005e6e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005e5a:	ffffe097          	auipc	ra,0xffffe
    80005e5e:	08a080e7          	jalr	138(ra) # 80003ee4 <iunlockput>
  end_op();
    80005e62:	fffff097          	auipc	ra,0xfffff
    80005e66:	876080e7          	jalr	-1930(ra) # 800046d8 <end_op>
  return 0;
    80005e6a:	4501                	li	a0,0
    80005e6c:	a031                	j	80005e78 <sys_mknod+0x80>
    end_op();
    80005e6e:	fffff097          	auipc	ra,0xfffff
    80005e72:	86a080e7          	jalr	-1942(ra) # 800046d8 <end_op>
    return -1;
    80005e76:	557d                	li	a0,-1
}
    80005e78:	60ea                	ld	ra,152(sp)
    80005e7a:	644a                	ld	s0,144(sp)
    80005e7c:	610d                	addi	sp,sp,160
    80005e7e:	8082                	ret

0000000080005e80 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005e80:	7135                	addi	sp,sp,-160
    80005e82:	ed06                	sd	ra,152(sp)
    80005e84:	e922                	sd	s0,144(sp)
    80005e86:	e526                	sd	s1,136(sp)
    80005e88:	e14a                	sd	s2,128(sp)
    80005e8a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e8c:	ffffc097          	auipc	ra,0xffffc
    80005e90:	b0a080e7          	jalr	-1270(ra) # 80001996 <myproc>
    80005e94:	892a                	mv	s2,a0
  
  begin_op();
    80005e96:	ffffe097          	auipc	ra,0xffffe
    80005e9a:	7c2080e7          	jalr	1986(ra) # 80004658 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e9e:	08000613          	li	a2,128
    80005ea2:	f6040593          	addi	a1,s0,-160
    80005ea6:	4501                	li	a0,0
    80005ea8:	ffffd097          	auipc	ra,0xffffd
    80005eac:	160080e7          	jalr	352(ra) # 80003008 <argstr>
    80005eb0:	04054b63          	bltz	a0,80005f06 <sys_chdir+0x86>
    80005eb4:	f6040513          	addi	a0,s0,-160
    80005eb8:	ffffe097          	auipc	ra,0xffffe
    80005ebc:	580080e7          	jalr	1408(ra) # 80004438 <namei>
    80005ec0:	84aa                	mv	s1,a0
    80005ec2:	c131                	beqz	a0,80005f06 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ec4:	ffffe097          	auipc	ra,0xffffe
    80005ec8:	dbe080e7          	jalr	-578(ra) # 80003c82 <ilock>
  if(ip->type != T_DIR){
    80005ecc:	04449703          	lh	a4,68(s1)
    80005ed0:	4785                	li	a5,1
    80005ed2:	04f71063          	bne	a4,a5,80005f12 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005ed6:	8526                	mv	a0,s1
    80005ed8:	ffffe097          	auipc	ra,0xffffe
    80005edc:	e6c080e7          	jalr	-404(ra) # 80003d44 <iunlock>
  iput(p->cwd);
    80005ee0:	15893503          	ld	a0,344(s2)
    80005ee4:	ffffe097          	auipc	ra,0xffffe
    80005ee8:	f58080e7          	jalr	-168(ra) # 80003e3c <iput>
  end_op();
    80005eec:	ffffe097          	auipc	ra,0xffffe
    80005ef0:	7ec080e7          	jalr	2028(ra) # 800046d8 <end_op>
  p->cwd = ip;
    80005ef4:	14993c23          	sd	s1,344(s2)
  return 0;
    80005ef8:	4501                	li	a0,0
}
    80005efa:	60ea                	ld	ra,152(sp)
    80005efc:	644a                	ld	s0,144(sp)
    80005efe:	64aa                	ld	s1,136(sp)
    80005f00:	690a                	ld	s2,128(sp)
    80005f02:	610d                	addi	sp,sp,160
    80005f04:	8082                	ret
    end_op();
    80005f06:	ffffe097          	auipc	ra,0xffffe
    80005f0a:	7d2080e7          	jalr	2002(ra) # 800046d8 <end_op>
    return -1;
    80005f0e:	557d                	li	a0,-1
    80005f10:	b7ed                	j	80005efa <sys_chdir+0x7a>
    iunlockput(ip);
    80005f12:	8526                	mv	a0,s1
    80005f14:	ffffe097          	auipc	ra,0xffffe
    80005f18:	fd0080e7          	jalr	-48(ra) # 80003ee4 <iunlockput>
    end_op();
    80005f1c:	ffffe097          	auipc	ra,0xffffe
    80005f20:	7bc080e7          	jalr	1980(ra) # 800046d8 <end_op>
    return -1;
    80005f24:	557d                	li	a0,-1
    80005f26:	bfd1                	j	80005efa <sys_chdir+0x7a>

0000000080005f28 <sys_exec>:

uint64
sys_exec(void)
{
    80005f28:	7145                	addi	sp,sp,-464
    80005f2a:	e786                	sd	ra,456(sp)
    80005f2c:	e3a2                	sd	s0,448(sp)
    80005f2e:	ff26                	sd	s1,440(sp)
    80005f30:	fb4a                	sd	s2,432(sp)
    80005f32:	f74e                	sd	s3,424(sp)
    80005f34:	f352                	sd	s4,416(sp)
    80005f36:	ef56                	sd	s5,408(sp)
    80005f38:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f3a:	08000613          	li	a2,128
    80005f3e:	f4040593          	addi	a1,s0,-192
    80005f42:	4501                	li	a0,0
    80005f44:	ffffd097          	auipc	ra,0xffffd
    80005f48:	0c4080e7          	jalr	196(ra) # 80003008 <argstr>
    return -1;
    80005f4c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005f4e:	0c054a63          	bltz	a0,80006022 <sys_exec+0xfa>
    80005f52:	e3840593          	addi	a1,s0,-456
    80005f56:	4505                	li	a0,1
    80005f58:	ffffd097          	auipc	ra,0xffffd
    80005f5c:	08e080e7          	jalr	142(ra) # 80002fe6 <argaddr>
    80005f60:	0c054163          	bltz	a0,80006022 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005f64:	10000613          	li	a2,256
    80005f68:	4581                	li	a1,0
    80005f6a:	e4040513          	addi	a0,s0,-448
    80005f6e:	ffffb097          	auipc	ra,0xffffb
    80005f72:	d50080e7          	jalr	-688(ra) # 80000cbe <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005f76:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005f7a:	89a6                	mv	s3,s1
    80005f7c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005f7e:	02000a13          	li	s4,32
    80005f82:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005f86:	00391793          	slli	a5,s2,0x3
    80005f8a:	e3040593          	addi	a1,s0,-464
    80005f8e:	e3843503          	ld	a0,-456(s0)
    80005f92:	953e                	add	a0,a0,a5
    80005f94:	ffffd097          	auipc	ra,0xffffd
    80005f98:	f96080e7          	jalr	-106(ra) # 80002f2a <fetchaddr>
    80005f9c:	02054a63          	bltz	a0,80005fd0 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005fa0:	e3043783          	ld	a5,-464(s0)
    80005fa4:	c3b9                	beqz	a5,80005fea <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005fa6:	ffffb097          	auipc	ra,0xffffb
    80005faa:	b2c080e7          	jalr	-1236(ra) # 80000ad2 <kalloc>
    80005fae:	85aa                	mv	a1,a0
    80005fb0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005fb4:	cd11                	beqz	a0,80005fd0 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005fb6:	6605                	lui	a2,0x1
    80005fb8:	e3043503          	ld	a0,-464(s0)
    80005fbc:	ffffd097          	auipc	ra,0xffffd
    80005fc0:	fc0080e7          	jalr	-64(ra) # 80002f7c <fetchstr>
    80005fc4:	00054663          	bltz	a0,80005fd0 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005fc8:	0905                	addi	s2,s2,1
    80005fca:	09a1                	addi	s3,s3,8
    80005fcc:	fb491be3          	bne	s2,s4,80005f82 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fd0:	10048913          	addi	s2,s1,256
    80005fd4:	6088                	ld	a0,0(s1)
    80005fd6:	c529                	beqz	a0,80006020 <sys_exec+0xf8>
    kfree(argv[i]);
    80005fd8:	ffffb097          	auipc	ra,0xffffb
    80005fdc:	9fe080e7          	jalr	-1538(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005fe0:	04a1                	addi	s1,s1,8
    80005fe2:	ff2499e3          	bne	s1,s2,80005fd4 <sys_exec+0xac>
  return -1;
    80005fe6:	597d                	li	s2,-1
    80005fe8:	a82d                	j	80006022 <sys_exec+0xfa>
      argv[i] = 0;
    80005fea:	0a8e                	slli	s5,s5,0x3
    80005fec:	fc040793          	addi	a5,s0,-64
    80005ff0:	9abe                	add	s5,s5,a5
    80005ff2:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005ff6:	e4040593          	addi	a1,s0,-448
    80005ffa:	f4040513          	addi	a0,s0,-192
    80005ffe:	fffff097          	auipc	ra,0xfffff
    80006002:	178080e7          	jalr	376(ra) # 80005176 <exec>
    80006006:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006008:	10048993          	addi	s3,s1,256
    8000600c:	6088                	ld	a0,0(s1)
    8000600e:	c911                	beqz	a0,80006022 <sys_exec+0xfa>
    kfree(argv[i]);
    80006010:	ffffb097          	auipc	ra,0xffffb
    80006014:	9c6080e7          	jalr	-1594(ra) # 800009d6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006018:	04a1                	addi	s1,s1,8
    8000601a:	ff3499e3          	bne	s1,s3,8000600c <sys_exec+0xe4>
    8000601e:	a011                	j	80006022 <sys_exec+0xfa>
  return -1;
    80006020:	597d                	li	s2,-1
}
    80006022:	854a                	mv	a0,s2
    80006024:	60be                	ld	ra,456(sp)
    80006026:	641e                	ld	s0,448(sp)
    80006028:	74fa                	ld	s1,440(sp)
    8000602a:	795a                	ld	s2,432(sp)
    8000602c:	79ba                	ld	s3,424(sp)
    8000602e:	7a1a                	ld	s4,416(sp)
    80006030:	6afa                	ld	s5,408(sp)
    80006032:	6179                	addi	sp,sp,464
    80006034:	8082                	ret

0000000080006036 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006036:	7139                	addi	sp,sp,-64
    80006038:	fc06                	sd	ra,56(sp)
    8000603a:	f822                	sd	s0,48(sp)
    8000603c:	f426                	sd	s1,40(sp)
    8000603e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006040:	ffffc097          	auipc	ra,0xffffc
    80006044:	956080e7          	jalr	-1706(ra) # 80001996 <myproc>
    80006048:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    8000604a:	fd840593          	addi	a1,s0,-40
    8000604e:	4501                	li	a0,0
    80006050:	ffffd097          	auipc	ra,0xffffd
    80006054:	f96080e7          	jalr	-106(ra) # 80002fe6 <argaddr>
    return -1;
    80006058:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    8000605a:	0e054063          	bltz	a0,8000613a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    8000605e:	fc840593          	addi	a1,s0,-56
    80006062:	fd040513          	addi	a0,s0,-48
    80006066:	fffff097          	auipc	ra,0xfffff
    8000606a:	dee080e7          	jalr	-530(ra) # 80004e54 <pipealloc>
    return -1;
    8000606e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006070:	0c054563          	bltz	a0,8000613a <sys_pipe+0x104>
  fd0 = -1;
    80006074:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006078:	fd043503          	ld	a0,-48(s0)
    8000607c:	fffff097          	auipc	ra,0xfffff
    80006080:	50a080e7          	jalr	1290(ra) # 80005586 <fdalloc>
    80006084:	fca42223          	sw	a0,-60(s0)
    80006088:	08054c63          	bltz	a0,80006120 <sys_pipe+0xea>
    8000608c:	fc843503          	ld	a0,-56(s0)
    80006090:	fffff097          	auipc	ra,0xfffff
    80006094:	4f6080e7          	jalr	1270(ra) # 80005586 <fdalloc>
    80006098:	fca42023          	sw	a0,-64(s0)
    8000609c:	06054863          	bltz	a0,8000610c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060a0:	4691                	li	a3,4
    800060a2:	fc440613          	addi	a2,s0,-60
    800060a6:	fd843583          	ld	a1,-40(s0)
    800060aa:	6ca8                	ld	a0,88(s1)
    800060ac:	ffffb097          	auipc	ra,0xffffb
    800060b0:	592080e7          	jalr	1426(ra) # 8000163e <copyout>
    800060b4:	02054063          	bltz	a0,800060d4 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800060b8:	4691                	li	a3,4
    800060ba:	fc040613          	addi	a2,s0,-64
    800060be:	fd843583          	ld	a1,-40(s0)
    800060c2:	0591                	addi	a1,a1,4
    800060c4:	6ca8                	ld	a0,88(s1)
    800060c6:	ffffb097          	auipc	ra,0xffffb
    800060ca:	578080e7          	jalr	1400(ra) # 8000163e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800060ce:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800060d0:	06055563          	bgez	a0,8000613a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    800060d4:	fc442783          	lw	a5,-60(s0)
    800060d8:	07e9                	addi	a5,a5,26
    800060da:	078e                	slli	a5,a5,0x3
    800060dc:	97a6                	add	a5,a5,s1
    800060de:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    800060e2:	fc042503          	lw	a0,-64(s0)
    800060e6:	0569                	addi	a0,a0,26
    800060e8:	050e                	slli	a0,a0,0x3
    800060ea:	9526                	add	a0,a0,s1
    800060ec:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    800060f0:	fd043503          	ld	a0,-48(s0)
    800060f4:	fffff097          	auipc	ra,0xfffff
    800060f8:	a30080e7          	jalr	-1488(ra) # 80004b24 <fileclose>
    fileclose(wf);
    800060fc:	fc843503          	ld	a0,-56(s0)
    80006100:	fffff097          	auipc	ra,0xfffff
    80006104:	a24080e7          	jalr	-1500(ra) # 80004b24 <fileclose>
    return -1;
    80006108:	57fd                	li	a5,-1
    8000610a:	a805                	j	8000613a <sys_pipe+0x104>
    if(fd0 >= 0)
    8000610c:	fc442783          	lw	a5,-60(s0)
    80006110:	0007c863          	bltz	a5,80006120 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006114:	01a78513          	addi	a0,a5,26
    80006118:	050e                	slli	a0,a0,0x3
    8000611a:	9526                	add	a0,a0,s1
    8000611c:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80006120:	fd043503          	ld	a0,-48(s0)
    80006124:	fffff097          	auipc	ra,0xfffff
    80006128:	a00080e7          	jalr	-1536(ra) # 80004b24 <fileclose>
    fileclose(wf);
    8000612c:	fc843503          	ld	a0,-56(s0)
    80006130:	fffff097          	auipc	ra,0xfffff
    80006134:	9f4080e7          	jalr	-1548(ra) # 80004b24 <fileclose>
    return -1;
    80006138:	57fd                	li	a5,-1
    8000613a:	853e                	mv	a0,a5
    8000613c:	70e2                	ld	ra,56(sp)
    8000613e:	7442                	ld	s0,48(sp)
    80006140:	74a2                	ld	s1,40(sp)
    80006142:	6121                	addi	sp,sp,64
    80006144:	8082                	ret
	...

0000000080006150 <kernelvec>:
    80006150:	7111                	addi	sp,sp,-256
    80006152:	e006                	sd	ra,0(sp)
    80006154:	e40a                	sd	sp,8(sp)
    80006156:	e80e                	sd	gp,16(sp)
    80006158:	ec12                	sd	tp,24(sp)
    8000615a:	f016                	sd	t0,32(sp)
    8000615c:	f41a                	sd	t1,40(sp)
    8000615e:	f81e                	sd	t2,48(sp)
    80006160:	fc22                	sd	s0,56(sp)
    80006162:	e0a6                	sd	s1,64(sp)
    80006164:	e4aa                	sd	a0,72(sp)
    80006166:	e8ae                	sd	a1,80(sp)
    80006168:	ecb2                	sd	a2,88(sp)
    8000616a:	f0b6                	sd	a3,96(sp)
    8000616c:	f4ba                	sd	a4,104(sp)
    8000616e:	f8be                	sd	a5,112(sp)
    80006170:	fcc2                	sd	a6,120(sp)
    80006172:	e146                	sd	a7,128(sp)
    80006174:	e54a                	sd	s2,136(sp)
    80006176:	e94e                	sd	s3,144(sp)
    80006178:	ed52                	sd	s4,152(sp)
    8000617a:	f156                	sd	s5,160(sp)
    8000617c:	f55a                	sd	s6,168(sp)
    8000617e:	f95e                	sd	s7,176(sp)
    80006180:	fd62                	sd	s8,184(sp)
    80006182:	e1e6                	sd	s9,192(sp)
    80006184:	e5ea                	sd	s10,200(sp)
    80006186:	e9ee                	sd	s11,208(sp)
    80006188:	edf2                	sd	t3,216(sp)
    8000618a:	f1f6                	sd	t4,224(sp)
    8000618c:	f5fa                	sd	t5,232(sp)
    8000618e:	f9fe                	sd	t6,240(sp)
    80006190:	c67fc0ef          	jal	ra,80002df6 <kerneltrap>
    80006194:	6082                	ld	ra,0(sp)
    80006196:	6122                	ld	sp,8(sp)
    80006198:	61c2                	ld	gp,16(sp)
    8000619a:	7282                	ld	t0,32(sp)
    8000619c:	7322                	ld	t1,40(sp)
    8000619e:	73c2                	ld	t2,48(sp)
    800061a0:	7462                	ld	s0,56(sp)
    800061a2:	6486                	ld	s1,64(sp)
    800061a4:	6526                	ld	a0,72(sp)
    800061a6:	65c6                	ld	a1,80(sp)
    800061a8:	6666                	ld	a2,88(sp)
    800061aa:	7686                	ld	a3,96(sp)
    800061ac:	7726                	ld	a4,104(sp)
    800061ae:	77c6                	ld	a5,112(sp)
    800061b0:	7866                	ld	a6,120(sp)
    800061b2:	688a                	ld	a7,128(sp)
    800061b4:	692a                	ld	s2,136(sp)
    800061b6:	69ca                	ld	s3,144(sp)
    800061b8:	6a6a                	ld	s4,152(sp)
    800061ba:	7a8a                	ld	s5,160(sp)
    800061bc:	7b2a                	ld	s6,168(sp)
    800061be:	7bca                	ld	s7,176(sp)
    800061c0:	7c6a                	ld	s8,184(sp)
    800061c2:	6c8e                	ld	s9,192(sp)
    800061c4:	6d2e                	ld	s10,200(sp)
    800061c6:	6dce                	ld	s11,208(sp)
    800061c8:	6e6e                	ld	t3,216(sp)
    800061ca:	7e8e                	ld	t4,224(sp)
    800061cc:	7f2e                	ld	t5,232(sp)
    800061ce:	7fce                	ld	t6,240(sp)
    800061d0:	6111                	addi	sp,sp,256
    800061d2:	10200073          	sret
    800061d6:	00000013          	nop
    800061da:	00000013          	nop
    800061de:	0001                	nop

00000000800061e0 <timervec>:
    800061e0:	34051573          	csrrw	a0,mscratch,a0
    800061e4:	e10c                	sd	a1,0(a0)
    800061e6:	e510                	sd	a2,8(a0)
    800061e8:	e914                	sd	a3,16(a0)
    800061ea:	6d0c                	ld	a1,24(a0)
    800061ec:	7110                	ld	a2,32(a0)
    800061ee:	6194                	ld	a3,0(a1)
    800061f0:	96b2                	add	a3,a3,a2
    800061f2:	e194                	sd	a3,0(a1)
    800061f4:	4589                	li	a1,2
    800061f6:	14459073          	csrw	sip,a1
    800061fa:	6914                	ld	a3,16(a0)
    800061fc:	6510                	ld	a2,8(a0)
    800061fe:	610c                	ld	a1,0(a0)
    80006200:	34051573          	csrrw	a0,mscratch,a0
    80006204:	30200073          	mret
	...

000000008000620a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000620a:	1141                	addi	sp,sp,-16
    8000620c:	e422                	sd	s0,8(sp)
    8000620e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006210:	0c0007b7          	lui	a5,0xc000
    80006214:	4705                	li	a4,1
    80006216:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006218:	c3d8                	sw	a4,4(a5)
}
    8000621a:	6422                	ld	s0,8(sp)
    8000621c:	0141                	addi	sp,sp,16
    8000621e:	8082                	ret

0000000080006220 <plicinithart>:

void
plicinithart(void)
{
    80006220:	1141                	addi	sp,sp,-16
    80006222:	e406                	sd	ra,8(sp)
    80006224:	e022                	sd	s0,0(sp)
    80006226:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006228:	ffffb097          	auipc	ra,0xffffb
    8000622c:	742080e7          	jalr	1858(ra) # 8000196a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006230:	0085171b          	slliw	a4,a0,0x8
    80006234:	0c0027b7          	lui	a5,0xc002
    80006238:	97ba                	add	a5,a5,a4
    8000623a:	40200713          	li	a4,1026
    8000623e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006242:	00d5151b          	slliw	a0,a0,0xd
    80006246:	0c2017b7          	lui	a5,0xc201
    8000624a:	953e                	add	a0,a0,a5
    8000624c:	00052023          	sw	zero,0(a0)
}
    80006250:	60a2                	ld	ra,8(sp)
    80006252:	6402                	ld	s0,0(sp)
    80006254:	0141                	addi	sp,sp,16
    80006256:	8082                	ret

0000000080006258 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006258:	1141                	addi	sp,sp,-16
    8000625a:	e406                	sd	ra,8(sp)
    8000625c:	e022                	sd	s0,0(sp)
    8000625e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006260:	ffffb097          	auipc	ra,0xffffb
    80006264:	70a080e7          	jalr	1802(ra) # 8000196a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006268:	00d5179b          	slliw	a5,a0,0xd
    8000626c:	0c201537          	lui	a0,0xc201
    80006270:	953e                	add	a0,a0,a5
  return irq;
}
    80006272:	4148                	lw	a0,4(a0)
    80006274:	60a2                	ld	ra,8(sp)
    80006276:	6402                	ld	s0,0(sp)
    80006278:	0141                	addi	sp,sp,16
    8000627a:	8082                	ret

000000008000627c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000627c:	1101                	addi	sp,sp,-32
    8000627e:	ec06                	sd	ra,24(sp)
    80006280:	e822                	sd	s0,16(sp)
    80006282:	e426                	sd	s1,8(sp)
    80006284:	1000                	addi	s0,sp,32
    80006286:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006288:	ffffb097          	auipc	ra,0xffffb
    8000628c:	6e2080e7          	jalr	1762(ra) # 8000196a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006290:	00d5151b          	slliw	a0,a0,0xd
    80006294:	0c2017b7          	lui	a5,0xc201
    80006298:	97aa                	add	a5,a5,a0
    8000629a:	c3c4                	sw	s1,4(a5)
}
    8000629c:	60e2                	ld	ra,24(sp)
    8000629e:	6442                	ld	s0,16(sp)
    800062a0:	64a2                	ld	s1,8(sp)
    800062a2:	6105                	addi	sp,sp,32
    800062a4:	8082                	ret

00000000800062a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800062a6:	1141                	addi	sp,sp,-16
    800062a8:	e406                	sd	ra,8(sp)
    800062aa:	e022                	sd	s0,0(sp)
    800062ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800062ae:	479d                	li	a5,7
    800062b0:	06a7c963          	blt	a5,a0,80006322 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800062b4:	0001d797          	auipc	a5,0x1d
    800062b8:	d4c78793          	addi	a5,a5,-692 # 80023000 <disk>
    800062bc:	00a78733          	add	a4,a5,a0
    800062c0:	6789                	lui	a5,0x2
    800062c2:	97ba                	add	a5,a5,a4
    800062c4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800062c8:	e7ad                	bnez	a5,80006332 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800062ca:	00451793          	slli	a5,a0,0x4
    800062ce:	0001f717          	auipc	a4,0x1f
    800062d2:	d3270713          	addi	a4,a4,-718 # 80025000 <disk+0x2000>
    800062d6:	6314                	ld	a3,0(a4)
    800062d8:	96be                	add	a3,a3,a5
    800062da:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800062de:	6314                	ld	a3,0(a4)
    800062e0:	96be                	add	a3,a3,a5
    800062e2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800062e6:	6314                	ld	a3,0(a4)
    800062e8:	96be                	add	a3,a3,a5
    800062ea:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800062ee:	6318                	ld	a4,0(a4)
    800062f0:	97ba                	add	a5,a5,a4
    800062f2:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800062f6:	0001d797          	auipc	a5,0x1d
    800062fa:	d0a78793          	addi	a5,a5,-758 # 80023000 <disk>
    800062fe:	97aa                	add	a5,a5,a0
    80006300:	6509                	lui	a0,0x2
    80006302:	953e                	add	a0,a0,a5
    80006304:	4785                	li	a5,1
    80006306:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000630a:	0001f517          	auipc	a0,0x1f
    8000630e:	d0e50513          	addi	a0,a0,-754 # 80025018 <disk+0x2018>
    80006312:	ffffc097          	auipc	ra,0xffffc
    80006316:	0c8080e7          	jalr	200(ra) # 800023da <wakeup>
}
    8000631a:	60a2                	ld	ra,8(sp)
    8000631c:	6402                	ld	s0,0(sp)
    8000631e:	0141                	addi	sp,sp,16
    80006320:	8082                	ret
    panic("free_desc 1");
    80006322:	00002517          	auipc	a0,0x2
    80006326:	63650513          	addi	a0,a0,1590 # 80008958 <syscall_names_table.0+0x330>
    8000632a:	ffffa097          	auipc	ra,0xffffa
    8000632e:	200080e7          	jalr	512(ra) # 8000052a <panic>
    panic("free_desc 2");
    80006332:	00002517          	auipc	a0,0x2
    80006336:	63650513          	addi	a0,a0,1590 # 80008968 <syscall_names_table.0+0x340>
    8000633a:	ffffa097          	auipc	ra,0xffffa
    8000633e:	1f0080e7          	jalr	496(ra) # 8000052a <panic>

0000000080006342 <virtio_disk_init>:
{
    80006342:	1101                	addi	sp,sp,-32
    80006344:	ec06                	sd	ra,24(sp)
    80006346:	e822                	sd	s0,16(sp)
    80006348:	e426                	sd	s1,8(sp)
    8000634a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000634c:	00002597          	auipc	a1,0x2
    80006350:	62c58593          	addi	a1,a1,1580 # 80008978 <syscall_names_table.0+0x350>
    80006354:	0001f517          	auipc	a0,0x1f
    80006358:	dd450513          	addi	a0,a0,-556 # 80025128 <disk+0x2128>
    8000635c:	ffffa097          	auipc	ra,0xffffa
    80006360:	7d6080e7          	jalr	2006(ra) # 80000b32 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006364:	100017b7          	lui	a5,0x10001
    80006368:	4398                	lw	a4,0(a5)
    8000636a:	2701                	sext.w	a4,a4
    8000636c:	747277b7          	lui	a5,0x74727
    80006370:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006374:	0ef71163          	bne	a4,a5,80006456 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006378:	100017b7          	lui	a5,0x10001
    8000637c:	43dc                	lw	a5,4(a5)
    8000637e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006380:	4705                	li	a4,1
    80006382:	0ce79a63          	bne	a5,a4,80006456 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006386:	100017b7          	lui	a5,0x10001
    8000638a:	479c                	lw	a5,8(a5)
    8000638c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000638e:	4709                	li	a4,2
    80006390:	0ce79363          	bne	a5,a4,80006456 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006394:	100017b7          	lui	a5,0x10001
    80006398:	47d8                	lw	a4,12(a5)
    8000639a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000639c:	554d47b7          	lui	a5,0x554d4
    800063a0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800063a4:	0af71963          	bne	a4,a5,80006456 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800063a8:	100017b7          	lui	a5,0x10001
    800063ac:	4705                	li	a4,1
    800063ae:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063b0:	470d                	li	a4,3
    800063b2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800063b4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800063b6:	c7ffe737          	lui	a4,0xc7ffe
    800063ba:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    800063be:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800063c0:	2701                	sext.w	a4,a4
    800063c2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063c4:	472d                	li	a4,11
    800063c6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800063c8:	473d                	li	a4,15
    800063ca:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800063cc:	6705                	lui	a4,0x1
    800063ce:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800063d0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800063d4:	5bdc                	lw	a5,52(a5)
    800063d6:	2781                	sext.w	a5,a5
  if(max == 0)
    800063d8:	c7d9                	beqz	a5,80006466 <virtio_disk_init+0x124>
  if(max < NUM)
    800063da:	471d                	li	a4,7
    800063dc:	08f77d63          	bgeu	a4,a5,80006476 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063e0:	100014b7          	lui	s1,0x10001
    800063e4:	47a1                	li	a5,8
    800063e6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800063e8:	6609                	lui	a2,0x2
    800063ea:	4581                	li	a1,0
    800063ec:	0001d517          	auipc	a0,0x1d
    800063f0:	c1450513          	addi	a0,a0,-1004 # 80023000 <disk>
    800063f4:	ffffb097          	auipc	ra,0xffffb
    800063f8:	8ca080e7          	jalr	-1846(ra) # 80000cbe <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800063fc:	0001d717          	auipc	a4,0x1d
    80006400:	c0470713          	addi	a4,a4,-1020 # 80023000 <disk>
    80006404:	00c75793          	srli	a5,a4,0xc
    80006408:	2781                	sext.w	a5,a5
    8000640a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000640c:	0001f797          	auipc	a5,0x1f
    80006410:	bf478793          	addi	a5,a5,-1036 # 80025000 <disk+0x2000>
    80006414:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006416:	0001d717          	auipc	a4,0x1d
    8000641a:	c6a70713          	addi	a4,a4,-918 # 80023080 <disk+0x80>
    8000641e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006420:	0001e717          	auipc	a4,0x1e
    80006424:	be070713          	addi	a4,a4,-1056 # 80024000 <disk+0x1000>
    80006428:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000642a:	4705                	li	a4,1
    8000642c:	00e78c23          	sb	a4,24(a5)
    80006430:	00e78ca3          	sb	a4,25(a5)
    80006434:	00e78d23          	sb	a4,26(a5)
    80006438:	00e78da3          	sb	a4,27(a5)
    8000643c:	00e78e23          	sb	a4,28(a5)
    80006440:	00e78ea3          	sb	a4,29(a5)
    80006444:	00e78f23          	sb	a4,30(a5)
    80006448:	00e78fa3          	sb	a4,31(a5)
}
    8000644c:	60e2                	ld	ra,24(sp)
    8000644e:	6442                	ld	s0,16(sp)
    80006450:	64a2                	ld	s1,8(sp)
    80006452:	6105                	addi	sp,sp,32
    80006454:	8082                	ret
    panic("could not find virtio disk");
    80006456:	00002517          	auipc	a0,0x2
    8000645a:	53250513          	addi	a0,a0,1330 # 80008988 <syscall_names_table.0+0x360>
    8000645e:	ffffa097          	auipc	ra,0xffffa
    80006462:	0cc080e7          	jalr	204(ra) # 8000052a <panic>
    panic("virtio disk has no queue 0");
    80006466:	00002517          	auipc	a0,0x2
    8000646a:	54250513          	addi	a0,a0,1346 # 800089a8 <syscall_names_table.0+0x380>
    8000646e:	ffffa097          	auipc	ra,0xffffa
    80006472:	0bc080e7          	jalr	188(ra) # 8000052a <panic>
    panic("virtio disk max queue too short");
    80006476:	00002517          	auipc	a0,0x2
    8000647a:	55250513          	addi	a0,a0,1362 # 800089c8 <syscall_names_table.0+0x3a0>
    8000647e:	ffffa097          	auipc	ra,0xffffa
    80006482:	0ac080e7          	jalr	172(ra) # 8000052a <panic>

0000000080006486 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006486:	7119                	addi	sp,sp,-128
    80006488:	fc86                	sd	ra,120(sp)
    8000648a:	f8a2                	sd	s0,112(sp)
    8000648c:	f4a6                	sd	s1,104(sp)
    8000648e:	f0ca                	sd	s2,96(sp)
    80006490:	ecce                	sd	s3,88(sp)
    80006492:	e8d2                	sd	s4,80(sp)
    80006494:	e4d6                	sd	s5,72(sp)
    80006496:	e0da                	sd	s6,64(sp)
    80006498:	fc5e                	sd	s7,56(sp)
    8000649a:	f862                	sd	s8,48(sp)
    8000649c:	f466                	sd	s9,40(sp)
    8000649e:	f06a                	sd	s10,32(sp)
    800064a0:	ec6e                	sd	s11,24(sp)
    800064a2:	0100                	addi	s0,sp,128
    800064a4:	8aaa                	mv	s5,a0
    800064a6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800064a8:	00c52c83          	lw	s9,12(a0)
    800064ac:	001c9c9b          	slliw	s9,s9,0x1
    800064b0:	1c82                	slli	s9,s9,0x20
    800064b2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800064b6:	0001f517          	auipc	a0,0x1f
    800064ba:	c7250513          	addi	a0,a0,-910 # 80025128 <disk+0x2128>
    800064be:	ffffa097          	auipc	ra,0xffffa
    800064c2:	704080e7          	jalr	1796(ra) # 80000bc2 <acquire>
  for(int i = 0; i < 3; i++){
    800064c6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064c8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064ca:	0001dc17          	auipc	s8,0x1d
    800064ce:	b36c0c13          	addi	s8,s8,-1226 # 80023000 <disk>
    800064d2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800064d4:	4b0d                	li	s6,3
    800064d6:	a0ad                	j	80006540 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800064d8:	00fc0733          	add	a4,s8,a5
    800064dc:	975e                	add	a4,a4,s7
    800064de:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064e2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064e4:	0207c563          	bltz	a5,8000650e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800064e8:	2905                	addiw	s2,s2,1
    800064ea:	0611                	addi	a2,a2,4
    800064ec:	19690d63          	beq	s2,s6,80006686 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    800064f0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064f2:	0001f717          	auipc	a4,0x1f
    800064f6:	b2670713          	addi	a4,a4,-1242 # 80025018 <disk+0x2018>
    800064fa:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064fc:	00074683          	lbu	a3,0(a4)
    80006500:	fee1                	bnez	a3,800064d8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006502:	2785                	addiw	a5,a5,1
    80006504:	0705                	addi	a4,a4,1
    80006506:	fe979be3          	bne	a5,s1,800064fc <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000650a:	57fd                	li	a5,-1
    8000650c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000650e:	01205d63          	blez	s2,80006528 <virtio_disk_rw+0xa2>
    80006512:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006514:	000a2503          	lw	a0,0(s4)
    80006518:	00000097          	auipc	ra,0x0
    8000651c:	d8e080e7          	jalr	-626(ra) # 800062a6 <free_desc>
      for(int j = 0; j < i; j++)
    80006520:	2d85                	addiw	s11,s11,1
    80006522:	0a11                	addi	s4,s4,4
    80006524:	ffb918e3          	bne	s2,s11,80006514 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006528:	0001f597          	auipc	a1,0x1f
    8000652c:	c0058593          	addi	a1,a1,-1024 # 80025128 <disk+0x2128>
    80006530:	0001f517          	auipc	a0,0x1f
    80006534:	ae850513          	addi	a0,a0,-1304 # 80025018 <disk+0x2018>
    80006538:	ffffc097          	auipc	ra,0xffffc
    8000653c:	d16080e7          	jalr	-746(ra) # 8000224e <sleep>
  for(int i = 0; i < 3; i++){
    80006540:	f8040a13          	addi	s4,s0,-128
{
    80006544:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006546:	894e                	mv	s2,s3
    80006548:	b765                	j	800064f0 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000654a:	0001f697          	auipc	a3,0x1f
    8000654e:	ab66b683          	ld	a3,-1354(a3) # 80025000 <disk+0x2000>
    80006552:	96ba                	add	a3,a3,a4
    80006554:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006558:	0001d817          	auipc	a6,0x1d
    8000655c:	aa880813          	addi	a6,a6,-1368 # 80023000 <disk>
    80006560:	0001f697          	auipc	a3,0x1f
    80006564:	aa068693          	addi	a3,a3,-1376 # 80025000 <disk+0x2000>
    80006568:	6290                	ld	a2,0(a3)
    8000656a:	963a                	add	a2,a2,a4
    8000656c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006570:	0015e593          	ori	a1,a1,1
    80006574:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006578:	f8842603          	lw	a2,-120(s0)
    8000657c:	628c                	ld	a1,0(a3)
    8000657e:	972e                	add	a4,a4,a1
    80006580:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006584:	20050593          	addi	a1,a0,512
    80006588:	0592                	slli	a1,a1,0x4
    8000658a:	95c2                	add	a1,a1,a6
    8000658c:	577d                	li	a4,-1
    8000658e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006592:	00461713          	slli	a4,a2,0x4
    80006596:	6290                	ld	a2,0(a3)
    80006598:	963a                	add	a2,a2,a4
    8000659a:	03078793          	addi	a5,a5,48
    8000659e:	97c2                	add	a5,a5,a6
    800065a0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800065a2:	629c                	ld	a5,0(a3)
    800065a4:	97ba                	add	a5,a5,a4
    800065a6:	4605                	li	a2,1
    800065a8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065aa:	629c                	ld	a5,0(a3)
    800065ac:	97ba                	add	a5,a5,a4
    800065ae:	4809                	li	a6,2
    800065b0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800065b4:	629c                	ld	a5,0(a3)
    800065b6:	973e                	add	a4,a4,a5
    800065b8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065bc:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065c0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065c4:	6698                	ld	a4,8(a3)
    800065c6:	00275783          	lhu	a5,2(a4)
    800065ca:	8b9d                	andi	a5,a5,7
    800065cc:	0786                	slli	a5,a5,0x1
    800065ce:	97ba                	add	a5,a5,a4
    800065d0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800065d4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065d8:	6698                	ld	a4,8(a3)
    800065da:	00275783          	lhu	a5,2(a4)
    800065de:	2785                	addiw	a5,a5,1
    800065e0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065e4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065e8:	100017b7          	lui	a5,0x10001
    800065ec:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065f0:	004aa783          	lw	a5,4(s5)
    800065f4:	02c79163          	bne	a5,a2,80006616 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800065f8:	0001f917          	auipc	s2,0x1f
    800065fc:	b3090913          	addi	s2,s2,-1232 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006600:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006602:	85ca                	mv	a1,s2
    80006604:	8556                	mv	a0,s5
    80006606:	ffffc097          	auipc	ra,0xffffc
    8000660a:	c48080e7          	jalr	-952(ra) # 8000224e <sleep>
  while(b->disk == 1) {
    8000660e:	004aa783          	lw	a5,4(s5)
    80006612:	fe9788e3          	beq	a5,s1,80006602 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006616:	f8042903          	lw	s2,-128(s0)
    8000661a:	20090793          	addi	a5,s2,512
    8000661e:	00479713          	slli	a4,a5,0x4
    80006622:	0001d797          	auipc	a5,0x1d
    80006626:	9de78793          	addi	a5,a5,-1570 # 80023000 <disk>
    8000662a:	97ba                	add	a5,a5,a4
    8000662c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006630:	0001f997          	auipc	s3,0x1f
    80006634:	9d098993          	addi	s3,s3,-1584 # 80025000 <disk+0x2000>
    80006638:	00491713          	slli	a4,s2,0x4
    8000663c:	0009b783          	ld	a5,0(s3)
    80006640:	97ba                	add	a5,a5,a4
    80006642:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006646:	854a                	mv	a0,s2
    80006648:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000664c:	00000097          	auipc	ra,0x0
    80006650:	c5a080e7          	jalr	-934(ra) # 800062a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006654:	8885                	andi	s1,s1,1
    80006656:	f0ed                	bnez	s1,80006638 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006658:	0001f517          	auipc	a0,0x1f
    8000665c:	ad050513          	addi	a0,a0,-1328 # 80025128 <disk+0x2128>
    80006660:	ffffa097          	auipc	ra,0xffffa
    80006664:	616080e7          	jalr	1558(ra) # 80000c76 <release>
}
    80006668:	70e6                	ld	ra,120(sp)
    8000666a:	7446                	ld	s0,112(sp)
    8000666c:	74a6                	ld	s1,104(sp)
    8000666e:	7906                	ld	s2,96(sp)
    80006670:	69e6                	ld	s3,88(sp)
    80006672:	6a46                	ld	s4,80(sp)
    80006674:	6aa6                	ld	s5,72(sp)
    80006676:	6b06                	ld	s6,64(sp)
    80006678:	7be2                	ld	s7,56(sp)
    8000667a:	7c42                	ld	s8,48(sp)
    8000667c:	7ca2                	ld	s9,40(sp)
    8000667e:	7d02                	ld	s10,32(sp)
    80006680:	6de2                	ld	s11,24(sp)
    80006682:	6109                	addi	sp,sp,128
    80006684:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006686:	f8042503          	lw	a0,-128(s0)
    8000668a:	20050793          	addi	a5,a0,512
    8000668e:	0792                	slli	a5,a5,0x4
  if(write)
    80006690:	0001d817          	auipc	a6,0x1d
    80006694:	97080813          	addi	a6,a6,-1680 # 80023000 <disk>
    80006698:	00f80733          	add	a4,a6,a5
    8000669c:	01a036b3          	snez	a3,s10
    800066a0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800066a4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800066a8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066ac:	7679                	lui	a2,0xffffe
    800066ae:	963e                	add	a2,a2,a5
    800066b0:	0001f697          	auipc	a3,0x1f
    800066b4:	95068693          	addi	a3,a3,-1712 # 80025000 <disk+0x2000>
    800066b8:	6298                	ld	a4,0(a3)
    800066ba:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800066bc:	0a878593          	addi	a1,a5,168
    800066c0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800066c2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800066c4:	6298                	ld	a4,0(a3)
    800066c6:	9732                	add	a4,a4,a2
    800066c8:	45c1                	li	a1,16
    800066ca:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800066cc:	6298                	ld	a4,0(a3)
    800066ce:	9732                	add	a4,a4,a2
    800066d0:	4585                	li	a1,1
    800066d2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800066d6:	f8442703          	lw	a4,-124(s0)
    800066da:	628c                	ld	a1,0(a3)
    800066dc:	962e                	add	a2,a2,a1
    800066de:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800066e2:	0712                	slli	a4,a4,0x4
    800066e4:	6290                	ld	a2,0(a3)
    800066e6:	963a                	add	a2,a2,a4
    800066e8:	058a8593          	addi	a1,s5,88
    800066ec:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800066ee:	6294                	ld	a3,0(a3)
    800066f0:	96ba                	add	a3,a3,a4
    800066f2:	40000613          	li	a2,1024
    800066f6:	c690                	sw	a2,8(a3)
  if(write)
    800066f8:	e40d19e3          	bnez	s10,8000654a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800066fc:	0001f697          	auipc	a3,0x1f
    80006700:	9046b683          	ld	a3,-1788(a3) # 80025000 <disk+0x2000>
    80006704:	96ba                	add	a3,a3,a4
    80006706:	4609                	li	a2,2
    80006708:	00c69623          	sh	a2,12(a3)
    8000670c:	b5b1                	j	80006558 <virtio_disk_rw+0xd2>

000000008000670e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000670e:	1101                	addi	sp,sp,-32
    80006710:	ec06                	sd	ra,24(sp)
    80006712:	e822                	sd	s0,16(sp)
    80006714:	e426                	sd	s1,8(sp)
    80006716:	e04a                	sd	s2,0(sp)
    80006718:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000671a:	0001f517          	auipc	a0,0x1f
    8000671e:	a0e50513          	addi	a0,a0,-1522 # 80025128 <disk+0x2128>
    80006722:	ffffa097          	auipc	ra,0xffffa
    80006726:	4a0080e7          	jalr	1184(ra) # 80000bc2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000672a:	10001737          	lui	a4,0x10001
    8000672e:	533c                	lw	a5,96(a4)
    80006730:	8b8d                	andi	a5,a5,3
    80006732:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006734:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006738:	0001f797          	auipc	a5,0x1f
    8000673c:	8c878793          	addi	a5,a5,-1848 # 80025000 <disk+0x2000>
    80006740:	6b94                	ld	a3,16(a5)
    80006742:	0207d703          	lhu	a4,32(a5)
    80006746:	0026d783          	lhu	a5,2(a3)
    8000674a:	06f70163          	beq	a4,a5,800067ac <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000674e:	0001d917          	auipc	s2,0x1d
    80006752:	8b290913          	addi	s2,s2,-1870 # 80023000 <disk>
    80006756:	0001f497          	auipc	s1,0x1f
    8000675a:	8aa48493          	addi	s1,s1,-1878 # 80025000 <disk+0x2000>
    __sync_synchronize();
    8000675e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006762:	6898                	ld	a4,16(s1)
    80006764:	0204d783          	lhu	a5,32(s1)
    80006768:	8b9d                	andi	a5,a5,7
    8000676a:	078e                	slli	a5,a5,0x3
    8000676c:	97ba                	add	a5,a5,a4
    8000676e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006770:	20078713          	addi	a4,a5,512
    80006774:	0712                	slli	a4,a4,0x4
    80006776:	974a                	add	a4,a4,s2
    80006778:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000677c:	e731                	bnez	a4,800067c8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000677e:	20078793          	addi	a5,a5,512
    80006782:	0792                	slli	a5,a5,0x4
    80006784:	97ca                	add	a5,a5,s2
    80006786:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006788:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000678c:	ffffc097          	auipc	ra,0xffffc
    80006790:	c4e080e7          	jalr	-946(ra) # 800023da <wakeup>

    disk.used_idx += 1;
    80006794:	0204d783          	lhu	a5,32(s1)
    80006798:	2785                	addiw	a5,a5,1
    8000679a:	17c2                	slli	a5,a5,0x30
    8000679c:	93c1                	srli	a5,a5,0x30
    8000679e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800067a2:	6898                	ld	a4,16(s1)
    800067a4:	00275703          	lhu	a4,2(a4)
    800067a8:	faf71be3          	bne	a4,a5,8000675e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800067ac:	0001f517          	auipc	a0,0x1f
    800067b0:	97c50513          	addi	a0,a0,-1668 # 80025128 <disk+0x2128>
    800067b4:	ffffa097          	auipc	ra,0xffffa
    800067b8:	4c2080e7          	jalr	1218(ra) # 80000c76 <release>
}
    800067bc:	60e2                	ld	ra,24(sp)
    800067be:	6442                	ld	s0,16(sp)
    800067c0:	64a2                	ld	s1,8(sp)
    800067c2:	6902                	ld	s2,0(sp)
    800067c4:	6105                	addi	sp,sp,32
    800067c6:	8082                	ret
      panic("virtio_disk_intr status");
    800067c8:	00002517          	auipc	a0,0x2
    800067cc:	22050513          	addi	a0,a0,544 # 800089e8 <syscall_names_table.0+0x3c0>
    800067d0:	ffffa097          	auipc	ra,0xffffa
    800067d4:	d5a080e7          	jalr	-678(ra) # 8000052a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
