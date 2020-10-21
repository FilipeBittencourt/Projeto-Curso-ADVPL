#Include 'Protheus.ch'
#Include "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH  "
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"

/*/{Protheus.doc} PTX0013
Função para impressão da DANFE
@type Function
@author Pontin
@since 14/06/2016
@version 1.0
/*/
User Function TESTPTX()

 
	/*DbSelectArea("ZZZ")
	ZZZ->(DbSetOrder(1)) // ZZZ_FILIAL, ZZZ_CHAVE, R_E_C_N_O_, D_E_L_E_T_
	ZZZ->(DbGoTop())	
	 
	If ZZZ->(DbSeek("0152170503657569000384550010000097721214114687"))
		PTX00XX("NOME_DO_ARQUIVO")
	EndIf
	*/
	PTX00XX("NOME_DO_ARQUIVO_TESTE")

return 

Static Function PTX00XX(cNomeArq)

	Local oSetupDanf
    Local cLocal     := "C:\temp\" //LOWER(SuperGetMV("ZZ_DIRDANF",.F.,"C:\temp\"))     
	Local oFont10N   		:= TFont():New("Times New Roman",,10,.T.,.T.) // 10N
    Default cNomeArq := LOWER(cNomeArq)

	FERASE(cLocal+cNomeArq+".pdf")                 
	oSetupDanf := FWMSPrinter():New(cNomeArq, IMP_PDF,.F.,cLocal,.T.,/*lTReport */ ,/*oPrintSetup*/ ,/*cPrinter*/ , .T., /*lPDFAsPNG*/,/*lRaw*/, .F.)
	oSetupDanf:cPathPDF := cLocal  
	oSetupDanf:Say(052,153,"HELO WORD",oFont10N)
	oSetupDanf:SetResolution(79)
	oSetupDanf:SetPortrait()
	oSetupDanf:SetPaperSize(9)
	oSetupDanf:SetMargin(65,60,65,60) 
	oSetupDanf:EndPage()
	oSetupDanf:Print()

return 
 
	 