#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA726
@author Marcos Alberto Soprani
@since 24/09/03
@version 1.0
@description Quadro de Pessoal
@obs Em 09/03/17... Por Marcos Alberto Soprani revisto tratamento de transferência entre empresas para CLVL
@obs Em 27/03/19... Marcelo Sousa - Facile - OS 13638-19 - Feita mudança em fonte para que verifique todas as 
@obs empresas que possuem matrículas ativas. 
@type function
/*/

User Function BIA726()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi
	Local aEmpr := {} 
	Local aTeste := {}
	Local gbAreAtu := GetArea()
	
	Local a
	
	cHInicio := Time()
	fPerg := "BIA726"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	// Buscando empresas do Sigamat
	aEmpr := retemp("01_03_04_05_06_07_08_09_10_11_12_13_14_16_17_90_91")
	
	// Verificando quais empresas possuem funcionarios ativos
	FOR a := 1 to len(aEmpr)
	
		cVal := ""
		
		cVal += " SELECT MAX(RA_MAT) AS RA_MAT "
		cVal += " FROM SRA" + aEmpr[a,1] + "0"
		cVal += " WHERE D_E_L_E_T_ = ''"
		cVal += " AND RA_FILIAL = '" + aEmpr[a,2] + "' " 
		cVal += " AND RA_DEMISSA = '' "
		cVal += " AND RA_FILIAL = '" + aEmpr[a,2] + "'"
		cVal += " AND RA_CATFUNC IN ('M','E','P') "
		Tcquery cVal New Alias cTeste
		
		IF cTeste->RA_MAT <> "      "
		
			aAdd(aTeste,{aEmpr[a,1],aEmpr[a,2],SUBSTRING(aEmpr[a,3],1,3)}) 
		
		ENDIF 
				
		cTeste->(DBCLOSEAREA())			
				
	Next a

	xyDtIni := Substr(dtos(MV_PAR01),1,6) + "01"
	xyDtFim := dtos(MV_PAR01) 

	//Rodando query´s para puxar funcionários ativos e gerar arquivo excel de saída. 
	execfun(aTeste,MV_PAR01,xyDtFim,xyDtIni)

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
	aAdd(aRegs,{cPerg,"01","Data de Referência  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ execfun¦ Autor ¦ Marcelo Sousa Correa    ¦ Data ¦ 27/03/19 ¦¦¦
¦¦¦Função utilizada para que o sistema busque todos os funcionários       ¦¦¦
¦¦¦Ativos nas empresas selecionadas, bem como gere o XML final.           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function execfun(aEmpr,MV_PAR01,xyDtFim,xyDtIni)

	Local xSaltLin := Chr(13) + Chr(10)
	
	Local i
	
	//-------------------------------------------------------------
	// Colaboradores
	//-------------------------------------------------------------
	RW005 := ""
	RW005 += Alltrim(" SELECT ' ' REFERENCIA,                                                                                      ") + xSaltLin
	RW005 += Alltrim("        QUADRO.*,                                                                                            ") + xSaltLin
	RW005 += Alltrim("        CTH_YQUADR QUADRO                                                                                    ") + xSaltLin
	RW005 += Alltrim("   FROM (                                                                                    				   ") + xSaltLin
	
	FOR i := 1 to len(aEmpr) 
	
		RW005 += Alltrim("                SELECT 'COLAB' TIPO,                                                                                ") + xSaltLin
		RW005 += Alltrim("                '"+ aEmpr[i,3] +"' EMPR,                                                                                  ") + xSaltLin
		RW005 += Alltrim("                ISNULL((SELECT TOP 1 RE_CLVLP                                                                ") + xSaltLin
		RW005 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW005 += Alltrim("                         WHERE RE_FILIALD = RE_FILIALP                                                       ") + xSaltLin
		RW005 += Alltrim("                           AND RE_EMPD = RE_EMPP                                                             ") + xSaltLin
		RW005 += Alltrim("                           AND RE_MATD = RE_MATP                                                             ") + xSaltLin
		RW005 += Alltrim("                           AND RE_FILIALP = '01'                                                             ") + xSaltLin
		RW005 += Alltrim("                           AND RE_EMPP = '"+ aEmpr[i,1] +"'                                                                ") + xSaltLin
		RW005 += Alltrim("                           AND RE_MATP = RA_MAT                                                              ") + xSaltLin
		RW005 += Alltrim("                           AND RE_DATA IN(SELECT MAX(RE_DATA)                                                ") + xSaltLin
		RW005 += Alltrim("                                            FROM SRE010 SRE                                                  ") + xSaltLin
		RW005 += Alltrim("                                           WHERE RE_FILIALD = RE_FILIALP                                     ") + xSaltLin
		RW005 += Alltrim("                                             AND RE_EMPD = RE_EMPP                                           ") + xSaltLin
		RW005 += Alltrim("                                             AND RE_MATD = RE_MATP                                           ") + xSaltLin
		RW005 += Alltrim("                                             AND RE_FILIALP = '"+ aEmpr[i,2] +"'                                           ") + xSaltLin
		RW005 += Alltrim("                                             AND RE_EMPP = '"+ aEmpr[i,1] +"'                                              ") + xSaltLin
		RW005 += Alltrim("                                             AND RE_MATP = RA_MAT                                            ") + xSaltLin
		RW005 += Alltrim("                                             AND RE_DATA <= '" + dtos(MV_PAR01) + "'                         ") + xSaltLin
		RW005 += Alltrim("                                             AND SRE.D_E_L_E_T_ = ' ')                                       ") + xSaltLin
		RW005 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), RA_CLVL) RA_CLVL,                                      ") + xSaltLin
		RW005 += Alltrim("                RA_MAT,                                                                                      ") + xSaltLin
		RW005 += Alltrim("                RA_NOME,                                                                                     ") + xSaltLin
		RW005 += Alltrim("                RA_ADMISSA,                                                                                  ") + xSaltLin
		RW005 += Alltrim("                RA_DEMISSA,                                                                                  ") + xSaltLin
		//****************
		RW005 += Alltrim("                (SELECT CASE                                                                                                                                                                                                                                              ") + xSaltLin
		RW005 += Alltrim("                          WHEN R8_DATAFIM = ''                                                                                                                                                                                                     THEN 'Afastado: TP1'   ") + xSaltLin
		RW005 += Alltrim("                          WHEN R8_DATAINI < '" + xyDtIni + "'                                 AND R8_DATAFIM <> '' AND R8_DATAFIM <= '" + xyDtFim + "' AND DATEDIFF(dd,'" + xyDtIni + "',R8_DATAFIM) + 1 > 15                                      THEN 'Afastado: TP2'   ") + xSaltLin
		RW005 += Alltrim("                          WHEN R8_DATAINI BETWEEN '" + xyDtIni + "' AND '" + xyDtFim + "'     AND R8_DATAFIM <> '' AND R8_DATAFIM <= '" + xyDtFim + "' AND DATEDIFF(dd,R8_DATAINI,R8_DATAFIM)        + 1 > 15                                      THEN 'Afastado: TP3'   ") + xSaltLin
		RW005 += Alltrim("                          WHEN R8_DATAINI BETWEEN '" + xyDtIni + "' AND '" + xyDtFim + "'     AND R8_DATAFIM <> '' AND R8_DATAFIM >  '" + xyDtFim + "' AND DATEDIFF(dd,R8_DATAINI,'" + xyDtFim + "') + 1 > 15                                      THEN 'Afastado: TP4'   ") + xSaltLin
		RW005 += Alltrim("                          WHEN R8_DATAINI < '" + xyDtIni + "'                                 AND R8_DATAFIM <> '' AND R8_DATAFIM >  '" + xyDtFim + "' AND DATEDIFF(dd,'"+xyDtIni+"','"+xyDtFim+ "') + 1 > 15                                      THEN 'Afastado: TP5'   ") + xSaltLin
		RW005 += Alltrim("                          WHEN R8_DATAINI BETWEEN '" + xyDtIni + "' AND '" + xyDtFim + "'     AND R8_DATAFIM <> '' AND R8_DATAFIM >  '" + xyDtFim + "' AND DATEDIFF(dd,R8_DATAINI,R8_DATAFIM)        + 1 > 15                                      THEN 'Afastado: TP6'   ") + xSaltLin
		RW005 += Alltrim("                          ELSE ''                                                                                                                                                                                                                                         ") + xSaltLin
		RW005 += Alltrim("                        END                                                                                                                                                                                                                                               ") + xSaltLin
		RW005 += Alltrim("                   FROM SR8"+ aEmpr[i,1] +"0 SR8                                                                                                                                                                                                                                        ") + xSaltLin
		RW005 += Alltrim("                  WHERE R8_FILIAL = '"+ aEmpr[i,2] +"'                                                                                                                                                                                                                                  ") + xSaltLin
		RW005 += Alltrim("                    AND R8_MAT = RA_MAT                                                                                                                                                                                                                                   ") + xSaltLin
		RW005 += Alltrim("                    AND R8_DATAINI <= '" + xyDtFim + "'                                                                                                                                                                                                                   ") + xSaltLin
		RW005 += Alltrim("                    AND (R8_DATAFIM = '        ' OR R8_DATAFIM > '" + xyDtFim + "')                                                                                                                                                                                       ") + xSaltLin
		RW005 += Alltrim("                    AND R8_TIPO <> 'F'                                                                                                                                                                                                                                    ") + xSaltLin
		RW005 += Alltrim("                    AND R8_TIPOAFA <> '001'                                                                                                                                                                                                                               ") + xSaltLin
		RW005 += Alltrim("                    AND SR8.D_E_L_E_T_ = ' ') AFASTADO,                                                                                                                                                                                                                   ") + xSaltLin
		//****************
		RW005 += Alltrim("                CASE                                                                                         ") + xSaltLin
		RW005 += Alltrim("                  WHEN RA_DEFIFIS = '1' THEN 'SIM'                                                           ") + xSaltLin
		RW005 += Alltrim("                  ELSE 'NAO'                                                                                 ") + xSaltLin
		RW005 += Alltrim("                END PCD,                                                                                     ") + xSaltLin
		RW005 += Alltrim("                RA_YSEMAIL SUPERMAIL,                                                                        ") + xSaltLin
		RW005 += Alltrim("                '' MENOR,                                                                                    ") + xSaltLin
		RW005 += Alltrim("                ISNULL((SELECT RE_DATA                                                                       ") + xSaltLin
		RW005 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW005 += Alltrim("                         WHERE RE_EMPD = '"+ aEmpr[i,1] +"'                                                                ") + xSaltLin
		RW005 += Alltrim("                           AND RE_FILIALD = RA_FILIAL                                                        ") + xSaltLin
		RW005 += Alltrim("                           AND RE_MATD = RA_MAT                                                              ") + xSaltLin
		RW005 += Alltrim("                           AND RE_EMPD <> RE_EMPP                                                            ") + xSaltLin
		RW005 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), '        ') SAIDA,                                     ") + xSaltLin
		RW005 += Alltrim("                ISNULL((SELECT RE_DATA                                                                       ") + xSaltLin
		RW005 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW005 += Alltrim("                         WHERE RE_EMPP = '"+ aEmpr[i,1] +"'                                                                ") + xSaltLin
		RW005 += Alltrim("                           AND RE_FILIALP = RA_FILIAL                                                        ") + xSaltLin
		RW005 += Alltrim("                           AND RE_MATP = RA_MAT                                                              ") + xSaltLin
		RW005 += Alltrim("                           AND RE_EMPD <> RE_EMPP                                                            ") + xSaltLin
		RW005 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), '        ') ENTRA                                      ") + xSaltLin
		RW005 += Alltrim("           FROM SRA"+ aEmpr[i,1] +"0 SRA                                                                                   ") + xSaltLin
		RW005 += Alltrim("          WHERE RA_MAT NOT LIKE '200%'                                                                       ") + xSaltLin
		RW005 += Alltrim("            AND RA_ADMISSA <= " + dtos(MV_PAR01) + "                                                         ") + xSaltLin
		RW005 += Alltrim("            AND ( RA_DEMISSA > " + dtos(MV_PAR01) + "                                                        ") + xSaltLin
		RW005 += Alltrim("                   OR RA_DEMISSA = '        ' )                                                              ") + xSaltLin
		RW005 += Alltrim("            AND RA_CATFUNC IN('M','P')                                                                       ") + xSaltLin
		RW005 += Alltrim("            AND RA_CATEG <> '07'                                                                             ") + xSaltLin
		RW005 += Alltrim("            AND D_E_L_E_T_ = ' '                                                                             ") + xSaltLin
		
		If (i < len(aEmpr))
		
			RW005 += Alltrim("          UNION ALL                                                                                          ") + xSaltLin
		
		Endif
		
	Next i	
	
	RW005 += Alltrim("  ) AS QUADRO                                                                  							   ") + xSaltLin
	RW005 += Alltrim("  INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '  '                                                  ") + xSaltLin
	RW005 += Alltrim("                       AND CTH_CLVL = RA_CLVL                                                                ") + xSaltLin
	RW005 += Alltrim("                       AND CTH.D_E_L_E_T_ = ' '                                                              ") + xSaltLin
	RW005 += Alltrim("  WHERE (                                                                                                    ") + xSaltLin
	RW005 += Alltrim("           ( SAIDA = '        ' AND ENTRA = '        ')                                                      ") + xSaltLin
	RW005 += Alltrim("        OR ( SAIDA = '        ' AND ENTRA <= " + dtos(MV_PAR01) + ")                                         ") + xSaltLin
	RW005 += Alltrim("        OR ( SAIDA <> '        ' AND ENTRA <= " + dtos(MV_PAR01) + ")                                        ") + xSaltLin
	RW005 += Alltrim("        OR ( SAIDA > '        ' AND ENTRA = '        ')                                                      ") + xSaltLin
	RW005 += Alltrim("        )                                                                                                    ") + xSaltLin
	RW005 += Alltrim("  ORDER BY 2,3,15                                                                                               ") + xSaltLin
		               
	RWIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RW005),'RW06',.T.,.T.)


	//-------------------------------------------------------------
	// Estagiário
	//-------------------------------------------------------------
	RW006 := ""
	RW006 += Alltrim(" SELECT ' ' REFERENCIA,                                                                                      ") + xSaltLin
	RW006 += Alltrim("        QUADRO.*,                                                                                            ") + xSaltLin
	RW006 += Alltrim("        CTH_YQUADR QUADRO                                                                                    ") + xSaltLin
	RW006 += Alltrim("   FROM (                                                                                    				   ") + xSaltLin
	
	FOR i := 1 to len(aEmpr) 
	
		RW006 += Alltrim("         SELECT 'ESTAG' TIPO,                                                                                ") + xSaltLin
		RW006 += Alltrim("                '"+ aEmpr[i,3] +"' EMPR,                                                                     ") + xSaltLin
		RW006 += Alltrim("                ISNULL((SELECT TOP 1 RE_CLVLP                                                                ") + xSaltLin
		RW006 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW006 += Alltrim("                         WHERE RE_FILIALD = RE_FILIALP                                                       ") + xSaltLin
		RW006 += Alltrim("                           AND RE_EMPD = RE_EMPP                                                             ") + xSaltLin
		RW006 += Alltrim("                           AND RE_MATD = RE_MATP                                                             ") + xSaltLin
		RW006 += Alltrim("                           AND RE_FILIALP = '"+ aEmpr[i,2] +"'                                               ") + xSaltLin
		RW006 += Alltrim("                           AND RE_EMPP = '"+ aEmpr[i,1] +"'                                                  ") + xSaltLin
		RW006 += Alltrim("                           AND RE_MATP = RA_MAT                                                              ") + xSaltLin
		RW006 += Alltrim("                           AND RE_DATA IN(SELECT MAX(RE_DATA)                                                ") + xSaltLin
		RW006 += Alltrim("                                            FROM SRE010 SRE                                                  ") + xSaltLin
		RW006 += Alltrim("                                           WHERE RE_FILIALD = RE_FILIALP                                     ") + xSaltLin
		RW006 += Alltrim("                                             AND RE_EMPD = RE_EMPP                                           ") + xSaltLin
		RW006 += Alltrim("                                             AND RE_MATD = RE_MATP                                           ") + xSaltLin
		RW006 += Alltrim("                                             AND RE_FILIALP = '"+ aEmpr[i,2] +"'                                           ") + xSaltLin
		RW006 += Alltrim("                                             AND RE_EMPP = '"+ aEmpr[i,1] +"'                                              ") + xSaltLin
		RW006 += Alltrim("                                             AND RE_MATP = RA_MAT                                            ") + xSaltLin
		RW006 += Alltrim("                                             AND RE_DATA <= '" + dtos(MV_PAR01) + "'                         ") + xSaltLin
		RW006 += Alltrim("                                             AND SRE.D_E_L_E_T_ = ' ')                                       ") + xSaltLin
		RW006 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), RA_CLVL) RA_CLVL,                                      ") + xSaltLin
		RW006 += Alltrim("                RA_MAT,                                                                                      ") + xSaltLin
		RW006 += Alltrim("                RA_NOME,                                                                                     ") + xSaltLin
		RW006 += Alltrim("                RA_ADMISSA,                                                                                  ") + xSaltLin
		RW006 += Alltrim("                RA_DEMISSA,                                                                                  ") + xSaltLin
		RW006 += Alltrim("                '' AFASTADO,                                                                                 ") + xSaltLin
		RW006 += Alltrim("                CASE                                                                                         ") + xSaltLin
		RW006 += Alltrim("                  WHEN RA_DEFIFIS = '1' THEN 'SIM'                                                           ") + xSaltLin
		RW006 += Alltrim("                  ELSE 'NAO'                                                                                 ") + xSaltLin
		RW006 += Alltrim("                END PCD,                                                                                     ") + xSaltLin
		RW006 += Alltrim("                RA_YSEMAIL SUPERMAIL,                                                                        ") + xSaltLin
		RW006 += Alltrim("                '' MENOR,                                                                                    ") + xSaltLin
		RW006 += Alltrim("                ISNULL((SELECT RE_DATA                                                                       ") + xSaltLin
		RW006 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW006 += Alltrim("                         WHERE RE_EMPD = '"+ aEmpr[i,1] +"'                                                                ") + xSaltLin
		RW006 += Alltrim("                           AND RE_FILIALD = RA_FILIAL                                                        ") + xSaltLin
		RW006 += Alltrim("                           AND RE_MATD = RA_MAT                                                              ") + xSaltLin
		RW006 += Alltrim("                           AND RE_EMPD <> RE_EMPP                                                            ") + xSaltLin
		RW006 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), '        ') SAIDA,                                     ") + xSaltLin
		RW006 += Alltrim("                ISNULL((SELECT RE_DATA                                                                       ") + xSaltLin
		RW006 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW006 += Alltrim("                         WHERE RE_EMPP = '"+ aEmpr[i,1] +"'                                                                ") + xSaltLin
		RW006 += Alltrim("                           AND RE_FILIALP = RA_FILIAL                                                        ") + xSaltLin
		RW006 += Alltrim("                           AND RE_MATP = RA_MAT                                                              ") + xSaltLin
		RW006 += Alltrim("                           AND RE_EMPD <> RE_EMPP                                                            ") + xSaltLin
		RW006 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), '        ') ENTRA                                      ") + xSaltLin
		RW006 += Alltrim("           FROM SRA"+ aEmpr[i,1] +"0 SRA                                                                                   ") + xSaltLin
		RW006 += Alltrim("          WHERE RA_MAT NOT LIKE '200%'                                                                       ") + xSaltLin
		RW006 += Alltrim("            AND RA_ADMISSA <= " + dtos(MV_PAR01) + "                                                         ") + xSaltLin
		RW006 += Alltrim("            AND ( RA_DEMISSA > " + dtos(MV_PAR01) + "                                                        ") + xSaltLin
		RW006 += Alltrim("                   OR RA_DEMISSA = '        ' )                                                              ") + xSaltLin
		RW006 += Alltrim("            AND RA_CATFUNC = 'E'                                                                             ") + xSaltLin
		RW006 += Alltrim("            AND D_E_L_E_T_ = ' '                                                                             ") + xSaltLin
				
		If (i < len(aEmpr))
		
			RW006 += Alltrim("          UNION ALL                                                                                          ") + xSaltLin
		
		Endif
		
	Next i	
	
	RW006 += Alltrim("  ) AS QUADRO                                                                  							   ") + xSaltLin
	RW006 += Alltrim("  INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '  '                                                  ") + xSaltLin
	RW006 += Alltrim("                       AND CTH_CLVL = RA_CLVL                                                                ") + xSaltLin
	RW006 += Alltrim("                       AND CTH.D_E_L_E_T_ = ' '                                                              ") + xSaltLin
	RW006 += Alltrim("  WHERE (                                                                                                    ") + xSaltLin
	RW006 += Alltrim("           ( SAIDA = '        ' AND ENTRA = '        ')                                                      ") + xSaltLin
	RW006 += Alltrim("        OR ( SAIDA = '        ' AND ENTRA <= " + dtos(MV_PAR01) + ")                                         ") + xSaltLin
	RW006 += Alltrim("        OR ( SAIDA <> '        ' AND ENTRA <= " + dtos(MV_PAR01) + ")                                        ") + xSaltLin
	RW006 += Alltrim("        OR ( SAIDA > '        ' AND ENTRA = '        ')                                                      ") + xSaltLin
	RW006 += Alltrim("        )                                                                                                    ") + xSaltLin
	RW006 += Alltrim("  ORDER BY 2,3,15                                                                                        ") + xSaltLin
		               
	RWIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RW006),'RW07',.T.,.T.)

	//-------------------------------------------------------------
	// Menor Aprendiz
	//-------------------------------------------------------------
	RW007 := ""
	RW007 += Alltrim(" SELECT ' ' REFERENCIA,                                                                                      ") + xSaltLin
	RW007 += Alltrim("        QUADRO.*,                                                                                            ") + xSaltLin
	RW007 += Alltrim("        CTH_YQUADR QUADRO                                                                                    ") + xSaltLin
	RW007 += Alltrim("   FROM (                                                                                    				   ") + xSaltLin
	
	FOR i := 1 to len(aEmpr) 
	
		RW007 += Alltrim("         SELECT 'MENOR' TIPO,                                                                                ") + xSaltLin
		RW007 += Alltrim("                '"+ aEmpr[i,3] +"' EMPR,                                                                                  ") + xSaltLin
		RW007 += Alltrim("                ISNULL((SELECT TOP 1 RE_CLVLP                                                                ") + xSaltLin
		RW007 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW007 += Alltrim("                         WHERE RE_FILIALD = RE_FILIALP                                                       ") + xSaltLin
		RW007 += Alltrim("                           AND RE_EMPD = RE_EMPP                                                             ") + xSaltLin
		RW007 += Alltrim("                           AND RE_MATD = RE_MATP                                                             ") + xSaltLin
		RW007 += Alltrim("                           AND RE_FILIALP = '"+ aEmpr[i,2] +"'                                                             ") + xSaltLin
		RW007 += Alltrim("                           AND RE_EMPP = '"+ aEmpr[i,1] +"'                                                                ") + xSaltLin
		RW007 += Alltrim("                           AND RE_MATP = RA_MAT                                                              ") + xSaltLin
		RW007 += Alltrim("                           AND RE_DATA IN(SELECT MAX(RE_DATA)                                                ") + xSaltLin
		RW007 += Alltrim("                                            FROM SRE010 SRE                                                  ") + xSaltLin
		RW007 += Alltrim("                                           WHERE RE_FILIALD = RE_FILIALP                                     ") + xSaltLin
		RW007 += Alltrim("                                             AND RE_EMPD = RE_EMPP                                           ") + xSaltLin
		RW007 += Alltrim("                                             AND RE_MATD = RE_MATP                                           ") + xSaltLin
		RW007 += Alltrim("                                             AND RE_FILIALP = '"+ aEmpr[i,2] +"'                                           ") + xSaltLin
		RW007 += Alltrim("                                             AND RE_EMPP = '"+ aEmpr[i,1] +"'                                              ") + xSaltLin
		RW007 += Alltrim("                                             AND RE_MATP = RA_MAT                                            ") + xSaltLin
		RW007 += Alltrim("                                             AND RE_DATA <= '" + dtos(MV_PAR01) + "'                         ") + xSaltLin
		RW007 += Alltrim("                                             AND SRE.D_E_L_E_T_ = ' ')                                       ") + xSaltLin
		RW007 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), RA_CLVL) RA_CLVL,                                      ") + xSaltLin
		RW007 += Alltrim("                RA_MAT,                                                                                      ") + xSaltLin
		RW007 += Alltrim("                RA_NOME,                                                                                     ") + xSaltLin
		RW007 += Alltrim("                RA_ADMISSA,                                                                                  ") + xSaltLin
		RW007 += Alltrim("                RA_DEMISSA,                                                                                  ") + xSaltLin
		//****************
		RW007 += Alltrim("                (SELECT CASE                                                                                                                                                                                                                                              ") + xSaltLin
		RW007 += Alltrim("                          WHEN R8_DATAFIM = ''                                                                                                                                                                                                     THEN 'Afastado: TP1'   ") + xSaltLin
		RW007 += Alltrim("                          WHEN R8_DATAINI < '" + xyDtIni + "'                                 AND R8_DATAFIM <> '' AND R8_DATAFIM <= '" + xyDtFim + "' AND DATEDIFF(dd,'" + xyDtIni + "',R8_DATAFIM) + 1 > 15                                      THEN 'Afastado: TP2'   ") + xSaltLin
		RW007 += Alltrim("                          WHEN R8_DATAINI BETWEEN '" + xyDtIni + "' AND '" + xyDtFim + "'     AND R8_DATAFIM <> '' AND R8_DATAFIM <= '" + xyDtFim + "' AND DATEDIFF(dd,R8_DATAINI,R8_DATAFIM)        + 1 > 15                                      THEN 'Afastado: TP3'   ") + xSaltLin
		RW007 += Alltrim("                          WHEN R8_DATAINI BETWEEN '" + xyDtIni + "' AND '" + xyDtFim + "'     AND R8_DATAFIM <> '' AND R8_DATAFIM >  '" + xyDtFim + "' AND DATEDIFF(dd,R8_DATAINI,'" + xyDtFim + "') + 1 > 15                                      THEN 'Afastado: TP4'   ") + xSaltLin
		RW007 += Alltrim("                          WHEN R8_DATAINI < '" + xyDtIni + "'                                 AND R8_DATAFIM <> '' AND R8_DATAFIM >  '" + xyDtFim + "' AND DATEDIFF(dd,'"+xyDtIni+"','"+xyDtFim+ "') + 1 > 15                                      THEN 'Afastado: TP5'   ") + xSaltLin
		RW007 += Alltrim("                          WHEN R8_DATAINI BETWEEN '" + xyDtIni + "' AND '" + xyDtFim + "'     AND R8_DATAFIM <> '' AND R8_DATAFIM >  '" + xyDtFim + "' AND DATEDIFF(dd,R8_DATAINI,R8_DATAFIM)        + 1 > 15                                      THEN 'Afastado: TP6'   ") + xSaltLin
		RW007 += Alltrim("                          ELSE ''                                                                                                                                                                                                                                         ") + xSaltLin
		RW007 += Alltrim("                        END                                                                                                                                                                                                                                               ") + xSaltLin
		RW007 += Alltrim("                   FROM SR8"+ aEmpr[i,1] +"0 SR8                                                                                                                                                                                                                                        ") + xSaltLin
		RW007 += Alltrim("                  WHERE R8_FILIAL = '"+ aEmpr[i,2] +"'                                                                                                                                                                                                                                  ") + xSaltLin
		RW007 += Alltrim("                    AND R8_MAT = RA_MAT                                                                                                                                                                                                                                   ") + xSaltLin
		RW007 += Alltrim("                    AND R8_DATAINI <= '" + xyDtFim + "'                                                                                                                                                                                                                   ") + xSaltLin
		RW007 += Alltrim("                    AND (R8_DATAFIM = '        ' OR R8_DATAFIM > '" + xyDtFim + "')                                                                                                                                                                                       ") + xSaltLin
		RW007 += Alltrim("                    AND R8_TIPO <> 'F'                                                                                                                                                                                                                                    ") + xSaltLin
		RW007 += Alltrim("                    AND R8_TIPOAFA <> '001'                                                                                                                                                                                                                               ") + xSaltLin
		RW007 += Alltrim("                    AND SR8.D_E_L_E_T_ = ' ') AFASTADO,                                                                                                                                                                                                                   ") + xSaltLin
		//****************
		RW007 += Alltrim("                CASE                                                                                         ") + xSaltLin
		RW007 += Alltrim("                  WHEN RA_DEFIFIS = '1' THEN 'SIM'                                                           ") + xSaltLin
		RW007 += Alltrim("                  ELSE 'NAO'                                                                                 ") + xSaltLin
		RW007 += Alltrim("                END PCD,                                                                                     ") + xSaltLin
		RW007 += Alltrim("                RA_YSEMAIL SUPERMAIL,                                                                        ") + xSaltLin
		RW007 += Alltrim("                (SELECT RJ_YMNRAPZ                                                                           ") + xSaltLin
		RW007 += Alltrim("                   FROM SRJ010                                                                 ") + xSaltLin
		RW007 += Alltrim("                  WHERE RJ_FUNCAO = RA_CODFUNC                                                               ") + xSaltLin
		RW007 += Alltrim("                    AND D_E_L_E_T_ = ' ') MENOR,                                                             ") + xSaltLin
		RW007 += Alltrim("                ISNULL((SELECT RE_DATA                                                                       ") + xSaltLin
		RW007 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW007 += Alltrim("                         WHERE RE_EMPD = '"+ aEmpr[i,1] +"'                                                  ") + xSaltLin
		RW007 += Alltrim("                           AND RE_FILIALD = RA_FILIAL                                                        ") + xSaltLin
		RW007 += Alltrim("                           AND RE_MATD = RA_MAT                                                              ") + xSaltLin
		RW007 += Alltrim("                           AND RE_EMPD <> RE_EMPP                                                            ") + xSaltLin
		RW007 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), '        ') SAIDA,                                     ") + xSaltLin
		RW007 += Alltrim("                ISNULL((SELECT RE_DATA                                                                       ") + xSaltLin
		RW007 += Alltrim("                          FROM SRE010 SRE                                                                    ") + xSaltLin
		RW007 += Alltrim("                         WHERE RE_EMPP = '"+ aEmpr[i,1] +"'                                                  ") + xSaltLin
		RW007 += Alltrim("                           AND RE_FILIALP = RA_FILIAL                                                        ") + xSaltLin
		RW007 += Alltrim("                           AND RE_MATP = RA_MAT                                                              ") + xSaltLin
		RW007 += Alltrim("                           AND RE_EMPD <> RE_EMPP                                                            ") + xSaltLin
		RW007 += Alltrim("                           AND SRE.D_E_L_E_T_ = ' '), '        ') ENTRA                                      ") + xSaltLin
		RW007 += Alltrim("           FROM SRA"+ aEmpr[i,1] +"0 SRA                                                                     ") + xSaltLin
		RW007 += Alltrim("          WHERE RA_MAT NOT LIKE '200%'                                                                       ") + xSaltLin
		RW007 += Alltrim("            AND RA_ADMISSA <= " + dtos(MV_PAR01) + "                                                         ") + xSaltLin
		RW007 += Alltrim("            AND ( RA_DEMISSA > " + dtos(MV_PAR01) + "                                                        ") + xSaltLin
		RW007 += Alltrim("                   OR RA_DEMISSA = '        ' )                                                              ") + xSaltLin
		RW007 += Alltrim("            AND RA_CATFUNC IN('M','P')                                                                       ") + xSaltLin
		RW007 += Alltrim("            AND RA_CATEG = '07'                                                                              ") + xSaltLin
		RW007 += Alltrim("            AND D_E_L_E_T_ = ' '                                                                             ") + xSaltLin
		
		If (i < len(aEmpr))
		
			RW007 += Alltrim("          UNION ALL                                                                                          ") + xSaltLin
		
		Endif
		
	Next i	
	
	RW007 += Alltrim("  ) AS QUADRO                                                                  							   ") + xSaltLin
	RW007 += Alltrim("  INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '  '                                                  ") + xSaltLin
	RW007 += Alltrim("                       AND CTH_CLVL = RA_CLVL                                                                ") + xSaltLin
	RW007 += Alltrim("                       AND CTH.D_E_L_E_T_ = ' '                                                              ") + xSaltLin
	RW007 += Alltrim("  WHERE (                                                                                                    ") + xSaltLin
	RW007 += Alltrim("           ( SAIDA = '        ' AND ENTRA = '        ')                                                      ") + xSaltLin
	RW007 += Alltrim("        OR ( SAIDA = '        ' AND ENTRA <= " + dtos(MV_PAR01) + ")                                         ") + xSaltLin
	RW007 += Alltrim("        OR ( SAIDA <> '        ' AND ENTRA <= " + dtos(MV_PAR01) + ")                                        ") + xSaltLin
	RW007 += Alltrim("        OR ( SAIDA > '        ' AND ENTRA = '        ')                                                      ") + xSaltLin
	RW007 += Alltrim("        )                                                                                                    ") + xSaltLin
	RW007 += Alltrim("  ORDER BY 2,3,15                                                                                        ") + xSaltLin
		               
	RWIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RW007),'RW08',.T.,.T.)

	ProcRegua(RecCount())
	
	aDados2 := {}
	aQuery  := {}
		
	aAdd(aQuery,{"RW06","RW07","RW08"})

	FOR i := 1 to len(aQuery[1]) 
		
		cAliasTab := aQuery[1,i]
		dbSelectArea(cAliasTab)
		(cAliasTab)->(dbGoTop())
		
		While !(cAliasTab)->(Eof())
	
			IncProc()
			
			gtMenor := ""
			
			If (cAliasTab)->MENOR = "T"
				gtMenor := "Técnico"
			ElseIf (cAliasTab)->MENOR = "S"
				gtMenor := "Superior"
			ElseIf (cAliasTab)->MENOR = "M"
				gtMenor := "Menor"
			ElseIf (cAliasTab)->MENOR = "C"
				gtMenor := "Cota"
			EndIf
			
			aAdd(aDados2, { dtoc(MV_PAR01)                                             		  ,;
			Alltrim((cAliasTab)->TIPO)                                                        ,;
			Alltrim((cAliasTab)->EMPR)                                                        ,;
			Alltrim((cAliasTab)->RA_CLVL)                                                     ,;
			Alltrim("'"+(cAliasTab)->RA_MAT)                                                  ,;
			Alltrim((cAliasTab)->RA_NOME)                                                     ,;
			IIF(!Empty((cAliasTab)->RA_ADMISSA), dtoc(stod((cAliasTab)->RA_ADMISSA)), "")     ,;
			IIF(!Empty((cAliasTab)->RA_DEMISSA), dtoc(stod((cAliasTab)->RA_DEMISSA)), "")     ,;
			(cAliasTab)->AFASTADO                                                             ,;
			Alltrim((cAliasTab)->PCD)                                                         ,;
			lower(Alltrim((cAliasTab)->SUPERMAIL))                                            ,;
			gtMenor                                                                           ,;
			IIF(!Empty((cAliasTab)->SAIDA), dtoc(stod((cAliasTab)->SAIDA)), "")               ,;
			IIF(!Empty((cAliasTab)->ENTRA), dtoc(stod((cAliasTab)->ENTRA)), "")               ,;
			Alltrim((cAliasTab)->QUADRO)                                                      })
	
			(cAliasTab)->(dbSkip())
	
		End
		
		IF i == len(aQuery[1])
			
			aStru1 := (cAliasTab)->(dbStruct())
		
		ENDIF	
	
		(cAliasTab)->(dbCloseArea())
		
	Next i
	
	U_BIAxExcel(aDados2, aStru1, "BIA726"+strzero(seconds()%3500,5) )

Return

Static Function retemp(kj_Empr)

	Local akEmp := {}
	Local gbAreAtu := GetArea()
	Local _aSm0	:=	{}
	Local _nI

	If ( select("SM0") == 0 )
		OpenSM0()
	EndIf

	_aSm0	:=	FWLoadSM0()

	For _nI	:=	1 to Len(_aSM0)

		If !Empty(_aSM0[_nI,SM0_EMPRESA])
			If _aSM0[_nI,SM0_EMPRESA] $ kj_Empr
				If _aSM0[_nI,SM0_FILIAL] == '01' .or. _aSM0[_nI,SM0_EMPRESA] == '06'
					aadd(akEmp ,{ _aSM0[_nI,SM0_EMPRESA], _aSM0[_nI,SM0_FILIAL],_aSM0[_nI,SM0_NOME] })
				EndIf
			EndIf
		Else
			If _aSM0[_nI,SM0_GRPEMP] $ kj_Empr
				If _aSM0[_nI,SM0_FILIAL] == '01' .or. _aSM0[_nI,SM0_GRPEMP] == '06'
					aadd(akEmp ,{ _aSM0[_nI,SM0_GRPEMP], _aSM0[_nI,SM0_FILIAL],_aSM0[_nI,SM0_NOME] })
				EndIf
			EndIf
		EndIf
	Next

	SM0->(DBCLOSEAREA())
	RestArea( gbAreAtu )

Return akEmp