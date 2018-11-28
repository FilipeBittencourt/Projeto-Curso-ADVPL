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
	cResponse := '{"response":['
	While (!SE4->(EOF()))
	    cResponse += '{'
	    cResponse += '"E4_CODIGO":"'+ AllTrim(SE4->E4_CODIGO)+'",'
	    cResponse += '"E4_TIPO":"'+ AllTrim(SE4->E4_TIPO)+'",'
	    cResponse += '"E4_COND":"'+ AllTrim(SE4->E4_COND)+'",'
	    cResponse += '"E4_DESCRI":"'+ AllTrim(SE4->E4_DESCRI)+'"'
	    cResponse += '},'
        SE4->(DbSkip())// salta para proximo registro
	EndDo
	cResponse += 	']}'
	cResponse := STRTRAN(cResponse,",]}","]}")

SE4->(DbCloseArea())
::SetResponse(cResponse)
Return .T.


//----------------------------------------
// PUT
//----------------------------------------
WSMETHOD PUT WSSERVICE SISRESTSE4

Local cResponse := ''
Local aDados := {}
Local oCondPgto := nil
Local logError := ''
Local lRet := .T.
Private lMsErroAuto := .F.

//Define o tipo de retorno do metodo
::SetContentType("application/json")

	If FWJsonDeserialize(::GetContent(),@oCondPgto)
		// Valida se hoube passagem de parametro via url
		If Len(::aUrlParms) == 0			
			cResponse := errorResponseMessages(404,Nil)			
		Else
			aDados:= {;
				{"E4_FILIAL","01",Nil},;
				{"E4_CODIGO",oCondPgto:E4_CODIGO,Nil},;
				{"E4_TIPO",oCondPgto:E4_TIPO,Nil},;
				{"E4_COND",AllTrim(oCondPgto:E4_COND),Nil},;
				{"E4_DESCRI",oCondPgto:E4_DESCRI,Nil};
			}
			// Alteracao do cadastro de fornecedor via rotina padrao
			MSExecAuto({|x,y,z| Mata360(x,y,z)},aDados,{},4)
			If lMsErroAuto
				logError := mostraErro()	    
				cResponse := '{'
					cResponse += '"status":400,'
					cResponse += '"message":"Bad request",'
					cResponse += '"response":"'+ logError +'"'        
				cResponse += '}'
			Else
				cResponse := '{'
		        cResponse += '"status":200,'
		        cResponse += '"message":"Success",'
		        cResponse += '"response":{'
		        	cResponse += '"ID":"'+oCondPgto:E4_CODIGO+'",'
		        	cResponse += '"E4_TIPO":'+oCondPgto:E4_TIPO+','
		        	cResponse += '"E4_COND":"'+ AllTrim(oCondPgto:E4_COND)+'",'
		        	cResponse += '"E4_DESCRI":"'+oCondPgto:E4_DESCRI+'"'
		        	cResponse += '}'
		       cResponse += '}'
			EndIf
		EndIf
	Else
		cResponse := errorResponseMessages(500,Nil)		
	EndIf
	::SetResponse(cResponse)
Return .T.


//----------------------------------------
// POST
//----------------------------------------
WSMETHOD POST WSSERVICE SISRESTSE4

Local cResponse := ''
Local aDados := {}
Local oCondPgto := nil
Local logError := ''
Private lMsErroAuto := .F.

//Define o tipo de retorno do metodo
::SetContentType("application/json")
DbSelectAre("SE4")
SE4->(dbSetOrder(1)) // define índice
SE4->(dbGoBottom()) // posiciona no último registro

If FWJsonDeserialize(::GetContent(),@oCondPgto)
	  aDados:= {;
	  	{"E4_FILIAL","01",Nil},;
	    {"E4_CODIGO",oCondPgto:E4_CODIGO,Nil},;
	    {"E4_TIPO",oCondPgto:E4_TIPO,Nil},;
	    {"E4_COND",AllTrim(oCondPgto:E4_COND),Nil},;
	    {"E4_DESCRI",oCondPgto:E4_DESCRI,Nil};
	  }
	    // Insert via rotina padrao
		MSExecAuto({|x,y| Mata360(x,y)},aDados,3)

		If lMsErroAuto
			logError := mostraErro()	    
			cResponse := '{'
				cResponse += '"status":400,'
				cResponse += '"message":"Bad request",'
				cResponse += '"response":"'+ logError +'"'        
			cResponse += '}'		
		Else	
			cResponse := '{'
	        cResponse += '"status":200,'
	        cResponse += '"message":"Success",'
	        cResponse += '"response":{'
	        	cResponse += '"ID":"'+oCondPgto:E4_CODIGO+'",'
	        	cResponse += '"E4_TIPO":'+oCondPgto:E4_TIPO+','
	        	cResponse += '"E4_COND":"'+ AllTrim(oCondPgto:E4_COND)+'",'
	        	cResponse += '"E4_DESCRI":"'+oCondPgto:E4_DESCRI+'"'
	        	cResponse += '}'
	       cResponse += '}'    
	    EndIf
Else	
	cResponse := errorResponseMessages(500,Nil)	
EndIf
	// Fecha tabela
	If Select("SE4") > 0
		SE4->(DbClearFilter())
		SE4->(DbCloseArea())
	EndIf
	::SetResponse(cResponse)
Return .T.

 

Static Function errorResponseMessages(status, logError)

Local cResponse := ''

 
	If INT(status) == 500 
		cResponse := '{'
			cResponse += '"status":500,'
			cResponse += '"message":"Internal server error",'
			cResponse += '"response":"json deserialize fault"'        
		cResponse += '}'
	ElseIf INT(status) == 404
		cResponse := '{'
			cResponse += '"status":404,'
			cResponse += '"message":"Bad request",'
			cResponse += '"response":"Code not found"'        
		cResponse += '}'
   /*ElseIf INT(status) == 400
		cResponse := '{'
			cResponse += '"status":400,'
			cResponse += '"message":"Bad request",'
			cResponse += '"response":"'+ logError +'"'        
		cResponse += '}'*/
   EndIf      
   ::SetResponse(cResponse)	
Return .T.
