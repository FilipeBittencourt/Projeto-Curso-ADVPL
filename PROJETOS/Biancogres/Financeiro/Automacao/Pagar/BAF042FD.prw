#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF042FD
Automação Financeira: Processa remessa de titulos a pagar para FIDC
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 28/07/2021
/*/
User Function BAF042FD()

	Local cBckFunc   := ""
	Local cForne     := ""
	Local cLojaForne := ""
	Local cNatureza  := ""
	Local nI         := 0
	Local aListForne := {;
								{"000534", "01", "1121"},;
								{"002912", "01", "2101"},;
								{"004695", "01", "2999"};
								}

	If Upper( AllTrim( GetEnvServer() ) ) == "COMP-PONTIN" .And. Select("SX6") <= 0
   		RpcSetEnv('07', '01')
	EndIf 
       
	cBckFunc := FUNNAME()

	SETFUNNAME("FINA290")
	
	ConOut("TAF => BAF042FD - [Fatura intercompany de titulos a pagar FIDC] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	U_GravaPZ2(0,"SE2","BAF042FD","INICIO","EMP:"+CEMPANT,"MNT",CUSERNAME)
      
	For nI=1 To Len(aListForne)
		
		cForne     := aListForne[nI][1] //fornecedor
		cLojaForne := aListForne[nI][2] //loja 
		cNatureza  := aListForne[nI][3] //natureza
		
		ConOut("TAF => BAF042FD - [Fatura intercompany de titulos a pagar FIDC] - Fornecedor/Loja/Natureza: "+cForne+'/'+cLojaForne+'/'+cNatureza+" - DATE: "+DTOC(Date())+" TIME: "+Time())
		U_GravaPZ2(0,"SE2","BAF042FD","INI_"+cForne,"EMP:"+CEMPANT,"MNT",CUSERNAME)
									
		oObj := TFaturaPagarIntercompany():New()
		oObj:lFidc	:= .T.
		oObj:Processa(cForne, cLojaForne, cNatureza)
		
		ConOut("TAF => BAF042FD - [Fatura intercompany de titulos a pagar FIDC] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
		U_GravaPZ2(0,"SE2","BAF042FD","FIM_"+cForne,"EMP:"+CEMPANT,"MNT",CUSERNAME)
	
	Next nI

	U_GravaPZ2(0,"SE2","BAF042FD","FIM","EMP:"+CEMPANT,"MNT",CUSERNAME)
    
	SETFUNNAME(cBckFunc)

Return
