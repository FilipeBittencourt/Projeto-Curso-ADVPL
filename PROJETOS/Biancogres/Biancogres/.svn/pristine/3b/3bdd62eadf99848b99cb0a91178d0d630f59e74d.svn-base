#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} TTransferenciaInterna
//TODO Descrição auto-gerada.
@author Pedro Henrique
@since 26/02/2019
@version 1.0
@return ${return}, ${return_description}

@type class
/*/

Class TTransferenciaInterna From LongClassName
	
	Data nOpcao		
	
	Data cDocumento		
	Data cItem		
	
	Data cProdOrigem
	Data cLocalOrigem
	Data nQuantOrigem
	
	Data cProdDestino
	Data cLocalDestino
	
	Data cLog
	Data cMensagem
	Data lOk	
	
	Method New(nOpcao, cDocumento, cItem, cProdOrigem, cLocalOrigem, nQuantOrigem, cProdDestino, cLocalDestino) Constructor
	Method Executar()
	Method GetSaldo()
	
EndClass

Method New(nOpcao, cDocumento, cItem, cProdOrigem, cLocalOrigem, nQuantOrigem, cProdDestino, cLocalDestino) Class TTransferenciaInterna	
		
	::cLog		:= ""
	::cMensagem	:= ""
	::lOk		:= .T.
	
	::nOpcao		:= nOpcao
	
	::cDocumento	:= IIF(Empty(cDocumento), GetSxeNum("SD3", "D3_DOC"), cDocumento) 		
	::cItem			:= IIF(Empty(cItem), "0001", cItem)
	
	DbSelectArea("SD3")
	SD3->(dbSetOrder(2))
	If SD3->(dbSeek(xFilial("SD3") + ::cDocumento))
		While .T.
			::cDocumento    := GetSxeNum("SD3", "D3_DOC")
			SD3->(dbSetOrder(2))
			If !SD3->(dbSeek(xFilial("SD3") + ::cDocumento))
				Exit
			EndIf
		EndDo
	EndIf
	
	::cProdOrigem	:= cProdOrigem
	::cLocalOrigem	:= cLocalOrigem
	::nQuantOrigem	:= nQuantOrigem	
	
	::cProdDestino	:= cProdDestino
	::cLocalDestino := cLocalDestino
	
Return(Self)

Method GetSaldo() Class TTransferenciaInterna
	
	Local aArea			:= SB2->(GetArea())
	Local nSaldo		:= 0
	
	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	
	If SB2->(DbSeek(xFilial("SB2") + PADR(::cProdOrigem, TamSx3("B1_COD")[1]) + ::cLocalOrigem))

		nSaldo := (SB2->B2_QATU - SB2->B2_RESERVA -  SB2->B2_QACLASS)

	EndIf
	
	SB2->(DbCloseArea())
	
	SB2->(RestArea(aArea))
	
Return nSaldo


Method Executar() Class TTransferenciaInterna

	Local aAuto			:= {}
	Local aLinha 		:= {}
	Local cPath			:= GetSrvProfString("Startpath","")
	Local cFileLog		:= Criatrab(,.F.) + ".log"
	Local nSaldo		:= ::GetSaldo()
	Local cTempo		:= Time()
	Local dDataEmis		:= Iif(cTempo >= '00:00:00' .And. cTempo <= '05:59:59',DaySub(dDatabase,1),dDataBase)
	
	
	Private lMsErroAuto := .F.
	
	::cLog += "Produto origem		: " + ::cProdOrigem + CRLF 
	::cLog += "Armazem origem		: " + ::cLocalOrigem + CRLF
	::cLog += "Produto destino		: " + ::cProdDestino + CRLF 
	::cLog += "Armazem destino		: " + ::cLocalDestino + CRLF
	
	Begin Transaction   	
						
		//Origem 
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(xFilial("SB1") + ::cProdOrigem))
		
			
			If (::nQuantOrigem <= nSaldo)
			
				aAdd(aAuto, {::cDocumento, dDataEmis})
			
				aLinha := {}
			
				aAdd(aLinha, {"ITEM"		, ::cItem 				, Nil})
				aAdd(aLinha, {"D3_COD"		, SB1->B1_COD			, Nil}) //Cod Produto origem 
				aAdd(aLinha, {"D3_DESCRI"	, SB1->B1_DESC			, Nil}) //descr produto origem 
				aAdd(aLinha, {"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida origem 
				aAdd(aLinha, {"D3_LOCAL"	, ::cLocalOrigem		, Nil}) //armazem origem 
				aAdd(aLinha, {"D3_LOCALIZ"	, PadR("", TamSx3('D3_LOCALIZ')[1]), Nil}) //InFormar endereço origem
			
				//Destino 
				If SB1->(DbSeek(xFilial("SB1") + ::cProdDestino))
				
					DbSelectArea("SB2")
					SB2->(DbSetOrder(1))
					If !SB2->(DbSeek(xFilial("SB2") + PADR(::cProdDestino, TamSx3("B1_COD")[1]) + ::cLocalDestino))
						
						CriaSB2(::cProdDestino, ::cLocalDestino)
					
						::cLog += "Mensagem		: " + "Criado SB2 do produto destino." + CRLF
			
					EndIf
					
					aAdd(aLinha, {"D3_COD"		, SB1->B1_COD			, Nil}) //cod produto destino 
					aAdd(aLinha, {"D3_DESCRI"	, SB1->B1_DESC			, Nil}) //descr produto destino 
					aAdd(aLinha, {"D3_UM"		, SB1->B1_UM			, Nil}) //unidade medida destino 
					aAdd(aLinha, {"D3_LOCAL"	, ::cLocalDestino		, Nil}) //armazem destino 
					aAdd(aLinha, {"D3_LOCALIZ"	, PadR("", TamSx3('D3_LOCALIZ')[1]), Nil}) //InFormar endereço destino
				
					aAdd(aLinha, {"D3_NUMSERI"	, ""					, Nil}) //Numero serie
					aAdd(aLinha, {"D3_LOTECTL"	, ""					, Nil}) //Lote Origem
					aAdd(aLinha, {"D3_NUMLOTE"	, ""					, Nil}) //sublote origem
					aAdd(aLinha, {"D3_DTVALID"	, ''					, Nil}) //data validade 
					aAdd(aLinha, {"D3_POTENCI"	,  0					, Nil}) // Potencia
					aAdd(aLinha, {"D3_QUANT"	,  ::nQuantOrigem		, Nil}) //Quantidade
					aAdd(aLinha, {"D3_QTSEGUM"	,  0					, Nil}) //Seg unidade medida
					aAdd(aLinha, {"D3_ESTORNO"	, ""					, Nil}) //Estorno 
					aAdd(aLinha, {"D3_NUMSEQ"	, ""					, Nil}) // Numero sequencia D3_NUMSEQ
				
					aAdd(aLinha, {"D3_LOTECTL"	, ""					, Nil}) //Lote destino
					aAdd(aLinha, {"D3_NUMLOTE"	, ""					, Nil}) //sublote destino 
					aAdd(aLinha, {"D3_DTVALID"	, ''					, Nil}) //validade lote destino
					aAdd(aLinha, {"D3_ITEMGRD"	, ""					, Nil}) //Item Grade
				
					aAdd(aLinha, {"D3_CODLAN"	, ""					, Nil}) //cat83 prod origem
					aAdd(aLinha, {"D3_CODLAN"	, ""					, Nil}) //cat83 prod destino 
				
					aAdd(aAuto, aLinha)
				
					MSExecAuto({|x,y| Mata261(x,y)}, aAuto, ::nOpcao)
				
					If lMsErroAuto
			
						::cLog	+= "Mensagem		: " + AllTrim(MostraErro(cPath, cFileLog))+CRLF
						::lOk	:= .F.
						::cMensagem	:= "Erro ao gravar transferência."
						
					Else
						
						::cLog	+= "Mensagem		: " + "Processo concluido." + CRLF
						::lOk	:= .T.			
						::cMensagem	:= "Transferência concluida com sucesso."
							
					EndIf
					
				Else
		
					::cLog	+= "Mensagem		: " + "Produto destino não encontrado." + CRLF
					::lOk	:= .F.
					::cMensagem	:= "Produto destino não encontrado."
					
				EndIf	
			
			Else
				
				::cLog	+= "Mensagem		: " + "Produto não tem saldo suficiente. Saldo: "+cvaltochar(nSaldo)+"." + CRLF
				::lOk	:= .F.
				::cMensagem	:= "Produto não tem saldo suficiente. Saldo: "+cvaltochar(nSaldo)+"."
			
			EndIf
				
		Else
			
			::cLog	+= "Mensagem		:" + "Produto origem não encontrado." + CRLF
			::lOk	:= .F.
			::cMensagem	:= "Produto não encontrado."
			
		EndIf
		
		SB1->(DbCloseArea())
		SB2->(DbCloseArea())

	End Transaction
	
Return()
