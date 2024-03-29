#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function Bia049()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("LEND,LABORTPRINT,TAMANHO,LIMITE,TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,ARETURN,ALINHA,NOMEPROG,NLASTKEY")
SetPrvt("LI,CPAG,CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1")
SetPrvt("CSAVCOR1,CBTXT,CBCONT,CABEC1,CABEC2,CSTRING")
SetPrvt("M_PAG,AORD,WNREL,_ACAMPOS,TMP,CCHAVE")
SetPrvt("CTIPO,CTRANSP,CPRODUTO,DCHEGADA,CCTRC,CNUMSEQ")
SetPrvt("DDTDIGIT,NPRCTF,WDOC,ADOC,AFOR,DVENCTO,WSERIE")
SetPrvt("NTOTNF,NUMIDADE,NTICKET,CFORNEC,NPRCUMP,NPRCTMP")
SetPrvt("APRCTF,NPRCUFRET,NPESONF,CDOC,CPREFIXO,CPEDIDO")
SetPrvt("CITEMPC,NUMID_F,NTOTUMID_T,NTOTGUMID,NTOTDIF_F,NTOTDIF_T")
SetPrvt("NTOTGDIF,NTOTMP_F,NTOTMP_T,NTOTGMP,NTFF,NTFT")
SetPrvt("NTGF,NTOTNF_F,NTOTNF_T,NTOTGNF,NTOTFTICKET,NTOTTTICKET")
SetPrvt("NTOTGTICKET,NTOTPTMP_F,NTOTPTMP_T,NTOTGPTMP,NTOTPTF_F,NTOTPTF_T")
SetPrvt("NTOTGTF,NPRZMF,NPRZMT,NPRZMG,ATRANSP,AFORNEC")
SetPrvt("LOK,ADIF,AMP,AFRT,XDOC,AUMIDAD")
SetPrvt("APRZ,")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � BIA049	  � Autor � CESAR MAGNAGO         � Data � 10/09/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � RELATORIO DE CONTROLE DE CHEGADA DE MATERIA-PRIMA	        낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � Interpretador xBase											낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	 #DEFINE PSAY SAY
#ENDIF

lEnd		:= lAbortPrint := .F.
tamanho	:= "G"
limite	:= 220
titulo	:= "Planilha de Controle Materia-Prima"
cDesc1	:= "Emite o controle de chegada de materia-prima.                           "
cDesc2	:= "                                                                        "
cDesc3	:= "                                                                        "
aReturn	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
aLinha	:= { }
nomeprog := "BIA049"
nLastKey := 0
li 		:= 1
Cpag		:= 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Vari쟶eis utilizadas para Impress꼘 do Cabe놹lho e Rodap�	 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cbtxt 	:= SPACE(10)
cbcont	:= 0
cabec1	:= "NOTA   PRF MATERIA-PRIMA       CHEGADA      VENCTO     CTRC     UMID      PESO DA         TICKET    DIFERENCA   /PRECO UNITARIO  \  /    PRECO TOTAL     \  /NF-COMPLEMENTAR (R$)\     PRAZO   PEDIDO/ITEM"
cabec2	:= "FISCAL                                                         MEDIA     NF (TON)          (TON)        (TON)     MP       FRETE     MAT.PRIMA       FRETE   MAT.PRIMA       FRETE    (DIAS)"
// 			 XXXXXX-XXX XXXXXXXXXXXXXXXXX  XX/XX/XXXX  XX/XX/XXXX  XXXXXX	XXX,XX  XXX.XXX,XXX	XXX.XXX,XXX  XXX.XXX,XXX	XXX,XX  XXX.XXX,XX  XXX.XXX,XX  XXX.XXX,XX  XXX.XXX,XX  XXX.XXX,XX	XXX	 XXXXXX	XX
cString	:= "SD1"
li 		:= 80
m_pag 	:= 1
aOrd		:= {" Por Transportadora+Fornecedor+Produto"}
wnrel 	:= "BIA049"   // nome default do relatorio em disco


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Ajuste dos par긩etros da impress꼘 via fun뇙o SETPRINT		 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
wnrel:=SetPrint(cString,wnrel,"BIA049",@Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,"G")

If LastKey() == 27 .Or. nLastKey == 27 .Or. lEnd .Or. lAbortPrint
	Return
End

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Aceita par긩etros e faz ajustes necess쟲ios 				�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
SetDefault(aReturn,cString)

If LastKey() == 27 .Or. nLastKey == 27 .Or. lEnd .Or. lAbortPrint
	Return
End


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Definicao do arquivo de trabalho para totalizar por conta contabil	   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
_aCampos := {	 {"TRANSP" ,  "C", 06, 0},;
{"FORNEC" ,  "C", 06, 0},;
{"PRODUTO",  "C", 15, 0},;
{"CHEGADA",  "D", 08, 0},;
{"DOC"    ,  "C", 06, 0},;
{"PREFIXO",  "C", 03, 0},;
{"CTRC"   ,  "C", 06, 0},;
{"UMIDADE",  "N", 06, 2},;
{"VENCTO" ,  "D", 08, 0},;
{"PRCTMP" ,  "N", 14, 2},;
{"PRCTF"  ,  "N", 14, 2},;
{"PESONF" ,  "N", 09, 3},;
{"TICKET" ,  "N", 09, 3},;
{"PRCUMP"  , "N", 08, 2},;
{"PEDIDO" ,  "C", 06, 0},;
{"ITEMPC"  , "C", 02, 0},;
{"PRCUFRET", "N", 08, 2}}

cArqTrab := CriaTrab(_aCampos, .T.)
DbUseArea(.T.,,cArqTrab,"TMP")
DbCreateInd(cArqTrab,"TRANSP+FORNEC+PRODUTO",{||TRANSP+FORNEC+PRODUTO})

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Solicita os parametros para a emissao do relatorio					   �
//쳐컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
//� mv_par01 � De  Transportadora										   �
//� mv_par02 � Da  Data Chegada											   �
//� mv_par03 � Ate Data Chegada											   �
//읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte("BIA049",.F.)

RptStatus({|| RptDetail() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	 RptStatus({|| Execute(RptDetail) })

fFinaliza()

Return( Nil )


// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION RptDetail
Static FUNCTION RptDetail()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta a linha da regua 												   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SetRegua( SD1 -> (RecCount()) )

DbSelectArea("SD1")
DbSetOrder(6)
DbGotop()
DbSeek(xFilial("SD1")+DTOS(MV_PAR02),.T.)
While !EOF() .And. (SD1->D1_DTDIGIT <= MV_PAR03)
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Movimenta o cursor da regua									   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	IncRegua()
	
	If SD1->D1_FORNECE <> MV_PAR01
		DbSelectArea("SD1")
		DbSkip()
		Loop
	EndIf
	
	If SD1->D1_TIPO <> "C"
		DbSelectArea("SD1")
		DbSkip()
		Loop
	EndIf
	
	If SD1->D1_NFORI $ "DIVERS_COMPL _AMOSTR"
		DbSelectArea("SD1")
		DbSkip()
		Loop
	EndIf
	
	cChave := xFilial("SB1")+D1_COD
	DbSelectArea("SB1")
	DbSeek(cChave)
	If !Found()
		DbSelectArea("SD1")
		DbSkip()
		Loop
	Else
		cTipo := SB1->B1_TIPO
	EndIF
	
	IF SUBST(SB1->B1_COD,1,3) <> "101"
		DbSelectArea("SD1")
		DbSkip()
		Loop
	EndIf
	
	IF cTipo <> "MP"
		DbSelectArea("SD1")
		DbSkip()
		Loop
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Monta Registro do Conhecimento de Frete da Mat.Prima 		   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cTransp	 := SD1->D1_FORNECE
	cProduto := SD1->D1_COD
	dChegada := SD1->D1_DTDIGIT
	cCtrc	 := SD1->D1_DOC
	cNumSeq	 := SD1->D1_NUMSEQ
	dDtDigit := SD1->D1_DTDIGIT
	nPrcTF 	 := SD1->D1_TOTAL - SD1->D1_VALDESC
	wDoc	 := SD1->D1_NFORI
	wSerie   := SD1->D1_SERIORI
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Procura Registro da NF-Mat.Prima do Conhecimento de Frete	   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SD1")
	DbSetOrder(1)
    DbSeek(xFilial("SD1")+wdoc+wserie, .F.)

	
    do while (SD1->D1_DOC==wDoc) .AND. !SD1->(EOF())
       if SD1->D1_DTDIGIT < mv_par02 .OR. SD1->D1_DTDIGIT > mv_par03
          dbSkip()
          Loop
 	   endif 
	   if SD1->D1_COD <> cProduto
	      DbSkip()
	      Loop
	   endif
	   wDoc := "999999"
    enddo
	
	aDoc		:= SD1->D1_DOC
	aFor		:= SD1->D1_FORNECE
	aSer		:= SD1->D1_SERIE
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Procura Registro do Titulo a Pagar para verificar vencto 	   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SE2")
	DbSetOrder(6)
	DbSeek(xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC,.T.)
	
	dVencto	 := SE2->E2_VENCREA
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Procura Valor Total da NF-Entrada							   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SF1")
	DbSetOrder(1)
	DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE,.T.)
	
	nTotNF 	 := SF1->F1_VALMERC
	DbSelectArea("SD1")
	do while (SD1->D1_DOC == aDoc) .AND. (SD1->D1_FORNECE==aFor) .AND. (SD1->D1_SERIE==aSer) .AND. !SD1->(EOF())  //.and. dVencto >= MV_PAR03
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Monta Registro da NF-Entrada da Mat.Prima 					   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		nUmidade  := SD1->D1_YUMID
		nTicket	  := SD1->D1_YTICKET
		cFornec	  := SD1->D1_FORNECE
		nPrcuMp	  := SD1->D1_VUNIT
		nPrcTMp	  := SD1->D1_TOTAL
		aPrcTF 	  := ((nPrcTF / nTotNF) * SD1->D1_TOTAL)
		nPrcUFret := (aPrcTF / SD1->D1_QUANT)
		nPesoNf	  := SD1->D1_QUANT
		cDoc	  := SD1->D1_DOC
		cPrefixo  := SD1->D1_SERIE
		cPedido	  := SD1->D1_PEDIDO
		cItemPc	  := SD1->D1_ITEMPC
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Grava Registro do Arquivo de Trabalho						   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		RecLock("TMP",.T.)
		TMP->TRANSP	:= cTransp
		TMP->FORNEC	:= cFornec
		TMP->PRODUTO	:= cProduto
		TMP->CHEGADA	:= dChegada
		TMP->CTRC		:= cCtrc
		TMP->DOC		:= cDoc
		TMP->UMIDADE	:= nUmidade
		TMP->PESONF	:= nPesoNf
		TMP->TICKET	:= nTicket
		TMP->PRCUMP	:= nPrcUMp
		TMP->PRCUFRET := nPrcUFret
		TMP->PREFIXO	:= cPrefixo
		TMP->PRCTMP	:= nPrcTMp
		TMP->PRCTF 	:= aPrcTF
		TMP->VENCTO	:= dVencto
		TMP->PEDIDO	:= cPedido
		TMP->ITEMPC	:= cItemPc
		MsUnLock()
		
		//	  GravaReg()
		DbSelectArea("SD1")
		DbSkip()
	enddo
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Volta ao Registro do Conhecimento de Frete Original				�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SD1")
	DbSetOrder(6)
	DbSeek(xFilial("SD1")+DTOS(dDtDigit)+cNumSeq,.T.)
	DbSkip()
enddo

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Gravar as informacoes de adiantamentos                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
DbSelectArea("SZK")
DbSetOrder(1)
DbSeek(xFilial("SZK")+Dtos(mv_par02),.t.)
Do while !eof() .and. ZK_FILIAL==xFilial("SZK") .and.  ZK_EMISSAO <= mv_par03
	    If ZK_TRANSP <> mv_par01
		   DbSkip()
		   Loop
    	EndIf	
        DbSelectArea("TMP")                   
        
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Grava Registro do Arquivo de Trabalho						   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		RecLock("TMP",.T.)
		TMP->TRANSP	    := SZK->ZK_TRANSP
		TMP->FORNEC 	:= SZK->ZK_FORN 
		TMP->PRODUTO	:= "AD"
		TMP->CHEGADA	:= SZK->ZK_EMISSAO
		TMP->CTRC		:= ""
		TMP->DOC		:= ""
		TMP->UMIDADE	:= 0
		TMP->PESONF	    := 0
		TMP->TICKET	    := (SZK->ZK_QUANT * -1)
		TMP->PRCUMP  	:= SZK->ZK_VRUFOR
		TMP->PRCUFRET   := SZK->ZK_VRUNIT
		TMP->PREFIXO	:= ""
		TMP->PRCTMP	    := SZK->ZK_QUANT * (SZK->ZK_VRUFOR * -1)
		TMP->PRCTF 	    := SZK->ZK_QUANT * (SZK->ZK_VRUNIT * -1)
		TMP->VENCTO  	:= SZK->ZK_VENCTO
		TMP->PEDIDO	    := ""
		TMP->ITEMPC	    := ""
		MsUnLock()         
		DbSelectArea("SZK")
		DbSkip()
EndDo
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Monta a linha da regua 																�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SetRegua( TMP -> (RecCount()) * 3 )

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicia o procedimento de impressao dos valores obtidos						�
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nUmid_F		  := 0
nTotUmid_T	  := 0
nTotGUmid	  := 0

nTotDif_F	  := 0
nTotDif_T	  := 0
nTotGDif 	  := 0

nTotMp_F 	  := 0
nTotMp_T 	  := 0
nTotGMp		  := 0

nTFF		  := 0
nTFT		  := 0
nTGF		  := 0

nTotNf_F 	  := 0
nTotNf_T 	  := 0
nTotGNf		  := 0

nTotFTicket   := 0
nTotTTicket   := 0
nTotGTicket   := 0

nTotPTMP_F	  := 0
nTotPTMP_T	  := 0
nTotGPTMP	  := 0

nTotPTF_F	  := 0
nTotPTF_T	  := 0
nTotGTF		  := 0

nPrzMF		  := 0
nPrzMT		  := 0
nPrzMG		  := 0

aTransp		  := SPACE(6)
aFornec		  := SPACE(6)
lOk			  := .T.
aDif		  := 0
aMp			  := 0
aFrt		  := 0
li 			  := 62
                                         
Private nstict := 0, nsdift := 0, nspctot := 0, nsfortot:=0                 
Private lprim := .t.

DbSelectArea("TMP")
DbGoTop()
While !EOF()
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Movimenta o cursor da regua 							  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	IncRegua()
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Verifica se teclou ALT + A (Interrompe a impressao) 	  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	If LastKey() == 27 .Or. nLastKey == 27 .Or. lEnd .Or. lAbortPrint
		@ li, 20 PSAY "*** IMPRESSAO ABORTADA PELO USUARIO ***"
		Return
	End
	
	aTransp := TMP->TRANSP
	aFornec := TMP->FORNEC
	xDoc 	:= TMP->DOC
	aUmidad := TMP->UMIDADE
	
	While !Eof() .and. TMP->TRANSP == aTransp
		
		While !Eof() .and. TMP->FORNEC == aFornec
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Checa se houve quebra de pagina									   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If  li >= 60
				cPag := cPag + 1
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
				li	 := li + 1
				DbSelectArea("SA2")
				DbSetOrder(1)
				DbSeek(xFilial("SA2")+aTransp)
				@ li,000 PSay "TRANSPORTADORA: "+SA2->A2_COD+" - "+SA2->A2_NOME
				li	 := li + 2
				DbSeek(xFilial("SA2")+aFornec)
				@ li,008 PSay "FORNECEDOR: "+SA2->A2_COD+" - "+SA2->A2_NOME
				li	 := li + 2
				DbSelectArea("TMP")
			EndIf
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Imprime linha de detalhe 										   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			
			@ li,000 PSay TMP->DOC
			@ li,007 Psay TMP->PREFIXO
			
			If Alltrim(TMP->PRODUTO) == "AD"
				If TMP->PRCUMP <> 0              
				    @ li,011 PSay "ADIANT.FORNEC."
				Else
					@ li,011 PSay "ADIANT.TRANSP."
				EndIf	
			Elseif 	lOk
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+TMP->PRODUTO)
				@ li,011 PSay Subst(SB1->B1_DESC,1,17)
				DbSelectArea("TMP")
			Else                                           
				@ li,011 PSay SPACE(17)
			EndIf
			
			@ li,030 PSay TMP->CHEGADA 								PICTURE "@D"
			@ li,042 PSay TMP->VENCTO									PICTURE "@D"
			@ li,054 PSay TMP->CTRC
			
			If xDoc == TMP->DOC
				@ li,062 PSay aUmidad												PICTURE "@E 999.99"
			Else
				@ li,062 PSay TMP->UMIDADE 							PICTURE "@E 999.99"
				xDoc 	:=  TMP->DOC
				aUmidad := TMP->UMIDADE
			EndIf
			
			@ li,070 PSay TMP->PESONF									PICTURE "@E 999,999.999"
			@ li,083 PSay TMP->TICKET									PICTURE "@E 999,999.999"
			
			aDif :=  (TMP->TICKET - TMP->PESONF )
			aMp	:=  (aDif * TMP->PRCUMP)
			aFrt :=  (aDif * TMP->PRCUFRET)
			aPrz :=  (TMP->VENCTO - TMP->CHEGADA)
			@ li,096 PSay aDif														PICTURE "@E 999,999.999"
			@ li,110 PSay TMP->PRCUMP									PICTURE "@E 999.99"
			@ li,118 PSay TMP->PRCUFRET								PICTURE "@E 9,999.99"
			@ li,130 PSay TMP->PRCTMP									PICTURE "@E 999,999.99"
			@ li,142 PSay TMP->PRCTF									PICTURE "@E 999,999.99"
			@ li,154 PSay aMp														PICTURE "@E 999,999.99"
			@ li,166 PSay aFrt														PICTURE "@E 999,999.99"
			@ li,179 PSay aPrz														PICTURE "@E 9,999"
			@ li,186 PSay TMP->PEDIDO
			@ li,194 PSay TMP->ITEMPC
			li	:= li + 1
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Acumula totais													   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			nUmid_F 	  := nUmid_F		+ (TMP->UMIDADE * TMP->TICKET)
			
			nTotNf_F	  := nTotNf_F		+ TMP->PESONF
			nTotNf_T	  := nTotNf_T		+ TMP->PESONF
			nTotGNf 	  := nTotGNf		+ TMP->PESONF
			
			nTotFTicket  := nTotFTicket	+ TMP->TICKET
			nTotTTicket  := nTotTTicket	+ TMP->TICKET
			nTotGTicket  := nTotGTicket	+ TMP->TICKET
			
			nTotDif_F	  := nTotDif_F 	+ aDif
			nTotDif_T	  := nTotDif_T 	+ aDif
			nTotGDif	  := nTotGDif		+ aDif
			
			nTotMp_F	  := nTotMp_F		+ aMp
			nTotMp_T	  := nTotMp_T		+ aMp
			nTotGMp 	  := nTotGMP		+ aMp
			
			nTotPTMP_F   := nTotPTMP_F	+ TMP->PRCTMP
			nTotPTMP_T   := nTotPTMP_T	+ TMP->PRCTMP
			nTotGPTMP	  := nTotGPTMP 	+ TMP->PRCTMP
			
			nTotPTF_F	  := nTotPTF_F 	+ TMP->PRCTF
			nTotPTF_T	  := nTotPTF_T 	+ TMP->PRCTF
			nTotGTF 	  := nTotGTF		+ TMP->PRCTF
			
			nPrzMF		  := nPrzMF 		+ (TMP->PESONF * aPrz)
			
			nTFF 		  := nTFF			+ aFrt
			nTFT 		  := nTFT			+ aFrt
			nTGF 		  := nTGF			+ aFrt
			
			aDif 		  := 0
			aMp			  := 0
			aFrt 		  := 0                
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Acumula totais de adiantamento									   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If Alltrim(TMP->PRODUTO) == "AD"
				nstict  +=TMP->TICKET
				nsdift  +=TMP->TICKET
				nspctot +=TMP->PRCTF
				nsfortot+=TMP->PRCTMP                   
			EndIf	
			DbSelectArea("TMP")
			DbSkip()
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Quebrar caso seja inicio do adiantamento						   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			If Alltrim(TMP->PRODUTO) == "AD" .and. lprim == .t.
//			    li++
				@ li,00 Psay Repli("-",limite)
				li++
				@ li,008 PSay "SUB-TOTAL: "
				@ li,062 PSay (nUmid_F / nTotFTicket)   PICTURE "@E 999.99"
				@ li,070 PSay nTotNf_F 					 PICTURE "@E 999,999.999"
				@ li,083 PSay nTotFTicket 				 PICTURE "@E 999,999.999"
				@ li,096 PSay nTotDif_F					 PICTURE "@E 999,999.999"
				@ li,130 PSay nTotPTMP_F				 PICTURE "@E 999,999.99"
				@ li,142 PSay nTotPTF_F					 PICTURE "@E 999,999.99"
				@ li,154 PSay nTotMp_F 					 PICTURE "@E 999,999.99"
				@ li,166 PSay nTFF						 PICTURE "@E 999,999.99"
				@ li,179 PSay (nPrzMF / nTotNf_F)		 PICTURE "@E 9,999"
				lprim := .F.  
				li++
				@ li,00 Psay Repli("-",limite)
				li++
			EndIf	
			
		EndDo
		If nstict <> 0
			@ li,00 Psay Repli("-",limite)
			li++
			@ li,008 PSay "SUB-TOTAL ADIANT.: "
			@ li,062 PSay 0					         PICTURE "@E 999.99"
			@ li,070 PSay 0  		                 PICTURE "@E 999,999.999"
			@ li,083 PSay nstict      				 PICTURE "@E 999,999.999"
			@ li,096 PSay nsdift    				 PICTURE "@E 999,999.999"
			@ li,130 PSay nsfortot         			 PICTURE "@E 999,999.99"
			@ li,142 PSay nspctot   				 PICTURE "@E 999,999.99"
			@ li,154 PSay nsfortot					 PICTURE "@E 999,999.99"
			@ li,166 PSay nspctot					 PICTURE "@E 999,999.99"
			@ li,179 PSay 0                      	 PICTURE "@E 9,999"
			nstict   := 0           
			nsdift   := 0             
			nsfortot := 0
			nspctot  := 0             
			nsfortot := 0            
			nspctot  := 0
			
			lprim := .F.  
			li++
			@ li,00 Psay Repli("-",limite)
			li++
		EndIf	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Checa se houve quebra de pagina									   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		If  li >= 60
			cPag := cPag + 1
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			li	 := li + 1
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek(xFilial("SA2")+aTransp)
			@ li,000 PSay "TRANSPORTADORA: "+SA2->A2_COD+" - "+SA2->A2_NOME
			li	 := li + 2
			DbSeek(xFilial("SA2")+aFornec)
			@ li,011 PSay "FORNECEDOR: "+SA2->A2_COD+" - "+SA2->A2_NOME
			DbSelectArea("TMP")
			li	 := li + 2
		EndIf
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Totaliza a quebra do fornecedor									   �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		aFornec 	  := TMP->FORNEC
		@ li,00 Psay Repli("-",limite)
		li++				
		@ li,008 PSay "TOTAL FORNECEDOR: "
		@ li,062 PSay (nUmid_F / nTotFTicket)  PICTURE "@E 999.99"
		@ li,070 PSay nTotNf_F 					 PICTURE "@E 999,999.999"
		@ li,083 PSay nTotFTicket 				 PICTURE "@E 999,999.999"
		@ li,096 PSay nTotDif_F					 PICTURE "@E 999,999.999"
		@ li,130 PSay nTotPTMP_F					 PICTURE "@E 999,999.99"
		@ li,142 PSay nTotPTF_F					 PICTURE "@E 999,999.99"
		@ li,154 PSay nTotMp_F 					 PICTURE "@E 999,999.99"
		@ li,166 PSay nTFF							 PICTURE "@E 999,999.99"
		@ li,179 PSay (nPrzMF / nTotNf_F)		 PICTURE "@E 9,999"
		li++
		@ li,00 Psay Repli("-",limite)
		li++
		lprim := .T.
		nTotUmid_T   := nTotUmid_T	+ (nUmid_F / nTotFTicket)
		nTotGUmid	  := nTotGUmid 	+ (nUmid_F / nTotFTicket)
		nPrzMT		  := nPrzMT 		+ (nPrzMF  / nTotNf_F)
		nPrzMG		  := nPrzMG 		+ (nPrzMF  / nTotNf_F)
		li			  := li + 2
		nTotDif_F	  := 0
		nTotMp_F	  := 0
		nTFF 		  := 0
		nTotNf_F	  := 0
		nTotFTicket  := 0
		nUmid_F 	  := 0
		nTotPTMP_F   := 0
		nTotPTF_F	  := 0
		nPrzMF		  := 0
		
		If !Eof()
			DbSelectArea("SA2")
			DbSeek(xFilial("SA2")+aFornec)
			@ li,008 PSay "FORNECEDOR: "+SA2->A2_COD+" - "+SA2->A2_NOME
			li	:= li + 2
		Else
			li	:= li + 1
		EndIf
		
		DbSelectArea("TMP")
		lOk			 := .T.
	EndDo
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Checa se houve quebra de pagina									   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If  li >= 60
		cPag := cPag + 1
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		li	 := li + 1
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek(xFilial("SA2")+aTransp)
		@ li,000 PSay "TRANSPORTADORA: "+SA2->A2_COD+" - "+SA2->A2_NOME
		li	 := li + 2
		DbSeek(xFilial("SA2")+aFornec)
		@ li,011 PSay "FORNECEDOR: "+SA2->A2_COD+" - "+SA2->A2_NOME
		DbSelectArea("TMP")
		li	 := li + 2
	EndIf
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Totaliza a quebra da transportadora								   �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	aTransp 	  := TMP->TRANSP
	li:=li-3
	@ li,00 Psay Repli("-",limite)
	li++
	@ li,008 PSay "TOTAL TRANSPORTADORA: "
	@ li,062 PSay nTotUmid_T					PICTURE "@E 999.99"
	@ li,070 PSay nTotNf_T 					PICTURE "@E 999,999.999"
	@ li,083 PSay nTotTTicket 				PICTURE "@E 999,999.999"
	@ li,096 PSay nTotDif_T					PICTURE "@E 999,999.999"
	@ li,130 PSay nTotPTMP_T					PICTURE "@E 999,999.99"
	@ li,142 PSay nTotPTF_T					PICTURE "@E 999,999.99"
	@ li,154 PSay nTotMp_T 					PICTURE "@E 999,999.99"
	@ li,166 PSay nTFT							PICTURE "@E 999,999.99"
	@ li,179 PSay nPrzMT						PICTURE "@E 9,999"
	li++
    @ li,00 Psay Repli("-",limite)
	li			  := li + 1
	nTotUmid_T   := 0
	nTotDif_T	  := 0
	nTotMp_T	  := 0
	nTFT 		  := 0
	nTotNf_T	  := 0
	nTotTTicket  := 0
	nPrzMT		  := 0
	
	DbSelectArea("TMP")
EndDo

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Checa se houve quebra de pagina 								   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If  li >= 60
	cPag := cPag + 1
	li	:= 1
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	li	:= li + 1
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Imprime o Total Geral											   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
@ li,00 Psay Repli("-",limite)
li++
@ li,008 PSay "TOTAL GERAL: "
@ li,062 PSay nTotGUmid 				PICTURE "@E 999.99"
@ li,070 PSay nTotGNf					PICTURE "@E 999,999.999"
@ li,083 PSay nTotGTicket				PICTURE "@E 999,999.999"
@ li,096 PSay nTotGDif					PICTURE "@E 999,999.999"
@ li,130 PSay nTotGPTMP 				PICTURE "@E 999,999.99"
@ li,142 PSay nTotGTF					PICTURE "@E 999,999.99"
@ li,154 PSay nTotGMp					PICTURE "@E 999,999.99"
@ li,166 PSay nTGF						PICTURE "@E 999,999.99"
li++
@ li,000 Psay Repli("-",limite)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Impress꼘 do rodap� 												   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
IF  li != 80
	roda(cbcont,cbtxt,"G")
ENDIF

Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fFinaliza
Static FUNCTION fFinaliza()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Restaura Tela e Set's                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SET DEVICE TO SCREEN

#IFNDEF WINDOWS
	RESTSCREEN(3,0,24,79,cSavScr1)
	DBSETORDER(1)
#ENDIF

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Se impress꼘 em Disco, chama SPOOL 									   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
IF aReturn[5] == 1		// disco
	Set Printer TO
	Commit					//grava em disco
	ourspool(wnrel)
ENDIF

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Apaga os arquivos temporarios										   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
dbSelectArea("TMP")
Use
IF  File(cArqTrab+".DBF")
	Ferase(cArqtrab+".*")
ENDIF


//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera relat줿io para Spool da Rede									   �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
FT_PFLUSH()

Return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � GravaReg   � Autor � Cesar Magnago		  � Data � 13/09/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Rotina para gravar o arquivo de trabalho						낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � Interpretador xBase											낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION GravaReg
/*/
Static FUNCTION GravaReg()

DbSelectArea("TMP")

If !RecLock("TMP", .F.)
	TMP->TRANSP	:= cTransp
	TMP->FORNEC	:= cFornec
	TMP->PRODUTO	:= cProduto
	TMP->CHEGADA	:= dChegada
	TMP->CTRC		:= cCtrc
	TMP->DOC		:= cDoc
	TMP->UMIDADE	:= nUmidade
	TMP->PESONF	:= nPesoNf
	TMP->TICKET	:= nTicket
	TMP->PRCUMP	:= nPrcUMp
	TMP->PRCUFRET := nPrcUFret
	TMP->PREFIXO	:= cPrefixo
	TMP->PRCTMP	:= nPrcTMp
	TMP->PRCTF 	:= aPrcTF
	TMP->VENCTO	:= dVencto
	TMP->PEDIDO	:= cPedido
	TMP->ITEMPC	:= cItemPc
Else
	RecLock("TMP",.T.)
	TMP->TRANSP	:= cTransp
	TMP->FORNEC	:= cFornec
	TMP->PRODUTO	:= cProduto
	TMP->CHEGADA	:= dChegada
	TMP->CTRC		:= cCtrc
	TMP->DOC		:= cDoc
	TMP->UMIDADE	:= nUmidade
	TMP->PESONF	:= nPesoNf
	TMP->TICKET	:= nTicket
	TMP->PRCUMP	:= nPrcUMp
	TMP->PRCUFRET := nPrcUFret
	TMP->PREFIXO	:= cPrefixo
	TMP->PRCTMP	:= nPrcTMp
	TMP->PRCTF 	:= aPrcTF
	TMP->VENCTO	:= dVencto
	TMP->PEDIDO	:= cPedido
	TMP->ITEMPC	:= cItemPc
	MsUnLock()
EndIf

Return

/*/
