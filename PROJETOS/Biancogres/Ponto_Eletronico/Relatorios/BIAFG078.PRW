#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG078
@author Gabriel Rossi Mafioletti
@since 27/12/2018
@version 1.0
@description Processamento da tabela SPB para ajustar o Saldo(Sempre manter apenas uma verba)
@type function
/*/

User Function BIAFG078()

	If MsgYesNo("Essa rotina irá atualizar os valores de banco de horas com o intuito de aglutinar os lançamentos somente em crédito ou débito, resultando em somente uma verba para a folha de pagamento. Deseja Continuar?")
	
		Processa({|| fProcess()})
	
	EndIf

Return

Static Function fProcess()

	Local _cPdProv	:=	fGetPdBH('023')
	Local _cPdDesc	:=	fGetPdBH('024')
	Local _cAlias	:=	GetNextAlias()
	Local _cSql		:=	""
	
	BeginSql Alias _cAlias
	
		SELECT SPB.PB_FILIAL
			,SUBSTRING(SPB.PB_DATA, 1, 6) ANOMES
			,SPB.PB_MAT
			,SUM(CASE 
					WHEN SPB.PB_PD = %Exp:_cPdProv%
						THEN SPB.PB_HORAS
					ELSE 0
					END) AS CREDITO
			,SUM(CASE 
					WHEN SPB.PB_PD = %Exp:_cPdDesc%
						THEN SPB.PB_HORAS
					ELSE 0
					END) AS DEBITO
		FROM %TABLE:SPB% SPB
		WHERE SPB.PB_PD IN (
				%Exp:_cPdProv%
				,%Exp:_cPdDesc%
				)
			AND SPB.%NotDel%
		GROUP BY SPB.PB_FILIAL
			,SPB.PB_MAT
			,SUBSTRING(SPB.PB_DATA, 1, 6)

	EndSql
	
	
	While (_cAlias)->(!EOF())
	
		If (_cAlias)->CREDITO >= (_cAlias)->DEBITO
	
			_cSql	:=	" UPDATE " + RetSqlName("SPB") + " "
			_cSql	+=	" SET PB_HORAS = PB_HORAS * -1, "			
			_cSql	+=	" 		PB_PD = " + ValtoSql(_cPdProv) + " "
			_cSql	+=	"	WHERE PB_FILIAL = " + ValtoSql(xFilial("SPB")) + " "
			_cSql	+=	"			AND PB_MAT = " + ValtoSql((_cAlias)->PB_MAT) + " "
			_cSql	+=	"			AND SUBSTRING(PB_DATA,1,6) = " + ValtoSql((_cAlias)->ANOMES) + " "
			_cSql	+=	"			AND PB_PD = " + ValToSql(_cPdDesc) + " "
			_cSql	+=	"			AND D_E_L_E_T_ = '' "
		Else
		
			_cSql	:=	" UPDATE " + RetSqlName("SPB") + " "
			_cSql	+=	" SET PB_HORAS = PB_HORAS * -1, "
			_cSql	+=	" 		PB_PD = " + ValtoSql(_cPdDesc) + " "
			_cSql	+=	"	WHERE PB_FILIAL = " + ValtoSql(xFilial("SPB")) + " "
			_cSql	+=	"			AND PB_MAT = " + ValtoSql((_cAlias)->PB_MAT) + " "
			_cSql	+=	"			AND SUBSTRING(PB_DATA,1,6) = " + ValtoSql((_cAlias)->ANOMES) + " "
			_cSql	+=	"			AND PB_PD = " + ValToSql(_cPdProv) + " "
			_cSql	+=	"			AND D_E_L_E_T_ = '' "
		EndIF
		
		TcSqlExec(_cSql)
	
		(_cAlias)->(DbSkip())
	
	EndDo
	
	(_cAlias)->(DBCloseArea())
	
Return

Static Function fGetPdBH(_cCodigo)

	Local _cPD	:=	""
	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias
	
		SELECT TOP 1 ISNULL(P9_CODFOL,'') AS COD
			FROM %TABLE:SP9% SP9
				WHERE SP9.P9_FILIAL = %Xfilial:SP9%
					AND SP9.P9_CODIGO = %Exp:_cCodigo%
					AND SP9.%NotDel%
	EndSql

	_cPd	:=	(_cAlias)->COD
	
	(_cAlias)->(DbCloseArea())

Return _cPD