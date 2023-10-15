
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fe250513          	addi	a0,a0,-30 # ffffffffc0206018 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	58260613          	addi	a2,a2,1410 # ffffffffc02065c0 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	171010ef          	jal	ra,ffffffffc02019be <memset>
    cons_init();  // init the console
ffffffffc0200052:	3fe000ef          	jal	ra,ffffffffc0200450 <cons_init>
    const char *message = "(THU.NKU) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	97a50513          	addi	a0,a0,-1670 # ffffffffc02019d0 <etext>
ffffffffc020005e:	090000ef          	jal	ra,ffffffffc02000ee <cputs>

    print_kerninfo();
ffffffffc0200062:	0dc000ef          	jal	ra,ffffffffc020013e <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	404000ef          	jal	ra,ffffffffc020046a <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	22c010ef          	jal	ra,ffffffffc0201296 <pmm_init>
    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3fc000ef          	jal	ra,ffffffffc020046a <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	39a000ef          	jal	ra,ffffffffc020040c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e8000ef          	jal	ra,ffffffffc020045e <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3ce000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	406010ef          	jal	ra,ffffffffc02014b0 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	3d2010ef          	jal	ra,ffffffffc02014b0 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	3680006f          	j	ffffffffc0200452 <cons_putc>

ffffffffc02000ee <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ee:	1101                	addi	sp,sp,-32
ffffffffc02000f0:	e822                	sd	s0,16(sp)
ffffffffc02000f2:	ec06                	sd	ra,24(sp)
ffffffffc02000f4:	e426                	sd	s1,8(sp)
ffffffffc02000f6:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f8:	00054503          	lbu	a0,0(a0)
ffffffffc02000fc:	c51d                	beqz	a0,ffffffffc020012a <cputs+0x3c>
ffffffffc02000fe:	0405                	addi	s0,s0,1
ffffffffc0200100:	4485                	li	s1,1
ffffffffc0200102:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200104:	34e000ef          	jal	ra,ffffffffc0200452 <cons_putc>
    (*cnt) ++;
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200112:	f96d                	bnez	a0,ffffffffc0200104 <cputs+0x16>
ffffffffc0200114:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200118:	4529                	li	a0,10
ffffffffc020011a:	338000ef          	jal	ra,ffffffffc0200452 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011e:	8522                	mv	a0,s0
ffffffffc0200120:	60e2                	ld	ra,24(sp)
ffffffffc0200122:	6442                	ld	s0,16(sp)
ffffffffc0200124:	64a2                	ld	s1,8(sp)
ffffffffc0200126:	6105                	addi	sp,sp,32
ffffffffc0200128:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012a:	4405                	li	s0,1
ffffffffc020012c:	b7f5                	j	ffffffffc0200118 <cputs+0x2a>

ffffffffc020012e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012e:	1141                	addi	sp,sp,-16
ffffffffc0200130:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200132:	328000ef          	jal	ra,ffffffffc020045a <cons_getc>
ffffffffc0200136:	dd75                	beqz	a0,ffffffffc0200132 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200138:	60a2                	ld	ra,8(sp)
ffffffffc020013a:	0141                	addi	sp,sp,16
ffffffffc020013c:	8082                	ret

ffffffffc020013e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200140:	00002517          	auipc	a0,0x2
ffffffffc0200144:	8e050513          	addi	a0,a0,-1824 # ffffffffc0201a20 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200148:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014a:	f6dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014e:	00000597          	auipc	a1,0x0
ffffffffc0200152:	ee858593          	addi	a1,a1,-280 # ffffffffc0200036 <kern_init>
ffffffffc0200156:	00002517          	auipc	a0,0x2
ffffffffc020015a:	8ea50513          	addi	a0,a0,-1814 # ffffffffc0201a40 <etext+0x70>
ffffffffc020015e:	f59ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200162:	00002597          	auipc	a1,0x2
ffffffffc0200166:	86e58593          	addi	a1,a1,-1938 # ffffffffc02019d0 <etext>
ffffffffc020016a:	00002517          	auipc	a0,0x2
ffffffffc020016e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201a60 <etext+0x90>
ffffffffc0200172:	f45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200176:	00006597          	auipc	a1,0x6
ffffffffc020017a:	ea258593          	addi	a1,a1,-350 # ffffffffc0206018 <edata>
ffffffffc020017e:	00002517          	auipc	a0,0x2
ffffffffc0200182:	90250513          	addi	a0,a0,-1790 # ffffffffc0201a80 <etext+0xb0>
ffffffffc0200186:	f31ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018a:	00006597          	auipc	a1,0x6
ffffffffc020018e:	43658593          	addi	a1,a1,1078 # ffffffffc02065c0 <end>
ffffffffc0200192:	00002517          	auipc	a0,0x2
ffffffffc0200196:	90e50513          	addi	a0,a0,-1778 # ffffffffc0201aa0 <etext+0xd0>
ffffffffc020019a:	f1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019e:	00007597          	auipc	a1,0x7
ffffffffc02001a2:	82158593          	addi	a1,a1,-2015 # ffffffffc02069bf <end+0x3ff>
ffffffffc02001a6:	00000797          	auipc	a5,0x0
ffffffffc02001aa:	e9078793          	addi	a5,a5,-368 # ffffffffc0200036 <kern_init>
ffffffffc02001ae:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b2:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b6:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b8:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001bc:	95be                	add	a1,a1,a5
ffffffffc02001be:	85a9                	srai	a1,a1,0xa
ffffffffc02001c0:	00002517          	auipc	a0,0x2
ffffffffc02001c4:	90050513          	addi	a0,a0,-1792 # ffffffffc0201ac0 <etext+0xf0>
}
ffffffffc02001c8:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ca:	eedff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ce <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ce:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d0:	00002617          	auipc	a2,0x2
ffffffffc02001d4:	82060613          	addi	a2,a2,-2016 # ffffffffc02019f0 <etext+0x20>
ffffffffc02001d8:	04e00593          	li	a1,78
ffffffffc02001dc:	00002517          	auipc	a0,0x2
ffffffffc02001e0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0201a08 <etext+0x38>
void print_stackframe(void) {
ffffffffc02001e4:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e6:	1c6000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001ea <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ea:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ec:	00002617          	auipc	a2,0x2
ffffffffc02001f0:	9e460613          	addi	a2,a2,-1564 # ffffffffc0201bd0 <commands+0xe0>
ffffffffc02001f4:	00002597          	auipc	a1,0x2
ffffffffc02001f8:	9fc58593          	addi	a1,a1,-1540 # ffffffffc0201bf0 <commands+0x100>
ffffffffc02001fc:	00002517          	auipc	a0,0x2
ffffffffc0200200:	9fc50513          	addi	a0,a0,-1540 # ffffffffc0201bf8 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200204:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200206:	eb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020020a:	00002617          	auipc	a2,0x2
ffffffffc020020e:	9fe60613          	addi	a2,a2,-1538 # ffffffffc0201c08 <commands+0x118>
ffffffffc0200212:	00002597          	auipc	a1,0x2
ffffffffc0200216:	a1e58593          	addi	a1,a1,-1506 # ffffffffc0201c30 <commands+0x140>
ffffffffc020021a:	00002517          	auipc	a0,0x2
ffffffffc020021e:	9de50513          	addi	a0,a0,-1570 # ffffffffc0201bf8 <commands+0x108>
ffffffffc0200222:	e95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200226:	00002617          	auipc	a2,0x2
ffffffffc020022a:	a1a60613          	addi	a2,a2,-1510 # ffffffffc0201c40 <commands+0x150>
ffffffffc020022e:	00002597          	auipc	a1,0x2
ffffffffc0200232:	a3258593          	addi	a1,a1,-1486 # ffffffffc0201c60 <commands+0x170>
ffffffffc0200236:	00002517          	auipc	a0,0x2
ffffffffc020023a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0201bf8 <commands+0x108>
ffffffffc020023e:	e79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc0200242:	60a2                	ld	ra,8(sp)
ffffffffc0200244:	4501                	li	a0,0
ffffffffc0200246:	0141                	addi	sp,sp,16
ffffffffc0200248:	8082                	ret

ffffffffc020024a <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024a:	1141                	addi	sp,sp,-16
ffffffffc020024c:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024e:	ef1ff0ef          	jal	ra,ffffffffc020013e <print_kerninfo>
    return 0;
}
ffffffffc0200252:	60a2                	ld	ra,8(sp)
ffffffffc0200254:	4501                	li	a0,0
ffffffffc0200256:	0141                	addi	sp,sp,16
ffffffffc0200258:	8082                	ret

ffffffffc020025a <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025a:	1141                	addi	sp,sp,-16
ffffffffc020025c:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025e:	f71ff0ef          	jal	ra,ffffffffc02001ce <print_stackframe>
    return 0;
}
ffffffffc0200262:	60a2                	ld	ra,8(sp)
ffffffffc0200264:	4501                	li	a0,0
ffffffffc0200266:	0141                	addi	sp,sp,16
ffffffffc0200268:	8082                	ret

ffffffffc020026a <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026a:	7115                	addi	sp,sp,-224
ffffffffc020026c:	e962                	sd	s8,144(sp)
ffffffffc020026e:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200270:	00002517          	auipc	a0,0x2
ffffffffc0200274:	8c850513          	addi	a0,a0,-1848 # ffffffffc0201b38 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200278:	ed86                	sd	ra,216(sp)
ffffffffc020027a:	e9a2                	sd	s0,208(sp)
ffffffffc020027c:	e5a6                	sd	s1,200(sp)
ffffffffc020027e:	e1ca                	sd	s2,192(sp)
ffffffffc0200280:	fd4e                	sd	s3,184(sp)
ffffffffc0200282:	f952                	sd	s4,176(sp)
ffffffffc0200284:	f556                	sd	s5,168(sp)
ffffffffc0200286:	f15a                	sd	s6,160(sp)
ffffffffc0200288:	ed5e                	sd	s7,152(sp)
ffffffffc020028a:	e566                	sd	s9,136(sp)
ffffffffc020028c:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028e:	e29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200292:	00002517          	auipc	a0,0x2
ffffffffc0200296:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0201b60 <commands+0x70>
ffffffffc020029a:	e1dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029e:	000c0563          	beqz	s8,ffffffffc02002a8 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a2:	8562                	mv	a0,s8
ffffffffc02002a4:	3a6000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002a8:	00002c97          	auipc	s9,0x2
ffffffffc02002ac:	848c8c93          	addi	s9,s9,-1976 # ffffffffc0201af0 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b0:	00002997          	auipc	s3,0x2
ffffffffc02002b4:	8d898993          	addi	s3,s3,-1832 # ffffffffc0201b88 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b8:	00002917          	auipc	s2,0x2
ffffffffc02002bc:	8d890913          	addi	s2,s2,-1832 # ffffffffc0201b90 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002c0:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c2:	00002b17          	auipc	s6,0x2
ffffffffc02002c6:	8d6b0b13          	addi	s6,s6,-1834 # ffffffffc0201b98 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002ca:	00002a97          	auipc	s5,0x2
ffffffffc02002ce:	926a8a93          	addi	s5,s5,-1754 # ffffffffc0201bf0 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d2:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d4:	854e                	mv	a0,s3
ffffffffc02002d6:	566010ef          	jal	ra,ffffffffc020183c <readline>
ffffffffc02002da:	842a                	mv	s0,a0
ffffffffc02002dc:	dd65                	beqz	a0,ffffffffc02002d4 <kmonitor+0x6a>
ffffffffc02002de:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e4:	c999                	beqz	a1,ffffffffc02002fa <kmonitor+0x90>
ffffffffc02002e6:	854a                	mv	a0,s2
ffffffffc02002e8:	6b8010ef          	jal	ra,ffffffffc02019a0 <strchr>
ffffffffc02002ec:	c925                	beqz	a0,ffffffffc020035c <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ee:	00144583          	lbu	a1,1(s0)
ffffffffc02002f2:	00040023          	sb	zero,0(s0)
ffffffffc02002f6:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f8:	f5fd                	bnez	a1,ffffffffc02002e6 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002fa:	dce9                	beqz	s1,ffffffffc02002d4 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	6582                	ld	a1,0(sp)
ffffffffc02002fe:	00001d17          	auipc	s10,0x1
ffffffffc0200302:	7f2d0d13          	addi	s10,s10,2034 # ffffffffc0201af0 <commands>
    if (argc == 0) {
ffffffffc0200306:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200308:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020030a:	0d61                	addi	s10,s10,24
ffffffffc020030c:	66a010ef          	jal	ra,ffffffffc0201976 <strcmp>
ffffffffc0200310:	c919                	beqz	a0,ffffffffc0200326 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	09740463          	beq	s0,s7,ffffffffc020039c <kmonitor+0x132>
ffffffffc0200318:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020031c:	6582                	ld	a1,0(sp)
ffffffffc020031e:	0d61                	addi	s10,s10,24
ffffffffc0200320:	656010ef          	jal	ra,ffffffffc0201976 <strcmp>
ffffffffc0200324:	f57d                	bnez	a0,ffffffffc0200312 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200326:	00141793          	slli	a5,s0,0x1
ffffffffc020032a:	97a2                	add	a5,a5,s0
ffffffffc020032c:	078e                	slli	a5,a5,0x3
ffffffffc020032e:	97e6                	add	a5,a5,s9
ffffffffc0200330:	6b9c                	ld	a5,16(a5)
ffffffffc0200332:	8662                	mv	a2,s8
ffffffffc0200334:	002c                	addi	a1,sp,8
ffffffffc0200336:	fff4851b          	addiw	a0,s1,-1
ffffffffc020033a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020033c:	f8055ce3          	bgez	a0,ffffffffc02002d4 <kmonitor+0x6a>
}
ffffffffc0200340:	60ee                	ld	ra,216(sp)
ffffffffc0200342:	644e                	ld	s0,208(sp)
ffffffffc0200344:	64ae                	ld	s1,200(sp)
ffffffffc0200346:	690e                	ld	s2,192(sp)
ffffffffc0200348:	79ea                	ld	s3,184(sp)
ffffffffc020034a:	7a4a                	ld	s4,176(sp)
ffffffffc020034c:	7aaa                	ld	s5,168(sp)
ffffffffc020034e:	7b0a                	ld	s6,160(sp)
ffffffffc0200350:	6bea                	ld	s7,152(sp)
ffffffffc0200352:	6c4a                	ld	s8,144(sp)
ffffffffc0200354:	6caa                	ld	s9,136(sp)
ffffffffc0200356:	6d0a                	ld	s10,128(sp)
ffffffffc0200358:	612d                	addi	sp,sp,224
ffffffffc020035a:	8082                	ret
        if (*buf == '\0') {
ffffffffc020035c:	00044783          	lbu	a5,0(s0)
ffffffffc0200360:	dfc9                	beqz	a5,ffffffffc02002fa <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200362:	03448863          	beq	s1,s4,ffffffffc0200392 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200366:	00349793          	slli	a5,s1,0x3
ffffffffc020036a:	0118                	addi	a4,sp,128
ffffffffc020036c:	97ba                	add	a5,a5,a4
ffffffffc020036e:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200372:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200376:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	e591                	bnez	a1,ffffffffc0200384 <kmonitor+0x11a>
ffffffffc020037a:	b749                	j	ffffffffc02002fc <kmonitor+0x92>
            buf ++;
ffffffffc020037c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	00044583          	lbu	a1,0(s0)
ffffffffc0200382:	ddad                	beqz	a1,ffffffffc02002fc <kmonitor+0x92>
ffffffffc0200384:	854a                	mv	a0,s2
ffffffffc0200386:	61a010ef          	jal	ra,ffffffffc02019a0 <strchr>
ffffffffc020038a:	d96d                	beqz	a0,ffffffffc020037c <kmonitor+0x112>
ffffffffc020038c:	00044583          	lbu	a1,0(s0)
ffffffffc0200390:	bf91                	j	ffffffffc02002e4 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc020039a:	b7f1                	j	ffffffffc0200366 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00002517          	auipc	a0,0x2
ffffffffc02003a2:	81a50513          	addi	a0,a0,-2022 # ffffffffc0201bb8 <commands+0xc8>
ffffffffc02003a6:	d11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003aa:	b72d                	j	ffffffffc02002d4 <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	06c30313          	addi	t1,t1,108 # ffffffffc0206418 <is_panic>
ffffffffc02003b4:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	02031c63          	bnez	t1,ffffffffc0200400 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	8432                	mv	s0,a2
ffffffffc02003d0:	00006717          	auipc	a4,0x6
ffffffffc02003d4:	04f72423          	sw	a5,72(a4) # ffffffffc0206418 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003dc:	85aa                	mv	a1,a0
ffffffffc02003de:	00002517          	auipc	a0,0x2
ffffffffc02003e2:	89250513          	addi	a0,a0,-1902 # ffffffffc0201c70 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e6:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e8:	ccfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003ec:	65a2                	ld	a1,8(sp)
ffffffffc02003ee:	8522                	mv	a0,s0
ffffffffc02003f0:	ca7ff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f4:	00002517          	auipc	a0,0x2
ffffffffc02003f8:	24450513          	addi	a0,a0,580 # ffffffffc0202638 <commands+0xb48>
ffffffffc02003fc:	cbbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200400:	064000ef          	jal	ra,ffffffffc0200464 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200404:	4501                	li	a0,0
ffffffffc0200406:	e65ff0ef          	jal	ra,ffffffffc020026a <kmonitor>
ffffffffc020040a:	bfed                	j	ffffffffc0200404 <__panic+0x58>

ffffffffc020040c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020040c:	1141                	addi	sp,sp,-16
ffffffffc020040e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200410:	02000793          	li	a5,32
ffffffffc0200414:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200418:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020041c:	67e1                	lui	a5,0x18
ffffffffc020041e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200422:	953e                	add	a0,a0,a5
ffffffffc0200424:	4f2010ef          	jal	ra,ffffffffc0201916 <sbi_set_timer>
}
ffffffffc0200428:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042a:	00006797          	auipc	a5,0x6
ffffffffc020042e:	0007b723          	sd	zero,14(a5) # ffffffffc0206438 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200432:	00002517          	auipc	a0,0x2
ffffffffc0200436:	85e50513          	addi	a0,a0,-1954 # ffffffffc0201c90 <commands+0x1a0>
}
ffffffffc020043a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020043c:	c7bff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc0200440 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200440:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200444:	67e1                	lui	a5,0x18
ffffffffc0200446:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020044a:	953e                	add	a0,a0,a5
ffffffffc020044c:	4ca0106f          	j	ffffffffc0201916 <sbi_set_timer>

ffffffffc0200450 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200450:	8082                	ret

ffffffffc0200452 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200452:	0ff57513          	andi	a0,a0,255
ffffffffc0200456:	4a40106f          	j	ffffffffc02018fa <sbi_console_putchar>

ffffffffc020045a <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045a:	4d80106f          	j	ffffffffc0201932 <sbi_console_getchar>

ffffffffc020045e <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200464:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200468:	8082                	ret

ffffffffc020046a <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020046e:	00000797          	auipc	a5,0x0
ffffffffc0200472:	30678793          	addi	a5,a5,774 # ffffffffc0200774 <__alltraps>
ffffffffc0200476:	10579073          	csrw	stvec,a5
}
ffffffffc020047a:	8082                	ret

ffffffffc020047c <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047c:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020047e:	1141                	addi	sp,sp,-16
ffffffffc0200480:	e022                	sd	s0,0(sp)
ffffffffc0200482:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200484:	00002517          	auipc	a0,0x2
ffffffffc0200488:	92450513          	addi	a0,a0,-1756 # ffffffffc0201da8 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc020048c:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020048e:	c29ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200492:	640c                	ld	a1,8(s0)
ffffffffc0200494:	00002517          	auipc	a0,0x2
ffffffffc0200498:	92c50513          	addi	a0,a0,-1748 # ffffffffc0201dc0 <commands+0x2d0>
ffffffffc020049c:	c1bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a0:	680c                	ld	a1,16(s0)
ffffffffc02004a2:	00002517          	auipc	a0,0x2
ffffffffc02004a6:	93650513          	addi	a0,a0,-1738 # ffffffffc0201dd8 <commands+0x2e8>
ffffffffc02004aa:	c0dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004ae:	6c0c                	ld	a1,24(s0)
ffffffffc02004b0:	00002517          	auipc	a0,0x2
ffffffffc02004b4:	94050513          	addi	a0,a0,-1728 # ffffffffc0201df0 <commands+0x300>
ffffffffc02004b8:	bffff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004bc:	700c                	ld	a1,32(s0)
ffffffffc02004be:	00002517          	auipc	a0,0x2
ffffffffc02004c2:	94a50513          	addi	a0,a0,-1718 # ffffffffc0201e08 <commands+0x318>
ffffffffc02004c6:	bf1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004ca:	740c                	ld	a1,40(s0)
ffffffffc02004cc:	00002517          	auipc	a0,0x2
ffffffffc02004d0:	95450513          	addi	a0,a0,-1708 # ffffffffc0201e20 <commands+0x330>
ffffffffc02004d4:	be3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d8:	780c                	ld	a1,48(s0)
ffffffffc02004da:	00002517          	auipc	a0,0x2
ffffffffc02004de:	95e50513          	addi	a0,a0,-1698 # ffffffffc0201e38 <commands+0x348>
ffffffffc02004e2:	bd5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e6:	7c0c                	ld	a1,56(s0)
ffffffffc02004e8:	00002517          	auipc	a0,0x2
ffffffffc02004ec:	96850513          	addi	a0,a0,-1688 # ffffffffc0201e50 <commands+0x360>
ffffffffc02004f0:	bc7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f4:	602c                	ld	a1,64(s0)
ffffffffc02004f6:	00002517          	auipc	a0,0x2
ffffffffc02004fa:	97250513          	addi	a0,a0,-1678 # ffffffffc0201e68 <commands+0x378>
ffffffffc02004fe:	bb9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200502:	642c                	ld	a1,72(s0)
ffffffffc0200504:	00002517          	auipc	a0,0x2
ffffffffc0200508:	97c50513          	addi	a0,a0,-1668 # ffffffffc0201e80 <commands+0x390>
ffffffffc020050c:	babff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200510:	682c                	ld	a1,80(s0)
ffffffffc0200512:	00002517          	auipc	a0,0x2
ffffffffc0200516:	98650513          	addi	a0,a0,-1658 # ffffffffc0201e98 <commands+0x3a8>
ffffffffc020051a:	b9dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020051e:	6c2c                	ld	a1,88(s0)
ffffffffc0200520:	00002517          	auipc	a0,0x2
ffffffffc0200524:	99050513          	addi	a0,a0,-1648 # ffffffffc0201eb0 <commands+0x3c0>
ffffffffc0200528:	b8fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052c:	702c                	ld	a1,96(s0)
ffffffffc020052e:	00002517          	auipc	a0,0x2
ffffffffc0200532:	99a50513          	addi	a0,a0,-1638 # ffffffffc0201ec8 <commands+0x3d8>
ffffffffc0200536:	b81ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053a:	742c                	ld	a1,104(s0)
ffffffffc020053c:	00002517          	auipc	a0,0x2
ffffffffc0200540:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201ee0 <commands+0x3f0>
ffffffffc0200544:	b73ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200548:	782c                	ld	a1,112(s0)
ffffffffc020054a:	00002517          	auipc	a0,0x2
ffffffffc020054e:	9ae50513          	addi	a0,a0,-1618 # ffffffffc0201ef8 <commands+0x408>
ffffffffc0200552:	b65ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200556:	7c2c                	ld	a1,120(s0)
ffffffffc0200558:	00002517          	auipc	a0,0x2
ffffffffc020055c:	9b850513          	addi	a0,a0,-1608 # ffffffffc0201f10 <commands+0x420>
ffffffffc0200560:	b57ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200564:	604c                	ld	a1,128(s0)
ffffffffc0200566:	00002517          	auipc	a0,0x2
ffffffffc020056a:	9c250513          	addi	a0,a0,-1598 # ffffffffc0201f28 <commands+0x438>
ffffffffc020056e:	b49ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200572:	644c                	ld	a1,136(s0)
ffffffffc0200574:	00002517          	auipc	a0,0x2
ffffffffc0200578:	9cc50513          	addi	a0,a0,-1588 # ffffffffc0201f40 <commands+0x450>
ffffffffc020057c:	b3bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200580:	684c                	ld	a1,144(s0)
ffffffffc0200582:	00002517          	auipc	a0,0x2
ffffffffc0200586:	9d650513          	addi	a0,a0,-1578 # ffffffffc0201f58 <commands+0x468>
ffffffffc020058a:	b2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020058e:	6c4c                	ld	a1,152(s0)
ffffffffc0200590:	00002517          	auipc	a0,0x2
ffffffffc0200594:	9e050513          	addi	a0,a0,-1568 # ffffffffc0201f70 <commands+0x480>
ffffffffc0200598:	b1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059c:	704c                	ld	a1,160(s0)
ffffffffc020059e:	00002517          	auipc	a0,0x2
ffffffffc02005a2:	9ea50513          	addi	a0,a0,-1558 # ffffffffc0201f88 <commands+0x498>
ffffffffc02005a6:	b11ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005aa:	744c                	ld	a1,168(s0)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	9f450513          	addi	a0,a0,-1548 # ffffffffc0201fa0 <commands+0x4b0>
ffffffffc02005b4:	b03ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b8:	784c                	ld	a1,176(s0)
ffffffffc02005ba:	00002517          	auipc	a0,0x2
ffffffffc02005be:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0201fb8 <commands+0x4c8>
ffffffffc02005c2:	af5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c6:	7c4c                	ld	a1,184(s0)
ffffffffc02005c8:	00002517          	auipc	a0,0x2
ffffffffc02005cc:	a0850513          	addi	a0,a0,-1528 # ffffffffc0201fd0 <commands+0x4e0>
ffffffffc02005d0:	ae7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d4:	606c                	ld	a1,192(s0)
ffffffffc02005d6:	00002517          	auipc	a0,0x2
ffffffffc02005da:	a1250513          	addi	a0,a0,-1518 # ffffffffc0201fe8 <commands+0x4f8>
ffffffffc02005de:	ad9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e2:	646c                	ld	a1,200(s0)
ffffffffc02005e4:	00002517          	auipc	a0,0x2
ffffffffc02005e8:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0202000 <commands+0x510>
ffffffffc02005ec:	acbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f0:	686c                	ld	a1,208(s0)
ffffffffc02005f2:	00002517          	auipc	a0,0x2
ffffffffc02005f6:	a2650513          	addi	a0,a0,-1498 # ffffffffc0202018 <commands+0x528>
ffffffffc02005fa:	abdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005fe:	6c6c                	ld	a1,216(s0)
ffffffffc0200600:	00002517          	auipc	a0,0x2
ffffffffc0200604:	a3050513          	addi	a0,a0,-1488 # ffffffffc0202030 <commands+0x540>
ffffffffc0200608:	aafff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060c:	706c                	ld	a1,224(s0)
ffffffffc020060e:	00002517          	auipc	a0,0x2
ffffffffc0200612:	a3a50513          	addi	a0,a0,-1478 # ffffffffc0202048 <commands+0x558>
ffffffffc0200616:	aa1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061a:	746c                	ld	a1,232(s0)
ffffffffc020061c:	00002517          	auipc	a0,0x2
ffffffffc0200620:	a4450513          	addi	a0,a0,-1468 # ffffffffc0202060 <commands+0x570>
ffffffffc0200624:	a93ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200628:	786c                	ld	a1,240(s0)
ffffffffc020062a:	00002517          	auipc	a0,0x2
ffffffffc020062e:	a4e50513          	addi	a0,a0,-1458 # ffffffffc0202078 <commands+0x588>
ffffffffc0200632:	a85ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200638:	6402                	ld	s0,0(sp)
ffffffffc020063a:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063c:	00002517          	auipc	a0,0x2
ffffffffc0200640:	a5450513          	addi	a0,a0,-1452 # ffffffffc0202090 <commands+0x5a0>
}
ffffffffc0200644:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200646:	a71ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00002517          	auipc	a0,0x2
ffffffffc0200656:	a5650513          	addi	a0,a0,-1450 # ffffffffc02020a8 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1bff0ef          	jal	ra,ffffffffc020047c <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00002517          	auipc	a0,0x2
ffffffffc020066e:	a5650513          	addi	a0,a0,-1450 # ffffffffc02020c0 <commands+0x5d0>
ffffffffc0200672:	a45ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00002517          	auipc	a0,0x2
ffffffffc020067e:	a5e50513          	addi	a0,a0,-1442 # ffffffffc02020d8 <commands+0x5e8>
ffffffffc0200682:	a35ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00002517          	auipc	a0,0x2
ffffffffc020068e:	a6650513          	addi	a0,a0,-1434 # ffffffffc02020f0 <commands+0x600>
ffffffffc0200692:	a25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00002517          	auipc	a0,0x2
ffffffffc02006a2:	a6a50513          	addi	a0,a0,-1430 # ffffffffc0202108 <commands+0x618>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	a0fff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc02006ac <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006ac:	11853783          	ld	a5,280(a0)
ffffffffc02006b0:	577d                	li	a4,-1
ffffffffc02006b2:	8305                	srli	a4,a4,0x1
ffffffffc02006b4:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02006b6:	472d                	li	a4,11
ffffffffc02006b8:	08f76563          	bltu	a4,a5,ffffffffc0200742 <interrupt_handler+0x96>
ffffffffc02006bc:	00001717          	auipc	a4,0x1
ffffffffc02006c0:	5f070713          	addi	a4,a4,1520 # ffffffffc0201cac <commands+0x1bc>
ffffffffc02006c4:	078a                	slli	a5,a5,0x2
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	439c                	lw	a5,0(a5)
ffffffffc02006ca:	97ba                	add	a5,a5,a4
ffffffffc02006cc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ce:	00001517          	auipc	a0,0x1
ffffffffc02006d2:	67250513          	addi	a0,a0,1650 # ffffffffc0201d40 <commands+0x250>
ffffffffc02006d6:	9e1ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006da:	00001517          	auipc	a0,0x1
ffffffffc02006de:	64650513          	addi	a0,a0,1606 # ffffffffc0201d20 <commands+0x230>
ffffffffc02006e2:	9d5ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006e6:	00001517          	auipc	a0,0x1
ffffffffc02006ea:	5fa50513          	addi	a0,a0,1530 # ffffffffc0201ce0 <commands+0x1f0>
ffffffffc02006ee:	9c9ff06f          	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006f2:	00001517          	auipc	a0,0x1
ffffffffc02006f6:	66e50513          	addi	a0,a0,1646 # ffffffffc0201d60 <commands+0x270>
ffffffffc02006fa:	9bdff06f          	j	ffffffffc02000b6 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006fe:	1141                	addi	sp,sp,-16
ffffffffc0200700:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200702:	d3fff0ef          	jal	ra,ffffffffc0200440 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200706:	00006797          	auipc	a5,0x6
ffffffffc020070a:	d3278793          	addi	a5,a5,-718 # ffffffffc0206438 <ticks>
ffffffffc020070e:	639c                	ld	a5,0(a5)
ffffffffc0200710:	06400713          	li	a4,100
ffffffffc0200714:	0785                	addi	a5,a5,1
ffffffffc0200716:	02e7f733          	remu	a4,a5,a4
ffffffffc020071a:	00006697          	auipc	a3,0x6
ffffffffc020071e:	d0f6bf23          	sd	a5,-738(a3) # ffffffffc0206438 <ticks>
ffffffffc0200722:	c315                	beqz	a4,ffffffffc0200746 <interrupt_handler+0x9a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200724:	60a2                	ld	ra,8(sp)
ffffffffc0200726:	0141                	addi	sp,sp,16
ffffffffc0200728:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020072a:	00001517          	auipc	a0,0x1
ffffffffc020072e:	65e50513          	addi	a0,a0,1630 # ffffffffc0201d88 <commands+0x298>
ffffffffc0200732:	985ff06f          	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	5ca50513          	addi	a0,a0,1482 # ffffffffc0201d00 <commands+0x210>
ffffffffc020073e:	979ff06f          	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc0200742:	f09ff06f          	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200748:	06400593          	li	a1,100
ffffffffc020074c:	00001517          	auipc	a0,0x1
ffffffffc0200750:	62c50513          	addi	a0,a0,1580 # ffffffffc0201d78 <commands+0x288>
}
ffffffffc0200754:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200756:	961ff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020075a <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020075a:	11853783          	ld	a5,280(a0)
ffffffffc020075e:	0007c863          	bltz	a5,ffffffffc020076e <trap+0x14>
    switch (tf->cause) {
ffffffffc0200762:	472d                	li	a4,11
ffffffffc0200764:	00f76363          	bltu	a4,a5,ffffffffc020076a <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc0200768:	8082                	ret
            print_trapframe(tf);
ffffffffc020076a:	ee1ff06f          	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc020076e:	f3fff06f          	j	ffffffffc02006ac <interrupt_handler>
	...

ffffffffc0200774 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200774:	14011073          	csrw	sscratch,sp
ffffffffc0200778:	712d                	addi	sp,sp,-288
ffffffffc020077a:	e002                	sd	zero,0(sp)
ffffffffc020077c:	e406                	sd	ra,8(sp)
ffffffffc020077e:	ec0e                	sd	gp,24(sp)
ffffffffc0200780:	f012                	sd	tp,32(sp)
ffffffffc0200782:	f416                	sd	t0,40(sp)
ffffffffc0200784:	f81a                	sd	t1,48(sp)
ffffffffc0200786:	fc1e                	sd	t2,56(sp)
ffffffffc0200788:	e0a2                	sd	s0,64(sp)
ffffffffc020078a:	e4a6                	sd	s1,72(sp)
ffffffffc020078c:	e8aa                	sd	a0,80(sp)
ffffffffc020078e:	ecae                	sd	a1,88(sp)
ffffffffc0200790:	f0b2                	sd	a2,96(sp)
ffffffffc0200792:	f4b6                	sd	a3,104(sp)
ffffffffc0200794:	f8ba                	sd	a4,112(sp)
ffffffffc0200796:	fcbe                	sd	a5,120(sp)
ffffffffc0200798:	e142                	sd	a6,128(sp)
ffffffffc020079a:	e546                	sd	a7,136(sp)
ffffffffc020079c:	e94a                	sd	s2,144(sp)
ffffffffc020079e:	ed4e                	sd	s3,152(sp)
ffffffffc02007a0:	f152                	sd	s4,160(sp)
ffffffffc02007a2:	f556                	sd	s5,168(sp)
ffffffffc02007a4:	f95a                	sd	s6,176(sp)
ffffffffc02007a6:	fd5e                	sd	s7,184(sp)
ffffffffc02007a8:	e1e2                	sd	s8,192(sp)
ffffffffc02007aa:	e5e6                	sd	s9,200(sp)
ffffffffc02007ac:	e9ea                	sd	s10,208(sp)
ffffffffc02007ae:	edee                	sd	s11,216(sp)
ffffffffc02007b0:	f1f2                	sd	t3,224(sp)
ffffffffc02007b2:	f5f6                	sd	t4,232(sp)
ffffffffc02007b4:	f9fa                	sd	t5,240(sp)
ffffffffc02007b6:	fdfe                	sd	t6,248(sp)
ffffffffc02007b8:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02007bc:	100024f3          	csrr	s1,sstatus
ffffffffc02007c0:	14102973          	csrr	s2,sepc
ffffffffc02007c4:	143029f3          	csrr	s3,stval
ffffffffc02007c8:	14202a73          	csrr	s4,scause
ffffffffc02007cc:	e822                	sd	s0,16(sp)
ffffffffc02007ce:	e226                	sd	s1,256(sp)
ffffffffc02007d0:	e64a                	sd	s2,264(sp)
ffffffffc02007d2:	ea4e                	sd	s3,272(sp)
ffffffffc02007d4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007d6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007d8:	f83ff0ef          	jal	ra,ffffffffc020075a <trap>

ffffffffc02007dc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007dc:	6492                	ld	s1,256(sp)
ffffffffc02007de:	6932                	ld	s2,264(sp)
ffffffffc02007e0:	10049073          	csrw	sstatus,s1
ffffffffc02007e4:	14191073          	csrw	sepc,s2
ffffffffc02007e8:	60a2                	ld	ra,8(sp)
ffffffffc02007ea:	61e2                	ld	gp,24(sp)
ffffffffc02007ec:	7202                	ld	tp,32(sp)
ffffffffc02007ee:	72a2                	ld	t0,40(sp)
ffffffffc02007f0:	7342                	ld	t1,48(sp)
ffffffffc02007f2:	73e2                	ld	t2,56(sp)
ffffffffc02007f4:	6406                	ld	s0,64(sp)
ffffffffc02007f6:	64a6                	ld	s1,72(sp)
ffffffffc02007f8:	6546                	ld	a0,80(sp)
ffffffffc02007fa:	65e6                	ld	a1,88(sp)
ffffffffc02007fc:	7606                	ld	a2,96(sp)
ffffffffc02007fe:	76a6                	ld	a3,104(sp)
ffffffffc0200800:	7746                	ld	a4,112(sp)
ffffffffc0200802:	77e6                	ld	a5,120(sp)
ffffffffc0200804:	680a                	ld	a6,128(sp)
ffffffffc0200806:	68aa                	ld	a7,136(sp)
ffffffffc0200808:	694a                	ld	s2,144(sp)
ffffffffc020080a:	69ea                	ld	s3,152(sp)
ffffffffc020080c:	7a0a                	ld	s4,160(sp)
ffffffffc020080e:	7aaa                	ld	s5,168(sp)
ffffffffc0200810:	7b4a                	ld	s6,176(sp)
ffffffffc0200812:	7bea                	ld	s7,184(sp)
ffffffffc0200814:	6c0e                	ld	s8,192(sp)
ffffffffc0200816:	6cae                	ld	s9,200(sp)
ffffffffc0200818:	6d4e                	ld	s10,208(sp)
ffffffffc020081a:	6dee                	ld	s11,216(sp)
ffffffffc020081c:	7e0e                	ld	t3,224(sp)
ffffffffc020081e:	7eae                	ld	t4,232(sp)
ffffffffc0200820:	7f4e                	ld	t5,240(sp)
ffffffffc0200822:	7fee                	ld	t6,248(sp)
ffffffffc0200824:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200826:	10200073          	sret

ffffffffc020082a <buddy_init>:
}

static void
buddy_init(void) {
    // free_list头初始化
    for (int i = 0;i < MAX_BUDDY_ORDER;i ++){
ffffffffc020082a:	00006797          	auipc	a5,0x6
ffffffffc020082e:	c1e78793          	addi	a5,a5,-994 # ffffffffc0206448 <buddy_s+0x8>
ffffffffc0200832:	00006717          	auipc	a4,0x6
ffffffffc0200836:	d5670713          	addi	a4,a4,-682 # ffffffffc0206588 <buddy_s+0x148>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020083a:	e79c                	sd	a5,8(a5)
ffffffffc020083c:	e39c                	sd	a5,0(a5)
ffffffffc020083e:	07c1                	addi	a5,a5,16
ffffffffc0200840:	fee79de3          	bne	a5,a4,ffffffffc020083a <buddy_init+0x10>
        list_init(buddy_array + i); 
    }
    max_order = 0;
ffffffffc0200844:	00006797          	auipc	a5,0x6
ffffffffc0200848:	be07ae23          	sw	zero,-1028(a5) # ffffffffc0206440 <buddy_s>
    nr_free = 0;
ffffffffc020084c:	00006797          	auipc	a5,0x6
ffffffffc0200850:	d407a623          	sw	zero,-692(a5) # ffffffffc0206598 <buddy_s+0x158>
    return;
}
ffffffffc0200854:	8082                	ret

ffffffffc0200856 <buddy_nr_free_pages>:
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200856:	00006517          	auipc	a0,0x6
ffffffffc020085a:	d4256503          	lwu	a0,-702(a0) # ffffffffc0206598 <buddy_s+0x158>
ffffffffc020085e:	8082                	ret

ffffffffc0200860 <show_buddy_array>:
show_buddy_array(void) {
ffffffffc0200860:	7159                	addi	sp,sp,-112
    cprintf("[TEST]Buddy System: Print buddy array:\n");
ffffffffc0200862:	00002517          	auipc	a0,0x2
ffffffffc0200866:	f0650513          	addi	a0,a0,-250 # ffffffffc0202768 <buddy_pmm_manager+0x40>
show_buddy_array(void) {
ffffffffc020086a:	f486                	sd	ra,104(sp)
ffffffffc020086c:	f062                	sd	s8,32(sp)
ffffffffc020086e:	f0a2                	sd	s0,96(sp)
ffffffffc0200870:	eca6                	sd	s1,88(sp)
ffffffffc0200872:	e8ca                	sd	s2,80(sp)
ffffffffc0200874:	e4ce                	sd	s3,72(sp)
ffffffffc0200876:	e0d2                	sd	s4,64(sp)
ffffffffc0200878:	fc56                	sd	s5,56(sp)
ffffffffc020087a:	f85a                	sd	s6,48(sp)
ffffffffc020087c:	f45e                	sd	s7,40(sp)
ffffffffc020087e:	ec66                	sd	s9,24(sp)
ffffffffc0200880:	e86a                	sd	s10,16(sp)
ffffffffc0200882:	e46e                	sd	s11,8(sp)
    cprintf("[TEST]Buddy System: Print buddy array:\n");
ffffffffc0200884:	833ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("---------------------------\n");
ffffffffc0200888:	00002517          	auipc	a0,0x2
ffffffffc020088c:	f0850513          	addi	a0,a0,-248 # ffffffffc0202790 <buddy_pmm_manager+0x68>
ffffffffc0200890:	827ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (int i = 0;i < max_order + 1;i ++) {
ffffffffc0200894:	00006c17          	auipc	s8,0x6
ffffffffc0200898:	bacc0c13          	addi	s8,s8,-1108 # ffffffffc0206440 <buddy_s>
ffffffffc020089c:	000c2703          	lw	a4,0(s8)
ffffffffc02008a0:	57fd                	li	a5,-1
ffffffffc02008a2:	0af70163          	beq	a4,a5,ffffffffc0200944 <show_buddy_array+0xe4>
ffffffffc02008a6:	00006917          	auipc	s2,0x6
ffffffffc02008aa:	ba290913          	addi	s2,s2,-1118 # ffffffffc0206448 <buddy_s+0x8>
ffffffffc02008ae:	4b81                	li	s7,0
        cprintf("No. %d: ", i);
ffffffffc02008b0:	00002d17          	auipc	s10,0x2
ffffffffc02008b4:	f00d0d13          	addi	s10,s10,-256 # ffffffffc02027b0 <buddy_pmm_manager+0x88>
ffffffffc02008b8:	00002d97          	auipc	s11,0x2
ffffffffc02008bc:	298d8d93          	addi	s11,s11,664 # ffffffffc0202b50 <nbase>
ffffffffc02008c0:	00006b17          	auipc	s6,0x6
ffffffffc02008c4:	cf8b0b13          	addi	s6,s6,-776 # ffffffffc02065b8 <pages>
ffffffffc02008c8:	00002a97          	auipc	s5,0x2
ffffffffc02008cc:	e98a8a93          	addi	s5,s5,-360 # ffffffffc0202760 <buddy_pmm_manager+0x38>
            cprintf("%d ", p);
ffffffffc02008d0:	00002497          	auipc	s1,0x2
ffffffffc02008d4:	ef048493          	addi	s1,s1,-272 # ffffffffc02027c0 <buddy_pmm_manager+0x98>
            cprintf("%d ", 1 << (p->property));
ffffffffc02008d8:	4a05                	li	s4,1
        cprintf("No. %d: ", i);
ffffffffc02008da:	85de                	mv	a1,s7
ffffffffc02008dc:	856a                	mv	a0,s10
ffffffffc02008de:	fd8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc02008e2:	00893c83          	ld	s9,8(s2)
        while ((le = list_next(le)) != &(buddy_array[i])) {
ffffffffc02008e6:	05990263          	beq	s2,s9,ffffffffc020092a <show_buddy_array+0xca>
ffffffffc02008ea:	000db983          	ld	s3,0(s11)
            struct Page *p = le2page(le, page_link);
ffffffffc02008ee:	fe8c8413          	addi	s0,s9,-24
            cprintf("%d ", p);
ffffffffc02008f2:	85a2                	mv	a1,s0
ffffffffc02008f4:	8526                	mv	a0,s1
ffffffffc02008f6:	fc0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02008fa:	000b3583          	ld	a1,0(s6)
ffffffffc02008fe:	000ab703          	ld	a4,0(s5)
            cprintf("%d ", page2ppn(p));
ffffffffc0200902:	8526                	mv	a0,s1
ffffffffc0200904:	40b405b3          	sub	a1,s0,a1
ffffffffc0200908:	858d                	srai	a1,a1,0x3
ffffffffc020090a:	02e585b3          	mul	a1,a1,a4
ffffffffc020090e:	95ce                	add	a1,a1,s3
ffffffffc0200910:	fa6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
            cprintf("%d ", 1 << (p->property));
ffffffffc0200914:	ff8ca583          	lw	a1,-8(s9)
ffffffffc0200918:	8526                	mv	a0,s1
ffffffffc020091a:	00ba15bb          	sllw	a1,s4,a1
ffffffffc020091e:	f98ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200922:	008cbc83          	ld	s9,8(s9)
        while ((le = list_next(le)) != &(buddy_array[i])) {
ffffffffc0200926:	fd2c94e3          	bne	s9,s2,ffffffffc02008ee <show_buddy_array+0x8e>
        cprintf("\n");
ffffffffc020092a:	00002517          	auipc	a0,0x2
ffffffffc020092e:	d0e50513          	addi	a0,a0,-754 # ffffffffc0202638 <commands+0xb48>
ffffffffc0200932:	f84ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    for (int i = 0;i < max_order + 1;i ++) {
ffffffffc0200936:	000c2783          	lw	a5,0(s8)
ffffffffc020093a:	2b85                	addiw	s7,s7,1
ffffffffc020093c:	0941                	addi	s2,s2,16
ffffffffc020093e:	2785                	addiw	a5,a5,1
ffffffffc0200940:	f8fbede3          	bltu	s7,a5,ffffffffc02008da <show_buddy_array+0x7a>
}
ffffffffc0200944:	7406                	ld	s0,96(sp)
ffffffffc0200946:	70a6                	ld	ra,104(sp)
ffffffffc0200948:	64e6                	ld	s1,88(sp)
ffffffffc020094a:	6946                	ld	s2,80(sp)
ffffffffc020094c:	69a6                	ld	s3,72(sp)
ffffffffc020094e:	6a06                	ld	s4,64(sp)
ffffffffc0200950:	7ae2                	ld	s5,56(sp)
ffffffffc0200952:	7b42                	ld	s6,48(sp)
ffffffffc0200954:	7ba2                	ld	s7,40(sp)
ffffffffc0200956:	7c02                	ld	s8,32(sp)
ffffffffc0200958:	6ce2                	ld	s9,24(sp)
ffffffffc020095a:	6d42                	ld	s10,16(sp)
ffffffffc020095c:	6da2                	ld	s11,8(sp)
    cprintf("---------------------------\n");
ffffffffc020095e:	00002517          	auipc	a0,0x2
ffffffffc0200962:	e3250513          	addi	a0,a0,-462 # ffffffffc0202790 <buddy_pmm_manager+0x68>
}
ffffffffc0200966:	6165                	addi	sp,sp,112
    cprintf("---------------------------\n");
ffffffffc0200968:	f4eff06f          	j	ffffffffc02000b6 <cprintf>

ffffffffc020096c <buddy_get_buddy>:
buddy_get_buddy(struct Page *page) {
ffffffffc020096c:	7179                	addi	sp,sp,-48
ffffffffc020096e:	e052                	sd	s4,0(sp)
ffffffffc0200970:	00006a17          	auipc	s4,0x6
ffffffffc0200974:	c48a0a13          	addi	s4,s4,-952 # ffffffffc02065b8 <pages>
ffffffffc0200978:	000a3583          	ld	a1,0(s4)
ffffffffc020097c:	00002797          	auipc	a5,0x2
ffffffffc0200980:	de478793          	addi	a5,a5,-540 # ffffffffc0202760 <buddy_pmm_manager+0x38>
ffffffffc0200984:	e44e                	sd	s3,8(sp)
ffffffffc0200986:	0007b983          	ld	s3,0(a5)
ffffffffc020098a:	40b505b3          	sub	a1,a0,a1
ffffffffc020098e:	858d                	srai	a1,a1,0x3
ffffffffc0200990:	033585b3          	mul	a1,a1,s3
ffffffffc0200994:	00002797          	auipc	a5,0x2
ffffffffc0200998:	1bc78793          	addi	a5,a5,444 # ffffffffc0202b50 <nbase>
ffffffffc020099c:	e84a                	sd	s2,16(sp)
ffffffffc020099e:	0007b903          	ld	s2,0(a5)
    size_t buddy_ppn = first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn)); 
ffffffffc02009a2:	00005797          	auipc	a5,0x5
ffffffffc02009a6:	65e78793          	addi	a5,a5,1630 # ffffffffc0206000 <first_ppn>
    size_t order = page->property;
ffffffffc02009aa:	4910                	lw	a2,16(a0)
    size_t buddy_ppn = first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn)); 
ffffffffc02009ac:	639c                	ld	a5,0(a5)
ffffffffc02009ae:	4705                	li	a4,1
buddy_get_buddy(struct Page *page) {
ffffffffc02009b0:	f022                	sd	s0,32(sp)
    size_t buddy_ppn = first_ppn + ((1 << order) ^ (page2ppn(page) - first_ppn)); 
ffffffffc02009b2:	00c7173b          	sllw	a4,a4,a2
ffffffffc02009b6:	95ca                	add	a1,a1,s2
ffffffffc02009b8:	40f58433          	sub	s0,a1,a5
ffffffffc02009bc:	8f21                	xor	a4,a4,s0
ffffffffc02009be:	00f70433          	add	s0,a4,a5
    cprintf("[TEST]Buddy System: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
ffffffffc02009c2:	1602                	slli	a2,a2,0x20
buddy_get_buddy(struct Page *page) {
ffffffffc02009c4:	ec26                	sd	s1,24(sp)
    cprintf("[TEST]Buddy System: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
ffffffffc02009c6:	9201                	srli	a2,a2,0x20
buddy_get_buddy(struct Page *page) {
ffffffffc02009c8:	84aa                	mv	s1,a0
    cprintf("[TEST]Buddy System: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
ffffffffc02009ca:	86a2                	mv	a3,s0
ffffffffc02009cc:	00002517          	auipc	a0,0x2
ffffffffc02009d0:	ccc50513          	addi	a0,a0,-820 # ffffffffc0202698 <commands+0xba8>
buddy_get_buddy(struct Page *page) {
ffffffffc02009d4:	f406                	sd	ra,40(sp)
    cprintf("[TEST]Buddy System: Page NO.%d 's buddy page on order %d is: %d\n", page2ppn(page), order, buddy_ppn);
ffffffffc02009d6:	ee0ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02009da:	000a3783          	ld	a5,0(s4)
ffffffffc02009de:	40f487b3          	sub	a5,s1,a5
ffffffffc02009e2:	878d                	srai	a5,a5,0x3
ffffffffc02009e4:	033787b3          	mul	a5,a5,s3
ffffffffc02009e8:	97ca                	add	a5,a5,s2
    if (buddy_ppn > page2ppn(page)) {
ffffffffc02009ea:	0287f263          	bleu	s0,a5,ffffffffc0200a0e <buddy_get_buddy+0xa2>
        return page + (buddy_ppn - page2ppn(page));
ffffffffc02009ee:	40f407b3          	sub	a5,s0,a5
ffffffffc02009f2:	00279513          	slli	a0,a5,0x2
}
ffffffffc02009f6:	70a2                	ld	ra,40(sp)
ffffffffc02009f8:	7402                	ld	s0,32(sp)
        return page + (buddy_ppn - page2ppn(page));
ffffffffc02009fa:	97aa                	add	a5,a5,a0
ffffffffc02009fc:	00379513          	slli	a0,a5,0x3
ffffffffc0200a00:	9526                	add	a0,a0,s1
}
ffffffffc0200a02:	6942                	ld	s2,16(sp)
ffffffffc0200a04:	64e2                	ld	s1,24(sp)
ffffffffc0200a06:	69a2                	ld	s3,8(sp)
ffffffffc0200a08:	6a02                	ld	s4,0(sp)
ffffffffc0200a0a:	6145                	addi	sp,sp,48
ffffffffc0200a0c:	8082                	ret
        return page - (page2ppn(page) - buddy_ppn);
ffffffffc0200a0e:	8f81                	sub	a5,a5,s0
ffffffffc0200a10:	00279513          	slli	a0,a5,0x2
}
ffffffffc0200a14:	70a2                	ld	ra,40(sp)
ffffffffc0200a16:	7402                	ld	s0,32(sp)
        return page - (page2ppn(page) - buddy_ppn);
ffffffffc0200a18:	97aa                	add	a5,a5,a0
ffffffffc0200a1a:	00379513          	slli	a0,a5,0x3
ffffffffc0200a1e:	40a48533          	sub	a0,s1,a0
}
ffffffffc0200a22:	6942                	ld	s2,16(sp)
ffffffffc0200a24:	64e2                	ld	s1,24(sp)
ffffffffc0200a26:	69a2                	ld	s3,8(sp)
ffffffffc0200a28:	6a02                	ld	s4,0(sp)
ffffffffc0200a2a:	6145                	addi	sp,sp,48
ffffffffc0200a2c:	8082                	ret

ffffffffc0200a2e <buddy_init_memmap>:
buddy_init_memmap(struct Page *base, size_t n) {
ffffffffc0200a2e:	1141                	addi	sp,sp,-16
ffffffffc0200a30:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200a32:	c1e1                	beqz	a1,ffffffffc0200af2 <buddy_init_memmap+0xc4>
    if (n & (n - 1)) {
ffffffffc0200a34:	fff58793          	addi	a5,a1,-1
ffffffffc0200a38:	8fed                	and	a5,a5,a1
ffffffffc0200a3a:	cb99                	beqz	a5,ffffffffc0200a50 <buddy_init_memmap+0x22>
    size_t res = 1;
ffffffffc0200a3c:	4785                	li	a5,1
ffffffffc0200a3e:	a011                	j	ffffffffc0200a42 <buddy_init_memmap+0x14>
            res = res << 1;
ffffffffc0200a40:	87ba                	mv	a5,a4
            n = n >> 1;
ffffffffc0200a42:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200a44:	00179713          	slli	a4,a5,0x1
        while (n) {
ffffffffc0200a48:	fde5                	bnez	a1,ffffffffc0200a40 <buddy_init_memmap+0x12>
        return res>>1; 
ffffffffc0200a4a:	55fd                	li	a1,-1
ffffffffc0200a4c:	8185                	srli	a1,a1,0x1
ffffffffc0200a4e:	8dfd                	and	a1,a1,a5
    while (n >> 1) {
ffffffffc0200a50:	0015d793          	srli	a5,a1,0x1
    unsigned int order = 0;
ffffffffc0200a54:	4601                	li	a2,0
    while (n >> 1) {
ffffffffc0200a56:	c781                	beqz	a5,ffffffffc0200a5e <buddy_init_memmap+0x30>
ffffffffc0200a58:	8385                	srli	a5,a5,0x1
        order ++;
ffffffffc0200a5a:	2605                	addiw	a2,a2,1
    while (n >> 1) {
ffffffffc0200a5c:	fff5                	bnez	a5,ffffffffc0200a58 <buddy_init_memmap+0x2a>
    for (; p != base + pnum; p ++) {
ffffffffc0200a5e:	00259693          	slli	a3,a1,0x2
ffffffffc0200a62:	96ae                	add	a3,a3,a1
ffffffffc0200a64:	068e                	slli	a3,a3,0x3
ffffffffc0200a66:	96aa                	add	a3,a3,a0
ffffffffc0200a68:	02d50463          	beq	a0,a3,ffffffffc0200a90 <buddy_init_memmap+0x62>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200a6c:	651c                	ld	a5,8(a0)
        assert(PageReserved(p));
ffffffffc0200a6e:	8b85                	andi	a5,a5,1
ffffffffc0200a70:	c3ad                	beqz	a5,ffffffffc0200ad2 <buddy_init_memmap+0xa4>
ffffffffc0200a72:	87aa                	mv	a5,a0
ffffffffc0200a74:	a021                	j	ffffffffc0200a7c <buddy_init_memmap+0x4e>
ffffffffc0200a76:	6798                	ld	a4,8(a5)
ffffffffc0200a78:	8b05                	andi	a4,a4,1
ffffffffc0200a7a:	cf21                	beqz	a4,ffffffffc0200ad2 <buddy_init_memmap+0xa4>
        p->flags = 0;
ffffffffc0200a7c:	0007b423          	sd	zero,8(a5)
        p->property = 0;   
ffffffffc0200a80:	0007a823          	sw	zero,16(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200a84:	0007a023          	sw	zero,0(a5)
    for (; p != base + pnum; p ++) {
ffffffffc0200a88:	02878793          	addi	a5,a5,40
ffffffffc0200a8c:	fed795e3          	bne	a5,a3,ffffffffc0200a76 <buddy_init_memmap+0x48>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200a90:	02061793          	slli	a5,a2,0x20
ffffffffc0200a94:	9381                	srli	a5,a5,0x20
    max_order = order;
ffffffffc0200a96:	00006697          	auipc	a3,0x6
ffffffffc0200a9a:	9aa68693          	addi	a3,a3,-1622 # ffffffffc0206440 <buddy_s>
ffffffffc0200a9e:	0792                	slli	a5,a5,0x4
ffffffffc0200aa0:	00f68833          	add	a6,a3,a5
ffffffffc0200aa4:	01083703          	ld	a4,16(a6)
    nr_free = pnum;
ffffffffc0200aa8:	00006897          	auipc	a7,0x6
ffffffffc0200aac:	aeb8a823          	sw	a1,-1296(a7) # ffffffffc0206598 <buddy_s+0x158>
    max_order = order;
ffffffffc0200ab0:	00006897          	auipc	a7,0x6
ffffffffc0200ab4:	98c8a823          	sw	a2,-1648(a7) # ffffffffc0206440 <buddy_s>
    list_add(&(buddy_array[max_order]), &(base->page_link)); 
ffffffffc0200ab8:	01850593          	addi	a1,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200abc:	e30c                	sd	a1,0(a4)
}     
ffffffffc0200abe:	60a2                	ld	ra,8(sp)
    list_add(&(buddy_array[max_order]), &(base->page_link)); 
ffffffffc0200ac0:	07a1                	addi	a5,a5,8
ffffffffc0200ac2:	00b83823          	sd	a1,16(a6)
ffffffffc0200ac6:	97b6                	add	a5,a5,a3
    elm->next = next;
ffffffffc0200ac8:	f118                	sd	a4,32(a0)
    elm->prev = prev;
ffffffffc0200aca:	ed1c                	sd	a5,24(a0)
    base->property = max_order;                       
ffffffffc0200acc:	c910                	sw	a2,16(a0)
}     
ffffffffc0200ace:	0141                	addi	sp,sp,16
ffffffffc0200ad0:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200ad2:	00002697          	auipc	a3,0x2
ffffffffc0200ad6:	c4668693          	addi	a3,a3,-954 # ffffffffc0202718 <commands+0xc28>
ffffffffc0200ada:	00002617          	auipc	a2,0x2
ffffffffc0200ade:	c0e60613          	addi	a2,a2,-1010 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200ae2:	07900593          	li	a1,121
ffffffffc0200ae6:	00002517          	auipc	a0,0x2
ffffffffc0200aea:	c1a50513          	addi	a0,a0,-998 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200aee:	8bfff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc0200af2:	00002697          	auipc	a3,0x2
ffffffffc0200af6:	bee68693          	addi	a3,a3,-1042 # ffffffffc02026e0 <commands+0xbf0>
ffffffffc0200afa:	00002617          	auipc	a2,0x2
ffffffffc0200afe:	bee60613          	addi	a2,a2,-1042 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200b02:	06f00593          	li	a1,111
ffffffffc0200b06:	00002517          	auipc	a0,0x2
ffffffffc0200b0a:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200b0e:	89fff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200b12 <buddy_check>:

    show_buddy_array();
    cprintf("!!! 测试结束 !!!\n");
}
static void
buddy_check(void) {
ffffffffc0200b12:	1101                	addi	sp,sp,-32
    cprintf("!!! 第一次分配 !!!\n");
ffffffffc0200b14:	00001517          	auipc	a0,0x1
ffffffffc0200b18:	76450513          	addi	a0,a0,1892 # ffffffffc0202278 <commands+0x788>
buddy_check(void) {
ffffffffc0200b1c:	ec06                	sd	ra,24(sp)
ffffffffc0200b1e:	e822                	sd	s0,16(sp)
ffffffffc0200b20:	e426                	sd	s1,8(sp)
ffffffffc0200b22:	e04a                	sd	s2,0(sp)
    cprintf("!!! 第一次分配 !!!\n");
ffffffffc0200b24:	d92ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b28:	4505                	li	a0,1
ffffffffc0200b2a:	6e2000ef          	jal	ra,ffffffffc020120c <alloc_pages>
ffffffffc0200b2e:	16050663          	beqz	a0,ffffffffc0200c9a <buddy_check+0x188>
ffffffffc0200b32:	842a                	mv	s0,a0
    cprintf("!!! 第二次分配 !!!\n");
ffffffffc0200b34:	00001517          	auipc	a0,0x1
ffffffffc0200b38:	78450513          	addi	a0,a0,1924 # ffffffffc02022b8 <commands+0x7c8>
ffffffffc0200b3c:	d7aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b40:	4505                	li	a0,1
ffffffffc0200b42:	6ca000ef          	jal	ra,ffffffffc020120c <alloc_pages>
ffffffffc0200b46:	892a                	mv	s2,a0
ffffffffc0200b48:	22050963          	beqz	a0,ffffffffc0200d7a <buddy_check+0x268>
    cprintf("!!! 第三次分配 !!!\n");
ffffffffc0200b4c:	00001517          	auipc	a0,0x1
ffffffffc0200b50:	7ac50513          	addi	a0,a0,1964 # ffffffffc02022f8 <commands+0x808>
ffffffffc0200b54:	d62ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b58:	4505                	li	a0,1
ffffffffc0200b5a:	6b2000ef          	jal	ra,ffffffffc020120c <alloc_pages>
ffffffffc0200b5e:	84aa                	mv	s1,a0
ffffffffc0200b60:	1e050d63          	beqz	a0,ffffffffc0200d5a <buddy_check+0x248>
    cprintf("!!! 第一次释放 !!!\n");
ffffffffc0200b64:	00001517          	auipc	a0,0x1
ffffffffc0200b68:	7d450513          	addi	a0,a0,2004 # ffffffffc0202338 <commands+0x848>
ffffffffc0200b6c:	d4aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_page(p0);
ffffffffc0200b70:	4585                	li	a1,1
ffffffffc0200b72:	8522                	mv	a0,s0
ffffffffc0200b74:	6dc000ef          	jal	ra,ffffffffc0201250 <free_pages>
    cprintf("!!! 第二次释放 !!!\n");
ffffffffc0200b78:	00001517          	auipc	a0,0x1
ffffffffc0200b7c:	7e050513          	addi	a0,a0,2016 # ffffffffc0202358 <commands+0x868>
ffffffffc0200b80:	d36ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_page(p1);
ffffffffc0200b84:	4585                	li	a1,1
ffffffffc0200b86:	854a                	mv	a0,s2
ffffffffc0200b88:	6c8000ef          	jal	ra,ffffffffc0201250 <free_pages>
    cprintf("!!! 第三次释放 !!!\n");
ffffffffc0200b8c:	00001517          	auipc	a0,0x1
ffffffffc0200b90:	7ec50513          	addi	a0,a0,2028 # ffffffffc0202378 <commands+0x888>
ffffffffc0200b94:	d22ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_page(p2);
ffffffffc0200b98:	4585                	li	a1,1
ffffffffc0200b9a:	8526                	mv	a0,s1
ffffffffc0200b9c:	6b4000ef          	jal	ra,ffffffffc0201250 <free_pages>
    show_buddy_array();
ffffffffc0200ba0:	cc1ff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
    cprintf("!!! 第四次分配-4 !!!\n");
ffffffffc0200ba4:	00001517          	auipc	a0,0x1
ffffffffc0200ba8:	7f450513          	addi	a0,a0,2036 # ffffffffc0202398 <commands+0x8a8>
ffffffffc0200bac:	d0aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200bb0:	4511                	li	a0,4
ffffffffc0200bb2:	65a000ef          	jal	ra,ffffffffc020120c <alloc_pages>
ffffffffc0200bb6:	892a                	mv	s2,a0
ffffffffc0200bb8:	18050163          	beqz	a0,ffffffffc0200d3a <buddy_check+0x228>
    cprintf("!!! 第五次分配-2 !!!\n");
ffffffffc0200bbc:	00002517          	auipc	a0,0x2
ffffffffc0200bc0:	81c50513          	addi	a0,a0,-2020 # ffffffffc02023d8 <commands+0x8e8>
ffffffffc0200bc4:	cf2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0200bc8:	4509                	li	a0,2
ffffffffc0200bca:	642000ef          	jal	ra,ffffffffc020120c <alloc_pages>
ffffffffc0200bce:	84aa                	mv	s1,a0
ffffffffc0200bd0:	14050563          	beqz	a0,ffffffffc0200d1a <buddy_check+0x208>
    cprintf("!!! 第六次分配-1 !!!\n");
ffffffffc0200bd4:	00002517          	auipc	a0,0x2
ffffffffc0200bd8:	84450513          	addi	a0,a0,-1980 # ffffffffc0202418 <commands+0x928>
ffffffffc0200bdc:	cdaff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((p2 = alloc_pages(1)) != NULL);
ffffffffc0200be0:	4505                	li	a0,1
ffffffffc0200be2:	62a000ef          	jal	ra,ffffffffc020120c <alloc_pages>
ffffffffc0200be6:	842a                	mv	s0,a0
ffffffffc0200be8:	10050963          	beqz	a0,ffffffffc0200cfa <buddy_check+0x1e8>
    cprintf("!!! 第四次释放 !!!\n");
ffffffffc0200bec:	00002517          	auipc	a0,0x2
ffffffffc0200bf0:	86c50513          	addi	a0,a0,-1940 # ffffffffc0202458 <commands+0x968>
ffffffffc0200bf4:	cc2ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p0, 4);
ffffffffc0200bf8:	4591                	li	a1,4
ffffffffc0200bfa:	854a                	mv	a0,s2
ffffffffc0200bfc:	654000ef          	jal	ra,ffffffffc0201250 <free_pages>
    cprintf("!!! 第五次释放 !!!\n");
ffffffffc0200c00:	00002517          	auipc	a0,0x2
ffffffffc0200c04:	87850513          	addi	a0,a0,-1928 # ffffffffc0202478 <commands+0x988>
ffffffffc0200c08:	caeff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p1, 2);
ffffffffc0200c0c:	4589                	li	a1,2
ffffffffc0200c0e:	8526                	mv	a0,s1
ffffffffc0200c10:	640000ef          	jal	ra,ffffffffc0201250 <free_pages>
    cprintf("!!! 第六次释放 !!!\n");
ffffffffc0200c14:	00002517          	auipc	a0,0x2
ffffffffc0200c18:	88450513          	addi	a0,a0,-1916 # ffffffffc0202498 <commands+0x9a8>
ffffffffc0200c1c:	c9aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p2, 1);
ffffffffc0200c20:	4585                	li	a1,1
ffffffffc0200c22:	8522                	mv	a0,s0
ffffffffc0200c24:	62c000ef          	jal	ra,ffffffffc0201250 <free_pages>
    show_buddy_array();
ffffffffc0200c28:	c39ff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
    cprintf("!!! 第七次分配-3 !!!\n");
ffffffffc0200c2c:	00002517          	auipc	a0,0x2
ffffffffc0200c30:	88c50513          	addi	a0,a0,-1908 # ffffffffc02024b8 <commands+0x9c8>
ffffffffc0200c34:	c82ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc0200c38:	450d                	li	a0,3
ffffffffc0200c3a:	5d2000ef          	jal	ra,ffffffffc020120c <alloc_pages>
ffffffffc0200c3e:	84aa                	mv	s1,a0
ffffffffc0200c40:	cd49                	beqz	a0,ffffffffc0200cda <buddy_check+0x1c8>
    cprintf("!!! 第八次分配-3 !!!\n");
ffffffffc0200c42:	00002517          	auipc	a0,0x2
ffffffffc0200c46:	8b650513          	addi	a0,a0,-1866 # ffffffffc02024f8 <commands+0xa08>
ffffffffc0200c4a:	c6cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200c4e:	450d                	li	a0,3
ffffffffc0200c50:	5bc000ef          	jal	ra,ffffffffc020120c <alloc_pages>
ffffffffc0200c54:	842a                	mv	s0,a0
ffffffffc0200c56:	c135                	beqz	a0,ffffffffc0200cba <buddy_check+0x1a8>
    cprintf("!!! 第七次释放 !!!\n");
ffffffffc0200c58:	00002517          	auipc	a0,0x2
ffffffffc0200c5c:	8e050513          	addi	a0,a0,-1824 # ffffffffc0202538 <commands+0xa48>
ffffffffc0200c60:	c56ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p0, 3);
ffffffffc0200c64:	458d                	li	a1,3
ffffffffc0200c66:	8526                	mv	a0,s1
ffffffffc0200c68:	5e8000ef          	jal	ra,ffffffffc0201250 <free_pages>
    cprintf("!!! 第八次释放 !!!\n");
ffffffffc0200c6c:	00002517          	auipc	a0,0x2
ffffffffc0200c70:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0202558 <commands+0xa68>
ffffffffc0200c74:	c42ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    free_pages(p1, 3);
ffffffffc0200c78:	8522                	mv	a0,s0
ffffffffc0200c7a:	458d                	li	a1,3
ffffffffc0200c7c:	5d4000ef          	jal	ra,ffffffffc0201250 <free_pages>
    show_buddy_array();
ffffffffc0200c80:	be1ff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
    basic_check();
}   
ffffffffc0200c84:	6442                	ld	s0,16(sp)
ffffffffc0200c86:	60e2                	ld	ra,24(sp)
ffffffffc0200c88:	64a2                	ld	s1,8(sp)
ffffffffc0200c8a:	6902                	ld	s2,0(sp)
    cprintf("!!! 测试结束 !!!\n");
ffffffffc0200c8c:	00002517          	auipc	a0,0x2
ffffffffc0200c90:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0202578 <commands+0xa88>
}   
ffffffffc0200c94:	6105                	addi	sp,sp,32
    cprintf("!!! 测试结束 !!!\n");
ffffffffc0200c96:	c20ff06f          	j	ffffffffc02000b6 <cprintf>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c9a:	00001697          	auipc	a3,0x1
ffffffffc0200c9e:	5fe68693          	addi	a3,a3,1534 # ffffffffc0202298 <commands+0x7a8>
ffffffffc0200ca2:	00002617          	auipc	a2,0x2
ffffffffc0200ca6:	a4660613          	addi	a2,a2,-1466 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200caa:	11000593          	li	a1,272
ffffffffc0200cae:	00002517          	auipc	a0,0x2
ffffffffc0200cb2:	a5250513          	addi	a0,a0,-1454 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200cb6:	ef6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cba:	00002697          	auipc	a3,0x2
ffffffffc0200cbe:	85e68693          	addi	a3,a3,-1954 # ffffffffc0202518 <commands+0xa28>
ffffffffc0200cc2:	00002617          	auipc	a2,0x2
ffffffffc0200cc6:	a2660613          	addi	a2,a2,-1498 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200cca:	12f00593          	li	a1,303
ffffffffc0200cce:	00002517          	auipc	a0,0x2
ffffffffc0200cd2:	a3250513          	addi	a0,a0,-1486 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200cd6:	ed6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(3)) != NULL);
ffffffffc0200cda:	00001697          	auipc	a3,0x1
ffffffffc0200cde:	7fe68693          	addi	a3,a3,2046 # ffffffffc02024d8 <commands+0x9e8>
ffffffffc0200ce2:	00002617          	auipc	a2,0x2
ffffffffc0200ce6:	a0660613          	addi	a2,a2,-1530 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200cea:	12d00593          	li	a1,301
ffffffffc0200cee:	00002517          	auipc	a0,0x2
ffffffffc0200cf2:	a1250513          	addi	a0,a0,-1518 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200cf6:	eb6ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_pages(1)) != NULL);
ffffffffc0200cfa:	00001697          	auipc	a3,0x1
ffffffffc0200cfe:	73e68693          	addi	a3,a3,1854 # ffffffffc0202438 <commands+0x948>
ffffffffc0200d02:	00002617          	auipc	a2,0x2
ffffffffc0200d06:	9e660613          	addi	a2,a2,-1562 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200d0a:	12300593          	li	a1,291
ffffffffc0200d0e:	00002517          	auipc	a0,0x2
ffffffffc0200d12:	9f250513          	addi	a0,a0,-1550 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200d16:	e96ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_pages(2)) != NULL);
ffffffffc0200d1a:	00001697          	auipc	a3,0x1
ffffffffc0200d1e:	6de68693          	addi	a3,a3,1758 # ffffffffc02023f8 <commands+0x908>
ffffffffc0200d22:	00002617          	auipc	a2,0x2
ffffffffc0200d26:	9c660613          	addi	a2,a2,-1594 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200d2a:	12100593          	li	a1,289
ffffffffc0200d2e:	00002517          	auipc	a0,0x2
ffffffffc0200d32:	9d250513          	addi	a0,a0,-1582 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200d36:	e76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p0 = alloc_pages(4)) != NULL);
ffffffffc0200d3a:	00001697          	auipc	a3,0x1
ffffffffc0200d3e:	67e68693          	addi	a3,a3,1662 # ffffffffc02023b8 <commands+0x8c8>
ffffffffc0200d42:	00002617          	auipc	a2,0x2
ffffffffc0200d46:	9a660613          	addi	a2,a2,-1626 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200d4a:	11f00593          	li	a1,287
ffffffffc0200d4e:	00002517          	auipc	a0,0x2
ffffffffc0200d52:	9b250513          	addi	a0,a0,-1614 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200d56:	e56ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d5a:	00001697          	auipc	a3,0x1
ffffffffc0200d5e:	5be68693          	addi	a3,a3,1470 # ffffffffc0202318 <commands+0x828>
ffffffffc0200d62:	00002617          	auipc	a2,0x2
ffffffffc0200d66:	98660613          	addi	a2,a2,-1658 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200d6a:	11400593          	li	a1,276
ffffffffc0200d6e:	00002517          	auipc	a0,0x2
ffffffffc0200d72:	99250513          	addi	a0,a0,-1646 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200d76:	e36ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d7a:	00001697          	auipc	a3,0x1
ffffffffc0200d7e:	55e68693          	addi	a3,a3,1374 # ffffffffc02022d8 <commands+0x7e8>
ffffffffc0200d82:	00002617          	auipc	a2,0x2
ffffffffc0200d86:	96660613          	addi	a2,a2,-1690 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200d8a:	11200593          	li	a1,274
ffffffffc0200d8e:	00002517          	auipc	a0,0x2
ffffffffc0200d92:	97250513          	addi	a0,a0,-1678 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200d96:	e16ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d9a <buddy_free_pages>:
buddy_free_pages(struct Page *base, size_t n) {
ffffffffc0200d9a:	715d                	addi	sp,sp,-80
ffffffffc0200d9c:	e486                	sd	ra,72(sp)
ffffffffc0200d9e:	e0a2                	sd	s0,64(sp)
ffffffffc0200da0:	fc26                	sd	s1,56(sp)
ffffffffc0200da2:	f84a                	sd	s2,48(sp)
ffffffffc0200da4:	f44e                	sd	s3,40(sp)
ffffffffc0200da6:	f052                	sd	s4,32(sp)
ffffffffc0200da8:	ec56                	sd	s5,24(sp)
ffffffffc0200daa:	e85a                	sd	s6,16(sp)
ffffffffc0200dac:	e45e                	sd	s7,8(sp)
    assert(n > 0);
ffffffffc0200dae:	16058f63          	beqz	a1,ffffffffc0200f2c <buddy_free_pages+0x192>
    size_t pnum = 1 << (base->property);
ffffffffc0200db2:	4918                	lw	a4,16(a0)
ffffffffc0200db4:	4b85                	li	s7,1
    if (n & (n - 1)) {
ffffffffc0200db6:	fff58793          	addi	a5,a1,-1
    size_t pnum = 1 << (base->property);
ffffffffc0200dba:	00eb963b          	sllw	a2,s7,a4
    if (n & (n - 1)) {
ffffffffc0200dbe:	8fed                	and	a5,a5,a1
ffffffffc0200dc0:	842a                	mv	s0,a0
    size_t pnum = 1 << (base->property);
ffffffffc0200dc2:	8bb2                	mv	s7,a2
    if (n & (n - 1)) {
ffffffffc0200dc4:	14079e63          	bnez	a5,ffffffffc0200f20 <buddy_free_pages+0x186>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200dc8:	18b61263          	bne	a2,a1,ffffffffc0200f4c <buddy_free_pages+0x1b2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200dcc:	00005797          	auipc	a5,0x5
ffffffffc0200dd0:	7ec78793          	addi	a5,a5,2028 # ffffffffc02065b8 <pages>
ffffffffc0200dd4:	639c                	ld	a5,0(a5)
ffffffffc0200dd6:	00002717          	auipc	a4,0x2
ffffffffc0200dda:	98a70713          	addi	a4,a4,-1654 # ffffffffc0202760 <buddy_pmm_manager+0x38>
ffffffffc0200dde:	630c                	ld	a1,0(a4)
ffffffffc0200de0:	40f407b3          	sub	a5,s0,a5
ffffffffc0200de4:	878d                	srai	a5,a5,0x3
ffffffffc0200de6:	02b787b3          	mul	a5,a5,a1
ffffffffc0200dea:	00002717          	auipc	a4,0x2
ffffffffc0200dee:	d6670713          	addi	a4,a4,-666 # ffffffffc0202b50 <nbase>
    cprintf("[TEST]Buddy System: Free NO.%d page about %d pages block: \n", page2ppn(base), pnum);
ffffffffc0200df2:	630c                	ld	a1,0(a4)
ffffffffc0200df4:	00001517          	auipc	a0,0x1
ffffffffc0200df8:	7b450513          	addi	a0,a0,1972 # ffffffffc02025a8 <commands+0xab8>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200dfc:	00005917          	auipc	s2,0x5
ffffffffc0200e00:	64490913          	addi	s2,s2,1604 # ffffffffc0206440 <buddy_s>
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));
ffffffffc0200e04:	01840993          	addi	s3,s0,24
ffffffffc0200e08:	00840a13          	addi	s4,s0,8
    cprintf("[TEST]Buddy System: Free NO.%d page about %d pages block: \n", page2ppn(base), pnum);
ffffffffc0200e0c:	95be                	add	a1,a1,a5
ffffffffc0200e0e:	aa8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    show_buddy_array();
ffffffffc0200e12:	a4fff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
ffffffffc0200e16:	01046783          	lwu	a5,16(s0)
    cprintf("[TEST]Buddy System: add to list\n");
ffffffffc0200e1a:	00001517          	auipc	a0,0x1
ffffffffc0200e1e:	7ce50513          	addi	a0,a0,1998 # ffffffffc02025e8 <commands+0xaf8>
ffffffffc0200e22:	0792                	slli	a5,a5,0x4
ffffffffc0200e24:	00f906b3          	add	a3,s2,a5
ffffffffc0200e28:	6a98                	ld	a4,16(a3)
    list_add(&(buddy_array[left_block->property]), &(left_block->page_link));
ffffffffc0200e2a:	07a1                	addi	a5,a5,8
ffffffffc0200e2c:	97ca                	add	a5,a5,s2
    prev->next = next->prev = elm;
ffffffffc0200e2e:	01373023          	sd	s3,0(a4)
ffffffffc0200e32:	0136b823          	sd	s3,16(a3)
    elm->prev = prev;
ffffffffc0200e36:	ec1c                	sd	a5,24(s0)
    elm->next = next;
ffffffffc0200e38:	f018                	sd	a4,32(s0)
    cprintf("[TEST]Buddy System: add to list\n");
ffffffffc0200e3a:	a7cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    show_buddy_array();
ffffffffc0200e3e:	a23ff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
    buddy = buddy_get_buddy(left_block);
ffffffffc0200e42:	8522                	mv	a0,s0
ffffffffc0200e44:	b29ff0ef          	jal	ra,ffffffffc020096c <buddy_get_buddy>
ffffffffc0200e48:	651c                	ld	a5,8(a0)
ffffffffc0200e4a:	84aa                	mv	s1,a0
ffffffffc0200e4c:	8385                	srli	a5,a5,0x1
    while (!PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200e4e:	8b85                	andi	a5,a5,1
ffffffffc0200e50:	e3d9                	bnez	a5,ffffffffc0200ed6 <buddy_free_pages+0x13c>
ffffffffc0200e52:	4818                	lw	a4,16(s0)
ffffffffc0200e54:	00092783          	lw	a5,0(s2)
ffffffffc0200e58:	06f77f63          	bleu	a5,a4,ffffffffc0200ed6 <buddy_free_pages+0x13c>
        cprintf("[TEST]Buddy System: Buddy free, MERGING!\n");
ffffffffc0200e5c:	00001a97          	auipc	s5,0x1
ffffffffc0200e60:	7b4a8a93          	addi	s5,s5,1972 # ffffffffc0202610 <commands+0xb20>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200e64:	5b75                	li	s6,-3
ffffffffc0200e66:	a031                	j	ffffffffc0200e72 <buddy_free_pages+0xd8>
    while (!PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200e68:	4818                	lw	a4,16(s0)
ffffffffc0200e6a:	00092783          	lw	a5,0(s2)
ffffffffc0200e6e:	06f77463          	bleu	a5,a4,ffffffffc0200ed6 <buddy_free_pages+0x13c>
        cprintf("[TEST]Buddy System: Buddy free, MERGING!\n");
ffffffffc0200e72:	8556                	mv	a0,s5
ffffffffc0200e74:	a42ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        if (left_block > buddy) { 
ffffffffc0200e78:	0084fd63          	bleu	s0,s1,ffffffffc0200e92 <buddy_free_pages+0xf8>
            left_block->property = 0;
ffffffffc0200e7c:	00042823          	sw	zero,16(s0)
ffffffffc0200e80:	616a302f          	amoand.d	zero,s6,(s4)
ffffffffc0200e84:	87a2                	mv	a5,s0
ffffffffc0200e86:	00848a13          	addi	s4,s1,8
ffffffffc0200e8a:	8426                	mv	s0,s1
ffffffffc0200e8c:	01848993          	addi	s3,s1,24
ffffffffc0200e90:	84be                	mv	s1,a5
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e92:	6c14                	ld	a3,24(s0)
ffffffffc0200e94:	701c                	ld	a5,32(s0)
        left_block->property += 1;
ffffffffc0200e96:	4818                	lw	a4,16(s0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200e98:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200e9a:	e394                	sd	a3,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200e9c:	6c88                	ld	a0,24(s1)
ffffffffc0200e9e:	708c                	ld	a1,32(s1)
ffffffffc0200ea0:	2705                	addiw	a4,a4,1
    __list_add(elm, listelm, listelm->next);
ffffffffc0200ea2:	02071793          	slli	a5,a4,0x20
ffffffffc0200ea6:	83f1                	srli	a5,a5,0x1c
    prev->next = next;
ffffffffc0200ea8:	e50c                	sd	a1,8(a0)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200eaa:	00f90633          	add	a2,s2,a5
ffffffffc0200eae:	6a14                	ld	a3,16(a2)
    next->prev = prev;
ffffffffc0200eb0:	e188                	sd	a0,0(a1)
ffffffffc0200eb2:	c818                	sw	a4,16(s0)
    prev->next = next->prev = elm;
ffffffffc0200eb4:	0136b023          	sd	s3,0(a3)
        list_add(&(buddy_array[left_block->property]), &(left_block->page_link)); 
ffffffffc0200eb8:	07a1                	addi	a5,a5,8
ffffffffc0200eba:	01363823          	sd	s3,16(a2)
ffffffffc0200ebe:	97ca                	add	a5,a5,s2
    elm->prev = prev;
ffffffffc0200ec0:	ec1c                	sd	a5,24(s0)
    elm->next = next;
ffffffffc0200ec2:	f014                	sd	a3,32(s0)
        show_buddy_array();
ffffffffc0200ec4:	99dff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
        buddy = buddy_get_buddy(left_block);
ffffffffc0200ec8:	8522                	mv	a0,s0
ffffffffc0200eca:	aa3ff0ef          	jal	ra,ffffffffc020096c <buddy_get_buddy>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200ece:	651c                	ld	a5,8(a0)
ffffffffc0200ed0:	84aa                	mv	s1,a0
    while (!PageProperty(buddy) && left_block->property < max_order) {
ffffffffc0200ed2:	8b89                	andi	a5,a5,2
ffffffffc0200ed4:	dbd1                	beqz	a5,ffffffffc0200e68 <buddy_free_pages+0xce>
    cprintf("[TEST]Buddy System: Buddy array finished FREE:\n");
ffffffffc0200ed6:	00001517          	auipc	a0,0x1
ffffffffc0200eda:	76a50513          	addi	a0,a0,1898 # ffffffffc0202640 <commands+0xb50>
ffffffffc0200ede:	9d8ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200ee2:	57f5                	li	a5,-3
ffffffffc0200ee4:	60fa302f          	amoand.d	zero,a5,(s4)
    nr_free += pnum;
ffffffffc0200ee8:	15892783          	lw	a5,344(s2)
ffffffffc0200eec:	01778bbb          	addw	s7,a5,s7
ffffffffc0200ef0:	00005797          	auipc	a5,0x5
ffffffffc0200ef4:	6b77a423          	sw	s7,1704(a5) # ffffffffc0206598 <buddy_s+0x158>
    show_buddy_array();
ffffffffc0200ef8:	969ff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
}
ffffffffc0200efc:	6406                	ld	s0,64(sp)
    cprintf("[TEST]Buddy System: nr_free is %d\n", nr_free);
ffffffffc0200efe:	15892583          	lw	a1,344(s2)
}
ffffffffc0200f02:	60a6                	ld	ra,72(sp)
ffffffffc0200f04:	74e2                	ld	s1,56(sp)
ffffffffc0200f06:	7942                	ld	s2,48(sp)
ffffffffc0200f08:	79a2                	ld	s3,40(sp)
ffffffffc0200f0a:	7a02                	ld	s4,32(sp)
ffffffffc0200f0c:	6ae2                	ld	s5,24(sp)
ffffffffc0200f0e:	6b42                	ld	s6,16(sp)
ffffffffc0200f10:	6ba2                	ld	s7,8(sp)
    cprintf("[TEST]Buddy System: nr_free is %d\n", nr_free);
ffffffffc0200f12:	00001517          	auipc	a0,0x1
ffffffffc0200f16:	75e50513          	addi	a0,a0,1886 # ffffffffc0202670 <commands+0xb80>
}
ffffffffc0200f1a:	6161                	addi	sp,sp,80
    cprintf("[TEST]Buddy System: nr_free is %d\n", nr_free);
ffffffffc0200f1c:	99aff06f          	j	ffffffffc02000b6 <cprintf>
    size_t res = 1;
ffffffffc0200f20:	4785                	li	a5,1
            n = n >> 1;
ffffffffc0200f22:	8185                	srli	a1,a1,0x1
            res = res << 1;
ffffffffc0200f24:	0786                	slli	a5,a5,0x1
        while (n) {
ffffffffc0200f26:	fdf5                	bnez	a1,ffffffffc0200f22 <buddy_free_pages+0x188>
            res = res << 1;
ffffffffc0200f28:	85be                	mv	a1,a5
ffffffffc0200f2a:	bd79                	j	ffffffffc0200dc8 <buddy_free_pages+0x2e>
    assert(n > 0);
ffffffffc0200f2c:	00001697          	auipc	a3,0x1
ffffffffc0200f30:	7b468693          	addi	a3,a3,1972 # ffffffffc02026e0 <commands+0xbf0>
ffffffffc0200f34:	00001617          	auipc	a2,0x1
ffffffffc0200f38:	7b460613          	addi	a2,a2,1972 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200f3c:	0d400593          	li	a1,212
ffffffffc0200f40:	00001517          	auipc	a0,0x1
ffffffffc0200f44:	7c050513          	addi	a0,a0,1984 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200f48:	c64ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(ROUNDUP2(n) == pnum);
ffffffffc0200f4c:	00001697          	auipc	a3,0x1
ffffffffc0200f50:	64468693          	addi	a3,a3,1604 # ffffffffc0202590 <commands+0xaa0>
ffffffffc0200f54:	00001617          	auipc	a2,0x1
ffffffffc0200f58:	79460613          	addi	a2,a2,1940 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc0200f5c:	0d600593          	li	a1,214
ffffffffc0200f60:	00001517          	auipc	a0,0x1
ffffffffc0200f64:	7a050513          	addi	a0,a0,1952 # ffffffffc0202700 <commands+0xc10>
ffffffffc0200f68:	c44ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200f6c <buddy_alloc_pages>:
buddy_alloc_pages(size_t n) {
ffffffffc0200f6c:	7119                	addi	sp,sp,-128
ffffffffc0200f6e:	fc86                	sd	ra,120(sp)
ffffffffc0200f70:	f8a2                	sd	s0,112(sp)
ffffffffc0200f72:	f4a6                	sd	s1,104(sp)
ffffffffc0200f74:	f0ca                	sd	s2,96(sp)
ffffffffc0200f76:	ecce                	sd	s3,88(sp)
ffffffffc0200f78:	e8d2                	sd	s4,80(sp)
ffffffffc0200f7a:	e4d6                	sd	s5,72(sp)
ffffffffc0200f7c:	e0da                	sd	s6,64(sp)
ffffffffc0200f7e:	fc5e                	sd	s7,56(sp)
ffffffffc0200f80:	f862                	sd	s8,48(sp)
ffffffffc0200f82:	f466                	sd	s9,40(sp)
ffffffffc0200f84:	f06a                	sd	s10,32(sp)
ffffffffc0200f86:	ec6e                	sd	s11,24(sp)
    assert(n > 0);
ffffffffc0200f88:	24050263          	beqz	a0,ffffffffc02011cc <buddy_alloc_pages+0x260>
    if (n > nr_free) {
ffffffffc0200f8c:	00005797          	auipc	a5,0x5
ffffffffc0200f90:	60c7e783          	lwu	a5,1548(a5) # ffffffffc0206598 <buddy_s+0x158>
ffffffffc0200f94:	20a7e263          	bltu	a5,a0,ffffffffc0201198 <buddy_alloc_pages+0x22c>
    if (n & (n - 1)) {
ffffffffc0200f98:	fff50793          	addi	a5,a0,-1
ffffffffc0200f9c:	8fe9                	and	a5,a5,a0
ffffffffc0200f9e:	8a2a                	mv	s4,a0
ffffffffc0200fa0:	1e079663          	bnez	a5,ffffffffc020118c <buddy_alloc_pages+0x220>
    while (n >> 1) {
ffffffffc0200fa4:	001a5693          	srli	a3,s4,0x1
ffffffffc0200fa8:	1e068a63          	beqz	a3,ffffffffc020119c <buddy_alloc_pages+0x230>
    unsigned int order = 0;
ffffffffc0200fac:	4c01                	li	s8,0
ffffffffc0200fae:	a011                	j	ffffffffc0200fb2 <buddy_alloc_pages+0x46>
        order ++;
ffffffffc0200fb0:	8c3e                	mv	s8,a5
    while (n >> 1) {
ffffffffc0200fb2:	8285                	srli	a3,a3,0x1
        order ++;
ffffffffc0200fb4:	001c079b          	addiw	a5,s8,1
    while (n >> 1) {
ffffffffc0200fb8:	fee5                	bnez	a3,ffffffffc0200fb0 <buddy_alloc_pages+0x44>
ffffffffc0200fba:	02079693          	slli	a3,a5,0x20
ffffffffc0200fbe:	2c09                	addiw	s8,s8,2
ffffffffc0200fc0:	9281                	srli	a3,a3,0x20
ffffffffc0200fc2:	00469993          	slli	s3,a3,0x4
ffffffffc0200fc6:	004c1d13          	slli	s10,s8,0x4
ffffffffc0200fca:	00898c93          	addi	s9,s3,8
ffffffffc0200fce:	84e2                	mv	s1,s8
ffffffffc0200fd0:	e462                	sd	s8,8(sp)
ffffffffc0200fd2:	0d21                	addi	s10,s10,8
    cprintf("[TEST]Buddy System: Allocating %d-->%d = 2^%d pages ...\n", n, pnum, order);
ffffffffc0200fd4:	85aa                	mv	a1,a0
ffffffffc0200fd6:	8652                	mv	a2,s4
ffffffffc0200fd8:	00001517          	auipc	a0,0x1
ffffffffc0200fdc:	14850513          	addi	a0,a0,328 # ffffffffc0202120 <commands+0x630>
ffffffffc0200fe0:	8d6ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (!list_empty(&(buddy_array[order]))) {
ffffffffc0200fe4:	00005b97          	auipc	s7,0x5
ffffffffc0200fe8:	45cb8b93          	addi	s7,s7,1116 # ffffffffc0206440 <buddy_s>
    show_buddy_array();
ffffffffc0200fec:	875ff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
ffffffffc0200ff0:	00248913          	addi	s2,s1,2
    return list->next == list;
ffffffffc0200ff4:	00449d93          	slli	s11,s1,0x4
ffffffffc0200ff8:	0912                	slli	s2,s2,0x4
ffffffffc0200ffa:	013b87b3          	add	a5,s7,s3
    if (!list_empty(&(buddy_array[order]))) {
ffffffffc0200ffe:	9cde                	add	s9,s9,s7
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0201000:	9d5e                	add	s10,s10,s7
ffffffffc0201002:	995e                	add	s2,s2,s7
ffffffffc0201004:	e03e                	sd	a5,0(sp)
ffffffffc0201006:	9dde                	add	s11,s11,s7
ffffffffc0201008:	2485                	addiw	s1,s1,1
ffffffffc020100a:	6782                	ld	a5,0(sp)
        for (int i = order+1;i < max_order + 1;i ++) {
ffffffffc020100c:	000ba503          	lw	a0,0(s7)
ffffffffc0201010:	0107b803          	ld	a6,16(a5)
ffffffffc0201014:	0015059b          	addiw	a1,a0,1
    if (!list_empty(&(buddy_array[order]))) {
ffffffffc0201018:	0f0c9063          	bne	s9,a6,ffffffffc02010f8 <buddy_alloc_pages+0x18c>
        for (int i = order+1;i < max_order + 1;i ++) {
ffffffffc020101c:	febc7ee3          	bleu	a1,s8,ffffffffc0201018 <buddy_alloc_pages+0xac>
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0201020:	010db783          	ld	a5,16(s11)
ffffffffc0201024:	16fd1263          	bne	s10,a5,ffffffffc0201188 <buddy_alloc_pages+0x21c>
ffffffffc0201028:	8426                	mv	s0,s1
ffffffffc020102a:	87ca                	mv	a5,s2
ffffffffc020102c:	a011                	j	ffffffffc0201030 <buddy_alloc_pages+0xc4>
ffffffffc020102e:	8432                	mv	s0,a2
        for (int i = order+1;i < max_order + 1;i ++) {
ffffffffc0201030:	0004071b          	sext.w	a4,s0
ffffffffc0201034:	feb772e3          	bleu	a1,a4,ffffffffc0201018 <buddy_alloc_pages+0xac>
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0201038:	6394                	ld	a3,0(a5)
ffffffffc020103a:	ff878713          	addi	a4,a5,-8
ffffffffc020103e:	00140613          	addi	a2,s0,1
ffffffffc0201042:	07c1                	addi	a5,a5,16
ffffffffc0201044:	fee685e3          	beq	a3,a4,ffffffffc020102e <buddy_alloc_pages+0xc2>
    assert(n > 0 && n <= max_order);
ffffffffc0201048:	16040263          	beqz	s0,ffffffffc02011ac <buddy_alloc_pages+0x240>
ffffffffc020104c:	1502                	slli	a0,a0,0x20
ffffffffc020104e:	9101                	srli	a0,a0,0x20
ffffffffc0201050:	14856e63          	bltu	a0,s0,ffffffffc02011ac <buddy_alloc_pages+0x240>
    assert(!list_empty(&(buddy_array[n])));
ffffffffc0201054:	00441793          	slli	a5,s0,0x4
ffffffffc0201058:	00fb89b3          	add	s3,s7,a5
ffffffffc020105c:	0109b703          	ld	a4,16(s3)
ffffffffc0201060:	07a1                	addi	a5,a5,8
ffffffffc0201062:	97de                	add	a5,a5,s7
ffffffffc0201064:	18f70463          	beq	a4,a5,ffffffffc02011ec <buddy_alloc_pages+0x280>
    cprintf("[TEST]Buddy System: SPLIT!\n");
ffffffffc0201068:	00001517          	auipc	a0,0x1
ffffffffc020106c:	18850513          	addi	a0,a0,392 # ffffffffc02021f0 <commands+0x700>
ffffffffc0201070:	846ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    page_b = page_a + (1 << (n - 1));
ffffffffc0201074:	fff4061b          	addiw	a2,s0,-1
ffffffffc0201078:	4b05                	li	s6,1
    return listelm->next;
ffffffffc020107a:	0109ba83          	ld	s5,16(s3)
ffffffffc020107e:	00cb173b          	sllw	a4,s6,a2
ffffffffc0201082:	00271b13          	slli	s6,a4,0x2
ffffffffc0201086:	9b3a                	add	s6,s6,a4
    page_a = le2page(list_next(&(buddy_array[n])), page_link);
ffffffffc0201088:	fe8a8593          	addi	a1,s5,-24
    page_b = page_a + (1 << (n - 1));
ffffffffc020108c:	0b0e                	slli	s6,s6,0x3
ffffffffc020108e:	9b2e                	add	s6,s6,a1
    page_a->property = n - 1;
ffffffffc0201090:	fecaac23          	sw	a2,-8(s5)
    page_b->property = n - 1;
ffffffffc0201094:	00cb2823          	sw	a2,16(s6)
    cprintf("[TEST]Buddy System: a is %d ",page_a);
ffffffffc0201098:	00001517          	auipc	a0,0x1
ffffffffc020109c:	17850513          	addi	a0,a0,376 # ffffffffc0202210 <commands+0x720>
ffffffffc02010a0:	816ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("[TEST]Buddy System: b is %d ",page_b);
ffffffffc02010a4:	85da                	mv	a1,s6
ffffffffc02010a6:	00001517          	auipc	a0,0x1
ffffffffc02010aa:	18a50513          	addi	a0,a0,394 # ffffffffc0202230 <commands+0x740>
ffffffffc02010ae:	808ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc02010b2:	0109b703          	ld	a4,16(s3)
    list_add(&(buddy_array[n-1]), &(page_a->page_link));
ffffffffc02010b6:	147d                	addi	s0,s0,-1
    __list_add(elm, listelm, listelm->next);
ffffffffc02010b8:	0412                	slli	s0,s0,0x4
    __list_del(listelm->prev, listelm->next);
ffffffffc02010ba:	6310                	ld	a2,0(a4)
ffffffffc02010bc:	6718                	ld	a4,8(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc02010be:	008b86b3          	add	a3,s7,s0
ffffffffc02010c2:	0421                	addi	s0,s0,8
    prev->next = next;
ffffffffc02010c4:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc02010c6:	e310                	sd	a2,0(a4)
    __list_add(elm, listelm, listelm->next);
ffffffffc02010c8:	6a98                	ld	a4,16(a3)
ffffffffc02010ca:	945e                	add	s0,s0,s7
    prev->next = next->prev = elm;
ffffffffc02010cc:	0156b823          	sd	s5,16(a3)
    elm->prev = prev;
ffffffffc02010d0:	008ab023          	sd	s0,0(s5)
    list_add(&(page_a->page_link), &(page_b->page_link));
ffffffffc02010d4:	018b0693          	addi	a3,s6,24
    prev->next = next->prev = elm;
ffffffffc02010d8:	e314                	sd	a3,0(a4)
ffffffffc02010da:	00dab423          	sd	a3,8(s5)
    elm->next = next;
ffffffffc02010de:	02eb3023          	sd	a4,32(s6)
    elm->prev = prev;
ffffffffc02010e2:	015b3c23          	sd	s5,24(s6)
                cprintf("[!]BS: Buddy array after SPLITT:\n");
ffffffffc02010e6:	00001517          	auipc	a0,0x1
ffffffffc02010ea:	16a50513          	addi	a0,a0,362 # ffffffffc0202250 <commands+0x760>
ffffffffc02010ee:	fc9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
                show_buddy_array();
ffffffffc02010f2:	f6eff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
                break;
ffffffffc02010f6:	bf11                	j	ffffffffc020100a <buddy_alloc_pages+0x9e>
    __list_del(listelm->prev, listelm->next);
ffffffffc02010f8:	00083703          	ld	a4,0(a6)
ffffffffc02010fc:	00883783          	ld	a5,8(a6)
        page = le2page(list_next(&(buddy_array[order])), page_link);
ffffffffc0201100:	fe880413          	addi	s0,a6,-24
    prev->next = next;
ffffffffc0201104:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201106:	e398                	sd	a4,0(a5)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201108:	4789                	li	a5,2
ffffffffc020110a:	ff080713          	addi	a4,a6,-16
ffffffffc020110e:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0201112:	00005797          	auipc	a5,0x5
ffffffffc0201116:	4a678793          	addi	a5,a5,1190 # ffffffffc02065b8 <pages>
ffffffffc020111a:	639c                	ld	a5,0(a5)
ffffffffc020111c:	00001717          	auipc	a4,0x1
ffffffffc0201120:	64470713          	addi	a4,a4,1604 # ffffffffc0202760 <buddy_pmm_manager+0x38>
ffffffffc0201124:	6318                	ld	a4,0(a4)
ffffffffc0201126:	40f407b3          	sub	a5,s0,a5
ffffffffc020112a:	878d                	srai	a5,a5,0x3
ffffffffc020112c:	02e787b3          	mul	a5,a5,a4
ffffffffc0201130:	00002717          	auipc	a4,0x2
ffffffffc0201134:	a2070713          	addi	a4,a4,-1504 # ffffffffc0202b50 <nbase>
        cprintf("[TEST]Buddy System: Buddy array after ALLOC NO.%d page:\n", page2ppn(page));
ffffffffc0201138:	630c                	ld	a1,0(a4)
ffffffffc020113a:	00001517          	auipc	a0,0x1
ffffffffc020113e:	02650513          	addi	a0,a0,38 # ffffffffc0202160 <commands+0x670>
ffffffffc0201142:	95be                	add	a1,a1,a5
ffffffffc0201144:	f73fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
        show_buddy_array();
ffffffffc0201148:	f18ff0ef          	jal	ra,ffffffffc0200860 <show_buddy_array>
    nr_free -= pnum;
ffffffffc020114c:	158ba783          	lw	a5,344(s7)
    cprintf("[!]BS: nr_free: %d\n", nr_free);
ffffffffc0201150:	00001517          	auipc	a0,0x1
ffffffffc0201154:	05050513          	addi	a0,a0,80 # ffffffffc02021a0 <commands+0x6b0>
    nr_free -= pnum;
ffffffffc0201158:	414785bb          	subw	a1,a5,s4
ffffffffc020115c:	00005797          	auipc	a5,0x5
ffffffffc0201160:	42b7ae23          	sw	a1,1084(a5) # ffffffffc0206598 <buddy_s+0x158>
    cprintf("[!]BS: nr_free: %d\n", nr_free);
ffffffffc0201164:	f53fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
}
ffffffffc0201168:	8522                	mv	a0,s0
ffffffffc020116a:	70e6                	ld	ra,120(sp)
ffffffffc020116c:	7446                	ld	s0,112(sp)
ffffffffc020116e:	74a6                	ld	s1,104(sp)
ffffffffc0201170:	7906                	ld	s2,96(sp)
ffffffffc0201172:	69e6                	ld	s3,88(sp)
ffffffffc0201174:	6a46                	ld	s4,80(sp)
ffffffffc0201176:	6aa6                	ld	s5,72(sp)
ffffffffc0201178:	6b06                	ld	s6,64(sp)
ffffffffc020117a:	7be2                	ld	s7,56(sp)
ffffffffc020117c:	7c42                	ld	s8,48(sp)
ffffffffc020117e:	7ca2                	ld	s9,40(sp)
ffffffffc0201180:	7d02                	ld	s10,32(sp)
ffffffffc0201182:	6de2                	ld	s11,24(sp)
ffffffffc0201184:	6109                	addi	sp,sp,128
ffffffffc0201186:	8082                	ret
            if (!list_empty(&(buddy_array[i]))) {
ffffffffc0201188:	6422                	ld	s0,8(sp)
ffffffffc020118a:	bd7d                	j	ffffffffc0201048 <buddy_alloc_pages+0xdc>
    if (n & (n - 1)) {
ffffffffc020118c:	87aa                	mv	a5,a0
    size_t res = 1;
ffffffffc020118e:	4a05                	li	s4,1
            n = n >> 1;
ffffffffc0201190:	8385                	srli	a5,a5,0x1
            res = res << 1;
ffffffffc0201192:	0a06                	slli	s4,s4,0x1
        while (n) {
ffffffffc0201194:	fff5                	bnez	a5,ffffffffc0201190 <buddy_alloc_pages+0x224>
ffffffffc0201196:	b539                	j	ffffffffc0200fa4 <buddy_alloc_pages+0x38>
        return NULL;
ffffffffc0201198:	4401                	li	s0,0
ffffffffc020119a:	b7f9                	j	ffffffffc0201168 <buddy_alloc_pages+0x1fc>
    while (n >> 1) {
ffffffffc020119c:	4785                	li	a5,1
ffffffffc020119e:	4d61                	li	s10,24
ffffffffc02011a0:	4485                	li	s1,1
ffffffffc02011a2:	e43e                	sd	a5,8(sp)
ffffffffc02011a4:	4ca1                	li	s9,8
ffffffffc02011a6:	4c05                	li	s8,1
ffffffffc02011a8:	4981                	li	s3,0
ffffffffc02011aa:	b52d                	j	ffffffffc0200fd4 <buddy_alloc_pages+0x68>
    assert(n > 0 && n <= max_order);
ffffffffc02011ac:	00001697          	auipc	a3,0x1
ffffffffc02011b0:	00c68693          	addi	a3,a3,12 # ffffffffc02021b8 <commands+0x6c8>
ffffffffc02011b4:	00001617          	auipc	a2,0x1
ffffffffc02011b8:	53460613          	addi	a2,a2,1332 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc02011bc:	08b00593          	li	a1,139
ffffffffc02011c0:	00001517          	auipc	a0,0x1
ffffffffc02011c4:	54050513          	addi	a0,a0,1344 # ffffffffc0202700 <commands+0xc10>
ffffffffc02011c8:	9e4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(n > 0);
ffffffffc02011cc:	00001697          	auipc	a3,0x1
ffffffffc02011d0:	51468693          	addi	a3,a3,1300 # ffffffffc02026e0 <commands+0xbf0>
ffffffffc02011d4:	00001617          	auipc	a2,0x1
ffffffffc02011d8:	51460613          	addi	a2,a2,1300 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc02011dc:	0a900593          	li	a1,169
ffffffffc02011e0:	00001517          	auipc	a0,0x1
ffffffffc02011e4:	52050513          	addi	a0,a0,1312 # ffffffffc0202700 <commands+0xc10>
ffffffffc02011e8:	9c4ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    assert(!list_empty(&(buddy_array[n])));
ffffffffc02011ec:	00001697          	auipc	a3,0x1
ffffffffc02011f0:	fe468693          	addi	a3,a3,-28 # ffffffffc02021d0 <commands+0x6e0>
ffffffffc02011f4:	00001617          	auipc	a2,0x1
ffffffffc02011f8:	4f460613          	addi	a2,a2,1268 # ffffffffc02026e8 <commands+0xbf8>
ffffffffc02011fc:	08c00593          	li	a1,140
ffffffffc0201200:	00001517          	auipc	a0,0x1
ffffffffc0201204:	50050513          	addi	a0,a0,1280 # ffffffffc0202700 <commands+0xc10>
ffffffffc0201208:	9a4ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc020120c <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020120c:	100027f3          	csrr	a5,sstatus
ffffffffc0201210:	8b89                	andi	a5,a5,2
ffffffffc0201212:	eb89                	bnez	a5,ffffffffc0201224 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201214:	00005797          	auipc	a5,0x5
ffffffffc0201218:	39478793          	addi	a5,a5,916 # ffffffffc02065a8 <pmm_manager>
ffffffffc020121c:	639c                	ld	a5,0(a5)
ffffffffc020121e:	0187b303          	ld	t1,24(a5)
ffffffffc0201222:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc0201224:	1141                	addi	sp,sp,-16
ffffffffc0201226:	e406                	sd	ra,8(sp)
ffffffffc0201228:	e022                	sd	s0,0(sp)
ffffffffc020122a:	842a                	mv	s0,a0
        intr_disable();
ffffffffc020122c:	a38ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201230:	00005797          	auipc	a5,0x5
ffffffffc0201234:	37878793          	addi	a5,a5,888 # ffffffffc02065a8 <pmm_manager>
ffffffffc0201238:	639c                	ld	a5,0(a5)
ffffffffc020123a:	8522                	mv	a0,s0
ffffffffc020123c:	6f9c                	ld	a5,24(a5)
ffffffffc020123e:	9782                	jalr	a5
ffffffffc0201240:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201242:	a1cff0ef          	jal	ra,ffffffffc020045e <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201246:	8522                	mv	a0,s0
ffffffffc0201248:	60a2                	ld	ra,8(sp)
ffffffffc020124a:	6402                	ld	s0,0(sp)
ffffffffc020124c:	0141                	addi	sp,sp,16
ffffffffc020124e:	8082                	ret

ffffffffc0201250 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201250:	100027f3          	csrr	a5,sstatus
ffffffffc0201254:	8b89                	andi	a5,a5,2
ffffffffc0201256:	eb89                	bnez	a5,ffffffffc0201268 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201258:	00005797          	auipc	a5,0x5
ffffffffc020125c:	35078793          	addi	a5,a5,848 # ffffffffc02065a8 <pmm_manager>
ffffffffc0201260:	639c                	ld	a5,0(a5)
ffffffffc0201262:	0207b303          	ld	t1,32(a5)
ffffffffc0201266:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201268:	1101                	addi	sp,sp,-32
ffffffffc020126a:	ec06                	sd	ra,24(sp)
ffffffffc020126c:	e822                	sd	s0,16(sp)
ffffffffc020126e:	e426                	sd	s1,8(sp)
ffffffffc0201270:	842a                	mv	s0,a0
ffffffffc0201272:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201274:	9f0ff0ef          	jal	ra,ffffffffc0200464 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201278:	00005797          	auipc	a5,0x5
ffffffffc020127c:	33078793          	addi	a5,a5,816 # ffffffffc02065a8 <pmm_manager>
ffffffffc0201280:	639c                	ld	a5,0(a5)
ffffffffc0201282:	85a6                	mv	a1,s1
ffffffffc0201284:	8522                	mv	a0,s0
ffffffffc0201286:	739c                	ld	a5,32(a5)
ffffffffc0201288:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020128a:	6442                	ld	s0,16(sp)
ffffffffc020128c:	60e2                	ld	ra,24(sp)
ffffffffc020128e:	64a2                	ld	s1,8(sp)
ffffffffc0201290:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201292:	9ccff06f          	j	ffffffffc020045e <intr_enable>

ffffffffc0201296 <pmm_init>:
    pmm_manager = &buddy_pmm_manager;
ffffffffc0201296:	00001797          	auipc	a5,0x1
ffffffffc020129a:	49278793          	addi	a5,a5,1170 # ffffffffc0202728 <buddy_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020129e:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc02012a0:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012a2:	00001517          	auipc	a0,0x1
ffffffffc02012a6:	53e50513          	addi	a0,a0,1342 # ffffffffc02027e0 <buddy_pmm_manager+0xb8>
void pmm_init(void) {
ffffffffc02012aa:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02012ac:	00005717          	auipc	a4,0x5
ffffffffc02012b0:	2ef73e23          	sd	a5,764(a4) # ffffffffc02065a8 <pmm_manager>
void pmm_init(void) {
ffffffffc02012b4:	e822                	sd	s0,16(sp)
ffffffffc02012b6:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_pmm_manager;
ffffffffc02012b8:	00005417          	auipc	s0,0x5
ffffffffc02012bc:	2f040413          	addi	s0,s0,752 # ffffffffc02065a8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02012c0:	df7fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02012c4:	601c                	ld	a5,0(s0)
ffffffffc02012c6:	679c                	ld	a5,8(a5)
ffffffffc02012c8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012ca:	57f5                	li	a5,-3
ffffffffc02012cc:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02012ce:	00001517          	auipc	a0,0x1
ffffffffc02012d2:	52a50513          	addi	a0,a0,1322 # ffffffffc02027f8 <buddy_pmm_manager+0xd0>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02012d6:	00005717          	auipc	a4,0x5
ffffffffc02012da:	2cf73d23          	sd	a5,730(a4) # ffffffffc02065b0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02012de:	dd9fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02012e2:	46c5                	li	a3,17
ffffffffc02012e4:	06ee                	slli	a3,a3,0x1b
ffffffffc02012e6:	40100613          	li	a2,1025
ffffffffc02012ea:	16fd                	addi	a3,a3,-1
ffffffffc02012ec:	0656                	slli	a2,a2,0x15
ffffffffc02012ee:	07e005b7          	lui	a1,0x7e00
ffffffffc02012f2:	00001517          	auipc	a0,0x1
ffffffffc02012f6:	51e50513          	addi	a0,a0,1310 # ffffffffc0202810 <buddy_pmm_manager+0xe8>
ffffffffc02012fa:	dbdfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02012fe:	777d                	lui	a4,0xfffff
ffffffffc0201300:	00006797          	auipc	a5,0x6
ffffffffc0201304:	2bf78793          	addi	a5,a5,703 # ffffffffc02075bf <end+0xfff>
ffffffffc0201308:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020130a:	00088737          	lui	a4,0x88
ffffffffc020130e:	00005697          	auipc	a3,0x5
ffffffffc0201312:	10e6b923          	sd	a4,274(a3) # ffffffffc0206420 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201316:	4601                	li	a2,0
ffffffffc0201318:	00005717          	auipc	a4,0x5
ffffffffc020131c:	2af73023          	sd	a5,672(a4) # ffffffffc02065b8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201320:	4681                	li	a3,0
ffffffffc0201322:	00005897          	auipc	a7,0x5
ffffffffc0201326:	0fe88893          	addi	a7,a7,254 # ffffffffc0206420 <npage>
ffffffffc020132a:	00005597          	auipc	a1,0x5
ffffffffc020132e:	28e58593          	addi	a1,a1,654 # ffffffffc02065b8 <pages>
ffffffffc0201332:	4805                	li	a6,1
ffffffffc0201334:	fff80537          	lui	a0,0xfff80
ffffffffc0201338:	a011                	j	ffffffffc020133c <pmm_init+0xa6>
ffffffffc020133a:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020133c:	97b2                	add	a5,a5,a2
ffffffffc020133e:	07a1                	addi	a5,a5,8
ffffffffc0201340:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201344:	0008b703          	ld	a4,0(a7)
ffffffffc0201348:	0685                	addi	a3,a3,1
ffffffffc020134a:	02860613          	addi	a2,a2,40
ffffffffc020134e:	00a707b3          	add	a5,a4,a0
ffffffffc0201352:	fef6e4e3          	bltu	a3,a5,ffffffffc020133a <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201356:	6190                	ld	a2,0(a1)
ffffffffc0201358:	00271793          	slli	a5,a4,0x2
ffffffffc020135c:	97ba                	add	a5,a5,a4
ffffffffc020135e:	fec006b7          	lui	a3,0xfec00
ffffffffc0201362:	078e                	slli	a5,a5,0x3
ffffffffc0201364:	96b2                	add	a3,a3,a2
ffffffffc0201366:	96be                	add	a3,a3,a5
ffffffffc0201368:	c02007b7          	lui	a5,0xc0200
ffffffffc020136c:	08f6e863          	bltu	a3,a5,ffffffffc02013fc <pmm_init+0x166>
ffffffffc0201370:	00005497          	auipc	s1,0x5
ffffffffc0201374:	24048493          	addi	s1,s1,576 # ffffffffc02065b0 <va_pa_offset>
ffffffffc0201378:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc020137a:	45c5                	li	a1,17
ffffffffc020137c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020137e:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201380:	04b6e963          	bltu	a3,a1,ffffffffc02013d2 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201384:	601c                	ld	a5,0(s0)
ffffffffc0201386:	7b9c                	ld	a5,48(a5)
ffffffffc0201388:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020138a:	00001517          	auipc	a0,0x1
ffffffffc020138e:	51e50513          	addi	a0,a0,1310 # ffffffffc02028a8 <buddy_pmm_manager+0x180>
ffffffffc0201392:	d25fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201396:	00004697          	auipc	a3,0x4
ffffffffc020139a:	c6a68693          	addi	a3,a3,-918 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc020139e:	00005797          	auipc	a5,0x5
ffffffffc02013a2:	08d7b523          	sd	a3,138(a5) # ffffffffc0206428 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc02013a6:	c02007b7          	lui	a5,0xc0200
ffffffffc02013aa:	06f6e563          	bltu	a3,a5,ffffffffc0201414 <pmm_init+0x17e>
ffffffffc02013ae:	609c                	ld	a5,0(s1)
}
ffffffffc02013b0:	6442                	ld	s0,16(sp)
ffffffffc02013b2:	60e2                	ld	ra,24(sp)
ffffffffc02013b4:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013b6:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc02013b8:	8e9d                	sub	a3,a3,a5
ffffffffc02013ba:	00005797          	auipc	a5,0x5
ffffffffc02013be:	1ed7b323          	sd	a3,486(a5) # ffffffffc02065a0 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013c2:	00001517          	auipc	a0,0x1
ffffffffc02013c6:	50650513          	addi	a0,a0,1286 # ffffffffc02028c8 <buddy_pmm_manager+0x1a0>
ffffffffc02013ca:	8636                	mv	a2,a3
}
ffffffffc02013cc:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02013ce:	ce9fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02013d2:	6785                	lui	a5,0x1
ffffffffc02013d4:	17fd                	addi	a5,a5,-1
ffffffffc02013d6:	96be                	add	a3,a3,a5
ffffffffc02013d8:	77fd                	lui	a5,0xfffff
ffffffffc02013da:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02013dc:	00c6d793          	srli	a5,a3,0xc
ffffffffc02013e0:	04e7f663          	bleu	a4,a5,ffffffffc020142c <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02013e4:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02013e6:	97aa                	add	a5,a5,a0
ffffffffc02013e8:	00279513          	slli	a0,a5,0x2
ffffffffc02013ec:	953e                	add	a0,a0,a5
ffffffffc02013ee:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02013f0:	8d95                	sub	a1,a1,a3
ffffffffc02013f2:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02013f4:	81b1                	srli	a1,a1,0xc
ffffffffc02013f6:	9532                	add	a0,a0,a2
ffffffffc02013f8:	9782                	jalr	a5
ffffffffc02013fa:	b769                	j	ffffffffc0201384 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02013fc:	00001617          	auipc	a2,0x1
ffffffffc0201400:	44460613          	addi	a2,a2,1092 # ffffffffc0202840 <buddy_pmm_manager+0x118>
ffffffffc0201404:	07000593          	li	a1,112
ffffffffc0201408:	00001517          	auipc	a0,0x1
ffffffffc020140c:	46050513          	addi	a0,a0,1120 # ffffffffc0202868 <buddy_pmm_manager+0x140>
ffffffffc0201410:	f9dfe0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201414:	00001617          	auipc	a2,0x1
ffffffffc0201418:	42c60613          	addi	a2,a2,1068 # ffffffffc0202840 <buddy_pmm_manager+0x118>
ffffffffc020141c:	08b00593          	li	a1,139
ffffffffc0201420:	00001517          	auipc	a0,0x1
ffffffffc0201424:	44850513          	addi	a0,a0,1096 # ffffffffc0202868 <buddy_pmm_manager+0x140>
ffffffffc0201428:	f85fe0ef          	jal	ra,ffffffffc02003ac <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020142c:	00001617          	auipc	a2,0x1
ffffffffc0201430:	44c60613          	addi	a2,a2,1100 # ffffffffc0202878 <buddy_pmm_manager+0x150>
ffffffffc0201434:	06c00593          	li	a1,108
ffffffffc0201438:	00001517          	auipc	a0,0x1
ffffffffc020143c:	46050513          	addi	a0,a0,1120 # ffffffffc0202898 <buddy_pmm_manager+0x170>
ffffffffc0201440:	f6dfe0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0201444 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201444:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201448:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020144a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020144e:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201450:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201454:	f022                	sd	s0,32(sp)
ffffffffc0201456:	ec26                	sd	s1,24(sp)
ffffffffc0201458:	e84a                	sd	s2,16(sp)
ffffffffc020145a:	f406                	sd	ra,40(sp)
ffffffffc020145c:	e44e                	sd	s3,8(sp)
ffffffffc020145e:	84aa                	mv	s1,a0
ffffffffc0201460:	892e                	mv	s2,a1
ffffffffc0201462:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201466:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0201468:	03067e63          	bleu	a6,a2,ffffffffc02014a4 <printnum+0x60>
ffffffffc020146c:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc020146e:	00805763          	blez	s0,ffffffffc020147c <printnum+0x38>
ffffffffc0201472:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201474:	85ca                	mv	a1,s2
ffffffffc0201476:	854e                	mv	a0,s3
ffffffffc0201478:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020147a:	fc65                	bnez	s0,ffffffffc0201472 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020147c:	1a02                	slli	s4,s4,0x20
ffffffffc020147e:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201482:	00001797          	auipc	a5,0x1
ffffffffc0201486:	61678793          	addi	a5,a5,1558 # ffffffffc0202a98 <error_string+0x38>
ffffffffc020148a:	9a3e                	add	s4,s4,a5
}
ffffffffc020148c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020148e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201492:	70a2                	ld	ra,40(sp)
ffffffffc0201494:	69a2                	ld	s3,8(sp)
ffffffffc0201496:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201498:	85ca                	mv	a1,s2
ffffffffc020149a:	8326                	mv	t1,s1
}
ffffffffc020149c:	6942                	ld	s2,16(sp)
ffffffffc020149e:	64e2                	ld	s1,24(sp)
ffffffffc02014a0:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02014a2:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc02014a4:	03065633          	divu	a2,a2,a6
ffffffffc02014a8:	8722                	mv	a4,s0
ffffffffc02014aa:	f9bff0ef          	jal	ra,ffffffffc0201444 <printnum>
ffffffffc02014ae:	b7f9                	j	ffffffffc020147c <printnum+0x38>

ffffffffc02014b0 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc02014b0:	7119                	addi	sp,sp,-128
ffffffffc02014b2:	f4a6                	sd	s1,104(sp)
ffffffffc02014b4:	f0ca                	sd	s2,96(sp)
ffffffffc02014b6:	e8d2                	sd	s4,80(sp)
ffffffffc02014b8:	e4d6                	sd	s5,72(sp)
ffffffffc02014ba:	e0da                	sd	s6,64(sp)
ffffffffc02014bc:	fc5e                	sd	s7,56(sp)
ffffffffc02014be:	f862                	sd	s8,48(sp)
ffffffffc02014c0:	f06a                	sd	s10,32(sp)
ffffffffc02014c2:	fc86                	sd	ra,120(sp)
ffffffffc02014c4:	f8a2                	sd	s0,112(sp)
ffffffffc02014c6:	ecce                	sd	s3,88(sp)
ffffffffc02014c8:	f466                	sd	s9,40(sp)
ffffffffc02014ca:	ec6e                	sd	s11,24(sp)
ffffffffc02014cc:	892a                	mv	s2,a0
ffffffffc02014ce:	84ae                	mv	s1,a1
ffffffffc02014d0:	8d32                	mv	s10,a2
ffffffffc02014d2:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02014d4:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014d6:	00001a17          	auipc	s4,0x1
ffffffffc02014da:	432a0a13          	addi	s4,s4,1074 # ffffffffc0202908 <buddy_pmm_manager+0x1e0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02014de:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02014e2:	00001c17          	auipc	s8,0x1
ffffffffc02014e6:	57ec0c13          	addi	s8,s8,1406 # ffffffffc0202a60 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02014ea:	000d4503          	lbu	a0,0(s10)
ffffffffc02014ee:	02500793          	li	a5,37
ffffffffc02014f2:	001d0413          	addi	s0,s10,1
ffffffffc02014f6:	00f50e63          	beq	a0,a5,ffffffffc0201512 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02014fa:	c521                	beqz	a0,ffffffffc0201542 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02014fc:	02500993          	li	s3,37
ffffffffc0201500:	a011                	j	ffffffffc0201504 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0201502:	c121                	beqz	a0,ffffffffc0201542 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0201504:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201506:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0201508:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020150a:	fff44503          	lbu	a0,-1(s0)
ffffffffc020150e:	ff351ae3          	bne	a0,s3,ffffffffc0201502 <vprintfmt+0x52>
ffffffffc0201512:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0201516:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020151a:	4981                	li	s3,0
ffffffffc020151c:	4801                	li	a6,0
        width = precision = -1;
ffffffffc020151e:	5cfd                	li	s9,-1
ffffffffc0201520:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201522:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201526:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201528:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020152c:	0ff6f693          	andi	a3,a3,255
ffffffffc0201530:	00140d13          	addi	s10,s0,1
ffffffffc0201534:	20d5e563          	bltu	a1,a3,ffffffffc020173e <vprintfmt+0x28e>
ffffffffc0201538:	068a                	slli	a3,a3,0x2
ffffffffc020153a:	96d2                	add	a3,a3,s4
ffffffffc020153c:	4294                	lw	a3,0(a3)
ffffffffc020153e:	96d2                	add	a3,a3,s4
ffffffffc0201540:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201542:	70e6                	ld	ra,120(sp)
ffffffffc0201544:	7446                	ld	s0,112(sp)
ffffffffc0201546:	74a6                	ld	s1,104(sp)
ffffffffc0201548:	7906                	ld	s2,96(sp)
ffffffffc020154a:	69e6                	ld	s3,88(sp)
ffffffffc020154c:	6a46                	ld	s4,80(sp)
ffffffffc020154e:	6aa6                	ld	s5,72(sp)
ffffffffc0201550:	6b06                	ld	s6,64(sp)
ffffffffc0201552:	7be2                	ld	s7,56(sp)
ffffffffc0201554:	7c42                	ld	s8,48(sp)
ffffffffc0201556:	7ca2                	ld	s9,40(sp)
ffffffffc0201558:	7d02                	ld	s10,32(sp)
ffffffffc020155a:	6de2                	ld	s11,24(sp)
ffffffffc020155c:	6109                	addi	sp,sp,128
ffffffffc020155e:	8082                	ret
    if (lflag >= 2) {
ffffffffc0201560:	4705                	li	a4,1
ffffffffc0201562:	008a8593          	addi	a1,s5,8
ffffffffc0201566:	01074463          	blt	a4,a6,ffffffffc020156e <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc020156a:	26080363          	beqz	a6,ffffffffc02017d0 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc020156e:	000ab603          	ld	a2,0(s5)
ffffffffc0201572:	46c1                	li	a3,16
ffffffffc0201574:	8aae                	mv	s5,a1
ffffffffc0201576:	a06d                	j	ffffffffc0201620 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0201578:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc020157c:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020157e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201580:	b765                	j	ffffffffc0201528 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0201582:	000aa503          	lw	a0,0(s5)
ffffffffc0201586:	85a6                	mv	a1,s1
ffffffffc0201588:	0aa1                	addi	s5,s5,8
ffffffffc020158a:	9902                	jalr	s2
            break;
ffffffffc020158c:	bfb9                	j	ffffffffc02014ea <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020158e:	4705                	li	a4,1
ffffffffc0201590:	008a8993          	addi	s3,s5,8
ffffffffc0201594:	01074463          	blt	a4,a6,ffffffffc020159c <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0201598:	22080463          	beqz	a6,ffffffffc02017c0 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc020159c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02015a0:	24044463          	bltz	s0,ffffffffc02017e8 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc02015a4:	8622                	mv	a2,s0
ffffffffc02015a6:	8ace                	mv	s5,s3
ffffffffc02015a8:	46a9                	li	a3,10
ffffffffc02015aa:	a89d                	j	ffffffffc0201620 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc02015ac:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015b0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02015b2:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02015b4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02015b8:	8fb5                	xor	a5,a5,a3
ffffffffc02015ba:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015be:	1ad74363          	blt	a4,a3,ffffffffc0201764 <vprintfmt+0x2b4>
ffffffffc02015c2:	00369793          	slli	a5,a3,0x3
ffffffffc02015c6:	97e2                	add	a5,a5,s8
ffffffffc02015c8:	639c                	ld	a5,0(a5)
ffffffffc02015ca:	18078d63          	beqz	a5,ffffffffc0201764 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc02015ce:	86be                	mv	a3,a5
ffffffffc02015d0:	00001617          	auipc	a2,0x1
ffffffffc02015d4:	57860613          	addi	a2,a2,1400 # ffffffffc0202b48 <error_string+0xe8>
ffffffffc02015d8:	85a6                	mv	a1,s1
ffffffffc02015da:	854a                	mv	a0,s2
ffffffffc02015dc:	240000ef          	jal	ra,ffffffffc020181c <printfmt>
ffffffffc02015e0:	b729                	j	ffffffffc02014ea <vprintfmt+0x3a>
            lflag ++;
ffffffffc02015e2:	00144603          	lbu	a2,1(s0)
ffffffffc02015e6:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015e8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02015ea:	bf3d                	j	ffffffffc0201528 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc02015ec:	4705                	li	a4,1
ffffffffc02015ee:	008a8593          	addi	a1,s5,8
ffffffffc02015f2:	01074463          	blt	a4,a6,ffffffffc02015fa <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02015f6:	1e080263          	beqz	a6,ffffffffc02017da <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc02015fa:	000ab603          	ld	a2,0(s5)
ffffffffc02015fe:	46a1                	li	a3,8
ffffffffc0201600:	8aae                	mv	s5,a1
ffffffffc0201602:	a839                	j	ffffffffc0201620 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0201604:	03000513          	li	a0,48
ffffffffc0201608:	85a6                	mv	a1,s1
ffffffffc020160a:	e03e                	sd	a5,0(sp)
ffffffffc020160c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc020160e:	85a6                	mv	a1,s1
ffffffffc0201610:	07800513          	li	a0,120
ffffffffc0201614:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201616:	0aa1                	addi	s5,s5,8
ffffffffc0201618:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc020161c:	6782                	ld	a5,0(sp)
ffffffffc020161e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201620:	876e                	mv	a4,s11
ffffffffc0201622:	85a6                	mv	a1,s1
ffffffffc0201624:	854a                	mv	a0,s2
ffffffffc0201626:	e1fff0ef          	jal	ra,ffffffffc0201444 <printnum>
            break;
ffffffffc020162a:	b5c1                	j	ffffffffc02014ea <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020162c:	000ab603          	ld	a2,0(s5)
ffffffffc0201630:	0aa1                	addi	s5,s5,8
ffffffffc0201632:	1c060663          	beqz	a2,ffffffffc02017fe <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0201636:	00160413          	addi	s0,a2,1
ffffffffc020163a:	17b05c63          	blez	s11,ffffffffc02017b2 <vprintfmt+0x302>
ffffffffc020163e:	02d00593          	li	a1,45
ffffffffc0201642:	14b79263          	bne	a5,a1,ffffffffc0201786 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201646:	00064783          	lbu	a5,0(a2)
ffffffffc020164a:	0007851b          	sext.w	a0,a5
ffffffffc020164e:	c905                	beqz	a0,ffffffffc020167e <vprintfmt+0x1ce>
ffffffffc0201650:	000cc563          	bltz	s9,ffffffffc020165a <vprintfmt+0x1aa>
ffffffffc0201654:	3cfd                	addiw	s9,s9,-1
ffffffffc0201656:	036c8263          	beq	s9,s6,ffffffffc020167a <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc020165a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020165c:	18098463          	beqz	s3,ffffffffc02017e4 <vprintfmt+0x334>
ffffffffc0201660:	3781                	addiw	a5,a5,-32
ffffffffc0201662:	18fbf163          	bleu	a5,s7,ffffffffc02017e4 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0201666:	03f00513          	li	a0,63
ffffffffc020166a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020166c:	0405                	addi	s0,s0,1
ffffffffc020166e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201672:	3dfd                	addiw	s11,s11,-1
ffffffffc0201674:	0007851b          	sext.w	a0,a5
ffffffffc0201678:	fd61                	bnez	a0,ffffffffc0201650 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc020167a:	e7b058e3          	blez	s11,ffffffffc02014ea <vprintfmt+0x3a>
ffffffffc020167e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201680:	85a6                	mv	a1,s1
ffffffffc0201682:	02000513          	li	a0,32
ffffffffc0201686:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201688:	e60d81e3          	beqz	s11,ffffffffc02014ea <vprintfmt+0x3a>
ffffffffc020168c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020168e:	85a6                	mv	a1,s1
ffffffffc0201690:	02000513          	li	a0,32
ffffffffc0201694:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201696:	fe0d94e3          	bnez	s11,ffffffffc020167e <vprintfmt+0x1ce>
ffffffffc020169a:	bd81                	j	ffffffffc02014ea <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020169c:	4705                	li	a4,1
ffffffffc020169e:	008a8593          	addi	a1,s5,8
ffffffffc02016a2:	01074463          	blt	a4,a6,ffffffffc02016aa <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc02016a6:	12080063          	beqz	a6,ffffffffc02017c6 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc02016aa:	000ab603          	ld	a2,0(s5)
ffffffffc02016ae:	46a9                	li	a3,10
ffffffffc02016b0:	8aae                	mv	s5,a1
ffffffffc02016b2:	b7bd                	j	ffffffffc0201620 <vprintfmt+0x170>
ffffffffc02016b4:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc02016b8:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016bc:	846a                	mv	s0,s10
ffffffffc02016be:	b5ad                	j	ffffffffc0201528 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02016c0:	85a6                	mv	a1,s1
ffffffffc02016c2:	02500513          	li	a0,37
ffffffffc02016c6:	9902                	jalr	s2
            break;
ffffffffc02016c8:	b50d                	j	ffffffffc02014ea <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc02016ca:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc02016ce:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc02016d2:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016d4:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc02016d6:	e40dd9e3          	bgez	s11,ffffffffc0201528 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc02016da:	8de6                	mv	s11,s9
ffffffffc02016dc:	5cfd                	li	s9,-1
ffffffffc02016de:	b5a9                	j	ffffffffc0201528 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02016e0:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc02016e4:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016e8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02016ea:	bd3d                	j	ffffffffc0201528 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc02016ec:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc02016f0:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02016f4:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc02016f6:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc02016fa:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016fe:	fcd56ce3          	bltu	a0,a3,ffffffffc02016d6 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0201702:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201704:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201708:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020170c:	0196873b          	addw	a4,a3,s9
ffffffffc0201710:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201714:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201718:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020171c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201720:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201724:	fcd57fe3          	bleu	a3,a0,ffffffffc0201702 <vprintfmt+0x252>
ffffffffc0201728:	b77d                	j	ffffffffc02016d6 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020172a:	fffdc693          	not	a3,s11
ffffffffc020172e:	96fd                	srai	a3,a3,0x3f
ffffffffc0201730:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201734:	00144603          	lbu	a2,1(s0)
ffffffffc0201738:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020173a:	846a                	mv	s0,s10
ffffffffc020173c:	b3f5                	j	ffffffffc0201528 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc020173e:	85a6                	mv	a1,s1
ffffffffc0201740:	02500513          	li	a0,37
ffffffffc0201744:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201746:	fff44703          	lbu	a4,-1(s0)
ffffffffc020174a:	02500793          	li	a5,37
ffffffffc020174e:	8d22                	mv	s10,s0
ffffffffc0201750:	d8f70de3          	beq	a4,a5,ffffffffc02014ea <vprintfmt+0x3a>
ffffffffc0201754:	02500713          	li	a4,37
ffffffffc0201758:	1d7d                	addi	s10,s10,-1
ffffffffc020175a:	fffd4783          	lbu	a5,-1(s10)
ffffffffc020175e:	fee79de3          	bne	a5,a4,ffffffffc0201758 <vprintfmt+0x2a8>
ffffffffc0201762:	b361                	j	ffffffffc02014ea <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201764:	00001617          	auipc	a2,0x1
ffffffffc0201768:	3d460613          	addi	a2,a2,980 # ffffffffc0202b38 <error_string+0xd8>
ffffffffc020176c:	85a6                	mv	a1,s1
ffffffffc020176e:	854a                	mv	a0,s2
ffffffffc0201770:	0ac000ef          	jal	ra,ffffffffc020181c <printfmt>
ffffffffc0201774:	bb9d                	j	ffffffffc02014ea <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201776:	00001617          	auipc	a2,0x1
ffffffffc020177a:	3ba60613          	addi	a2,a2,954 # ffffffffc0202b30 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020177e:	00001417          	auipc	s0,0x1
ffffffffc0201782:	3b340413          	addi	s0,s0,947 # ffffffffc0202b31 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201786:	8532                	mv	a0,a2
ffffffffc0201788:	85e6                	mv	a1,s9
ffffffffc020178a:	e032                	sd	a2,0(sp)
ffffffffc020178c:	e43e                	sd	a5,8(sp)
ffffffffc020178e:	1c2000ef          	jal	ra,ffffffffc0201950 <strnlen>
ffffffffc0201792:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201796:	6602                	ld	a2,0(sp)
ffffffffc0201798:	01b05d63          	blez	s11,ffffffffc02017b2 <vprintfmt+0x302>
ffffffffc020179c:	67a2                	ld	a5,8(sp)
ffffffffc020179e:	2781                	sext.w	a5,a5
ffffffffc02017a0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc02017a2:	6522                	ld	a0,8(sp)
ffffffffc02017a4:	85a6                	mv	a1,s1
ffffffffc02017a6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017a8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02017aa:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02017ac:	6602                	ld	a2,0(sp)
ffffffffc02017ae:	fe0d9ae3          	bnez	s11,ffffffffc02017a2 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02017b2:	00064783          	lbu	a5,0(a2)
ffffffffc02017b6:	0007851b          	sext.w	a0,a5
ffffffffc02017ba:	e8051be3          	bnez	a0,ffffffffc0201650 <vprintfmt+0x1a0>
ffffffffc02017be:	b335                	j	ffffffffc02014ea <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc02017c0:	000aa403          	lw	s0,0(s5)
ffffffffc02017c4:	bbf1                	j	ffffffffc02015a0 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc02017c6:	000ae603          	lwu	a2,0(s5)
ffffffffc02017ca:	46a9                	li	a3,10
ffffffffc02017cc:	8aae                	mv	s5,a1
ffffffffc02017ce:	bd89                	j	ffffffffc0201620 <vprintfmt+0x170>
ffffffffc02017d0:	000ae603          	lwu	a2,0(s5)
ffffffffc02017d4:	46c1                	li	a3,16
ffffffffc02017d6:	8aae                	mv	s5,a1
ffffffffc02017d8:	b5a1                	j	ffffffffc0201620 <vprintfmt+0x170>
ffffffffc02017da:	000ae603          	lwu	a2,0(s5)
ffffffffc02017de:	46a1                	li	a3,8
ffffffffc02017e0:	8aae                	mv	s5,a1
ffffffffc02017e2:	bd3d                	j	ffffffffc0201620 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc02017e4:	9902                	jalr	s2
ffffffffc02017e6:	b559                	j	ffffffffc020166c <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc02017e8:	85a6                	mv	a1,s1
ffffffffc02017ea:	02d00513          	li	a0,45
ffffffffc02017ee:	e03e                	sd	a5,0(sp)
ffffffffc02017f0:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02017f2:	8ace                	mv	s5,s3
ffffffffc02017f4:	40800633          	neg	a2,s0
ffffffffc02017f8:	46a9                	li	a3,10
ffffffffc02017fa:	6782                	ld	a5,0(sp)
ffffffffc02017fc:	b515                	j	ffffffffc0201620 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc02017fe:	01b05663          	blez	s11,ffffffffc020180a <vprintfmt+0x35a>
ffffffffc0201802:	02d00693          	li	a3,45
ffffffffc0201806:	f6d798e3          	bne	a5,a3,ffffffffc0201776 <vprintfmt+0x2c6>
ffffffffc020180a:	00001417          	auipc	s0,0x1
ffffffffc020180e:	32740413          	addi	s0,s0,807 # ffffffffc0202b31 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201812:	02800513          	li	a0,40
ffffffffc0201816:	02800793          	li	a5,40
ffffffffc020181a:	bd1d                	j	ffffffffc0201650 <vprintfmt+0x1a0>

ffffffffc020181c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020181c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020181e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201822:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201824:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201826:	ec06                	sd	ra,24(sp)
ffffffffc0201828:	f83a                	sd	a4,48(sp)
ffffffffc020182a:	fc3e                	sd	a5,56(sp)
ffffffffc020182c:	e0c2                	sd	a6,64(sp)
ffffffffc020182e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201830:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201832:	c7fff0ef          	jal	ra,ffffffffc02014b0 <vprintfmt>
}
ffffffffc0201836:	60e2                	ld	ra,24(sp)
ffffffffc0201838:	6161                	addi	sp,sp,80
ffffffffc020183a:	8082                	ret

ffffffffc020183c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020183c:	715d                	addi	sp,sp,-80
ffffffffc020183e:	e486                	sd	ra,72(sp)
ffffffffc0201840:	e0a2                	sd	s0,64(sp)
ffffffffc0201842:	fc26                	sd	s1,56(sp)
ffffffffc0201844:	f84a                	sd	s2,48(sp)
ffffffffc0201846:	f44e                	sd	s3,40(sp)
ffffffffc0201848:	f052                	sd	s4,32(sp)
ffffffffc020184a:	ec56                	sd	s5,24(sp)
ffffffffc020184c:	e85a                	sd	s6,16(sp)
ffffffffc020184e:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201850:	c901                	beqz	a0,ffffffffc0201860 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201852:	85aa                	mv	a1,a0
ffffffffc0201854:	00001517          	auipc	a0,0x1
ffffffffc0201858:	2f450513          	addi	a0,a0,756 # ffffffffc0202b48 <error_string+0xe8>
ffffffffc020185c:	85bfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201860:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201862:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201864:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201866:	4aa9                	li	s5,10
ffffffffc0201868:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc020186a:	00004b97          	auipc	s7,0x4
ffffffffc020186e:	7aeb8b93          	addi	s7,s7,1966 # ffffffffc0206018 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201872:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201876:	8b9fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020187a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020187c:	00054b63          	bltz	a0,ffffffffc0201892 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201880:	00a95b63          	ble	a0,s2,ffffffffc0201896 <readline+0x5a>
ffffffffc0201884:	029a5463          	ble	s1,s4,ffffffffc02018ac <readline+0x70>
        c = getchar();
ffffffffc0201888:	8a7fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc020188c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020188e:	fe0559e3          	bgez	a0,ffffffffc0201880 <readline+0x44>
            return NULL;
ffffffffc0201892:	4501                	li	a0,0
ffffffffc0201894:	a099                	j	ffffffffc02018da <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201896:	03341463          	bne	s0,s3,ffffffffc02018be <readline+0x82>
ffffffffc020189a:	e8b9                	bnez	s1,ffffffffc02018f0 <readline+0xb4>
        c = getchar();
ffffffffc020189c:	893fe0ef          	jal	ra,ffffffffc020012e <getchar>
ffffffffc02018a0:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02018a2:	fe0548e3          	bltz	a0,ffffffffc0201892 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02018a6:	fea958e3          	ble	a0,s2,ffffffffc0201896 <readline+0x5a>
ffffffffc02018aa:	4481                	li	s1,0
            cputchar(c);
ffffffffc02018ac:	8522                	mv	a0,s0
ffffffffc02018ae:	83dfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc02018b2:	009b87b3          	add	a5,s7,s1
ffffffffc02018b6:	00878023          	sb	s0,0(a5)
ffffffffc02018ba:	2485                	addiw	s1,s1,1
ffffffffc02018bc:	bf6d                	j	ffffffffc0201876 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc02018be:	01540463          	beq	s0,s5,ffffffffc02018c6 <readline+0x8a>
ffffffffc02018c2:	fb641ae3          	bne	s0,s6,ffffffffc0201876 <readline+0x3a>
            cputchar(c);
ffffffffc02018c6:	8522                	mv	a0,s0
ffffffffc02018c8:	823fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02018cc:	00004517          	auipc	a0,0x4
ffffffffc02018d0:	74c50513          	addi	a0,a0,1868 # ffffffffc0206018 <edata>
ffffffffc02018d4:	94aa                	add	s1,s1,a0
ffffffffc02018d6:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02018da:	60a6                	ld	ra,72(sp)
ffffffffc02018dc:	6406                	ld	s0,64(sp)
ffffffffc02018de:	74e2                	ld	s1,56(sp)
ffffffffc02018e0:	7942                	ld	s2,48(sp)
ffffffffc02018e2:	79a2                	ld	s3,40(sp)
ffffffffc02018e4:	7a02                	ld	s4,32(sp)
ffffffffc02018e6:	6ae2                	ld	s5,24(sp)
ffffffffc02018e8:	6b42                	ld	s6,16(sp)
ffffffffc02018ea:	6ba2                	ld	s7,8(sp)
ffffffffc02018ec:	6161                	addi	sp,sp,80
ffffffffc02018ee:	8082                	ret
            cputchar(c);
ffffffffc02018f0:	4521                	li	a0,8
ffffffffc02018f2:	ff8fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02018f6:	34fd                	addiw	s1,s1,-1
ffffffffc02018f8:	bfbd                	j	ffffffffc0201876 <readline+0x3a>

ffffffffc02018fa <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02018fa:	00004797          	auipc	a5,0x4
ffffffffc02018fe:	71678793          	addi	a5,a5,1814 # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201902:	6398                	ld	a4,0(a5)
ffffffffc0201904:	4781                	li	a5,0
ffffffffc0201906:	88ba                	mv	a7,a4
ffffffffc0201908:	852a                	mv	a0,a0
ffffffffc020190a:	85be                	mv	a1,a5
ffffffffc020190c:	863e                	mv	a2,a5
ffffffffc020190e:	00000073          	ecall
ffffffffc0201912:	87aa                	mv	a5,a0
}
ffffffffc0201914:	8082                	ret

ffffffffc0201916 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc0201916:	00005797          	auipc	a5,0x5
ffffffffc020191a:	b1a78793          	addi	a5,a5,-1254 # ffffffffc0206430 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc020191e:	6398                	ld	a4,0(a5)
ffffffffc0201920:	4781                	li	a5,0
ffffffffc0201922:	88ba                	mv	a7,a4
ffffffffc0201924:	852a                	mv	a0,a0
ffffffffc0201926:	85be                	mv	a1,a5
ffffffffc0201928:	863e                	mv	a2,a5
ffffffffc020192a:	00000073          	ecall
ffffffffc020192e:	87aa                	mv	a5,a0
}
ffffffffc0201930:	8082                	ret

ffffffffc0201932 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201932:	00004797          	auipc	a5,0x4
ffffffffc0201936:	6d678793          	addi	a5,a5,1750 # ffffffffc0206008 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc020193a:	639c                	ld	a5,0(a5)
ffffffffc020193c:	4501                	li	a0,0
ffffffffc020193e:	88be                	mv	a7,a5
ffffffffc0201940:	852a                	mv	a0,a0
ffffffffc0201942:	85aa                	mv	a1,a0
ffffffffc0201944:	862a                	mv	a2,a0
ffffffffc0201946:	00000073          	ecall
ffffffffc020194a:	852a                	mv	a0,a0
ffffffffc020194c:	2501                	sext.w	a0,a0
ffffffffc020194e:	8082                	ret

ffffffffc0201950 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201950:	c185                	beqz	a1,ffffffffc0201970 <strnlen+0x20>
ffffffffc0201952:	00054783          	lbu	a5,0(a0)
ffffffffc0201956:	cf89                	beqz	a5,ffffffffc0201970 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201958:	4781                	li	a5,0
ffffffffc020195a:	a021                	j	ffffffffc0201962 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020195c:	00074703          	lbu	a4,0(a4)
ffffffffc0201960:	c711                	beqz	a4,ffffffffc020196c <strnlen+0x1c>
        cnt ++;
ffffffffc0201962:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201964:	00f50733          	add	a4,a0,a5
ffffffffc0201968:	fef59ae3          	bne	a1,a5,ffffffffc020195c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020196c:	853e                	mv	a0,a5
ffffffffc020196e:	8082                	ret
    size_t cnt = 0;
ffffffffc0201970:	4781                	li	a5,0
}
ffffffffc0201972:	853e                	mv	a0,a5
ffffffffc0201974:	8082                	ret

ffffffffc0201976 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201976:	00054783          	lbu	a5,0(a0)
ffffffffc020197a:	0005c703          	lbu	a4,0(a1)
ffffffffc020197e:	cb91                	beqz	a5,ffffffffc0201992 <strcmp+0x1c>
ffffffffc0201980:	00e79c63          	bne	a5,a4,ffffffffc0201998 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201984:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201986:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020198a:	0585                	addi	a1,a1,1
ffffffffc020198c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201990:	fbe5                	bnez	a5,ffffffffc0201980 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201992:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201994:	9d19                	subw	a0,a0,a4
ffffffffc0201996:	8082                	ret
ffffffffc0201998:	0007851b          	sext.w	a0,a5
ffffffffc020199c:	9d19                	subw	a0,a0,a4
ffffffffc020199e:	8082                	ret

ffffffffc02019a0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02019a0:	00054783          	lbu	a5,0(a0)
ffffffffc02019a4:	cb91                	beqz	a5,ffffffffc02019b8 <strchr+0x18>
        if (*s == c) {
ffffffffc02019a6:	00b79563          	bne	a5,a1,ffffffffc02019b0 <strchr+0x10>
ffffffffc02019aa:	a809                	j	ffffffffc02019bc <strchr+0x1c>
ffffffffc02019ac:	00b78763          	beq	a5,a1,ffffffffc02019ba <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02019b0:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02019b2:	00054783          	lbu	a5,0(a0)
ffffffffc02019b6:	fbfd                	bnez	a5,ffffffffc02019ac <strchr+0xc>
    }
    return NULL;
ffffffffc02019b8:	4501                	li	a0,0
}
ffffffffc02019ba:	8082                	ret
ffffffffc02019bc:	8082                	ret

ffffffffc02019be <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02019be:	ca01                	beqz	a2,ffffffffc02019ce <memset+0x10>
ffffffffc02019c0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02019c2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02019c4:	0785                	addi	a5,a5,1
ffffffffc02019c6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02019ca:	fec79de3          	bne	a5,a2,ffffffffc02019c4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02019ce:	8082                	ret
