#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE _NBIANCOGRES 	1
#DEFINE _NINCESA 		2
#DEFINE _NBELLACASA 	3
#DEFINE _MUNDIALLI		4
#DEFINE _PEGASUS		5
#DEFINE _VINILICO		6

/*
#############################################################################################################
# PROGRAMA...: BIA583																						#
# AUTOR......: Luana Marin Ribeiro																			#
# DATA.......: 12/04/2016																					#
# DESCRICAO..: Relatório de preço de produto para representantes											#
#############################################################################################################
*/

User Function BIA583()
	Local oReport
	Local valCliente
	Local cLoad				:= "BIA583" + cEmpAnt
	Local cFileName			:= RetCodUsr() +"_"+ cLoad
	
	
	Private cTitRel := "TABELA DE PREÇOS - "
	Private codTab
	Private fatFin 
	Private fatMult
	Private _cCliente
	Private	_cVendedor
	Private	_lPaletizado
	Private	_nPICMS
	Private	_nPPIS
	Private	_nPCOF
	Private	_nAComis
	Private aPergs := {}
	Private MV_PAR01 := Space(6)
	Private MV_PAR02 := Space(2)
	Private MV_PAR03 := Space(3)
	Private MV_PAR04 := ""
	Private nMarca	 := 0

	If cEmpAnt <> "01" .And. cEmpAnt <> "05" .And. cEmpAnt <> "13"
		Alert("Relatório apenas para as empresas Biancogrês, Incesa e Mundi.")
		Return ()
	EndIf
	
	
	aAdd( aPergs ,{1,"Cliente"				,MV_PAR01 ,""  ,"", 'SA1BIA','.T.',50,.F.})	
	aAdd( aPergs ,{1,"Loja"					,MV_PAR02 ,""  ,"", ''		,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Cond. Pagto."    		,MV_PAR03 ,""  ,"", 'SE4'	,'.T.',50,.F.})	
	aAdd( aPergs ,{2,"Marca"  				,MV_PAR04 ,{"1-Biancogres","2-Incesa","3-Bellacasa","4-Mundialli","5-Pegasus","6-Vinilico"},50,'.T.',.F.})
	
	//cPerg := "BIA583"
	//fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	//ValPergAco() 
		
	//If !Pergunte(cPerg,.T.)
	//	Return
	//EndIf
	
	ParamBox(aPergs ,"Parametros",,,,,,,,cLoad,.T.,.T.)
	MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
	MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
	MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
	nMarca 	 := Val(ParamLoad(cFileName,,4,MV_PAR04))
	MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)

		
	IF !Empty(Trim(cRepAtu))
		valCLiente = VerificaRep()
		
		If valCliente == .F.	
			While valCliente == .F.
				Alert("Cliente inválido!")
			
				//If !Pergunte(cPerg,.T.)
				//	ReturnRANIS
				//EndIf
				
				valCLiente = VerificaRep()
			EndDo
		EndIf
	EndIf
	
	Parametros()

	oReport := ReportDef()
	oReport:PrintDialog()
Return ()

Static Function VerificaRep()

Local aArea	:= GetArea()
Local lret	:= .F.

DbSelectArea("SA1")                 
DbSetOrder(1)

If DbSeek(xFilial("SA1") + MV_PAR01 + MV_PAR02)
	Do Case
	   	Case nMarca == _NBIANCOGRES
	    	If SA1->A1_VEND == CREPATU .or. SA1->A1_YVENDB2 == CREPATU .or. SA1->A1_YVENDB3 == CREPATU
				lret := .T.
			EndIf
	   	Case nMarca == _NINCESA
			If SA1->A1_YVENDI == CREPATU .or. SA1->A1_YVENDI2 == CREPATU .or. SA1->A1_YVENDI3 == CREPATU
				lret := .T.
			EndIf	   	
		Case nMarca == _NBELLACASA
			If SA1->A1_YVENBE1 == CREPATU .or. SA1->A1_YVENBE2 == CREPATU .or. SA1->A1_YVENBE3 == CREPATU
				lret := .T.
			EndIf		
		Case nMarca == _MUNDIALLI
			If SA1->A1_YVENML1 == CREPATU .or. SA1->A1_YVENML2 == CREPATU .or. SA1->A1_YVENML3 == CREPATU
				lret := .T.
			EndIf	    
	    Case nMarca == _PEGASUS
	    	If SA1->A1_YVENPEG == CREPATU
				lret := .T.
			EndIf    
	    Case nMarca == _VINILICO
	    	If SA1->A1_YVENVI1 == CREPATU
				lret := .T.
			EndIf   
	EndCase
EndIf

Return(lret)

Static Function Parametros()

Local Enter := chr(13) + Chr(10)
Local tbB583 := GetNextAlias()

CSQL := "SELECT X5_DESCRI, DA0_DESCRI" + Enter
CSQL += "FROM " + RetSqlName("SX5") + Enter
CSQL += "	INNER JOIN " + RetSqlName("DA0") + Enter
CSQL += "		ON X5_DESCRI = DA0_CODTAB" + Enter
CSQL += "			AND " + RetSqlName("DA0") + ".D_E_L_E_T_=''" + Enter
CSQL += "WHERE	" + Enter
Do Case
   	Case nMarca == _NBIANCOGRES
      CSQL += " X5_TABELA = 'ZF' And X5_CHAVE = '1P' " + Enter
   	Case nMarca == _NINCESA
      CSQL += " X5_TABELA = 'ZF' And X5_CHAVE = '2P' " + Enter
	Case nMarca == _NBELLACASA
      CSQL += " X5_TABELA = 'ZF' And X5_CHAVE = '3P' " + Enter
	Case nMarca == _MUNDIALLI
      CSQL += " X5_TABELA = 'ZF' And X5_CHAVE = '4P' " + Enter
    Case nMarca == _PEGASUS
      CSQL += " X5_TABELA = 'ZF' And X5_CHAVE = '5P' " + Enter                        
    Case nMarca == _VINILICO
      //CSQL += " X5_TABELA = 'ZF' And X5_CHAVE = 'XX' " + Enter   
EndCase
CSQL += "	AND " + RetSqlName("SX5") + ".D_E_L_E_T_ = ''" + Enter	
TCQUERY CSQL ALIAS "QRY_SX5" NEW 
                          
codTab	:= QRY_SX5->X5_DESCRI
cTitRel += QRY_SX5->DA0_DESCRI

QRY_SX5->(DbCloseArea())

//fator financeiro
CSQL := "SELECT SE4.E4_DESCRI" + Enter
CSQL += "	, SE4.E4_YMAXDES" + Enter
CSQL += "FROM " + RetSqlName("SE4") + " SE4 WITH(NOLOCK)" + Enter
CSQL += "WHERE SE4.E4_FILIAL='" + xFilial('SE4') + "'" + Enter
CSQL += "	AND SE4.E4_CODIGO='" + MV_PAR03 + "'" + Enter
CSQL += "	AND SE4.D_E_L_E_T_=''" + Enter
TCQUERY CSQL ALIAS "QRY_SE4" NEW 
                          
fatFin := QRY_SE4->E4_YMAXDES
cTitRel += Enter + " - " + MV_PAR01 + " - " + QRY_SE4->E4_DESCRI

QRY_SE4->(DbCloseArea())

Do Case
   	Case nMarca == _NBIANCOGRES
		cSQL := "SELECT SA1.A1_VEND AS VEND" + Enter
		cSQL += "	, SA1.A1_COMIS AS COMI" + Enter
   	Case nMarca == _NINCESA
		cSQL := "SELECT SA1.A1_YVENDI AS VEND" + Enter
		cSQL += "	, SA1.A1_YCOMISI AS COMI" + Enter
	Case nMarca == _NBELLACASA
		cSQL := "SELECT SA1.A1_YVENBE1 AS VEND" + Enter
		cSQL += "	, SA1.A1_YCOMBE1 AS COMI" + Enter
	Case nMarca == _MUNDIALLI
		cSQL := "SELECT SA1.A1_YVENML1 AS VEND" + Enter
		cSQL += "	, SA1.A1_YCOMML1 AS COMI" + Enter
    Case nMarca == _PEGASUS
		cSQL := "SELECT SA1.A1_YVENPEG AS VEND" + Enter
		cSQL += "	, SA1.A1_YCOMPEG AS COMI" + Enter                 
    Case nMarca == _VINILICO
		cSQL := "SELECT SA1.A1_YVENVI1 AS VEND" + Enter
		cSQL += "	, SA1.A1_YCOMVI1 AS COMI" + Enter  		  
EndCase	
cSQL += "	,Z65.Z65_ICMSOR AS ICMSOR" + Enter
cSQL += "	,Z65.Z65_FATMUL AS FAT_MULT" + Enter
cSQL += "FROM " + RetSqlName("Z65") + " Z65 WITH(NOLOCK)" + Enter
cSQL += "	INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK)" + Enter
cSQL += "		ON Z65.Z65_UF = (CASE SA1.A1_EST WHEN 'ES' THEN SA1.A1_EST ELSE '' END)" + Enter
cSQL += "			AND Z65.Z65_ZONAFR = SA1.A1_SUFRAMA" + Enter
cSQL += "			AND SA1.A1_FILIAL='" + xFilial('SA1') + "'" + Enter
cSQL += "			AND SA1.A1_COD='" + MV_PAR01 + "'" + Enter
cSQL += "			AND SA1.D_E_L_E_T_=''" + Enter
cSQL += "WHERE Z65.Z65_GRTRIB = '001'" + Enter
cSQL += "	AND Z65.Z65_TIPO = 'R'" + Enter
cSQL += "	AND Z65.Z65_CONTRI = '1'" + Enter
cSQL += "	AND Z65.Z65_ICMSOR <> '99'" + Enter
cSQL += "	AND Z65.Z65_TIPVEN = ''" + Enter
cSQL += "	AND Z65.D_E_L_E_T_ = ''" + Enter
TcQuery cSQL New Alias (tbB583)
    
If !(tbB583)->(Eof())
	fatMult := (tbB583)->FAT_MULT
	_cCliente := MV_PAR01 + MV_PAR02
	_cVendedor := (tbB583)->VEND
	_lPaletizado := .T.
	_nPICMS := (tbB583)->ICMSOR
	_nPPIS := 1.65
	_nPCOF := 7.6
	_nAComis := (tbB583)->COMI	
EndIf

(tbB583)->(dbCloseArea())

Return ()

Static Function ReportDef()
Local oReport
Local oSecForm
Local oSecProd
Local tbBia583 := GetNextAlias()
Local Enter := chr(13) + Chr(10)
	
	oReport := TReport():New("BIA583", cTitRel, {|| pergunte(fPerg,.F.) }, {|oReport| PrintReport(oReport, tbBia583)}, cTitRel)	
	oReport:SetCustomText({||u_CriaCab(cTitRel)}) 
	oReport:lXlsHeader := .T.
	oReport:ShowFooter()
	//oReport:SetPageFooter(5,oReport:PrtRight(oReport:Page()))
	If cRepAtu <> ""
		oReport:nDevice := 6
	EndIf
	//oReport:SetLandscape()
	//oReport:DisableOrientation()
		
	oSecForm := TRSection():New(oReport, "Formato", tbBia583)
	oSecForm:SetLineStyle(.T.)
	TRCell():New(oSecForm, "DESC_FORM", tbBia583, "Formato","@!",30)
	
	oSecProd := TRSection():New(oSecForm, "Produto", tbBia583)	
	TRCell():New(oSecProd, "COD_PROD", tbBia583, "CÓDIGO" + Enter + "PRODUTO","@!",9)	
	TRCell():New(oSecProd, "DESC_LIN", tbBia583, Enter + "PRODUTO","@!",30)
	TRCell():New(oSecProd, "PRC_CLAS1", tbBia583, "R$/M²   (" + Enter + "'A'","@E 999.99",09,,,"CENTER",,"CENTER",,0)
	TRCell():New(oSecProd, "PRC_CLAS2", tbBia583, cValToChar(_nPICMS) + "% ICMS)" + Enter + "'B'","@E 999.99",09,,,"CENTER",,"CENTER",,0)	
	TRCell():New(oSecProd, "LOC_USO", tbBia583, "LOCAL" + Enter + "DE USO","@!",07,,,"CENTER",,"CENTER")	
	TRCell():New(oSecProd, "CLAS_AD", tbBia583, "CLASSE" + Enter + "AD","@!",07,,,"CENTER",,"CENTER")	
	TRCell():New(oSecProd, "VAR_TON", tbBia583, "VARIAÇÃO" + Enter + "TON/DES","@!",08,,,"CENTER",,"CENTER")
	TRCell():New(oSecProd, "JUNTA", tbBia583, Enter + "JUNTA","",06,,,"CENTER",,"CENTER")
	TRCell():New(oSecProd, "PALE_M2", tbBia583, "_____PAL" + Enter + "M²","@E 999.99",06,,,"CENTER",,"CENTER",,0)
	TRCell():New(oSecProd, "PALE_CAIX", tbBia583, "ETE_____" + Enter + "    CX","@E 999",10,,,"CENTER",,"LEFT",,0)
	TRCell():New(oSecProd, "CAIX_M2", tbBia583, "______C" + Enter + "M²","@E 999.99",07,,,"CENTER",,"CENTER",,0)
	TRCell():New(oSecProd, "CAIX_PC", tbBia583, "AIX" + Enter + "PÇ","@E 999",03,,,"RIGHT",,"CENTER",,0)
	TRCell():New(oSecProd, "CAIX_KG", tbBia583, "A______" + Enter + "KG","@E 999.99",06,,,"RIGHT",,"CENTER",,0)
	TRCell():New(oSecProd, "M2_KG", tbBia583, "M²" + Enter + "KG","@E 999.99",08,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecProd, "COD_BAR", tbBia583, "CÓDIGO" + Enter + "BARRAS","@!",14,,,"RIGHT",,"RIGHT")
Return(oReport)

User Function CriaCab(_cTitRel)

Local _linha0,_linha1
Local _ArrayCab

_linha0 := " "
_linha1 := space(500) + _cTitRel

_ArrayCab := {_linha0,_linha1}

return _ArrayCab

Static Function PrintReport(oReport, tbBia583)
Local oSecForm := oReport:Section(1)
Local oSecProd := oReport:Section(1):Section(1)
Local cSQL := ""
Local Enter := chr(13) + Chr(10) 
Local cSpName
Local Formato := ""
Local _cProduto
Local _nDPAL
Local _nDCAT
Local _nDREG
Local _nDGER				
Local _DPOL
Local _cLote

If AllTrim(cRepAtu) != "" .And. oReport:nDevice <> 6
	Alert("Você só pode gerar esse relatório no formato PDF.")
	Return
EndIf

cSQL := "SELECT ZZ6.ZZ6_DESC AS DESC_FORM" + Enter
cSQL += "	, SB1.B1_COD AS COD_PROD" + Enter
cSQL += "	, ZZ7.ZZ7_DESC AS DESC_LIN" + Enter
cSQL += "	, ISNULL((SELECT DA1_PRCVEN" + Enter
cSQL += "		FROM " + RetSqlName("DA1") + " DA1 WITH(NOLOCK)" + Enter
cSQL += "		WHERE DA1.DA1_CODTAB = '" + codTab + "'" + Enter
cSQL += "			AND DA1.DA1_CODPRO=SB1.B1_COD" + Enter
cSQL += "			AND SB1.B1_YCLASSE=1), 0.0)" + Enter
//cSQL += "		* ISNULL((SELECT Z65.Z65_FATMUL" + Enter
//cSQL += "		FROM " + RetSqlName("Z65") + " Z65 WITH(NOLOCK)" + Enter
//cSQL += "			INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK)" + Enter
//cSQL += "				ON Z65.Z65_UF = (CASE SA1.A1_EST WHEN 'ES' THEN SA1.A1_EST ELSE '' END)" + Enter
//cSQL += "					AND Z65.Z65_ZONAFR = SA1.A1_SUFRAMA" + Enter
//cSQL += "					AND SA1.A1_FILIAL='" + xFilial('SA1') + "'" + Enter
//cSQL += "					AND SA1.A1_COD='" + MV_PAR01 + "'" + Enter
//cSQL += "					AND SA1.D_E_L_E_T_=''" + Enter
//cSQL += "		WHERE Z65.Z65_GRTRIB = '001'" + Enter
//cSQL += "			AND Z65.Z65_TIPO = 'R'" + Enter
//cSQL += "			AND Z65.Z65_CONTRI = '1'" + Enter
//cSQL += "			AND Z65.Z65_ICMSOR <> '99'" + Enter
//cSQL += "			AND Z65.Z65_TIPVEN = ''" + Enter
//cSQL += "			AND Z65.D_E_L_E_T_ = ''), 0.0) *" + Enter
//cSQL += "		" + cValToChar(fatFin) + "" + Enter
cSQL += "		AS PRC_CLAS1" + Enter
cSQL += "	, ISNULL((SELECT DA1_PRCVEN" + Enter
cSQL += "		FROM " + RetSqlName("DA1") + " DA1 WITH(NOLOCK)" + Enter
cSQL += "		WHERE DA1.DA1_CODTAB = '" + codTab + "'" + Enter
cSQL += "			AND DA1.DA1_CODPRO=SUBSTRING(SB1.B1_COD,1,LEN(SB1.B1_COD) - 1) + '2'),0.0)" + Enter
//cSQL += "		* ISNULL((SELECT Z65.Z65_FATMUL" + Enter
//cSQL += "		FROM " + RetSqlName("Z65") + " Z65 WITH(NOLOCK)" + Enter
//cSQL += "			INNER JOIN " + RetSqlName("SA1") + " SA1 WITH(NOLOCK)" + Enter
//cSQL += "				ON Z65.Z65_UF = (CASE SA1.A1_EST WHEN 'ES' THEN SA1.A1_EST ELSE '' END)" + Enter
//cSQL += "					AND Z65.Z65_ZONAFR = SA1.A1_SUFRAMA" + Enter
//cSQL += "					AND SA1.A1_FILIAL='" + xFilial('SA1') + "'" + Enter
//cSQL += "					AND SA1.A1_COD='" + MV_PAR01 + "'" + Enter
//cSQL += "					AND SA1.D_E_L_E_T_=''" + Enter
//cSQL += "		WHERE Z65.Z65_GRTRIB = '001'" + Enter
//cSQL += "			AND Z65.Z65_TIPO = 'R'" + Enter
//cSQL += "			AND Z65.Z65_CONTRI = '1'" + Enter
//cSQL += "			AND Z65.Z65_ICMSOR <> '99'" + Enter
//cSQL += "			AND Z65.Z65_TIPVEN = ''" + Enter
//cSQL += "			AND Z65.D_E_L_E_T_ = ''), 0.0) *" + Enter
//cSQL += "		" + cValToChar(fatFin) + "" + Enter
cSQL += "		AS PRC_CLAS2" + Enter
cSQL += "	, B1_YLOCUSO AS LOC_USO" + Enter
cSQL += "	, B1_YCLASAD AS CLAS_AD" + Enter
cSQL += "	, B1_YTONDES AS VAR_TON" + Enter
cSQL += "	, B1_YJUNTA AS JUNTA" + Enter
cSQL += "	, (SB1.B1_CONV * SB1.B1_YDIVPA) AS PALE_M2" + Enter
cSQL += "	, SB1.B1_YDIVPA AS PALE_CAIX" + Enter
cSQL += "	, SB1.B1_CONV AS CAIX_M2" + Enter
cSQL += "	, SB1.B1_YPECA AS CAIX_PC" + Enter
cSQL += "	, ((SB1.B1_PESO + SB1.B1_YPESEMB) * SB1.B1_CONV) AS CAIX_KG" + Enter
cSQL += "	, (SB1.B1_PESO + (SB1.B1_YPESEMB / SB1.B1_CONV)) AS M2_KG" + Enter //foi dividido por SB1.B1_CONV pedido do Claudeir. 03/05/2016
cSQL += "	, SB1.B1_CODBAR AS COD_BAR" + Enter
cSQL += "FROM " + RetSqlName("SB1") + " SB1 WITH(NOLOCK)" + Enter
cSQL += "	INNER JOIN " + RetSqlName("ZZ6") + " ZZ6 WITH(NOLOCK)" + Enter
cSQL += "		ON SB1.B1_YFORMAT = ZZ6.ZZ6_COD" + Enter
cSQL += "			AND ZZ6.ZZ6_FILIAL = '" + xFilial('ZZ6') + "'" + Enter
cSQL += "			AND ZZ6.ZZ6_EMP <> 'V'" + Enter
cSQL += "			AND ZZ6.D_E_L_E_T_ = ''" + Enter
cSQL += "	INNER JOIN " + RetSqlName("ZZ7") + " ZZ7 WITH(NOLOCK)" + Enter
cSQL += "		ON (SB1.B1_YLINHA + SB1.B1_YLINSEQ) = (ZZ7.ZZ7_COD + ZZ7.ZZ7_LINSEQ)" + Enter
cSQL += "			AND ZZ7.ZZ7_FILIAL = '" + xFilial('ZZ7') + "'" + Enter
Do Case
   	Case nMarca == _NBIANCOGRES
   		cSQL += "	AND ZZ7.ZZ7_EMP='0101'" + Enter //BIANCOGRES
   	Case nMarca == _NINCESA
   		cSQL += "	AND ZZ7.ZZ7_EMP='0501'" + Enter //INCESA 
	Case nMarca == _NBELLACASA
		cSQL += "	AND ZZ7.ZZ7_EMP='0599'" + Enter //BELLACASA
	Case nMarca == _MUNDIALLI
		cSQL += "	AND ZZ7.ZZ7_EMP='1301'" + Enter //MUNDI
    Case nMarca == _PEGASUS
		cSQL += "	AND ZZ7.ZZ7_EMP='0199'" + Enter //Pegasus                
    Case nMarca == _VINILICO
		cSQL += "	AND ZZ7.ZZ7_EMP='1302'" + Enter //VINILICO
EndCase	
cSQL += "			AND ZZ7.D_E_L_E_T_ = ''" + Enter
cSQL += "WHERE SB1.B1_FILIAL = '" + xFilial('SB1') + "'" + Enter
cSQL += "	AND SB1.B1_YCLASSE IN('1')" + Enter
cSQL += "	AND SB1.B1_YSTATUS = '1'" + Enter
cSQL += "	AND SB1.B1_TIPO = 'PA'" + Enter
cSQL += "	AND SB1.B1_YIMPTAB = 'S'" + Enter
cSQL += "	AND SB1.D_E_L_E_T_ = ''" + Enter
cSQL += "ORDER BY DESC_FORM, COD_PROD" + Enter	
TcQuery cSQL New Alias (tbBia583)

oReport:SetMeter(RecCount()) 
While (tbBia583)->(!Eof()) 
	If oReport:Cancel() 
		Exit 
	EndIf 
	
	oReport:SkipLine(2)
	oReport:FatLine()
	oSecForm:Init() 	
	oSecForm:PrintLine()
	
	Formato := (tbBia583)->DESC_FORM
	
	oSecProd:Init() 
	While (tbBia583)->(!Eof()) .And. (tbBia583)->DESC_FORM==Formato 
		//If Trim((tbBia583)->COD_PROD) == 'C60207N1'
		//	Alert("Uhu")
		//EndIf
	
		If (tbBia583)->PRC_CLAS1 <> 0.0 .Or. (tbBia583)->PRC_CLAS2 <> 0.0
			
			_cProduto	:= (tbBia583)->COD_PROD
			_cLote		:= ""		
	
			cSpName := "SP_POL_GET_POLITICA_01" //PROJETO CONSOLIDAÇÃO - POLITICAS COMERCIAIS TODAS CONCENTRADAS NA BIANCOGRES
			
			_cAliasDet := GetNextAlias()
			//_cSQL := "EXEC "+cSpName+" '"+XFilial("ZA0")+"', '"+_cCliente+"' , '"+_cVendedor+"', '"+_cProduto+"', "+AllTrim(Str(IIf(_lPaletizado,1,0)))+", "+AllTrim(Str(_nPICMS))+", "+AllTrim(Str(_nPPIS))+", "+AllTrim(Str(_nPCOF))+", "+AllTrim(Str(_nAComis))+" "
			_cSQL := "EXEC "+cSpName+" '"+XFilial("ZA0")+"', '"+_cCliente+"' , '', '"+_cProduto+"', '', "+AllTrim(Str(IIf(_lPaletizado,1,0)))+", "+AllTrim(Str(_nPICMS))+", "+AllTrim(Str(_nPPIS))+", "+AllTrim(Str(_nPCOF))+", 4.00 "
			TCQuery _cSQL Alias (_cAliasDet) New
			   
			If !(_cAliasDet)->(Eof())     
				_nDPAL := (_cAliasDet)->DPAL
				_nDCAT := (_cAliasDet)->DCAT
				_nDREG := (_cAliasDet)->DREG
				_nDGER := (_cAliasDet)->DGER
				
				_DPOL := (1 - ( (1 - (_nDCAT/100)) * (1 - (_nDREG/100)) * (1 - (_nDGER/100)) )) * 100
				
				oSecProd:Cell("PRC_CLAS1"):SetValue((tbBia583)->PRC_CLAS1 * fatFin * fatMult * ((100 - _nDPAL)/100) * ((100 - _DPOL)/100))
				oSecProd:Cell("PRC_CLAS2"):SetValue((tbBia583)->PRC_CLAS2 * fatFin * fatMult * ((100 - _nDPAL)/100) * ((100 - _DPOL)/100))
			EndIf
			
			(_cAliasDet)->(dbCloseArea())
		EndIf
	
		oSecProd:PrintLine()
		
		(tbBia583)->(dbSkip())
	End 
	oSecProd:Finish()
	oSecForm:Finish() 
End

(tbBia583)->(dbCloseArea())

Return()

Static Function ValPergAco()
Local i,j,nX
Local aRegs := {}
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local Enter := chr(13) + Chr(10)
              
cPerg := PADR(cPerg,10)
aAdd(aRegs,{cPerg,"01","Cliente?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SA1BIA"})
aAdd(aRegs,{cPerg,"02","Loja?","","","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Forma Pag.?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SE4"})
If cEmpAnt == "01"
	aAdd(aRegs,{cPerg,"04","Marca?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Biancogres","","","","","Pegasus","","","","","","","","","","","","","","","","","","",""})
ElseIf cEmpAnt == "05"
	aAdd(aRegs,{cPerg,"04","Marca?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Incesa","","","","","Bellacasa","","","","","","","","","","","","","","","","","","",""})
ElseIf cEmpAnt == "13"
	aAdd(aRegs,{cPerg,"04","Marca?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Mundialli","","","","","","","","","","","","","","","","","","","","","","","",""})
EndIf

//Grava no SX1 se ja nao existir
dbSelectArea("SX1")
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Else
		//ATUALIZA SX1
		RecLock("SX1",.F.)
		For j:=3 to FCount()
			If j <= Len(aRegs[i])
				If SubStr(FieldName(j),1,6) <> "X1_CNT"
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	EndIf	
Next

//Renumerar perguntas
_ncont := 1
SX1->(dbSeek(cPerg))
While .Not. SX1->(Eof()) .And. X1_GRUPO == cPerg
	RecLock("SX1",.F.)
	SX1->X1_ORDEM := StrZero(_ncont,2)
	SX1->(MsUnlock())
	SX1->(DbSkip())
	_ncont++
EndDo

//Deletar Perguntas sobrando - apagadas do vetor
While SX1->(dbSeek(cPerg+StrZero(i,2)))
	RecLock("SX1",.F.)
	SX1->(DbDelete())
	SX1->(MsUnlock())
	i++
EndDo

Return