#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"   


#Define CRLF chr(13)+chr(10)

/*
##############################################################################################################
# PROGRAMA...: FCACRE03         
# AUTOR......: Luiz Guilherme Barcellos (FACILE SISTEMAS)
# DATA.......: 14/05/2015                      
# DESCRICAO..: Relat�rio de Hist�rico de Atendimento
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/
User Function FCACRE03()                

	Private _cNomRel := "FCACRE03"
	Private _cTitRel := "Relat�rio de Hist�rico de Atendimento"
	
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
   //	oReport:lBold := .T.  
   	oReport:lBold := .F.  // ALFONSO 20180806
	oReport:lUnderLine := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .F.

	Pergunte(_cNomRel, .F.)
	
	oSection1 := TRSection():New(oReport, "Equipamentos", {}) 
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1, "CODEQUIP", , "Cod. Equip."	,,         18, .F.)
	TRCell():New(oSection1, "NOMEQUIP", , "Nome Equip."	,,         40, .F.)
	TRCell():New(oSection1, "NUMSER"  ,	, "N�m. S�rie"	,,         20, .F.)
	TRCell():New(oSection1, "CODCLI"  ,	, "Cod. Cliente",,         20, .F.)
	TRCell():New(oSection1, "NOMCLI"  ,	, "Nome Cliente",,         40, .F.)
    
	oSection2 := TRSection():New(oSection1, "Ordens de Servi�o", {}) 
	oSection2:SetTotalInLine(.F.)	
	TRCell():New(oSection2, "OS"		, , "O.S."		,,12, .F.) 
	TRCell():New(oSection2, "FORMUL"	, , "Formul."	,,12, .F.)
	TRCell():New(oSection2, "EMISSAO"	, , "Data"		,,18, .F.)
	TRCell():New(oSection2, "ORCAMENTO"	, , "Or�amento" ,,15, .F.)
	TRCell():New(oSection2, "CHAMADO"	, , "Chamado"	,,12, .F.)
   //	TRCell():New(oSection2, "TECNICO"	, , "T�cnico"	,,30, .F.)  
	TRCell():New(oSection2, "TECNICO"	, , "T�cnico"	,,40, .F.)// alfonso 20180806
	//TRCell():New(oSection2, "OCORRENCIA", , "Ocorr�ncia",,30, .F.) 
	TRCell():New(oSection2, "OCORRENCIA", , "Ocorr�ncia",,50, .F.)    // alfonso 20180806
	TRCell():New(oSection2, "CODITEM" 	, , "Cod. Item"	,,15, .F.)
	TRCell():New(oSection2, "NOMEITEM"	, , "Desc. Item",,40, .F.)

Return(oReport)


Static Function ReportPrint(oReport)
	Local _cSerAnt := ""
	Local _cOsAnt := ""
	Local _cFormAnt := ""
	Local lImpApont := .t.

	oSection1 := oReport:Section(1)
	oSection2 := oReport:Section(1):Section(1)
	
	_cSql:="SELECT DISTINCT AB7_NUMSER, AB7_CODPRO, B1_DESC DESCEQUIP, AB7_CODCLI, A1_NOME, AB7_LOJA , AB7_NUMOS, AB7_YNRFOR, AB9_MEMO1,"
	_cSql:= _cSql+CRLF+"	ISNULL(AB9_DTFIM,AB7_EMISSA) AS EMISSAO,"
	_cSql:= _cSql+CRLF+"	ISNULL(AB2_NRCHAM, SUBSTRING(AB4_NRCHAM,1,8)) AS CHAMADO, AB4_NUMORC, AB8_CODPRO, AB8.AB8_DESPRO, AA1_NOMTEC, AAG_DESCRI"
	_cSql:= _cSql+CRLF+"FROM "+RetSqlName("AB7")+" AB7"
	_cSql:= _cSql+CRLF+"		INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_COD=AB7.AB7_CODCLI AND AB7.AB7_LOJA=SA1.A1_LOJA AND SA1.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"		INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD=AB7.AB7_CODPRO AND SB1.D_E_L_E_T_=' '" 
	_cSql:= _cSql+CRLF+"		INNER JOIN "+RetSqlName("AAG")+" AAG ON AAG_CODPRB=AB7_CODPRB AND AAG.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"		LEFT JOIN "+RetSqlName("AB2")+" AB2 ON AB7.AB7_NRCHAM=AB2.AB2_NRCHAM+AB2.AB2_ITEM AND AB2.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"		LEFT JOIN "+RetSqlName("AB4")+" AB4 ON AB7.AB7_NUMOS+AB7.AB7_ITEM=AB4.AB4_NUMOS AND AB4.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"		LEFT JOIN "+RetSqlName("AB8")+" AB8 ON AB8.AB8_NUMOS=AB7.AB7_NUMOS AND AB8.AB8_ITEM=AB7.AB7_ITEM AND AB8.D_E_L_E_T_=' '	"
	_cSql:= _cSql+CRLF+"		LEFT JOIN "+RetSqlName("AB9")+" AB9 ON AB9.AB9_NUMOS=AB7.AB7_NUMOS+AB7.AB7_ITEM AND AB9.D_E_L_E_T_=' '" 
	_cSql:= _cSql+CRLF+"		LEFT JOIN "+RetSqlName("AA1")+" AA1 ON AA1.AA1_CODTEC= AB9.AB9_CODTEC AND AA1.D_E_L_E_T_=' '
	_cSql:= _cSql+CRLF+"WHERE AB7_FILIAL='"+xFilial("AB7")+"' AND AB7.AB7_EMISSA  BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'"
	_cSql:= _cSql+CRLF+"	AND AB7_CODPRO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"  //retirado o LIKE para funcionar corretamente.
	_cSql:= _cSql+CRLF+"	AND AB7_NUMSER BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	_cSql:= _cSql+CRLF+"	AND AB7_CODCLI BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR09+"' AND AB7_LOJA BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR10+"'"
	_cSql:= _cSql+CRLF+"	AND AB7_CODPRB NOT IN " + FormatIn(alltrim(MV_PAR11)," ")+" AND AB7.D_E_L_E_T_=' '"
	_cSql:= _cSql+CRLF+"ORDER BY AB7_NUMSER, AB7_CODPRO, AB7_NUMOS"
	
	If select("TRB")>0
		TRB->(DbCloseArea())
	Endif
	
	TCQUERY _cSql NEW ALIAS "TRB"
                         
	While TRB->(!EOF())	    
	    IF TRB->AB7_NUMSER <> _cSerAnt
			oSection1:Finish()
		    oSection2:Finish()		    				    			
			If !empty(_cSerAnt)
				oReport:EndPage()
			Endif
			// oReport:nFontBody := 10	  
			oReport:nFontBody := 8 // alfonso 2018AGO06	  
				
			oSection1:Init()
			oSection1:Cell("CODEQUIP"):SetValue(TRB->AB7_CODPRO)
			oSection1:Cell("NOMEQUIP"):SetValue(TRB->DESCEQUIP)
			oSection1:Cell("NUMSER"):SetValue(TRB->AB7_NUMSER)
			
			oSection1:Cell("CODCLI"):SetValue(TRB->AB7_CODCLI)
			oSection1:Cell("NOMCLI"):SetValue(TRB->A1_NOME)
		    oSection1:PrintLine() 
		    oReport:nFontBody := 8
		    
		    oSection2:Init()
		    
	    EndIf 
	    
	    IF TRB->AB7_NUMOS == _cOsAnt .and. TRB->AB7_YNRFOR == _cFormAnt
	    	 oSection2:Cell("OS"):Hide() 
	    	 oSection2:Cell("FORMUL"):Hide()
	    	 oSection2:Cell("TECNICO"):Hide()
	    Else
	    	oSection2:Finish()
	    	oSection2:Init()
	    Endif 

	    
		oSection2:Cell("OS"):SetValue(TRB->AB7_NUMOS) 
		oSection2:Cell("FORMUL"):SetValue(TRB->AB7_YNRFOR)
		oSection2:Cell("CHAMADO"):SetValue(TRB->CHAMADO) 
		oSection2:Cell("ORCAMENTO"):SetValue(TRB->AB4_NUMORC)
		oSection2:Cell("EMISSAO"):SetValue(DTOC(STOD(TRB->EMISSAO))) 
		oSection2:Cell("TECNICO"):SetValue(TRB->AA1_NOMTEC) 
		oSection2:Cell("OCORRENCIA"):SetValue(TRB->AAG_DESCRI)
		oSection2:Cell("CODITEM"):SetValue(TRB->AB8_CODPRO)
		oSection2:Cell("NOMEITEM"):SetValue(TRB->AB8_DESPRO)
		oSection2:PrintLine() 
		    
		IF !Empty(TRB->AB9_MEMO1)		   	
		   	_cLaudo:= STRTRAN(MSMM(TRB->AB9_MEMO1),CHR(13)+CHR(10)," || ")
		   	// oReport:printtext("Laudo t�cnico: "+SUBSTR(_cLaudo,1,180))    
		   	oReport:printtext("Laudo t�cnico: "+SUBSTR(_cLaudo,1,160))  // ALFONSO 20180806
		   	WHILE !EMPTY(_cLaudo)
		   	   //	_cLaudo := SUBSTR(_cLaudo,181) 
		   		_cLaudo := SUBSTR(_cLaudo,161) // ALFONSO 20180806
		   	   //	oReport:printtext("               "+SUBSTR(_cLaudo,1,180))
		   		oReport:printtext("          "+SUBSTR(_cLaudo,1,160)) // ALFONSO 20180806
		   	ENDDO
		ENDIF
	    
	    _cSerAnt	:= TRB->AB7_NUMSER
	    _cOsAnt		:= TRB->AB7_NUMOS
	    _cFormAnt	:= TRB->AB7_YNRFOR
	    
	    oSection2:Cell("OS"):Show()
	    oSection2:Cell("FORMUL"):Show()
	    oSection2:Cell("TECNICO"):Show()
		
		TRB->(DbSkip())
	EndDo

    oSection2:Finish()
	oSection1:Finish()
	
	TRB->(DbCloseArea())

Return Nil

*-----------------------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para Ajustar as Perguntas conforme necessidade do Relatorio //
////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
	PutSx1(cPerg, "01", "Dt. Atendimento De  :    ", "", "", "mv_ch1", "D", 08, 00, 0, "G","NaoVazio()"  , ""    ,"", " ", "MV_PAR01", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "02", "Dt. Atendimento Ate :    ", "", "", "mv_ch2", "D", 08, 00, 0, "G","NaoVazio()"  , ""    ,"", " ", "MV_PAR02", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	                                                                                                     
	PutSx1(cPerg, "03", "Equipamento de:          ", "", "", "mv_ch3", "C", 15, 00, 0, "G",""            ,"SB1"  ,"", " ", "MV_PAR03", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
//	PutSx1(cPerg, "04", "Equipamento at�:         ", "", "", "mv_ch4", "C", 15, 00, 0, "G","NaoVazio()"  ,"SB1"  ,"", " ", "MV_PAR04", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")//
	
	PutSx1(cPerg, "05", "ID equip. de:            ", "", "", "mv_ch5", "C", 15, 00, 0, "G",""            ,""     ,"", " ", "MV_PAR05", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "06", "ID equip. at�:           ", "", "", "mv_ch6", "C", 15, 00, 0, "G","NaoVazio()"  ,""     ,"", " ", "MV_PAR06", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	
	PutSx1(cPerg, "07", "Cliente de:              ", "", "", "mv_ch7", "C", 06, 00, 0, "G",""            ,"SA1"  ,"", " ", "MV_PAR07", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "08", "Loja de:                 ", "", "", "mv_ch8", "C", 02, 00, 0, "G",""            ,""     ,"", " ", "MV_PAR08", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "09", "Cliente at�:             ", "", "", "mv_ch9", "C", 06, 00, 0, "G","NaoVazio()"  ,"SA1"  ,"", " ", "MV_PAR09", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "10", "Loja at�:                ", "", "", "mv_cha", "C", 02, 00, 0, "G","NaoVazio()"  ,""     ,"", " ", "MV_PAR10", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")	
	
	PutSx1(cPerg, "11", "Exceto ocorr�ncias tipo: ", "", "", "mv_chb", "C", 99, 00, 0, "G","u_marcaPrb()",""     ,"", " ", "MV_PAR11", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------------------  



User function marcaPrb()

	Local aPrb := {}
	Local _cPrb

	DbSelectArea("AAG")
	AAG->(DbSetOrder(1))
	AAG->(DbGoTop())
	
	MvParDef := ""
	While !AAG->(eof())
		_cPrb := Alltrim(AAG->AAG_DESCRI)
		aadd(aPrb, _cPrb)
		MvParDef += Alltrim(AAG->AAG_CODPRB)+" "
		AAG->(dbskip())
	EndDo

	cMvPar:=Alltrim( ReadVar())
	cPar := &cMvPar

	if f_Opcoes(@cPar, "Escolha os tipos de ocorr�ncia", aPrb,MvParDef,,,.f.,7,105)
		&( Alltrim( ReadVar())) := StrTran(cPar,"*","")
	endif	

Return


User function ExcluiSX1(cPerg)
DbSelectArea("SX1")

SX1->(DbSetOrder(1))
if(SX1->(DbSeek(cPerg)))
	while ALLTRIM(SX1->X1_GRUPO)==cPerg
		RecLock("SX1",.f.)
		SX1->(DbDelete())
		SX1->(MsUnlock())
		SX1->(DbSkip())
	enddo
endif

Return