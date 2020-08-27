#Include "PROTHEUS.CH"
#Include "RPTDEF.CH" 
#INCLUDE "TBICONN.CH"

User Function DataMatrix()

Local oPrinter   
	
	oPrinter := FWMSPrinter():New('teste',6,.F.,,.F.,,,,,.F.)
	oPrinter:Setup()
	oPrinter:setDevice(IMP_PDF)
	//oPrinter:cPathPDF :="C:\"
	oPrinter:Say(180,0,"Teste para DataMatrix")
	oPrinter:DataMatrix(0,300,"DataMatrix gerado com sucesso", 100)	       
	oPrinter:EndPage()
	oPrinter:Preview()                                                                   
	FreeObj(oPrinter)
	oPrinter := Nil
Return
