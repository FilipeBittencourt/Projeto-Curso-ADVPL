#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA792
@author Marcos Alberto Soprani
@since 08/11/21
@version 1.0
@description Responsável por apagar os registros gerados a parti da rotina BIA792 - Gera Devolução / Requisição Valorizada
.            para valorizar as movmentações de PA resultado de beneficiamento próprio a partir das requisições de encerra-
.            mento de lote - TM 517
@type function
/*/

User Function BIA792()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private msEnter      := CHR(13) + CHR(10)
	Private msStaExcQy   := 0

	cHInicio := Time()
	fPerg := "BIA792"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	If !ValidPerg()
		Return
	EndIf

	dDataIni := stod(MV_PAR01 + '01')
	dDataFin := UltimoDia(stod(MV_PAR01 + '01'))

	If ( dDataIni <= GetMV("MV_ULMES") .or. dDataFin <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA792 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA792 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA792",fPerg)

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD "
	cSql += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) "
	cSql += " WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	cSql += "       AND D3_EMISSAO BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "' "
	cSql += "       AND D3_DOC = 'DEVVAL517' "
	cSql += "       AND D3_YRFCUST = 'BIA790              ' "
	cSql += "       AND SD3.D_E_L_E_T_ = ' ' "
	TcQuery cSQL New Alias (cQry)

	ProcRegua(RecCount())
	If (cQry)->(CONTAD) > 0

		IncProc("Apagando Registros encontrados na base...")

		If MsgYesNo("Já existem dados para período informado. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "Empresa: [" + cEmpAnt + "]  - ATENÇÃO")

			cSql := " DELETE SD3 "
			cSql += " FROM " + RetSqlName("SD3") + " SD3 (NOLOCK) "
			cSql += " WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
			cSql += "       AND D3_EMISSAO BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "' "
			cSql += "       AND D3_DOC = 'DEVVAL517' "
			cSql += "       AND D3_YRFCUST = 'BIA790              ' "
			cSql += "       AND SD3.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Deletando registros SD3... ",,{|| msStaExcQy := TcSQLExec(cSql) })

			If msStaExcQy < 0

				msErroQuery := TCSQLError()
				Aviso('Erro na Query', "Erro na execução do processamento: " + msEnter + msEnter + msEnter + msErroQuery,{'Ok'},3)

			Else

				Aviso('Processamento Realizado', "Os Registros selecionados foram apagados corretamente. Pode refazer os processos necessários...", {'Ok'}, 3)

			EndIf

		Else

			Aviso('Processamento Cancelado', "O processamento será cancelado porque foi selecionado não zerar os registros já exisitentes", {'Ok'}, 3)

		EndIf

	Else

		Aviso('Processamento Desnecessário', "Não existem registros na base para serem apagados", {'Ok'}, 3)

	EndIf

	(cQry)->(DbCloseArea())

	oLogProc:LogFimProc()

Return

Static Function ValidPerg()

	local cLoad	    := "BIA792" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(06)

	aAdd( aPergs ,{1, "Ano/Mês"          ,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Apaga registros BIA790",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet
