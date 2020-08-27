#Include "Protheus.ch"
#Include "Totvs.ch"

User Function Testam() 
Local oBol := TWBolSantan():New()

	DbSelectArea("SE1")
	Set Filter To E1_FILIAL = "0201" .And. E1_PREFIXO = "DEB"
	
	DbGoTop()
	
	While !SE1->(Eof()) 
		If oBol:CartValida()
			oBol:Preparar()
			oBol:Montar()		
			oBol:VerPDF()		
		EndIf	
	
		SE1->(DbSkip())
	End

	DbSelectArea("SE1")	
	Set Filter To
Return