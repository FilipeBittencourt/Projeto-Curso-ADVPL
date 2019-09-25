  /*/{Protheus.doc} RESTSB1
@name      Facile - Rest Produto
@type      function
@author    Filipe
@since     07/08/2019
@version   1.0
/*/

#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#Include "TBICONN.ch"
#DEFINE CRLF (Chr(13)+Chr(10))
WsRestFul RESTSB1 Description "Facile - Rest Produto"
	WsData id AS String
	WsMethod GET Description  "Get method"  WsSyntax "/RESTSB1/{codebar}/{empresa}/{filial}"
End WsRestFul
 
WSMETHOD GET WSRECEIVE codebar, empresa , filial WSSERVICE RESTSB1

Local cResponse := ''

//Define o tipo de retorno do metodo
::SetContentType("application/json")
//Registra no console a chamada do metodo
ConOut('RESTSB1 - GET METHOD') 

ConOut(::aUrlParms[1]) //codebar
ConOut(::aUrlParms[2])// empresa
ConOut(::aUrlParms[3]) //filial

Do Case
    // 1. Quando ha parametros na URL
    Case Len(::aUrlParms) = 3    

		RPCSetEnv(::aUrlParms[2], ::aUrlParms[3], NIL, NIL, "COM", NIL, {"SB1", "SB5"}) 
		DbSelectArea("SB1")
		SB1->(DbSetOrder(5)) //B1_FILIAL, B1_CODBAR, R_E_C_N_O_, D_E_L_E_T_    
		If SB1->(dbSeek(::aUrlParms[3]+::aUrlParms[1]))
			cResponse += '{ "status":200,'
			cResponse  += '"response":{'
				cResponse += '"B1_COD":"'+ AllTrim(SB1->B1_COD)+'",'
				cResponse += '"B1_DESC":"'+ AllTrim(SB1->B1_DESC)+'",'
				cResponse += '"B1_UM":"'+ AllTrim(SB1->B1_UM)+'",'	
				cResponse += '"B1_CODBAR":"'+ AllTrim(SB1->B1_CODBAR)+'",'					
				cResponse += '"B1_PESO":"'+ cValToChar(SB1->B1_PESO)+'",'	
				cResponse += '"B1_DESCNF1":"'+ StrTran(StrTran(AllTrim(SB1->B1_DESCNF1),"'",""),'"','')+'",'									
				cResponse += '"B1_BITMAP":""'
			cResponse += '}}'			
			::SetResponse(cResponse)    
			Return .T.
		EndIf
		                     
		SB1->(DbSetOrder(1))   //B1_FILIAL, B1_COD		
		If SB1->(dbSeek(::aUrlParms[3]+::aUrlParms[1]))
			cResponse += '{ "status":200,'
			cResponse  += '"response":{'
				cResponse += '"B1_COD":"'+ AllTrim(SB1->B1_COD)+'",'
				cResponse += '"B1_DESC":"'+ AllTrim(SB1->B1_DESC)+'",'
				cResponse += '"B1_UM":"'+ AllTrim(SB1->B1_UM)+'",'	      
				cResponse += '"B1_CODBAR":"'+ AllTrim(SB1->B1_CODBAR)+'",'	
				cResponse += '"B1_PESO":"'+ cValToChar(SB1->B1_PESO)+'",'	
				cResponse += '"B1_DESCNF1":"'+ StrTran(StrTran(AllTrim(SB1->B1_DESCNF1),"'",""),'"','')+'",'									
				cResponse += '"B1_BITMAP":""'
			cResponse += '}}'			
			::SetResponse(cResponse)
			Return .T.
		EndIf	 						
		::SetResponse(messages(404,Nil))
		Return .T.        
	
	End Case

Return


Static Function messages(status, logError)

Local cResponse := ''
 
	If INT(status) == 500 
		cResponse := '{'
			cResponse += '"status":500,'
			cResponse += '"message":"Internal server error in PROTHEUS WS",'
			cResponse += '"detail":"json deserialize fault"'        
		cResponse += '}'
	ElseIf INT(status) == 404
		cResponse := '{'
			cResponse += '"status":404,'
			cResponse += '"message":"Not Found in PROTHEUS WS",'
			cResponse += '"detail":"No records found"'        
		cResponse += '}'
   ElseIf INT(status) == 400
		cResponse := '{'
			cResponse += '"status":400,'
			cResponse += '"message":"Bad request in PROTHEUS WS",'
			cResponse += '"detail":"'+ logError +'"'        
		cResponse += '}'
   ElseIf INT(status) == 406
		cResponse := '{'
			cResponse += '"status":406,'
			cResponse += '"message":"Duplicate in PROTHEUS WS",'
			cResponse += '"detail":"Record found, duplicate."'        
		cResponse += '}'
   EndIf   
 
Return cResponse 

Static Function GetIMG(Filial, B1BITMAP, B1COD)
		
		Local pathIMG := ""
		// VERIFICA SE O PRODUTO INFORMADO TEM IMAGEM CADASTRADA       
            ConOut("Imagem abaixo")	
			ConOut(B1BITMAP)
	    	If !Empty(B1BITMAP)		
				ConOut("VERIFICA SE O PRODUTO INFORMADO TEM IMAGEM CADASTRADA") 
				If (RepExtract(AllTrim(B1BITMAP), "\workflow\ConsultaProdutos\images\" + AllTrim(B1COD) + ".jpg" , .T.))
					If File("/workflow/ConsultaProdutos/images/" + AllTrim(B1COD) + ".jpg")
						conout("imagem criada")
					EndIf			
					pathIMG := AllTrim(B1COD) + ".jpg"	                       

				EndIf	   
	   		EndIf  	 

Return pathIMG 