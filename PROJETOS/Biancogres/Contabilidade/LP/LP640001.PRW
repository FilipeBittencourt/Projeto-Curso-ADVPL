#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LP640001  � Autor � AP5 IDE            � Data �  20/11/02   ���
�������������������������������������������������������������������������͹��
���Descricao � Devolucao                                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function LP640001()
Local clp := Paramixb

Private Enter3	 := CHR(13)+CHR(10)
Private cconta3	 := ""
Private cSql3	 := ""
Private cTes   	 := SD1->D1_TES
Private xGrupo	 := ""

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSF4	:= ""
Private cIndSF4	:= 0
Private cRegSF4	:= 0

Private cArqSD2	:= ""
Private cIndSD2	:= 0
Private cRegSD2	:= 0

Private cArqSA1	:= ""
Private cIndSA1	:= 0
Private cRegSA1	:= 0

Private cArqSB1	:= ""
Private cIndSB1	:= 0
Private cRegSB1	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SF4")
cArqSF4 := Alias()
cIndSF4 := IndexOrd()
cRegSF4 := Recno()

DbSelectArea("SD1")
cArqSD1 := Alias()
cIndSD1 := IndexOrd()
cRegSD1 := Recno()

DbSelectArea("SA1")
cArqSA1 := Alias()
cIndSA1 := IndexOrd()
cRegSA1 := Recno()

//Posicionando no TES
DbSelectArea("SF4")
DbSetOrder(1)
If DbSeek(xFilial("SF4")+cTes,.F.)       // Pesquisa TES da NF de saida
	xGrupo := SF4->F4_YCCONT              // Carrega variavel com o Grupo Contab.
Endif

//Posicionando no Cliente
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA,.T.)

Do case
	case clp == "D"
		//Filtrando a Conta Contabil, pelo Tipo de Produto
		cSql3 := ""
		cSql3 += "SELECT	B1_COD, B1_YTPPROD, " + Enter3
		cSql3 += "		Z6_CTRSVDI,  --VENDA MERC. INTERNO " + Enter3
		cSql3 += "		Z6_CTRSVDE,  --VENDA MERC. EXTERNO " + Enter3
		cSql3 += "		Z6_CTASERV,  --LOCACAO DE BENS " + Enter3
		cSql3 += "		Z6_CTARSDV,  --DEVOLUCAO VENDA " + Enter3
		cSql3 += "		Z6_CTAIPI,	 --IPI " + Enter3
		cSql3 += "		Z6_CTAICMS,	 --ICMS " + Enter3
		cSql3 += "		Z6_CTAPIS,   --PIS " + Enter3
		cSql3 += "		Z6_CTACOF,   --COFINS " + Enter3
		cSql3 += "		Z6_CTDESIN,	 --DESCONTO INCONDICIONAL " + Enter3
		cSql3 += "		Z6_CTICMST,	 --ICMS SUBST. TRIBUTARIA " + Enter3
		cSql3 += "		Z6_CTIPIDV,  --IPI DEVOLUCAO 				" + Enter3
		cSql3 += "		Z6_CTICMDV,	 --ICMS DEVOLUCAO 				" + Enter3
		cSql3 += "		Z6_CTPISDV,  --PIS DEVOLUCAO 				" + Enter3
		cSql3 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO				" + Enter3
		cSql3 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter3
		cSql3 += "WHERE	SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter3
		cSql3 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter3
		cSql3 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter3
		cSql3 += "		SB1.B1_COD  	= '"+SD1->D1_COD+"'		AND	" + Enter3
		cSql3 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter3
		cSql3 += "		SB1.D_E_L_E_T_	= ''						" + Enter3
		If chkfile("TRB3")
			DbSelectArea("TRB3")
			DbCloseArea("TRB3")
		EndIf
		TCQUERY cSql3 ALIAS "TRB3" NEW
		
		If xGrupo == "020"          // Devolucao de Venda
			cConta3 := TRB3->Z6_CTARSDV
		Else						// Nota Fiscal Servico
			cConta3 := '41201060'
		Endif
		
		//Fecha area de trabalho temporaria
		DbSelectArea("TRB3")
		DbCloseArea("TRB3")
		
	case clp == "C"
		cConta3 := SA1->A1_CONTA
ENDCASE

//Volta area de Trabalho
If cArqSF4 <> ""
	dbSelectArea(cArqSF4)
	dbSetOrder(cIndSF4)
	dbGoTo(cRegSF4)
	RetIndex("SF4")
EndIf

If cArqSD1 <> ""
	dbSelectArea(cArqSD1)
	dbSetOrder(cIndSD1)
	dbGoTo(cRegSD1)
	RetIndex("SD1")
EndIf

If cArqSA1 <> ""
	dbSelectArea(cArqSA1)
	dbSetOrder(cIndSA1)
	dbGoTo(cRegSA1)
	RetIndex("SA1")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(cConta3)
