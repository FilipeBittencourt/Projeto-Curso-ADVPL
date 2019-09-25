/*
@1 - Tem que estar rodando appserver (rest)
@2 - appserver rest (environment - este apenas se vc quiser entrar no protheus)
@3 - dbaccess
@4 - sql
*/
/*/{Protheus.doc} SISRESTSE4
@name      Sisnet Solutions - Payment-Conditions Webservice
@type      function
@author    Filipe
@since     26/10/2017
@version   1.0
/*/

#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"
#DEFINE CRLF (Chr(13)+Chr(10))
WsRestFul SISRESTSE4 Description "Sisnet Solutions - Payment-Conditions Webservice"
	WsData id AS String
	WsMethod GET Description  "Get method"  WsSyntax "/SISRESTSE4 || /SISRESTSE4/{id}"
	WsMethod POST Description "Post method" WsSyntax "/SISRESTSE4/{id}"
	WsMethod PUT Description  "Put method"  WSSYNTAX "/SISRESTSE4/{id}"
End WsRestFul

//WsMethod GET WsService SISRESTSE4
WsMethod GET WsReceive id WsService SISRESTSE4

Local cResponse := ''

//Define o tipo de retorno do metodo
::SetContentType("application/json")
//Registra no console a chamada do metodo
ConOut('SISRESTSE4 - GET METHOD')

DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTop())

Do Case
    // 1. Quando ha parametros na URL
    Case Len(::aUrlParms) > 0        
		If SE4->(MsSeek(xFilial("SE4")+::aUrlParms[1]))	        // verifica a existencia do registro    	   	            
			dbSeek(xFilial("SE4")+::aUrlParms[1]) //posiciona no registr que eu procuro
			cResponse += '{ "status":200,'
			cResponse  += '"response":{'
				cResponse += '"E4_CODIGO":"'+ AllTrim(SE4->E4_CODIGO)+'",'
				cResponse += '"E4_TIPO":"'+ AllTrim(SE4->E4_TIPO)+'",'
				cResponse += '"E4_COND":"'+ AllTrim(SE4->E4_COND)+'",'
				cResponse += '"E4_DESCRI":"'+ AllTrim(SE4->E4_DESCRI)+'"'
			cResponse += '}}'			
			SE4->(DbCloseArea())
			::SetResponse(cResponse)
			Return .T.                    
		Else		
			SE4->(DbCloseArea())
			::SetResponse(messages(404,Nil))
			Return .T.            
        EndIf
		
    Case Len(::aUrlParms) == 0        
        cResponse += '{ "status":200,'
		cResponse  += '"response":['
        While (!SE4->(EOF()))
            cResponse += '{'          
            cResponse += '"E4_CODIGO":"'+ AllTrim(SE4->E4_CODIGO)+'",'
            cResponse += '"E4_TIPO":"'+ AllTrim(SE4->E4_TIPO)+'",'
            cResponse += '"E4_COND":"'+ AllTrim(SE4->E4_COND)+'",'
            cResponse += '"E4_DESCRI":"'+ AllTrim(SE4->E4_DESCRI)+'"'
            cResponse += '},'
            SE4->(DbSkip())// salta para proximo registro
        EndDo
        cResponse +=     ']}'
        cResponse := STRTRAN(cResponse,",]}","]}")
        SE4->(DbCloseArea())
        ::SetResponse(cResponse)
        Return .T.
End Case


//----------------------------------------
// PUT
//----------------------------------------
WSMETHOD PUT WSSERVICE SISRESTSE4

Local cResponse := ''
Local aDados := {}
Local oCondPgto := nil
Local logError := ''
Private lMsErroAuto := .F.

//Define o tipo de retorno do metodo
::SetContentType("application/json")

// Registra no console a chamada do metodo
conOut('SISRESTSE4 - PUT METHOD')

DbSelectArea("SE4")
SE4->(DbSetOrder(1))
SE4->(DbGoTop())

	If FWJsonDeserialize(::GetContent(),@oCondPgto)
		Do Case
            // 1. Quando ha parametros na URL
		    Case Len(::aUrlParms) > 0        
				If SE4->(MsSeek(xFilial("SE4")+::aUrlParms[1]))	 // verifica a existencia do registro    	   	            
				   aDados:= {;
							{"E4_FILIAL",xFilial("SE4"),Nil},;
							{"E4_CODIGO",oCondPgto:E4_CODIGO,Nil},;
							{"E4_TIPO",oCondPgto:E4_TIPO,Nil},;
							{"E4_COND",Substring(AllTrim(oCondPgto:E4_COND), 1,TAMSX3("E4_COND")[1]),Nil},;
							{"E4_DESCRI",Substring(oCondPgto:E4_DESCRI, 1,TAMSX3("E4_DESCRI")[1]),Nil};
						}
					MSExecAuto({|x,y,z| Mata360(x,y,z)},aDados, {},4)  //Função para alterar
					If lMsErroAuto
						logError := mostraErro()  
						::SetResponse(messages(400,logError))
					Else
						cResponse := '{'
				        cResponse += '"status":200,'				        
				        cResponse += '"response":{'
				        	cResponse += '"ID":"' + oCondPgto:E4_CODIGO+'",'
				        	cResponse += '"E4_TIPO":' + oCondPgto:E4_TIPO+','
				        	cResponse += '"E4_COND":"' + Substring(AllTrim(oCondPgto:E4_COND), 1,TAMSX3("E4_COND")[1]) + '",'
				        	cResponse += '"E4_DESCRI":"' + Substring(oCondPgto:E4_DESCRI, 1,TAMSX3("E4_DESCRI")[1]) + '"'
				        	cResponse += '}'
				       cResponse += '}'
					EndIf
					SE4->(DbCloseArea())					
					::SetResponse(cResponse)
					Return .T.                    
				Else		
					SE4->(DbCloseArea())
					::SetResponse(messages(404,Nil))
					Return .T.            
		        EndIf				
		    Case Len(::aUrlParms) == 0        
				SE4->(DbCloseArea())
			    ::SetResponse(messages(404,Nil))
			Return .T.
		End Case
	Else		
		SE4->(DbCloseArea())
		::SetResponse(messages(500,Nil))
		Return .T.            
	EndIf	 
				
 
//----------------------------------------
// POST
//----------------------------------------
WSMETHOD POST WSSERVICE SISRESTSE4

Local cResponse := ''
Local aDados := {}
Local oCondPgto := nil
Local logError := ''
Local cCodCond := ''
Private lMsErroAuto := .F.

//Define o tipo de retorno do metodo
::SetContentType("application/json")

// Registra no console a chamada do metodo
conOut('SISRESTSE4 - POST METHOD')
	
If FWJsonDeserialize(::GetContent(),@oCondPgto) 
	
	DbSelectAre("SE4")
	SE4->(dbSetOrder(1)) // define índice
	SE4->(dbGoBottom()) // posiciona no último registro
	
	cCodCond := Soma1(SE4->E4_CODIGO) 
						
	aDados:= {;
		{"E4_FILIAL",xFilial("SE4"),Nil},;
		{"E4_CODIGO",cCodCond,Nil},;
		{"E4_TIPO",oCondPgto:E4_TIPO,Nil},;
		{"E4_COND", Substring(AllTrim(oCondPgto:E4_COND), 1,TAMSX3("E4_COND")[1]),Nil},;
		{"E4_DESCRI",Substring(oCondPgto:E4_DESCRI, 1,TAMSX3("E4_DESCRI")[1]),Nil};
	}
	MSExecAuto({|x,y| Mata360(x,y)},aDados,3)  //Função para inserir
	
	If lMsErroAuto
		logError := mostraErro()  
		::SetResponse(messages(400,logError))			
		Return .T.
	Else
		cResponse := '{'
		cResponse += '"status":200,'				        
		cResponse += '"response":{'
			cResponse += '"E4_CODIGO": "'+ cCodCond + '",'
			cResponse += '"E4_TIPO": "' + oCondPgto:E4_TIPO + '",'
			cResponse += '"E4_COND": "'+ Substring(AllTrim(oCondPgto:E4_COND), 1,TAMSX3("E4_COND")[1]) +'",'
			cResponse += '"E4_DESCRI": "'+ Substring(oCondPgto:E4_DESCRI, 1,TAMSX3("E4_DESCRI")[1]) +'"'
			cResponse += '}'
	   cResponse += '}'		   
	EndIf
	SE4->(DbCloseArea())					
	::SetResponse(cResponse)
	Return .T.
	
Else	 
	::SetResponse(messages(500,Nil))
	Return .T.     
	       
EndIf	
	 
SE4->(DbCloseArea())
Return .T.


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
