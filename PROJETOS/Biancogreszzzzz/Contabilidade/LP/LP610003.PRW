#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LP610003  ³ Autor ³ Ranisses A. Corona    ³ Data ³ 30/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Contabilizacao do Produto				 				  ³±±
±±³          ³ 								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Contabilizacao Faturamento                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function LP610003()
Private Enter3	 := CHR(13)+CHR(10)
Private cconta3	 := ""
Private cSql3	 := ""
Private cTes   	 := SD2->D2_TES
Private xGrupo	 := ""

//Armazena area de Trabalho
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

DbSelectArea("SD2")
cArqSD2 := Alias()
cIndSD2 := IndexOrd()
cRegSD2 := Recno()

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
DbSeek(xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA,.T.)

//Filtrando a Conta Contabil, pelo Tipo de Produto
cSql3 := ""
cSql3 += "SELECT	B1_COD, B1_YTPPROD, B1_GRUPO,  " + Enter3
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
cSql3 += "		Z6_CTIPIDV,  --IPI DEVOLUCAO " + Enter3
cSql3 += "		Z6_CTICMDV,	 --ICMS DEVOLUCAO " + Enter3
cSql3 += "		Z6_CTPISDV,  --PIS DEVOLUCAO " + Enter3
cSql3 += "		Z6_CTCOFDV   --COFINS DEVOLUCAO " + Enter3
cSql3 += "FROM	" + RetSqlName("SZ6") + " SZ6, SB1010 SB1 	" + Enter3         
cSql3 += "WHERE	SZ6.Z6_FILIAL	= '"+xFilial("SZ6")+"'	AND " + Enter3
cSql3 += "		SB1.B1_FILIAL	= '"+xFilial("SB1")+"'	AND " + Enter3
cSql3 += "		SZ6.Z6_TPPROD	= B1_YTPPROD 			AND " + Enter3
cSql3 += "		SB1.B1_COD  	= '"+SD2->D2_COD+"'		AND	" + Enter3
cSql3 += "		SZ6.D_E_L_E_T_	= ''					AND	" + Enter3
cSql3 += "		SB1.D_E_L_E_T_	= ''						" + Enter3
If chkfile("TRB3")
	DbSelectArea("TRB3")
	DbCloseArea("TRB3")
EndIf
TCQUERY cSql3 ALIAS "TRB3" NEW

If xGrupo <> "560"          // Nota Fiscal Venda
   cConta3 := TRB3->Z6_CTRSVDI 
   If SA1->A1_EST == "EX"
      cConta3 := TRB3->Z6_CTRSVDE
   Endif
Else						// Nota Fiscal Servico
   cConta3 := TRB3->Z6_CTASERV
Endif

If xGrupo = "650"           // Nota Fiscal de Bonificacao
   cConta3 := ""
EndIf

// Tiago/Berger em 31.10.14 a pedido da OS Effetivo 1438-14   
cGrupo := Posicione("SB1", 1, xFilial("SB1") + SD2->D2_COD, "B1_GRUPO")

// Venda expositores 
If SM0->M0_CODIGO == "13" .And. Alltrim(Substr(cGrupo,1,3)) == "216" 
	cConta3 := "41501011" 

//Berger em 20.11.14 a pedido da OS Effetivo 1609-14
//Venda de Produtos não acabados								//Berger em 11.09.15 OS 1897-15
/*ElseIf  (SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(Substr(cGrupo,1,3)) $ "101/102/104/107") .or. (SM0->M0_CODIGO $ "01/05/14" .And. cGrupo >= '201 ' .And. cGrupo <= '222Z' )
		cConta3 := "41501011"
*/

//Berger em 20.11.14 a pedido da OS Effetivo 1609-14
//Venda de Produtos não acabados								//Berger em 11.09.15 OS 1897-15																						//OS 3343-15
ElseIf  (SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(Substr(cGrupo,1,3)) $ "101/102/104/107") .or. (SM0->M0_CODIGO $ "01/05/14" .And. cGrupo >= '201 ' .And. cGrupo <= '222Z' .And. cGrupo != '216B')
		cConta3 := "41501011"
		
//OS 3343-15 - Venda de Paletes - Berger 25.01.16
ElseIf (SM0->M0_CODIGO $ "01/05/14" .And. cGrupo == '216B')
		cConta3 := "41501001" 

//|Pontin / Facile - Tratamento para vendas eventuais de conta 4 - Effetivo 1520-17 |
ElseIf SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(SubStr(cGrupo,1,3)) $ "501" .And. SF4->F4_YCCONT == "530"
	cConta3 := "41501011" 

//|Pontin / Facile - Tratamento para vendas de oleo - Effetivo 2042-17 |
ElseIf SM0->M0_CODIGO $ "01/05/14" .And. Alltrim(SD2->D2_COD) $ "5010020"	//|Tania pediu para amarrar diretamente ao produto 5010020 |
	cConta3 := "41501005" 
	
//Gas Natural.
ElseIf (SUBSTR(SD2->D2_CF,2,3) == "102" .AND. !SD2->D2_TES $ '515/5B5' .AND. SM0->M0_CODIGO <> '07' .AND. SD2->D2_TP <> 'PA')
   DbSelectArea("SB1")
   cArqSB1 := Alias()
   cIndSB1 := IndexOrd()
   cRegSB1 := Recno()
   DbSetOrder(1)
   DbSeek(xFilial("SB1")+SD2->D2_COD)
   cConta3 := SB1->B1_CONTA   

// Marcelo Sousa / Facile - Tratamento empresa 06 filial 07 - OS 9190-18
Elseif (SM0->M0_CODIGO == '06' .AND. ALLTRIM(SM0->M0_CODFIL) == '07')
	cConta3 := "41101010000011"
          
EndIf          
     
//Volta area de Trabalho
If cArqSF4 <> ""
	dbSelectArea(cArqSF4)
	dbSetOrder(cIndSF4)
	dbGoTo(cRegSF4)
	RetIndex("SF4")
EndIf

If cArqSD2 <> ""
	dbSelectArea(cArqSD2)
	dbSetOrder(cIndSD2)
	dbGoTo(cRegSD2)
	RetIndex("SD2")
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

//Fecha area de trabalho temporaria
DbSelectArea("TRB3")
DbCloseArea("TRB3")

Return(cConta3)