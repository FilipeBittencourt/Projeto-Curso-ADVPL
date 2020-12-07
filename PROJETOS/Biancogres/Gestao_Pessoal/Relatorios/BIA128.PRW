#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA128
@author Marcos Alberto Soprani
@since 11/11/16
@version 1.0
@description Lista de tempo de casa
@obs OS: 3101-16 Vera
@type function
/*/

User Function BIA128()

	fPerg  := "BIA128"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	Processa({|| BIA128PRC() })

Return

Static Function BIA128PRC()

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha01"
	nxTabl := "Tempo de Casa" 

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMPRESA      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MATRICULA    "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "INGRESSO     "               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "ADMISSAO     "               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCLVL        "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SITFOLH      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FUNCAO       "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DFUNCAO      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "OBS          "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ANOS_DE_CASA "               ,1,1)

	RT003 := " WITH TIMEHOUSE AS (SELECT 'Biancogres' EMPR,
	RT003 += "                           RA_MAT MATRICULA,
	RT003 += "                           RA_NOME NOME,
	RT003 += "                           RA_YINGRES INGRESSO,
	RT003 += "                           RA_ADMISSA ADMISSAO,
	RT003 += "                           RA_CLVL CLVL,
	RT003 += "                           CTH_DESC01 DCLVL,
	RT003 += "                           RA_SITFOLH SITFOLH,
	RT003 += "                           RA_CODFUNC FUNCAO,
	RT003 += "                           RJ_DESC DFUNCAO,
	RT003 += "                           CASE
	RT003 += "                             WHEN RA_ADMISSA = RA_YINGRES THEN 'ADMITIDO AQUI EM SERRA'
	RT003 += "                             WHEN RA_ADMISSA <> RA_YINGRES THEN 'ORIUNDO DA INCESA'
	RT003 += "                           END OBS,
	RT003 += "                           DATEDIFF ( year , convert(datetime, RA_YINGRES) , "+ ValToSQL(MV_PAR02) +" ) ANOS_DE_CASA
	RT003 += "                      FROM SRA010 SRA
	RT003 += "                      INNER JOIN CTH010 CTH ON CTH_CLVL = RA_CLVL
	RT003 += "                                           AND CTH.D_E_L_E_T_ = ' '
	RT003 += "                      INNER JOIN SRJ010 SRJ ON RJ_FUNCAO = RA_CODFUNC
	RT003 += "                                           AND SRJ.D_E_L_E_T_ = ' '
	RT003 += "                     WHERE RA_FILIAL = '01'
	RT003 += "                       AND RA_MAT <= '199999'
	RT003 += "                       AND RA_SITFOLH <> 'D'
	RT003 += "                       AND SRA.D_E_L_E_T_ = ' '
	RT003 += "                     UNION ALL
	RT003 += "                    SELECT 'Incesa' EMPR,
	RT003 += "                           RA_MAT MATRICULA,
	RT003 += "                           RA_NOME NOME,
	RT003 += "                           RA_YINGRES INGRESSO,
	RT003 += "                           RA_ADMISSA ADMISSAO,
	RT003 += "                           RA_CLVL CLVL,
	RT003 += "                           CTH_DESC01 DCLVL,
	RT003 += "                           RA_SITFOLH SITFOLH,
	RT003 += "                           RA_CODFUNC FUNCAO,
	RT003 += "                           RJ_DESC DFUNCAO,
	RT003 += "                           CASE
	RT003 += "                             WHEN RA_ADMISSA = RA_YINGRES THEN 'ADMITIDO AQUI EM SERRA'
	RT003 += "                             WHEN RA_ADMISSA <> RA_YINGRES THEN 'ORIUNDO DA INCESA'
	RT003 += "                           END OBS,
	RT003 += "                           DATEDIFF ( year , convert(datetime, RA_YINGRES) , "+ ValToSQL(MV_PAR02) +" ) ANOS_DE_CASA
	RT003 += "                      FROM SRA050 SRA
	RT003 += "                      INNER JOIN CTH010 CTH ON CTH_CLVL = RA_CLVL
	RT003 += "                                           AND CTH.D_E_L_E_T_ = ' '
	RT003 += "                      INNER JOIN SRJ010 SRJ ON RJ_FUNCAO = RA_CODFUNC
	RT003 += "                                           AND SRJ.D_E_L_E_T_ = ' '
	RT003 += "                     WHERE RA_FILIAL = '01'
	RT003 += "                       AND RA_MAT <= '199999'
	RT003 += "                       AND RA_SITFOLH <> 'D'
	RT003 += "                       AND SRA.D_E_L_E_T_ = ' '
	RT003 += "                     UNION ALL
	RT003 += "                    SELECT 'JK' EMPR,
	RT003 += "                           RA_MAT MATRICULA,
	RT003 += "                           RA_NOME NOME,
	RT003 += "                           RA_YINGRES INGRESSO,
	RT003 += "                           RA_ADMISSA ADMISSAO,
	RT003 += "                           RA_CLVL CLVL,
	RT003 += "                           CTH_DESC01 DCLVL,
	RT003 += "                           RA_SITFOLH SITFOLH,
	RT003 += "                           RA_CODFUNC FUNCAO,
	RT003 += "                           RJ_DESC DFUNCAO,
	RT003 += "                           CASE
	RT003 += "                             WHEN RA_ADMISSA = RA_YINGRES THEN 'ADMITIDO AQUI EM SERRA'
	RT003 += "                             WHEN RA_ADMISSA <> RA_YINGRES THEN 'ORIUNDO DA INCESA'
	RT003 += "                           END OBS,
	RT003 += "                           DATEDIFF ( year , convert(datetime, RA_YINGRES) , "+ ValToSQL(MV_PAR02) +" ) ANOS_DE_CASA
	RT003 += "                      FROM SRA060 SRA
	RT003 += "                      INNER JOIN CTH010 CTH ON CTH_CLVL = RA_CLVL
	RT003 += "                                           AND CTH.D_E_L_E_T_ = ' '
	RT003 += "                      INNER JOIN SRJ010 SRJ ON RJ_FUNCAO = RA_CODFUNC
	RT003 += "                                           AND SRJ.D_E_L_E_T_ = ' '
	RT003 += "                     WHERE RA_MAT <= '199999'
	RT003 += "                       AND RA_SITFOLH <> 'D'
	RT003 += "                       AND SRA.D_E_L_E_T_ = ' '
	RT003 += "                     UNION ALL
	RT003 += "                    SELECT 'Mundi' EMPR,
	RT003 += "                           RA_MAT MATRICULA,
	RT003 += "                           RA_NOME NOME,
	RT003 += "                           RA_YINGRES INGRESSO,
	RT003 += "                           RA_ADMISSA ADMISSAO,
	RT003 += "                           RA_CLVL CLVL,
	RT003 += "                           CTH_DESC01 DCLVL,
	RT003 += "                           RA_SITFOLH SITFOLH,
	RT003 += "                           RA_CODFUNC FUNCAO,
	RT003 += "                           RJ_DESC DFUNCAO,
	RT003 += "                           CASE
	RT003 += "                             WHEN RA_ADMISSA = RA_YINGRES THEN 'ADMITIDO AQUI EM SERRA'
	RT003 += "                             WHEN RA_ADMISSA <> RA_YINGRES THEN 'ORIUNDO DA INCESA'
	RT003 += "                           END OBS,
	RT003 += "                           DATEDIFF ( year , convert(datetime, RA_YINGRES) , "+ ValToSQL(MV_PAR02) +" ) ANOS_DE_CASA
	RT003 += "                      FROM SRA130 SRA
	RT003 += "                      INNER JOIN CTH010 CTH ON CTH_CLVL = RA_CLVL
	RT003 += "                                           AND CTH.D_E_L_E_T_ = ' '
	RT003 += "                      INNER JOIN SRJ010 SRJ ON RJ_FUNCAO = RA_CODFUNC
	RT003 += "                                           AND SRJ.D_E_L_E_T_ = ' '
	RT003 += "                     WHERE RA_FILIAL = '01'
	RT003 += "                       AND RA_MAT <= '199999'
	RT003 += "                       AND RA_SITFOLH <> 'D'
	RT003 += "                       AND SRA.D_E_L_E_T_ = ' '
	RT003 += "                     UNION ALL
	RT003 += "                    SELECT 'Vitcer' EMPR,
	RT003 += "                           RA_MAT MATRICULA,
	RT003 += "                           RA_NOME NOME,
	RT003 += "                           RA_YINGRES INGRESSO,
	RT003 += "                           RA_ADMISSA ADMISSAO,
	RT003 += "                           RA_CLVL CLVL,
	RT003 += "                           CTH_DESC01 DCLVL,
	RT003 += "                           RA_SITFOLH SITFOLH,
	RT003 += "                           RA_CODFUNC FUNCAO,
	RT003 += "                           RJ_DESC DFUNCAO,
	RT003 += "                           CASE
	RT003 += "                             WHEN RA_ADMISSA = RA_YINGRES THEN 'ADMITIDO AQUI EM SERRA'
	RT003 += "                             WHEN RA_ADMISSA <> RA_YINGRES THEN 'ORIUNDO DA INCESA'
	RT003 += "                           END OBS,
	RT003 += "                           DATEDIFF ( year , convert(datetime, RA_YINGRES) , "+ ValToSQL(MV_PAR02) +" ) ANOS_DE_CASA
	RT003 += "                      FROM SRA140 SRA
	RT003 += "                      INNER JOIN CTH010 CTH ON CTH_CLVL = RA_CLVL
	RT003 += "                                           AND CTH.D_E_L_E_T_ = ' '
	RT003 += "                      INNER JOIN SRJ010 SRJ ON RJ_FUNCAO = RA_CODFUNC
	RT003 += "                                           AND SRJ.D_E_L_E_T_ = ' '
	RT003 += "                     WHERE RA_FILIAL = '01'
	RT003 += "                       AND RA_MAT <= '199999'
	RT003 += "                       AND RA_SITFOLH <> 'D'
	RT003 += "                       AND SRA.D_E_L_E_T_ = ' ')
	RT003 += " SELECT *
	RT003 += "   FROM TIMEHOUSE
	RT003 += "  ORDER BY 1, 2
	RTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT003),'RT03',.F.,.T.)
	dbSelectArea("RT03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(nxPlan, nxTabl, { RT03->EMPR    ,;
		RT03->MATRICULA                               ,;
		RT03->NOME                                    ,;
		stod(RT03->INGRESSO)                          ,;
		stod(RT03->ADMISSAO)                          ,;
		RT03->CLVL                                    ,;
		RT03->DCLVL                                   ,;
		RT03->SITFOLH                                 ,;
		RT03->FUNCAO                                  ,;
		RT03->DFUNCAO                                 ,;
		RT03->OBS                                     ,;
		RT03->ANOS_DE_CASA		                      })

		dbSelectArea("RT03")
		dbSkip()

	End

	RT03->(dbCloseArea())
	Ferase(RTcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RTcIndex+OrdBagExt())          //indice gerado

	xArqTemp := IIF(Empty(MV_PAR01), "BIA128", Alltrim(MV_PAR01) )

	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 04/08/16 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Nome do Arquivo:      ?","","","mv_ch1","C",20,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data de Referencia:      ?","","","mv_ch2","D",0,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
