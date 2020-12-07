#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA943
@author Marcos Alberto Soprani
@since 08/11/17
@version 1.0
@description Browser Principal do Custo Unitário / Total Reajustado
@type function
/*/

User Function BIA943()

	Local tyArea         := GetArea()
	Private tyEnter      := Chr(13) + Chr(10)
	Private cTab	     := "ZBS"

	Private cCadastro 	:= "Custo Unitário / Total Reajustado"
	Private aRotina 	:= { {"Pesquisar"                  ,"AxPesqui"        ,0,1},;
	{                         "Reajuste Unitário"          ,"U_B943RUNT"      ,0,3},;
	{                         "Custo Total"                ,"U_B943TOTC"      ,0,4},;
	{                         "C.VARIAVEL p/ ORCAFINAL"    ,"U_B943CVDS"      ,0,5},;
	{                         "C.VAR.Unit p/ Ajustado RAC" ,"U_B943CVAR"      ,0,6} }

	dbSelectArea("ZBS")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"ZBS",,,,,,)

	RestArea(tyArea)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B943RUNT ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Grava os custos unitários reajustados a partir das tabelas ¦¦¦
¦¦¦          ¦ ZBT e ZBU                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B943RUNT()

	Processa({|| RptB943RUNT()})

Return

Static Function RptB943RUNT()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	If Alltrim(FunName()) == "BIA518"

		_cVersao   := cGet2   
		_cRevisa   := cGet3
		_cAnoRef   := cGet4

	Else

		fPerg := "BIA943"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		fValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		_cVersao   := MV_PAR01   
		_cRevisa   := MV_PAR02
		_cAnoRef   := MV_PAR03

	EndIf

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	If Alltrim(FunName()) == "BIA518"

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
		xfMensCompl += "Status igual Fechado" + msrhEnter
		xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
		xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
		xfMensCompl += "Data Encerramento diferente de branco e menor ou igual a DataBase" + msrhEnter

		BeginSql Alias M001
			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZB5% ZB5
			WHERE ZB5_FILIAL = %xFilial:ZB5%
			AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
			AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
			AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
			AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
			AND ZB5.ZB5_STATUS = 'F'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTENCR <> ''
			AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
			AND ZB5.%NotDel%
		EndSql

	Else

		xfMensCompl := ""
		xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
		xfMensCompl += "Status igual Aberto" + msrhEnter
		xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
		xfMensCompl += "Data Conciliação diferente de branco e menor ou igual a DataBase" + msrhEnter
		xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

		BeginSql Alias M001
			SELECT COUNT(*) CONTAD
			FROM %TABLE:ZB5% ZB5
			WHERE ZB5_FILIAL = %xFilial:ZB5%
			AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
			AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
			AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
			AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
			AND ZB5.ZB5_STATUS = 'A'
			AND ZB5.ZB5_DTDIGT <> ''
			AND ZB5.ZB5_DTCONS <> ''
			AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
			AND ZB5.ZB5_DTENCR = ''
			AND ZB5.%NotDel%
		EndSql

	EndIf

	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("ZBS") + " ZBS "
	M0007 += "  WHERE ZBS.ZBS_FILIAL = '" + xFilial("ZBS") + "' "
	M0007 += "    AND ZBS.ZBS_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBS.ZBS_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBS.ZBS_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBS.ZBS_TIPO = 'U' "
	If Alltrim(FunName()) == "BIA518"
		M0007 += "    AND ZBS.ZBS_COD IN " + FormatIn(w8FilAleat,",") + "	
	EndIf
	M0007 += "    AND ZBS.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existe reajuste de custo unitário para a Versão informada." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados reajustados. Inclusive dos custos Totais... " + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("ZBS") + " "
			KS001 += "   FROM " + RetSqlName("ZBS") + " ZBS "
			KS001 += "  WHERE ZBS.ZBS_FILIAL = '" + xFilial("ZBS") + "' "
			KS001 += "    AND ZBS.ZBS_VERSAO = '" + _cVersao + "' "
			KS001 += "    AND ZBS.ZBS_REVISA = '" + _cRevisa + "' "
			KS001 += "    AND ZBS.ZBS_ANOREF = '" + _cAnoRef + "' "
			KS001 += "    AND ZBS.ZBS_TIPO = 'U' "
			If Alltrim(FunName()) == "BIA518"
				KS001 += "    AND ZBS.ZBS_COD IN " + FormatIn(w8FilAleat,",") + "	
			EndIf
			KS001 += "    AND ZBS.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBS... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	QL003 := " SELECT * "
	QL003 += "   FROM " + RetSqlName("ZBT") + " ZBT "
	QL003 += "   LEFT JOIN " + RetSqlName("ZBU") + " ZBU ON ZBU_FILIAL = '" + xFilial("ZBU") + "' "
	QL003 += "                       AND ZBU_VERSAO = ZBT_VERSAO "
	QL003 += "                       AND ZBU_REVISA = ZBT_REVISA "
	QL003 += "                       AND ZBU_ANOREF = ZBT_ANOREF "
	QL003 += "                       AND ZBU_ITCUS = ZBT_ITCUS "
	QL003 += "                       AND ZBU.D_E_L_E_T_ = ' ' "
	QL003 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = ZBT_COD "
	QL003 += "                       AND B1_TIPO = 'PA' "
	QL003 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	If Alltrim(FunName()) <> "BIA518"
		QL003 += "  INNER JOIN " + RetSqlName("Z47") + " Z47 ON Z47_FILIAL = '" + xFilial("Z47") + "' "
		QL003 += "                       AND Z47_VERSAO = ZBT_VERSAO "
		QL003 += "                       AND Z47_REVISA = ZBT_REVISA "
		QL003 += "                       AND Z47_ANOREF = ZBT_ANOREF "
		QL003 += "                       AND SUBSTRING(Z47_PRODUT,1,7) = SUBSTRING(ZBT_COD,1,7) "
		QL003 += "                       AND Z47.D_E_L_E_T_ = ' ' "
	EndIf
	QL003 += "  WHERE ZBT_FILIAL = '" + xFilial("ZBT") + "' "
	QL003 += "    AND ZBT_VERSAO = '" + _cVersao + "' "
	QL003 += "    AND ZBT_REVISA = '" + _cRevisa + "' "
	QL003 += "    AND ZBT_ANOREF = '" + _cAnoRef + "' "
	QL003 += "    AND ZBT_ITCUS <> '   ' "
	If Alltrim(FunName()) == "BIA518"
		QL003 += "    AND ZBT.ZBT_COD IN " + FormatIn(w8FilAleat,",") + "	
	EndIf
	QL003 += "    AND ZBT.D_E_L_E_T_ = ' ' "
	QLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QL003),'QL03',.T.,.T.)
	dbSelectArea("QL03")
	QL03->(dbGoTop())
	ProcRegua(RecCount())
	While !QL03->(Eof())

		IncProc("Processando registro: " + Alltrim(Str(QL03->(Recno()))) )

		dbSelectArea("ZBS")
		RecLock("ZBS",.T.)
		ZBS->ZBS_FILIAL  := xFilial("ZBS")
		ZBS->ZBS_VERSAO  := _cVersao
		ZBS->ZBS_REVISA  := _cRevisa
		ZBS->ZBS_ANOREF  := _cAnoRef
		ZBS->ZBS_TIPO    := "U"
		ZBS->ZBS_COD     := QL03->ZBT_COD
		ZBS->ZBS_CONTA   := QL03->ZBT_CONTA
		ZBS->ZBS_ITCUS   := QL03->ZBT_ITCUS
		ZBS->ZBS_CTOTAL  := QL03->ZBT_CTOTAL
		// Antes do fechamento do custo de julho de 2018 identificou-se que o sistema não estava projetando o custo de acordo com o IGPM quando fora do MIX.
		// Em 01/08/18, ajuste efetuado 
		If IsInCallStack("U_BIA518")
			ZBS->ZBS_M01     := QL03->ZBT_M01 // * QL03->ZBU_M01        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M01 )
			ZBS->ZBS_M02     := QL03->ZBT_M02 // * QL03->ZBU_M02        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M02 )
			ZBS->ZBS_M03     := QL03->ZBT_M03 // * QL03->ZBU_M03        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M03 )
			ZBS->ZBS_M04     := QL03->ZBT_M04 // * QL03->ZBU_M04        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M04 )
			ZBS->ZBS_M05     := QL03->ZBT_M05 // * QL03->ZBU_M05        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M05 )
			ZBS->ZBS_M06     := QL03->ZBT_M06 // * QL03->ZBU_M06        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M06 )
			ZBS->ZBS_M07     := QL03->ZBT_M07 // * QL03->ZBU_M07        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M07 )
			ZBS->ZBS_M08     := QL03->ZBT_M08 // * QL03->ZBU_M08        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M08 )
			ZBS->ZBS_M09     := QL03->ZBT_M09 // * QL03->ZBU_M09        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M09 )
			ZBS->ZBS_M10     := QL03->ZBT_M10 // * QL03->ZBU_M10        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M10 )
			ZBS->ZBS_M11     := QL03->ZBT_M11 // * QL03->ZBU_M11        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M11 )
			ZBS->ZBS_M12     := QL03->ZBT_M12 // * QL03->ZBU_M12        //IIf( Alltrim(FunName()) == "BIA518", 1, QL03->ZBU_M12 )
		Else
			ZBS->ZBS_M01     := QL03->ZBT_M01
			ZBS->ZBS_M02     := QL03->ZBT_M02
			ZBS->ZBS_M03     := QL03->ZBT_M03
			ZBS->ZBS_M04     := QL03->ZBT_M04
			ZBS->ZBS_M05     := QL03->ZBT_M05
			ZBS->ZBS_M06     := QL03->ZBT_M06
			ZBS->ZBS_M07     := QL03->ZBT_M07
			ZBS->ZBS_M08     := QL03->ZBT_M08
			ZBS->ZBS_M09     := QL03->ZBT_M09
			ZBS->ZBS_M10     := QL03->ZBT_M10
			ZBS->ZBS_M11     := QL03->ZBT_M11
			ZBS->ZBS_M12     := QL03->ZBT_M12		
		EndIf
		MsUnLock()

		QL03->(dbSkip())

	End

	QL03->(dbCloseArea())
	Ferase(QLIndex+GetDBExtension())
	Ferase(QLIndex+OrdBagExt())

	MsgINFO("Fim do processamento....")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B943TOTC ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Grava os custos totais reajustados a partir das tabelas    ¦¦¦
¦¦¦          ¦ ZBS e Z47 (Unitário Ajustado vs Mix de produção)           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B943TOTC()

	Processa({|| RptB943TOTC()})

Return

Static Function RptB943TOTC()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA943"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco e menor ou igual a DataBase" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("ZBS") + " ZBS "
	M0007 += "  WHERE ZBS.ZBS_FILIAL = '" + xFilial("ZBS") + "' "
	M0007 += "    AND ZBS.ZBS_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBS.ZBS_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBS.ZBS_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBS.ZBS_TIPO = 'T' "
	M0007 += "    AND ZBS.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existe reajuste de custo total reajustado para a Versão informada." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados reajustados. " + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("ZBS") + " "
			KS001 += "   FROM " + RetSqlName("ZBS") + " ZBS "
			KS001 += "  WHERE ZBS.ZBS_FILIAL = '" + xFilial("ZBS") + "' "
			KS001 += "    AND ZBS.ZBS_VERSAO = '" + _cVersao + "' "
			KS001 += "    AND ZBS.ZBS_REVISA = '" + _cRevisa + "' "
			KS001 += "    AND ZBS.ZBS_ANOREF = '" + _cAnoRef + "' "
			KS001 += "    AND ZBS.ZBS_TIPO = 'T' "
			KS001 += "    AND ZBS.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBS... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	QL003 := " SELECT * "
	QL003 += "   FROM " + RetSqlName("ZBS") + " ZBS "
	QL003 += "  INNER JOIN " + RetSqlName("Z47") + " Z47 ON Z47_FILIAL = '" + xFilial("Z47") + "' "
	QL003 += "                       AND Z47_VERSAO = ZBS_VERSAO "
	QL003 += "                       AND Z47_REVISA = ZBS_REVISA "
	QL003 += "                       AND Z47_ANOREF = ZBS_ANOREF "
	QL003 += "                       AND SUBSTRING(Z47_PRODUT,1,7) = SUBSTRING(ZBS_COD,1,7) "
	QL003 += "                       AND Z47.D_E_L_E_T_ = ' ' "
	QL003 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = ZBS_COD "
	QL003 += "                       AND B1_TIPO = 'PA' "
	QL003 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	QL003 += "  WHERE ZBS_FILIAL = '" + xFilial("ZBS") + "' "
	QL003 += "    AND ZBS_VERSAO = '" + _cVersao + "' "
	QL003 += "    AND ZBS_REVISA = '" + _cRevisa + "' "
	QL003 += "    AND ZBS_ANOREF = '" + _cAnoRef + "' "
	QL003 += "    AND ZBS_TIPO = 'U' "
	QL003 += "    AND ZBS.D_E_L_E_T_ = ' ' "
	QLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QL003),'QL03',.T.,.T.)
	dbSelectArea("QL03")
	QL03->(dbGoTop())
	ProcRegua(RecCount())
	While !QL03->(Eof())

		IncProc("Processando registro: " + Alltrim(Str(QL03->(Recno()))) )

		dbSelectArea("ZBS")
		RecLock("ZBS",.T.)
		ZBS->ZBS_FILIAL  := xFilial("ZBS")
		ZBS->ZBS_VERSAO  := _cVersao
		ZBS->ZBS_REVISA  := _cRevisa
		ZBS->ZBS_ANOREF  := _cAnoRef
		ZBS->ZBS_TIPO    := "T"
		ZBS->ZBS_COD     := QL03->ZBS_COD
		ZBS->ZBS_CONTA   := QL03->ZBS_CONTA
		ZBS->ZBS_ITCUS   := QL03->ZBS_ITCUS
		ZBS->ZBS_M01     := QL03->ZBS_M01 * QL03->Z47_QTDM01
		ZBS->ZBS_M02     := QL03->ZBS_M02 * QL03->Z47_QTDM02
		ZBS->ZBS_M03     := QL03->ZBS_M03 * QL03->Z47_QTDM03
		ZBS->ZBS_M04     := QL03->ZBS_M04 * QL03->Z47_QTDM04
		ZBS->ZBS_M05     := QL03->ZBS_M05 * QL03->Z47_QTDM05
		ZBS->ZBS_M06     := QL03->ZBS_M06 * QL03->Z47_QTDM06
		ZBS->ZBS_M07     := QL03->ZBS_M07 * QL03->Z47_QTDM07
		ZBS->ZBS_M08     := QL03->ZBS_M08 * QL03->Z47_QTDM08
		ZBS->ZBS_M09     := QL03->ZBS_M09 * QL03->Z47_QTDM09
		ZBS->ZBS_M10     := QL03->ZBS_M10 * QL03->Z47_QTDM10
		ZBS->ZBS_M11     := QL03->ZBS_M11 * QL03->Z47_QTDM11
		ZBS->ZBS_M12     := QL03->ZBS_M12 * QL03->Z47_QTDM12
		MsUnLock()

		QL03->(dbSkip())

	End

	QL03->(dbCloseArea())
	Ferase(QLIndex+GetDBExtension())
	Ferase(QLIndex+OrdBagExt())

	MsgINFO("Fim do processamento....")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B943CVDS ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Transporta os custos totais do Orçamento C.VARIAVEL para   ¦¦¦
¦¦¦          ¦ DESPESAS (ZBZ)                                             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B943CVDS()

	Processa({|| RptB943CVDS()})

Return

Static Function RptB943CVDS()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA943"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e menor ou igual a DataBase" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTENCR <> ''
		AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
	M0007 += "  WHERE ZBZ.ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
	M0007 += "    AND ZBZ.ZBZ_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND ZBZ.ZBZ_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND ZBZ.ZBZ_ANOREF = '" + _cAnoRef + "' "
	M0007 += "    AND ZBZ.ZBZ_ORIPRC = 'C.VARIAVEL' "
	M0007 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existe base contábel orçamentária para a Versão / Revisão / AnoRef informados." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("ZBZ") + " "
			KS001 += "   FROM " + RetSqlName("ZBZ") + " ZBZ "
			KS001 += "  WHERE ZBZ.ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
			KS001 += "    AND ZBZ.ZBZ_VERSAO = '" + _cVersao + "' "
			KS001 += "    AND ZBZ.ZBZ_REVISA = '" + _cRevisa + "' "
			KS001 += "    AND ZBZ.ZBZ_ANOREF = '" + _cAnoRef + "' "
			KS001 += "    AND ZBZ.ZBZ_ORIPRC = 'C.VARIAVEL' "
			KS001 += "    AND ZBZ.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBZ... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	Processa({ || cMsg := BIA943A() }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function BIA943A()

	Local msFx

	For msFx := 1 to 12

		xhDatRef := UltimoDia(stod(_cAnoRef + StrZero(msFx,2) + "01"))

		XH004 := " WITH CVARIAVEL AS (SELECT ZBS_VERSAO, "
		XH004 += "                           ZBS_REVISA, "
		XH004 += "                           ZBS_ANOREF, "
		XH004 += "                           '" + dtos(xhDatRef) + "' DATREF, "
		XH004 += "                           ZBS_CONTA, "
		XH004 += "                           CASE "
		If cEmpAnt == "14"
			XH004 += "                             WHEN Z47.Z47_FORNOP IN('F01') THEN '3500' "
		Else
			XH004 += "                             WHEN Z47.Z47_FORNOP IN('F04','F05') THEN '3200' "
			XH004 += "                             ELSE '3100' "
		EndIf
		XH004 += "                           END CLVL, "
		XH004 += "                           SUM(ZBS_M" + StrZero(msFx,2) + ") MESREF "
		XH004 += "                      FROM " + RetSqlName("ZBS") + " ZBS "
		XH004 += "                     INNER JOIN " + RetSqlName("Z47") + " Z47 ON Z47_VERSAO = ZBS_VERSAO "
		XH004 += "                                          AND Z47_REVISA = ZBS_REVISA "
		XH004 += "                                          AND Z47_ANOREF = ZBS_ANOREF "
		XH004 += "                                          AND Z47_PRODUT = ZBS_COD "
		XH004 += "                                          AND Z47.D_E_L_E_T_ = ' ' "
		XH004 += "                     WHERE ZBS_VERSAO = '" + _cVersao + "' "
		XH004 += "                       AND ZBS_REVISA = '" + _cRevisa + "' "
		XH004 += "                       AND ZBS_ANOREF = '" + _cAnoRef + "' "
		XH004 += "                       AND ZBS_TIPO = 'T' "
		XH004 += "                       AND ZBS.D_E_L_E_T_ = ' ' "
		XH004 += "                     GROUP BY ZBS_VERSAO, "
		XH004 += "                              ZBS_REVISA, "
		XH004 += "                              ZBS_ANOREF, "
		XH004 += "                              ZBS_CONTA, "
		XH004 += "                              Z47_FORNOP) "
		XH004 += " SELECT ZBS_VERSAO, "
		XH004 += "        ZBS_REVISA, "
		XH004 += "        ZBS_ANOREF, "
		XH004 += "        DATREF, "
		XH004 += "        ZBS_CONTA, "
		XH004 += "        CLVL, "
		XH004 += "        SUM(MESREF) MESREF "
		XH004 += "   FROM CVARIAVEL "
		XH004 += "  GROUP BY ZBS_VERSAO, "
		XH004 += "           ZBS_REVISA, "
		XH004 += "           ZBS_ANOREF, "
		XH004 += "           DATREF, "
		XH004 += "           ZBS_CONTA, "
		XH004 += "           CLVL "
		XH004 += "  ORDER BY ZBS_VERSAO, "
		XH004 += "           ZBS_REVISA, "
		XH004 += "           ZBS_ANOREF, "
		XH004 += "           DATREF, "
		XH004 += "           ZBS_CONTA, "
		XH004 += "           CLVL "
		XHIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,XH004),'XH04',.T.,.T.)
		dbSelectArea("XH04")
		XH04->(dbGoTop())

		xtrTot := 0
		ProcRegua(xtrTot)

		If XH04->(!Eof())

			While XH04->(!Eof())

				IncProc("Mês " + StrZero(msFx,2) + ", Conta: " + Alltrim(XH04->ZBS_CONTA) + ", Rec.: " + AllTrim(Str(XH04->(Recno()))))

				If XH04->MESREF <> 0

					Reclock("ZBZ",.T.)
					ZBZ->ZBZ_FILIAL := xFilial("ZBZ") 
					ZBZ->ZBZ_VERSAO := _cVersao
					ZBZ->ZBZ_REVISA := _cRevisa
					ZBZ->ZBZ_ANOREF := _cAnoRef
					ZBZ->ZBZ_ORIPRC := "C.VARIAVEL"
					ZBZ->ZBZ_ORGLAN := "D"
					ZBZ->ZBZ_DATA   := stod(XH04->DATREF)
					ZBZ->ZBZ_LOTE   := "004900"
					ZBZ->ZBZ_SBLOTE := "001"
					ZBZ->ZBZ_DOC    := ""
					ZBZ->ZBZ_LINHA  := ""
					ZBZ->ZBZ_DC     := "1"
					ZBZ->ZBZ_DEBITO := XH04->ZBS_CONTA
					ZBZ->ZBZ_CREDIT := ""
					ZBZ->ZBZ_CLVLDB := XH04->CLVL
					ZBZ->ZBZ_CLVLCR := ""
					ZBZ->ZBZ_ITEMD  := ""
					ZBZ->ZBZ_ITEMC  := ""
					ZBZ->ZBZ_VALOR  := XH04->MESREF
					ZBZ->ZBZ_HIST   := "ORCTO C.VARIAVEL" 
					ZBZ->ZBZ_YHIST  := "ORCAMENTO C.VARIAVEL"
					ZBZ->ZBZ_SI     := ""
					ZBZ->ZBZ_YDELTA := ctod("  /  /  ")
					ZBZ->(MsUnlock())

				EndIf

				XH04->(dbSkip())

			EndDo

		EndIf	

		XH04->(dbCloseArea())
		Ferase(XHIndex+GetDBExtension())
		Ferase(XHIndex+OrdBagExt())

	Next msFx

	ZP001 := " UPDATE " + RetSqlName("ZB5") + " SET ZB5_STATUS = 'F' "
	ZP001 += "   FROM " + RetSqlName("ZB5") + " ZB5 "
	ZP001 += "  WHERE ZB5.ZB5_FILIAL = '" + xFilial("ZB5") + "' "
	ZP001 += "    AND ZB5.ZB5_VERSAO = '" + _cVersao + "' "
	ZP001 += "    AND ZB5.ZB5_REVISA = '" + _cRevisa + "' "
	ZP001 += "    AND ZB5.ZB5_ANOREF = '" + _cAnoRef + "' "
	ZP001 += "    AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL' "
	ZP001 += "    AND ZB5.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Fechando Versão Orçamentária ... ",,{|| TcSQLExec(ZP001) })

	MsgINFO("... Fim do Processamento ...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ B943CVAR ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08/11/17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Transporta os custos totais do Orçamento C.VARIAVEL para   ¦¦¦
¦¦¦          ¦ DESPESAS (ZBZ)                                             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function B943CVAR()

	Processa({|| RptB943CVAR()})

Return

Static Function RptB943CVAR()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)

	If Alltrim(FunName()) == "BIA518"

		_cVersao   := cGet2   
		_cRevisa   := cGet3
		_cAnoRef   := cGet4

	Else

		fPerg := "BIA943"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		fValidPerg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		_cVersao   := MV_PAR01   
		_cRevisa   := MV_PAR02
		_cAnoRef   := MV_PAR03

	EndIf

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Fechado" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Conciliação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento diferente de branco e menor ou igual a DataBase" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'C.VARIAVEL'
		AND ZB5.ZB5_STATUS = 'F'
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS <> ''
		AND ZB5.ZB5_DTENCR <> ''
		AND ZB5.ZB5_DTENCR <= %Exp:dtos(Date())%
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está com o status adequado para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	M0007 := " SELECT COUNT(*) CONTAD "
	M0007 += "   FROM " + RetSqlName("Z50") + " Z50 "
	M0007 += "  WHERE Z50.Z50_FILIAL = '" + xFilial("Z50") + "' "
	M0007 += "    AND Z50.Z50_VERSAO = '" + _cVersao + "' "
	M0007 += "    AND Z50.Z50_REVISA = '" + _cRevisa + "' "
	M0007 += "    AND Z50.Z50_ANOREF = '" + _cAnoRef + "' "
	If Alltrim(FunName()) == "BIA518"
		M0007 += "    AND Z50.Z50_COD IN " + FormatIn(w8FilAleat,",") + "	
	EndIf
	M0007 += "    AND Z50.D_E_L_E_T_ = ' ' "
	MSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,M0007),'M007',.T.,.T.)
	dbSelectArea("M007")
	M007->(dbGoTop())

	If M007->CONTAD <> 0

		xkContinua := MsgNOYES("Já existe base orçamentária para a Versão / Revisão / AnoRef informados na tabela de C.Unitário para Variável Ajustado." + msrhEnter + msrhEnter + " Importante: caso confirme, o sistema irá efetuar a limpeza dos dados gravados." + msrhEnter + msrhEnter+ " Deseja prosseguir com o reprocessamento!!!")

		If xkContinua

			KS001 := " DELETE " + RetSqlName("Z50") + " "
			KS001 += "   FROM " + RetSqlName("Z50") + " Z50 "
			KS001 += "  WHERE Z50.Z50_FILIAL = '" + xFilial("Z50") + "' "
			KS001 += "    AND Z50.Z50_VERSAO = '" + _cVersao + "' "
			KS001 += "    AND Z50.Z50_REVISA = '" + _cRevisa + "' "
			KS001 += "    AND Z50.Z50_ANOREF = '" + _cAnoRef + "' "
			If Alltrim(FunName()) == "BIA518"
				KS001 += "    AND Z50.Z50_COD IN " + FormatIn(w8FilAleat,",") + "	
			EndIf
			KS001 += "    AND Z50.D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros Z50... ",,{|| TcSQLExec(KS001) })

		Else

			M007->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			Return .F.

		EndIf

	EndIf

	M007->(dbCloseArea())
	Ferase(MSIndex+GetDBExtension())
	Ferase(MSIndex+OrdBagExt())

	Processa({ || cMsg := BIA943B() }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function BIA943B()

	ET004 := " SELECT * "
	ET004 += "   FROM " + RetSqlName("ZBS") + " "
	ET004 += "  WHERE ZBS_FILIAL = '" + xFilial("ZBS") + "' "
	ET004 += "    AND ZBS_VERSAO = '" + _cVersao + "' "
	ET004 += "    AND ZBS_REVISA = '" + _cRevisa + "' "
	ET004 += "    AND ZBS_ANOREF = '" + _cAnoRef + "' "
	ET004 += "    AND ZBS_TIPO = 'U' "
	ET004 += "    AND ZBS_M01 + ZBS_M02 + ZBS_M03 + ZBS_M04 + ZBS_M05 + ZBS_M06 + ZBS_M07 + ZBS_M08 + ZBS_M09 + ZBS_M10 + ZBS_M11 + ZBS_M12 <> 0 "
	If Alltrim(FunName()) == "BIA518"
		ET004 += "    AND ZBS_COD IN " + FormatIn(w8FilAleat,",") + "	
	EndIf
	ET004 += "    AND D_E_L_E_T_ = ' ' "
	ETIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ET004),'ET04',.T.,.T.)
	dbSelectArea("ET04")
	ET04->(dbGoTop())
	If ET04->(!Eof())

		While ET04->(!Eof())

			IncProc("Produto: " + Alltrim(ET04->ZBS_COD) + ", Conta: " + Alltrim(ET04->ZBS_CONTA) )

			Reclock("Z50",.T.)
			Z50->Z50_FILIAL  := xFilial("Z50")
			Z50->Z50_DATARF  := stod(StrZero(Val(ET04->ZBS_ANOREF) - 1, 4) + "1231")
			Z50->Z50_COD     := ET04->ZBS_COD   
			Z50->Z50_CONTA   := ET04->ZBS_CONTA 
			Z50->Z50_ITCUS   := ET04->ZBS_ITCUS 
			Z50->Z50_CTOTAL  := ET04->ZBS_CTOTAL
			Z50->Z50_M01     := ET04->ZBS_M01   
			Z50->Z50_M02     := ET04->ZBS_M02   
			Z50->Z50_M03     := ET04->ZBS_M03   
			Z50->Z50_M04     := ET04->ZBS_M04   
			Z50->Z50_M05     := ET04->ZBS_M05   
			Z50->Z50_M06     := ET04->ZBS_M06   
			Z50->Z50_M07     := ET04->ZBS_M07   
			Z50->Z50_M08     := ET04->ZBS_M08   
			Z50->Z50_M09     := ET04->ZBS_M09   
			Z50->Z50_M10     := ET04->ZBS_M10   
			Z50->Z50_M11     := ET04->ZBS_M11   
			Z50->Z50_M12     := ET04->ZBS_M12   
			Z50->Z50_VERSAO  := ET04->ZBS_VERSAO
			Z50->Z50_REVISA  := ET04->ZBS_REVISA
			Z50->Z50_ANOREF  := ET04->ZBS_ANOREF
			If Alltrim(FunName()) == "BIA518"
				Z50->Z50_DTAJST  := Date()
			EndIf
			Z50->(MsUnlock())

			ET04->(dbSkip())

		EndDo

	EndIf	

	ET04->(dbCloseArea())
	Ferase(ETIndex+GetDBExtension())
	Ferase(ETIndex+OrdBagExt())

	MsgINFO("... Fim do Processamento ...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg    ¦ Autor ¦ Marcos Alberto S ¦ Data ¦ 13/05/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária      ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa            ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência        ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	RestArea(_sAlias)

Return
