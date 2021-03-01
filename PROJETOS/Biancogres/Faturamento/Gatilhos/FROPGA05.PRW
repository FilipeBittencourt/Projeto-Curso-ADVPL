#include "PROTHEUS.CH"

User Function FROPGA05() 

	If (!Empty(M->C5_CONDPAG))
		M->C5_YMAXPRO := GETMV("MV_YMAXPRO")                                                                                 
		
		DbSelectArea('SE4')
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(XFILIAL("SE4")+M->C5_CONDPAG) )                                                                       
		
		M->C5_YMAXCND 	:= IIF(cEmpAnt=="13" .And. M->C5_CLIENTE=="010064",1,SE4->E4_YMAXDES)                                  
		                                                                      
		M->C5_YMAXPAL	:= GETMV("MV_YMAXPAL")                                                                                 
		
		M->C5_CONDPAG 	:= IIF(SE4->E4_YATIVO== "2","",M->C5_CONDPAG)                                                          
		
		M->C5_YFORMA 	:= EXECBLOCK("BIA801",.F.,.F.)                                                                         
		
		M->C5_CONDPAG 	:= EXECBLOCK("BIA806",.F.,.F.)                                                                         
		
		__cContPag 	:= EXECBLOCK("ATU_PEDIDO",.F.,.F.)                                                                     
		If (!Empty(__cContPag))
			M->C5_CONDPAG := __cContPag
		EndIf
		
		If (ALLTRIM(M->C5_TIPO)=="N")
			M->C5_CLIENTE 	:= EXECBLOCK("BIA525",.F.,.F.)                                                                                                                                             
		EndIf         
	EndIf                                                             
	                                                                       	
Return (M->C5_CONDPAG)

