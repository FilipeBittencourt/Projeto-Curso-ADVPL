#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.CH"

User Function RETP0003()
	
	Local nI			:= 0
	Local nJ			:= 0
	Local oList 		:= Nil
	Local cEmp			:= "01"
	Local cFil			:= "01"
	Local cUser			:= ""
	Local cSenhaUser	:= ""
	
	Local oAbstract 	:=	Nil
	Local lLog			:= .F.
	
	Public _cTpFreteA	:= ""
	
	//Local bError		:= { |e| oError := e , Break(e) }
	//Local bErrorBlock	:= ErrorBlock( bError )
	//Private oError		:= Nil
	
	RPCSetEnv(cEmp, cFil, cUser, cSenhaUser)
	
	Conout('Executando função: RETP0003')	
	
	oPIntCC		:= TPortalIntegracaoCC():New()
	oList		:= oPIntCC:Get()//retorna lista de AE não integrada
	
	
	If (lLog)
		oAbstract := TAbstractClass():New()
		oAbstract:oPro:Start()	
		oAbstract:oPro:oWFP:cMethod := "Inclusão/Atualização Cotação" //Campos para workflow
	EndIf
	
	For nI := 1 To oList:GetCount()
		
		cEmp	:= oList:GetItem(nI):cEmp
		cFil	:= oList:GetItem(nI):cFil
		
		If (cEmpAnt <> cEmp .Or. cFilAnt <> cFil)
			RpcClearEnv()
			RPCSetEnv(cEmp, cFil, cUser, cSenhaUser)	
		EndIf
		
	//	BEGIN SEQUENCE	
			
			_lNovo	:= .F.
			If (Empty(oList:GetItem(nI):cNumero))
				_lNovo	:= .T.
			EndIf
			
			oCC			:= TCotacaoCompra():New()//executa execauto
			oCCResult	:= oCC:Execute(oList:GetItem(nI), _lNovo)
			
			If (oCCResult:lOk)
				
				For nJ := 1 To oCC:oObj:oItens:GetCount()
					oItem := oList:GetItem(nI):oItens:GetItem(nJ)
					oPIntCCConfirm	:= TPortalIntegracaoCC():New()
					oPIntCCConfirm:ConfirmReg(_lNovo, oItem:cID, oList:GetItem(nI):cNumero, oItem:cItem)//confirma item como integrado
				Next nJ
				
				MsgAlert('<p style="color:green">Cotação inserida/atualizada com sucesso.</p>', 'Sucesso')
				
			Else
				MsgAlert('<p style="color:red">'+oCCResult:cMensagem+'</p>', 'Erro')
			EndIf
			
			//envio de log
			If (!oCCResult:lOk .And. lLog)
				oAbstract:oLog:cIDProc 	:= oAbstract:oPro:cIDProc
				oAbstract:oLog:cOperac 	:= "N"	
				oAbstract:oLog:cMetodo 	:= "IBZ_ICC"
				oAbstract:oLog:cTabela 	:= RetSQLName("SC8")  	//tabela de origem
				oAbstract:oLog:nIDTab 	:= oList:GetItem(nI):cID		//recno da tabela de origem
				oAbstract:oLog:cRetMen	:= oCCResult:cMensagem	//mensagem do erro/retorno
				oAbstract:oLog:cHrFin 	:= Time()
				oAbstract:oLog:cEnvWF 	:= 'S' //SIM	
				oAbstract:oLog:Insert()
				
				If (lErroReg)
					oAbstract:oPro:oWFP:cMenRet := oCCResult:cMensagem
					oAbstract:oPro:oWFP:AddMensagem("Processo Bizagi", oList:GetItem(nI):cID) 
				EndIf
			EndIf
			
			
	//	RECOVER //executado caso ocorra um erro 
			
	//	END SEQUENCE
		
	//	ErrorBlock( bErrorBlock )
	
	//	If Valtype(oError) == "O" //caso erro
	//		ConOut('Erro integraçao item: '+cvaltochar(nI))
	//	EndIf
		
	Next nI
	
	RpcClearEnv()
	
Return