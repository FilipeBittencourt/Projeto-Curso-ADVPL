#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function BIA069()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SetPrvt("LEND,LABORTPRINT,TAMANHO,LIMITE,TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,ARETURN,ALINHA,NOMEPROG,NLASTKEY")
SetPrvt("CPERG,LI,CSAVSCR1,CSAVCUR1,CSAVROW1,CSAVCOL1")
SetPrvt("CSAVCOR1,CBTXT,CBCONT,CABEC1,CABEC2,CSTRING")
SetPrvt("M_PAG,WNREL,_ACAMPOS,_CANALITICO,XPREFIXO,XNUM")
SetPrvt("XPARCELA,XCLIENTE,XEMISSAO,XVENCTO,XVALOR,XPEDIDO")
SetPrvt("XPORTADO,XLOJA,CTRACOS,CCHAVE,XCLIENT,XENDCOB")
SetPrvt("XTELCOB,XCGCCOB,XCIDCOB,XESTCOB,XFAX,XNOME")
SetPrvt("XEND,XCEP,XMUN,XEST,XCGC,XINSCR")
SetPrvt("XDIA,XMES,XANO,")

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё BIA069     Ё Autor Ё    MAGNAGO            Ё Data Ё 20/10/99 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё RELATORIO DE COMUNICACAO INTERNA                             Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё Interpretador xBase                                          Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
lEnd     	:= .F.
lAbortPrint := .F.
tamanho     := "M"
limite      := 132
titulo      := "Comunicacao Interna            "
cDesc1      := "Emite o Fornmulario de Comunicacao Interna.                "
cDesc2   	:= "                                                                        "
cDesc3   	:= "                                                                        "
aReturn  	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
aLinha   	:= { }
nomeprog 	:= "BIA069"
nLastKey 	:= 0
cPerg    	:= "BIA069"
li       	:= 1

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Vari═veis utilizadas para Impress└o do Cabe┤alho e Rodap┌    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cbtxt    := SPACE(10)
cbcont   := 0
cabec1   := "  "
cabec2   := "  "
cString  := "SE1"
li       := 80
m_pag    := 1
wnrel    := "BIA069"   // nome default do relatorio em disco

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definicao do arquivo de trabalho para totalizar as informacoes por prod.  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If chkfile("TMP")
	dbSelectArea("TMP")
	dbCloseArea()
EndIf

_aCampos := {   {"PREFIXO" ,"C", 03, 0},;
{"NUM"     ,"C", 09, 0},;
{"PARCELA" ,"C", 01, 0},;
{"LOJA"    ,"C", 02, 0},;
{"CLIENTE" ,"C", 06, 0},;
{"EMISSAO" ,"D", 08, 0},;
{"VENCTO"  ,"D", 08, 0},;
{"PORTADO" ,"C", 03, 0},;
{"VALOR"   ,"N", 17, 2},;
{"TIPO"    ,"C", 02, 0},;
{"PEDIDO"  ,"C", 06, 0}}
       
cTrab := CriaTrab(_aCampos, .T.)
DbUseArea(.T.,,cTrab,"TMP")
DbCreateInd(cTrab,"NUM",{||NUM})

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ajuste dos par┐metros da impress└o via fun┤└o SETPRINT       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

If LastKey() == 27 .Or. nLastKey == 27 .OR. lEnd .OR. lAbortPrint
	// RestScreen(3,0,24,79,cSavScr1)
	Return
End

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Aceita par┐metros e faz ajustes necess═rios                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetDefault(aReturn,cString)

If LastKey() == 27 .or. nLastKey == 27 .or. lEnd .or. lAbortPrint
	// RestScreen(3,0,24,79,cSavScr1)
	Return
End

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Solicita os parametros para a emissao do relatorio                     Ё
//цддддддддддбддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
//Ё mv_par01 Ё Referencia                                                  Ё
//Ё mv_par02 Ё Numero da nota fiscal                                       Ё
//Ё mv_par03 Ё Serie da nota fiscal                                        Ё
//Ё mv_par04 Ё Parcela da nota fiscal                                      Ё
//Ё mv_par05 Ё Data da prorrogacao                                         Ё
//Ё mv_par06 Ё Valor do desconto                                           Ё
//Ё mv_par07 Ё Motivo1                                                     Ё
//Ё mv_par08 Ё Motivo2                                                     Ё
//Ё mv_par09 Ё Motivo3                                                     Ё
//Ё mv_par10 Ё Motivo4                                                     Ё
//Ё mv_par11 Ё Motivo5                                                     Ё
//юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Pergunte("BIA069",.F.)

RptStatus({|| RptDetail() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     RptStatus({|| Execute(RptDetail) })

fFinaliza()

RETURN

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION RptDetail
Static FUNCTION RptDetail()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a linha da regua                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SETREGUA( SE1 -> (RecCount()) )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia a leitura do SD2 para posterior impressao.                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DBSELECTAREA("SE1")
DBSETORDER(1)
//DbseeK(xFilial("SE1")+mv_par03+mv_par02+mv_par04,.F.)
DbseeK(xFilial("SE1")+mv_par03+mv_par02,.F.)

WHILE !EOF() .AND. (SE1->E1_NUM   == MV_PAR02) .AND. (SE1->E1_PREFIXO == MV_PAR03)
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Movimenta o cursor da regua                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IncRegua()
	
	if (MV_PAR04 <> SPACE(1)) .AND. !(SE1->E1_PARCELA $ ALLTRIM(MV_PAR04) .OR. ALLTRIM(MV_PAR04)== '*')
		DbSkip()
		Loop
	endif
	
	if SE1->E1_SALDO == 0
		DbSkip()
		Loop
	endIf
	
	xPrefixo  := Se1->e1_Prefixo
	xNum      := Se1->e1_Num
	xParcela  := Se1->e1_Parcela
	xTipo	  := Se1->e1_Tipo
	xCliente  := Se1->e1_Cliente
	xEmissao  := Se1->e1_Emissao
	//xVencto   := Se1->e1_Vencrea
	xVencto   := Se1->e1_Vencto
	xValor    := Se1->e1_Valor
	xPedido   := Se1->e1_Pedido
	xPortado  := Se1->e1_Portado
	xLoja     := Se1->e1_Loja
	
	RecLock("TMP",.T.)
	TMP->PREFIXO  := xprefixo
	TMP->NUM      := xnum
	TMP->PARCELA  := xparcela
	TMP->TIPO	  := xTipo
	TMP->CLIENTE  := xcliente
	TMP->EMISSAO  := xemissao
	TMP->VENCTO   := xvencto 
	//TMP->VENCTO   := xvencto + MV_PAR05
	TMP->VALOR    := xvalor
	TMP->PEDIDO   := xpedido
	TMP->PORTADO  := xportado
	TMP->LOJA     := xloja
	MsUnLock()
	
	DBSELECTAREA("Se1")
	DBSKIP()
END

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a linha da regua                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SETREGUA(TMP -> (RecCount()) * 3)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia o procedimento de impressao dos valores obtidos                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTracos    := "-"
DBSELECTAREA("TMP")
DBGOTOP()
WHILE !EOF()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Movimenta o cursor da regua                               Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	INCRegua()
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se teclou ALT + A (Interrompe a impressao)       Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	IF  LASTKEY() == 27 .OR. nLastKey == 27 .OR. lEnd .Or. lAbortPrint
		@ li, 20 PSAY "*** IMPRESSAO ABORTADA PELO USUARIO ***"
		RETURN( NIL )
	ENDIF
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao do cabecalho                                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	li            := 3
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	@ li,82   PSAY "----------------------------------------"
	@ li,122  PSAY "--------"
	@ li,130  PSAY "-"
	li        := li + 1
	xNum      := TMP->NUM
	xPrefixo  := TMP->PREFIXO
	xLoja     := TMP->LOJA
	xPedido   := TMP->PEDIDO
	DBSELECTAREA("SC5")
	cChave    := xFilial("SC5") + xPedido
	DBSEEK(cChave)
	xEmissao  := DATE()
	//xClient   := SC5->C5_CLIENTE
	DBSELECTAREA("SM0")
	@ li,01   PSAY SM0->M0_NOME
	xEndcob   := SM0->M0_ENDCOB
	xTelcob   := SM0->M0_TEL
	xCgccob   := SM0->M0_CGC
	xCidcob   := SUBSTR(SM0->M0_CIDCOB,1,10)
	xEstcob   := SM0->M0_ESTCOB
	xFax      := SM0->M0_FAX
	@ li,42   PSAY "|"
	cChave    := xFilial("SA1") + xCliente + xLoja
	DBSELECTAREA ("SA1")
	DBSEEK(cChave)
	xCliente  := SA1->A1_COD
	xLoja     := SA1->A1_LOJA
	xNome     := SUBSTR(SA1->A1_NOME,1,30)
	xEnd      := SA1->A1_END
	xCep      := SA1->A1_CEP
	xMun      := SA1->A1_MUN
	xEst      := SA1->A1_EST
	xCgc      := SA1->A1_CGC
	xInscr    := SA1->A1_INSCR
	@ li,44   PSAY xCliente
	@ li,50   PSAY "/"
	@ li,51   PSAY xLoja
	@ li,54   PSAY xNome
	@ li,99   PSAY "|"
	@ li,101  PSAY "COMUNICACAO INTERNA"
	li        := li +1
	@ li,01   PSAY xEndcob
	@ li,42   PSAY "|"
	@ li,44   PSAY xEnd
	@ li,99   PSAY "|"
	li        := li + 1
	@ li,01   PSAY "Tel: "
	@ li,06   PSAY xTelcob
	@ li,22   PSAY "Fax: "
	@ li,27   PSAY xFax
	@ li,42   PSAY "|"
	@ li,44   PSAY xCep
	@ li,54   PSAY xMun
	@ li,96   PSAY xEst
	@ li,99   PSAY "|"
	@ li,101  PSAY "EMISSAO: "
	@ li,110  PSAY Transform(xEmissao,"@D")
	
	/*xDia      := STR(DAY(xEmissao),2)
	xMes      := STR(MONTH(xEmissao),2)
	xAno      := SUBSTR(STR(YEAR(xEmissao)),4)
	@ li,110  PSAY xDia                       PICTURE "99"
	@ li,112  PSAY "/"
	@ li,113  PSAY xMes                       PICTURE "99"
	@ li,115  PSAY "/"
	@ li,116  PSAY xAno                       PICTURE "99"*/
	
	li        := li + 1
	@ li,01   PSAY "CGC: "
	@ li,06   PSAY xCgccob       PICTURE "99999999999999"
	@ li,21   PSAY SUBSTR(xCidcob,1,12)
	@ li,38   PSAY xEstcob
	@ li,42   PSAY "|"
	@ li,44   PSAY xCgc          PICTURE "99999999999999"
	@ li,63   PSAY "IE: "
	@ li,67   PSAY xInscr
	@ li,99   PSAY "|"
	li        := li + 1
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	@ li,82   PSAY "----------------------------------------"
	@ li,122  PSAY "--------"
	@ li,130  PSAY "-"
	li        := li + 2
	@ li,01   PSAY "DE..: DEPTO VENDAS"
	li        := li + 1
	@ li,01   PSAY "PARA: CREDITO/COBRANCA"
	li        := li + 2
	@ li,01   PSAY "REFERENCIA.:"
	
	IF mv_par01 == 1
		@ li,16   PSAY "PRORROGACAO DE TITULO(S) REALIZADO EM  _____/_____/_____"
	END
	
	IF mv_par01 == 2
		@ li,16   PSAY "DESCONTO DE TITULO(S) REALIZADO EM  _____/_____/_____"
	END
	
	IF MV_PAR01 == 3
		@ li,16   PSAY "BAIXA DE TITULO(S) REALIZADO EM  _____/_____/_____"
	END
	
	IF MV_PAR01 == 4
		@ li,16   PSAY "SUSTA PROTESTO REALIZADO EM  _____/_____/_____"
	END
	
	IF MV_PAR01 == 5
		@ li,16   PSAY "CANCELA DE TITULO(S) REALIZADO EM  _____/_____/_____"
	END
	
	li        := li + 2
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	li        := li + 1
	If mv_par01 == 1
		@ li,01   PSAY "N.Fiscal   Serie   Parcela   Emissao             Valor   Vencto   Portador     Tipo     Novo Vencto"
	Else
		@ li,01   PSAY "N.Fiscal   Serie   Parcela   Emissao             Valor   Vencto   Portador     Tipo"
	EndIf
	li        := li + 1
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	li        := li + 1
	DBSELECTAREA("TMP")
	
	WHILE TMP->Num == xNum .AND. !EOF()
		@ li,02   PSAY TMP->NUM           PICTURE "999999999"
		@ li,13   PSAY TMP->PREFIXO       PICTURE "@AAA"
		@ li,21   PSAY TMP->PARCELA       PICTURE "@A"
		xEmissao  := TMP->Emissao
		@ li,28	  PSAY Transform(xEmissao,"@D")

		/*xDia      := STR(DAY(xEmissao),2)
		xMes      := STR(MONTH(xEmissao),2)
		xAno      := SUBSTR(STR(YEAR(xEmissao)),4)
		@ li,28   PSAY xDia                      PICTURE "99"
		@ li,30   PSAY "/"
		@ li,31   PSAY xMes                      PICTURE "99"
		@ li,33   PSAY "/"
		@ li,34   PSAY xAno                      PICTURE "99"*/
		
		@ li,39   PSAY TMP->Valor        PICTURE "@E 999,999,999.99"
		xEmissao  := TMP->Vencto
		@ li,55	  PSAY Transform(xEmissao,"@D")

		/*xDia      := STR(DAY(xEmissao),2)
		xMes      := STR(MONTH(xEmissao),2)
		xAno      := SUBSTR(STR(YEAR(xEmissao)),4)
		@ li,55   PSAY xDia                      PICTURE "99"
		@ li,57   PSAY "/"
		@ li,58   PSAY xMes                      PICTURE "99"
		@ li,60   PSAY "/"
		@ li,61   PSAY xAno                      PICTURE "99"*/

		@ li,68   PSAY TMP->Portado
		@ li,80   PSAY TMP->TIPO
		xVenct := xEmissao + MV_PAR05
		@ li,90   PSAY Transform(xVenct ,"@D")
		
		li        := li + 1
		DBSKIP()
	END
	
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "---------------------------------------"
	li        := li + 2
	
	IF mv_par01 == 1
		//@ li,01   PSAY "Solicito prorrogar no(s) titulo(s) em epigrafe para o dia :"
		@ li,01   PSAY "Solicito prorrogar no(s) titulo(s) em epigrafe em " +AllTrim(STR(MV_PAR05))+" dia(s)"
		//xEmissao  := TMP->VENCTO
		//xEmissao := xvencto + MV_PAR05
		//@ li,54	  PSAY Transform(xEmissao,"@D")

		/*xDia      := STR(DAY(xEmissao),2)
		xMes      := STR(MONTH(xEmissao),2)
		xAno      := SUBSTR(STR(YEAR(xEmissao)),4)
		@ li,54   PSAY xDia                      PICTURE "99"
		@ li,56   PSAY "/"
		@ li,57   PSAY xMes                      PICTURE "99"
		@ li,59   PSAY "/"
		@ li,60   PSAY xAno                      PICTURE "99"*/
		
	END
	
	IF mv_par01 == 2
		@ li,01   PSAY "Solicito desconto no(s) titulo(s) em ep║grafe no valor de :"
		@ li,56   PSAY mv_par06          PICTURE "@E 999,999,999.99"
	END
	
	IF MV_PAR01 == 3
		@ li,01   PSAY "Solicito baixa no t║tulo em ep║grafe."
	END
	
	IF MV_PAR01 == 4
		@ li,01   PSAY "Solicito sustar o protesto em ep║grafe."
	END
	
	IF MV_PAR01 == 5
		@ li,01   PSAY "Solicito cancelamento do t║tulo em ep║grafe."
	END
	
	li := li + 2
	@ li,01       PSAY "* FAVOR INFORMAR AO CLIENTE"
	li := li + 2
	@ li,01       PSAY "MOTIVO :"
	li := li + 2
	@ li,01       PSAY mv_par07
	li := li + 1
	@ li,01       PSAY mv_par08
	li := li + 1
	@ li,01       PSAY mv_par09
	li := li + 1
	@ li,01       PSAY mv_par10
	li := li + 2
	@ li,01       PSAY "Atenciosamente,"
	li            := li + 3
	cChave        := xFilial("SC5") + xNum
	DBSELECTAREA("SC5")
	DBSEEK(cChave)
	
	@ li,01       PSAY "-"
	@ li,02       PSAY "----------------------------------------"
	@ li,42       PSAY "----------------------------------------"
	@ li,82       PSAY "----------------------------------------"
	@ li,122      PSAY "--------"
	@ li,130      PSAY "-"
	li            := li + 50
	DBSELECTAREA("TMP")
	DBSKIP()
	
END

RETURN

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fFinaliza
Static FUNCTION fFinaliza()

DBSETORDER(1)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se impress└o em Disco, chama SPOOL                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF aReturn[5] == 1      // disco
	Set Printer TO
	Commit               //grava em disco
	ourspool(wnrel)
ENDIF

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apaga os arquivos temporarios                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("TMP")
Use
IF File(cTrab+".DBF")
	Ferase(cTrab+".*")
ENDIF

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera relat╒rio para Spool da Rede                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FT_PFLUSH()

RETURN
