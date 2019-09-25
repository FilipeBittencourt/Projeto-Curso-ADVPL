#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVSWEBSRV.CH"

#DEFINE LIBERADO "LIBERADO"
#DEFINE BLOQUEADO "BLOQUEADO"
#DEFINE CANCELADO "CANCELADO"

/*/{Protheus.doc} TINWSRetornoProposta
@description Web Service SERVER que recebe retorno das propostas - executado pelo motor Neurotech
@author Pontin / Facile Sistemas
@since 02/01/2019
@version 1.0
@url http://localhost:8999/UNIAO_RET_NEUROTECH.apw?WSDL
/*/
WSSTRUCT DataRetorno
	WSDATA Status   		AS String
	WSDATA Descricao 		AS String
ENDWSSTRUCT


WSSERVICE UNIAO_RET_NEUROTECH

	//|Entrada |
	WSDATA Login			AS String
	WSDATA Id_Proposta		AS String
	WSDATA Novo_Status 		AS String
	WSDATA Usuario_Mesa   	AS String
	WSDATA Lim_Credito   	AS Float
	WSDATA Venc_Limite   	AS String
	WSDATA Usuario_Mesa   	AS String
	WSDATA Observacao   	AS String OPTIONAL
	WSDATA DTNeurotech   	AS String OPTIONAL

	//|Saída |
	WSDATA Retorno			AS DataRetorno

	//|Métodos |
	WSMETHOD RetornoProposta

ENDWSSERVICE


//-------------------------------------------------------------------
/*/{Protheus.doc} RetornoProposta
Metodo que será consumido pela Neurotech
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
WSMETHOD RetornoProposta WSRECEIVE Login,Id_Proposta,Novo_Status,Usuario_Mesa,Lim_Credito,Venc_Limite,Observacao,DTNeurotech WSSEND Retorno WSSERVICE UNIAO_RET_NEUROTECH

	Local lReturn	:= .T.
	Local lContinua	:= .T.
	Local nRecZZ8	:= 0
	Local cTexto	:= ""
	Local cQuery	:= ""
	Local cStatus	:= ""
	Local cLogin	:= SuperGetMV("MV_YLOGNEU",.T.,"UNIAO2019")
	Local oElimiResC := TINEliminaResiduoPVController():New()

	//|Autentica o consumo |
	If lContinua .And. cLogin <> Login

		Retorno:Status		:= "ERRO"
		Retorno:Descricao	:= "LOGIN INVALIDO"

		lContinua	:= .F.

	EndIf

	//|Valida as variaveis recebidas |
	If lContinua

		If Empty(Id_Proposta) .Or. Empty(Novo_Status) .Or. Empty(Usuario_Mesa)

			Retorno:Status		:= "ERRO"
			Retorno:Descricao	:= "CAMPOS OBRIGATORIOS NAO INFORMADOS"

			lContinua	:= .F.

		EndIf

		//|Valida Status |
		If lContinua .And. !(Novo_Status == LIBERADO .Or. Novo_Status == BLOQUEADO .Or. Novo_Status == CANCELADO)

			Retorno:Status		:= "ERRO"
			Retorno:Descricao	:= "STATUS INVALIDO"	
			lContinua	:= .F.

		EndIf


		//|Valida se a proposta existe |
		If lContinua
			
			cQuery	:= " SELECT ZZ8.R_E_C_N_O_ AS RECZZ8, ZZ8_STATUS "
			cQuery	+= " FROM " + RetSqlName("ZZ8") + " ZZ8 "
			cQuery	+= " WHERE ZZ8_CNTNEU = " + ValToSql(Id_Proposta)
			//cQuery	+= "	AND ZZ8_STATUS = '5' "
			cQuery	+= "	AND D_E_L_E_T_ = '' "
			cQuery	+= "	order by ZZ8_DTENVI DESC ;  "


			If Select("__TRB") > 0
				__TRB->(dbCloseArea())
			EndIf

			TcQuery cQuery New Alias "__TRB"

			__TRB->(dbGoTop())

			//ConOut(cValToChar(cQuery))

			//|Não encontrou a proposta na ZZ8 |
			If !__TRB->(EoF()) //Achou
				If __TRB->ZZ8_STATUS == '5'					
					nRecZZ8		:= __TRB->RECZZ8
					lContinua	:= .T.
				Else			
					Retorno:Status		:= "ERRO"
					Retorno:Descricao	:= "A PROPOSTA JA FOI PROCESSADA."					
					lContinua	:= .F.
				EndIf
					
			Else // Não achou a proposta
				Retorno:Status		:= "ERRO"
				Retorno:Descricao	:= "NÃO ENCONTRAMOS A PROPOSTA NO SISTEMA."
				lContinua	:= .F.

			EndIf

		EndIf

		//|Atualiza a proposta |
		If lContinua .And. nRecZZ8 > 0

			dbSelectArea("ZZ8")
			ZZ8->(dbSetOrder(1))
			ZZ8->(dbGoTo(nRecZZ8))

			Venc_Limite	:= cValToChar(Venc_Limite)

			//|Atualiza o log |
			cTexto := "DATA: " + DtoC(dDataBase) + CRLF
			cTexto += "HORA: " + Time() + CRLF
			cTexto += "NOVO STATUS: " + Novo_Status + CRLF
			cTexto += "LIMITE CRÉDITO: " + cValToChar(Lim_Credito) + CRLF
			cTexto += "VENCTO LIMITE: " + Venc_Limite + CRLF
			cTexto += "MESA: " + Usuario_Mesa + CRLF
			cTexto += "OBSERVACAO: " + FwNoAccent(Observacao)

			If Novo_Status == LIBERADO
				cStatus = "4" 
			ElseIf  Novo_Status == BLOQUEADO
				cStatus = "2"
			Else //CANCELADO
				cStatus = "6"
			EndIf

 

			RecLock("ZZ8",.F.)
			ZZ8->ZZ8_MOTLIB	:= cTexto
			ZZ8->ZZ8_STATUS	:=  cStatus
			ZZ8->ZZ8_LIMCAL := IIf(Empty(Lim_Credito),0, Lim_Credito)  
			ZZ8->(MsUnLock())
	 

			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If !SC5->(dbSeek(ZZ8->ZZ8_FILIAL + ZZ8->ZZ8_NUMPED))
				lContinua	:= .F.
			EndIf
		

			//|Atualiza o pedido de venda |
			If SC5->C5_YSTATUS == "X"

				If lContinua .And. Novo_Status == LIBERADO				

					RecLock("SC5",.F.)
					SC5->C5_YSTATUS := "1"  // liberar pedido
					SC5->(MsUnLock())				

				ElseIf lContinua .And. (Novo_Status == CANCELADO .Or. Novo_Status == BLOQUEADO)			 

					RecLock("SC5",.F.)
					SC5->C5_YSTATUS := "8"  // 8 - EXCLUIR ( PARA BLOQUEADO e CANCELADO )
					SC5->(MsUnLock())					
					oElimiResC:ElimiResid(SC5->C5_NUM)//Elimina residuo do pedido se vier BLOQUEADO ou CANCELADO

				EndIf

				// COLOCANCO STATUS NO PEDIDO DO CALL CENTER				
				SUA->(DbSetOrder(8)) //UA_FILIAL, UA_NUMSC5, R_E_C_N_O_, D_E_L_E_T_
				SUA->(DbGoTop())
				If(SUA->(DbSeek(XFilial("SUA")+SC5->C5_NUM)))			 
					RecLock("SUA", .F.)
					SUA->UA_YNEUROT := Novo_Status
					SUA->(MsUnLock())
				EndIf

				//ATUALIZA  DATA validade de CREDITO NEUROTECH PARA liberar compras apenas com titulos em atraso 
				If !Empty(DTNeurotech)
					SA1->(DbSetOrder(1))
					SA1->(DbGoTop())
					If SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))			 
						RecLock("SA1",.F.)
						SA1->A1_YDTNEU := CtoD(DTNeurotech)						
						SA1->(MsUnLock())
					EndIf
				EndIf

			EndIf
			

			//|Atualiza o cliente |
			If lContinua .And. !Empty(Lim_Credito)

				dbSelectArea("SA1")
				SA1->(dbSetOrder(1))
				If SA1->(dbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

					RecLock("SA1",.F.)
					SA1->A1_LC		:= Lim_Credito
					SA1->A1_VENCLC	:= IIf(Empty(Venc_Limite),SA1->A1_VENCLC,CtoD(Venc_Limite))
					SA1->(MsUnLock())

				EndIf

			EndIf

			Retorno:Status		:= "OK"
			Retorno:Descricao	:= "REQUISICAO PROCESSADA COM SUCESSO"

		EndIf

	EndIf

RETURN lReturn
