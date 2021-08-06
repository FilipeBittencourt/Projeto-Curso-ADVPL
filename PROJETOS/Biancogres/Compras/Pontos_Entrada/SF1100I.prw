#include "rwmake.ch"
#include "topconn.ch"

User Function SF1100I()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := SF1100I
Empresa   := Biancogres Cerâmica S/A
Data      := 11/10/2011
Uso       := Compras
Aplicação := PONTO DE ENTRADA executado após a gravação do arquivo SF1
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Local fpArea := GetArea()

// Processo de Devolução. Incluído por Marcos Alberto em 11/10/11 a pedido da Diretoria.
// Rotinas envolvidas: BIA267, SF1100I, SF1100E, SD1100I, MT100LOK, MT100GRV
If SF1->F1_TIPO == "D"
	A0002 := " UPDATE "+ RetSqlName("Z26")
	A0002 += "    SET Z26_ITEMNF = 'XX', Z26_OBS = '"+SF1->F1_DOC+SF1->F1_SERIE+"'
	A0002 += "  WHERE Z26_FILIAL = '"+xFilial("Z26")+"'
	A0002 += "    AND Z26_NFISC + Z26_SERIE IN
	A0002 += "        (SELECT D1_NFORI + D1_SERIORI
	A0002 += "           FROM "+ RetSqlName("SD1")
	A0002 += "          WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	A0002 += "            AND D1_DOC = '"+SF1->F1_DOC+"'
	A0002 += "            AND D1_SERIE = '"+SF1->F1_SERIE+"'
	A0002 += "            AND D1_FORNECE = '"+SF1->F1_FORNECE+"'
	A0002 += "            AND D1_LOJA = '"+SF1->F1_LOJA+"'
	A0002 += "            AND D1_EMISSAO = '"+dtos(SF1->F1_EMISSAO)+"'
	A0002 += "            AND D_E_L_E_T_ = ' '
	A0002 += "          GROUP BY D1_NFORI + D1_SERIORI)
	A0002 += "    AND Z26_NUMPRC = '"+xd_NumPrc+"'
	A0002 += "    AND Z26_ITEMNF = '  '
	A0002 += "    AND D_E_L_E_T_ = ' '
	TCSQLEXEC(A0002)
EndIf

// Rotina Incluída em 30/04/12 para atender a importações realizadas por meio da rotina FAXML02 e a partir de 08/05/12 BIA296
// Incluída funcionalidade em 15/05/12 por Marcos Alberto Soprani atendendo ao projeto XML
If Alltrim(SF1->F1_ESPECIE) $ "SPED/CTE"
	If !Empty(SF1->F1_CHVNFE)
		EY001 := " SELECT COUNT(*) CONTAD
		EY001 += "   FROM "+ RetSqlName("SDS")
		EY001 += "  WHERE DS_FILIAL = '"+xFilial("SDS")+"'
		EY001 += "    AND DS_CHAVENF = '"+SF1->F1_CHVNFE+"'
		EY001 += "    AND D_E_L_E_T_ = ' '
		TcQuery EY001 ALIAS "EY01" NEW
		dbSelectArea("EY01")
		dbGoTop()
		If EY01->CONTAD >= 1
			R0001 := " UPDATE "+ RetSqlName("SDS")
			R0001 += "    SET DS_STATUS = 'P',
			R0001 += "        DS_USERPRE = '" + __cUserID +"',
			R0001 += "        DS_DATAPRE = '" + dtos(dDataBase) +"',
			R0001 += "        DS_HORAPRE = '" + Substr(Time(),1,5) +"'
			R0001 += "  WHERE DS_FILIAL = '"+xFilial("SDS")+"'
			R0001 += "    AND DS_CHAVENF = '"+SF1->F1_CHVNFE+"'
			R0001 += "    AND D_E_L_E_T_ = ' '
			TCSQLEXEC(R0001)
			dbSelectArea("SF1")
			RecLock("SF1",.F.)
			SF1->F1_YIMPXML := "S"
			MsunLock()
		EndIf
		EY01->(dbCloseArea())
	EndIf
EndIf

// Implementado em 16/05/12 por Marcos Alberto Soprani para atender ao controle de qual rotina e qual usuário está efetuando a inclusão da nota fiscal no sistema.
dbSelectArea("SF1")
RecLock("SF1",.F.)
SF1->F1_YORILAN := Upper(Alltrim(FunName()))
SF1->F1_YUSRLAN := __cUserID
MsunLock()

//OS 3780-15

If SF1->F1_FORNECE == "003721" .and. SF1->F1_TIPO == "N" //F1_TIPO = "N" : TIPO NORMAL, PODERIA SER "D", DE DEVOLUÇÃO, POR EXEMPLO
	WF_ENTRADANF_VITCER()
EndIf

// Tratamento implementado por Marcos Alberto Soprani em 19/01/15 para adequar o Totvs Colaboração à sistemática de leitura de XML (BIA296)
If UPPER(Alltrim(FunName())) <> "MATA116"  .And. !IsInCallStack("U_PNFM0003") .and. !FwIsInCallStack('MATA116')

	If l103Class .Or. UPPER(Alltrim(FunName())) == "U_GATI001" 
		
		If __Distri
			
			HK007 := " SELECT D1_COD, D1_NUMSEQ, D1_QUANT
			HK007 += "   FROM " + RetSqlName("SD1")
			HK007 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
			HK007 += "    AND D1_FORNECE = '"+SF1->F1_FORNECE+"'
			HK007 += "    AND D1_LOJA = '"+SF1->F1_LOJA+"'
			HK007 += "    AND D1_DOC = '"+SF1->F1_DOC+"'
			HK007 += "    AND D1_SERIE = '"+SF1->F1_SERIE+"'
			HK007 += "    AND D_E_L_E_T_ = ' '
			cIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,HK007),'HK07',.T.,.T.)
			dbSelectArea("HK07")
			dbGoTop()
			While !HK07->(Eof())
				
				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+HK07->D1_COD))
				If SB1->B1_RASTRO == "L"
					
					aCabSDA    := {}
					aItSDB     := {}
					_aItensSDB := {}
					
					//Cabeçalho com a informação do item e NumSeq que sera endereçado.
					aCabSDA := {{"DA_PRODUTO" ,HK07->D1_COD             ,Nil},;
					{            "DA_NUMSEQ"  ,HK07->D1_NUMSEQ          ,Nil} }
					
					//Dados do item que será endereçado
					aItSDB := {{"DB_ITEM"	  ,"0001"	                ,Nil},;
					{           "DB_ESTORNO"  ," "	                    ,Nil},;
					{           "DB_LOCALIZ"  ,__LocDis                 ,Nil},;
					{           "DB_DATA"	  ,dDataBase                ,Nil},;
					{           "DB_QUANT"    ,HK07->D1_QUANT           ,Nil} }
					aadd(_aItensSDB,aitSDB)
					
					LMSERROAUTO := .F.
					lMsHelpAuto := .T.
					lAutoErrNoFile := .T.
					
					//Executa o endereçamento do item
					MATA265( aCabSDA, _aItensSDB, 3)
					If LMSERROAUTO
						MsgBox("Distribuição com erro de digitação. Entre em contato com o setor de TI!","STOP")
					EndIf
				EndIf
				
				HK07->(dbSkip())
				
			End
			
			Ferase(cIndex+OrdBagExt())
			HK07->(dbCloseArea())
			
		EndIf
		
	EndIf

EndIf

RestArea(fpArea)

Return 

Static Function WF_ENTRADANF_VITCER()
	Local pw_ImpCabec := .F.
	
	EY001 := "SELECT SD1.D1_DOC AS NF "
	EY001 += "	, SD1.D1_SERIE AS SERIE "
	EY001 += "	, SD1.D1_EMISSAO AS DATA_E "
	EY001 += "	, SD1.D1_DTDIGIT AS DATA_ENT "
	EY001 += "	, SB1.B1_COD AS COD_PROD "
	EY001 += "	, SB1.B1_DESC AS DESC_PROD "
	EY001 += "	, SD1.D1_LOTECTL AS LOTE "
	EY001 += "	, SD1.D1_QUANT AS QUANT "
	EY001 += "	, ZZ9.ZZ9_RESTRI AS REST "
	EY001 += "	, SD1.D1_YOP AS OP "
	EY001 += "FROM " + RetSqlName("SD1") + " SD1 "
	EY001 += "	INNER JOIN " + RetSqlName("SB1") + " SB1 ON SD1.D1_COD=SB1.B1_COD "
	EY001 += "		AND SB1.B1_TIPO='PA' "
	EY001 += "		AND SB1.B1_FILIAL='" + xFilial("SB1") + "' "
	EY001 += "		AND SB1.D_E_L_E_T_='' "
	EY001 += "	INNER JOIN " + RetSqlName("SF4") + " SF4 ON SD1.D1_TES=SF4.F4_CODIGO "
	EY001 += "		AND SF4.F4_PODER3='N' "
	EY001 += "		AND SF4.F4_FILIAL='" + xFilial("SF4") + "' "
	EY001 += "		AND SF4.D_E_L_E_T_='' "
	EY001 += "	LEFT JOIN " + RetSqlName("ZZ9") + " ZZ9 ON SD1.D1_COD=ZZ9.ZZ9_PRODUT "
	EY001 += "		AND SD1.D1_LOTECTL=ZZ9.ZZ9_LOTE "
	EY001 += "		AND ZZ9.ZZ9_FILIAL='" + xFilial("ZZ9") + "' "
	EY001 += "		AND ZZ9.D_E_L_E_T_='' "
	EY001 += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
	EY001 += "	AND SD1.D1_DOC = '"+SF1->F1_DOC+"' "
	EY001 += "	AND SD1.D1_SERIE = '"+SF1->F1_SERIE+"' "
	EY001 += "	AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' "
	EY001 += "	AND SD1.D1_LOJA = '"+SF1->F1_LOJA+"' "
	EY001 += "	AND SD1.D1_EMISSAO = '"+dtos(SF1->F1_EMISSAO)+"' "
	EY001 += "	AND SD1.D1_FORNECE='003721' "
	EY001 += "	AND SD1.D_E_L_E_T_ = ' ' "
	
	If chkfile("cRelEntNF")
		DbSelectArea("cRelEntNF")
		DbCloseArea()
	EndIf
	TcQuery EY001 New Alias "cRelEntNF"
	DbSelectArea("cRelEntNF")
	DbGoTop()
	
	While !Eof()
		
		If !pw_ImpCabec
			pw_ImpCabec := .T.
			
			cHtmEntNF := '<html xmlns="http://www.w3.org/1999/xhtml"> '
			cHtmEntNF += '<head> '
			cHtmEntNF += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
			cHtmEntNF += '<!-- TemplateBeginEditable name="doctitle" --> '
			cHtmEntNF += '<title>ENTRADA DE NF RETORNO VITCER, ATUALIZA ESTOQUE PA</title> '
			cHtmEntNF += '<style type="text/css"> '
			cHtmEntNF += '<!-- '
			cHtmEntNF += '.style1 { '
			cHtmEntNF += '	font-family: Geneva, Arial, Helvetica, sans-serif; '
			cHtmEntNF += '	font-weight: bold; '
			cHtmEntNF += '	color: #000066; '
			cHtmEntNF += '} '
			cHtmEntNF += '.style2 {color: #000066} '
			cHtmEntNF += '--> '
			cHtmEntNF += '</style> '
			cHtmEntNF += '</head> '
			cHtmEntNF += '<body> '
			cHtmEntNF += '<h3 class="style1">ENTRADA DE NF RETORNO VITCER, ATUALIZA ESTOQUE PA</h3> '
			cHtmEntNF += '<table width="1000" border="1" cellspacing="1" bordercolor="#666666"> '
			cHtmEntNF += '    <tr> '
			cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">NF</span></div></td> '
			cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">SÉRIE</span></div></td> '
			cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">EMISSÃO</span></div></td> '
			cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">ENTRADA</span></div></td> '
			cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">CÓDIGO</span></div></td> '
			cHtmEntNF += '        <td width="500" bgcolor="#99CCFF"><div align="left"><span class="style2">PRODUTO</span></div></td> '
			cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">LOTE</span></div></td> '
			cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">QUANT.</span></div></td> '
			cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">REST.</span></div></td> '
			//cHtmEntNF += '        <td width="30" bgcolor="#99CCFF"><div align="left"><span class="style2">OP</span></div></td> '
			cHtmEntNF += '    </tr> '
		EndIf
		
		cHtmEntNF += '    <tr> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + Alltrim(cRelEntNF->NF) + '</span></div></td> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + Alltrim(cRelEntNF->SERIE) + '</span></div></td> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + dtoc(stod(cRelEntNF->DATA_E)) + '</span></div></td> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + dtoc(stod(cRelEntNF->DATA_ENT)) + '</span></div></td> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + Alltrim(cRelEntNF->COD_PROD) + '</span></div></td> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + Alltrim(cRelEntNF->DESC_PROD) + '</span></div></td> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + Alltrim(cRelEntNF->LOTE) + '</span></div></td> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + Transform(cRelEntNF->QUANT, "@E 999,999.99") + '</span></div></td> '
		cHtmEntNF += '        <td><div align="left"><span class="style2">' + Alltrim(cRelEntNF->REST) + '</span></div></td> '
		//cHtmEntNF += '        <td><div align="left"><span class="style2">' + Alltrim(cRelEntNF->OP) + '</span></div></td> '
		cHtmEntNF += '    </tr> '
		
		
		dbSelectArea("cRelEntNF")
		dbSkip()
	End
	
	DbCloseArea()
	
	If pw_ImpCabec == .T.
		cHtmEntNF += ' </table> '
		cHtmEntNF += ' <p>&nbsp;</p> '
		cHtmEntNF += ' <p>&nbsp;</p> '
		cHtmEntNF += ' <p>by Protheus (SF1100I)</p> '
		cHtmEntNF += ' </body> '
		cHtmEntNF += ' </html> '

		df_Dest := "raul.grossi@biancogres.com.br"
		xCLVL   := ""
		df_Dest := U_EmailWF('SF1100I_ENT', cEmpAnt , xCLVL )
		
		df_Assu := "Entrada de NF retorno Vitcer, atualiza estoque PA."
		df_Erro := "Entrada de NF retorno Vitcer, atualiza estoque PA. Favor verificar!!!"
		U_BIAEnvMail(, df_Dest, df_Assu, cHtmEntNF, df_Erro)
	EndIf
	
	ConOut("HORA: "+TIME()+" - Finalizando Processo SF1100I - Entrada de NF retorno Vitcer ")
	
			
Return
