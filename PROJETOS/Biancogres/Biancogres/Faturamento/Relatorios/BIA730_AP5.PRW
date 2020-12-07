#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/02/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF
#include "topconn.ch"

User Function Bia730()        // incluido pelo assistente de conversao do AP5 IDE em 02/02/01

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Local aDriver := ReadDriver( )  
SetPrvt("LEND,LABORTPRINT,TAMANHO,LIMITE,TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,ARETURN,ALINHA,NOMEPROG,NLASTKEY")
SetPrvt("CPERG,LI,CBTXT,CBCONT,CABEC1,CABEC2")
SetPrvt("CSTRING,M_PAG,WNREL,_ACAMPOS,TMP,REL,XNUMERO")
SetPrvt("XPRODUTO,XITEM,XNF,XQTDVEN,XSERIE,XEMISSAO")
SetPrvt("XVALORNF,XNUMSEQ,XCLIENTE,XLOJA,WPESOLIQC,WPESOBR")
SetPrvt("CTRACOS,XNUM,CCHAVE,XCLIENT,XTRANSP,XVEND1")
SetPrvt("XCONDPAG,XENDCOB,XTELCOB,XCGCCOB,XCIDCOB,XESTCOB")
SetPrvt("XFAX,XNOME,XEND,XCEP,XMUN,XEST")
SetPrvt("XCGC,XINSCR,XFAXCLI,XTELCLI,XCONTATO,XDIA")
SetPrvt("XMES,XANO,XTOTQTD,YITEM,XTOTNF,XTOTPB")
SetPrvt("XDESCRI,")

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	 Ё 	          Ё 	                          Ё Data Ё 20/11/02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё                                       	                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		 Ё Interpretador xBase										    Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

lEnd		   := .F.
lAbortPrint := .F.
tamanho		:= "M"
limite		:= 132
titulo		:= "Fax de Transportadoras  "
cDesc1		:= "Emite o Fax de Transportadoras considerandos apenas "
cDesc2		:= "os pedidos liberados. "
cDesc3		:= "      "
aReturn		:= { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
aLinha		:= { }
nomeprog 	:= "BIA730"
nLastKey 	:= 0
cPerg 		:= "BIA730"
li 			:= 1

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Vari═veis utilizadas para Impress└o do Cabe┤alho e Rodap┌	  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cbtxt 	:= SPACE(10)
cbcont	:= 0
cabec1	:= "  "
cabec2	:= "  "
cString	:= "SC9"
li 		:= 80
m_pag 	:= 1
wnrel 	:= "BIA730"   // nome default do relatorio em disco

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definicao do arquivo de trabalho para totalizar as informacoes por prod.	Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aCampos := {}
AADD(aCampos, {"PEDIDO"  , "C", 06, 0})
AADD(aCampos, {"VALORPD" , "N", 12, 2})
AADD(aCampos, {"EMISSAO" , "D", 08, 0})
AADD(aCampos, {"VOLUME"  , "N", 12, 2})
AADD(aCampos, {"ESPECIE" , "C", 10, 0})
AADD(aCampos, {"PRODUTO" , "C", 15, 0})
AADD(aCampos, {"PRODDESC", "C", 28, 0})
AADD(aCampos, {"QTDVEN"  , "N", 12, 2})
AADD(aCampos, {"PBRUTO"  , "N", 12, 2})
AADD(aCampos, {"QTDCXS"  , "N", 12, 2})
AADD(aCampos, {"TRANSP"  , "C", 06, 0})
AADD(aCampos, {"TRANDESC", "C", 30, 0})
AADD(aCampos, {"CLIENTE" , "C", 06, 0})
AADD(aCampos, {"CLILOJA" , "C", 02, 0})
AADD(aCampos, {"CLIEND"  , "C", 30, 0})
AADD(aCampos, {"CLIMUN"  , "C", 20, 0})
AADD(aCampos, {"CLIEST"  , "C", 02, 0})
AADD(aCampos, {"CLIDESC" , "C", 30, 0})
AADD(aCampos, {"TRANEND" , "C", 40, 0})
AADD(aCampos, {"TRANCEP" , "C", 08, 0})
AADD(aCampos, {"TRANMUN" , "C", 15, 0})
AADD(aCampos, {"TRANEST" , "C", 02, 0})
AADD(aCampos, {"TRANCGC" , "C", 14, 0})
AADD(aCampos, {"TRANIE"  , "C", 15, 0})
AADD(aCampos, {"TRANTEL" , "C", 15, 0})
AADD(aCampos, {"TRANCONT", "C", 15, 0})              

cArqTemp := CriaTrab(aCampos, .T.)
DbUseArea(.T.,,cArqTemp,"REL")
DbCreateInd(cArqTemp+".001","TRANSP+CLIENTE+PEDIDO",{||TRANSP+CLIENTE+PEDIDO})
OrdListClear()
OrdListAdd(cArqTemp+".001")

/*
_aCampos := {{"TRANSP", "C", 06, 0},;
{"CLIENTE", "C", 06, 0},;
{"PEDIDO" , "C", 06, 0},;
{"VALORPD", "N", 11, 3},;
{"PBRUTO" , "N", 09, 2},;
{"EMISSAO", "C", 10, 0} }

cTrab := CriaTrab(_aCampos, .T.)
DbUseArea(.T.,,cTrab,"TMP")
DbCreateInd(cTrab,"TRANSP+CLIENTE+PEDIDO",{||TRANSP+CLIENTE+PEDIDO})
*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ajuste dos par┐metros da impress└o via fun┤└o SETPRINT		  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)
if lastkey()==27
	Return
endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Aceita par┐metros e faz ajustes necess═rios 					 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetDefault(aReturn,cString)
if lastkey()==27
	Return
endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Solicita os parametros para a emissao do relatorio					   Ё
//цддддддддддбддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
//Ё mv_par01 Ё Transportadora Inicial									   Ё
//Ё mv_par02 Ё Transportadora Final										   Ё
//Ё mv_par03 Ё Emissao Inicial											   Ё
//Ё mv_par04 Ё Emissao Final											   Ё
//Ё mv_par05 Ё Linha                                                       Ё
//юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte("BIA730",.F.)
if lastkey()==27
	Return
endif

Processa({|| Monta_Arq()  })
fFinaliza()

RETURN

//зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
//ЁFun┤└o	 Ё Monta_Arq  Ё Autor Ё Adam Del Fiume	      Ё Data Ё 20/11/02 Ё
//цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
//ЁDescri┤└o Ё Monta arquivo de trabalho e imprime relatorio				Ё
//юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Static FUNCTION Monta_Arq()

DbSelectArea("SF2")
DbSetOrder(6)
DbGoTop()

cQuery  := ""
cQuery  := cQuery + "SELECT COUNT(C9_PEDIDO) AS TOTREGS "
cQuery  := cQuery + "FROM " +RetSQLName("SC9")+" SC9, "
cQuery  := cQuery + RetSQLName("SC5")+" SC5, "  
cQuery  := cQuery + RetSQLName("SA1")+" SA1, "
cQuery  := cQuery + RetSQLName("SA4")+" SA4, "
cQuery  := cQuery + RetSQLName("SB1")+" SB1 "
cQuery  := cQuery + "WHERE "
cQuery  := cQuery + "SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND "
cQuery  := cQuery + "SC9.C9_BLEST = '  ' AND SC9.C9_BLCRED = '  ' AND "
cQuery  := cQuery + "SC9.C9_NFISCAL = '      ' AND "
cQuery  := cQuery + "SC9.D_E_L_E_T_ = '' AND "
cQuery  := cQuery + "SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
cQuery  := cQuery + "SC5.C5_NUM = SC9.C9_PEDIDO AND "
cQuery  := cQuery + "SC5.C5_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND "
cQuery  := cQuery + "SC5.C5_TRANSP BETWEEN  '"+MV_PAR01      +"' AND '"+MV_PAR02      +"' AND "
If MV_PAR05 == 1 
     cQuery  := cQuery + "SC5.C5_YLINHA  = '1' AND "
Else
     cQuery  := cQuery + "SC5.C5_YLINHA  = '2' AND "
EndIf
cQuery  := cQuery + "SC5.C5_TIPO    = 'N' AND "
cQuery  := cQuery + "SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cQuery  := cQuery + "SB1.B1_COD = SC9.C9_PRODUTO AND "
cQuery  := cQuery + "SB1.D_E_L_E_T_ = ''AND "
cQuery  := cQuery + "SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
cQuery  := cQuery + "SA1.A1_COD = SC9.C9_CLIENTE AND "
cQuery  := cQuery + "SA1.A1_LOJA = SC9.C9_LOJA AND "
cQuery  := cQuery + "SA1.D_E_L_E_T_ = '' AND "
cQuery  := cQuery + "SA4.A4_FILIAL = '"+xFilial("SA4")+"' AND "
cQuery  := cQuery + "SA4.A4_COD = SC5.C5_TRANSP AND "
cQuery  := cQuery + "SA4.D_E_L_E_T_ = '' "
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

/*
cQuery  := cQuery + "( "
cQuery  := cQuery + ""
cQuery  := cQuery + "               SELECT COUNT(DISTINCT D1_NFORI) "
cQuery  := cQuery + "               FROM SD1010 "
cQuery  := cQuery + "               WHERE "
cQuery  := cQuery + "                     (D1_NFORI  = F2_DOC    ) AND "
cQuery  := cQuery + "                     (D1_SERIORI = F2_SERIE ) AND "
cQuery  := cQuery + "                     (SD1010.D_E_L_E_T_ = '')"
cQuery  := cQuery + ""
cQuery  := cQuery + ") = 0 "
*/

If nTotRegs == 0
	MsgAlert("Nao Existem Registros para os Parametros Informados.....")
//	Exit
EndIf

DbSelectArea("SF2")
DbSetOrder(6)
DbSeek(xFilial("SF2")+DTOS(MV_PAR03),.T.)

cQuery  := ""
cQuery  := cQuery + "SELECT "
cQuery  := cQuery + "SC9.C9_PEDIDO, "
cQuery  := cQuery + "SC9.C9_PRODUTO, "
cQuery  := cQuery + "SC9.C9_ITEM, "
cQuery  := cQuery + "SC9.C9_QTDLIB, "
cQuery  := cQuery + "SC9.C9_CLIENTE, "
cQuery  := cQuery + "SC9.C9_LOJA, "
cQuery  := cQuery + "(SC9.C9_QTDLIB* SB1.B1_PESO) AS PESOL, "
cQuery  := cQuery + "(SC9.C9_QTDLIB* SC9.C9_PRCVEN) AS VLRITEM, "
cQuery  := cQuery + "SB1.B1_DESC, "
cQuery  := cQuery + "SB1.B1_TIPCONV, "
cQuery  := cQuery + "SB1.B1_CONV, "
cQuery  := cQuery + "SB1.B1_YPESEMB, "
cQuery  := cQuery + "SC5.C5_EMISSAO, "
cQuery  := cQuery + "SC5.C5_CLIENTE, "
cQuery  := cQuery + "SC5.C5_TRANSP, "
cQuery  := cQuery + "SC5.C5_VEND1, "
cQuery  := cQuery + "SC5.C5_CONDPAG, "
cQuery  := cQuery + "SC5.C5_REAJUST, "
cQuery  := cQuery + "SC5.C5_FRETE, "
cQuery  := cQuery + "SC5.C5_REDESP, "
cQuery  := cQuery + "SC5.C5_TABELA, "
cQuery  := cQuery + "SC5.C5_VOLUME1, "
cQuery  := cQuery + "SC5.C5_ESPECI1, "
cQuery  := cQuery + "SA1.A1_END, "
cQuery  := cQuery + "SA1.A1_NOME, "
cQuery  := cQuery + "SA1.A1_MUN, "
cQuery  := cQuery + "SA1.A1_EST, "
cQuery  := cQuery + "SA4.A4_NOME, "
cQuery  := cQuery + "SA4.A4_END, "
cQuery  := cQuery + "SA4.A4_CEP, "
cQuery  := cQuery + "SA4.A4_MUN, "
cQuery  := cQuery + "SA4.A4_EST, "
cQuery  := cQuery + "SA4.A4_CGC, "
cQuery  := cQuery + "SA4.A4_INSEST, "
cQuery  := cQuery + "SA4.A4_TEL, "
cQuery  := cQuery + "SA4.A4_CONTATO, "
cQuery  := cQuery + "SA4.A4_NOME "
cQuery  := cQuery + "FROM " +RetSQLName("SC9")+" SC9, "
cQuery  := cQuery + RetSQLName("SC5")+" SC5, "
cQuery  := cQuery + RetSQLName("SA1")+" SA1, "
cQuery  := cQuery + RetSQLName("SA4")+" SA4, "
cQuery  := cQuery + RetSQLName("SB1")+" SB1 "
cQuery  := cQuery + "WHERE "
cQuery  := cQuery + "SC9.C9_FILIAL = '"+xFilial("SC9")+"' AND "
cQuery  := cQuery + "SC9.C9_BLEST = '  ' AND SC9.C9_BLCRED = '  ' AND "
cQuery  := cQuery + "SC9.C9_NFISCAL = '      ' AND "
cQuery  := cQuery + "SC9.D_E_L_E_T_ = '' AND "
cQuery  := cQuery + "SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
cQuery  := cQuery + "SC5.C5_NUM = SC9.C9_PEDIDO AND "
cQuery  := cQuery + "SC5.C5_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND "
cQuery  := cQuery + "SC5.C5_TRANSP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
If MV_PAR05 == 1 
     cQuery  := cQuery + "SC5.C5_YLINHA  = '1' AND "
Else
     cQuery  := cQuery + "SC5.C5_YLINHA  = '2' AND "
EndIf
cQuery  := cQuery + "SC5.C5_TIPO    = 'N' AND "
cQuery  := cQuery + "SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
cQuery  := cQuery + "SA1.A1_COD = SC9.C9_CLIENTE AND "
cQuery  := cQuery + "SA1.A1_LOJA =SC9.C9_LOJA AND "
cQuery  := cQuery + "SA1.D_E_L_E_T_ = ''AND "
cQuery  := cQuery + "SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cQuery  := cQuery + "SB1.B1_COD = SC9.C9_PRODUTO AND "
cQuery  := cQuery + "SB1.D_E_L_E_T_ = ''AND "
cQuery  := cQuery + "SA4.A4_FILIAL = '"+xFilial("SA4")+"' AND "
cQuery  := cQuery + "SA4.A4_COD = SC5.C5_TRANSP AND "
cQuery  := cQuery + "SA4.D_E_L_E_T_ = '' "
cQuery  := cQuery + "ORDER BY "
cQuery  := cQuery + "SC9.C9_PEDIDO, "
cQuery  := cQuery + "SC9.C9_PRODUTO, "
cQuery  := cQuery + "SC9.C9_ITEM "
TCQuery cQuery Alias "TRB" New

ProcRegua(nTotRegs)

DbSelectArea("TRB")
DbGoTop()

WHILE !EOF()
	
    	INCPROC("Processando Pedidos Liberados....")

        //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa o totalizador de Peso Bruto do produto atual e captura ...    Ё
		//Ё os dados da NF, Cliente, Transportadora, Vendedor e Cond. Pagamento.     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		
		cPedido  := TRB->C9_PEDIDO
		dEmissao := u_stod(TRB->C5_EMISSAO)
		nVolume  := TRB->C5_VOLUME1
		cEspecie := TRB->C5_ESPECI1
		cProduto := TRB->C9_PRODUTO
		cProdDesc:= TRB->B1_DESC
		nPesoBr  := 0
		nQtdcxs  := 0
		nValorPD := 0
		cVend    := TRB->C5_VEND1
		cCondPag := TRB->C5_CONDPAG
		cTransp  := TRB->C5_TRANSP
		cTranDesc:= TRB->A4_NOME
		cCliente := TRB->C9_CLIENTE
		cCliLoja := TRB->C9_LOJA
		cCliDesc := TRB->A1_NOME
		cCliMun  := TRB->A1_MUN
		cCliEst  := TRB->A1_EST
		cTranDes := TRB->A4_NOME
		cTranEnd := TRB->A4_END
		cTranCep := TRB->A4_CEP
		cTranMun := TRB->A4_MUN
		cTranEst := TRB->A4_EST
		cTranCGC := TRB->A4_CGC
		cTranIE  := TRB->A4_INSEST
		cTranTel := TRB->A4_TEL
		cTranCon := TRB->A4_CONTATO





		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Totaliza o Peso Bruto da NF e produto atuais.                            Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		do while TRB->C9_PEDIDO == cPedido
			do case
				case TRB->B1_TIPCONV == "M"; nPesoBr += (TRB->C9_QTDLIB * TRB->B1_CONV * TRB->B1_YPESEMB) + TRB->PESOL; nQtdcxs += (TRB->C9_QTDLIB * TRB->B1_CONV)
				case TRB->B1_TIPCONV == "D"; nPesoBr += (TRB->C9_QTDLIB / TRB->B1_CONV * TRB->B1_YPESEMB) + TRB->PESOL; nQtdcxs += (TRB->C9_QTDLIB / TRB->B1_CONV)
			endcase
			nValorPD :=nValorPD + TRB->VLRITEM
			TRB->(dbSkip())
		enddo

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava arquivo de trabalho                                                Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    	dbSelectArea("REL")
    	RecLock("REL",.T.)
		REL->PEDIDO   := cPedido
		REL->EMISSAO  := dEmissao
		REL->VOLUME   := nVolume
		REL->ESPECIE  := cEspecie
		REL->PRODUTO  := cProduto
		REL->PRODDESC := cProdDesc
//		REL->QTDVEN   := nQtdVen
		REL->VALORPD  := nValorPD
		REL->PBRUTO   := nPesoBr
		REL->QTDCXS   := nQtdcxs
		REL->TRANSP   := cTransp
		REL->TRANDESC := cTranDesc
		REL->CLIENTE  := cCliente
		REL->CLILOJA  := cCliLoja
		REL->CLIDESC  := cCliDesc
        REL->CLIMUN   := cCliMun
        REL->CLIEST   := cCliEst
        REL->TRANDESC := cTranDes
        REL->TRANEND  := cTranEnd
        REL->TRANCEP  := cTranCep
        REL->TRANMUN  := cTranMun
        REL->TRANEST  := cTranEst
        REL->TRANCGC  := cTranCGC
        REL->TRANIE   := cTranIE
        REL->TRANTEL  := cTranTel
        REL->TRANCONT := cTranCon
        nTotRegs++
		REL->(MsUnLock())	
    	
	    DbSelectArea("TRB")
//	    DbSkip()
EndDo
TRB->(DBCloseArea())

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a linha da regua 																Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PROCREGUA( REL -> (RecCount()) * 3 )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicia o procedimento de impressao dos valores obtidos				      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTracos	  := "-"

DBSELECTAREA("REL")
DBGOTOP()
WHILE !EOF()
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Movimenta o cursor da regua 							           Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	INCPROC("Processando Arquivo de Trabalho.....")
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se teclou ALT + A (Interrompe a impressao) 	     Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If LastKey() == 27 .Or. nLastKey == 27 .Or. lEnd .Or. lAbortPrint
		dbSelectArea("REL")
		Use
		IF  File(cTrab+".DBF")
			Ferase(cTrab+".*")
		ENDIF
	Endif
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao do cabecalho												  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	li 		  := 3
	//xNf		  := TMP->NF
	//xSerie	  := TMP->SERIE
	xTransp	  := REL->TRANSP
	//DBSELECTAREA("SA4")
	//cChave	  := xFilial("SA4") + xTransp
	//DBSEEK(cChave)
	xEmissao  := Date()
	//xClient   := TMP->CLIENTE

    If ( Tamanho == 'P' )
       @ li,00 PSAY &(aDriver[1])
    ElseIf ( Tamanho == 'G' )
       @ li,00 PSAY &(aDriver[5])
    ElseIf ( Tamanho == 'M' ) .And. ( aReturn[4] == 1 ) 
       @ li,00 PSAY &(aDriver[3])
    ElseIf ( Tamanho == 'M' ) .And. ( aReturn[4] == 2 )
       @ li,00 PSAY &(aDriver[4])
    EndIf

    li        := li + 1
	@ li,045 PSay "F A X   D E   T R A N S P O R T A D O R A"
	li		  := li + 3
	@ li,01   PSAY "A "+REL->TRANDESC
	li		  := li + 1
	@ li,01   PSAY "A/C: "+REL->TRANCONT
	li		  := li + 1
	@ li,01   PSAY "FONE: "+REL->TRANTEL
	li		  := li + 1
	@ li,01   PSay space(05)+"INFORMAMOS QUE O(S) PEDIDO(S) ABAIXO JA ESTA(AO) LIBERADO(S) P/ CARREGAMENTO."
	li		  := li + 1
    @ li,01   PSay space(05)+"SOLICITAMOS ENTRAR EM CONTATO CONOSCO PARA PROGRAMARMOS A SUA RETIRADA."
	li		  := li + 1
//	@ li,01   PSAY "MERCADORIAS PENDENTES A RETIRAR EM NOSSA EXPEDICAO:"
//	li		  := li + 1
	@ li,01   PSAY space(05)+"ABAIXO SEGUE, AS PENDENCIAS:"
	
	li		:= li + 3
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	@ li,82   PSAY "----------------------------------------"
	@ li,122  PSAY "--------"
	@ li,130  PSAY "------------------------------------------------------------------------------------------------------------------------"
//	@ li,130  PSAY "-"
	li		  := li + 1
	DBSELECTAREA("SM0")
	@ li,01   PSAY SM0->M0_NOME
	xEndcob   := SM0->M0_ENDCOB
	xTelcob   := SM0->M0_TEL
	xCgccob   := SM0->M0_CGC
	xCidcob   := SUBSTR(SM0->M0_CIDCOB,1,10)
	xEstcob   := SM0->M0_ESTCOB
	xFax 	  := SM0->M0_FAX
	
	@ li,42   PSAY "|"
	@ li,44   PSAY xTransp
	@ li,50   PSAY "/"
	@ li,51   PSAY xLoja
	@ li,54   PSAY REL->TRANDESC
	@ li,99   PSAY "|"
	@ li,101  PSAY "FAX DE TRANSPORTADORAS"
	li		  := li +1
	@ li,01   PSAY xEndcob
	@ li,42   PSAY "|"
	@ li,44   PSAY REL->TRANEND
	@ li,99   PSAY "|"
	li		  := li + 1
	@ li,01   PSAY "Tel: "
	@ li,06   PSAY xTelcob
	@ li,22   PSAY "Fax: "
	@ li,27   PSAY xFax
	@ li,42   PSAY "|"
	@ li,44   PSAY REL->TRANCEP
	@ li,54   PSAY REL->TRANMUN
	@ li,96   PSAY REL->TRANEST
	@ li,99   PSAY "|"
	@ li,101  PSAY "DATA...: "
//	xDia 	  := STR(DAY(xEmissao),2)
//	xMes 	  := STR(MONTH(xEmissao),2)
//	xAno 	  := SUBSTR(STR(YEAR(xEmissao)),4)
//	@ li,110  PSAY xDia			PICTURE "99"
//	@ li,112  PSAY "/"
//	@ li,113  PSAY xMes			PICTURE "99"
//	@ li,115  PSAY "/"
//	@ li,116  PSAY AllTrim(xAno)PICTURE "9999"
    @ li,110  PSAY DTOC(REL->EMISSAO)
		li		  := li + 1
	@ li,01   PSAY "CGC: "
	@ li,06   PSAY xCgccob 		PICTURE "99999999999999"
	@ li,21   PSAY SUBSTR(xCidcob,1,12)
	@ li,38   PSAY xEstcob
	@ li,42   PSAY "|"
	@ li,44   PSAY REL->TRANCGC PICTURE "99999999999999"
	@ li,63   PSAY "IE: "
	@ li,67   PSAY REL->TRANIE
	@ li,99   PSAY "|"
	li		  := li + 1
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	@ li,82   PSAY "----------------------------------------"
	@ li,122  PSAY "--------"
	@ li,130  PSAY "------------------------------------------------------------------------------------------------------------------------"
	li		  := li + 2
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	@ li,82   PSAY "----------------------------------------"
	@ li,122  PSAY "--------"
	@ li,130  PSAY "------------------------------------------------------------------------------------------------------------------------"
	li		  := li + 1
	@ li,01   PSAY "Cliente          "
	@ li,42   PSAY "Emissao    Cidade                 UF  Pedido          Peso Bruto    Tot.PV(R$)    QTD.CXS"
	li		  := li + 1
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	@ li,82   PSAY "----------------------------------------"
	@ li,122  PSAY "--------"
	@ li,130  PSAY "------------------------------------------------------------------------------------------------------------------------"
	li		  := li + 1
	//DBSELECTAREA("TMP")
	xTotQtd   := 0
	yItem	  := 0
	xTotNF	  := 0
	xTotPB	  := 0
	
	WHILE REL->TRANSP == xTransp .AND. !EOF()
		@ li,01   PSAY REL->CLIENTE
	//	cChave := xFilial("SA1") + TMP->CLIENTE
	//	DBSELECTAREA("SA1")
	//	DBSEEK(cChave)
		xNome	:= SUBST(REL->CLIDESC,1,30)
		//DBSELECTAREA("TMP")
		@ li,10   PSAY SUBST(REL->CLIDESC,1,30)	  			PICTURE "@!"
//		xEmissao	:= U_STOD(REL->EMISSAO)
//		xDia		:= STR(DAY(xEmissao),2)
//		xMes		:= STR(MONTH(xEmissao),2)
//		xAno		:= SUBSTR(STR(YEAR(xEmissao)),4)
//		@ li,42		PSAY xDia							  	PICTURE "99"
//		@ li,44		PSAY "/"
//		@ li,45		PSAY xMes							  	PICTURE "99"
//		@ li,47		PSAY "/"
//		@ li,48		PSAY AllTrim(xAno)					  	PICTURE "9999"
        @ li,42		PSAY DTOC(REL->EMISSAO)
		@ li,53		PSAY REL->CLIMUN 			  			PICTURE "@!"
		@ li,76 	PSAY REL->CLIEST 			 			PICTURE "@!"
		@ li,80		PSAY REL->PEDIDO		  				PICTURE "999999"
		@ li,96   	PSAY REL->PBRUTO 			  			PICTURE "@E 999,999.99"
		@ li,109   	PSAY REL->VALORPD 			  			PICTURE "@E 999,999.99"
		@ li,121   	PSAY REL->QTDCXS                        PICTURE "@E 999,999.99"
		//@ li,118   	PSAY TMP->VOLUME 			  			PICTURE "@E 999,999.99"
		li 		 := li + 1
    
    	DBSELECTAREA("REL")
		DBSKIP()
		
		
	ENDDO
	
	@ li,01   PSAY "-"
	@ li,02   PSAY "----------------------------------------"
	@ li,42   PSAY "----------------------------------------"
	@ li,82   PSAY "----------------------------------------"
	@ li,122  PSAY "--------"
	@ li,130  PSAY "------------------------------------------------------------------------------------------------------------------------"
	li := li + 5
	
	@ li,01 		PSAY "-"
	@ li,02 		PSAY "----------------------------------------"
	@ li,42 		PSAY "----------------------------------------"
	@ li,82 		PSAY "----------------------------------------"
	@ li,122		PSAY "--------"
	@ li,130		PSAY "------------------------------------------------------------------------------------------------------------------------"
	li				:= li + 2
	
	Dizeres()
	
	DBSELECTAREA("REL")
	
ENDDO

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura Tela e Set's                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SET DEVICE TO SCREEN
RETURN( NIL )


//зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
//ЁFun┤└o	 Ё fFianaliza Ё Autor Ё                       Ё Data Ё          Ё
//цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
//ЁDescri┤└o Ё Finaliza impresao do relatorio                    			Ё
//юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Static FUNCTION fFinaliza()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se impress└o em Disco, chama SPOOL 												Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF aReturn[5] == 1		// disco
	Set Printer TO
	Commit					//grava em disco
	ourspool(wnrel)
ENDIF

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apaga os arquivos temporarios														Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("REL")
Use
IF  File(cArqTemp+".DBF")
	Ferase(cArqTemp+".*")
ENDIF

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera relat╒rio para Spool da Rede												Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FT_PFLUSH()

RETURN( NIL )


// Substituido pelo assistente de conversao do AP5 IDE em 02/02/01 ==> Function Dizeres
Static Function Dizeres()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Emite os dizeres finais do fax de embarque										Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ li,01   PSAY "SOLICITAMOS A RETIRADA DAS PEDIDOS RELACIONADOS ACIMA, COM PRAZO DE ATE 03 DIAS, AFIM DE"
li		  := li + 1
@ li,01   PSAY "EVITARMOS RECLAMACOES FUTURAS COM NOSSOS CLIENTES, POIS OS MESMOS ESTAO CIENTES DESTAS"
li		  := li + 1
@ li,01   PSAY "PENDENCIAS."
li		  := li + 2
@ li,01   PSAY "FAVOR CONTACTAR NOSSA EXPEDICAO PARA PROGRAMAR A SUA RETIRADA."
li		  := li + 4
@ li,01   PSAY "ATENCIOSAMENTE,"
li		  := li + 3
@ li,01   PSAY "RENZO"
li		  := li + 3
@ li,01   PSAY "DEPTO COMERCIAL"
li		  := li + 1
@ li,01   PSAY "TEL. (27) 3421-9024"

li		  := li + 2
@ li,01   PSAY "-"
@ li,02   PSAY "----------------------------------------"
@ li,42   PSAY "----------------------------------------"
@ li,82   PSAY "----------------------------------------"
@ li,122  PSAY "--------"
@ li,130  PSAY "------------------------------------------------------------------------------------------------------------------------"
Return
