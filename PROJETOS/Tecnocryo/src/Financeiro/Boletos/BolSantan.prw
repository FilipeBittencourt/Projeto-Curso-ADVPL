#Include "Totvs.ch"
#Include "Protheus.ch"
#Include "TopConn.ch" 

//________________________________________________________________________ 
//                                                                        
//
//________________________________________________________________________

User Function TECRE002()

	Local oBol := TWBolSantan():New()
	Local nK   := 0 	


	//If FWFilName(cEmpAnt,cFilAnt) $ "TECNOCRYO"

	//	Aviso("Atenção","Rotina desabilitada para a Filial  "+ Alltrim(FWFilName(cEmpAnt,cFilAnt))+"" ,{"OK"},1)
	//Else 

	U_TECFAT04()

	If oBol:CartValida()
		oBol:Preparar()
		oBol:Montar()		
		oBol:VerPDF()		
	EndIf 
	
	// Endif 

Return(.T.)