#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF042
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Processa remessa de titulos a pagar 
@type function
/*/

User Function BAF042()

    Local cBckFunc 			:= ""
    Local cForne            := ""
    Local cLojaForne        := "" 
    Local cNatureza         := ""
    Local nI				:= 0
    Local aListForne		:= {;
    							{"000534",  "01" , "1121"},;
    							{"002912",  "01" , "2101"},;
    							{"004695",  "01" , "2999"};
    							}
    
       
    cBckFunc := FUNNAME()

	SETFUNNAME("FINA290")
	
    ConOut("TAF => BAF042 - [Fatura intercompany de titulos a pagar] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	U_GravaPZ2(0,"SE2","BAF042","INICIO","EMP:"+CEMPANT,"MNT",CUSERNAME)
      
	For nI=1 To Len(aListForne)
		
		cForne		:= aListForne[nI][1]//fornecedor
		cLojaForne	:= aListForne[nI][2]//loha 
		cNatureza	:= aListForne[nI][3]//natureza
		
		 ConOut("TAF => BAF042 - [Fatura intercompany de titulos a pagar] - Fornecedor/Loja/Natureza: "+cForne+'/'+cLojaForne+'/'+cNatureza+" - DATE: "+DTOC(Date())+" TIME: "+Time())
		 U_GravaPZ2(0,"SE2","BAF042","INI_"+cForne,"EMP:"+CEMPANT,"MNT",CUSERNAME)
									
		oObj := TFaturaPagarIntercompany():New()
		oObj:Processa(cForne, cLojaForne, cNatureza)
		
		ConOut("TAF => BAF042 - [Fatura intercompany de titulos a pagar] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
		U_GravaPZ2(0,"SE2","BAF042","FIM_"+cForne,"EMP:"+CEMPANT,"MNT",CUSERNAME)
	
	Next nI

	U_GravaPZ2(0,"SE2","BAF042","FIM","EMP:"+CEMPANT,"MNT",CUSERNAME)
    
    SETFUNNAME(cBckFunc)

Return()
