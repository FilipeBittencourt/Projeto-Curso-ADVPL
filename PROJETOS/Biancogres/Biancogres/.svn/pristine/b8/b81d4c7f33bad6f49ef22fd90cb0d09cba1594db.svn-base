#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"



/*/{Protheus.doc} BIAFG066
@author Gabriel Rossi Mafioletti
@since 27/09/2018
@version 1.0
@description Rotina de Envio de Produtos para o Ecosis
@type function
/*/

User Function BIAFG066()


	Processa({|| fProcessa()})
	
Return

Static Function fProcessa()

	Local _cAlias	:= GetNextAlias()
	Local nTotReg
	Local nRegAtu	:=	0
	
	BeginSql Alias _cAlias
		SELECT R_E_C_N_O_ REC
		FROM %TABLE:SB1% SB1
		WHERE B1_TIPO = 'PA'
			AND B1_YSTATUS = '1'
			AND B1_MSBLQL <> '1'
			AND %NotDel%
	EndSql
		
	Count To nTotReg
	ProcRegua(nTotReg)
	
	(_cAlias)->(DbGoTop())	
		
	While (_cAlias)->(!EOF())
		nRegAtu++
		SB1->(DbGoTo((_cAlias)->REC))
		IncProc("Processando Registro - " + Alltrim(Str(nRegAtu)) + "/" + Alltrim(Str(nTotReg)))
		If SB1->(!EOF())
			U_EXPECO(2)			
			msBlqProd := IIf(SB1->B1_MSBLQL == "1" .or. SB1->B1_YSTATUS $ "2/3", "1", " ")
			U_UpProdEco(SB1->B1_COD, msBlqProd, SB1->B1_CODBAR, SB1->B1_PESO)						
		EndIf
		(_cAlias)->(DbSkip())
	EndDo

Return