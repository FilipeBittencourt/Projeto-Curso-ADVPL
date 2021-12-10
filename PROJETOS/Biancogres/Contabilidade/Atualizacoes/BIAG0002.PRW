#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAG0002
@author Gabriel Rossi Mafioletti
@since 25/10/2021
@version 1.0
@description Rotina para Zeramento do CAPEX e/ou OBZ
@type function
/*/

User Function BIAG0002()

	Local _cAlias	:=	GetNextAlias()
	Local _cTpOrct	:=	""
	If !ValidPerg()
		Return
	EndIf

	Do Case 
		Case MV_PAR04 == "O"
			_cTpOrct	:=	"OBZ"
			_cArqOrct	:=	"Z98"
		Case MV_PAR04 == "C"
			_cTpOrct	:=	"CAPEX"
			_cArqOrct	:=	"ZBV"
		OTHERWISE
			MsgStop("O Tipo de Orçamento está Incorreto!")
			Return
	EndCase

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual CAPEX ou OBZ" + CRLF
	xfMensCompl += "Status igual Aberto" + CRLF
	xfMensCompl += "Data Digitação igual branco" + CRLF
	xfMensCompl += "Data Conciliação igual branco" + CRLF
	xfMensCompl += "Data Encerramento igual branco"


	BeginSql Alias _cAlias
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:MV_PAR01%
		AND ZB5.ZB5_REVISA = %Exp:MV_PAR02%
		AND ZB5.ZB5_ANOREF = %Exp:MV_PAR03%
		AND RTRIM(ZB5.ZB5_TPORCT) = %Exp:_cTpOrct%
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT = ''
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	
	(_cAlias)->(dbGoTop())

	If (_cAlias)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + CRLF + CRLF + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + CRLF + CRLF + xfMensCompl + CRLF + CRLF + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(_cAlias)->(dbCloseArea())
		Return
	EndIf	
	
	
	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName(_cArqOrct) + " " +  _cArqOrct + " "
	M0007 += "  WHERE " + _cArqOrct + "."+_cArqORct + "_FILIAL = '" + xFilial(_cArqOrct) + "' "
	M0007 += "    AND " + _cArqOrct + "."+_cArqORct + "_VERSAO = '" + MV_PAR01 + "' "
	M0007 += "    AND " + _cArqOrct + "."+_cArqORct + "_REVISA = '" + MV_PAR02 + "' "
	M0007 += "    AND " + _cArqOrct + "."+_cArqORct + "_ANOREF = '" + MV_PAR03 + "' "
	If !Empty(MV_PAR05)
		M0007 += "    AND " + _cArqOrct + "."+_cArqORct + "_CLVL IN " + FormatIn(Alltrim(MV_PAR05),",")
	EndIf
	M0007 += "    AND " + _cArqOrct + ".D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES(" Importante: caso confirme, o sistema irá efetuar a limpeza dos dados." + CRLF + CRLF+ " Deseja prosseguir com a Exclusão???")

		If xkContinua .And. MsgNoYes("CUIDADO!!! A operação de exclusão não pode ser desfeita!" + CRLF + CRLF + " Tem certeza que deseja continuar???" )
 
			KS001 := " DELETE " + RetSqlName(_cArqOrct) + " "
			KS001 += "   FROM " + RetSqlName(_cArqOrct) + " " + _cArqOrct + " "
			KS001 += "  WHERE " + _cArqOrct + "."+_cArqORct + "_FILIAL = '" + xFilial(_cArqOrct) + "' "
			KS001 += "    AND " + _cArqOrct + "."+_cArqORct + "_VERSAO = '" + MV_PAR01 + "' "
			KS001 += "    AND " + _cArqOrct + "."+_cArqORct + "_REVISA = '" + MV_PAR02 + "' "
			KS001 += "    AND " + _cArqOrct + "."+_cArqORct + "_ANOREF = '" + MV_PAR03 + "' "
			If !Empty(MV_PAR05)
				KS001 += "    AND " + _cArqOrct + "."+_cArqORct + "_CLVL IN " + FormatIn(Alltrim(MV_PAR05),",")
			EndIf
			KS001 += "    AND " + _cArqOrct + ".D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros... ",,{|| TcSQLExec(KS001) })
			
			MsgInfo("Zeramento efetuado com Sucesso!")
		EndIf
	Else
		MsgInfo("Não Existem dados a serem Deletados!")
	EndIf

	(_cAlias)->(dbCloseArea())
	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

Return

Static Function ValidPerg()

	local cLoad	    := "BIAG0002" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	local aOpcs 	:= {"O=OBZ","C=CAPEX"}

	MV_PAR01 := SPACE(TAMSX3("ZBV_VERSAO")[1])
	MV_PAR02 := SPACE(TAMSX3("ZBV_REVISA")[1])
	MV_PAR03 := SPACE(TAMSX3("ZBV_ANOREF")[1])
	MV_PAR04 := "O"
	MV_PAR05 := SPACE(100)


	aAdd( aPergs ,{1,"Versão " 	   		,MV_PAR01 ,""  ,"",'ZB5'     ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Revisão " 	   	,MV_PAR02 ,""  ,"",''        ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"AnoRef " 	   		,MV_PAR03 ,""  ,"",''        ,'.F.',50,.F.})
	aAdd( aPergs ,{2,"Tipo Orç." 	,MV_PAR04 ,aOpcs,60,'.T.',.T.})
	aAdd( aPergs ,{1,"Cl. Valor " 	   		,MV_PAR05 ,""  ,"",''        ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Zeramento de CAPEX/OBZ ",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

	EndIf

Return lRet
