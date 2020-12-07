#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#INCLUDE "SHELL.CH"
#include "Fileio.ch"
#include "vkey.ch"
#include "Ap5Mail.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA242
Empresa   := Biancogres Cerâmica S/A
Data      := 21/08/12
Uso       := Livros Fiscais
Aplicação := Layout ISS Web para Prefeitura de Serra-ES
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA242()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	cHInicio := Time()
	fPerg := "BIA242"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If Month(MV_PAR01) <> Month(MV_PAR02)
		MsgINFO("Não é permitido processamento fora MES.")
		Return
	EndIf

	// Estrutura para criação do arquivo txt
	df_ArqEtq := "c:\temp\iss_web_"+dtos(MV_PAR02)+".txt"
	If File(df_ArqEtq)
		FERASE(df_ArqEtq)
		nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
		FCLOSE(nHandle)
	Else
		nHandle := FCREATE(df_ArqEtq, FC_NORMAL)
		FCLOSE(nHandle)
	EndIf
	nTerHdl := FOPEN(df_ArqEtq,FO_WRITE)
	nTamArq := FSEEK(nTerHdl,0,0)

	//                                                         Monta registro Header
	********************************************************************************
	fr_Header := +;
	Padr("0"                             ,001)+;
	Padr("T"                             ,001)+;
	Padr("1"                             ,001)+;
	Padr(SM0->M0_CGC                     ,014)+;
	Padr(Substr(MV_PAR04,1,2)            ,002)+;
	Padr(Substr(MV_PAR04,3,4)            ,004)+;
	Padr(GravaData(dDatabase, .F., 5)    ,008)+;
	Padr(IIF(MV_PAR03 == 1, "N", "C")    ,001)+;
	Padr("02"                            ,002)+;
	Padr(Space(66)                       ,066)
	FWRITE(nTerHdl,  fr_Header + CRLF )

	tt_RegTp1 := 0
	tt_Servic := 0
	tt_Deduca := 0
	tt_Impost := 0

	KF001 := " SELECT F1_DOC,
	KF001 += "        F1_SERIE,
	KF001 += "        F1_DTDIGIT,
	KF001 += "        F1_EMISSAO,
	KF001 += "        A2_CGC,
	KF001 += "        A2_NOME,
	KF001 += "        A2_MUN,
	KF001 += "        A2_EST,
	KF001 += "        A2_SIMPNAC,
	KF001 += "        F1_VALBRUT,
	KF001 += "        SUM(DEDUCOES) DEDUCOES,
	KF001 += "        B1_CODISS,
	KF001 += "        SUM(D1_BASEISS) D1_BASEISS,
	KF001 += "        AVG(D1_ALIQISS) D1_ALIQISS,
	KF001 += "        SUM(D1_VALISS) D1_VALISS,
	KF001 += "        SITUACAO,
	KF001 += "        VLR_IMPOST
	KF001 += "   FROM (SELECT SF1.F1_DOC, 
	KF001 += "                SF1.F1_SERIE, 
	KF001 += "                F1_DTDIGIT, 
	KF001 += "                F1_EMISSAO, 
	KF001 += "                A2_CGC, 
	KF001 += "                SA2.A2_NOME, 
	KF001 += "                SA2.A2_MUN, 
	KF001 += "                SA2.A2_EST, 
	KF001 += "                CASE 
	KF001 += "                  WHEN SA2.A2_SIMPNAC = '1' THEN '540' 
	KF001 += "                  ELSE '512' 
	KF001 += "                END A2_SIMPNAC, 
	KF001 += "                SF1.F1_VALBRUT, 
	KF001 += "                0   DEDUCOES, 
	KF001 += "                SB1.B1_CODISS, 
	KF001 += "                SD1.D1_BASEISS, 
	KF001 += "                SD1.D1_ALIQISS, 
	KF001 += "                SD1.D1_VALISS, 
	KF001 += "                '1' SITUACAO, 
	KF001 += "                'S' VLR_IMPOST 
	KF001 += "           FROM "+RetSqlName("SF1")+" SF1 
	KF001 += "          INNER JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL = '"+xFilial("SA2")+"' 
	KF001 += "                           AND SA2.A2_COD = SF1.F1_FORNECE 
	KF001 += "                           AND SA2.A2_LOJA = SF1.F1_LOJA 
	KF001 += "                           AND SA2.D_E_L_E_T_ = ' ' 
	KF001 += "          INNER JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL = '"+xFilial("SD1")+"' 
	KF001 += "                           AND SD1.D1_DOC = SF1.F1_DOC 
	KF001 += "                           AND SD1.D1_SERIE = SF1.F1_SERIE 
	KF001 += "                           AND SD1.D1_FORNECE = SF1.F1_FORNECE 
	KF001 += "                           AND SD1.D1_LOJA = SF1.F1_LOJA 
	KF001 += "                           AND SD1.D_E_L_E_T_ = ' ' 
	KF001 += "          INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' 
	KF001 += "                           AND SB1.B1_COD = SD1.D1_COD 
	KF001 += "                           AND SB1.D_E_L_E_T_ = ' ' 
	KF001 += "          WHERE SF1.F1_FILIAL = '01' 
	KF001 += "            AND SF1.F1_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND 
	KF001 += "                                       '"+dtos(MV_PAR02)+"' 
	KF001 += "            AND SF1.F1_ISS <> 0 
	KF001 += "            AND SF1.F1_DUPL <> '         ' 
	KF001 += "            AND (SELECT SUM(E2_ISS) 
	KF001 += "                   FROM "+RetSqlName("SE2") 
	KF001 += "                  WHERE E2_FILIAL = '"+xFilial("SE2")+"' 
	KF001 += "                    AND E2_PREFIXO = SF1.F1_SERIE 
	KF001 += "                    AND E2_NUM = SF1.F1_DOC 
	KF001 += "                    AND E2_FORNECE = SF1.F1_FORNECE 
	KF001 += "                    AND E2_LOJA = SF1.F1_LOJA 
	KF001 += "                    AND E2_EMIS1 = SF1.F1_DTDIGIT 
	KF001 += "                    AND E2_TIPO = 'NF' 
	KF001 += "                    AND D_E_L_E_T_ = ' ') > 0 
	KF001 += "            AND SF1.D_E_L_E_T_ = ' ') SERV  
	KF001 += "  GROUP BY F1_DOC,
	KF001 += "           F1_SERIE,
	KF001 += "           F1_DTDIGIT,
	KF001 += "           F1_EMISSAO,
	KF001 += "           A2_CGC,
	KF001 += "           A2_NOME,
	KF001 += "           A2_MUN,
	KF001 += "           A2_EST,
	KF001 += "           A2_SIMPNAC,
	KF001 += "           F1_VALBRUT,
	KF001 += "           B1_CODISS,
	KF001 += "           SITUACAO,
	KF001 += "           VLR_IMPOST
	TcQuery KF001 ALIAS "KF01" NEW
	dbSelectArea("KF01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		//                                                        Monta registro Detalhe
		********************************************************************************
		fr_Detalhe := +;
		Padr("1"                                                                 ,001)+;
		Padr(IIF(Len(Alltrim(KF01->A2_CGC)) == 14, "1", "2" )                    ,001)+;
		Padr(KF01->A2_CGC                                                        ,014)+;
		Padr(KF01->A2_NOME                                                       ,100)+;
		Padr(KF01->A2_MUN                                                        ,060)+;
		Padr(KF01->A2_EST                                                        ,002)+;
		Padr(StrZero(Val(Alltrim(KF01->F1_DOC)),8)                               ,008)+;
		Padr(GravaData(stod(KF01->F1_EMISSAO), .F., 5)                           ,008)+;
		Padr(StrZero(KF01->D1_BASEISS*100,14)                                    ,014)+;
		Padr(StrZero(KF01->DEDUCOES*100,14)                                      ,014)+;
		Padr(StrZero(KF01->D1_ALIQISS*100,05)                                    ,005)+;
		Padr(StrZero(KF01->D1_VALISS*100,14)                                     ,014)+;
		Padr("S"                                                                 ,001)+;
		Padr("1"                                                                 ,001)+;
		Padr(StrZero(Val(Alltrim(StrTran(KF01->B1_CODISS, ".",""))),6)           ,006)+;
		Padr(KF01->A2_SIMPNAC                                                    ,003)+;
		Padr("01"                                                                ,002)+;
		Padr(Space(96)                                                           ,096)
		FWRITE(nTerHdl,  fr_Detalhe + CRLF )

		tt_RegTp1 ++
		tt_Servic += KF01->D1_BASEISS
		tt_Deduca += KF01->DEDUCOES
		tt_Impost += KF01->D1_VALISS

		dbSelectArea("KF01")
		dbSkip()
	End

	KF01->(dbCloseArea())

	//                                                       Monta registro Trailler
	********************************************************************************
	fr_Trailler := +;
	Padr("9"                                                                 ,001)+;
	Padr(StrZero(tt_RegTp1,04)                                               ,004)+;
	Padr(StrZero(tt_Servic*100,14)                                           ,014)+;
	Padr(StrZero(tt_Deduca*100,14)                                           ,014)+;
	Padr(StrZero(tt_Impost*100,14)                                           ,014)+;
	Padr(Space(53)                                                           ,053)
	FWRITE(nTerHdl,  fr_Trailler + CRLF )

	FCLOSE(nTerHdl)

	MsgINFO("Arquivo: " + df_ArqEtq + " foi gerado!!!")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Tipo Referência     ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Normal","","","","","Complementar","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Mes / Ano de Refer. ?","","","mv_ch4","C",06,0,0,"C","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
