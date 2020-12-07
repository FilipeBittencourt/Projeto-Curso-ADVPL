#include "rwmake.ch"

/*/{Protheus.doc} BIA574
@author Marcos Alberto Soprani
@since 22/07/20
@version 1.1
@description Tela de cadastro de META para Forno Vazio  
@type function
/*/                                                                                               

User Function BIA574()

	Private aRotina := {}
	Private cCadastro := "Meta para Forno Vazio"
	Private cAlias := "ZDD"

	aAdd(aRotina, {"Pesquisar"  , "PesqBrw"   , 0, 1})
	aAdd(aRotina, {"Visualizar" , "AxVisual"  , 0, 2})
	aAdd(aRotina, {"Incluir"    , "AxInclui"  , 0, 3})
	aAdd(aRotina, {"Alterar"    , "AxAltera"  , 0, 4})
	aAdd(aRotina, {"Excluir"    , "AxDeleta"  , 0, 5})
	aAdd(aRotina, {"Replicar"   , "U_BIA574A" , 0, 6})

	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias)

Return()

User Function BIA574A()

	Private msEnter     := CHR(13) + CHR(10)      
	Private msStaExcQy  := 0
	Private mslOk       := .T.
	Private msGravaErr  := ""

	fPerg := "BIA574"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	Begin Transaction

		TY001 := Alltrim(" WITH ZDDDTREF                                                                                       ") + msEnter
		TY001 += Alltrim("      AS (SELECT FILIAL = ZDD_FILIAL,                                                                ") + msEnter
		TY001 += Alltrim("                 DTREF = ZDD_DTREF,                                                                  ") + msEnter
		TY001 += Alltrim("                 TURNO = ZDD_TURNO,                                                                  ") + msEnter
		TY001 += Alltrim("                 LINHA = ZDD_LINHA,                                                                  ") + msEnter
		TY001 += Alltrim("                 META = ZDD_META,                                                                    ") + msEnter
		TY001 += Alltrim("                 REGZDD = R_E_C_N_O_                                                                 ") + msEnter
		TY001 += Alltrim("          FROM " + RetSqlName("ZDD") + " ZDD(NOLOCK)                                                 ") + msEnter
		TY001 += Alltrim("          WHERE ZDD_FILIAL = '" + xFilial("ZDD") + "'                                                ") + msEnter
		TY001 += Alltrim("                AND ZDD_DTREF = '" + dtos(ZDD->ZDD_DTREF) + "'                                       ") + msEnter
		TY001 += Alltrim("                AND ZDD_LINHA = '" + ZDD->ZDD_LINHA + "'                                             ") + msEnter
		TY001 += Alltrim("                AND D_E_L_E_T_ = ' ')                                                                ") + msEnter
		TY001 += Alltrim("      INSERT INTO " + RetSqlName("ZDD") + "                                                          ") + msEnter
		TY001 += Alltrim("      (ZDD_FILIAL,                                                                                   ") + msEnter
		TY001 += Alltrim("       ZDD_DTREF,                                                                                    ") + msEnter
		TY001 += Alltrim("       ZDD_TURNO,                                                                                    ") + msEnter
		TY001 += Alltrim("       ZDD_LINHA,                                                                                    ") + msEnter
		TY001 += Alltrim("       ZDD_META,                                                                                     ") + msEnter
		TY001 += Alltrim("       D_E_L_E_T_,                                                                                   ") + msEnter
		TY001 += Alltrim("       R_E_C_N_O_,                                                                                   ") + msEnter
		TY001 += Alltrim("       R_E_C_D_E_L_,                                                                                 ") + msEnter
		TY001 += Alltrim("       ZDD_OBS                                                                                       ") + msEnter
		TY001 += Alltrim("      )                                                                                              ") + msEnter
		TY001 += Alltrim("             SELECT *,                                                                               ") + msEnter
		TY001 += Alltrim("                    OBS = ' '                                                                        ") + msEnter
		TY001 += Alltrim("             FROM                                                                                    ") + msEnter
		TY001 += Alltrim("             (                                                                                       ") + msEnter
		TY001 += Alltrim("                 SELECT FILIAL,                                                                      ") + msEnter
		TY001 += Alltrim("                        CONVERT(VARCHAR, B.DATA, 112) ZDD_DTREF,                                     ") + msEnter
		TY001 += Alltrim("                        TURNO,                                                                       ") + msEnter
		TY001 += Alltrim("                        LINHA,                                                                       ") + msEnter
		TY001 += Alltrim("                        META,                                                                        ") + msEnter
		TY001 += Alltrim("                        ' ' D_E_L_E_T_,                                                              ") + msEnter
		TY001 += Alltrim("                 (                                                                                   ") + msEnter
		TY001 += Alltrim("                     SELECT MAX(R_E_C_N_O_)                                                          ") + msEnter
		TY001 += Alltrim("                     FROM " + RetSqlName("ZDD") + " ZDD(NOLOCK)                                      ") + msEnter
		TY001 += Alltrim("                 ) + ROW_NUMBER() OVER(                                                              ") + msEnter
		TY001 += Alltrim("                        ORDER BY ZDD.REGZDD) AS R_E_C_N_O_,                                          ") + msEnter
		TY001 += Alltrim("                        0 R_E_C_D_E_L_                                                               ") + msEnter
		TY001 += Alltrim("                 FROM ZDDDTREF ZDD                                                                   ") + msEnter
		TY001 += Alltrim("                      LEFT JOIN FNC_CALENDARIO('" + dtos(MV_PAR01) + "', '" + dtos(MV_PAR02) + "') B ON 1 = 1  ") + msEnter
		TY001 += Alltrim("             ) AS TEMP1                                                                              ") + msEnter
		TY001 += Alltrim("             WHERE NOT EXISTS                                                                        ") + msEnter
		TY001 += Alltrim("             (                                                                                       ") + msEnter
		TY001 += Alltrim("                 SELECT *                                                                            ") + msEnter
		TY001 += Alltrim("                 FROM " + RetSqlName("ZDD") + " XXX(NOLOCK)                                          ") + msEnter
		TY001 += Alltrim("                 WHERE XXX.ZDD_DTREF = TEMP1.ZDD_DTREF                                               ") + msEnter
		TY001 += Alltrim("             )                                                                                       ") + msEnter
		U_BIAMsgRun("Aguarde... Criando arquivo de Trabalho... ",,{|| msStaExcQy := TcSQLExec(TY001) })
		If msStaExcQy < 0
			mslOk := .F.
		EndIf

		If !mslOk

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction 

	If mslOk

		MsgINFO("Processamento realizado com Sucesso.", "Fim do processamento")

	Else

		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msEnter + msEnter + msEnter + msGravaErr + msEnter + msEnter + msEnter + msEnter + "Processo Cancelado!!!" + msEnter + msEnter + msEnter, {'Fecha'}, 3 )

	EndIf

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
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
