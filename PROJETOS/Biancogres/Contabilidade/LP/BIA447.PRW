#include "rwmake.ch"
#include "topconn.ch"

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北砅rograma  � BIA447   � Autor � Wanisay William                          � Data � 11/11/08 潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escri噮o � Ajusta regra 650/015, 650/016, 655/017 Pis/Cofins/Csll                        潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北矨lteracao � Em 30/11/11 foram efetuados ajustes no programa para que fosse poss韛el dar   潮�
北�          � um Loop nos itens da nota procurando tes que n鉶 gera contabiliza玢o          潮�
北�          � Altera玢o efetuada por Marcos Alberto Soprani                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � SIGACOM                                                                       潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北*/

User Function BIA447()

	Private cConta	:= ""
	Private cCodLP  := Paramixb
	Private cCf  	:= ""
	Private cRegra	:= ""
	Private cArq	:= ""
	Private cInd	:= 0
	Private cReg	:= 0
	Private cArqSD1	:= ""
	Private cIndSD1	:= 0
	Private cRegSD1	:= 0

	xfArea := GetArea()
	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	dbSelectArea("SD1")
	cArqSD1 := Alias()
	cIndSD1 := IndexOrd()
	cRegSD1 := Recno()
	nValor := 0

	// Implementa玢o efetuada em 30/11/11 por Marcos Alberto
	xf_CntaTs := 0
	xf_TotVal := 0
	If cCodLP $ '660007/665007'
		// Tratamento feito exclusivamente para tratar o TES 396 - n鉶 contabiliza para este TES
		//df_TesEp := IIF(cEmpAnt == "01", "396", IIF(cEmpAnt == "05", "398", "" ))
		df_TesEp := IIF(cEmpAnt == "01", "396", IIF(cEmpAnt == "05", "3J6", "" ))//altera玢o OS 1414-14 em 09/12/2014 por Berger
		A0Y01 := " SELECT COUNT(D1_TES) CONTAD
		A0Y01 += "   FROM "+RetSqlName("SD1")+" SD1
		A0Y01 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
		A0Y01 += "    AND D1_DOC = '"+SF1->F1_DOC+"'
		A0Y01 += "    AND D1_SERIE = '"+SF1->F1_SERIE+"'
		A0Y01 += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"'
		A0Y01 += "    AND D1_LOJA = '"+SF1->F1_LOJA+"'
		A0Y01 += "    AND D1_EMISSAO = '"+dtos(SF1->F1_EMISSAO)+"'
		A0Y01 += "    AND D1_TES = '"+df_TesEp+"'
		A0Y01 += "    AND SD1.D_E_L_E_T_ = ' '
		TCQUERY A0Y01 ALIAS "A0Y1" NEW
		dbSelectArea("A0Y1")
		dbGoTop()
		xf_CntaTs := A0Y1->CONTAD
		A0Y1->(dbCloseArea())
		If xf_CntaTs > 0
			Return(nValor)
		Else
			xf_CntaTs := 0
			A00K7 := " SELECT COUNT(D1_TES) CONTAD
			A00K7 += "   FROM "+RetSqlName("SD1")+" SD1
			A00K7 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
			A00K7 += "                       AND F4_CODIGO = D1_TES
			A00K7 += "                       AND F4_YCCONT NOT IN('999','050')
			A00K7 += "                       AND SF4.D_E_L_E_T_ = ' '
			A00K7 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
			A00K7 += "    AND D1_DOC = '"+SF1->F1_DOC+"'
			A00K7 += "    AND D1_SERIE = '"+SF1->F1_SERIE+"'
			A00K7 += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"'
			A00K7 += "    AND D1_LOJA = '"+SF1->F1_LOJA+"'
			A00K7 += "    AND D1_EMISSAO = '"+dtos(SF1->F1_EMISSAO)+"'
			A00K7 += "    AND SD1.D_E_L_E_T_ = ' '
			TCQUERY A00K7 ALIAS "A0K7" NEW
			dbSelectArea("A0K7")
			dbGoTop()
			xf_CntaTs := A0K7->CONTAD
			A0K7->(dbCloseArea())
			If xf_CntaTs == 0
				Return(nValor)
			EndIf
		EndIf

	ElseIf cCodLP $ '660008/665008'
		// Tratamento feito exclusivamente para tratar o TES 396
		// df_TesEp := IIF(cEmpAnt == "01", "396", IIF(cEmpAnt == "05", "398/3J8", "" ))
		df_TesEp := IIF(cEmpAnt == "01", "396", IIF(cEmpAnt == "05", "3J6", "" ))//altera玢o OS 1414-14 em 09/12/2014 por Berger
		A0Y01 := " SELECT COUNT(D1_TES) CONTAD
		A0Y01 += "   FROM "+RetSqlName("SD1")+" SD1
		A0Y01 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
		A0Y01 += "    AND D1_DOC = '"+SF1->F1_DOC+"'
		A0Y01 += "    AND D1_SERIE = '"+SF1->F1_SERIE+"'
		A0Y01 += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"'
		A0Y01 += "    AND D1_LOJA = '"+SF1->F1_LOJA+"'
		A0Y01 += "    AND D1_EMISSAO = '"+dtos(SF1->F1_EMISSAO)+"'
		A0Y01 += "    AND D1_TES = '"+df_TesEp+"'
		A0Y01 += "    AND SD1.D_E_L_E_T_ = ' '
		TCQUERY A0Y01 ALIAS "A0Y1" NEW
		dbSelectArea("A0Y1")
		dbGoTop()
		xf_CntaTs := A0Y1->CONTAD
		A0Y1->(dbCloseArea())
		If xf_CntaTs == 0
			Return(nValor)
		Else
			A00K7 := " SELECT SUM(D1_TOTAL+D1_VALIPI) TOTVAL
			A00K7 += "   FROM "+RetSqlName("SD1")+" SD1
			A00K7 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
			A00K7 += "                       AND F4_CODIGO = D1_TES
			A00K7 += "                       AND F4_YCCONT NOT IN('999','050')
			A00K7 += "                       AND SF4.D_E_L_E_T_ = ' '
			A00K7 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
			A00K7 += "    AND D1_DOC = '"+SF1->F1_DOC+"'
			A00K7 += "    AND D1_SERIE = '"+SF1->F1_SERIE+"'
			A00K7 += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"'
			A00K7 += "    AND D1_LOJA = '"+SF1->F1_LOJA+"'
			A00K7 += "    AND D1_EMISSAO = '"+dtos(SF1->F1_EMISSAO)+"'
			A00K7 += "    AND SD1.D_E_L_E_T_ = ' '
			TCQUERY A00K7 ALIAS "A0K7" NEW
			dbSelectArea("A0K7")
			dbGoTop()
			xf_TotVal := A0K7->TOTVAL
			A0K7->(dbCloseArea())
			Return(xf_TotVal)
		EndIf
	EndIf

	DO CASE
		CASE cCodLP $ '660001/665001' //PIS
		nValor := SF1->F1_VALPIS
		CASE cCodLP $ '660002/665002' //COFINS
		nValor := SF1->F1_VALCOFI
		CASE cCodLP $ '660003/665003' //CSLL
		nValor := SF1->F1_VALCSLL
		CASE cCodLP $ '660004/665004' //IRRF
		nValor := SF1->F1_IRRF
		CASE cCodLP $ '660005/665005' //ISS
		nValor := SF1->F1_ISS
		CASE cCodLP $ '660006/665006' //INSS
		nValor := SF1->F1_INSS
		CASE cCodLP $ '660007/665007' //TODOS OS VALORES DE RETENCAO
		nValor := SF1->F1_VALBRUT - ( SF1->F1_VALPIS + SF1->F1_VALCOFI + SF1->F1_VALCSLL + SF1->F1_IRRF + SF1->F1_ISS + SF1->F1_INSS )
		OTHERWISE
		nValor := 0
	ENDCASE

	If cArqSD1 <> ""
		dbSelectArea(cArqSD1)
		dbSetOrder(cIndSD1)
		dbGoTo(cRegSD1)
	EndIf

	dbSelectArea(cArq)
	dbSetOrder(cInd)
	dbGoTo(cReg)

	RestArea(xfArea)

Return(nValor)
