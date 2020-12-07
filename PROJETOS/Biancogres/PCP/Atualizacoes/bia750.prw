#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA750
@author Marcos Alberto Soprani
@since 07/11/18
@version 1.0
@description Rotina para Atualizar pontualmente as quantidades (comumente chamada CAMADA) das estruturas orçamentárias - SGG    
@type function
/*/

User Function BIA750()

	Local M001      := GetNextAlias()
	Local entEnter  := CHR(13) + CHR(10)

	fPerg := "BIA750"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If Substr(dtos(MV_PAR04),1,4) <> MV_PAR03 .or. Substr(dtos(MV_PAR05),1,4) <> MV_PAR03 
		MsgSTOP("Uma das datas informada não pertece ao ano orçamentário. Favor verificar!!!")
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" +entEnter
	xfMensCompl += "Status igual Aberto" +entEnter
	xfMensCompl += "Data Digitação diferente de branco" +entEnter
	xfMensCompl += "Data Conciliação diferente de branco e menor ou igual a DataBase" +entEnter
	xfMensCompl += "Data Encerramento igual a branco" +entEnter

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
		MsgALERT("A versão informada não está ativa para execução deste processo." +entEnter +entEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" +entEnter +entEnter + xfMensCompl +entEnter +entEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())	

	RC003 := " UPDATE SGG SET GG_QUANT = " + Alltrim(Str(MV_PAR09)) + " "
	RC003 += "   FROM " + RetSqlName("SGG") + " SGG "
	RC003 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = GG_COD
	If !Empty(MV_PAR10)
		RC003 += "                           AND B1_YESPESS = '" + MV_PAR10 + "'
	EndIf
	RC003 += "                           AND SB1.D_E_L_E_T_ = ' '
	RC003 += "  WHERE GG_FILIAL = '" + xFilial("SGG") + "' "
	RC003 += "    AND GG_INI >= '" + dtos(MV_PAR04) + "' "
	RC003 += "    AND GG_FIM <= '" + dtos(MV_PAR05) + "' "
	RC003 += "    AND GG_COD BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' "
	RC003 += "    AND GG_COMP = '" + MV_PAR08 + "' "
	RC003 += "    AND SGG.D_E_L_E_T_ = ' ' "

	U_BIAMsgRun("Aguarde... Efetuando atualização de Quantidade... ", , {|| TcSqlExec(RC003) })

	MsgINFO("Fim do Processamento... Favor conferir se os ajustes aplicados corrigiram as quantidades conforme parâmetros.")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
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
	aAdd(aRegs,{cPerg,"04","De Data                  ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Até Data                 ?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","De Produto               ?","","","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"07","Até Produto              ?","","","mv_ch7","C",15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"08","Componente afetado       ?","","","mv_ch8","C",15,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"09","Nova Quantidade (camada) ?","","","mv_ch9","N",18,8,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Espessura (branco todas) ?","","","mv_cha","C",03,8,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","Z34"})
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
