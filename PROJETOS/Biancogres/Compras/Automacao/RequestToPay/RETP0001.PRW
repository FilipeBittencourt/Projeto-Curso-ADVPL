#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.CH"

User Function RETP0001()
	
	Local nI			:= 0
	Local nJ			:= 0
	Local oList 		:= Nil
	Local cEmp			:= "01"
	Local cFil			:= "01"
	Local cUser			:= "FACILE"
	Local cSenhaUser	:= "TESTE06"
	
	Local oAbstract 	:=	Nil
	Local lLog			:= .F.
	
	Local cErro		:= ""
	Local bErro 	:= ErrorBlock( { |oErr| cErro := oErr:Description })
	
	If Select("SX6") <= 0
		RPCSetEnv(cEmp, cFil, cUser, cSenhaUser)	
	EndIf
	
	oIntAE		:= TBizagiIntegracaoAE():New()
	oList		:= oIntAE:Get()//retorna lista de AE n�o integrada
	
	Conout('Executando fun��o: RETP0001')
	
	If (lLog)
		oAbstract := TAbstractClass():New()
		oAbstract:oPro:Start()	
		oAbstract:oPro:oWFP:cMethod := "Inclus�o Autoriza��o de Entrega" //Campos para workflow
	EndIf
	
	For nI := 1 To oList:GetCount()
		
		cEmp	:= oList:GetItem(nI):cEmp
		cFil	:= oList:GetItem(nI):cFil
		
		If (cEmpAnt <> cEmp .Or. cFilAnt <> cFil)
			RpcClearEnv()
			RPCSetEnv(cEmp, cFil, cUser, cSenhaUser)	
		EndIf
		
		Begin Transaction
		
			BEGIN SEQUENCE	
				
				oList:GetItem(nI):cNumero	:= GetNumSC7()
				oList:GetItem(nI):dEmissao	:= dDataBase
				
				oAE				:= TAutorizacaoEntrega():New()//executa execauto
				oAEResult		:= oAE:Execute(oList:GetItem(nI))
				
				If (oAEResult:lOk)
					
					For nJ := 1 To oList:GetItem(nI):oItens:GetCount()
						oItem := oList:GetItem(nI):oItens:GetItem(nJ)
						oIntAEConfirm	:= TBizagiIntegracaoAE():New()
						oIntAEConfirm:ConfirmReg(oItem:cID)//confirma item como integrado
					Next nJ
					
					MsgAlert('<p style="color:green">Autoriza��o de entrega inserida com sucesso.</p>', 'Sucesso')
				Else
					MsgAlert('<p style="color:red">'+oAEResult:cMensagem+'</p>', 'Erro')
				EndIf
				
				//envio de log
				If (!oAEResult:lOk .And. lLog)
					oAbstract:oLog:cIDProc 	:= oAbstract:oPro:cIDProc
					oAbstract:oLog:cOperac 	:= "N"	
					oAbstract:oLog:cMetodo 	:= "IBZ_IAE"
					oAbstract:oLog:cTabela 	:= RetSQLName("SC7")  	//tabela de origem
					oAbstract:oLog:nIDTab 	:= oList:GetItem(nI):cID		//recno da tabela de origem
					oAbstract:oLog:cRetMen	:= oAEResult:cMensagem	//mensagem do erro/retorno
					oAbstract:oLog:cHrFin 	:= Time()
					oAbstract:oLog:cEnvWF 	:= 'S' //SIM	
					oAbstract:oLog:Insert()
					
					If (lErroReg)
						oAbstract:oPro:oWFP:cMenRet := oAEResult:cMensagem
						oAbstract:oPro:oWFP:AddMensagem("Processo Bizagi", oList:GetItem(nI):cID) 
					EndIf
				EndIf
				
			End Sequence
	
			ErrorBlock( bErro )
			
			If ( ValType(cErro) <> "U" .And. !Empty(cErro) ) .Or. !oAEResult:lOk
				DisarmTransaction()
			EndIf
			
		End Transaction 	
		
	Next nI
	
	RpcClearEnv()   
	
Return
