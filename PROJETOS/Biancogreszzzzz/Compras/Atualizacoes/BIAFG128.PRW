#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG128
@author Gabriel Rossi Mafioletti
@since 03/06/2020
@version 1.0
@description Tela de Cancelamento de Processo de Pré-Nota e Nota (BIZAGI)  
@type function
/*/

User Function BIAFG128()

	If ValidPerg()
	
		fCancProc()
	
	EndIf

Return

Static Function fCancProc()

	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias
	
		SELECT COUNT(*) QTD
		FROM BZINTEGRACAO
		WHERE PROCESSO_NOME = 'RM'
			AND PROCESSO_BIZAGI = %Exp:MV_PAR01%
	EndSql
	
	If (_cAlias)->QTD > 0
		(_cAlias)->(DbCloseArea())
		_cAlias	:=	GetNextAlias()
		
		BeginSql Alias _cAlias
		
			SELECT ISNULL(ID,0) ID
			FROM BZINTEGRACAO
			WHERE PROCESSO_NOME = 'RM'
				AND PROCESSO_BIZAGI = %Exp:MV_PAR01%
				AND STATUS = 'IM'
		EndSql		
		
		If (_cAlias)->ID > 0
			TcSqlExec("UPDATE BZINTEGRACAO SET STATUS = 'CN' WHERE ID = " + Alltrim(Str((_cAlias)->ID)))
			MsgInfo("Processo Cancelado Com Sucesso!","BIAFG128")
		Else
			(_cAlias)->(DbCloseArea())
			_cAlias	:=	GetNextAlias()
			
			BeginSql Alias _cAlias
			
				SELECT ISNULL(ID,0) ID
				FROM BZINTEGRACAO
				WHERE PROCESSO_NOME = 'RM'
					AND PROCESSO_BIZAGI = %Exp:MV_PAR01%
					AND STATUS = 'CN'
			EndSql			
			
			If (_cAlias)->ID > 0
				MsgInfo("Processo já Cancelado Anteriormente!","BIAFG128")
			Else
				MsgInfo("O Processo ainda não foi concluído, não será possível cancelar!","BIAFG128")
			EndIf
		EndIf
		
	Else
		MsgInfo("Processo digitado não existe!","BIAFG128")
	EndIf
	(_cAlias)->(DbCloseArea())
Return


Static Function ValidPerg()

	local cLoad	    := "BIAFG128" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	
	
	MV_PAR01 :=	SPACE(9)
	
	aAdd( aPergs ,{1,"Processo " 		  	,MV_PAR01 ,"RM-999999"  ,"",''  ,'.T.',70,.T.})
	
	If ParamBox(aPergs ,"Cancelamento de Pocesso Bizagi",,,,,,,,,.T.,.T.)
	
		lRet := .T.
	
	EndIf
	
Return lRet
