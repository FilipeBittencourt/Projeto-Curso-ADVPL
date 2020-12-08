#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "tbiconn.CH"

User Function RETP0001()
	
	Local nI			:= 0
	Local oList 		:= Nil
	Local cEmp			:= "01"
	Local cFil			:= "01"
	Local cUser			:= "FACILE"
	Local cSenhaUser	:= "TESTE03"
	
	Local oAbstract 	:=	Nil
	Local lLog			:= .F.
	
	Local bError		:= { |e| oError := e , Break(e) }
	Local bErrorBlock	:= ErrorBlock( bError )
	Private oError		:= Nil
	
	RPCSetEnv(cEmp, cFil, cUser, cSenhaUser)	
	
	oIntAE		:= TBizagiIntegracaoAE():New()
	oList		:= oIntAE:Get()//retorna lista de AE n�o integrada
	
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
		
		BEGIN SEQUENCE	
		
			oList:GetItem(nI):cNumero	:= GetNumSC7()
			oList:GetItem(nI):dEmissao	:= dDataBase
			
			oAE				:= TAutorizacaoEntrega():New()//executa execauto
			oAEResult		:= oAE:Execute(oList:GetItem(nI))
			
			If (oAEResult:lOk)
				MsgAlert('<p style="color:green">Autoriza��o de entrega inserida com sucesso.</p>', 'Sucesso')
				oIntAE:ConfirmReg(oList:GetItem(nI):cIDIntegracao)//confirma item como integrado
			Else
				MsgAlert('<p style="color:red">'+oPCResulStruct:cMensagem+'</p>', 'Erro')
			EndIf
			
			//envio de log
			If (!oAEResult:lOk .And. lLog)
				oAbstract:oLog:cIDProc 	:= oAbstract:oPro:cIDProc
				oAbstract:oLog:cOperac 	:= "N"	
				oAbstract:oLog:cMetodo 	:= "IBZ_IAE"
				oAbstract:oLog:cTabela 	:= RetSQLName("SC7")  	//tabela de origem
				oAbstract:oLog:nIDTab 	:= oList:GetItem(nI):cIDIntegracao		//recno da tabela de origem
				oAbstract:oLog:cRetMen	:= oPCResulStruct:cMensagem	//mensagem do erro/retorno
				oAbstract:oLog:cHrFin 	:= Time()
				oAbstract:oLog:cEnvWF 	:= 'S' //SIM	
				oAbstract:oLog:Insert()
				
				If (lErroReg)
					oAbstract:oPro:oWFP:cMenRet := oPCResulStruct:cMensagem
					oAbstract:oPro:oWFP:AddMensagem("Processo Bizagi", oList:GetItem(nI):cIDIntegracao) 
				EndIf
			EndIf
		
		RECOVER //executado caso ocorra um erro 
			
		END SEQUENCE
		
		ErrorBlock( bErrorBlock )
	
		If Valtype(oError) == "O" //caso erro
			ConOut('Erro integra�ao item: '+cvaltochar(nI))
		EndIf
		
	Next nI
	
	RpcClearEnv()   
	
Return