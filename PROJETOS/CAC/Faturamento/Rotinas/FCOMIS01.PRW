#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE DEF_NAOPROC   "NAO PROC." //Texto p/ exibir registro nao processado

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ FCOMIS01 ³ Autor ³ FERNANDO ROCHA        ³ Data ³13/08/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ CALCULO DE COMISSAO                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ CAC			                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FCOMIS01()
Local aArea 	:= GetArea()
Local cCbPer
Local aButtons	:= {}

//Declaração de cVariable dos componentes
Private dGetDtFim  := CtoD(" ")
Private dGetDtIni  := CtoD(" ")
Private lCBMensal  := .T.
Private lCBQuinzen := .F.
Private lCBSemanal := .F.
Private lCBAtlas := .T.
Private lCBVendedor := .F.
Private cVendedor  := Space(TamSX3("A3_COD")[1])
Private cGetFilAte := cFilAnt
Private cGetFilDe  := cFilAnt
Private lReceb 	   := Nil

//Declaração de Variaveis Private dos Objetos
SetPrvt("oFont1","oFont2","oDlg1","oGrp1","oCBAtlas","oCBVendedor","oCBMensal","oCBQuinzenal","oCBSemanal","oGrp2","oSay1","oSay2")
SetPrvt("oGetDtIni","oGetDtFim","oGVend","oBtnCalc","oBtnCancela","oTBar","oTBtnBmp1","oTBtnBmp2","oTBtnBmp3","oGetFilAte","oGetFilDe")

//Privates da Rotina
Private bCalcCom
Private bSimCom
Private bCancela
Private cDNP := DEF_NAOPROC

//Carrega combo de sub-canais

//Definicao do Dialog e todos os seus componentes.
//oDlg1      := MSDialog():New( 095,232,323,600,"Cálculo de Comissões de Contratos",,,.F.,,,,,,.T.,,,.T. )

DEFINE MSDIALOG oDlg1 TITLE "Cálculo de Comissões" FROM 095,232 TO 400	,800 PIXEL OF oMainWnd //"Atendimento"

oGrp3      	:= TGroup():New( 005,002,035,182,"Processo:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oCBAtlas  	:= TCheckBox():New( 019,007,"Atlas",{|u| If(PCount()>0,lCBAtlas:=u,lCBAtlas)},oGrp3,040,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBVendedor := TCheckBox():New( 019,057,"Vendedor",{|u| If(PCount()>0,lCBVendedor:=u,lCBVendedor)},oGrp3,040,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

oGrp1      := TGroup():New( 036,002,066,182,"Período de Apuração",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oCBMensal  := TCheckBox():New( 050,007,"Mensal",{|u| If(PCount()>0,lCBMensal:=u,lCBMensal)},oGrp1,040,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBQuinzen := TCheckBox():New( 050,057,"Quinzenal",{|u| If(PCount()>0,lCBQuinzenal:=u,lCBQuinzenal)},oGrp1,040,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
oCBSemanal := TCheckBox():New( 050,107,"Semanal",{|u| If(PCount()>0,lCBSemanal:=u,lCBSemanal)},oGrp1,040,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

oGrp2      := TGroup():New( 067,002,124,182,"Filtros:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oSayFilAte := TSay():New( 075,096,{||"Até:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,009)
oSayFilDe  := TSay():New( 075,007,{||"Filial De:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,009)
oSay1      := TSay():New( 091,007,{||"Data Inicial:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2      := TSay():New( 091,096,{||"Data Final:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( 0106,007,{||"Vendedor:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGetFilDe  := TGet():New( 074,042,{|u| If(PCount()>0,cGetFilDe:=u,cGetFilDe)},oGrp2,045,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cGetFilDe",,)
oGetFilAte := TGet():New( 074,131,{|u| If(PCount()>0,cGetFilAte:=u,cGetFilAte)},oGrp2,045,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SM0","cGetFilAte",,)
oGetDtIni  := TGet():New( 090,042,{|u| If(PCount()>0,dGetDtIni:=u,dGetDtIni)},oGrp2,045,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGetDtIni",,)
oGetDtFim  := TGet():New( 090,131,{|u| If(PCount()>0,dGetDtFim:=u,dGetDtFim)},oGrp2,045,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGetDtFim",,)
oGVend 	   := TGet():New( 105,042,{|u| If(PCount()>0,cVendedor:=u,cVendedor)},oGrp2,045,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SA3","cVendedor",,)

//Funcoes dos botoes
bCancela := {|| oDlg1:End()}
bCalcCom := {|| U_FC01CAL(cGetFilDe,cGetFilAte, dGetDtIni, dGetDtFim, cVendedor,,,,lCBAtlas) }
//bExcCom  := {|| U_FC01EXC(cGetFilDe,cGetFilAte, dGetDtIni, dGetDtFim, cVendedor) }

//AADD( aButtons, {'SIMULACA', bCalcCom, "Cálcular comissão"} )
//AADD( aButtons, {'EXCLUIR', bExcCom, "Consultar/Excluir Comissao"} )

TButton():Create( oDlg1,130,002,"Processar",bCalcCom,60,10,,,,.T.,,,,,,)
//TButton():Create( oDlg1,130,072,"Consultar/Excluir",bExcCom,60,10,,,,.T.,,,,,,)
TButton():Create( oDlg1,130,072,"Fechar",{|| oDlg1:End() },60,10,,,,.T.,,,,,,)

//Funcoes dos Check-boxes
DataSug()
oCBAtlas:bChange  	:= {|| CBAtlasChk() 	}
oCBVendedor:bChange := {|| CBVendChk() 	}

oCBMensal:bChange  := {|| CBMensChk() 	}
oCBQuinzen:bChange := {|| CBQuinChk() 	}
oCBSemanal:bChange := {|| CBSemChk() 	}

//oDlg1:bInit := {|| EnchoiceBar(oDlg1, {|| oDlg1:End() },{|| oDlg1:End() },,aButtons)}
oDlg1:Activate(,,,.T.)

//ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1, {|| oDlg1:End() }, {|| oDlg1:End() },,aButtons))

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ -        ³ Autor ³ FERNANDO ROCHA        ³ Data ³20/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ FUNCOES DE CONTROLE DE CHECK-BOXES DE PERIODO E DATAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ ORTHOHEAD                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CBAtlasChk()
lCBVendedor := !lCBAtlas

oCBAtlas:Refresh()
oCBVendedor:Refresh()
oDlg1:Refresh()
Return

Static Function CBVendChk()
lCBAtlas := !lCBVendedor

oCBAtlas:Refresh()
oCBVendedor:Refresh()
oDlg1:Refresh()
Return


Static Function CBMensChk()
IF lCBMensal
	lCBQuinzen := .F.
	lCBSemanal := .F.
ELSE
	lCBMensal  := .T.
ENDIF
oCBMensal:Refresh()
oCBQuinzen:Refresh()
oCBSemanal:Refresh()
oDlg1:Refresh()
DataSug()
Return

Static Function CBQuinChk()
IF lCBQuinzen
	lCBMensal := .F.
	lCBSemanal := .F.
ELSE
	lCBQuinzen  := .T.
ENDIF
oCBMensal:Refresh()
oCBQuinzen:Refresh()
oCBSemanal:Refresh()
oDlg1:Refresh()
DataSug()
Return

Static Function CBSemChk()
IF lCBSemanal
	lCBMensal := .F.
	lCBQuinzen := .F.
ELSE
	lCBSemanal  := .T.
ENDIF
oCBMensal:Refresh()
oCBQuinzen:Refresh()
oCBSemanal:Refresh()
oDlg1:Refresh()
DataSug()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//CALCULAR SUGESTAO DE DATAS AO TROCAR CHECK DE PERIODO
Considerando:
MENSAL =  SEMPRE O MES ANTERIOR COMPLETO
QUINZENAL = SEMPRE A ULTIMA QUIZENA COMPLETA - DE 1 a 15  /  ou 16 a Fim do Mes
SEMANAL = SEMPRE A ULTIMA SEMANA COMPLETA - DE SEGUNDA A DOMINGO
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DataSug()
Local nAno,nMes,nDia
Local dDataIni, dDataFim
Local I

DO CASE
	CASE lCBMensal
		
		If Month(dDataBase) > 1
			nAno := Year(dDataBase)
			nMes := Month(dDataBase)-1
		Else
			nAno := Year(dDataBase)-1
			nMes := 12
		Endif
		dDataIni := STOD(StrZero(nAno,4)+StrZero(nMes,2)+StrZero(1,2))
		dDataFim := UltimoDia(dDataIni)
		
	CASE lCBQuinzen
		
		If Day(dDataBase) >= 16
			nAno := Year(dDataBase)
			nMes := Month(dDataBase)
			dDataIni := STOD(StrZero(nAno,4)+StrZero(nMes,2)+StrZero(1,2))
			dDataFim := STOD(StrZero(nAno,4)+StrZero(nMes,2)+StrZero(15,2))
		Else
			If Month(dDataBase) > 1
				nAno := Year(dDataBase)
				nMes := Month(dDataBase)-1
			Else
				nAno := Year(dDataBase)-1
				nMes := 12
			Endif
			dDataIni := STOD(StrZero(nAno,4)+StrZero(nMes,2)+StrZero(16,2))
			dDataFim := UltimoDia(dDataIni)
		EndIf
		
	CASE lCBSemanal
		
		dDataFim := dDataBase-1
		nDia := Dow(dDataFim)
		While nDia <> 1
			dDataFim--
			nDia := Dow(dDataFim)
		EndDo
		dDataIni := dDataFim - 6
		
ENDCASE

dGetDtFim := dDataFim
dGetDtIni := dDataIni
oGetDtFim:Refresh()
oGetDtIni:Refresh()
oDlg1:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³ FC01CAL  ³ Autor ³ FERNANDO ROCHA        ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Carregar Browse de contratos/vendedores a serem calculados  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ ORTHOHEAD                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FC01CAL(_cFilDe,_cFilAte,_dDataIni, _dDataFim, _cVendedor, _lVisual, _cIdProc, _lGerPC, _lAtlas)
Local aCampos		:= {}
Local cCondicao		:= ""
Local _stru,cArq,cIND1,cIND2

Default _lVisual := .F.
Default _cIdProc := ""
Default _lGerPC  := .F.
Default _lAtlas  := .T.

//Privates da Rotina
Private aRotina		:= {}
Private cCadastro	:= "NF X Vendedor - Cálculo de Comissão"
Private cMarca 		:= GetMark()
Private lMarkAll	:= .F.

Private cXAlias 		:= "TRBCOM"
Private cXAlias2		:= "TRBCOM2"
Private cXAlias3		:= "TRBCOM3"

Private lGerPC      := _lGerPC

//Paramentro filtro
Private cFilDe			:= _cFilDe
Private cFilAte			:= _cFilAte
Private dDataIni		:= _dDataIni
Private dDataFim		:= _dDataFim
Private cVendedor		:= _cVendedor
Private lAtlas			:= _lAtlas

IF !lAtlas .And. Empty(cVendedor)
	MsgAlert("Para cálculo de comissão do Vendedor é obrigado a informar o código do vendedor","CAC - Comissão")
	return
ENDIF

//Botoes do browse
AADD(aRotina,{"Vis.Pedido"  		,"U_FC01VPV"  			,0,2})
AADD(aRotina,{"Vis.NF"  			,"U_FC01VNF"  			,0,2})
//AADD(aRotina,{"Troca Vendedor"	,"U_FC01TVD"  			,0,2})
//AADD(aRotina,{"Rpc.Comis.NF" 		,"U_FC01PAC()"  		,0,4})
AADD(aRotina,{"Processar" 	   		,"U_FC01PRO(.F.)"  		,0,4})
AADD(aRotina,{"Gerar Comissão" 		,"U_FC01GCO()"  		,0,4})

IF lAtlas
	AADD(aRotina,{"Gerar Ped.Atlas"		,"U_FC01GCP()"    	,0,4})
ENDIF

//Criar arquivo de trabalho
_stru:={}
AADD(_stru,{"MARCA"     	,"C", Len(cMarca),0})
AADD(_stru,{"F2_EMISSAO"	,"D", 8,0})
AADD(_stru,{"C6_YPEDATL"	,"C", 10,0})
AADD(_stru,{"F2_DOC" 		,"C", TamSx3("F2_DOC")[1],0})
AADD(_stru,{"F2_SERIE"  	,"C", TamSx3("F2_SERIE")[1],0})
AADD(_stru,{"A1_NOME" 		,"C", 20,0})
AADD(_stru,{"C5_VEND1" 		,"C", TamSx3("F2_VEND1")[1],0})
AADD(_stru,{"A3_NOME"   	,"C", 20,0})
AADD(_stru,{"B1_GRUPO"		,"C", TamSx3("B1_GRUPO")[1],0})
AADD(_stru,{"B1_DESC"		,"C", 20,0})

AADD(_stru,{"F2_COND"  		,"C", TamSx3("F2_COND")[1],0})
AADD(_stru,{"E4_COND"  		,"C", TamSx3("E4_COND")[1],0})
AADD(_stru,{"D2_ITEM"  		,"C", 2,0})
AADD(_stru,{"D2_COD"  		,"C", 10,0})

AADD(_stru,{"D2_TOTAL"		,"N", TamSx3("D2_TOTAL")[1],TamSx3("D2_TOTAL")[2]})
AADD(_stru,{"C6_YIPIATL"	,"N", TamSx3("C6_YIPIATL")[1],TamSx3("C6_YIPIATL")[2]})
AADD(_stru,{"C6_YVALNET"	,"N", TamSx3("C6_YVALNET")[1],TamSx3("C6_YVALNET")[2]})

AADD(_stru,{"PARCELA" 		,"C", TamSx3("E1_PARCELA")[1],0})
AADD(_stru,{"VALPARC"		,"N", TamSx3("E1_VALOR")[1],TamSx3("E1_VALOR")[2]})
AADD(_stru,{"VENCTO"		,"D", 8,0})

AADD(_stru,{"BASEIT"		,"N", TamSx3("E3_BASE")[1],TamSx3("E3_BASE")[2]})
AADD(_stru,{"PCOMIT"		,"N", TamSx3("E3_PORC")[1],TamSx3("E3_PORC")[2]})
AADD(_stru,{"PCOMIT2"		,"N", TamSx3("E3_PORC")[1],TamSx3("E3_PORC")[2]})

AADD(_stru,{"E3_PREFIXO"	,"C", TamSx3("E3_PREFIXO")[1],0})
AADD(_stru,{"E3_BASE"		,"N", TamSx3("E3_BASE")[1],TamSx3("E3_BASE")[2]})
AADD(_stru,{"E3_PORC"		,"N", TamSx3("E3_PORC")[1],TamSx3("E3_PORC")[2]})
AADD(_stru,{"E3_COMIS"		,"N", TamSx3("E3_COMIS")[1],TamSx3("E3_COMIS")[2]})

AADD(_stru,{"PVEND"			,"N", TamSx3("E3_PORC")[1],TamSx3("E3_PORC")[2]})
AADD(_stru,{"GERAVD"		,"C", 3,0})  // Indiciar se gerou comissao do vendedor

//AADD(_stru,{"MARG"	,"C", 2,0})//Campo xumbado pois o markbrow estava cortando a ultima coluna

cArq:=Criatrab(_stru,.T.)
If Select(cXAlias) > 0; (cXAlias)->(DbCloseArea()); EndIf
DBUSEAREA(.t.,,carq,cXAlias)

//Criar indice no arquivo de trabalho
_cInd1 :=Criatrab(nil,.F.)
cIND1 := DbCreateIndex(_cInd1,"F2_DOC+D2_ITEM")
(cXAlias)->(DbCommit())
DbSetIndex(_cInd1)
(cXAlias)->(DbSetOrder(1))

//Arquivo auxiliar clone
cArq:=Criatrab(_stru,.T.)
If Select(cXAlias2) > 0; (cXAlias2)->(DbCloseArea()); EndIf
DBUSEAREA(.t.,,carq,cXAlias2)

cArq:=Criatrab(_stru,.T.)
If Select(cXAlias3) > 0; (cXAlias3)->(DbCloseArea()); EndIf
DBUSEAREA(.t.,,carq,cXAlias3)

//Consulta SQL e preenchimento do arquivo de trabalho para browse
LjMsgRun("Consultando dados...",, {|| BCN9Proc()  })

//Campos para exibicao no browse
IF !_lVisual
	AADD(aCampos,{"MARCA"			,,""					, "" })
ENDIF

AADD(aCampos,{"F2_EMISSAO"		,,"Emissao"			, "" })
AADD(aCampos,{"C6_YPEDATL"		,,"Ped.Atlas"		, "@!" })
AADD(aCampos,{"F2_DOC"			,,"NF"				, "@!" })
AADD(aCampos,{"F2_SERIE"		,,"Serie"			, "@!" })
AADD(aCampos,{"A1_NOME"			,,"Cliente"			, "@S20" })
AADD(aCampos,{"C5_VEND1"		,,"Vend."			, "@!" })
AADD(aCampos,{"A3_NOME"			,,"Nome Vend."		, "@S20" })
AADD(aCampos,{"B1_GRUPO"		,,"Grupo"			, "@!" })
AADD(aCampos,{"B1_DESC"			,,"Produto"			, "@!" })
AADD(aCampos,{"F2_COND"			,,"CPg"			    , "@!" })
AADD(aCampos,{"E4_COND"			,,"Desc.CPg"	    , "@!" })
AADD(aCampos,{"D2_ITEM"			,,"Item"			, "@!" })
AADD(aCampos,{"D2_COD"			,,"Produto"			, "@!" })

AADD(aCampos,{"D2_TOTAL"		,,"Valor NF"		, "@E 99,999,999.99" })
AADD(aCampos,{"C6_YIPIATL"		,,"IPI Atlas"		, "@E 999,999.99" })
AADD(aCampos,{"C6_YVALNET"		,,"Valor Net"		, "@E 99,999,999.99" })

AADD(aCampos,{"PARCELA"	   		,,"Parc."			, "@!" })
AADD(aCampos,{"VALPARC"	   		,,"Vl.Parc"			, "@E 99,999,999.99" })
AADD(aCampos,{"VENCTO"	   		,,"Vencto"			, "" })

AADD(aCampos,{"BASEIT"			,,"Base It."		, "@E 999,999.99" })
AADD(aCampos,{"PCOMIT"			,,"%.Venda"			, "@E 999.99" })
AADD(aCampos,{"PCOMIT2"			,,"%.Partida"		, "@E 999.99" })

AADD(aCampos,{"E3_PREFIXO"		,,"Tipo.Com"		, "@!" })
AADD(aCampos,{"E3_BASE"			,,"Base.Com."		, "@E 999,999.99" })
AADD(aCampos,{"E3_PORC"			,,"Perc.Com."		, "@E 999.99" })
AADD(aCampos,{"E3_COMIS"		,,"Valor.Com." 		, "@E 99,999.99" })

If !lAtlas
	AADD(aCampos,{"PVEND"			,,"%.Vendedor"		, "@E 999.99" })
	AADD(aCampos,{"GERAVD"			,,"P.Vendedor?" 	, "@!" })
EndIf

//Chama o Markbrowse
(cXAlias)->(DbSetOrder(1))
(cXAlias)->(DbGoTop())

FilBrowse(cXAlias,{},cCondicao)

MarkBrow(cXAlias,"MARCA",,aCampos,.F.,cMarca,"U_MarkAll()",,,,"U_Mark()")

Return

// Grava marca no campo
User Function Mark()
If (cXAlias)->MARCA == cMarca
	RecLock(cXAlias, .F. )
	Replace MARCA With Space(Len((cXAlias)->MARCA))
	MsUnLock()
Else
	IF (lAtlas .And. Empty((cXAlias)->E3_PREFIXO));
		.Or. (!lAtlas .And. Empty((cXAlias)->GERAVD))
	
		RecLock(cXAlias, .F. )
		Replace MARCA With cMarca
		MsUnLock()
	
	ENDIF
EndIf
MARKBREFRESH()
Return

// Grava marca em todos os registros validos
User Function MarkAll()
Local nRecno := Recno()
dbSelectArea(cXAlias)
dbGotop()
While !Eof()
	RecLock(cXAlias, .F. )
	IF lMarkAll
		Replace MARCA With Space(Len((cXAlias)->MARCA))
	ELSE
		IF (lAtlas .And. Empty((cXAlias)->E3_PREFIXO));
		.Or. (!lAtlas .And. Empty((cXAlias)->GERAVD))
		
			Replace MARCA With cMarca
		
		ENDIF
	ENDIF
	MsUnLock()
	dbSkip()
End
lMarkAll := !lMarkAll
dbGoto( nRecno )
MARKBREFRESH()
Return

Static Function BCN9Proc(_lRep)

Local cARQ
Local cWhere
Local I
Local cExpWhere
Local cSQL := ""
Local cCmpVen, cCmpCom, cCmpOrd
Local cXAliasAux
Local _cParc


Default _lRep := .F.  //Reprocessar consulta

If Select("QRY") > 0; QRY->(DbCloseArea()); EndIf

//Apaga o arquivo de trabalho para refazer a consulta
IF _lRep
	(cXAlias)->(DbGoTop())
	While .Not. (cXAlias)->(Eof())
		RecLock(cXAlias,.F.)
		(cXAlias)->(DbDelete())
		(cXAlias)->(MsUnlock())
		(cXAlias)->(DbSkip())
	EndDo
	
	(cXAlias2)->(DbGoTop())
	While .Not. (cXAlias2)->(Eof())
		RecLock(cXAlias2,.F.)
		(cXAlias2)->(DbDelete())
		(cXAlias2)->(MsUnlock())
		(cXAlias2)->(DbSkip())
	EndDo
	
	(cXAlias3)->(DbGoTop())
	While .Not. (cXAlias3)->(Eof())
		RecLock(cXAlias3,.F.)
		(cXAlias3)->(DbDelete())
		(cXAlias3)->(MsUnlock())
		(cXAlias3)->(DbSkip())
	EndDo
	
ENDIF


cSQL := " SELECT "+CRLF
cSQL += " F2_EMISSAO, "+CRLF
cSQL += " C6_YPEDATL, "+CRLF
cSQL += " F2_DOC, "+CRLF
cSQL += " F2_SERIE, "+CRLF
cSQL += " A1_NOME, "+CRLF
cSQL += " C5_VEND1, "+CRLF
cSQL += " A3_NOME, "+CRLF
cSQL += " F2_COND, "+CRLF
cSQL += " E4_COND, "+CRLF
cSQL += " D2_ITEM, "+CRLF
cSQL += " D2_COD, "+CRLF
cSQL += " B1_GRUPO, "+CRLF
cSQL += " B1_DESC, "+CRLF
cSQL += " D2_TOTAL, "+CRLF
cSQL += " C6_YIPIATL, "+CRLF
cSQL += " C6_YVALNET "+CRLF

cSQL += " FROM SCJ010 SCJ "+CRLF
cSQL += " JOIN SCK010 SCK ON CK_FILIAL = CJ_FILIAL AND CK_NUM = CJ_NUM "+CRLF
cSQL += " JOIN SC6010 SC6 ON C6_FILIAL = CK_FILIAL AND C6_NUMORC = CK_NUM+CK_ITEM "+CRLF
cSQL += " JOIN SC5010 SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM "+CRLF
cSQL += " JOIN SD2010 SD2 ON D2_FILIAL = C6_FILIAL AND D2_DOC = C6_NOTA AND D2_SERIE = C6_SERIE AND D2_ITEMPV = C6_ITEM AND D2_PEDIDO = C6_NUM "+CRLF
cSQL += " JOIN SF2010 SF2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE "+CRLF
cSQL += " JOIN SA3010 SA3 ON A3_COD = C5_VEND1 "+CRLF
cSQL += " JOIN SA1010 SA1 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI "+CRLF
cSQL += " JOIN SE4010 SE4 ON E4_CODIGO = F2_COND "+CRLF
cSQL += " JOIN SB1010 SB1 ON B1_COD = D2_COD "+CRLF

cSQL += " WHERE
cSQL += " SF2.F2_EMISSAO BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "+CRLF
cSQL += " AND SF2.F2_SERIE = '900' "+CRLF

IF !Empty(cVendedor)
	cSQL += " AND SC5.C5_VEND1 = '"+cVendedor+"' "+CRLF
ENDIF

cSQL += " AND SCJ.D_E_L_E_T_ = '' "+CRLF
cSQL += " AND SCK.D_E_L_E_T_ = '' "+CRLF
cSQL += " AND SC6.D_E_L_E_T_ = '' "+CRLF
cSQL += " AND SC5.D_E_L_E_T_ = '' "+CRLF
cSQL += " AND SD2.D_E_L_E_T_ = '' "+CRLF
cSQL += " AND SF2.D_E_L_E_T_ = '' "+CRLF
cSQL += " AND SA1.D_E_L_E_T_ = '' "+CRLF
cSQL += " AND SA3.D_E_L_E_T_ = '' "+CRLF
cSQL += " AND SE4.D_E_L_E_T_ = '' "+CRLF

cSQL += " ORDER BY "+CRLF
cSQL += "	F2_DOC "+CRLF

MemoWrite("\SQLPCOM.TXT",cSQL)
cSQL := ChangeQuery(cSQL)
TcQuery cSQL New Alias "QRY"

TCSetField("QRY","F2_EMISSAO","D")

//Adiciona dados da consulta - cliente direto - no arquivo
DbSelectArea(cXAlias)
Append from QRY
QRY->(DbCloseArea())

//Preechimento de campos padroes arquivo de trabalho
(cXAlias)->(DbGoTop())
While .Not. (cXAlias)->(Eof())
	
cXAliasAux := GetNextAlias()
	BeginSql Alias cXAliasAux
		SELECT TOP 1 * FROM SZ0010 WHERE %EXP:(cXAlias)->B1_GRUPO% >= Z0_GRUINI AND %EXP:(cXAlias)->B1_GRUPO% <= Z0_GRUFIM AND D_E_L_E_T_=''
	EndSql
	(cXAliasAux)->(DbGoTop())
	
	If (cXAliasAux)->(Eof())
		MsgAlert("Produto: "+(cXAlias)->D2_COD+" Sem parametros de COMISSÃO!!!","ATENÇÃO - CADASTRO DE PARAMETROS DE COMISSÃO")
		(cXAlias)->(DbSkip())
		loop
	EndIf
	
	_nValTot := (cXAlias)->D2_TOTAL
	
	If (cXAliasAux)->Z0_TIPCOM == "1"
		_nValTot := (cXAlias)->C6_YVALNET
	Else
		_nValTot := (cXAlias)->D2_TOTAL - (cXAlias)->C6_YIPIATL
	EndIf
	
	//Comissao pelo recebimento - Abrir as parcelas da condicao
	If (cXAliasAux)->Z0_COMPAG == "2"
		
		_aVenc := Condicao(_nValTot,(cXAlias)->F2_COND,,(cXAlias)->F2_EMISSAO)
		_aAux := {}
		
		_cParc := "1"
		For I := 1 To Len(_aVenc)
			
			If I == 1
				
				_aAux := {(cXAlias)->F2_EMISSAO,(cXAlias)->C6_YPEDATL,(cXAlias)->F2_DOC,(cXAlias)->F2_SERIE,(cXAlias)->A1_NOME,(cXAlias)->C5_VEND1,(cXAlias)->A3_NOME,(cXAlias)->B1_GRUPO,(cXAlias)->B1_DESC,(cXAlias)->F2_COND,;
				(cXAlias)->E4_COND,(cXAlias)->D2_ITEM,(cXAlias)->D2_COD,(cXAlias)->D2_TOTAL,(cXAlias)->C6_YIPIATL,(cXAlias)->C6_YVALNET}
				
				RecLock(cXAlias,.F.)
				
				(cXAlias)->PARCELA 	:= _cParc
				(cXAlias)->VALPARC 	:= _aVenc[I][2]
				(cXAlias)->VENCTO	:= _aVenc[I][1]
				
				(cXAlias)->(MsUnLock())
				
				AtuComissao(cXAlias)
				
			Else
				
				RecLock(cXAlias2,.T.)
				
				(cXAlias2)->F2_EMISSAO 	:= _aAux[1]
				(cXAlias2)->C6_YPEDATL 	:= _aAux[2]
				(cXAlias2)->F2_DOC 		:= _aAux[3]
				(cXAlias2)->F2_SERIE 	:= _aAux[4]
				(cXAlias2)->A1_NOME 	:= _aAux[5]
				(cXAlias2)->C5_VEND1 	:= _aAux[6]
				(cXAlias2)->A3_NOME 	:= _aAux[7]
				(cXAlias2)->B1_GRUPO 	:= _aAux[8]
				(cXAlias2)->B1_DESC 	:= _aAux[9]
				(cXAlias2)->F2_COND 	:= _aAux[10]
				(cXAlias2)->E4_COND 	:= _aAux[11]
				(cXAlias2)->D2_ITEM		:= _aAux[12]
				(cXAlias2)->D2_COD 		:= _aAux[13]
				(cXAlias2)->D2_TOTAL 	:= _aAux[14]
				(cXAlias2)->C6_YIPIATL 	:= _aAux[15]
				(cXAlias2)->C6_YVALNET 	:= _aAux[16]
				
				(cXAlias2)->PARCELA		:= _cParc
				(cXAlias2)->VALPARC		:= _aVenc[I][2]
				(cXAlias2)->VENCTO		:= _aVenc[I][1]
				
				(cXAlias2)->(MsUnLock())
				
				AtuComissao(cXAlias2)
				
			EndIf
			
			_cParc := Soma1(_cParc,1)
			
		Next I
		
		//Comissao pelo Faturamento
	Else
		
		RecLock(cXAlias,.F.)
		(cXAlias)->PARCELA 	:= "1"
		(cXAlias)->VALPARC 	:= _nValTot
		(cXAlias)->VENCTO	:= (cXAlias)->F2_EMISSAO
		(cXAlias)->(MsUnLock())
		
		AtuComissao(cXAlias)
		
	EndIf
	
	(cXAlias)->(DbSkip())
EndDo

(cXAlias2)->(DbGoTop())
(cXAlias3)->(DbGoTop())

DbSelectArea(cXAlias)
Append from (cXAlias2)
Append from (cXAlias3)

//Se for calculo de vendedor - só  trazer as comissoes já geradas para a ATLAS
If !lAtlas
	
	//Calcular o total do periodo de competencia  (so pode ter um vendedor filtrado)
	__nTotComp := 0
	(cXAlias)->(DbGoTop())
	While !(cXAlias)->(Eof())
		If !Empty((cXAlias)->E3_PREFIXO) .And. (cXAlias)->E3_PREFIXO == "FAT"
			__nTotComp += (cXAlias)->VALPARC
		EndIf
		(cXAlias)->(DbSkip())
	EndDo
	
	(cXAlias)->(DbGoTop())
	While !(cXAlias)->(Eof())
		
		If Empty((cXAlias)->E3_PREFIXO)
			
			RecLock(cXAlias,.F.)
			(cXAlias)->(DbDelete())
			(cXAlias)->(MsUnlock())
			
		Else
			
			//Buscar o percentual de comissão do Vendedor
			cXAliasAux := GetNextAlias()
			BeginSql Alias cXAliasAux
				SELECT TOP 1 Z1_COMIS FROM SZ1010 WHERE Z1_VALTOT >= %EXP:__nTotComp% AND D_E_L_E_T_=''
			EndSql
			(cXAliasAux)->(DbGoTop())
			
			If !(cXAliasAux)->(Eof())
				RecLock(cXAlias,.F.)
				(cXAlias)->PVEND := (cXAliasAux)->Z1_COMIS
				(cXAlias)->(MsUnlock())
			EndIf
			(cXAliasAux)->(DbCloseArea())
			
		EndIf
		
		(cXAlias)->(DbSkip())
	EndDo
EndIf

DbSelectArea(cXAlias)
(cXAlias)->(DbGoTop())

Return

Static Function AtuComissao(_cXAliasOri)

//Posicionando registro de Comissao se ja tiver gerado - comissao sobre a venda
SE3->(DbSetOrder(1))
If SE3->(DbSeek(XFilial("SE3")+"FAT"+(_cXAliasOri)->(F2_DOC+PARCELA+D2_ITEM)))
	
	RecLock(_cXAliasOri,.F.)
	(_cXAliasOri)->E3_PREFIXO 	:= SE3->E3_PREFIXO
	(_cXAliasOri)->E3_BASE 		:= SE3->E3_BASE
	(_cXAliasOri)->E3_PORC		:= SE3->E3_PORC
	(_cXAliasOri)->E3_COMIS		:= SE3->E3_COMIS
	
	If !lAtlas .And. SE3->(DbSeek(XFilial("SE3")+"FAT"+(_cXAliasOri)->(F2_DOC+PARCELA+D2_ITEM+cVendedor)))
		(_cXAliasOri)->GERAVD := "S"
	EndIf
	
	(_cXAliasOri)->(MsUnLock())
	
EndIf

//Posicionando registro de Comissao se ja tiver gerado - comissao partida tecnica
SE3->(DbSetOrder(1))
If SE3->(DbSeek(XFilial("SE3")+"PTE"+(_cXAliasOri)->(F2_DOC+PARCELA+D2_ITEM)))
	
	RecLock(cXAlias3,.T.)
	
	(cXAlias3)->F2_EMISSAO 	:= (_cXAliasOri)->F2_EMISSAO
	(cXAlias3)->C6_YPEDATL 	:= (_cXAliasOri)->C6_YPEDATL
	(cXAlias3)->F2_DOC 		:= (_cXAliasOri)->F2_DOC
	(cXAlias3)->F2_SERIE 	:= (_cXAliasOri)->F2_SERIE
	(cXAlias3)->A1_NOME 	:= (_cXAliasOri)->A1_NOME
	(cXAlias3)->C5_VEND1 	:= (_cXAliasOri)->C5_VEND1
	(cXAlias3)->A3_NOME 	:= (_cXAliasOri)->A3_NOME
	(cXAlias3)->B1_GRUPO 	:= (_cXAliasOri)->B1_GRUPO
	(cXAlias3)->B1_DESC 	:= (_cXAliasOri)->B1_DESC
	(cXAlias3)->F2_COND 	:= (_cXAliasOri)->F2_COND
	(cXAlias3)->E4_COND 	:= (_cXAliasOri)->E4_COND
	(cXAlias3)->D2_ITEM 	:= (_cXAliasOri)->D2_ITEM
	(cXAlias3)->D2_COD 		:= (_cXAliasOri)->D2_COD
	(cXAlias3)->D2_TOTAL 	:= (_cXAliasOri)->D2_TOTAL
	(cXAlias3)->C6_YIPIATL 	:= (_cXAliasOri)->C6_YIPIATL
	(cXAlias3)->C6_YVALNET 	:= (_cXAliasOri)->C6_YVALNET
	(cXAlias3)->PARCELA 	:= (_cXAliasOri)->PARCELA
	(cXAlias3)->VALPARC 	:= (_cXAliasOri)->VALPARC
	(cXAlias3)->VENCTO		:= (_cXAliasOri)->VENCTO
	
	(cXAlias3)->E3_PREFIXO	:= SE3->E3_PREFIXO
	(cXAlias3)->E3_BASE 		:= SE3->E3_BASE
	(cXAlias3)->E3_PORC		:= SE3->E3_PORC
	(cXAlias3)->E3_COMIS		:= SE3->E3_COMIS
	
	If !lAtlas .And. SE3->(DbSeek(XFilial("SE3")+"PTE"+(_cXAliasOri)->(F2_DOC+PARCELA+D2_ITEM+cVendedor)))
		(cXAlias3)->GERAVD := "S"
	EndIf
	
	(cXAlias3)->(MsUnLock())
	
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³FC01PRO   ³ Autor ³ FERNANDO ROCHA        ³ Data ³29/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Processar arquivo de trabalhao para calculo de comissao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ ORTHOHEAD                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FC01PRO(_lGera)
Local lRet
LjMsgRun("Processando dados para comissão...",, {|| lRet := Processar(_lGera)  })
Return(lRet)

Static Function Processar(_lGera)
Local nValCtr
Local nCodVd
Local I,J
Local lNotPerc := .F.
Local lNotForn := .F.
Local nRet
Local aPessoa
Local cQryTmp
Local cTotProc
Local nPRed
Local cXAliasAux

Default _lGera := .F.   //Informar que esta sendo dispara pela geracao do SE3

//LER ARQUIVO DE TRABALHO E CRIAR MATRIZES
(cXAlias)->(DbGoTop())
While .Not. (cXAlias)->(Eof())
	
	IF ((cXAlias)->MARCA == cMarca)
		
		//Vendedor
		//nCodVd := (cXAlias)->VEND
		//Posiciona Arquivo do Vendedor
		//SA3->(DbSetOrder(1))
		//SA3->(DbSeek(XFilial("SA3")+nCodVd))
		
		
		cXAliasAux := GetNextAlias()
		BeginSql Alias cXAliasAux
			SELECT TOP 1 * FROM SZ0010 WHERE %EXP:(cXAlias)->B1_GRUPO% >= Z0_GRUINI AND %EXP:(cXAlias)->B1_GRUPO% <= Z0_GRUFIM AND D_E_L_E_T_=''
		EndSql
		(cXAliasAux)->(DbGoTop())
		
		If !(cXAliasAux)->(Eof())
			
			 
			nValCtr	:= (cXAlias)->VALPARC
			
			/*If (cXAliasAux)->Z0_TIPCOM == "1"
				nValCtr	:= Round((cXAlias)->VALPARC * (cXAliasAux)->Z0_INDNET,2)
			Else
				nValCtr	:= Round((cXAlias)->VALPARC - ((cXAlias)->C6_YIPIATL * ( (cXAlias)->VALPARC / (cXAlias)->D2_TOTAL )),2)
			EndIf*/
			
			//Atualiza arquivo de trabalho
			RecLock(cXAlias,.F.)
			(cXAlias)->BASEIT 		:= nValCtr
			(cXAlias)->PCOMIT 		:= (cXAliasAux)->Z0_COMVEN
			(cXAlias)->PCOMIT2 		:= (cXAliasAux)->Z0_COMPAR
			(cXAlias)->(MsUnlock())
			
			
		Else
			MsgAlert("Produto: "+(cXAlias)->D2_COD+" Sem parametros de COMISSÃO!!!","ATENÇÃO - CADASTRO DE PARAMETROS DE COMISSÃO")
			(cXAlias)->(DbSkip())
			loop
		EndIf
		
		(cXAliasAux)->(DbCloseArea())
		
	ENDIF
	
	(cXAlias)->(DbSkip())
EndDo

(cXAlias)->(DbGoTop())
MARKBREFRESH()

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³FC01GCO   ³ Autor ³ FERNANDO ROCHA        ³ Data ³05/09/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Gerar registros de comissoes no SE3                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³CAC			                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FC01GCO()
LjMsgRun("Gravando comissões SE3...",, {|| GerarSE3() })
Return()

Static Function GerarSE3()
Local aAuto
Local cPrefixo := GetNewPar("MV_3DUPREF","COM")
Local cIdProc
Local lGravouSE3 := .F.
Local cXAliasTmp
Local cSeq
Local dVencto
Local nValCtr
Local cFilOld
Local cXAliasAux
Local cVendAtl := GetNewPar("FC_VENDATL","900000")
Local cVendedor := ""

Private lMsErroAuto := .F.

//Refazer e validar calculo
IF !U_FC01PRO(.T.)
	MsgInfo("Geração de comissões cancelada!","CÁLCULO DE COMISSÃO")
	Return
ENDIF

IF Aviso('GERACAO DE COMISSOES',;
	'Tem certeza que deseja gerar as comissoes dos registros selecionados?',{'SIM','NAO'}) == 2
	Return
ENDIF

BEGIN TRANSACTION

SE3->(DbSetOrder(4))

//LER ARQUIVO DE TRABALHO PARA GERAR SE3
(cXAlias)->(DbGoTop())
While .Not. (cXAlias)->(Eof())
	
	cXAliasAux := GetNextAlias()
	BeginSql Alias cXAliasAux
		SELECT TOP 1 * FROM SZ0010 WHERE %EXP:(cXAlias)->B1_GRUPO% >= Z0_GRUINI AND %EXP:(cXAlias)->B1_GRUPO% <= Z0_GRUFIM AND D_E_L_E_T_=''
	EndSql
	(cXAliasAux)->(DbGoTop())
	
	If (cXAliasAux)->(Eof())
		MsgAlert("Produto: "+(cXAlias)->D2_COD+" Sem parametros de COMISSÃO!!!","ATENÇÃO - CADASTRO DE PARAMETROS DE COMISSÃO")
		(cXAlias)->(DbSkip())
		loop
	EndIf
	
	//Vendedor para comissao Atlas
	cVendedor := (cXAlias)->C5_VEND1
	If lAtlas
		cVendedor := cVendAtl
	EndIf
	
	SE3->(DbSetOrder(1))
	
	IF ((cXAlias)->MARCA == cMarca)
		
		If lAtlas
		
			//ATLAS - processa a comissao do faturamento e depois da partida tecnica
			
			For I := 1 To 2
				
				If (I == 1 .And. (cXAlias)->PCOMIT > 0) .Or. (I == 2 .And. (cXAlias)->PCOMIT2 > 0)
					
					//So gerar novamente se ainda nao foi gerado o SE3
					If (I == 1 .And. !SE3->(DbSeek(XFilial("SE3")+"FAT"+(cXAlias)->(F2_DOC+PARCELA+D2_ITEM+cVendedor))));
						.Or. (I == 2 .And. !SE3->(DbSeek(XFilial("SE3")+"PTE"+(cXAlias)->(F2_DOC+PARCELA+D2_ITEM+cVendedor))))
						
						//INCLUSAO AUTOMATICA - AJUSTANDO PARA VARIAS FILIAIS
						aAuto := {}
						aAdd(aAuto,{"E3_VEND"		,cVendedor								,Nil})
						aAdd(aAuto,{"E3_NUM"		,(cXAlias)->F2_DOC						,Nil})
						aAdd(aAuto,{"E3_SERIE"		,(cXAlias)->F2_SERIE					,Nil})
						aAdd(aAuto,{"E3_PARCELA"	,(cXAlias)->PARCELA						,Nil})
						
						aAdd(aAuto,{"E3_EMISSAO"	,dDataFim								,Nil})
						aAdd(aAuto,{"E3_CODCLI"		,(cXAliasAux)->Z0_CODCLI				,Nil})
						aAdd(aAuto,{"E3_LOJA"		,(cXAliasAux)->Z0_LOJCLI				,Nil})
						aAdd(aAuto,{"E3_BASE"		,(cXAlias)->BASEIT						,Nil})
						
						aAdd(aAuto,{"E3_PORC"		,IIF(I == 1,(cXAlias)->PCOMIT,(cXAlias)->PCOMIT2)		,Nil})
						aAdd(aAuto,{"E3_SEQ"		,(cXAlias)->D2_ITEM						,Nil})
						aAdd(aAuto,{"E3_PREFIXO"	,IIF(I == 1,"FAT","PTE")				,Nil})
						
						aAdd(aAuto,{"E3_TIPO"		,"DP"									,Nil})
						aAdd(aAuto,{"E3_VENCTO"		,(cXAlias)->VENCTO						,Nil})
						
						//Customizados SE3
						aAdd(aAuto,{"E3_YVDORI"		,(cXAlias)->C5_VEND1					,Nil})
						aAdd(aAuto,{"E3_YPROD"		,(cXAlias)->D2_COD						,Nil})
						
						MSExecAuto({|x,y| Mata490(x,y)},aAuto,3)
						IF lMsErroAuto
							DisarmTransaction()
							MostraErro()
							cFilAnt := cFilOld
							Return
						ENDIF
						
					EndIf
					
				EndIf
				
			Next I
			
		Else
			             
			//VENDEDOR - so processa as comissoes ja processada para a Atlas
			
			If ((cXAlias)->E3_PREFIXO == "FAT" .And. (cXAlias)->PCOMIT > 0) .Or. ((cXAlias)->E3_PREFIXO == "PTE" .And. (cXAlias)->PCOMIT2 > 0)
				
				//So gerar novamente se ainda nao foi gerado o SE3
				If ((cXAlias)->E3_PREFIXO == "FAT" .And. !SE3->(DbSeek(XFilial("SE3")+"FAT"+(cXAlias)->(F2_DOC+PARCELA+D2_ITEM+cVendedor))));
					.Or. ((cXAlias)->E3_PREFIXO == "PTE" .And. !SE3->(DbSeek(XFilial("SE3")+"PTE"+(cXAlias)->(F2_DOC+PARCELA+D2_ITEM+cVendedor))))
					                      
					
					//posiciona pedido
					SC6->(DbSetOrder(4))
					SC6->(DbSeek(XFilial("SC6")+(cXAlias)->F2_DOC+(cXAlias)->F2_SERIE))
					
					//INCLUSAO AUTOMATICA - AJUSTANDO PARA VARIAS FILIAIS
					aAuto := {}
					aAdd(aAuto,{"E3_VEND"		,cVendedor									,Nil})
					aAdd(aAuto,{"E3_NUM"		,(cXAlias)->F2_DOC							,Nil})
					aAdd(aAuto,{"E3_SERIE"		,(cXAlias)->F2_SERIE						,Nil})
					aAdd(aAuto,{"E3_PARCELA"	,(cXAlias)->PARCELA							,Nil})
					
					aAdd(aAuto,{"E3_EMISSAO"	,dDataFim									,Nil})
					aAdd(aAuto,{"E3_CODCLI"		,SC6->C6_CLI								,Nil})
					aAdd(aAuto,{"E3_LOJA"		,SC6->C6_LOJA								,Nil})
					aAdd(aAuto,{"E3_BASE"		,(cXAlias)->E3_COMIS						,Nil})
					
					aAdd(aAuto,{"E3_PORC"		,(cXAlias)->PVEND							,Nil})
					aAdd(aAuto,{"E3_SEQ"		,(cXAlias)->D2_ITEM							,Nil})
					aAdd(aAuto,{"E3_PREFIXO"	,(cXAlias)->E3_PREFIXO	  					,Nil})
					
					aAdd(aAuto,{"E3_TIPO"		,"DP"										,Nil})
					aAdd(aAuto,{"E3_VENCTO"		,(cXAlias)->VENCTO							,Nil})
					
					//Customizados SE3
					aAdd(aAuto,{"E3_YVDORI"		,(cXAlias)->C5_VEND1						,Nil})
					aAdd(aAuto,{"E3_YPROD"		,(cXAlias)->D2_COD							,Nil})
					
					MSExecAuto({|x,y| Mata490(x,y)},aAuto,3)
					IF lMsErroAuto
						DisarmTransaction()
						MostraErro()
						cFilAnt := cFilOld
						Return
					ENDIF
					
				EndIf
				
			EndIf
			
		EndIf
		
		lGravouSE3 := .T.
		
	ENDIF
	(cXAlias)->(DbSkip())
EndDo

END TRANSACTION

//ATUALIZA ARQUIVO DE TRABALHO E A TELA
BCN9Proc(.T.)
MARKBREFRESH()

(cXAlias)->(DbGoTop())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³FC01EXC  ³ Autor ³ FERNANDO ROCHA        ³ Data ³30/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Carregar Browse de processos de comissao para exclusao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ORTHOHEAD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FC01EXC(_cFilDe,_cFilAte,_dDataIni, _dDataFim, _cVendedor)
Local cCondicao		:= ""

//Privates da Rotina
Private aRotina		:= {}
Private cCadastro	:= "Contratos X Vendedor - Exclusão de Comissão"

//Paramentro filtro
Private cFilDe			:= _cFilDe
Private cFilAte			:= _cFilAte
Private dDataIni		:= _dDataIni
Private dDataFim		:= _dDataFim
Private cVendedor		:= _cVendedor

//Botoes do browse
AADD(aRotina,{"Vis.Comissoes"  	,"U_FC01VCM"  		,0,2})
AADD(aRotina,{"Excluir"  			,"U_FC01DEL"  		,0,4})

//Chama o MBrowse
SZI->(DbClearFilter())
SZI->(DbSetOrder(1))
SZI->(DbGoTop())

//Filtros do browse
cCondicao := "ZI_VEND == '"+PADR(cVendedor,TamSx3("ZI_VEND")[1])+"'"
cCondicao += ".And. ZI_FILDE >= '"+cFilDe+"'"
cCondicao += ".And. ZI_FILATE <= '"+cFilAte+"'"
cCondicao += ".And. DTOS(ZI_DATINI) >= '"+DTOS(dDataIni)+"'"
cCondicao += ".And. DTOS(ZI_DATFIM) <= '"+DTOS(dDataFim)+"'"

FilBrowse("SZI",{},cCondicao)

SZI->(MBrowse(6,1,22,75,"SZI",,,,,1,/*aCores*/))
SZI->(DbClearFilter())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
// DISPARAR A VISUALIZACAO DAS COMISSOES PELO BROWSE DE EXCLUSAO
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FC01VCM
U_FC01CAL(cGetFilDe,cGetFilAte, dGetDtIni, dGetDtFim, cVendedor,.T., SZI->ZI_IDPROC)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³GCT11EXC  ³ Autor ³ FERNANDO ROCHA        ³ Data ³23/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Excluir comissoes em aberto pelo log do processo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ ORTHOHEAD                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FC01DEL
IF  Aviso('EXCLUSAO DE COMISSOES',;
	'Tem certeza que deseja excluir todas as comissoes do processo selecionado?'+CRLF+;
	'Serão excluidas somente as comissoes que ainda estiverem em aberto.',{'SIM','NAO'}) == 2
	Return
ENDIF

LjMsgRun("Excluindo comissões SE3...",, {|| ExclSE3() })
Return()

Static Function ExclSE3()
Local nCont

Private lMsErroAuto := .F.

BEGIN TRANSACTION

If Select("QRY") > 0; QRY->(DbCloseArea()); EndIf
BeginSql Alias "QRY"
	
	SELECT * FROM %Table:SE3% SE3
	WHERE SE3.E3_YIDPROC = %Exp:SZI->ZI_IDPROC%
	AND SE3.E3_DATA = ' '
	AND SE3.%NotDel%
	
EndSql

While .Not. QRY->(Eof())
	
	SE3->(DbSetOrder(1))
	IF SE3->(DbSeek(QRY->(E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND)))
		RecLock("SE3",.F.)
		SE3->(DbDelete())
		SE3->(MsUnlock())
	ENDIF
	
	QRY->(DbSkip())
EndDo

//VERIFICA SE RESTOU ALGUM CALCULCO DE COMISSAO - SE3 - NO PROCESSO - CASO CONTRARIO APAGA O PROCESSO
If Select("QRY") > 0; QRY->(DbCloseArea()); EndIf
BeginSql Alias "QRY"
	
	SELECT * FROM %Table:SE3% SE3
	WHERE SE3.E3_YIDPROC = %Exp:SZI->ZI_IDPROC%
	AND SE3.%NotDel%
	
EndSql

IF QRY->(Eof())
	RecLock("SZI",.F.)
	SZI->(DbDelete())
	SZI->(MsUnlock())
ENDIF

QRY->(DbCloseArea())

END TRANSACTION

Return


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//VISUALIZAR NOTA FISCAL
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function FC01VNF
Local aArea := GetArea()

SD2->(DbSetOrder(3))
SD2->(DbSeek((cXAlias)->F2_FILIAL+(cXAlias)->F2_DOC+(cXAlias)->F2_SERIE))

//DbSelectArea("SF2")
//DbSetOrder(1)
//DbSeek((cXAlias)->F2_FILIAL+(cXAlias)->F2_DOC+(cXAlias)->F2_SERIE)

A920NFSAI("SD2",SD2->(RecNo()),0)

RestArea(aArea)
Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//VISUALIZAR PEDIDO DE VENDAS
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function FC01VPV
Local aArea := GetArea()

SD2->(DbSetOrder(3))
SD2->(DbSeek((cXAlias)->F2_FILIAL+(cXAlias)->F2_DOC+(cXAlias)->F2_SERIE))
SC5->(DbSetOrder(1))
SC5->(DbSeek(SD2->(D2_FILIAL+D2_PEDIDO)))
A410Visual('SC5',SC5->(RecNo()),2)

RestArea(aArea)
Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//TROCAR VENDEDOR DA NOTA FISCAL
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function FC01TVD
Local aArea := GetArea()
Local cPerg := "OM28TVEND"
Local nRet

ValPTV(cPerg)
_nChvDoc := (cXAlias)->(F2_FILIAL+F2_DOC+F2_SERIE)

IF !((cXAlias)->E3_YIDPROC == PADR(cDNP,TamSx3("E3_YIDPROC")[1]))
	MsgAlert("Não é possível trocar comissão de vendedor quando já está processada.","ATENÇÃO! - TROCA DE VENDEDOR P/ COMISSAO")
	Return
ENDIF

If !Empty(_nChvDoc)
	If !Pergunte(cPerg)
		Return
	EndIf
	
	SA3->(DbSetOrder(1))
	IF !SA3->(DbSeek(XFilial("SA3")+MV_PAR01))
		Return
	ENDIF
	
	nRet := Aviso("ATENÇÃO! - TROCA DE VENDEDOR P/ COMISSAO",;
	"Tem certeza que deseja TROCAR o vendedor da nota fiscal: "+CRLF+;
	">>> "+_nChvDoc+CRLF+;
	", E alterar a arvore de calculo de comissao para o novo vendedor ("+AllTrim(SA3->A3_NREDUZ)+")?"+CRLF+CRLF+;
	"Após este processo será necessário reiniciar a rotina com o novo vendedor a fim de conferir as comissões do mesmo.",{"OK","CANCELAR"})
	
	IF nRet == 2
		Return
	EndIf
	
	LjMsgRun("Aguarde, processando...",, {|| OTVDProc(_nChvDoc,SA3->A3_COD)  })
	
	//ATUALIZA A TELA
	MARKBREFRESH()
	
EndIf

RestArea(aArea)
Return

Static Function OTVDProc(_nChvDoc,_cNewVend)

//TROCA VENDEDOR
U_TrocVend(_nChvDoc,_cNewVend)
//REPROCESSA ARVORE DE COMISSAO
U_PrComNF(_nChvDoc)
//ATUALIZA ARQUIVO DE TRABALHO
BCN9Proc(.T.)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao     ³FC01PAC   ³ Autor ³ FERNANDO ROCHA        ³ Data ³24/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³Processar arvore hierarquica de vendas e salvar dados no PV ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso        ³ORTHOHEAD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FC01PAC(_nOpc)
Local aArea := GetArea()
Local _nChvDoc
Local cTexto
Local nOpc

cTexto := "ESTA ROTINA VAI REPROCESSAR TODOS OS PERCENTUAIS DE COMISSAO"
cTexto += " DAS NOTAS FISCAIS DE ACORDO COM O CADASTRO DE VENDEDORES E REGRAS DE COMISSAO."+CRLF+CRLF
cTexto += "AS OPCOES SAO:"+CRLF+"<<SELEÇÃO>> SOMENTE A NF SELECIONADA"+CRLF+"<<TODAS>> TODAS NF DO PERIODO/VENDEDOR FILTRADOS."

//Pergunta de deseja atualizar vendedores e percentuais ja gravados no Faturamento
nOpc := Aviso("Processamento de Comissão",cTexto,{ "SELEÇÃO","TODAS","CANCELAR" },3)

IF nOpc == 3
	Return
EndIf

IF !MsgNoYes("TEM CERTEZA QUE DESEJA CONTINUAR A OPERAÇÃO SELECIONADA?","PROCESSAMENTO DE COMISSÃO - ATENÇÃO!")
	Return
ENDIF

RptStatus({|| PACProc(nOpc) },"Aguarde... Reprocessanso Comissões")

BCN9Proc(.T.)
MARKBREFRESH()

RestArea(aArea)
Return

Static Function PACProc(nOpc)
Local aVChvNF := {}
Local nCont := 0

IF nOpc == 1
	_nChvDoc := (cXAlias)->(F2_FILIAL+F2_DOC+F2_SERIE)
	U_PrComNF(_nChvDoc)
ELSEIF nOpc == 2
	(cXAlias)->(DbGoTop())
	
	While .Not. (cXAlias)->(Eof())
		_nChvDoc := (cXAlias)->(F2_FILIAL+F2_DOC+F2_SERIE)
		IF AScan(aVChvNF,{|x| x == _nChvDoc}) <= 0
			AAdd(aVChvNF,_nChvDoc)
			nCont++
		ENDIF
		(cXAlias)->(DbSkip())
	EndDo
	
	SetRegua(nCont)
	For I := 1 To Len(aVChvNF)
		U_PrComNF(aVChvNF[I])
		IncRegua()
	Next
ENDIF

Return


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//PROCESSAR ARVORE DE COMISSAO - SALVAR SUPERIORES E COMISSOES
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function PrComNF(_nChvDoc)
Local nPCom
Local cVend
Local aVendP := {}
Local nOrder := 1
Local cQryTmp
Local cProced := ""

SD2->(DbSetOrder(3))
SA3->(DbSetOrder(1))
SF2->(DbSetOrder(1))
SC5->(DbSetOrder(1))
SUA->(DbSetOrder(1))
SUC->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SZC->(DbSetOrder(1))


IF SD2->(DbSeek(_nChvDoc))
	
	BEGIN TRANSACTION
	
	While .Not. SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == _nChvDoc
		
		If !SF2->(DbSeek(_nChvDoc))
			exit
		EndIf
		
		IF !SC5->(DbSeek(SD2->D2_FILIAL+SD2->D2_PEDIDO))
			exit
		EndIf
		
		//Se vendedor principal vazio ou invalido nao processa comissao para a nota
		cVend := SF2->F2_VEND1
		If Empty(SF2->F2_VEND1)
			exit
		EndIf
		
		
		While SA3->(DbSeek(XFilial("SA3")+cVend))
			
			//Seguranca para nao processar vendedores em loop caso cadastro errado
			If AScan(aVendP,{|x| x == cVend}) > 0
				exit
			EndIf
			AAdd(aVendP, cVend)
			nPCom := 0
			
			//Procura percentual comissao do vendedor
			//Procura nas regras de excecao
			IF SUA->(DbSeek(XFilial("SUA")+SC5->C5_YCODTLV))
				SUC->(DbSetOrder(10))
				IF SUC->(DbSeek(XFilial("SUC")+SUA->UA_YEMPMAS+SUA->UA_YCODTMK))
					
					//Xumbado para fazer SUS = SESA
					_cConv := SUC->UC_YCONV
					_cConv := IIF(AllTrim(_cConv)=="SESA","SUS",SUC->UC_YCONV)
					
					
					//Procura nas regras de excecao de acordo com a ordem de prioridade
					cQryTmp := GetNextAlias()
					BeginSql Alias cQryTmp
						SELECT TOP 1 ZH_PCOM FROM SZH010 SZH
						WHERE
						SZH.D_E_L_E_T_<>'*'
						AND SZH.ZH_VEND = %Exp:cVend%
						AND ((SZH.ZH_ESPEC = %Exp:SUC->UC_YESPEC%) OR (SZH.ZH_ESPEC = %Exp:PADR('Z',TamSx3("ZH_ESPEC")[1],'Z')%))
						AND ((SZH.ZH_HOSP = %Exp:SUC->UC_YHOSP%) OR (SZH.ZH_HOSP = %Exp:PADR('Z',TamSx3("ZH_HOSP")[1],'Z')%))
						AND ((SZH.ZH_MEDI = %Exp:SUC->UC_YMEDI%) OR (SZH.ZH_MEDI = %Exp:PADR('Z',TamSx3("ZH_MEDI")[1],'Z')%))
						AND ((SZH.ZH_CONV = %Exp:_cConv%) OR (SZH.ZH_CONV = %Exp:PADR('Z',TamSx3("ZH_CONV")[1],'Z')%))
						ORDER BY ZH_VEND,ZH_ESPEC,ZH_HOSP,ZH_MEDI,ZH_CONV
					EndSql
					
					If !(cQryTmp)->(Eof())
						nPCom := (cQryTmp)->ZH_PCOM
					EndIf
					(cQryTmp)->(DbCloseArea())
					//Guarda procedimento do Agendamento para pesquisa por cadastros abaixo
					cProced := SUC->UC_YPROC
				EndIf
			ENDIF
			
			IF nPCom == 0 .And. !Empty(cProced)
				SZ2->(DbSetOrder(1))
				If SZ2->(DbSeek(XFilial("SZ2")+cProced)) .And. SZ2->Z2_PCOM > 0
					nPCom := SZ2->Z2_PCOM
				EndIf
			ENDIF
			
			IF nPCom == 0
				nPCom := SA3->A3_COMIS
			ENDIF
			
			//Procura cadastros: Produto / Fami@lia / Procedimento / Vendedor - Caso nao aja excecao
			IF nPCom == 0
				IF SB1->(DbSeek(XFilial("SB1")+SD2->D2_COD))
					IF SB1->B1_COMIS > 0
						nPCom := SB1->B1_COMIS
					ELSEIF SZC->(DbSeek(XFilial("SZC")+SB1->B1_YFAMILI)) .AND. SZC->ZC_PCOM > 0
						nPCom := SZC->ZC_PCOM
					ENDIF
				ENDIF
			ENDIF
			
			//FILTRAR CLIENTES QUE NAO CALCULAM COMISSAO
			IF AllTrim(SD2->D2_CLIENTE) $ AllTrim(GetMV("MV_YCLINCO"))
				nPCom := 0
			ENDIF
			
			//Grava percentual de comissao encontrado no SD2 e SC5
			If nPCom >= 0
				RecLock("SD2",.F.)
				&("SD2->D2_COMIS"+AllTrim(Str(nOrder))) := nPCom
				SD2->(MsUnlock())
				//////
				RecLock("SC5",.F.)
				&("SC5->C5_COMIS"+AllTrim(Str(nOrder))) := nPCom
				SC5->(MsUnlock())
			EndIf
			
			//Grava os vendedores superiores no PV e NF
			If nOrder > 1
				RecLock("SC5",.F.)
				&("SC5->C5_VEND"+AllTrim(Str(nOrder))) := cVend
				SC5->(MsUnlock())
				//////
				RecLock("SF2",.F.)
				&("SF2->F2_VEND"+AllTrim(Str(nOrder))) := cVend
				SF2->(MsUnlock())
			EndIf
			
			If !Empty(SA3->A3_SUPER)
				nOrder++
				cVend := SA3->A3_SUPER
				loop
			Else
				exit
			Endif
			
		EndDo
		
		aVendP := {}
		nOrder := 1
		SD2->(DbSkip())
	EndDo
	
	END TRANSACTION
	
ENDIF

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//TROCAR VENDEDOR DE UMA NOTA FISCAL ANTES DO CALCULO DE COMISSAO
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function TrocVend(_nChvDoc,_cNewVend)

IF SF2->(DbSeek(_nChvDoc))
	
	BEGIN TRANSACTION
	
	SF2->(DbSetOrder(1))
	While .Not. SF2->(Eof()) .And. SF2->(F2_FILIAL+F2_DOC+F2_SERIE) == _nChvDoc
		
		//Troca vendedor principal da nota
		If (SF2->F2_VEND1 <> _cNewVend)
			RecLock("SF2",.F.)
			SF2->F2_VEND1 := _cNewVend
			SF2->(MsUnlock())
		EndIf
		
		//Troca vendedor principal do pedido
		SD2->(DbSetOrder(3))
		SD2->(DbSeek(_nChvDoc))
		While .Not. SD2->(Eof()) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE) == _nChvDoc
			
			SC5->(DbSetOrder(1))
			IF !SC5->(DbSeek(SD2->D2_FILIAL+SD2->D2_PEDIDO))
				loop
			EndIf
			
			If (SC5->C5_VEND1 <> _cNewVend)
				RecLock("SC5",.F.)
				SC5->C5_VEND1 := _cNewVend
				SC5->(MsUnlock())
			EndIf
			
			SD2->(DbSkip())
		EndDo
		
		//Troca vendedor principal dos titulos a receber
		SE1->(DbSetOrder(2))
		IF SE1->(DbSeek(XFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC))
			While !SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == (XFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_PREFIXO+SF2->F2_DOC)
				
				If (SE1->E1_VEND1 <> _cNewVend)
					RecLock("SE1",.F.)
					SE1->E1_VEND1 := _cNewVend
					SE1->(MsUnlock())
				EndIf
				
				SE1->(DbSkip())
			EndDo
		ENDIF
		
		SF2->(DbSkip())
	EndDo
	
	END TRANSACTION
	
ENDIF

Return


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±³ValPerg - Funcao para criar o grupo de perguntas SX1 se nao existir    ³±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function ValPTV(cPerg)
Local i,j,nX
Local aTRegs := {}
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

cPerg := PADR(cPerg,10)

//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
aAdd(aTRegs,{"Novo Vendedor?","C",6,0,0,"G","","","","","","","SA3","Selecione novo vendedor #para substituir a comissão."})

//Criar aRegs na ordem do vetor Temporario
aRegs := {}
For I := 1 To Len(aTRegs)
	aAdd(aRegs,{cPerg,StrZero(I,2),aTRegs[I][1],aTRegs[I][1],aTRegs[I][1]	,"mv_ch"+Alltrim(Str(I)),aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],aTRegs[I][6],aTRegs[I][7],;
	"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","","",aTRegs[I][12],"","","",aTRegs[I][13],""})
Next I

//Grava no SX1 se ja nao existir
dbSelectArea("SX1")
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Else
		//ATUALIZA SX1
		RecLock("SX1",.F.)
		For j:=3 to FCount()
			If j <= Len(aRegs[i])
				If SubStr(FieldName(j),1,6) <> "X1_CNT"
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	EndIf
	
	//HELP DAS PERGUNTAS
	aHelpPor := {}
	__aRet := STRTOKARR(aTRegs[I][14],"#")
	FOR nX := 1 To Len(__aRet)
		AADD(aHelpPor,__aRet[nX])
	NEXT nX
	PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)
Next

//Renumerar perguntas
_ncont := 1
SX1->(dbSeek(cPerg))
While .Not. SX1->(Eof()) .And. X1_GRUPO == cPerg
	RecLock("SX1",.F.)
	SX1->X1_ORDEM := StrZero(_ncont,2)
	SX1->(MsUnlock())
	SX1->(DbSkip())
	_ncont++
EndDo

//Deletar Perguntas sobrando - apagadas do vetor
While SX1->(dbSeek(cPerg+StrZero(i,2)))
	RecLock("SX1",.F.)
	SX1->(DbDelete())
	SX1->(MsUnlock())
	i++
EndDo

Return
