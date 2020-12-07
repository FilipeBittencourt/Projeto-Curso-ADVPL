#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GPM5002
@author Marcos Alberto Soprani
@since 01/08/2016
@version 1.0
@description Ponto de entrada que permite efetua filtros diversos para a cálculo e impressão do vale transporte
@obs OS: 2536-16 - Jessica Silva
@type function
/*/

USER FUNCTION GPM5002()

	Local lRet := .T.
	Local tw
	
	Private oDlgMTrpt
	Private oBut1Mtrp
	Private oGet1Mtrp
	Private cGet1Mtrp := Space(200)
	Private oSay1Mtrp

	If Empty(bpmFiltM0Tr)

		DEFINE MSDIALOG oDlgMTrpt TITLE "Fornecedor de Transporte" FROM 000, 000  TO 075, 700 COLORS 0, 16777215 PIXEL

		@ 012, 129 MSGET oGet1Mtrp VAR cGet1Mtrp SIZE 159, 010 OF oDlgMTrpt VALID U_GRetZ1VT() COLORS 0, 16777215 PIXEL
		@ 011, 291 BUTTON oBut1Mtrp PROMPT "Confirma" SIZE 037, 012 OF oDlgMTrpt ACTION oDlgMTrpt:End() PIXEL
		@ 015, 009 SAY oSay1Mtrp PROMPT "Selecione os Fornecedores de Transporte para cálculo:" SIZE 117, 007 OF oDlgMTrpt COLORS 0, 16777215 PIXEL
		ACTIVATE MSDIALOG oDlgMTrpt

		bpmFiltM0Tr := ""
		twFornec    := ""
		For tw := 1 to len(cGet1Mtrp)
			If Substr(cGet1Mtrp,tw,3) <> "***"
				twFornec += Substr(cGet1Mtrp,tw,3)+"/"
			EndIf
			TW += 2
		Next tw

		VZ002 := " SELECT RN_COD "
		VZ002 += "   FROM " + RetSqlName("SRN") + " "
		VZ002 += "  WHERE D_E_L_E_T_ = ' ' "
		VZ002 += "    AND RN_TPBEN IN(SELECT SUBSTRING(RCC_CONTEU, 1, 2) "
		VZ002 += "                      FROM " + RetSqlName("RCC") + " "
		VZ002 += "                     WHERE D_E_L_E_T_ = ' ' "
		VZ002 += "                       AND RCC_CODIGO = 'S011' "
		VZ002 += "                       AND SUBSTRING(RCC_CONTEU, 33, 3) IN " + FormatIn(twFornec,"/") + " "
		VZ002 += "                       AND SUBSTRING(RCC_CONTEU, 33, 3) <> '   ' "
		VZ002 += "                       AND D_E_L_E_T_ = ' ') "
		VZ002 += "  ORDER BY 1 "
		VZcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,VZ002),'VZ02',.F.,.T.)
		dbSelectArea("VZ02")
		dbGoTop()
		While !Eof()
			bpmFiltM0Tr += VZ02->RN_COD+"/"
			dbSkip()
		End

		VZ02->(dbCloseArea())
		Ferase(VZcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(VZcIndex+OrdBagExt())          //indice gerado

	EndIf

	If SR0->R0_CODIGO $ bpmFiltM0Tr
		lRet := .F.
	Endif

Return(lRet) 

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ GRetZ1VT  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 01/08/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Valid User para seleção de Meio de Transporte              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function GRetZ1VT(l1Elem,lTipoRet)

	Local cTitulo  := ""
	Local MvPar
	Local MvParDef := ""
	Local nTamx    := 3
	Local grtArea  := GetArea()
	Private aSit   := {}
	l1Elem := If (l1Elem = Nil , .F. , .T.)

	DEFAULT lTipoRet := .T.

	If lTipoRet
		MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		MvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIf

	cTitulo := Alltrim(Left("Fornecedores de Benefícios",20))
	MvParDef := ""

	KT009 = " SELECT SUBSTRING(RCC_CONTEU, 1, 3) CODIGO, "
	KT009 += "        SUBSTRING(RCC_CONTEU, 4, 30) FORNECEDOR "
	KT009 += "   FROM " + RetSqlName("RCC") + " "
	KT009 += "  WHERE RCC_CODIGO = 'S018' "
	KT009 += "    AND SUBSTRING(RCC_CONTEU, 1, 3) IN(SELECT SUBSTRING(RCC_CONTEU, 33, 3) "
	KT009 += "                                         FROM " + RetSqlName("RCC") + " "
	KT009 += "                                        WHERE RCC_CODIGO = 'S011' "
	KT009 += "                                          AND D_E_L_E_T_ = ' ') "
	KT009 += "    AND D_E_L_E_T_ = ' ' "
	KT009 += "  ORDER BY 1 "
	KTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KT009),'KT09',.F.,.T.)
	dbSelectArea("KT09")
	dbGoTop()
	While !Eof()
		AADD(aSit, KT09->CODIGO+" "+FORNECEDOR )
		MvParDef += KT09->CODIGO
		dbSkip()
	End

	KT09->(dbCloseArea())
	Ferase(KTcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(KTcIndex+OrdBagExt())          //indice gerado

	If lTipoRet
		If f_Opcoes(@MvPar, cTitulo, aSit, MvParDef, 12, 49, l1Elem, nTamx)  // Chama funcao f_Opcoes
			&MvRet := MvPar                                                  // Devolve Resultado
		EndIf
	EndIf

	RestArea( grtArea )

Return( IF( lTipoRet , .T. , MvParDef ) )

