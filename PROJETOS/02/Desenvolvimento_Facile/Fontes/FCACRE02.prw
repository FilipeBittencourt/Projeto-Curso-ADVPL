#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "TBIConn.ch"

/*
##############################################################################################################
# PROGRAMA...: AT410GRV         
# AUTOR......: Gabriel Rossi Mafioletti (FACILE SISTEMAS)
# DATA.......: 08/04/2015                      
# DESCRICAO..: Relatório de OS Atendidas
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/
User Function FCACRE02()                

	Private _cNomRel := "FCACRE02"
	Private _cTitRel := "Relatório de OS Atendidas"
	
	AjustaSX1(_cNomRel)
	oReport := ReportDef()
	oReport :PrintDialog()

Return


Static Function ReportDef()
	
	oReport := TReport():New(_cNomRel, _cTitRel, _cNomRel, {|oReport| ReportPrint(oReport)}, _cTitRel)
	oReport:SetPortrait() // Retrato 
	oReport:SetTotalInLine(.F.)
	oReport:SetLineHeight(40)
	oReport:SetColSpace(1)
	oReport:SetLeftMargin(1)
	oReport:oPage:SetPageNumber(1)
	oReport:nFontBody := 6 // Tamanho Fonte
	oReport:lBold := .T.
	oReport:lUnderLine := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .F.

	Pergunte(_cNomRel, .F.)
	
	oSection1 := TRSection():New(oReport, "Clientes", {"AB8"}) 
	oSection1:SetTotalInLine(.F.)
	TRCell():New(oSection1, "CODCLI", , "Cod. Cliente",,         20, .F.)
	TRCell():New(oSection1, "NOMCLI", , "Nome Cliente",,         40, .F.)

	oSection1:SetNoFilter({"AB8"})

	oSection2 := TRSection():New(oSection1, "Ordens de Servico", {"AB8"}) 
	oSection2:SetTotalInLine(.F.)	
	TRCell():New(oSection2, "NUMOS", , "OS",,         12, .F.)
	TRCell():New(oSection2, "EMISSAO", , "Emissão",,         15, .F.)
	TRCell():New(oSection2, "NOMTEC", , "Técnico",,         40, .F.)	
	TRCell():New(oSection2, "OSRETR", , "OS Retrab.",,         20, .F.)

	oSection2:SetNoFilter({"AB8"})

	oSection3 := TRSection():New(oSection2, "Apontamentos", {"AB8"}) 
	oSection3:SetTotalInLine(.F.)	
	TRCell():New(oSection3, "NRFORM", , "Nr. Form.",,         20, .F.)	
	TRCell():New(oSection3, "CODPRO", , "Prod/Serv",,         20, .F.)
	TRCell():New(oSection3, "DESPRO", , "Descricao",,         40, .F.)
	TRCell():New(oSection3, "OBSERV", , "Observacao",,        80, .F.)	

	oSection3:SetNoFilter({"AB8"})
	
	oSection4 := TRSection():New(oSection3, "TOTAIS", {"AB8"}) 
	oSection4:SetTotalInLine(.F.)
	TRCell():New(oSection4, "TOTOS"   , , "Tot. Geral",,   15, , , "RIGHT", , "RIGHT")
	TRCell():New(oSection4, "TOTNR"   , , "Tot. Normais",,   15, , , "RIGHT", , "RIGHT")
	TRCell():New(oSection4, "TOTRE"   , , "Tot. Retrab.",,   15, , , "RIGHT", , "RIGHT")
	TRCell():New(oSection4, "NRCLI"   , , "Nr. Clientes",,   15, , , "RIGHT", , "RIGHT")
	oSection4:SetNoFilter({"AB8"})


	// Total por Centro de Custo
	oBreak1 := TRBreak():New(oSection1, oSection1:Cell("CODCLI"), "Total Cliente", .F.)
	TRFunction():New(oSection3:Cell("NRFORM"), "Total Cliente", "COUNT", oBreak1, , "@E 999,999,999", , .F., .F.)

Return(oReport)


Static Function ReportPrint(oReport)
	Local _cALias		:=	GetNextAlias()
	Local _cOSAnt		:=	""    
	Local _nTotOs		:=	0
	Local _nTotNr		:=	0
	Local _nTotRe		:=	0
	Local _nTotCli		:=	0
	Local _nFechadas    :=	Iif(MV_PAR04 == 1,1,0)

	oSection1 := oReport:Section(1)
	oSection2 := oReport:Section(1):Section(1)
	oSection3 := oReport:Section(1):Section(1):Section(1)
	oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
	_cEoL     := Chr(13) + Chr(10)	


	BeginSql Alias _cAlias
		%NoParser%
	
		EXEC STPCAC_ORDENS_DE_SERVICO %Exp:MV_PAR01%,%Exp:MV_PAR02%,%Exp:MV_PAR03%,%Exp:_nFechadas%
	
	EndSql  
	
	If (_cAlias)->(!EOF())
		oSection1:Init()
		oSection1:Cell("CODCLI"):SetValue((_cAlias)->CODCLI)
		oSection1:Cell("NOMCLI"):SetValue((_cAlias)->NOMCLI)
	    oSection1:PrintLine()	
                                                            
		oSection2:Init()
		oSection2:Cell("NUMOS"):SetValue((_cAlias)->NUMOS)
		oSection2:Cell("EMISSAO"):SetValue(DTOC(STOD((_cAlias)->EMISS)))
		oSection2:Cell("NOMTEC"):SetValue((_cAlias)->NOMTEC)		
		oSection2:Cell("OSRETR"):SetValue((_cAlias)->RETRAB)
	    oSection2:PrintLine()	

		oSection3:Init()
		
	    _cOSAnt	:= (_cAlias)->NUMOS
	    _cCliAnt	:=	(_cAlias)->CODCLI
		_nTotCli++
	EndIf                          
	                         
	While (_cAlias)->(!EOF())
	    
	    IF (_cAlias)->CODCLI <> _cCliAnt
			oSection1:Finish()
		    oSection2:Finish()
		    oSection3:Finish()		    				    			
		
			oSection1:Init()
			oSection1:Cell("CODCLI"):SetValue((_cAlias)->CODCLI)
			oSection1:Cell("NOMCLI"):SetValue((_cAlias)->NOMCLI)
		    oSection1:PrintLine()
			_nTotCli++

	    EndIf
	    
	    IF (_cAlias)->NUMOS <> _cOsAnt
		    oSection2:Finish()
		    oSection3:Finish()		    				    			

			oSection2:Init()
			oSection2:Cell("NUMOS"):SetValue((_cAlias)->NUMOS)
			oSection2:Cell("EMISSAO"):SetValue(DTOC(STOD((_cAlias)->EMISS)))
			oSection2:Cell("NOMTEC"):SetValue((_cAlias)->NOMTEC)		
			oSection2:Cell("OSRETR"):SetValue((_cAlias)->RETRAB)
		    oSection2:PrintLine()
		    
			oSection3:Init()
	    
	    EndIf
		Iif(!Empty((_cAlias)->RETRAB),_nTotRE++,_nTotNR++)

		oSection3:Cell("NRFORM"):SetValue((_cAlias)->NRFORM)
		oSection3:Cell("CODPRO"):SetValue((_cAlias)->CODPRO)
		oSection3:Cell("DESPRO"):SetValue((_cAlias)->DESPRO)
		oSection3:Cell("OBSERV"):SetValue(Iif(!Empty((_cAlias)->CDMEMO),MSMM((_cAlias)->CDMEMO),""))
		oSection3:PrintLine()
	    
	    _cCliAnt	:=	(_cAlias)->CODCLI
	    _cOSAnt	:= (_cAlias)->NUMOS
		(_cAlias)->(DbSkip())
	EndDo

	oSection3:Finish()
    oSection2:Finish()
	oSection1:Finish()
	oSection4:Init()
	oSection4:Cell("TOTOS"):SetValue(_nTotRE+_nTotNR)
	oSection4:Cell("TOTNR"):SetValue(_nTotNR)
	oSection4:Cell("TOTRE"):SetValue(_nTotRE)
	oSection4:Cell("NRCLI"):SetValue(_nTotCli)
	oSection4:PrintLine()

	oSection4:Finish()	
	(_cAlias)->(DbCloseArea())

Return Nil

*-----------------------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para Ajustar as Perguntas conforme necessidade do Relatorio //
////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
	PutSx1(cPerg, "01", "Emissao   De        : ", "", "", "mv_ch1", "D", 08, 00, 0, "G", "NaoVazio()", ""    ,"", " ", "mv_par01", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "02", "Emissao  Ate        : ", "", "", "mv_ch2", "D", 08, 00, 0, "G", "NaoVazio()", ""    ,"", " ", "mv_par02", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "03", "Tipo Relator        : ", "", "", "mv_ch3", "N", 01, 00, 0, "C", ""          , ""    ,"", " ", "mv_par03", "1=Servicos     ", "", "", "", "2=Peças		  ", "", "", "3=Ambos        ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "04", "Somente Fechadas    : ", "", "", "mv_ch4", "N", 01, 00, 0, "C", ""          , ""    ,"", " ", "mv_par04", "1=Sim		   ", "", "", "", "2=Não		  ", "", "", "		         ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------------------