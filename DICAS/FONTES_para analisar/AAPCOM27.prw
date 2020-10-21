#Include "rwmake.ch"
#Include "topconn.ch"
#Include "protheus.ch"

/*
------------------------------------------------------------------------------------------------------------
Função		: AAPCOM27
Tipo		: Função de Usuário
Descrição	: Relatório de Notas sem Classificar (Transferencias)
Uso			: Compras
Parâmetros	: 
Retorno		: 
------------------------------------------------------------------------------------------------------------
Atualizações:
- 24/04/2014 - Wemerson Randolfo - Construção inicial do fonte

------------------------------------------------------------------------------------------------------------
*/

User Function AAPCOM27()

	Local oReport
	Private cPerg		:= "AAPCOM27"

	CriaSX1(cPerg)
	
	If TRepInUse()
		Pergunte(cPerg, .F.)
		oReport := ReportDef()		
		oReport:PrintDialog()
		
	EndIf

Return


Static Function ReportDef()

	Local oReport
	Local oSec02
	Local oSec01
	Local oBreak
	
	oReport := TReport():New("AAPCOM27","Relatório de Notas sem Classificação",cPerg,{|oReport| PrintReport(oReport)},"Notas a Classificar")
	
	oReport:oPage:nPaperSize	:= 9  //Papel A4
	oReport:nFontBody			:= 08
	oReport:nLineHeight			:= 60
	oReport:cFontBody 			:= "Arial"
	oReport:nFontBody 			:= 9
	oReport:lBold 				:= .F.
	oReport:lUnderLine 			:= .F.
	oReport:lHeaderVisible 		:= .T.
	oReport:lFooterVisible 		:= .F.
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:SetLeftMargin(2)
	oReport:oPage:SetPageNumber(1)
	oReport:SetColSpace(1)
	
	oSec01 := TRSection():New(oReport,"Filial")
	//oSec02	:= TRSection():New(oSec01,"Notas")
		
	//TRCell():New(oSec01,"F2_FILIAL","",,,20)	
	
	TRCell():New(oSec01,"F2_FILIAL","",,,20)	
	TRCell():New(oSec01,"F2_DOC","",,,15)
	TRCell():New(oSec01,"A1_CGC","",,,20)
	TRCell():New(oSec01,"A1_NOME","",,,80)	
	TRCell():New(oSec01,"F2_VALBRUT","",,"@E 999,999,999.99",30)
	TRCell():New(oSec01,"F2_EMISSAO","",,"",25)
	
	oBreak 	:= TRBreak():New(oSec01, oSec01:Cell("F2_FILIAL"), "")
	
	//TRFunction():New(oSec02:Cell("RA_DOC"),NIL,"COUNT",oBreak,NIL,NIL,NIL,.F.,.T.)
	TRFunction():New(oSec01:Cell("F2_VALBRUT"),NIL,"SUM",oBreak,NIL,NIL,NIL,.F.,.T.)
	
	
Return oReport


/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Impressão do Relatório									   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
*/
Static Function PrintReport(oReport)

	Local oSec01	:= oReport:Section(1)
	Local oSec02	:= oSec01:Section(1)
	Local dDtIni	:= mv_par01
	Local dDtFin	:= mv_par02
	Local oBreak 
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf                 
	
	BeginSql Alias "TRB1"
	
		SELECT F2_DOC,
		       F2_FILIAL,
		       A1_CGC,
		       A1_NOME,
		       F2_EMISSAO,
		       F2_VALBRUT,
		       F2_EMISSAO
		FROM   %Table:SF2% SF2
		       INNER JOIN %Table:SA1% SA1
		               ON SA1.A1_COD = SF2.F2_CLIENTE
		                  AND SA1.A1_LOJA = SF2.F2_LOJA
		                  AND SA1.A1_YTIPOEX = 'LOJ'
		                  AND SA1.%NotDel%
		       INNER JOIN %Table:VS1%  VS1
		               ON VS1.VS1_FILIAL = SF2.F2_FILIAL
		                  AND VS1.VS1_NUMNFI = SF2.F2_DOC
		                  AND VS1.VS1_SERNFI = SF2.F2_SERIE
		                  AND VS1.VS1_CLIFAT = SF2.F2_CLIENTE
		                  AND VS1.VS1_LOJA = SF2.F2_LOJA
		                  AND VS1.%NotDel%
		       INNER JOIN %Table:SF1%  SF1
		               ON SF1.F1_FILIAL = VS1.VS1_FILDES
		                  AND SF1.F1_DOC = SF2.F2_DOC
		                  AND SF1.F1_SERIE = SF2.F2_SERIE
		                  AND SF1.F1_STATUS = ' '
		                  AND SF1.%NotDel%
		WHERE   F2_CHVNFE <> ''
		       AND F2_EMISSAO BETWEEN %Exp:dDtIni% AND %Exp:dDtFin% 
		       AND SF2.%NotDel%
		ORDER  BY F2_FILIAL,
		          F2_DOC 	
	
	
	EndSql	

	TcSetField( "TRB1", "F2_EMISSAO", "D" )
	
	TRB1->(dbGoTop())
	
	oSec01:EndQuery()

	oSec01:SetParentQuery()

	oSec01:Print()
	
	If Select("TRB1") > 0
		TRB1->(DbCloseArea())
	EndIf
	

Return

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³Perguntas do Relatório									   		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
*/
Static Function CriaSX1(cPerg)

	PutSx1(cPerg, "01","Emissao De ?","","","mv_ch01","D",08,0,0,"G","","",,,"MV_PAR01","","","",,"","","","","","","","","","","","",{"Data Emissão inicial"},{},{},"")                                                       
	PutSx1(cPerg, "02","Emissao Ate?","","","mv_ch02","D",08,0,0,"G","NaoVazio()","","","","MV_PAR02","","","","","","","","","","","","","","","","",{"Data Emissão final"},{},{},"")
	PutSx1(cPerg, "03","Filial De ?","","","mv_ch03","C",08,0,0,"G","","",,,"MV_PAR03","","","",,"","","","","","","","","","","","",{"Filial Inicial"},{},{},"")                                                       
	PutSx1(cPerg, "04","Filial Até?","","","mv_ch04","C",08,0,0,"G","NaoVazio()","","","","MV_PAR03","","","","","","","","","","","","","","","","",{"Filial Final"},{},{},"")


Return


