#include "rwMake.ch"
#include "Topconn.ch"

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  � EXP_VALE       篈utor  � BRUNO MADALENO     � Data �  08/05/07   罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     � EXPORTACAO DO VALE TRANSPORTE 碢ARA OS CARTOES DOS MESMOS        罕�
北�          �                													罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � AP 7                                                             罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

User Function EXP_VALE()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private cSQL
	Private cEOL       := "CHR(13)+CHR(10)"
	Private Enter      := CHR(13)+CHR(10) 
	Private cArqTxt    := "C:\TEMP\VALE.TXT"
	PRIVATE nARQUIVO   := ""
	Public bpmFiltM0Tr := Space(200)

	fPerg  := "VA_TRA"
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
	U_GPM5002()

	cSQL := " SELECT RA_CLVL, " + Enter
	cSQL += "        RA_APELIDO, " + Enter
	cSQL += "        RA_MAT, " + Enter
	cSQL += "        RA_NOME, " + Enter
	cSQL += "        RA_VALEREF, " + Enter
	cSQL += "        RA_TNOTRAB, " + Enter
	cSQL += "        R0_CODIGO, " + Enter
	cSQL += "        ISNULL(R0_QDIACAL,0) VALE, " + Enter
	cSQL += "        (R6_DIAVTRA) TICK " + Enter
	cSQL += "   FROM " + RetSqlName("SRA") + " SRA " + Enter
	cSQL += "  INNER JOIN " + RetSqlName("SR6") + " SR6 ON SR6.R6_TURNO = SRA.RA_TNOTRAB " + Enter
	cSQL += "                       AND SR6.D_E_L_E_T_ = ' ' " + Enter
	cSQL += "   LEFT JOIN " + RetSqlName("SR0") + " SR0 ON SRA.RA_MAT = SR0.R0_MAT " + Enter
	cSQL += "                       AND SR0.D_E_L_E_T_ = ' ' " + Enter
	cSQL += "  WHERE SRA.RA_SITFOLH <> 'D' " + Enter
	cSQL += "	 AND SRA.D_E_L_E_T_ = ' ' " + Enter
	If chkfile("_VAL")
		dbSelectArea("_VAL")
		dbCloseArea()
	EndIf
	TCQUERY cSQL NEW ALIAS "_VAL"

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif
	nARQUIVO    := fCreate(cArqTxt)

	nxCont := 0 
	dbSelectArea("_VAL")
	dbGoTop()
	ProcRegua(RecCount())
	While !_VAL->(Eof())

		nxCont ++
		IncProc("Processamento... " + Alltrim(Str(nxCont)))

		If _VAL->R0_CODIGO $ bpmFiltM0Tr

			If _VAL->VALE <> 0
				nLINHA := _VAL->RA_MAT + ";"
				nLINHA += _VAL->RA_NOME + ";"
				nLINHA += alltrim(STRTRAN(STR((_VAL->VALE * mv_par01),14,2),".",",")) + ";"         
				fWrite(nARQUIVO,nLINHA+cEOL)
			EndIf

		EndIf

		_VAL->(DBSKIP())

	End

	fClose(nARQUIVO)

	Aviso('Fim de processamento', 'Arquivo >> c:\temp\vale.txt << gerado com sucesso !!!',{'Ok'})

Return
