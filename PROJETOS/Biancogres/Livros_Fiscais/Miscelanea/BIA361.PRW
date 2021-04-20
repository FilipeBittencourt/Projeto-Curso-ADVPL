#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"

/*/{Protheus.doc} BIA361
@author Marcos Alberto Soprani
@since 21/12/17
@version 1.0
@description Geração de retistros referente Demais Documentos PIS/COFINS - tabela CF8
@type function
/*/

User Function BIA361()

	cHInicio := Time()
	fPerg := "BIA361"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	Processa({ || fProcGrava() }, "Aguarde...", "Carregando Arquivo...", .F.)

Return

//Processa listagem para gravação dos registros
Static Function fProcGrava()

	Local aRetCF8   := {}
	// Local msEnter   := CHR(13)+CHR(10)
	Local msDeData  := MV_PAR01 + "01"
	Local msAtData  := dtos(UltimoDia(stod(MV_PAR01 + "01")))  

	// "Conta", "Empr", "Tipo Regime:", "Ind. Oper:", "Sit. Trib.PIS:", "Sit. Trib.cofins:", "aliquota PIS:", "aliquota COFINS:", "Tab.Nat.Re:"
	Aadd( aRetCF8, {"414", "01", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "03", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "05", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "06", "1", "2", "06", "06", 0.00, 0.00, "911"} )
	Aadd( aRetCF8, {"414", "07", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "08", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "09", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "10", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "11", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "12", "1", "2", "06", "06", 0.00, 0.00, "911"} )
	Aadd( aRetCF8, {"414", "13", "2", "1", "02", "02", 0.65, 4.00, "911"} )
	Aadd( aRetCF8, {"414", "14", "1", "2", "06", "06", 0.00, 0.00, "911"} )
	Aadd( aRetCF8, {"414", "16", "1", "2", "06", "06", 0.00, 0.00, "911"} )	
	Aadd( aRetCF8, {"414", "17", "1", "2", "06", "06", 0.00, 0.00, "911"} )
	Aadd( aRetCF8, {"415", "01", "2", "2", "07", "07", 0.00, 0.00, "999"} )
	Aadd( aRetCF8, {"415", "03", "2", "1", "01", "01", 1.65, 7.60, "911"} )
	Aadd( aRetCF8, {"415", "05", "2", "2", "07", "07", 0.00, 0.00, "999"} )
	Aadd( aRetCF8, {"415", "08", "2", "1", "01", "01", 1.65, 7.60, "911"} )
	Aadd( aRetCF8, {"415", "09", "2", "1", "01", "01", 1.65, 7.60, "911"} )
	Aadd( aRetCF8, {"415", "10", "2", "1", "01", "01", 1.65, 7.60, "911"} )
	Aadd( aRetCF8, {"415", "11", "2", "1", "01", "01", 1.65, 7.60, "911"} )
	Aadd( aRetCF8, {"415", "13", "2", "1", "01", "01", 1.65, 7.60, "999"} )

	aSort(aRetCF8,,, { |x, y| x[1] + x[2] < y[1] + y[2] }) // Reordena Conta + Empr

	BX009 := " SELECT CQ1_CONTA CONTA, "
	BX009 += "        SUM(CQ1_DEBITO - CQ1_CREDIT) * ( -1 ) SALDO, "
	BX009 += "        (SELECT MAX(CF8_CODIGO) "
	BX009 += "           FROM " + RetSqlName("CF8") + " "
	BX009 += "          WHERE D_E_L_E_T_ = ' ') CODIGO "
	BX009 += "   FROM " + RetSqlName("CQ1") + " CQ1 "
	BX009 += "  WHERE CQ1_DATA BETWEEN '" + msDeData + "' AND '" + msAtData + "' "
	BX009 += "    AND ( SUBSTRING(CQ1_CONTA, 1, 3) IN( '414' ) "
	BX009 += "          OR CQ1_CONTA IN('41501010','41501007') ) "
	BX009 += "    AND CQ1.D_E_L_E_T_ = ' ' "
	BX009 += "  GROUP BY CQ1_CONTA "
	BXIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,BX009),'BX09',.T.,.T.)
	dbSelectArea("BX09")
	BX09->(dbGoTop())

	If BX09->(!Eof())

		ProcRegua(RecCount())
		msCodigoSeq := BX09->CODIGO

		While BX09->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str(BX09->(Recno()))) )

			msKeyCta := Substr(BX09->CONTA,1,3)
			nPosColG := aScan(aRetCF8,{|x| AllTrim(x[1]) + AllTrim(x[2]) == msKeyCta + cEmpAnt } )
			//msCodigoSeq := Soma1(msCodigoSeq) 
			msCodigoSeq := GETSXENUM("CF8","CF8_CODIGO","CF8_CODIGO",1)

			if RecLock("CF8", .T.)
				CF8->CF8_FILIAL := xFilial("CF8")
				CF8->CF8_TPREG  := aRetCF8[nPosColG][3]
				CF8->CF8_INDOPE := aRetCF8[nPosColG][4]
				CF8->CF8_DTOPER := stod(msAtData)
				CF8->CF8_VLOPER := BX09->SALDO
				CF8->CF8_CSTPIS := aRetCF8[nPosColG][5]
				CF8->CF8_BASPIS := BX09->SALDO
				CF8->CF8_ALQPIS := aRetCF8[nPosColG][7]
				CF8->CF8_VALPIS := BX09->SALDO * aRetCF8[nPosColG][7] / 100
				CF8->CF8_CSTCOF := aRetCF8[nPosColG][6]
				CF8->CF8_BASCOF := BX09->SALDO
				CF8->CF8_ALQCOF := aRetCF8[nPosColG][8]
				CF8->CF8_VALCOF := BX09->SALDO * aRetCF8[nPosColG][8] / 100
				CF8->CF8_CODCTA := BX09->CONTA
				CF8->CF8_SCORGP := aRetCF8[nPosColG][9]
				CF8->CF8_SALDO  := BX09->SALDO
				CF8->CF8_CODIGO := msCodigoSeq	
				CF8->CF8_RECBRU := '2'	
				
				ConfirmSx8()
				
				MsUnLock()
			else
			    RollbackSx8()
			endif

			BX09->(dbSkip())
		End

	EndIf

	BX09->(dbCloseArea())
	Ferase(BXIndex+GetDBExtension())
	Ferase(BXIndex+OrdBagExt())

	MsgINFO("Fim do Processamento...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.05.06 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
	Local i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Ano / Mes         ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
	dbSelectArea(_sAlias)

Return
