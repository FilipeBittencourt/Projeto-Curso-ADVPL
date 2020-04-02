#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"   


#Define CRLF chr(13)+chr(10)

/*
##############################################################################################################
# PROGRAMA...: FCACRE05         
# AUTOR......: Luiz Guilherme Barcellos (FACILE SISTEMAS)
# DATA.......: 30/06/2015                      
# DESCRICAO..: Relatório de Manutenção Preventiva
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/                          
User Function FCACRE05()                

	Private _cNomRel := "FCACRE05"
	Private _cTitRel := "Relatório de Manutenção Preventiva"
	
	AjustaSX1(_cNomRel)
	oReport := ReportDef()
	oReport :PrintDialog()

Return


Static Function ReportDef()
	
	oReport := TReport():New(_cNomRel, _cTitRel, _cNomRel, {|oReport| ReportPrint(oReport)}, _cTitRel)
	//oReport:SetPortrait() // Retrato 
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)
	oReport:SetLineHeight(40)
	oReport:SetColSpace(1)
	oReport:SetLeftMargin(1)
	oReport:oPage:SetPageNumber(1)
	oReport:nFontBody := 8 // Tamanho Fonte
	oReport:lBold := .T.
	oReport:lUnderLine := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .F.

	Pergunte(_cNomRel, .F.)
	
	oSection1 := TRSection():New(oReport, "Manutencoes", {}) 
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1, "CODCLI"  ,	, "Cod. Cliente",,         20, .F.)
	TRCell():New(oSection1, "NOMCLI"  ,	, "Nome Cliente",,         40, .F.)
	TRCell():New(oSection1, "CODEQUIP", , "Cod. Equip."	,,         18, .F.)
	TRCell():New(oSection1, "NOMEQUIP", , "Nome Equip."	,,         40, .F.)
	TRCell():New(oSection1, "NUMSER"  ,	, "Núm. Série"	,,         20, .F.)
	
	TRCell():New(oSection1, "HORIMETRO", , "Horím. Atual"	,,     18, .F.)
	TRCell():New(oSection1, "REVISAO",	, "Revisão"	,,         	   20, .F.)
	TRCell():New(oSection1, "DATA"  ,	, "Dt. Revisão"	,,         20, .F.)

Return(oReport)


Static Function ReportPrint(oReport) 

Local _cSql 
Local cAtend := ""
Local nHorimAtu
Local nProxManut


DbSelectArea("AA3")
AA3->(DbSetOrder(1)) 
AA3->(DbGotop())

DbSelectArea("SZ4")
SZ4->(DbSetOrder(1))


oSection1 := oReport:Section(1) 
oSection1:Init()

While !AA3->(Eof()) .AND. AA3->(AA3_CODCLI+AA3_LOJA) <= (MV_PAR05+MV_PAR06)
	If AA3->(AA3_CODCLI+AA3_LOJA) < MV_PAR03+MV_PAR04
		AA3->(DbSkip())
		loop
	Endif
	If .not. SZ4->(DbSeek(xFilial("SZ4")+AA3->AA3_CODPRO))
		AA3->(DbSkip())
		loop
	Endif
	nHorimAtu := U_calcHori(DATE(),IIF(EMPTY(AA3->AA3_YDTHOR),AA3->AA3_DTVEND,AA3->AA3_YDTHOR), AA3->AA3_HORDIA,AA3->AA3_DIAOPE,AA3->AA3_YHORIM)
	While !SZ4->(Eof()) .and. SZ4->Z4_PRODUTO == AA3->AA3_CODPRO .and. SZ4->Z4_HORAS < nHorimAtu
		SZ4->(DbSkip())
	EndDo
	If !SZ4->(Eof()) .and. SZ4->Z4_PRODUTO == AA3->AA3_CODPRO 
		nProxManut := SZ4->Z4_HORAS
		nMediaDia  := (AA3->AA3_HORDIA*AA3->AA3_DIAOPE)/7  
		nDiasManut := (nProxManut-nHorimAtu) / nMediaDia
		dDataManut := date() + nDiasManut 
		if dDataManut >= MV_PAR01 .and. dDataManut<= MV_PAR02
			
			oSection1:Cell("CODCLI"):SetValue(AA3->AA3_CODCLI+"-"+AA3->AA3_LOJA)
			oSection1:Cell("NOMCLI"):SetValue(Alltrim(Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODCLI+AA3->AA3_LOJA,"A1_NOME")))
			oSection1:Cell("CODEQUIP"):SetValue(Alltrim(AA3->AA3_CODPRO))
			oSection1:Cell("NOMEQUIP"):SetValue(Alltrim(Posicione("SB1", 1, xFilial("SB1")+AA3->AA3_CODPRO, "B1_DESC")))
			oSection1:Cell("NUMSER"):SetValue(Alltrim(AA3->AA3_NUMSER))
			oSection1:Cell("HORIMETRO"):SetValue(Alltrim(Str(NOROUND(nHorimAtu,0))))
			oSection1:Cell("REVISAO"):SetValue(Alltrim(Str(nProxManut)))
			oSection1:Cell("DATA"):SetValue(dtoc(dDataManut))
			oSection1:PrintLine()
		endif
	EndIf
	
	AA3->(DbSkip())
EndDo

oSection1:Finish()

Return Nil

*-----------------------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para Ajustar as Perguntas conforme necessidade do Relatorio //
////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
	PutSx1(cPerg, "01", "Dt. Prevista de  :    ", "", "", "mv_ch1", "D", 08, 00, 0, "G","NaoVazio()"  , ""    ,"", " ", "MV_PAR01", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "02", "Dt. Prevista ate :    ", "", "", "mv_ch2", "D", 08, 00, 0, "G","NaoVazio()"  , ""    ,"", " ", "MV_PAR02", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	
	PutSx1(cPerg, "03", "Cliente de:              ", "", "", "mv_ch3", "C", 06, 00, 0, "G",""            ,"SA1"  ,"", " ", "MV_PAR03", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "04", "Loja de:                 ", "", "", "mv_ch4", "C", 02, 00, 0, "G",""            ,""     ,"", " ", "MV_PAR04", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "05", "Cliente até:             ", "", "", "mv_ch5", "C", 06, 00, 0, "G","NaoVazio()"  ,"SA1"  ,"", " ", "MV_PAR05", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "06", "Loja até:                ", "", "", "mv_ch6", "C", 02, 00, 0, "G","NaoVazio()"  ,""     ,"", " ", "MV_PAR06", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")	
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------------------  
