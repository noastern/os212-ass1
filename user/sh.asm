
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <exec_other_paths>:

// our code
char* PATH[40]; 
int num_of_pathes;

void exec_other_paths(struct execcmd * ecmd){ // our code
       0:	714d                	addi	sp,sp,-336
       2:	e686                	sd	ra,328(sp)
       4:	e2a2                	sd	s0,320(sp)
       6:	fe26                	sd	s1,312(sp)
       8:	fa4a                	sd	s2,304(sp)
       a:	f64e                	sd	s3,296(sp)
       c:	f252                	sd	s4,288(sp)
       e:	ee56                	sd	s5,280(sp)
      10:	ea5a                	sd	s6,272(sp)
      12:	0a80                	addi	s0,sp,336
      14:	89aa                	mv	s3,a0
  char str[256];
  char c[1];
  int fd = open("/path", O_RDONLY);
      16:	4581                	li	a1,0
      18:	00001517          	auipc	a0,0x1
      1c:	3d050513          	addi	a0,a0,976 # 13e8 <malloc+0xe6>
      20:	00001097          	auipc	ra,0x1
      24:	ed4080e7          	jalr	-300(ra) # ef4 <open>
      28:	892a                	mv	s2,a0
  if (-1 == fd){
      2a:	57fd                	li	a5,-1
      2c:	02f50063          	beq	a0,a5,4c <exec_other_paths+0x4c>
      fprintf(2, "open file failed \n");
  }
  int strIndex = 0;
  char* commandName = ecmd->argv[0];
      30:	0089ba83          	ld	s5,8(s3)
  if (commandName[0] != '/'){ //in case we got path we don't want to to chain it to pathes from the 'path' file
      34:	000ac703          	lbu	a4,0(s5)
      38:	02f00793          	li	a5,47
  int strIndex = 0;
      3c:	4481                	li	s1,0
  if (commandName[0] != '/'){ //in case we got path we don't want to to chain it to pathes from the 'path' file
      3e:	08f70663          	beq	a4,a5,ca <exec_other_paths+0xca>
    while(read(fd, c, 1) > 0){ //reading letter by letter the path from the pth file
      if (c[0] != ':'){ // checking delimiter butween different pathes
      42:	03a00a13          	li	s4,58
          str[strIndex] = commandName[i]; // chainning the path to the command received from user.  
          i++;
          strIndex++; 
        }
        str[strIndex]='\0'; //inorder to avoid suffix of previous path command
        exec(str, ecmd->argv);
      46:	09a1                	addi	s3,s3,8
        strIndex=0; //initializing the path command to be sent
      48:	4b01                	li	s6,0
      4a:	a899                	j	a0 <exec_other_paths+0xa0>
      fprintf(2, "open file failed \n");
      4c:	00001597          	auipc	a1,0x1
      50:	3a458593          	addi	a1,a1,932 # 13f0 <malloc+0xee>
      54:	4509                	li	a0,2
      56:	00001097          	auipc	ra,0x1
      5a:	1c0080e7          	jalr	448(ra) # 1216 <fprintf>
      5e:	bfc9                	j	30 <exec_other_paths+0x30>
        while(commandName[i] != '\0'){ 
      60:	000ac703          	lbu	a4,0(s5)
      64:	0014879b          	addiw	a5,s1,1
      68:	001a8693          	addi	a3,s5,1
      6c:	cf09                	beqz	a4,86 <exec_other_paths+0x86>
          str[strIndex] = commandName[i]; // chainning the path to the command received from user.  
      6e:	ec040613          	addi	a2,s0,-320
      72:	963e                	add	a2,a2,a5
      74:	fee60fa3          	sb	a4,-1(a2)
          strIndex++; 
      78:	0007849b          	sext.w	s1,a5
        while(commandName[i] != '\0'){ 
      7c:	0006c703          	lbu	a4,0(a3)
      80:	0785                	addi	a5,a5,1
      82:	0685                	addi	a3,a3,1
      84:	f76d                	bnez	a4,6e <exec_other_paths+0x6e>
        str[strIndex]='\0'; //inorder to avoid suffix of previous path command
      86:	fc040793          	addi	a5,s0,-64
      8a:	94be                	add	s1,s1,a5
      8c:	f0048023          	sb	zero,-256(s1)
        exec(str, ecmd->argv);
      90:	85ce                	mv	a1,s3
      92:	ec040513          	addi	a0,s0,-320
      96:	00001097          	auipc	ra,0x1
      9a:	e56080e7          	jalr	-426(ra) # eec <exec>
        strIndex=0; //initializing the path command to be sent
      9e:	84da                	mv	s1,s6
    while(read(fd, c, 1) > 0){ //reading letter by letter the path from the pth file
      a0:	4605                	li	a2,1
      a2:	eb840593          	addi	a1,s0,-328
      a6:	854a                	mv	a0,s2
      a8:	00001097          	auipc	ra,0x1
      ac:	e24080e7          	jalr	-476(ra) # ecc <read>
      b0:	00a05d63          	blez	a0,ca <exec_other_paths+0xca>
      if (c[0] != ':'){ // checking delimiter butween different pathes
      b4:	eb844783          	lbu	a5,-328(s0)
      b8:	fb4784e3          	beq	a5,s4,60 <exec_other_paths+0x60>
        str[strIndex] = c[0];
      bc:	fc040713          	addi	a4,s0,-64
      c0:	9726                	add	a4,a4,s1
      c2:	f0f70023          	sb	a5,-256(a4)
        strIndex++;
      c6:	2485                	addiw	s1,s1,1
      c8:	bfe1                	j	a0 <exec_other_paths+0xa0>
      }
    }
  }
  close(fd);
      ca:	854a                	mv	a0,s2
      cc:	00001097          	auipc	ra,0x1
      d0:	e10080e7          	jalr	-496(ra) # edc <close>
}
      d4:	60b6                	ld	ra,328(sp)
      d6:	6416                	ld	s0,320(sp)
      d8:	74f2                	ld	s1,312(sp)
      da:	7952                	ld	s2,304(sp)
      dc:	79b2                	ld	s3,296(sp)
      de:	7a12                	ld	s4,288(sp)
      e0:	6af2                	ld	s5,280(sp)
      e2:	6b52                	ld	s6,272(sp)
      e4:	6171                	addi	sp,sp,336
      e6:	8082                	ret

00000000000000e8 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
      e8:	1101                	addi	sp,sp,-32
      ea:	ec06                	sd	ra,24(sp)
      ec:	e822                	sd	s0,16(sp)
      ee:	e426                	sd	s1,8(sp)
      f0:	e04a                	sd	s2,0(sp)
      f2:	1000                	addi	s0,sp,32
      f4:	84aa                	mv	s1,a0
      f6:	892e                	mv	s2,a1
  fprintf(2, "$ ");
      f8:	00001597          	auipc	a1,0x1
      fc:	31058593          	addi	a1,a1,784 # 1408 <malloc+0x106>
     100:	4509                	li	a0,2
     102:	00001097          	auipc	ra,0x1
     106:	114080e7          	jalr	276(ra) # 1216 <fprintf>
  memset(buf, 0, nbuf);
     10a:	864a                	mv	a2,s2
     10c:	4581                	li	a1,0
     10e:	8526                	mv	a0,s1
     110:	00001097          	auipc	ra,0x1
     114:	ba8080e7          	jalr	-1112(ra) # cb8 <memset>
  gets(buf, nbuf);
     118:	85ca                	mv	a1,s2
     11a:	8526                	mv	a0,s1
     11c:	00001097          	auipc	ra,0x1
     120:	be2080e7          	jalr	-1054(ra) # cfe <gets>
  if(buf[0] == 0) // EOF
     124:	0004c503          	lbu	a0,0(s1)
     128:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
     12c:	40a00533          	neg	a0,a0
     130:	60e2                	ld	ra,24(sp)
     132:	6442                	ld	s0,16(sp)
     134:	64a2                	ld	s1,8(sp)
     136:	6902                	ld	s2,0(sp)
     138:	6105                	addi	sp,sp,32
     13a:	8082                	ret

000000000000013c <panic>:
  exit(0);
}

void
panic(char *s)
{
     13c:	1141                	addi	sp,sp,-16
     13e:	e406                	sd	ra,8(sp)
     140:	e022                	sd	s0,0(sp)
     142:	0800                	addi	s0,sp,16
     144:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
     146:	00001597          	auipc	a1,0x1
     14a:	2ca58593          	addi	a1,a1,714 # 1410 <malloc+0x10e>
     14e:	4509                	li	a0,2
     150:	00001097          	auipc	ra,0x1
     154:	0c6080e7          	jalr	198(ra) # 1216 <fprintf>
  exit(1);
     158:	4505                	li	a0,1
     15a:	00001097          	auipc	ra,0x1
     15e:	d5a080e7          	jalr	-678(ra) # eb4 <exit>

0000000000000162 <fork1>:
}

int
fork1(void)
{
     162:	1141                	addi	sp,sp,-16
     164:	e406                	sd	ra,8(sp)
     166:	e022                	sd	s0,0(sp)
     168:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
     16a:	00001097          	auipc	ra,0x1
     16e:	d42080e7          	jalr	-702(ra) # eac <fork>
  if(pid == -1)
     172:	57fd                	li	a5,-1
     174:	00f50663          	beq	a0,a5,180 <fork1+0x1e>
    panic("fork");
  return pid;
}
     178:	60a2                	ld	ra,8(sp)
     17a:	6402                	ld	s0,0(sp)
     17c:	0141                	addi	sp,sp,16
     17e:	8082                	ret
    panic("fork");
     180:	00001517          	auipc	a0,0x1
     184:	29850513          	addi	a0,a0,664 # 1418 <malloc+0x116>
     188:	00000097          	auipc	ra,0x0
     18c:	fb4080e7          	jalr	-76(ra) # 13c <panic>

0000000000000190 <runcmd>:
{
     190:	7179                	addi	sp,sp,-48
     192:	f406                	sd	ra,40(sp)
     194:	f022                	sd	s0,32(sp)
     196:	ec26                	sd	s1,24(sp)
     198:	1800                	addi	s0,sp,48
  if(cmd == 0)
     19a:	c10d                	beqz	a0,1bc <runcmd+0x2c>
     19c:	84aa                	mv	s1,a0
  switch(cmd->type){
     19e:	4118                	lw	a4,0(a0)
     1a0:	4795                	li	a5,5
     1a2:	02e7e263          	bltu	a5,a4,1c6 <runcmd+0x36>
     1a6:	00056783          	lwu	a5,0(a0)
     1aa:	078a                	slli	a5,a5,0x2
     1ac:	00001717          	auipc	a4,0x1
     1b0:	36c70713          	addi	a4,a4,876 # 1518 <malloc+0x216>
     1b4:	97ba                	add	a5,a5,a4
     1b6:	439c                	lw	a5,0(a5)
     1b8:	97ba                	add	a5,a5,a4
     1ba:	8782                	jr	a5
    exit(1);
     1bc:	4505                	li	a0,1
     1be:	00001097          	auipc	ra,0x1
     1c2:	cf6080e7          	jalr	-778(ra) # eb4 <exit>
    panic("runcmd");
     1c6:	00001517          	auipc	a0,0x1
     1ca:	25a50513          	addi	a0,a0,602 # 1420 <malloc+0x11e>
     1ce:	00000097          	auipc	ra,0x0
     1d2:	f6e080e7          	jalr	-146(ra) # 13c <panic>
    if(ecmd->argv[0] == 0)
     1d6:	6508                	ld	a0,8(a0)
     1d8:	c91d                	beqz	a0,20e <runcmd+0x7e>
    exec(ecmd->argv[0], ecmd->argv); //first try running original way
     1da:	00848593          	addi	a1,s1,8
     1de:	00001097          	auipc	ra,0x1
     1e2:	d0e080e7          	jalr	-754(ra) # eec <exec>
    exec_other_paths(ecmd); // our code
     1e6:	8526                	mv	a0,s1
     1e8:	00000097          	auipc	ra,0x0
     1ec:	e18080e7          	jalr	-488(ra) # 0 <exec_other_paths>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     1f0:	6490                	ld	a2,8(s1)
     1f2:	00001597          	auipc	a1,0x1
     1f6:	23658593          	addi	a1,a1,566 # 1428 <malloc+0x126>
     1fa:	4509                	li	a0,2
     1fc:	00001097          	auipc	ra,0x1
     200:	01a080e7          	jalr	26(ra) # 1216 <fprintf>
  exit(0);
     204:	4501                	li	a0,0
     206:	00001097          	auipc	ra,0x1
     20a:	cae080e7          	jalr	-850(ra) # eb4 <exit>
      exit(1);
     20e:	4505                	li	a0,1
     210:	00001097          	auipc	ra,0x1
     214:	ca4080e7          	jalr	-860(ra) # eb4 <exit>
    close(rcmd->fd);
     218:	5148                	lw	a0,36(a0)
     21a:	00001097          	auipc	ra,0x1
     21e:	cc2080e7          	jalr	-830(ra) # edc <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     222:	508c                	lw	a1,32(s1)
     224:	6888                	ld	a0,16(s1)
     226:	00001097          	auipc	ra,0x1
     22a:	cce080e7          	jalr	-818(ra) # ef4 <open>
     22e:	00054763          	bltz	a0,23c <runcmd+0xac>
    runcmd(rcmd->cmd);
     232:	6488                	ld	a0,8(s1)
     234:	00000097          	auipc	ra,0x0
     238:	f5c080e7          	jalr	-164(ra) # 190 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     23c:	6890                	ld	a2,16(s1)
     23e:	00001597          	auipc	a1,0x1
     242:	1fa58593          	addi	a1,a1,506 # 1438 <malloc+0x136>
     246:	4509                	li	a0,2
     248:	00001097          	auipc	ra,0x1
     24c:	fce080e7          	jalr	-50(ra) # 1216 <fprintf>
      exit(1);
     250:	4505                	li	a0,1
     252:	00001097          	auipc	ra,0x1
     256:	c62080e7          	jalr	-926(ra) # eb4 <exit>
    if(fork1() == 0)
     25a:	00000097          	auipc	ra,0x0
     25e:	f08080e7          	jalr	-248(ra) # 162 <fork1>
     262:	c919                	beqz	a0,278 <runcmd+0xe8>
    wait(0);
     264:	4501                	li	a0,0
     266:	00001097          	auipc	ra,0x1
     26a:	c56080e7          	jalr	-938(ra) # ebc <wait>
    runcmd(lcmd->right);
     26e:	6888                	ld	a0,16(s1)
     270:	00000097          	auipc	ra,0x0
     274:	f20080e7          	jalr	-224(ra) # 190 <runcmd>
      runcmd(lcmd->left);
     278:	6488                	ld	a0,8(s1)
     27a:	00000097          	auipc	ra,0x0
     27e:	f16080e7          	jalr	-234(ra) # 190 <runcmd>
    if(pipe(p) < 0)
     282:	fd840513          	addi	a0,s0,-40
     286:	00001097          	auipc	ra,0x1
     28a:	c3e080e7          	jalr	-962(ra) # ec4 <pipe>
     28e:	04054363          	bltz	a0,2d4 <runcmd+0x144>
    if(fork1() == 0){
     292:	00000097          	auipc	ra,0x0
     296:	ed0080e7          	jalr	-304(ra) # 162 <fork1>
     29a:	c529                	beqz	a0,2e4 <runcmd+0x154>
    if(fork1() == 0){
     29c:	00000097          	auipc	ra,0x0
     2a0:	ec6080e7          	jalr	-314(ra) # 162 <fork1>
     2a4:	cd25                	beqz	a0,31c <runcmd+0x18c>
    close(p[0]);
     2a6:	fd842503          	lw	a0,-40(s0)
     2aa:	00001097          	auipc	ra,0x1
     2ae:	c32080e7          	jalr	-974(ra) # edc <close>
    close(p[1]);
     2b2:	fdc42503          	lw	a0,-36(s0)
     2b6:	00001097          	auipc	ra,0x1
     2ba:	c26080e7          	jalr	-986(ra) # edc <close>
    wait(0);
     2be:	4501                	li	a0,0
     2c0:	00001097          	auipc	ra,0x1
     2c4:	bfc080e7          	jalr	-1028(ra) # ebc <wait>
    wait(0);
     2c8:	4501                	li	a0,0
     2ca:	00001097          	auipc	ra,0x1
     2ce:	bf2080e7          	jalr	-1038(ra) # ebc <wait>
    break;
     2d2:	bf0d                	j	204 <runcmd+0x74>
      panic("pipe");
     2d4:	00001517          	auipc	a0,0x1
     2d8:	17450513          	addi	a0,a0,372 # 1448 <malloc+0x146>
     2dc:	00000097          	auipc	ra,0x0
     2e0:	e60080e7          	jalr	-416(ra) # 13c <panic>
      close(1);
     2e4:	4505                	li	a0,1
     2e6:	00001097          	auipc	ra,0x1
     2ea:	bf6080e7          	jalr	-1034(ra) # edc <close>
      dup(p[1]);
     2ee:	fdc42503          	lw	a0,-36(s0)
     2f2:	00001097          	auipc	ra,0x1
     2f6:	c3a080e7          	jalr	-966(ra) # f2c <dup>
      close(p[0]);
     2fa:	fd842503          	lw	a0,-40(s0)
     2fe:	00001097          	auipc	ra,0x1
     302:	bde080e7          	jalr	-1058(ra) # edc <close>
      close(p[1]);
     306:	fdc42503          	lw	a0,-36(s0)
     30a:	00001097          	auipc	ra,0x1
     30e:	bd2080e7          	jalr	-1070(ra) # edc <close>
      runcmd(pcmd->left);
     312:	6488                	ld	a0,8(s1)
     314:	00000097          	auipc	ra,0x0
     318:	e7c080e7          	jalr	-388(ra) # 190 <runcmd>
      close(0);
     31c:	00001097          	auipc	ra,0x1
     320:	bc0080e7          	jalr	-1088(ra) # edc <close>
      dup(p[0]);
     324:	fd842503          	lw	a0,-40(s0)
     328:	00001097          	auipc	ra,0x1
     32c:	c04080e7          	jalr	-1020(ra) # f2c <dup>
      close(p[0]);
     330:	fd842503          	lw	a0,-40(s0)
     334:	00001097          	auipc	ra,0x1
     338:	ba8080e7          	jalr	-1112(ra) # edc <close>
      close(p[1]);
     33c:	fdc42503          	lw	a0,-36(s0)
     340:	00001097          	auipc	ra,0x1
     344:	b9c080e7          	jalr	-1124(ra) # edc <close>
      runcmd(pcmd->right);
     348:	6888                	ld	a0,16(s1)
     34a:	00000097          	auipc	ra,0x0
     34e:	e46080e7          	jalr	-442(ra) # 190 <runcmd>
    if(fork1() == 0)
     352:	00000097          	auipc	ra,0x0
     356:	e10080e7          	jalr	-496(ra) # 162 <fork1>
     35a:	ea0515e3          	bnez	a0,204 <runcmd+0x74>
      runcmd(bcmd->cmd);
     35e:	6488                	ld	a0,8(s1)
     360:	00000097          	auipc	ra,0x0
     364:	e30080e7          	jalr	-464(ra) # 190 <runcmd>

0000000000000368 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     368:	1101                	addi	sp,sp,-32
     36a:	ec06                	sd	ra,24(sp)
     36c:	e822                	sd	s0,16(sp)
     36e:	e426                	sd	s1,8(sp)
     370:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     372:	0a800513          	li	a0,168
     376:	00001097          	auipc	ra,0x1
     37a:	f8c080e7          	jalr	-116(ra) # 1302 <malloc>
     37e:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     380:	0a800613          	li	a2,168
     384:	4581                	li	a1,0
     386:	00001097          	auipc	ra,0x1
     38a:	932080e7          	jalr	-1742(ra) # cb8 <memset>
  cmd->type = EXEC;
     38e:	4785                	li	a5,1
     390:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     392:	8526                	mv	a0,s1
     394:	60e2                	ld	ra,24(sp)
     396:	6442                	ld	s0,16(sp)
     398:	64a2                	ld	s1,8(sp)
     39a:	6105                	addi	sp,sp,32
     39c:	8082                	ret

000000000000039e <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     39e:	7139                	addi	sp,sp,-64
     3a0:	fc06                	sd	ra,56(sp)
     3a2:	f822                	sd	s0,48(sp)
     3a4:	f426                	sd	s1,40(sp)
     3a6:	f04a                	sd	s2,32(sp)
     3a8:	ec4e                	sd	s3,24(sp)
     3aa:	e852                	sd	s4,16(sp)
     3ac:	e456                	sd	s5,8(sp)
     3ae:	e05a                	sd	s6,0(sp)
     3b0:	0080                	addi	s0,sp,64
     3b2:	8b2a                	mv	s6,a0
     3b4:	8aae                	mv	s5,a1
     3b6:	8a32                	mv	s4,a2
     3b8:	89b6                	mv	s3,a3
     3ba:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3bc:	02800513          	li	a0,40
     3c0:	00001097          	auipc	ra,0x1
     3c4:	f42080e7          	jalr	-190(ra) # 1302 <malloc>
     3c8:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3ca:	02800613          	li	a2,40
     3ce:	4581                	li	a1,0
     3d0:	00001097          	auipc	ra,0x1
     3d4:	8e8080e7          	jalr	-1816(ra) # cb8 <memset>
  cmd->type = REDIR;
     3d8:	4789                	li	a5,2
     3da:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3dc:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     3e0:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     3e4:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     3e8:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     3ec:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     3f0:	8526                	mv	a0,s1
     3f2:	70e2                	ld	ra,56(sp)
     3f4:	7442                	ld	s0,48(sp)
     3f6:	74a2                	ld	s1,40(sp)
     3f8:	7902                	ld	s2,32(sp)
     3fa:	69e2                	ld	s3,24(sp)
     3fc:	6a42                	ld	s4,16(sp)
     3fe:	6aa2                	ld	s5,8(sp)
     400:	6b02                	ld	s6,0(sp)
     402:	6121                	addi	sp,sp,64
     404:	8082                	ret

0000000000000406 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     406:	7179                	addi	sp,sp,-48
     408:	f406                	sd	ra,40(sp)
     40a:	f022                	sd	s0,32(sp)
     40c:	ec26                	sd	s1,24(sp)
     40e:	e84a                	sd	s2,16(sp)
     410:	e44e                	sd	s3,8(sp)
     412:	1800                	addi	s0,sp,48
     414:	89aa                	mv	s3,a0
     416:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     418:	4561                	li	a0,24
     41a:	00001097          	auipc	ra,0x1
     41e:	ee8080e7          	jalr	-280(ra) # 1302 <malloc>
     422:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     424:	4661                	li	a2,24
     426:	4581                	li	a1,0
     428:	00001097          	auipc	ra,0x1
     42c:	890080e7          	jalr	-1904(ra) # cb8 <memset>
  cmd->type = PIPE;
     430:	478d                	li	a5,3
     432:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     434:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     438:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     43c:	8526                	mv	a0,s1
     43e:	70a2                	ld	ra,40(sp)
     440:	7402                	ld	s0,32(sp)
     442:	64e2                	ld	s1,24(sp)
     444:	6942                	ld	s2,16(sp)
     446:	69a2                	ld	s3,8(sp)
     448:	6145                	addi	sp,sp,48
     44a:	8082                	ret

000000000000044c <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     44c:	7179                	addi	sp,sp,-48
     44e:	f406                	sd	ra,40(sp)
     450:	f022                	sd	s0,32(sp)
     452:	ec26                	sd	s1,24(sp)
     454:	e84a                	sd	s2,16(sp)
     456:	e44e                	sd	s3,8(sp)
     458:	1800                	addi	s0,sp,48
     45a:	89aa                	mv	s3,a0
     45c:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     45e:	4561                	li	a0,24
     460:	00001097          	auipc	ra,0x1
     464:	ea2080e7          	jalr	-350(ra) # 1302 <malloc>
     468:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     46a:	4661                	li	a2,24
     46c:	4581                	li	a1,0
     46e:	00001097          	auipc	ra,0x1
     472:	84a080e7          	jalr	-1974(ra) # cb8 <memset>
  cmd->type = LIST;
     476:	4791                	li	a5,4
     478:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     47a:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     47e:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     482:	8526                	mv	a0,s1
     484:	70a2                	ld	ra,40(sp)
     486:	7402                	ld	s0,32(sp)
     488:	64e2                	ld	s1,24(sp)
     48a:	6942                	ld	s2,16(sp)
     48c:	69a2                	ld	s3,8(sp)
     48e:	6145                	addi	sp,sp,48
     490:	8082                	ret

0000000000000492 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     492:	1101                	addi	sp,sp,-32
     494:	ec06                	sd	ra,24(sp)
     496:	e822                	sd	s0,16(sp)
     498:	e426                	sd	s1,8(sp)
     49a:	e04a                	sd	s2,0(sp)
     49c:	1000                	addi	s0,sp,32
     49e:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4a0:	4541                	li	a0,16
     4a2:	00001097          	auipc	ra,0x1
     4a6:	e60080e7          	jalr	-416(ra) # 1302 <malloc>
     4aa:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     4ac:	4641                	li	a2,16
     4ae:	4581                	li	a1,0
     4b0:	00001097          	auipc	ra,0x1
     4b4:	808080e7          	jalr	-2040(ra) # cb8 <memset>
  cmd->type = BACK;
     4b8:	4795                	li	a5,5
     4ba:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     4bc:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     4c0:	8526                	mv	a0,s1
     4c2:	60e2                	ld	ra,24(sp)
     4c4:	6442                	ld	s0,16(sp)
     4c6:	64a2                	ld	s1,8(sp)
     4c8:	6902                	ld	s2,0(sp)
     4ca:	6105                	addi	sp,sp,32
     4cc:	8082                	ret

00000000000004ce <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     4ce:	7139                	addi	sp,sp,-64
     4d0:	fc06                	sd	ra,56(sp)
     4d2:	f822                	sd	s0,48(sp)
     4d4:	f426                	sd	s1,40(sp)
     4d6:	f04a                	sd	s2,32(sp)
     4d8:	ec4e                	sd	s3,24(sp)
     4da:	e852                	sd	s4,16(sp)
     4dc:	e456                	sd	s5,8(sp)
     4de:	e05a                	sd	s6,0(sp)
     4e0:	0080                	addi	s0,sp,64
     4e2:	8a2a                	mv	s4,a0
     4e4:	892e                	mv	s2,a1
     4e6:	8ab2                	mv	s5,a2
     4e8:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     4ea:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     4ec:	00001997          	auipc	s3,0x1
     4f0:	08498993          	addi	s3,s3,132 # 1570 <whitespace>
     4f4:	00b4fd63          	bgeu	s1,a1,50e <gettoken+0x40>
     4f8:	0004c583          	lbu	a1,0(s1)
     4fc:	854e                	mv	a0,s3
     4fe:	00000097          	auipc	ra,0x0
     502:	7dc080e7          	jalr	2012(ra) # cda <strchr>
     506:	c501                	beqz	a0,50e <gettoken+0x40>
    s++;
     508:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     50a:	fe9917e3          	bne	s2,s1,4f8 <gettoken+0x2a>
  if(q)
     50e:	000a8463          	beqz	s5,516 <gettoken+0x48>
    *q = s;
     512:	009ab023          	sd	s1,0(s5)
  ret = *s;
     516:	0004c783          	lbu	a5,0(s1)
     51a:	00078a9b          	sext.w	s5,a5
  switch(*s){
     51e:	03c00713          	li	a4,60
     522:	06f76563          	bltu	a4,a5,58c <gettoken+0xbe>
     526:	03a00713          	li	a4,58
     52a:	00f76e63          	bltu	a4,a5,546 <gettoken+0x78>
     52e:	cf89                	beqz	a5,548 <gettoken+0x7a>
     530:	02600713          	li	a4,38
     534:	00e78963          	beq	a5,a4,546 <gettoken+0x78>
     538:	fd87879b          	addiw	a5,a5,-40
     53c:	0ff7f793          	andi	a5,a5,255
     540:	4705                	li	a4,1
     542:	06f76c63          	bltu	a4,a5,5ba <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     546:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     548:	000b0463          	beqz	s6,550 <gettoken+0x82>
    *eq = s;
     54c:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     550:	00001997          	auipc	s3,0x1
     554:	02098993          	addi	s3,s3,32 # 1570 <whitespace>
     558:	0124fd63          	bgeu	s1,s2,572 <gettoken+0xa4>
     55c:	0004c583          	lbu	a1,0(s1)
     560:	854e                	mv	a0,s3
     562:	00000097          	auipc	ra,0x0
     566:	778080e7          	jalr	1912(ra) # cda <strchr>
     56a:	c501                	beqz	a0,572 <gettoken+0xa4>
    s++;
     56c:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     56e:	fe9917e3          	bne	s2,s1,55c <gettoken+0x8e>
  *ps = s;
     572:	009a3023          	sd	s1,0(s4)
  return ret;
}
     576:	8556                	mv	a0,s5
     578:	70e2                	ld	ra,56(sp)
     57a:	7442                	ld	s0,48(sp)
     57c:	74a2                	ld	s1,40(sp)
     57e:	7902                	ld	s2,32(sp)
     580:	69e2                	ld	s3,24(sp)
     582:	6a42                	ld	s4,16(sp)
     584:	6aa2                	ld	s5,8(sp)
     586:	6b02                	ld	s6,0(sp)
     588:	6121                	addi	sp,sp,64
     58a:	8082                	ret
  switch(*s){
     58c:	03e00713          	li	a4,62
     590:	02e79163          	bne	a5,a4,5b2 <gettoken+0xe4>
    s++;
     594:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     598:	0014c703          	lbu	a4,1(s1)
     59c:	03e00793          	li	a5,62
      s++;
     5a0:	0489                	addi	s1,s1,2
      ret = '+';
     5a2:	02b00a93          	li	s5,43
    if(*s == '>'){
     5a6:	faf701e3          	beq	a4,a5,548 <gettoken+0x7a>
    s++;
     5aa:	84b6                	mv	s1,a3
  ret = *s;
     5ac:	03e00a93          	li	s5,62
     5b0:	bf61                	j	548 <gettoken+0x7a>
  switch(*s){
     5b2:	07c00713          	li	a4,124
     5b6:	f8e788e3          	beq	a5,a4,546 <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5ba:	00001997          	auipc	s3,0x1
     5be:	fb698993          	addi	s3,s3,-74 # 1570 <whitespace>
     5c2:	00001a97          	auipc	s5,0x1
     5c6:	fa6a8a93          	addi	s5,s5,-90 # 1568 <symbols>
     5ca:	0324f563          	bgeu	s1,s2,5f4 <gettoken+0x126>
     5ce:	0004c583          	lbu	a1,0(s1)
     5d2:	854e                	mv	a0,s3
     5d4:	00000097          	auipc	ra,0x0
     5d8:	706080e7          	jalr	1798(ra) # cda <strchr>
     5dc:	e505                	bnez	a0,604 <gettoken+0x136>
     5de:	0004c583          	lbu	a1,0(s1)
     5e2:	8556                	mv	a0,s5
     5e4:	00000097          	auipc	ra,0x0
     5e8:	6f6080e7          	jalr	1782(ra) # cda <strchr>
     5ec:	e909                	bnez	a0,5fe <gettoken+0x130>
      s++;
     5ee:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5f0:	fc991fe3          	bne	s2,s1,5ce <gettoken+0x100>
  if(eq)
     5f4:	06100a93          	li	s5,97
     5f8:	f40b1ae3          	bnez	s6,54c <gettoken+0x7e>
     5fc:	bf9d                	j	572 <gettoken+0xa4>
    ret = 'a';
     5fe:	06100a93          	li	s5,97
     602:	b799                	j	548 <gettoken+0x7a>
     604:	06100a93          	li	s5,97
     608:	b781                	j	548 <gettoken+0x7a>

000000000000060a <peek>:

int
peek(char **ps, char *es, char *toks)
{
     60a:	7139                	addi	sp,sp,-64
     60c:	fc06                	sd	ra,56(sp)
     60e:	f822                	sd	s0,48(sp)
     610:	f426                	sd	s1,40(sp)
     612:	f04a                	sd	s2,32(sp)
     614:	ec4e                	sd	s3,24(sp)
     616:	e852                	sd	s4,16(sp)
     618:	e456                	sd	s5,8(sp)
     61a:	0080                	addi	s0,sp,64
     61c:	8a2a                	mv	s4,a0
     61e:	892e                	mv	s2,a1
     620:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     622:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     624:	00001997          	auipc	s3,0x1
     628:	f4c98993          	addi	s3,s3,-180 # 1570 <whitespace>
     62c:	00b4fd63          	bgeu	s1,a1,646 <peek+0x3c>
     630:	0004c583          	lbu	a1,0(s1)
     634:	854e                	mv	a0,s3
     636:	00000097          	auipc	ra,0x0
     63a:	6a4080e7          	jalr	1700(ra) # cda <strchr>
     63e:	c501                	beqz	a0,646 <peek+0x3c>
    s++;
     640:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     642:	fe9917e3          	bne	s2,s1,630 <peek+0x26>
  *ps = s;
     646:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     64a:	0004c583          	lbu	a1,0(s1)
     64e:	4501                	li	a0,0
     650:	e991                	bnez	a1,664 <peek+0x5a>
}
     652:	70e2                	ld	ra,56(sp)
     654:	7442                	ld	s0,48(sp)
     656:	74a2                	ld	s1,40(sp)
     658:	7902                	ld	s2,32(sp)
     65a:	69e2                	ld	s3,24(sp)
     65c:	6a42                	ld	s4,16(sp)
     65e:	6aa2                	ld	s5,8(sp)
     660:	6121                	addi	sp,sp,64
     662:	8082                	ret
  return *s && strchr(toks, *s);
     664:	8556                	mv	a0,s5
     666:	00000097          	auipc	ra,0x0
     66a:	674080e7          	jalr	1652(ra) # cda <strchr>
     66e:	00a03533          	snez	a0,a0
     672:	b7c5                	j	652 <peek+0x48>

0000000000000674 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     674:	7159                	addi	sp,sp,-112
     676:	f486                	sd	ra,104(sp)
     678:	f0a2                	sd	s0,96(sp)
     67a:	eca6                	sd	s1,88(sp)
     67c:	e8ca                	sd	s2,80(sp)
     67e:	e4ce                	sd	s3,72(sp)
     680:	e0d2                	sd	s4,64(sp)
     682:	fc56                	sd	s5,56(sp)
     684:	f85a                	sd	s6,48(sp)
     686:	f45e                	sd	s7,40(sp)
     688:	f062                	sd	s8,32(sp)
     68a:	ec66                	sd	s9,24(sp)
     68c:	1880                	addi	s0,sp,112
     68e:	8a2a                	mv	s4,a0
     690:	89ae                	mv	s3,a1
     692:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     694:	00001b97          	auipc	s7,0x1
     698:	ddcb8b93          	addi	s7,s7,-548 # 1470 <malloc+0x16e>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     69c:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     6a0:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     6a4:	a02d                	j	6ce <parseredirs+0x5a>
      panic("missing file for redirection");
     6a6:	00001517          	auipc	a0,0x1
     6aa:	daa50513          	addi	a0,a0,-598 # 1450 <malloc+0x14e>
     6ae:	00000097          	auipc	ra,0x0
     6b2:	a8e080e7          	jalr	-1394(ra) # 13c <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     6b6:	4701                	li	a4,0
     6b8:	4681                	li	a3,0
     6ba:	f9043603          	ld	a2,-112(s0)
     6be:	f9843583          	ld	a1,-104(s0)
     6c2:	8552                	mv	a0,s4
     6c4:	00000097          	auipc	ra,0x0
     6c8:	cda080e7          	jalr	-806(ra) # 39e <redircmd>
     6cc:	8a2a                	mv	s4,a0
    switch(tok){
     6ce:	03e00b13          	li	s6,62
     6d2:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     6d6:	865e                	mv	a2,s7
     6d8:	85ca                	mv	a1,s2
     6da:	854e                	mv	a0,s3
     6dc:	00000097          	auipc	ra,0x0
     6e0:	f2e080e7          	jalr	-210(ra) # 60a <peek>
     6e4:	c925                	beqz	a0,754 <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     6e6:	4681                	li	a3,0
     6e8:	4601                	li	a2,0
     6ea:	85ca                	mv	a1,s2
     6ec:	854e                	mv	a0,s3
     6ee:	00000097          	auipc	ra,0x0
     6f2:	de0080e7          	jalr	-544(ra) # 4ce <gettoken>
     6f6:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     6f8:	f9040693          	addi	a3,s0,-112
     6fc:	f9840613          	addi	a2,s0,-104
     700:	85ca                	mv	a1,s2
     702:	854e                	mv	a0,s3
     704:	00000097          	auipc	ra,0x0
     708:	dca080e7          	jalr	-566(ra) # 4ce <gettoken>
     70c:	f9851de3          	bne	a0,s8,6a6 <parseredirs+0x32>
    switch(tok){
     710:	fb9483e3          	beq	s1,s9,6b6 <parseredirs+0x42>
     714:	03648263          	beq	s1,s6,738 <parseredirs+0xc4>
     718:	fb549fe3          	bne	s1,s5,6d6 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     71c:	4705                	li	a4,1
     71e:	20100693          	li	a3,513
     722:	f9043603          	ld	a2,-112(s0)
     726:	f9843583          	ld	a1,-104(s0)
     72a:	8552                	mv	a0,s4
     72c:	00000097          	auipc	ra,0x0
     730:	c72080e7          	jalr	-910(ra) # 39e <redircmd>
     734:	8a2a                	mv	s4,a0
      break;
     736:	bf61                	j	6ce <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     738:	4705                	li	a4,1
     73a:	60100693          	li	a3,1537
     73e:	f9043603          	ld	a2,-112(s0)
     742:	f9843583          	ld	a1,-104(s0)
     746:	8552                	mv	a0,s4
     748:	00000097          	auipc	ra,0x0
     74c:	c56080e7          	jalr	-938(ra) # 39e <redircmd>
     750:	8a2a                	mv	s4,a0
      break;
     752:	bfb5                	j	6ce <parseredirs+0x5a>
    }
  }
  return cmd;
}
     754:	8552                	mv	a0,s4
     756:	70a6                	ld	ra,104(sp)
     758:	7406                	ld	s0,96(sp)
     75a:	64e6                	ld	s1,88(sp)
     75c:	6946                	ld	s2,80(sp)
     75e:	69a6                	ld	s3,72(sp)
     760:	6a06                	ld	s4,64(sp)
     762:	7ae2                	ld	s5,56(sp)
     764:	7b42                	ld	s6,48(sp)
     766:	7ba2                	ld	s7,40(sp)
     768:	7c02                	ld	s8,32(sp)
     76a:	6ce2                	ld	s9,24(sp)
     76c:	6165                	addi	sp,sp,112
     76e:	8082                	ret

0000000000000770 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     770:	7159                	addi	sp,sp,-112
     772:	f486                	sd	ra,104(sp)
     774:	f0a2                	sd	s0,96(sp)
     776:	eca6                	sd	s1,88(sp)
     778:	e8ca                	sd	s2,80(sp)
     77a:	e4ce                	sd	s3,72(sp)
     77c:	e0d2                	sd	s4,64(sp)
     77e:	fc56                	sd	s5,56(sp)
     780:	f85a                	sd	s6,48(sp)
     782:	f45e                	sd	s7,40(sp)
     784:	f062                	sd	s8,32(sp)
     786:	ec66                	sd	s9,24(sp)
     788:	1880                	addi	s0,sp,112
     78a:	8a2a                	mv	s4,a0
     78c:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     78e:	00001617          	auipc	a2,0x1
     792:	cea60613          	addi	a2,a2,-790 # 1478 <malloc+0x176>
     796:	00000097          	auipc	ra,0x0
     79a:	e74080e7          	jalr	-396(ra) # 60a <peek>
     79e:	e905                	bnez	a0,7ce <parseexec+0x5e>
     7a0:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     7a2:	00000097          	auipc	ra,0x0
     7a6:	bc6080e7          	jalr	-1082(ra) # 368 <execcmd>
     7aa:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     7ac:	8656                	mv	a2,s5
     7ae:	85d2                	mv	a1,s4
     7b0:	00000097          	auipc	ra,0x0
     7b4:	ec4080e7          	jalr	-316(ra) # 674 <parseredirs>
     7b8:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     7ba:	008c0913          	addi	s2,s8,8
     7be:	00001b17          	auipc	s6,0x1
     7c2:	cdab0b13          	addi	s6,s6,-806 # 1498 <malloc+0x196>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     7c6:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     7ca:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     7cc:	a0b1                	j	818 <parseexec+0xa8>
    return parseblock(ps, es);
     7ce:	85d6                	mv	a1,s5
     7d0:	8552                	mv	a0,s4
     7d2:	00000097          	auipc	ra,0x0
     7d6:	1bc080e7          	jalr	444(ra) # 98e <parseblock>
     7da:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     7dc:	8526                	mv	a0,s1
     7de:	70a6                	ld	ra,104(sp)
     7e0:	7406                	ld	s0,96(sp)
     7e2:	64e6                	ld	s1,88(sp)
     7e4:	6946                	ld	s2,80(sp)
     7e6:	69a6                	ld	s3,72(sp)
     7e8:	6a06                	ld	s4,64(sp)
     7ea:	7ae2                	ld	s5,56(sp)
     7ec:	7b42                	ld	s6,48(sp)
     7ee:	7ba2                	ld	s7,40(sp)
     7f0:	7c02                	ld	s8,32(sp)
     7f2:	6ce2                	ld	s9,24(sp)
     7f4:	6165                	addi	sp,sp,112
     7f6:	8082                	ret
      panic("syntax");
     7f8:	00001517          	auipc	a0,0x1
     7fc:	c8850513          	addi	a0,a0,-888 # 1480 <malloc+0x17e>
     800:	00000097          	auipc	ra,0x0
     804:	93c080e7          	jalr	-1732(ra) # 13c <panic>
    ret = parseredirs(ret, ps, es);
     808:	8656                	mv	a2,s5
     80a:	85d2                	mv	a1,s4
     80c:	8526                	mv	a0,s1
     80e:	00000097          	auipc	ra,0x0
     812:	e66080e7          	jalr	-410(ra) # 674 <parseredirs>
     816:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     818:	865a                	mv	a2,s6
     81a:	85d6                	mv	a1,s5
     81c:	8552                	mv	a0,s4
     81e:	00000097          	auipc	ra,0x0
     822:	dec080e7          	jalr	-532(ra) # 60a <peek>
     826:	e131                	bnez	a0,86a <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     828:	f9040693          	addi	a3,s0,-112
     82c:	f9840613          	addi	a2,s0,-104
     830:	85d6                	mv	a1,s5
     832:	8552                	mv	a0,s4
     834:	00000097          	auipc	ra,0x0
     838:	c9a080e7          	jalr	-870(ra) # 4ce <gettoken>
     83c:	c51d                	beqz	a0,86a <parseexec+0xfa>
    if(tok != 'a')
     83e:	fb951de3          	bne	a0,s9,7f8 <parseexec+0x88>
    cmd->argv[argc] = q;
     842:	f9843783          	ld	a5,-104(s0)
     846:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     84a:	f9043783          	ld	a5,-112(s0)
     84e:	04f93823          	sd	a5,80(s2)
    argc++;
     852:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     854:	0921                	addi	s2,s2,8
     856:	fb7999e3          	bne	s3,s7,808 <parseexec+0x98>
      panic("too many args");
     85a:	00001517          	auipc	a0,0x1
     85e:	c2e50513          	addi	a0,a0,-978 # 1488 <malloc+0x186>
     862:	00000097          	auipc	ra,0x0
     866:	8da080e7          	jalr	-1830(ra) # 13c <panic>
  cmd->argv[argc] = 0;
     86a:	098e                	slli	s3,s3,0x3
     86c:	99e2                	add	s3,s3,s8
     86e:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     872:	0409bc23          	sd	zero,88(s3)
  return ret;
     876:	b79d                	j	7dc <parseexec+0x6c>

0000000000000878 <parsepipe>:
{
     878:	7179                	addi	sp,sp,-48
     87a:	f406                	sd	ra,40(sp)
     87c:	f022                	sd	s0,32(sp)
     87e:	ec26                	sd	s1,24(sp)
     880:	e84a                	sd	s2,16(sp)
     882:	e44e                	sd	s3,8(sp)
     884:	1800                	addi	s0,sp,48
     886:	892a                	mv	s2,a0
     888:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     88a:	00000097          	auipc	ra,0x0
     88e:	ee6080e7          	jalr	-282(ra) # 770 <parseexec>
     892:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     894:	00001617          	auipc	a2,0x1
     898:	c0c60613          	addi	a2,a2,-1012 # 14a0 <malloc+0x19e>
     89c:	85ce                	mv	a1,s3
     89e:	854a                	mv	a0,s2
     8a0:	00000097          	auipc	ra,0x0
     8a4:	d6a080e7          	jalr	-662(ra) # 60a <peek>
     8a8:	e909                	bnez	a0,8ba <parsepipe+0x42>
}
     8aa:	8526                	mv	a0,s1
     8ac:	70a2                	ld	ra,40(sp)
     8ae:	7402                	ld	s0,32(sp)
     8b0:	64e2                	ld	s1,24(sp)
     8b2:	6942                	ld	s2,16(sp)
     8b4:	69a2                	ld	s3,8(sp)
     8b6:	6145                	addi	sp,sp,48
     8b8:	8082                	ret
    gettoken(ps, es, 0, 0);
     8ba:	4681                	li	a3,0
     8bc:	4601                	li	a2,0
     8be:	85ce                	mv	a1,s3
     8c0:	854a                	mv	a0,s2
     8c2:	00000097          	auipc	ra,0x0
     8c6:	c0c080e7          	jalr	-1012(ra) # 4ce <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8ca:	85ce                	mv	a1,s3
     8cc:	854a                	mv	a0,s2
     8ce:	00000097          	auipc	ra,0x0
     8d2:	faa080e7          	jalr	-86(ra) # 878 <parsepipe>
     8d6:	85aa                	mv	a1,a0
     8d8:	8526                	mv	a0,s1
     8da:	00000097          	auipc	ra,0x0
     8de:	b2c080e7          	jalr	-1236(ra) # 406 <pipecmd>
     8e2:	84aa                	mv	s1,a0
  return cmd;
     8e4:	b7d9                	j	8aa <parsepipe+0x32>

00000000000008e6 <parseline>:
{
     8e6:	7179                	addi	sp,sp,-48
     8e8:	f406                	sd	ra,40(sp)
     8ea:	f022                	sd	s0,32(sp)
     8ec:	ec26                	sd	s1,24(sp)
     8ee:	e84a                	sd	s2,16(sp)
     8f0:	e44e                	sd	s3,8(sp)
     8f2:	e052                	sd	s4,0(sp)
     8f4:	1800                	addi	s0,sp,48
     8f6:	892a                	mv	s2,a0
     8f8:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     8fa:	00000097          	auipc	ra,0x0
     8fe:	f7e080e7          	jalr	-130(ra) # 878 <parsepipe>
     902:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     904:	00001a17          	auipc	s4,0x1
     908:	ba4a0a13          	addi	s4,s4,-1116 # 14a8 <malloc+0x1a6>
     90c:	a839                	j	92a <parseline+0x44>
    gettoken(ps, es, 0, 0);
     90e:	4681                	li	a3,0
     910:	4601                	li	a2,0
     912:	85ce                	mv	a1,s3
     914:	854a                	mv	a0,s2
     916:	00000097          	auipc	ra,0x0
     91a:	bb8080e7          	jalr	-1096(ra) # 4ce <gettoken>
    cmd = backcmd(cmd);
     91e:	8526                	mv	a0,s1
     920:	00000097          	auipc	ra,0x0
     924:	b72080e7          	jalr	-1166(ra) # 492 <backcmd>
     928:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     92a:	8652                	mv	a2,s4
     92c:	85ce                	mv	a1,s3
     92e:	854a                	mv	a0,s2
     930:	00000097          	auipc	ra,0x0
     934:	cda080e7          	jalr	-806(ra) # 60a <peek>
     938:	f979                	bnez	a0,90e <parseline+0x28>
  if(peek(ps, es, ";")){
     93a:	00001617          	auipc	a2,0x1
     93e:	b7660613          	addi	a2,a2,-1162 # 14b0 <malloc+0x1ae>
     942:	85ce                	mv	a1,s3
     944:	854a                	mv	a0,s2
     946:	00000097          	auipc	ra,0x0
     94a:	cc4080e7          	jalr	-828(ra) # 60a <peek>
     94e:	e911                	bnez	a0,962 <parseline+0x7c>
}
     950:	8526                	mv	a0,s1
     952:	70a2                	ld	ra,40(sp)
     954:	7402                	ld	s0,32(sp)
     956:	64e2                	ld	s1,24(sp)
     958:	6942                	ld	s2,16(sp)
     95a:	69a2                	ld	s3,8(sp)
     95c:	6a02                	ld	s4,0(sp)
     95e:	6145                	addi	sp,sp,48
     960:	8082                	ret
    gettoken(ps, es, 0, 0);
     962:	4681                	li	a3,0
     964:	4601                	li	a2,0
     966:	85ce                	mv	a1,s3
     968:	854a                	mv	a0,s2
     96a:	00000097          	auipc	ra,0x0
     96e:	b64080e7          	jalr	-1180(ra) # 4ce <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     972:	85ce                	mv	a1,s3
     974:	854a                	mv	a0,s2
     976:	00000097          	auipc	ra,0x0
     97a:	f70080e7          	jalr	-144(ra) # 8e6 <parseline>
     97e:	85aa                	mv	a1,a0
     980:	8526                	mv	a0,s1
     982:	00000097          	auipc	ra,0x0
     986:	aca080e7          	jalr	-1334(ra) # 44c <listcmd>
     98a:	84aa                	mv	s1,a0
  return cmd;
     98c:	b7d1                	j	950 <parseline+0x6a>

000000000000098e <parseblock>:
{
     98e:	7179                	addi	sp,sp,-48
     990:	f406                	sd	ra,40(sp)
     992:	f022                	sd	s0,32(sp)
     994:	ec26                	sd	s1,24(sp)
     996:	e84a                	sd	s2,16(sp)
     998:	e44e                	sd	s3,8(sp)
     99a:	1800                	addi	s0,sp,48
     99c:	84aa                	mv	s1,a0
     99e:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     9a0:	00001617          	auipc	a2,0x1
     9a4:	ad860613          	addi	a2,a2,-1320 # 1478 <malloc+0x176>
     9a8:	00000097          	auipc	ra,0x0
     9ac:	c62080e7          	jalr	-926(ra) # 60a <peek>
     9b0:	c12d                	beqz	a0,a12 <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     9b2:	4681                	li	a3,0
     9b4:	4601                	li	a2,0
     9b6:	85ca                	mv	a1,s2
     9b8:	8526                	mv	a0,s1
     9ba:	00000097          	auipc	ra,0x0
     9be:	b14080e7          	jalr	-1260(ra) # 4ce <gettoken>
  cmd = parseline(ps, es);
     9c2:	85ca                	mv	a1,s2
     9c4:	8526                	mv	a0,s1
     9c6:	00000097          	auipc	ra,0x0
     9ca:	f20080e7          	jalr	-224(ra) # 8e6 <parseline>
     9ce:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     9d0:	00001617          	auipc	a2,0x1
     9d4:	af860613          	addi	a2,a2,-1288 # 14c8 <malloc+0x1c6>
     9d8:	85ca                	mv	a1,s2
     9da:	8526                	mv	a0,s1
     9dc:	00000097          	auipc	ra,0x0
     9e0:	c2e080e7          	jalr	-978(ra) # 60a <peek>
     9e4:	cd1d                	beqz	a0,a22 <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     9e6:	4681                	li	a3,0
     9e8:	4601                	li	a2,0
     9ea:	85ca                	mv	a1,s2
     9ec:	8526                	mv	a0,s1
     9ee:	00000097          	auipc	ra,0x0
     9f2:	ae0080e7          	jalr	-1312(ra) # 4ce <gettoken>
  cmd = parseredirs(cmd, ps, es);
     9f6:	864a                	mv	a2,s2
     9f8:	85a6                	mv	a1,s1
     9fa:	854e                	mv	a0,s3
     9fc:	00000097          	auipc	ra,0x0
     a00:	c78080e7          	jalr	-904(ra) # 674 <parseredirs>
}
     a04:	70a2                	ld	ra,40(sp)
     a06:	7402                	ld	s0,32(sp)
     a08:	64e2                	ld	s1,24(sp)
     a0a:	6942                	ld	s2,16(sp)
     a0c:	69a2                	ld	s3,8(sp)
     a0e:	6145                	addi	sp,sp,48
     a10:	8082                	ret
    panic("parseblock");
     a12:	00001517          	auipc	a0,0x1
     a16:	aa650513          	addi	a0,a0,-1370 # 14b8 <malloc+0x1b6>
     a1a:	fffff097          	auipc	ra,0xfffff
     a1e:	722080e7          	jalr	1826(ra) # 13c <panic>
    panic("syntax - missing )");
     a22:	00001517          	auipc	a0,0x1
     a26:	aae50513          	addi	a0,a0,-1362 # 14d0 <malloc+0x1ce>
     a2a:	fffff097          	auipc	ra,0xfffff
     a2e:	712080e7          	jalr	1810(ra) # 13c <panic>

0000000000000a32 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     a32:	1101                	addi	sp,sp,-32
     a34:	ec06                	sd	ra,24(sp)
     a36:	e822                	sd	s0,16(sp)
     a38:	e426                	sd	s1,8(sp)
     a3a:	1000                	addi	s0,sp,32
     a3c:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     a3e:	c521                	beqz	a0,a86 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     a40:	4118                	lw	a4,0(a0)
     a42:	4795                	li	a5,5
     a44:	04e7e163          	bltu	a5,a4,a86 <nulterminate+0x54>
     a48:	00056783          	lwu	a5,0(a0)
     a4c:	078a                	slli	a5,a5,0x2
     a4e:	00001717          	auipc	a4,0x1
     a52:	ae270713          	addi	a4,a4,-1310 # 1530 <malloc+0x22e>
     a56:	97ba                	add	a5,a5,a4
     a58:	439c                	lw	a5,0(a5)
     a5a:	97ba                	add	a5,a5,a4
     a5c:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     a5e:	651c                	ld	a5,8(a0)
     a60:	c39d                	beqz	a5,a86 <nulterminate+0x54>
     a62:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     a66:	67b8                	ld	a4,72(a5)
     a68:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     a6c:	07a1                	addi	a5,a5,8
     a6e:	ff87b703          	ld	a4,-8(a5)
     a72:	fb75                	bnez	a4,a66 <nulterminate+0x34>
     a74:	a809                	j	a86 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     a76:	6508                	ld	a0,8(a0)
     a78:	00000097          	auipc	ra,0x0
     a7c:	fba080e7          	jalr	-70(ra) # a32 <nulterminate>
    *rcmd->efile = 0;
     a80:	6c9c                	ld	a5,24(s1)
     a82:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
     a86:	8526                	mv	a0,s1
     a88:	60e2                	ld	ra,24(sp)
     a8a:	6442                	ld	s0,16(sp)
     a8c:	64a2                	ld	s1,8(sp)
     a8e:	6105                	addi	sp,sp,32
     a90:	8082                	ret
    nulterminate(pcmd->left);
     a92:	6508                	ld	a0,8(a0)
     a94:	00000097          	auipc	ra,0x0
     a98:	f9e080e7          	jalr	-98(ra) # a32 <nulterminate>
    nulterminate(pcmd->right);
     a9c:	6888                	ld	a0,16(s1)
     a9e:	00000097          	auipc	ra,0x0
     aa2:	f94080e7          	jalr	-108(ra) # a32 <nulterminate>
    break;
     aa6:	b7c5                	j	a86 <nulterminate+0x54>
    nulterminate(lcmd->left);
     aa8:	6508                	ld	a0,8(a0)
     aaa:	00000097          	auipc	ra,0x0
     aae:	f88080e7          	jalr	-120(ra) # a32 <nulterminate>
    nulterminate(lcmd->right);
     ab2:	6888                	ld	a0,16(s1)
     ab4:	00000097          	auipc	ra,0x0
     ab8:	f7e080e7          	jalr	-130(ra) # a32 <nulterminate>
    break;
     abc:	b7e9                	j	a86 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     abe:	6508                	ld	a0,8(a0)
     ac0:	00000097          	auipc	ra,0x0
     ac4:	f72080e7          	jalr	-142(ra) # a32 <nulterminate>
    break;
     ac8:	bf7d                	j	a86 <nulterminate+0x54>

0000000000000aca <parsecmd>:
{
     aca:	7179                	addi	sp,sp,-48
     acc:	f406                	sd	ra,40(sp)
     ace:	f022                	sd	s0,32(sp)
     ad0:	ec26                	sd	s1,24(sp)
     ad2:	e84a                	sd	s2,16(sp)
     ad4:	1800                	addi	s0,sp,48
     ad6:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     ada:	84aa                	mv	s1,a0
     adc:	00000097          	auipc	ra,0x0
     ae0:	1b2080e7          	jalr	434(ra) # c8e <strlen>
     ae4:	1502                	slli	a0,a0,0x20
     ae6:	9101                	srli	a0,a0,0x20
     ae8:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     aea:	85a6                	mv	a1,s1
     aec:	fd840513          	addi	a0,s0,-40
     af0:	00000097          	auipc	ra,0x0
     af4:	df6080e7          	jalr	-522(ra) # 8e6 <parseline>
     af8:	892a                	mv	s2,a0
  peek(&s, es, "");
     afa:	00001617          	auipc	a2,0x1
     afe:	9ee60613          	addi	a2,a2,-1554 # 14e8 <malloc+0x1e6>
     b02:	85a6                	mv	a1,s1
     b04:	fd840513          	addi	a0,s0,-40
     b08:	00000097          	auipc	ra,0x0
     b0c:	b02080e7          	jalr	-1278(ra) # 60a <peek>
  if(s != es){
     b10:	fd843603          	ld	a2,-40(s0)
     b14:	00961e63          	bne	a2,s1,b30 <parsecmd+0x66>
  nulterminate(cmd);
     b18:	854a                	mv	a0,s2
     b1a:	00000097          	auipc	ra,0x0
     b1e:	f18080e7          	jalr	-232(ra) # a32 <nulterminate>
}
     b22:	854a                	mv	a0,s2
     b24:	70a2                	ld	ra,40(sp)
     b26:	7402                	ld	s0,32(sp)
     b28:	64e2                	ld	s1,24(sp)
     b2a:	6942                	ld	s2,16(sp)
     b2c:	6145                	addi	sp,sp,48
     b2e:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     b30:	00001597          	auipc	a1,0x1
     b34:	9c058593          	addi	a1,a1,-1600 # 14f0 <malloc+0x1ee>
     b38:	4509                	li	a0,2
     b3a:	00000097          	auipc	ra,0x0
     b3e:	6dc080e7          	jalr	1756(ra) # 1216 <fprintf>
    panic("syntax");
     b42:	00001517          	auipc	a0,0x1
     b46:	93e50513          	addi	a0,a0,-1730 # 1480 <malloc+0x17e>
     b4a:	fffff097          	auipc	ra,0xfffff
     b4e:	5f2080e7          	jalr	1522(ra) # 13c <panic>

0000000000000b52 <main>:
{
     b52:	7139                	addi	sp,sp,-64
     b54:	fc06                	sd	ra,56(sp)
     b56:	f822                	sd	s0,48(sp)
     b58:	f426                	sd	s1,40(sp)
     b5a:	f04a                	sd	s2,32(sp)
     b5c:	ec4e                	sd	s3,24(sp)
     b5e:	e852                	sd	s4,16(sp)
     b60:	e456                	sd	s5,8(sp)
     b62:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     b64:	00001497          	auipc	s1,0x1
     b68:	99c48493          	addi	s1,s1,-1636 # 1500 <malloc+0x1fe>
     b6c:	4589                	li	a1,2
     b6e:	8526                	mv	a0,s1
     b70:	00000097          	auipc	ra,0x0
     b74:	384080e7          	jalr	900(ra) # ef4 <open>
     b78:	00054963          	bltz	a0,b8a <main+0x38>
    if(fd >= 3){
     b7c:	4789                	li	a5,2
     b7e:	fea7d7e3          	bge	a5,a0,b6c <main+0x1a>
      close(fd);
     b82:	00000097          	auipc	ra,0x0
     b86:	35a080e7          	jalr	858(ra) # edc <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b8a:	00001497          	auipc	s1,0x1
     b8e:	9fe48493          	addi	s1,s1,-1538 # 1588 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b92:	06300913          	li	s2,99
     b96:	02000993          	li	s3,32
      if(chdir(buf+3) < 0)
     b9a:	00001a17          	auipc	s4,0x1
     b9e:	9f1a0a13          	addi	s4,s4,-1551 # 158b <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     ba2:	00001a97          	auipc	s5,0x1
     ba6:	966a8a93          	addi	s5,s5,-1690 # 1508 <malloc+0x206>
     baa:	a819                	j	bc0 <main+0x6e>
    if(fork1() == 0)
     bac:	fffff097          	auipc	ra,0xfffff
     bb0:	5b6080e7          	jalr	1462(ra) # 162 <fork1>
     bb4:	c925                	beqz	a0,c24 <main+0xd2>
    wait(0);
     bb6:	4501                	li	a0,0
     bb8:	00000097          	auipc	ra,0x0
     bbc:	304080e7          	jalr	772(ra) # ebc <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     bc0:	06400593          	li	a1,100
     bc4:	8526                	mv	a0,s1
     bc6:	fffff097          	auipc	ra,0xfffff
     bca:	522080e7          	jalr	1314(ra) # e8 <getcmd>
     bce:	06054763          	bltz	a0,c3c <main+0xea>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     bd2:	0004c783          	lbu	a5,0(s1)
     bd6:	fd279be3          	bne	a5,s2,bac <main+0x5a>
     bda:	0014c703          	lbu	a4,1(s1)
     bde:	06400793          	li	a5,100
     be2:	fcf715e3          	bne	a4,a5,bac <main+0x5a>
     be6:	0024c783          	lbu	a5,2(s1)
     bea:	fd3791e3          	bne	a5,s3,bac <main+0x5a>
      buf[strlen(buf)-1] = 0;  // chop \n
     bee:	8526                	mv	a0,s1
     bf0:	00000097          	auipc	ra,0x0
     bf4:	09e080e7          	jalr	158(ra) # c8e <strlen>
     bf8:	fff5079b          	addiw	a5,a0,-1
     bfc:	1782                	slli	a5,a5,0x20
     bfe:	9381                	srli	a5,a5,0x20
     c00:	97a6                	add	a5,a5,s1
     c02:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     c06:	8552                	mv	a0,s4
     c08:	00000097          	auipc	ra,0x0
     c0c:	31c080e7          	jalr	796(ra) # f24 <chdir>
     c10:	fa0558e3          	bgez	a0,bc0 <main+0x6e>
        fprintf(2, "cannot cd %s\n", buf+3);
     c14:	8652                	mv	a2,s4
     c16:	85d6                	mv	a1,s5
     c18:	4509                	li	a0,2
     c1a:	00000097          	auipc	ra,0x0
     c1e:	5fc080e7          	jalr	1532(ra) # 1216 <fprintf>
     c22:	bf79                	j	bc0 <main+0x6e>
      runcmd(parsecmd(buf));
     c24:	00001517          	auipc	a0,0x1
     c28:	96450513          	addi	a0,a0,-1692 # 1588 <buf.0>
     c2c:	00000097          	auipc	ra,0x0
     c30:	e9e080e7          	jalr	-354(ra) # aca <parsecmd>
     c34:	fffff097          	auipc	ra,0xfffff
     c38:	55c080e7          	jalr	1372(ra) # 190 <runcmd>
  exit(0);
     c3c:	4501                	li	a0,0
     c3e:	00000097          	auipc	ra,0x0
     c42:	276080e7          	jalr	630(ra) # eb4 <exit>

0000000000000c46 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     c46:	1141                	addi	sp,sp,-16
     c48:	e422                	sd	s0,8(sp)
     c4a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c4c:	87aa                	mv	a5,a0
     c4e:	0585                	addi	a1,a1,1
     c50:	0785                	addi	a5,a5,1
     c52:	fff5c703          	lbu	a4,-1(a1)
     c56:	fee78fa3          	sb	a4,-1(a5)
     c5a:	fb75                	bnez	a4,c4e <strcpy+0x8>
    ;
  return os;
}
     c5c:	6422                	ld	s0,8(sp)
     c5e:	0141                	addi	sp,sp,16
     c60:	8082                	ret

0000000000000c62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c62:	1141                	addi	sp,sp,-16
     c64:	e422                	sd	s0,8(sp)
     c66:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c68:	00054783          	lbu	a5,0(a0)
     c6c:	cb91                	beqz	a5,c80 <strcmp+0x1e>
     c6e:	0005c703          	lbu	a4,0(a1)
     c72:	00f71763          	bne	a4,a5,c80 <strcmp+0x1e>
    p++, q++;
     c76:	0505                	addi	a0,a0,1
     c78:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c7a:	00054783          	lbu	a5,0(a0)
     c7e:	fbe5                	bnez	a5,c6e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c80:	0005c503          	lbu	a0,0(a1)
}
     c84:	40a7853b          	subw	a0,a5,a0
     c88:	6422                	ld	s0,8(sp)
     c8a:	0141                	addi	sp,sp,16
     c8c:	8082                	ret

0000000000000c8e <strlen>:

uint
strlen(const char *s)
{
     c8e:	1141                	addi	sp,sp,-16
     c90:	e422                	sd	s0,8(sp)
     c92:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c94:	00054783          	lbu	a5,0(a0)
     c98:	cf91                	beqz	a5,cb4 <strlen+0x26>
     c9a:	0505                	addi	a0,a0,1
     c9c:	87aa                	mv	a5,a0
     c9e:	4685                	li	a3,1
     ca0:	9e89                	subw	a3,a3,a0
     ca2:	00f6853b          	addw	a0,a3,a5
     ca6:	0785                	addi	a5,a5,1
     ca8:	fff7c703          	lbu	a4,-1(a5)
     cac:	fb7d                	bnez	a4,ca2 <strlen+0x14>
    ;
  return n;
}
     cae:	6422                	ld	s0,8(sp)
     cb0:	0141                	addi	sp,sp,16
     cb2:	8082                	ret
  for(n = 0; s[n]; n++)
     cb4:	4501                	li	a0,0
     cb6:	bfe5                	j	cae <strlen+0x20>

0000000000000cb8 <memset>:

void*
memset(void *dst, int c, uint n)
{
     cb8:	1141                	addi	sp,sp,-16
     cba:	e422                	sd	s0,8(sp)
     cbc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     cbe:	ca19                	beqz	a2,cd4 <memset+0x1c>
     cc0:	87aa                	mv	a5,a0
     cc2:	1602                	slli	a2,a2,0x20
     cc4:	9201                	srli	a2,a2,0x20
     cc6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     cca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cce:	0785                	addi	a5,a5,1
     cd0:	fee79de3          	bne	a5,a4,cca <memset+0x12>
  }
  return dst;
}
     cd4:	6422                	ld	s0,8(sp)
     cd6:	0141                	addi	sp,sp,16
     cd8:	8082                	ret

0000000000000cda <strchr>:

char*
strchr(const char *s, char c)
{
     cda:	1141                	addi	sp,sp,-16
     cdc:	e422                	sd	s0,8(sp)
     cde:	0800                	addi	s0,sp,16
  for(; *s; s++)
     ce0:	00054783          	lbu	a5,0(a0)
     ce4:	cb99                	beqz	a5,cfa <strchr+0x20>
    if(*s == c)
     ce6:	00f58763          	beq	a1,a5,cf4 <strchr+0x1a>
  for(; *s; s++)
     cea:	0505                	addi	a0,a0,1
     cec:	00054783          	lbu	a5,0(a0)
     cf0:	fbfd                	bnez	a5,ce6 <strchr+0xc>
      return (char*)s;
  return 0;
     cf2:	4501                	li	a0,0
}
     cf4:	6422                	ld	s0,8(sp)
     cf6:	0141                	addi	sp,sp,16
     cf8:	8082                	ret
  return 0;
     cfa:	4501                	li	a0,0
     cfc:	bfe5                	j	cf4 <strchr+0x1a>

0000000000000cfe <gets>:

char*
gets(char *buf, int max)
{
     cfe:	711d                	addi	sp,sp,-96
     d00:	ec86                	sd	ra,88(sp)
     d02:	e8a2                	sd	s0,80(sp)
     d04:	e4a6                	sd	s1,72(sp)
     d06:	e0ca                	sd	s2,64(sp)
     d08:	fc4e                	sd	s3,56(sp)
     d0a:	f852                	sd	s4,48(sp)
     d0c:	f456                	sd	s5,40(sp)
     d0e:	f05a                	sd	s6,32(sp)
     d10:	ec5e                	sd	s7,24(sp)
     d12:	1080                	addi	s0,sp,96
     d14:	8baa                	mv	s7,a0
     d16:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d18:	892a                	mv	s2,a0
     d1a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d1c:	4aa9                	li	s5,10
     d1e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d20:	89a6                	mv	s3,s1
     d22:	2485                	addiw	s1,s1,1
     d24:	0344d863          	bge	s1,s4,d54 <gets+0x56>
    cc = read(0, &c, 1);
     d28:	4605                	li	a2,1
     d2a:	faf40593          	addi	a1,s0,-81
     d2e:	4501                	li	a0,0
     d30:	00000097          	auipc	ra,0x0
     d34:	19c080e7          	jalr	412(ra) # ecc <read>
    if(cc < 1)
     d38:	00a05e63          	blez	a0,d54 <gets+0x56>
    buf[i++] = c;
     d3c:	faf44783          	lbu	a5,-81(s0)
     d40:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d44:	01578763          	beq	a5,s5,d52 <gets+0x54>
     d48:	0905                	addi	s2,s2,1
     d4a:	fd679be3          	bne	a5,s6,d20 <gets+0x22>
  for(i=0; i+1 < max; ){
     d4e:	89a6                	mv	s3,s1
     d50:	a011                	j	d54 <gets+0x56>
     d52:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d54:	99de                	add	s3,s3,s7
     d56:	00098023          	sb	zero,0(s3)
  return buf;
}
     d5a:	855e                	mv	a0,s7
     d5c:	60e6                	ld	ra,88(sp)
     d5e:	6446                	ld	s0,80(sp)
     d60:	64a6                	ld	s1,72(sp)
     d62:	6906                	ld	s2,64(sp)
     d64:	79e2                	ld	s3,56(sp)
     d66:	7a42                	ld	s4,48(sp)
     d68:	7aa2                	ld	s5,40(sp)
     d6a:	7b02                	ld	s6,32(sp)
     d6c:	6be2                	ld	s7,24(sp)
     d6e:	6125                	addi	sp,sp,96
     d70:	8082                	ret

0000000000000d72 <stat>:

int
stat(const char *n, struct stat *st)
{
     d72:	1101                	addi	sp,sp,-32
     d74:	ec06                	sd	ra,24(sp)
     d76:	e822                	sd	s0,16(sp)
     d78:	e426                	sd	s1,8(sp)
     d7a:	e04a                	sd	s2,0(sp)
     d7c:	1000                	addi	s0,sp,32
     d7e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d80:	4581                	li	a1,0
     d82:	00000097          	auipc	ra,0x0
     d86:	172080e7          	jalr	370(ra) # ef4 <open>
  if(fd < 0)
     d8a:	02054563          	bltz	a0,db4 <stat+0x42>
     d8e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d90:	85ca                	mv	a1,s2
     d92:	00000097          	auipc	ra,0x0
     d96:	17a080e7          	jalr	378(ra) # f0c <fstat>
     d9a:	892a                	mv	s2,a0
  close(fd);
     d9c:	8526                	mv	a0,s1
     d9e:	00000097          	auipc	ra,0x0
     da2:	13e080e7          	jalr	318(ra) # edc <close>
  return r;
}
     da6:	854a                	mv	a0,s2
     da8:	60e2                	ld	ra,24(sp)
     daa:	6442                	ld	s0,16(sp)
     dac:	64a2                	ld	s1,8(sp)
     dae:	6902                	ld	s2,0(sp)
     db0:	6105                	addi	sp,sp,32
     db2:	8082                	ret
    return -1;
     db4:	597d                	li	s2,-1
     db6:	bfc5                	j	da6 <stat+0x34>

0000000000000db8 <atoi>:

int
atoi(const char *s)
{
     db8:	1141                	addi	sp,sp,-16
     dba:	e422                	sd	s0,8(sp)
     dbc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     dbe:	00054603          	lbu	a2,0(a0)
     dc2:	fd06079b          	addiw	a5,a2,-48
     dc6:	0ff7f793          	andi	a5,a5,255
     dca:	4725                	li	a4,9
     dcc:	02f76963          	bltu	a4,a5,dfe <atoi+0x46>
     dd0:	86aa                	mv	a3,a0
  n = 0;
     dd2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     dd4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     dd6:	0685                	addi	a3,a3,1
     dd8:	0025179b          	slliw	a5,a0,0x2
     ddc:	9fa9                	addw	a5,a5,a0
     dde:	0017979b          	slliw	a5,a5,0x1
     de2:	9fb1                	addw	a5,a5,a2
     de4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     de8:	0006c603          	lbu	a2,0(a3)
     dec:	fd06071b          	addiw	a4,a2,-48
     df0:	0ff77713          	andi	a4,a4,255
     df4:	fee5f1e3          	bgeu	a1,a4,dd6 <atoi+0x1e>
  return n;
}
     df8:	6422                	ld	s0,8(sp)
     dfa:	0141                	addi	sp,sp,16
     dfc:	8082                	ret
  n = 0;
     dfe:	4501                	li	a0,0
     e00:	bfe5                	j	df8 <atoi+0x40>

0000000000000e02 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e02:	1141                	addi	sp,sp,-16
     e04:	e422                	sd	s0,8(sp)
     e06:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e08:	02b57463          	bgeu	a0,a1,e30 <memmove+0x2e>
    while(n-- > 0)
     e0c:	00c05f63          	blez	a2,e2a <memmove+0x28>
     e10:	1602                	slli	a2,a2,0x20
     e12:	9201                	srli	a2,a2,0x20
     e14:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e18:	872a                	mv	a4,a0
      *dst++ = *src++;
     e1a:	0585                	addi	a1,a1,1
     e1c:	0705                	addi	a4,a4,1
     e1e:	fff5c683          	lbu	a3,-1(a1)
     e22:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e26:	fee79ae3          	bne	a5,a4,e1a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e2a:	6422                	ld	s0,8(sp)
     e2c:	0141                	addi	sp,sp,16
     e2e:	8082                	ret
    dst += n;
     e30:	00c50733          	add	a4,a0,a2
    src += n;
     e34:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e36:	fec05ae3          	blez	a2,e2a <memmove+0x28>
     e3a:	fff6079b          	addiw	a5,a2,-1
     e3e:	1782                	slli	a5,a5,0x20
     e40:	9381                	srli	a5,a5,0x20
     e42:	fff7c793          	not	a5,a5
     e46:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e48:	15fd                	addi	a1,a1,-1
     e4a:	177d                	addi	a4,a4,-1
     e4c:	0005c683          	lbu	a3,0(a1)
     e50:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e54:	fee79ae3          	bne	a5,a4,e48 <memmove+0x46>
     e58:	bfc9                	j	e2a <memmove+0x28>

0000000000000e5a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e5a:	1141                	addi	sp,sp,-16
     e5c:	e422                	sd	s0,8(sp)
     e5e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e60:	ca05                	beqz	a2,e90 <memcmp+0x36>
     e62:	fff6069b          	addiw	a3,a2,-1
     e66:	1682                	slli	a3,a3,0x20
     e68:	9281                	srli	a3,a3,0x20
     e6a:	0685                	addi	a3,a3,1
     e6c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e6e:	00054783          	lbu	a5,0(a0)
     e72:	0005c703          	lbu	a4,0(a1)
     e76:	00e79863          	bne	a5,a4,e86 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e7a:	0505                	addi	a0,a0,1
    p2++;
     e7c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e7e:	fed518e3          	bne	a0,a3,e6e <memcmp+0x14>
  }
  return 0;
     e82:	4501                	li	a0,0
     e84:	a019                	j	e8a <memcmp+0x30>
      return *p1 - *p2;
     e86:	40e7853b          	subw	a0,a5,a4
}
     e8a:	6422                	ld	s0,8(sp)
     e8c:	0141                	addi	sp,sp,16
     e8e:	8082                	ret
  return 0;
     e90:	4501                	li	a0,0
     e92:	bfe5                	j	e8a <memcmp+0x30>

0000000000000e94 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e94:	1141                	addi	sp,sp,-16
     e96:	e406                	sd	ra,8(sp)
     e98:	e022                	sd	s0,0(sp)
     e9a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e9c:	00000097          	auipc	ra,0x0
     ea0:	f66080e7          	jalr	-154(ra) # e02 <memmove>
}
     ea4:	60a2                	ld	ra,8(sp)
     ea6:	6402                	ld	s0,0(sp)
     ea8:	0141                	addi	sp,sp,16
     eaa:	8082                	ret

0000000000000eac <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     eac:	4885                	li	a7,1
 ecall
     eae:	00000073          	ecall
 ret
     eb2:	8082                	ret

0000000000000eb4 <exit>:
.global exit
exit:
 li a7, SYS_exit
     eb4:	4889                	li	a7,2
 ecall
     eb6:	00000073          	ecall
 ret
     eba:	8082                	ret

0000000000000ebc <wait>:
.global wait
wait:
 li a7, SYS_wait
     ebc:	488d                	li	a7,3
 ecall
     ebe:	00000073          	ecall
 ret
     ec2:	8082                	ret

0000000000000ec4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     ec4:	4891                	li	a7,4
 ecall
     ec6:	00000073          	ecall
 ret
     eca:	8082                	ret

0000000000000ecc <read>:
.global read
read:
 li a7, SYS_read
     ecc:	4895                	li	a7,5
 ecall
     ece:	00000073          	ecall
 ret
     ed2:	8082                	ret

0000000000000ed4 <write>:
.global write
write:
 li a7, SYS_write
     ed4:	48c1                	li	a7,16
 ecall
     ed6:	00000073          	ecall
 ret
     eda:	8082                	ret

0000000000000edc <close>:
.global close
close:
 li a7, SYS_close
     edc:	48d5                	li	a7,21
 ecall
     ede:	00000073          	ecall
 ret
     ee2:	8082                	ret

0000000000000ee4 <kill>:
.global kill
kill:
 li a7, SYS_kill
     ee4:	4899                	li	a7,6
 ecall
     ee6:	00000073          	ecall
 ret
     eea:	8082                	ret

0000000000000eec <exec>:
.global exec
exec:
 li a7, SYS_exec
     eec:	489d                	li	a7,7
 ecall
     eee:	00000073          	ecall
 ret
     ef2:	8082                	ret

0000000000000ef4 <open>:
.global open
open:
 li a7, SYS_open
     ef4:	48bd                	li	a7,15
 ecall
     ef6:	00000073          	ecall
 ret
     efa:	8082                	ret

0000000000000efc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     efc:	48c5                	li	a7,17
 ecall
     efe:	00000073          	ecall
 ret
     f02:	8082                	ret

0000000000000f04 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f04:	48c9                	li	a7,18
 ecall
     f06:	00000073          	ecall
 ret
     f0a:	8082                	ret

0000000000000f0c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f0c:	48a1                	li	a7,8
 ecall
     f0e:	00000073          	ecall
 ret
     f12:	8082                	ret

0000000000000f14 <link>:
.global link
link:
 li a7, SYS_link
     f14:	48cd                	li	a7,19
 ecall
     f16:	00000073          	ecall
 ret
     f1a:	8082                	ret

0000000000000f1c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f1c:	48d1                	li	a7,20
 ecall
     f1e:	00000073          	ecall
 ret
     f22:	8082                	ret

0000000000000f24 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f24:	48a5                	li	a7,9
 ecall
     f26:	00000073          	ecall
 ret
     f2a:	8082                	ret

0000000000000f2c <dup>:
.global dup
dup:
 li a7, SYS_dup
     f2c:	48a9                	li	a7,10
 ecall
     f2e:	00000073          	ecall
 ret
     f32:	8082                	ret

0000000000000f34 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f34:	48ad                	li	a7,11
 ecall
     f36:	00000073          	ecall
 ret
     f3a:	8082                	ret

0000000000000f3c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f3c:	48b1                	li	a7,12
 ecall
     f3e:	00000073          	ecall
 ret
     f42:	8082                	ret

0000000000000f44 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f44:	48b5                	li	a7,13
 ecall
     f46:	00000073          	ecall
 ret
     f4a:	8082                	ret

0000000000000f4c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f4c:	48b9                	li	a7,14
 ecall
     f4e:	00000073          	ecall
 ret
     f52:	8082                	ret

0000000000000f54 <trace>:
.global trace
trace:
 li a7, SYS_trace
     f54:	48d9                	li	a7,22
 ecall
     f56:	00000073          	ecall
 ret
     f5a:	8082                	ret

0000000000000f5c <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
     f5c:	48dd                	li	a7,23
 ecall
     f5e:	00000073          	ecall
 ret
     f62:	8082                	ret

0000000000000f64 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
     f64:	48e1                	li	a7,24
 ecall
     f66:	00000073          	ecall
 ret
     f6a:	8082                	ret

0000000000000f6c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f6c:	1101                	addi	sp,sp,-32
     f6e:	ec06                	sd	ra,24(sp)
     f70:	e822                	sd	s0,16(sp)
     f72:	1000                	addi	s0,sp,32
     f74:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f78:	4605                	li	a2,1
     f7a:	fef40593          	addi	a1,s0,-17
     f7e:	00000097          	auipc	ra,0x0
     f82:	f56080e7          	jalr	-170(ra) # ed4 <write>
}
     f86:	60e2                	ld	ra,24(sp)
     f88:	6442                	ld	s0,16(sp)
     f8a:	6105                	addi	sp,sp,32
     f8c:	8082                	ret

0000000000000f8e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f8e:	7139                	addi	sp,sp,-64
     f90:	fc06                	sd	ra,56(sp)
     f92:	f822                	sd	s0,48(sp)
     f94:	f426                	sd	s1,40(sp)
     f96:	f04a                	sd	s2,32(sp)
     f98:	ec4e                	sd	s3,24(sp)
     f9a:	0080                	addi	s0,sp,64
     f9c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f9e:	c299                	beqz	a3,fa4 <printint+0x16>
     fa0:	0805c863          	bltz	a1,1030 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     fa4:	2581                	sext.w	a1,a1
  neg = 0;
     fa6:	4881                	li	a7,0
     fa8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fac:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fae:	2601                	sext.w	a2,a2
     fb0:	00000517          	auipc	a0,0x0
     fb4:	5a050513          	addi	a0,a0,1440 # 1550 <digits>
     fb8:	883a                	mv	a6,a4
     fba:	2705                	addiw	a4,a4,1
     fbc:	02c5f7bb          	remuw	a5,a1,a2
     fc0:	1782                	slli	a5,a5,0x20
     fc2:	9381                	srli	a5,a5,0x20
     fc4:	97aa                	add	a5,a5,a0
     fc6:	0007c783          	lbu	a5,0(a5)
     fca:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fce:	0005879b          	sext.w	a5,a1
     fd2:	02c5d5bb          	divuw	a1,a1,a2
     fd6:	0685                	addi	a3,a3,1
     fd8:	fec7f0e3          	bgeu	a5,a2,fb8 <printint+0x2a>
  if(neg)
     fdc:	00088b63          	beqz	a7,ff2 <printint+0x64>
    buf[i++] = '-';
     fe0:	fd040793          	addi	a5,s0,-48
     fe4:	973e                	add	a4,a4,a5
     fe6:	02d00793          	li	a5,45
     fea:	fef70823          	sb	a5,-16(a4)
     fee:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     ff2:	02e05863          	blez	a4,1022 <printint+0x94>
     ff6:	fc040793          	addi	a5,s0,-64
     ffa:	00e78933          	add	s2,a5,a4
     ffe:	fff78993          	addi	s3,a5,-1
    1002:	99ba                	add	s3,s3,a4
    1004:	377d                	addiw	a4,a4,-1
    1006:	1702                	slli	a4,a4,0x20
    1008:	9301                	srli	a4,a4,0x20
    100a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    100e:	fff94583          	lbu	a1,-1(s2)
    1012:	8526                	mv	a0,s1
    1014:	00000097          	auipc	ra,0x0
    1018:	f58080e7          	jalr	-168(ra) # f6c <putc>
  while(--i >= 0)
    101c:	197d                	addi	s2,s2,-1
    101e:	ff3918e3          	bne	s2,s3,100e <printint+0x80>
}
    1022:	70e2                	ld	ra,56(sp)
    1024:	7442                	ld	s0,48(sp)
    1026:	74a2                	ld	s1,40(sp)
    1028:	7902                	ld	s2,32(sp)
    102a:	69e2                	ld	s3,24(sp)
    102c:	6121                	addi	sp,sp,64
    102e:	8082                	ret
    x = -xx;
    1030:	40b005bb          	negw	a1,a1
    neg = 1;
    1034:	4885                	li	a7,1
    x = -xx;
    1036:	bf8d                	j	fa8 <printint+0x1a>

0000000000001038 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    1038:	7119                	addi	sp,sp,-128
    103a:	fc86                	sd	ra,120(sp)
    103c:	f8a2                	sd	s0,112(sp)
    103e:	f4a6                	sd	s1,104(sp)
    1040:	f0ca                	sd	s2,96(sp)
    1042:	ecce                	sd	s3,88(sp)
    1044:	e8d2                	sd	s4,80(sp)
    1046:	e4d6                	sd	s5,72(sp)
    1048:	e0da                	sd	s6,64(sp)
    104a:	fc5e                	sd	s7,56(sp)
    104c:	f862                	sd	s8,48(sp)
    104e:	f466                	sd	s9,40(sp)
    1050:	f06a                	sd	s10,32(sp)
    1052:	ec6e                	sd	s11,24(sp)
    1054:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1056:	0005c903          	lbu	s2,0(a1)
    105a:	18090f63          	beqz	s2,11f8 <vprintf+0x1c0>
    105e:	8aaa                	mv	s5,a0
    1060:	8b32                	mv	s6,a2
    1062:	00158493          	addi	s1,a1,1
  state = 0;
    1066:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1068:	02500a13          	li	s4,37
      if(c == 'd'){
    106c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1070:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1074:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    1078:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    107c:	00000b97          	auipc	s7,0x0
    1080:	4d4b8b93          	addi	s7,s7,1236 # 1550 <digits>
    1084:	a839                	j	10a2 <vprintf+0x6a>
        putc(fd, c);
    1086:	85ca                	mv	a1,s2
    1088:	8556                	mv	a0,s5
    108a:	00000097          	auipc	ra,0x0
    108e:	ee2080e7          	jalr	-286(ra) # f6c <putc>
    1092:	a019                	j	1098 <vprintf+0x60>
    } else if(state == '%'){
    1094:	01498f63          	beq	s3,s4,10b2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1098:	0485                	addi	s1,s1,1
    109a:	fff4c903          	lbu	s2,-1(s1)
    109e:	14090d63          	beqz	s2,11f8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    10a2:	0009079b          	sext.w	a5,s2
    if(state == 0){
    10a6:	fe0997e3          	bnez	s3,1094 <vprintf+0x5c>
      if(c == '%'){
    10aa:	fd479ee3          	bne	a5,s4,1086 <vprintf+0x4e>
        state = '%';
    10ae:	89be                	mv	s3,a5
    10b0:	b7e5                	j	1098 <vprintf+0x60>
      if(c == 'd'){
    10b2:	05878063          	beq	a5,s8,10f2 <vprintf+0xba>
      } else if(c == 'l') {
    10b6:	05978c63          	beq	a5,s9,110e <vprintf+0xd6>
      } else if(c == 'x') {
    10ba:	07a78863          	beq	a5,s10,112a <vprintf+0xf2>
      } else if(c == 'p') {
    10be:	09b78463          	beq	a5,s11,1146 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10c2:	07300713          	li	a4,115
    10c6:	0ce78663          	beq	a5,a4,1192 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10ca:	06300713          	li	a4,99
    10ce:	0ee78e63          	beq	a5,a4,11ca <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10d2:	11478863          	beq	a5,s4,11e2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10d6:	85d2                	mv	a1,s4
    10d8:	8556                	mv	a0,s5
    10da:	00000097          	auipc	ra,0x0
    10de:	e92080e7          	jalr	-366(ra) # f6c <putc>
        putc(fd, c);
    10e2:	85ca                	mv	a1,s2
    10e4:	8556                	mv	a0,s5
    10e6:	00000097          	auipc	ra,0x0
    10ea:	e86080e7          	jalr	-378(ra) # f6c <putc>
      }
      state = 0;
    10ee:	4981                	li	s3,0
    10f0:	b765                	j	1098 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10f2:	008b0913          	addi	s2,s6,8
    10f6:	4685                	li	a3,1
    10f8:	4629                	li	a2,10
    10fa:	000b2583          	lw	a1,0(s6)
    10fe:	8556                	mv	a0,s5
    1100:	00000097          	auipc	ra,0x0
    1104:	e8e080e7          	jalr	-370(ra) # f8e <printint>
    1108:	8b4a                	mv	s6,s2
      state = 0;
    110a:	4981                	li	s3,0
    110c:	b771                	j	1098 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    110e:	008b0913          	addi	s2,s6,8
    1112:	4681                	li	a3,0
    1114:	4629                	li	a2,10
    1116:	000b2583          	lw	a1,0(s6)
    111a:	8556                	mv	a0,s5
    111c:	00000097          	auipc	ra,0x0
    1120:	e72080e7          	jalr	-398(ra) # f8e <printint>
    1124:	8b4a                	mv	s6,s2
      state = 0;
    1126:	4981                	li	s3,0
    1128:	bf85                	j	1098 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    112a:	008b0913          	addi	s2,s6,8
    112e:	4681                	li	a3,0
    1130:	4641                	li	a2,16
    1132:	000b2583          	lw	a1,0(s6)
    1136:	8556                	mv	a0,s5
    1138:	00000097          	auipc	ra,0x0
    113c:	e56080e7          	jalr	-426(ra) # f8e <printint>
    1140:	8b4a                	mv	s6,s2
      state = 0;
    1142:	4981                	li	s3,0
    1144:	bf91                	j	1098 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    1146:	008b0793          	addi	a5,s6,8
    114a:	f8f43423          	sd	a5,-120(s0)
    114e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1152:	03000593          	li	a1,48
    1156:	8556                	mv	a0,s5
    1158:	00000097          	auipc	ra,0x0
    115c:	e14080e7          	jalr	-492(ra) # f6c <putc>
  putc(fd, 'x');
    1160:	85ea                	mv	a1,s10
    1162:	8556                	mv	a0,s5
    1164:	00000097          	auipc	ra,0x0
    1168:	e08080e7          	jalr	-504(ra) # f6c <putc>
    116c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    116e:	03c9d793          	srli	a5,s3,0x3c
    1172:	97de                	add	a5,a5,s7
    1174:	0007c583          	lbu	a1,0(a5)
    1178:	8556                	mv	a0,s5
    117a:	00000097          	auipc	ra,0x0
    117e:	df2080e7          	jalr	-526(ra) # f6c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1182:	0992                	slli	s3,s3,0x4
    1184:	397d                	addiw	s2,s2,-1
    1186:	fe0914e3          	bnez	s2,116e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    118a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    118e:	4981                	li	s3,0
    1190:	b721                	j	1098 <vprintf+0x60>
        s = va_arg(ap, char*);
    1192:	008b0993          	addi	s3,s6,8
    1196:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    119a:	02090163          	beqz	s2,11bc <vprintf+0x184>
        while(*s != 0){
    119e:	00094583          	lbu	a1,0(s2)
    11a2:	c9a1                	beqz	a1,11f2 <vprintf+0x1ba>
          putc(fd, *s);
    11a4:	8556                	mv	a0,s5
    11a6:	00000097          	auipc	ra,0x0
    11aa:	dc6080e7          	jalr	-570(ra) # f6c <putc>
          s++;
    11ae:	0905                	addi	s2,s2,1
        while(*s != 0){
    11b0:	00094583          	lbu	a1,0(s2)
    11b4:	f9e5                	bnez	a1,11a4 <vprintf+0x16c>
        s = va_arg(ap, char*);
    11b6:	8b4e                	mv	s6,s3
      state = 0;
    11b8:	4981                	li	s3,0
    11ba:	bdf9                	j	1098 <vprintf+0x60>
          s = "(null)";
    11bc:	00000917          	auipc	s2,0x0
    11c0:	38c90913          	addi	s2,s2,908 # 1548 <malloc+0x246>
        while(*s != 0){
    11c4:	02800593          	li	a1,40
    11c8:	bff1                	j	11a4 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11ca:	008b0913          	addi	s2,s6,8
    11ce:	000b4583          	lbu	a1,0(s6)
    11d2:	8556                	mv	a0,s5
    11d4:	00000097          	auipc	ra,0x0
    11d8:	d98080e7          	jalr	-616(ra) # f6c <putc>
    11dc:	8b4a                	mv	s6,s2
      state = 0;
    11de:	4981                	li	s3,0
    11e0:	bd65                	j	1098 <vprintf+0x60>
        putc(fd, c);
    11e2:	85d2                	mv	a1,s4
    11e4:	8556                	mv	a0,s5
    11e6:	00000097          	auipc	ra,0x0
    11ea:	d86080e7          	jalr	-634(ra) # f6c <putc>
      state = 0;
    11ee:	4981                	li	s3,0
    11f0:	b565                	j	1098 <vprintf+0x60>
        s = va_arg(ap, char*);
    11f2:	8b4e                	mv	s6,s3
      state = 0;
    11f4:	4981                	li	s3,0
    11f6:	b54d                	j	1098 <vprintf+0x60>
    }
  }
}
    11f8:	70e6                	ld	ra,120(sp)
    11fa:	7446                	ld	s0,112(sp)
    11fc:	74a6                	ld	s1,104(sp)
    11fe:	7906                	ld	s2,96(sp)
    1200:	69e6                	ld	s3,88(sp)
    1202:	6a46                	ld	s4,80(sp)
    1204:	6aa6                	ld	s5,72(sp)
    1206:	6b06                	ld	s6,64(sp)
    1208:	7be2                	ld	s7,56(sp)
    120a:	7c42                	ld	s8,48(sp)
    120c:	7ca2                	ld	s9,40(sp)
    120e:	7d02                	ld	s10,32(sp)
    1210:	6de2                	ld	s11,24(sp)
    1212:	6109                	addi	sp,sp,128
    1214:	8082                	ret

0000000000001216 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1216:	715d                	addi	sp,sp,-80
    1218:	ec06                	sd	ra,24(sp)
    121a:	e822                	sd	s0,16(sp)
    121c:	1000                	addi	s0,sp,32
    121e:	e010                	sd	a2,0(s0)
    1220:	e414                	sd	a3,8(s0)
    1222:	e818                	sd	a4,16(s0)
    1224:	ec1c                	sd	a5,24(s0)
    1226:	03043023          	sd	a6,32(s0)
    122a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    122e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1232:	8622                	mv	a2,s0
    1234:	00000097          	auipc	ra,0x0
    1238:	e04080e7          	jalr	-508(ra) # 1038 <vprintf>
}
    123c:	60e2                	ld	ra,24(sp)
    123e:	6442                	ld	s0,16(sp)
    1240:	6161                	addi	sp,sp,80
    1242:	8082                	ret

0000000000001244 <printf>:

void
printf(const char *fmt, ...)
{
    1244:	711d                	addi	sp,sp,-96
    1246:	ec06                	sd	ra,24(sp)
    1248:	e822                	sd	s0,16(sp)
    124a:	1000                	addi	s0,sp,32
    124c:	e40c                	sd	a1,8(s0)
    124e:	e810                	sd	a2,16(s0)
    1250:	ec14                	sd	a3,24(s0)
    1252:	f018                	sd	a4,32(s0)
    1254:	f41c                	sd	a5,40(s0)
    1256:	03043823          	sd	a6,48(s0)
    125a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    125e:	00840613          	addi	a2,s0,8
    1262:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1266:	85aa                	mv	a1,a0
    1268:	4505                	li	a0,1
    126a:	00000097          	auipc	ra,0x0
    126e:	dce080e7          	jalr	-562(ra) # 1038 <vprintf>
}
    1272:	60e2                	ld	ra,24(sp)
    1274:	6442                	ld	s0,16(sp)
    1276:	6125                	addi	sp,sp,96
    1278:	8082                	ret

000000000000127a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    127a:	1141                	addi	sp,sp,-16
    127c:	e422                	sd	s0,8(sp)
    127e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1280:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1284:	00000797          	auipc	a5,0x0
    1288:	2fc7b783          	ld	a5,764(a5) # 1580 <freep>
    128c:	a805                	j	12bc <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    128e:	4618                	lw	a4,8(a2)
    1290:	9db9                	addw	a1,a1,a4
    1292:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1296:	6398                	ld	a4,0(a5)
    1298:	6318                	ld	a4,0(a4)
    129a:	fee53823          	sd	a4,-16(a0)
    129e:	a091                	j	12e2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12a0:	ff852703          	lw	a4,-8(a0)
    12a4:	9e39                	addw	a2,a2,a4
    12a6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    12a8:	ff053703          	ld	a4,-16(a0)
    12ac:	e398                	sd	a4,0(a5)
    12ae:	a099                	j	12f4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12b0:	6398                	ld	a4,0(a5)
    12b2:	00e7e463          	bltu	a5,a4,12ba <free+0x40>
    12b6:	00e6ea63          	bltu	a3,a4,12ca <free+0x50>
{
    12ba:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12bc:	fed7fae3          	bgeu	a5,a3,12b0 <free+0x36>
    12c0:	6398                	ld	a4,0(a5)
    12c2:	00e6e463          	bltu	a3,a4,12ca <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12c6:	fee7eae3          	bltu	a5,a4,12ba <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12ca:	ff852583          	lw	a1,-8(a0)
    12ce:	6390                	ld	a2,0(a5)
    12d0:	02059813          	slli	a6,a1,0x20
    12d4:	01c85713          	srli	a4,a6,0x1c
    12d8:	9736                	add	a4,a4,a3
    12da:	fae60ae3          	beq	a2,a4,128e <free+0x14>
    bp->s.ptr = p->s.ptr;
    12de:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12e2:	4790                	lw	a2,8(a5)
    12e4:	02061593          	slli	a1,a2,0x20
    12e8:	01c5d713          	srli	a4,a1,0x1c
    12ec:	973e                	add	a4,a4,a5
    12ee:	fae689e3          	beq	a3,a4,12a0 <free+0x26>
  } else
    p->s.ptr = bp;
    12f2:	e394                	sd	a3,0(a5)
  freep = p;
    12f4:	00000717          	auipc	a4,0x0
    12f8:	28f73623          	sd	a5,652(a4) # 1580 <freep>
}
    12fc:	6422                	ld	s0,8(sp)
    12fe:	0141                	addi	sp,sp,16
    1300:	8082                	ret

0000000000001302 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1302:	7139                	addi	sp,sp,-64
    1304:	fc06                	sd	ra,56(sp)
    1306:	f822                	sd	s0,48(sp)
    1308:	f426                	sd	s1,40(sp)
    130a:	f04a                	sd	s2,32(sp)
    130c:	ec4e                	sd	s3,24(sp)
    130e:	e852                	sd	s4,16(sp)
    1310:	e456                	sd	s5,8(sp)
    1312:	e05a                	sd	s6,0(sp)
    1314:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1316:	02051493          	slli	s1,a0,0x20
    131a:	9081                	srli	s1,s1,0x20
    131c:	04bd                	addi	s1,s1,15
    131e:	8091                	srli	s1,s1,0x4
    1320:	0014899b          	addiw	s3,s1,1
    1324:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1326:	00000517          	auipc	a0,0x0
    132a:	25a53503          	ld	a0,602(a0) # 1580 <freep>
    132e:	c515                	beqz	a0,135a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1330:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1332:	4798                	lw	a4,8(a5)
    1334:	02977f63          	bgeu	a4,s1,1372 <malloc+0x70>
    1338:	8a4e                	mv	s4,s3
    133a:	0009871b          	sext.w	a4,s3
    133e:	6685                	lui	a3,0x1
    1340:	00d77363          	bgeu	a4,a3,1346 <malloc+0x44>
    1344:	6a05                	lui	s4,0x1
    1346:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    134a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    134e:	00000917          	auipc	s2,0x0
    1352:	23290913          	addi	s2,s2,562 # 1580 <freep>
  if(p == (char*)-1)
    1356:	5afd                	li	s5,-1
    1358:	a895                	j	13cc <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    135a:	00000797          	auipc	a5,0x0
    135e:	3d678793          	addi	a5,a5,982 # 1730 <base>
    1362:	00000717          	auipc	a4,0x0
    1366:	20f73f23          	sd	a5,542(a4) # 1580 <freep>
    136a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    136c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1370:	b7e1                	j	1338 <malloc+0x36>
      if(p->s.size == nunits)
    1372:	02e48c63          	beq	s1,a4,13aa <malloc+0xa8>
        p->s.size -= nunits;
    1376:	4137073b          	subw	a4,a4,s3
    137a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    137c:	02071693          	slli	a3,a4,0x20
    1380:	01c6d713          	srli	a4,a3,0x1c
    1384:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1386:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    138a:	00000717          	auipc	a4,0x0
    138e:	1ea73b23          	sd	a0,502(a4) # 1580 <freep>
      return (void*)(p + 1);
    1392:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1396:	70e2                	ld	ra,56(sp)
    1398:	7442                	ld	s0,48(sp)
    139a:	74a2                	ld	s1,40(sp)
    139c:	7902                	ld	s2,32(sp)
    139e:	69e2                	ld	s3,24(sp)
    13a0:	6a42                	ld	s4,16(sp)
    13a2:	6aa2                	ld	s5,8(sp)
    13a4:	6b02                	ld	s6,0(sp)
    13a6:	6121                	addi	sp,sp,64
    13a8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13aa:	6398                	ld	a4,0(a5)
    13ac:	e118                	sd	a4,0(a0)
    13ae:	bff1                	j	138a <malloc+0x88>
  hp->s.size = nu;
    13b0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13b4:	0541                	addi	a0,a0,16
    13b6:	00000097          	auipc	ra,0x0
    13ba:	ec4080e7          	jalr	-316(ra) # 127a <free>
  return freep;
    13be:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13c2:	d971                	beqz	a0,1396 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13c6:	4798                	lw	a4,8(a5)
    13c8:	fa9775e3          	bgeu	a4,s1,1372 <malloc+0x70>
    if(p == freep)
    13cc:	00093703          	ld	a4,0(s2)
    13d0:	853e                	mv	a0,a5
    13d2:	fef719e3          	bne	a4,a5,13c4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    13d6:	8552                	mv	a0,s4
    13d8:	00000097          	auipc	ra,0x0
    13dc:	b64080e7          	jalr	-1180(ra) # f3c <sbrk>
  if(p == (char*)-1)
    13e0:	fd5518e3          	bne	a0,s5,13b0 <malloc+0xae>
        return 0;
    13e4:	4501                	li	a0,0
    13e6:	bf45                	j	1396 <malloc+0x94>
