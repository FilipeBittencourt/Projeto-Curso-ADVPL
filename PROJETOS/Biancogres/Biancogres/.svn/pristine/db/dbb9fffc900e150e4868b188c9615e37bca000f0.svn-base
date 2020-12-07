#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*/{Protheus.doc} BIA932A
@author Wlysses Cerqueira (Facile)
@since 07/02/2020
@Ticket 21215
@version 1.0
@description Classe para relatorio de comissao
convertido para TReport do BIA932
@type class
/*/

#DEFINE ENTER CHR(13)+CHR(10)

Class BIA932A From LongClassName

    Data oProcess
    Data oTableCom
    Data oTableVend
    Data cAlias
    Data cAliasVend

    Data oReport
    Data oSection1
    Data oSection2
    Data oSection3
    Data oSection4
    Data oSection5
    Data oFont1
    Data cTitle

    Data cName
    Data aParam
    Data aParRet
    Data bConfirm
    Data lConfirm

    Data cFilDe
    Data cFilAte

    Data dDtBaixaDe
    Data dDtBaixaAte
    Data cClienteDe
    Data cClienteAte
    Data cLojaDe
    Data cLojaAte
    Data cVendDe
    Data cVendAte

    Method New() Constructor
    Method Relatorio()
    Method Pergunte()
    Method Load()
    Method PrepPrint()
    Method ProcPrint()

    Method fRecebido()
    Method fEstorno()
    Method fComissao()

    Method Imprimir()

EndClass

Method New() Class BIA932A

    Local aCampos := {}

    ::oReport := Nil
    ::oSection1 := Nil
    ::oSection2 := Nil
    ::oSection3 := Nil
    ::oSection4 := Nil
    ::oSection5 := Nil
    ::oFont1 := TFont():New("Courier New",8,8,.T.,.T.,5,.T.,5,.T.,.F.)

    ::cTitle := "Comissoes por titulos Recebidos - Por data da baixa"

    ::cName := "BIA932A"
    ::aParam := {}
    ::aParRet := {}
    ::bConfirm := {|| .T.}
    ::lConfirm := .F.

    ::oTableCom := FWTemporaryTable():New( /*(::cAlias)*/, /*aFields*/)

    aCampos := {{"PREFIXO"  , "C", 03, 0} ,;
        {"NUMERO"	    , "C", 09, 0},;
        {"PARCELA"	    , "C", 01, 0},;
        {"CLIENTE"	    , "C", 06, 0},;
        {"LOJA"		    , "C", 02, 0},;
        {"NOME" , "C", 35, 0},;
        {"TIPO"		    , "C", 03, 0},;
        {"VEND"		    , "C", 06, 0},;
        {"VALOR"  	    , "N", 14, 2},;
        {"ESTORNO"	    , "N", 12, 2},;
        {"COMIS"	    , "N", 12, 2},;
        {"PERCOMIS"	    , "N", 06, 2},;
        {"CFCOM"	    , "C", 01, 0},;
        {"BASECALC"	    , "N", 14, 2},;
        {"DATATIT"	    , "D", 08, 0},;
        {"DATAEXT"	    , "D", 08, 0},;
        {"DATACOM"	    , "D", 08, 0}}

    ::oTableCom:SetFields(aCampos)

    ::oTableCom:AddIndex("01", {"PREFIXO", "NUMERO", "PARCELA", "CLIENTE", "LOJA", "TIPO", "VEND"})
    ::oTableCom:AddIndex("02", {"PREFIXO", "PERCOMIS", "VEND", "CLIENTE", "LOJA"})
    ::oTableCom:AddIndex("03", {"NOME"})

    ::oTableCom:Create()

    ::oTableVend := FWTemporaryTable():New( /*(::cAlias)*/, /*aFields*/)

    aCampos := {{"CODIGO"   , "C", 06, 0} ,;
        {"VALOR"	, "N", 14, 2},;
        {"BASE"		, "N", 14, 2},;
        {"COMISSAO"	, "N", 12, 2} }

    ::oTableVend:SetFields(aCampos)

    ::oTableVend:AddIndex("01", {"CODIGO"})

    ::oTableVend:Create()

    (::cAlias) := ::oTableCom:GetAlias()

    (::cAliasVend) := ::oTableVend:GetAlias()
    
    ::cFilDe := Space(TamSx3("E1_FILIAL")[1])
    ::cFilAte := Space(TamSx3("E1_FILIAL")[1])

    ::dDtBaixaDe := StoD("  /  /  ")
    ::dDtBaixaAte := StoD("  /  /  ")

    ::cClienteDe := Space(TamSx3("E1_CLIENTE")[1])
    ::cClienteAte := Space(TamSx3("E1_CLIENTE")[1])

    ::cLojaDe := Space(TamSx3("E1_LOJA")[1])
    ::cLojaAte := Space(TamSx3("E1_LOJA")[1])

    ::cVendDe := Space(TamSx3("E1_VEND1")[1])
    ::cVendAte := Space(TamSx3("E1_VEND1")[1])

Return()

Method Load() Class BIA932A

	//{|| ::Pergunte()}
	
	Local oFont	:= TFont():New("Arial"   	 	,12, -12, /*.T.*/,/*.T.*/,/*5*/,/*.T.*/,/*5*/,/*.T.*,/*.F.*/) // Arial   12 Bold  - Cabeçalho Ficha de Compra
	
	
	//Private oFont1	 := TFont():New( "Arial"/*<cName>*/,  /*<nWidth>*/, -12/*<nHeight>*/, /*<.from.>*/, .T./*[<.bold.>]*/, /*<nEscapement>*/, , /*<nWeight>*/, /*[<.italic.>]*/, /*[<.underline.>]*/,,,,,, /*[<oDevice>]*/ )
	
	
    ::oReport := TReport():New(::cName, ::cTitle, "BIA932", {|oReport| ::PrepPrint()}, ::cTitle)
    ::oReport:nFontBody := 7.5
    
    
    ::oReport:lBold := .T.
    //::oReport:ShowParamPage()
    //::oReport:lParamPage := .T.

    ::oSection1:= TRSection():New(::oReport,"Conferencia de titulos", {(::cAlias)})
    ::oSection1:SetTotalInLine(.F.)

    //::oSection1:lBold := .T.

    //::oReport:nFontBody := 10

    ::oReport:SetLandScape(.T.)

    TRCell():New(::oSection1, "PREFIXO"	    , (::cAlias), "Prefixo"         ,,TamSX3("E5_PREFIXO")[1])
    TRCell():New(::oSection1, "TIPO"	    , (::cAlias), "Tipo"            ,,TamSX3("E5_TIPO")[1])
    TRCell():New(::oSection1, "VEND"        , (::cAlias), "Cod.Vendedor"    ,,TamSX3("E1_VEND1")[1])
    TRCell():New(::oSection1, "NOME_VEND"   , (::cAlias), "Nome Vendedor"   ,,TamSX3("A1_NOME")[1]-10)

    TRCell():New(::oSection1, "CLIENTE"	    , (::cAlias), "Cod.Cli."     ,,TamSX3("A1_COD")[1])
    TRCell():New(::oSection1, "LOJA"		, (::cAlias), "Loja"            ,,TamSX3("A1_LOJA")[1])
    TRCell():New(::oSection1, "NOME"        , (::cAlias), "Nome Cliente"    ,,TamSX3("A3_NOME")[1])

    TRCell():New(::oSection1, "NUMERO"	    , (::cAlias), "Numero"          ,,16)
    TRCell():New(::oSection1, "PARCELA"	    , (::cAlias), "Par."	        ,,6/*TamSX3("E1_PARCELA")[1]*/)
    TRCell():New(::oSection1, "DATACOM"	    , (::cAlias), "Dt. Baixa", , 14)

    TRCell():New(::oSection1, "VALOR"       , (::cAlias), "Vlr. Recebido"  ,"@E 999,999,999.99", 24,,,"RIGHT",,"RIGHT")
    TRCell():New(::oSection1, "BASECALC"    , (::cAlias), "Base Calculo"    ,"@E 999,999,999.99",24,,,"RIGHT",,"RIGHT")
    TRCell():New(::oSection1, "PERCOMIS"    , (::cAlias), "% Comissao"      ,"@E 999,999,999.99",20,,,"RIGHT",,"RIGHT")
    TRCell():New(::oSection1, "COMIS"       , (::cAlias), "Vlr. Comissao"   ,"@E 999,999,999.99",20,,,"RIGHT",,"RIGHT")
   // TRCell():New(::oSection1, "CFCOM"       , (::cAlias), "CF.Comissao")	
    
    
    ::oSection1:Cell('PREFIXO'    	):oFontBody := oFont
    ::oSection1:Cell('TIPO'    		):oFontBody := oFont
    ::oSection1:Cell('VEND'    		):oFontBody := oFont
    ::oSection1:Cell('NOME_VEND'    ):oFontBody := oFont
    ::oSection1:Cell('CLIENTE'    	):oFontBody := oFont
    ::oSection1:Cell('NOME'    		):oFontBody := oFont
    ::oSection1:Cell('NUMERO'    	):oFontBody := oFont
    ::oSection1:Cell('PARCELA'    	):oFontBody := oFont
    ::oSection1:Cell('DATACOM'    	):oFontBody := oFont
    ::oSection1:Cell('VALOR'    	):oFontBody := oFont
    ::oSection1:Cell('BASECALC'    	):oFontBody := oFont
    ::oSection1:Cell('PERCOMIS'    	):oFontBody := oFont
    ::oSection1:Cell('COMIS'    	):oFontBody := oFont
    //::oSection1:Cell('COMIS'    	):oFontBody := oFont
    

    ::oSection2 := TRSection():New(::oReport, "Totais", "TEMP")    
	::oSection2:SetHeaderSection(.F.)
    
	TRCell():New( ::oSection2, "VAZIO1"		,,"Prefixo"				,"@"					,TamSX3("E5_PREFIXO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( ::oSection2, "VAZIO2"		,,"Tipo"				,"@"					,TamSX3("E5_TIPO")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( ::oSection2, "VAZIO3"		,,"Cod.Vendedor"		,"@"					,TamSX3("E1_VEND1")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( ::oSection2, "VAZIO4"		,,"Nome Vendedor"		,"@"					,TamSX3("A1_NOME")[1]-10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( ::oSection2, "VAZIO5"		,,"Cod.Cli."			,"@"					,TamSX3("A1_COD")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( ::oSection2, "VAZIO6"		,,"Loja"				,"@"					,TamSX3("A1_LOJA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	
	
	TRCell():New( ::oSection2, "DESCRICAO"	,,"Representante"		,"@"					, TamSX3("A3_NOME")[1]+10/*TamSX3("E1_PARCELA")[1]*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	TRCell():New( ::oSection2, "VAZIO7"		,,"Numero"				,"@"					, 10,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( ::oSection2, "VAZIO8"		,,"Par."				,"@"					, 6,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( ::oSection2, "VAZIO9"		,,"Dt. Baixa"			,"@"					, 8,/*lPixel*/,/*{|| code-block de impressao }*/)
	
	
	TRCell():New( ::oSection2, "TOTAL1"		,,"Vlr. Recebido"				,"@"					,24,,,"RIGHT",,"RIGHT")
	TRCell():New( ::oSection2, "TOTAL2"		,,"Base Calculo"				,"@"					,24,,,"RIGHT",,"RIGHT")
	TRCell():New( ::oSection2, "TOTAL3"		,,"% Comissao"					,"@"					,20,,,"RIGHT",,"RIGHT")
	TRCell():New( ::oSection2, "TOTAL4"		,,"Vlr. Comissao"				,"@"					,20,,,"RIGHT",,"RIGHT")
	//TRCell():New(::oSection2, "VAZIO10"      ,, "CF.Comissao")	
	
	
	
	::oSection2:Cell('VAZIO1'    	):oFontBody := oFont
    ::oSection2:Cell('VAZIO2'    	):oFontBody := oFont
    ::oSection2:Cell('VAZIO3'    	):oFontBody := oFont
    ::oSection2:Cell('VAZIO4'    	):oFontBody := oFont
    ::oSection2:Cell('VAZIO5'    	):oFontBody := oFont
    ::oSection2:Cell('VAZIO6'    	):oFontBody := oFont
    ::oSection2:Cell('DESCRICAO'    ):oFontBody := oFont
    ::oSection2:Cell('VAZIO7'    	):oFontBody := oFont
    ::oSection2:Cell('VAZIO8'    	):oFontBody := oFont
    ::oSection2:Cell('VAZIO9'    	):oFontBody := oFont
    ::oSection2:Cell('TOTAL1'    	):oFontBody := oFont
    ::oSection2:Cell('TOTAL2'    	):oFontBody := oFont
    ::oSection2:Cell('TOTAL3'    	):oFontBody := oFont
    ::oSection2:Cell('TOTAL4'    	):oFontBody := oFont
 //   ::oSection2:Cell('VAZIO10'    	):oFontBody := oFont
	//oBreak1 := TRBreak():New(::oSection1,{|| ((::cAlias))->E1_NUMBOR})

    //TRFunction():New(::oSection1:Cell("E1_VALOR"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
    //TRFunction():New(::oSection1:Cell("E1_SALDO"),Nil,"SUM",oBreak1, Nil, Nil, Nil, .F., .F.)
   

Return()

Method PrepPrint() Class BIA932A

    ::oProcess := MsNewProcess():New ( {|| ::ProcPrint() }, "Comissão", "Aguarde ...", .F. )

    ::oProcess:Activate()

Return()

Method ProcPrint() Class BIA932A

    ::oProcess:SetRegua1(3)
    
    ::fRecebido()

    ::fEstorno()

    ::fComissao()

    ::Imprimir()

Return()

Method fRecebido() Class BIA932A

    Local nTotReg := 0

    ::oProcess:IncRegua1("Processando recebimentos...")

    /*
    //titulos recebidos
    cSql := "SELECT * " + ENTER
    cSql += "FROM " + ENTER
    cSql += "(SELECT SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPO, SE5.E5_VALOR, SE5.E5_DATA, " + ENTER
    cSql += "		 VEND = CASE " + ENTER
    cSql += "			WHEN SE5.E5_TIPO = 'FT' THEN (SELECT MAX(E1_VEND1) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '01' AND E1_FATPREF = SE5.E5_PREFIXO AND E1_FATURA = SE5.E5_NUMERO AND D_E_L_E_T_ = '') " + ENTER
    cSql += "			ELSE (SELECT MAX(E1_VEND1) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '01' AND E1_PREFIXO = SE5.E5_PREFIXO AND E1_NUM = SE5.E5_NUMERO AND E1_PARCELA = SE5.E5_PARCELA AND E1_TIPO = SE5.E5_TIPO AND D_E_L_E_T_ = '') " + ENTER
    //cSql += "			ELSE '999999' " + ENTER
    cSql += "		 END " + ENTER
    cSql += "FROM "+RetSqlName("SE5")+" SE5"  + ENTER
    cSql += "WHERE SE5.E5_FILIAL= '"+XFilial("SE5")+"'"  + ENTER
    cSql += " 	AND SE5.E5_TIPODOC	NOT IN ('MT','CM','D2','J2','M2','C2','V2','TL','JR', 'DC')"  + ENTER
    cSql += "	AND SE5.E5_TIPO		NOT IN ('NCC', 'DEV','CH','RA','PA','')"  + ENTER
    cSql += "	AND SE5.E5_NATUREZ	IN ('1121', '1131')"  + ENTER

    If cempant == "01"
        cSql += " AND SE5.E5_PREFIXO IN ('01','S1','S1F','S2','1','2','3','4','NDI','')"  + ENTER
    Else
        //cSql += " AND SE5.E5_PREFIXO = ''"  + ENTER
        cSql += " AND SE5.E5_PREFIXO IN ('01','S1','','1','2','3','4','6','7','NDI') "  + ENTER
    EndIf

    cSql += "	AND SE5.E5_RECPAG			= 'R'"  + ENTER
    cSql += "	AND SE5.E5_SITUACA		<> 'C'"  + ENTER
    cSql += "	AND SE5.E5_MOTBX		NOT IN ('FAT', 'LIQ') "  + ENTER
    cSql += "	AND SE5.E5_DATA BETWEEN	'"+DToS(::dDtBaixaDe)+"' AND '"+DToS(::dDtBaixaAte)+"'"  + ENTER
    cSql += "	AND SE5.E5_CLIFOR BETWEEN	'"+::cClienteDe+"' AND '"+::cClienteAte+"'"  + ENTER
    cSql += "	AND SE5.E5_LOJA BETWEEN	'"+::cLojaDe+"' AND '"+::cLojaAte+"'"  + ENTER
    cSql += "	AND SE5.D_E_L_E_T_		= '') AS REC " + ENTER
    //cSql += "	AND SE5.E5_NUMERO = '026084') AS REC " + ENTER  //RANISSES
    cSql += "WHERE VEND >= '"+::cVendDe+"' AND VEND <= '"+::cVendAte+"' " + ENTER
    cSql += "ORDER BY E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, E5_LOJA, E5_TIPO"  + ENTER
    */

    cSql := "SELECT * " 
    cSql += "FROM " 
    cSql += "    ( " 
    cSql += "        SELECT " 
    cSql += "            SE5.E5_PREFIXO, " 
    cSql += "            SE5.E5_DOCUMEN, " 
    cSql += "            SE5.E5_NUMERO, " 
    cSql += "            SE5.E5_PARCELA, " 
    cSql += "            SE5.E5_CLIFOR, " 
    cSql += "            SE5.E5_LOJA, " 
    cSql += "            SE5.E5_TIPO, " 
    cSql += "            SE5.E5_VALOR, " 
    cSql += "            SE5.E5_DATA, " 
    cSql += "            VEND = CASE " 
    cSql += "                       WHEN SE5.E5_TIPO = 'FT' " 
    cSql += "                           THEN " 
    cSql += "							( " 
    cSql += "								CASE " 
    cSql += "									 WHEN  " 
    cSql += "									 ( " 
    cSql += "											SELECT COUNT(*) "  // LIQUIDACAO
    cSql += "											FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) " 
    cSql += "											WHERE SE1.E1_FILIAL = SE5.E5_FILIAL " 
    cSql += "											AND SE1.E1_NUM      = SE5.E5_NUMERO " 
    cSql += "											AND SE1.E1_PREFIXO  = SE5.E5_PREFIXO " 
    cSql += "											AND SE1.E1_PARCELA  = SE5.E5_PARCELA " 
    cSql += "											AND SE1.E1_CLIENTE  = SE5.E5_CLIFOR " 
    cSql += "											AND SE1.E1_LOJA     = SE5.E5_LOJA " 
    cSql += "											AND SE1.E1_NUMLIQ   <> '' " 
    cSql += "											AND SE1.D_E_L_E_T_  = '' " 
    cSql += "									 ) > 0 " 
    cSql += "										 THEN " 
    cSql += "										 ( " 
    cSql += "										 	SELECT MAX(SE1.E1_VEND1) "  // LIQUIDACAO
    cSql += "											FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) " 
    cSql += "											WHERE SE1.E1_FILIAL = SE5.E5_FILIAL " 
    cSql += "											AND SE1.E1_NUM      = SE5.E5_NUMERO " 
    cSql += "											AND SE1.E1_PREFIXO  = SE5.E5_PREFIXO " 
    cSql += "											AND SE1.E1_PARCELA  = SE5.E5_PARCELA " 
    cSql += "											AND SE1.E1_CLIENTE  = SE5.E5_CLIFOR " 
    cSql += "											AND SE1.E1_LOJA     = SE5.E5_LOJA " 
    cSql += "											AND SE1.E1_NUMLIQ   <> '' " 
    cSql += "											AND SE1.D_E_L_E_T_  = '' " 
    cSql += "										 ) " 
    cSql += "									 ELSE " 
    cSql += "									 ( " 
    cSql += "										 SELECT  MAX(SE1.E1_VEND1) "  // FATURA ANTIGA
    cSql += "										 FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) " 
    cSql += "										 WHERE " 
    cSql += "											 SE1.E1_FILIAL      = SE5.E5_FILIAL " 
    cSql += "											 AND SE1.E1_FATPREF = SE5.E5_PREFIXO " 
    cSql += "											 AND SE1.E1_FATURA  = SE5.E5_NUMERO " 
    cSql += "											 AND SE1.D_E_L_E_T_ = '' " 
    cSql += "									 ) " 
    cSql += "								 END " 
    cSql += "							) " 
    cSql += "                       ELSE " 
    cSql += "                       ( " 
    cSql += "                           SELECT MAX(E1_VEND1) " 
    cSql += "                           FROM " + RetSqlName("SE1") + " " 
    cSql += "                           WHERE " 
    cSql += "                               E1_FILIAL       = SE5.E5_FILIAL " 
    cSql += "                               AND E1_PREFIXO  = SE5.E5_PREFIXO " 
    cSql += "                               AND E1_NUM      = SE5.E5_NUMERO " 
    cSql += "                               AND E1_PARCELA  = SE5.E5_PARCELA " 
    cSql += "                               AND E1_TIPO     = SE5.E5_TIPO " 
    cSql += "                               AND D_E_L_E_T_  = '' " 
    cSql += "                       ) " 
    cSql += "                   END " 
    cSql += "        FROM " + RetSqlName("SE5") + " SE5 " 
    cSql += "        WHERE " 
    cSql += "            SE5.E5_FILIAL          = " + ValToSql(xFilial("SE5")) 
    cSql += "            AND SE5.E5_TIPODOC     NOT IN ( 'MT', 'CM', 'D2', 'J2', 'M2', 'C2', 'V2', 'TL', 'JR', 'DC' ) " 
    cSql += "            AND SE5.E5_TIPO        NOT IN ( 'NCC', 'DEV', 'CH', 'RA', 'PA', '' ) " 
    cSql += "            AND SE5.E5_NATUREZ     IN ( '1121', '1131' ) " 
 
    If cEmpAnt == "01"

        cSql += "        AND SE5.E5_PREFIXO IN ( '01', 'S1', 'S1F', 'S2', '1', '2', '3', '4', 'NDI', '' )"  
    
    Else
    
        cSql += "        AND SE5.E5_PREFIXO IN ( '01', 'S1', '', '1', '2', '3', '4', '6', '7', 'NDI' ) "  
    
    EndIf

    cSql += "            AND SE5.E5_RECPAG      = 'R' " 
    cSql += "            AND SE5.E5_SITUACA     <> 'C' " 
    cSql += "            AND SE5.E5_MOTBX       NOT IN ( 'FAT', 'LIQ' ) " 
    cSql += "            AND SE5.E5_DATA        BETWEEN " + ValToSql(DToS(::dDtBaixaDe))    + " AND " + ValToSql(DToS(::dDtBaixaAte)) 
    cSql += "            AND SE5.E5_CLIFOR      BETWEEN " + ValToSql(::cClienteDe)          + " AND " + ValToSql(::cClienteAte) 
    cSql += "            AND SE5.E5_LOJA        BETWEEN " + ValToSql(::cLojaDe)             + " AND " + ValToSql(::cLojaAte) 
    cSql += "            AND SE5.D_E_L_E_T_     = '' " 
    cSql += "    ) AS REC " 
    cSql += "WHERE VEND BETWEEN " + ValToSql(::cVendDe) + " AND " + ValToSql(::cVendAte) 
    cSql += "ORDER BY " 
    cSql += "    E5_PREFIXO, " 
    cSql += "    E5_NUMERO, " 
    cSql += "    E5_PARCELA, " 
    cSql += "    E5_CLIFOR, " 
    cSql += "    E5_LOJA, " 
    cSql += "    E5_TIPO " 

    TCQUERY cSql NEW ALIAS "cRecebido"

    ConOut(cSql)

    DbSelectArea("cRecebido")
    cRecebido->(DbGotop())

    nTotReg := Contar("cRecebido","!Eof()")

    ::oProcess:SetRegua2(nTotReg)

    cRecebido->(DbGotop())

    Do while ! cRecebido->(EOF())

        ::oProcess:IncRegua2("Carregando recebimentos...")

        DbSelectArea("SE1")
        DbSetOrder(1)
        DbSeek(xFilial("SE1")+cRecebido->E5_PREFIXO+cRecebido->E5_NUMERO+cRecebido->E5_PARCELA+cRecebido->E5_TIPO+cRecebido->E5_CLIFOR+cRecebido->E5_LOJA)

        lInclui := .T.

        If (::cAlias)->(dbSeek(cRecebido->E5_PREFIXO+cRecebido->E5_NUMERO+cRecebido->E5_PARCELA+cRecebido->E5_CLIFOR+cRecebido->E5_LOJA+cRecebido->E5_TIPO+cRecebido->VEND))
            lInclui := .F.
        EndIf

        Reclock((::cAlias),lInclui)
        (::cAlias)->PREFIXO     := cRecebido->E5_PREFIXO
        (::cAlias)->NUMERO      := cRecebido->E5_NUMERO
        (::cAlias)->PARCELA     := cRecebido->E5_PARCELA
        (::cAlias)->CLIENTE     := cRecebido->E5_CLIFOR
        (::cAlias)->LOJA        := cRecebido->E5_LOJA
        (::cAlias)->NOME        := Posicione("SA1",1,XFILIAL("SA1")+cRecebido->E5_CLIFOR+cRecebido->E5_LOJA,"A1_NREDUZ")
        (::cAlias)->TIPO        := cRecebido->E5_TIPO
        (::cAlias)->DATATIT     := SToD(cRecebido->E5_DATA)
        (::cAlias)->VALOR       += cRecebido->E5_VALOR
        (::cAlias)->VEND		     := cRecebido->VEND
        (::cAlias)->CFCOM       := SE1->E1_YCFCOM
	    /*SE1->(DbSetOrder(1))
        If SE1->(DbSeek(xFilial("SE1")+cRecebido->E5_PREFIXO+cRecebido->E5_NUMERO+cRecebido->E5_PARCELA+cRecebido->E5_TIPO))  //Ranisses
		(::cAlias)->VEND := SE1->E1_VEND1
        EndIf	*/
	    (::cAlias)->(MsUnlock())
	    cRecebido->(DbSkip())

    Enddo

    cRecebido->(DbCloseArea())

Return()

Method fEstorno() Class BIA932A

    Local nTotReg := 0

    ::oProcess:IncRegua1("Processando estornos...")

    /*
    //titulos estornados
    cSql := "SELECT * " + ENTER
    cSql += "FROM " + ENTER
    cSql += "(SELECT SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPO, " + ENTER
    cSql += " CASE WHEN SE5.E5_MOTBX = 'CEC' AND SE5.E5_VLJUROS > 0 THEN SE5.E5_VALOR - SE5.E5_VLJUROS ELSE SE5.E5_VALOR END AS E5_VALOR, SE5.E5_DATA, " + ENTER
    cSql += "		 VEND = CASE " + ENTER
    cSql += "			WHEN SE5.E5_TIPO = 'FT' THEN (SELECT MAX(E1_VEND1) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '01' AND E1_FATPREF = SE5.E5_PREFIXO AND E1_FATURA = SE5.E5_NUMERO AND D_E_L_E_T_ = '') " + ENTER
    cSql += "			WHEN SE5.E5_TIPO = 'NF' THEN (SELECT MAX(E1_VEND1) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '01' AND E1_PREFIXO = SE5.E5_PREFIXO AND E1_NUM = SE5.E5_NUMERO AND E1_PARCELA = SE5.E5_PARCELA AND E1_TIPO = SE5.E5_TIPO AND D_E_L_E_T_ = '') " + ENTER
    cSql += "			ELSE '999999' " + ENTER
    cSql += "		 END " + ENTER
    cSql += "FROM "+RetSqlName("SE5")+" SE5" + ENTER
    cSql += "WHERE SE5.E5_FILIAL= '"+XFilial("SE5")+"'" + ENTER
    cSql += "	AND SE5.E5_TIPODOC IN ('ES') " + ENTER
    cSql += "	AND SE5.E5_TIPO    NOT IN ('NCC', 'DEV','CH') " + ENTER

    If cempant == "01"
            cSql += "	AND SE5.E5_PREFIXO IN ('01','S1','S1F','S2','1','2','3','4','NDI','')" + ENTER
    Else
        //cSql += "	AND SE5.E5_PREFIXO = ''" + ENTER
            cSql += " AND SE5.E5_PREFIXO IN ('01','S1','','1','2','3','4','6','7','NDI') "  + ENTER
    EndIf

    cSql += "	AND SE5.E5_RECPAG	= 'P' " + ENTER
    cSql += "	AND SE5.E5_SITUACA	<> 'C' " + ENTER
    cSql += "	AND SE5.E5_DATA 	>= '"+DToS(::dDtBaixaDe)+"'" + ENTER
    cSql += "	AND SE5.E5_CLIFOR	BETWEEN '"+::cClienteDe+"' AND '"+::cClienteAte+"'" + ENTER
    cSql += "	AND SE5.E5_LOJA 	BETWEEN '"+::cLojaDe+"' AND '"+::cLojaAte+"'" + ENTER  
    cSql += "	AND SE5.D_E_L_E_T_	= '' ) AS EST " + ENTER
    //cSql += "	AND SE5.E5_NUMERO = '026084' ) AS EST " + ENTER //RANISSES
    cSql += "WHERE VEND >= '"+::cVendDe+"' AND VEND <= '"+::cVendAte+"' " + ENTER
    cSql += "ORDER BY E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, E5_LOJA, E5_TIPO " + ENTER 
    */

    cSql := "SELECT * "
    cSql += "FROM "
    cSql += "    ( "
    cSql += "        SELECT "
    cSql += "            SE5.E5_PREFIXO, "
    cSql += "            SE5.E5_NUMERO, "
    cSql += "            SE5.E5_PARCELA, "
    cSql += "            SE5.E5_CLIFOR, "
    cSql += "            SE5.E5_LOJA, "
    cSql += "            SE5.E5_TIPO, "
    cSql += "            CASE "
    cSql += "                WHEN SE5.E5_MOTBX = 'CEC' "
    cSql += "                     AND SE5.E5_VLJUROS > 0 "
    cSql += "                    THEN "
    cSql += "                    SE5.E5_VALOR - SE5.E5_VLJUROS "
    cSql += "                ELSE "
    cSql += "                    SE5.E5_VALOR "
    cSql += "            END  AS E5_VALOR, "
    cSql += "            SE5.E5_DATA, "
    cSql += "            VEND = CASE "
    cSql += "                       WHEN SE5.E5_TIPO = 'FT' "
    cSql += "                           THEN "
    cSql += "							( "
    cSql += "								CASE "
    cSql += "									 WHEN  "
    cSql += "									 ( "
    cSql += "											SELECT COUNT(*) "
    cSql += "											FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "
    cSql += "											WHERE SE1.E1_FILIAL = SE5.E5_FILIAL "
    cSql += "											AND SE1.E1_NUM      = SE5.E5_NUMERO "
    cSql += "											AND SE1.E1_PREFIXO  = SE5.E5_PREFIXO "
    cSql += "											AND SE1.E1_PARCELA  = SE5.E5_PARCELA "
    cSql += "											AND SE1.E1_CLIENTE  = SE5.E5_CLIFOR "
    cSql += "											AND SE1.E1_LOJA     = SE5.E5_LOJA "
    cSql += "											AND SE1.E1_NUMLIQ   <> '' "
    cSql += "											AND SE1.D_E_L_E_T_  = '' "
    cSql += "									 ) > 0 "
    cSql += "										 THEN "
    cSql += "										 (
    cSql += "										 	SELECT SE1.E1_VEND1 "
    cSql += "											FROM " + RetSqlName("SE1") + " SE1 (NOLOCK) "
    cSql += "											WHERE SE1.E1_FILIAL = SE5.E5_FILIAL "
    cSql += "											AND SE1.E1_NUM      = SE5.E5_NUMERO "
    cSql += "											AND SE1.E1_PREFIXO  = SE5.E5_PREFIXO "
    cSql += "											AND SE1.E1_PARCELA  = SE5.E5_PARCELA "
    cSql += "											AND SE1.E1_CLIENTE  = SE5.E5_CLIFOR "
    cSql += "											AND SE1.E1_LOJA     = SE5.E5_LOJA "
    cSql += "											AND SE1.E1_NUMLIQ   <> '' "
    cSql += "											AND SE1.D_E_L_E_T_  = '' "
    cSql += "										 ) "
    cSql += "									 ELSE "
    cSql += "									 ( "
    cSql += "										 SELECT MAX(E1_VEND1) "
    cSql += "										 FROM " + RetSqlName("SE1") + " SE1 "
    cSql += "										 WHERE "
    cSql += "											SE1.E1_FILIAL       = SE5.E5_FILIAL "
    cSql += "											AND SE1.E1_FATPREF  = SE5.E5_PREFIXO "
    cSql += "											AND SE1.E1_FATURA   = SE5.E5_NUMERO "
    cSql += "											AND SE1.D_E_L_E_T_  = '' "
    cSql += "									 ) "
    cSql += "								 END "
    cSql += "							) "
    cSql += "                        WHEN SE5.E5_TIPO = 'NF' "
    cSql += "                           THEN "
    cSql += "                           ( "
    cSql += "                               SELECT MAX(E1_VEND1) "
    cSql += "                               FROM " + RetSqlName("SE1") + " SE1 "
    cSql += "                               WHERE "
    cSql += "                                   SE1.E1_FILIAL        = SE5.E5_FILIAL "
    cSql += "                                   AND SE1.E1_PREFIXO   = SE5.E5_PREFIXO "
    cSql += "                                   AND SE1.E1_NUM       = SE5.E5_NUMERO "
    cSql += "                                   AND SE1.E1_PARCELA   = SE5.E5_PARCELA "
    cSql += "                                   AND SE1.E1_TIPO      = SE5.E5_TIPO "
    cSql += "                                   AND SE1.D_E_L_E_T_   = '' "
    cSql += "                           ) "
    cSql += "                       ELSE '999999' "
    cSql += "                   END "
    cSql += "        FROM " + RetSqlName("SE5") + " SE5 "
    cSql += "        WHERE "
    cSql += "            SE5.E5_FILIAL       = " + ValToSql(xFilial("SE5")) 
    cSql += "            AND SE5.E5_TIPODOC  IN ( 'ES' ) "
    cSql += "            AND SE5.E5_TIPO NOT IN ( 'NCC', 'DEV', 'CH' ) "

    If cEmpAnt == "01"

        cSql += "        AND SE5.E5_PREFIXO  IN ( '01', 'S1', 'S1F', 'S2', '1', '2', '3', '4', 'NDI', '' ) "
    
    Else

        cSql += "        AND SE5.E5_PREFIXO IN ('01', 'S1', '', '1', '2', '3', '4', '6', '7', 'NDI' ) "

    EndIf

    cSql += "            AND SE5.E5_RECPAG   = 'P' "
    cSql += "            AND SE5.E5_SITUACA  <> 'C' "
    cSql += "            AND SE5.E5_DATA     > " + ValToSql(DToS(::dDtBaixaDe)) // Estranho nao usar a dataAte, vou deixar como estava.
    cSql += "            AND SE5.E5_CLIFOR   BETWEEN " + ValToSql(::cClienteDe) + " AND " + ValToSql(::cClienteAte) 
    cSql += "            AND SE5.E5_LOJA     BETWEEN " + ValToSql(::cLojaDe)    + " AND " + ValToSql(::cLojaAte) 
    cSql += "            AND SE5.D_E_L_E_T_  = '' "
    cSql += "    ) AS EST "
    cSql += "WHERE VEND BETWEEN " + ValToSql(::cVendDe) + " AND " + ValToSql(::cVendAte) 
    cSql += "ORDER BY "
    cSql += "    E5_PREFIXO, "
    cSql += "    E5_NUMERO, "
    cSql += "    E5_PARCELA, "
    cSql += "    E5_CLIFOR, "
    cSql += "    E5_LOJA, "
    cSql += "    E5_TIPO "

    TCQUERY cSql NEW ALIAS "cEstorno"

    ConOut(cSql)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³gravar os valores com estornados   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("cEstorno")
    cEstorno->(DbGotop())

    nTotReg := Contar("cEstorno","!Eof()")
    
    ::oProcess:SetRegua2(nTotReg)

    cEstorno->(DbGotop())

    Do while ! cEstorno->(EOF())

        ::oProcess:IncRegua2("Carregando estornos...")
        
        DbSelectArea("SE1")
        DbSetOrder(1)
        DbSeek(xFilial("SE1")+cEstorno->E5_PREFIXO+cEstorno->E5_NUMERO+cEstorno->E5_PARCELA+cEstorno->E5_TIPO+cEstorno->E5_CLIFOR+cEstorno->E5_LOJA)
    
        If (::cAlias)->(dbSeek(cEstorno->E5_PREFIXO+cEstorno->E5_NUMERO+cEstorno->E5_PARCELA+cEstorno->E5_CLIFOR+cEstorno->E5_LOJA+cEstorno->E5_TIPO+cEstorno->VEND))
    
            Reclock((::cAlias),.F.)
            (::cAlias)->PREFIXO     := cEstorno->E5_PREFIXO
            (::cAlias)->NUMERO      := cEstorno->E5_NUMERO
            (::cAlias)->PARCELA     := cEstorno->E5_PARCELA
            (::cAlias)->CLIENTE     := cEstorno->E5_CLIFOR
            (::cAlias)->LOJA        := cEstorno->E5_LOJA
            (::cAlias)->NOME        := Posicione("SA1",1,XFILIAL("SA1")+cEstorno->E5_CLIFOR+cEstorno->E5_LOJA,"A1_NREDUZ")
            (::cAlias)->TIPO        := cEstorno->E5_TIPO
            (::cAlias)->DATAEXT     := SToD(cEstorno->E5_DATA)
            (::cAlias)->ESTORNO     += cEstorno->E5_VALOR                
            (::cAlias)->VEND 		:= cEstorno->VEND
            (::cAlias)->CFCOM       := SE1->E1_YCFCOM
            /*SE1->(DbSetOrder(1))
            If SE1->(DbSeek(xFilial("SE1")+cEstorno->E5_PREFIXO+cEstorno->E5_NUMERO+cEstorno->E5_PARCELA+cEstorno->E5_TIPO))
                (::cAlias)->VEND := SE1->E1_VEND1
            EndIf*/
            (::cAlias)->(MsUnlock())

        EndIf

    	cEstorno->(DbSkip())

    Enddo

    cEstorno->(DbCloseArea())

Return()

Method fComissao() Class BIA932A

    Local nTotReg := 0

    ::oProcess:IncRegua1("Processando comissao...")

    //titulos recebidos com comissao
    cSql := "SELECT SE3.E3_PREFIXO, SE3.E3_NUM, SE3.E3_PARCELA, SE3.E3_CODCLI, SE3.E3_LOJA, SE3.E3_TIPO, SE3.E3_EMISSAO, SE3.E3_VEND, SE3.E3_PORC, SE3.E3_COMIS, SE3.E3_BASE " + ENTER  
    cSql += "FROM "+RetSqlName("SE3")+" SE3 " + ENTER  
    cSql += "WHERE	SE3.E3_FILIAL= '"+XFilial("SE3")+"' " + ENTER  

    If cempant == "01"
        cSql += "	AND SE3.E3_PREFIXO IN ('01','S1','S1F','S2','1','2','3','4','NDI') " + ENTER  
    Else
        //cSql += "	AND SE3.E3_PREFIXO = '' " + ENTER  
        cSql += " AND SE3.E3_PREFIXO IN ('01','S1','','1','2','3','4','6','7','NDI') "  + ENTER
    EndIf

    cSql += "	AND SE3.E3_TIPO NOT IN ('NCC', 'DEV','CH') " + ENTER  
    cSql += "	AND SE3.E3_EMISSAO BETWEEN '"+DToS(::dDtBaixaDe)+"' AND '"+DToS(::dDtBaixaAte)+"' " + ENTER  
    cSql += "	AND SE3.E3_CODCLI BETWEEN '"+::cClienteDe+"' AND '"+::cClienteAte+"' " + ENTER  
    cSql += "	AND SE3.E3_LOJA BETWEEN '"+::cLojaDe+"' AND '"+::cLojaAte+"' " + ENTER  
    cSql += "	AND SE3.E3_VEND   BETWEEN '"+::cVendDe+"' AND '"+::cVendAte+"' " + ENTER  
    cSql += "	AND SE3.D_E_L_E_T_ = '' " + ENTER  
    //cSql += "	AND SE3.E3_NUM = '026084' " + ENTER  //RANISSES
    cSql += "ORDER BY SE3.E3_PREFIXO, SE3.E3_NUM, SE3.E3_PARCELA, SE3.E3_CODCLI, SE3.E3_LOJA, SE3.E3_TIPO " + ENTER  

    TCQUERY cSql NEW ALIAS "cComissao"

    ConOut(cSql)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³gravar os valores com comissoes    ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    DbSelectArea("cComissao")
    cComissao->(DbGotop())
    
    nTotReg := Contar("cComissao","!Eof()")
    
    ::oProcess:SetRegua2(nTotReg)

    cComissao->(DbGotop())
    
    Do while ! cComissao->(EOF())

        ::oProcess:IncRegua2("Carregando comissão...")

        lInclui := .T.                                                    

        DbSelectArea("SE1")
        DbSetOrder(1)

        DbSeek(xFilial("SE1")+cComissao->E3_PREFIXO+cComissao->E3_NUM+cComissao->E3_PARCELA+cComissao->E3_TIPO+cComissao->E3_CODCLI+cComissao->E3_LOJA)

        If (::cAlias)->(dbSeek(cComissao->E3_PREFIXO+cComissao->E3_NUM+cComissao->E3_PARCELA+cComissao->E3_CODCLI+cComissao->E3_LOJA+cComissao->E3_TIPO+cComissao->E3_VEND))
            lInclui := .F.
        EndIf

        Reclock((::cAlias),lInclui)
        (::cAlias)->PREFIXO     := cComissao->E3_PREFIXO
        (::cAlias)->NUMERO      := cComissao->E3_NUM
        (::cAlias)->PARCELA     := cComissao->E3_PARCELA
        (::cAlias)->CLIENTE     := cComissao->E3_CODCLI
        (::cAlias)->LOJA        := cComissao->E3_LOJA
        (::cAlias)->NOME        := Posicione("SA1",1,XFILIAL("SA1")+cComissao->E3_CODCLI+cComissao->E3_LOJA,"A1_NREDUZ")
        (::cAlias)->TIPO        := cComissao->E3_TIPO
        (::cAlias)->VEND        := cComissao->E3_VEND
        (::cAlias)->DATACOM     := SToD(cComissao->E3_EMISSAO)
        (::cAlias)->PERCOMIS    := cComissao->E3_PORC
        (::cAlias)->BASECALC    += cComissao->E3_BASE
        (::cAlias)->COMIS       += cComissao->E3_COMIS
        (::cAlias)->CFCOM       := SE1->E1_YCFCOM	
        (::cAlias)->(MsUnlock())
        cComissao->(DbSkip())
    
    Enddo
    
    cComissao->(DbCloseArea())

Return()

Method Relatorio() Class BIA932A

    ::Pergunte()

    ::Load()

    ::oReport:PrintDialog()

Return()

Method Pergunte() Class BIA932A

    Local lRet := .F.

    If Pergunte("BIA932", .T.)

        ::dDtBaixaDe  := mv_par01
        ::dDtBaixaAte := mv_par02
        ::cClienteDe  := mv_par03
        ::cLojaDe     := mv_par04
        ::cClienteAte := mv_par05
        ::cLojaAte    := mv_par06
        ::cVendDe     := mv_par07
        ::cVendAte    := mv_par08

        lRet := .T.

    EndIf

Return(lRet)

Method Imprimir() Class BIA932A

    Local _cCliImp,_cLojImp

    Local ntotrec:=0,ntotcom:=0,ngerrec:=0,ngercom:=0,ntotbas:=0,ngerbas:=0
    Local ntotrec1:=0,ntotcom1:=0,ntotbas1:=0
    Local ntotrec2:=0,ntotcom2:=0,ntotbas2:=0
    Local cSQL, cRecebido,nComisAnt:=0, cVendAnt, cEstorno, cTitulo, _acampos, cVendedor
    Local nrep1:=0, nrep2:=0, nrep3:=0

    //Variavel para filtro da Marca
    Local nMarca := ""

    Local nPosColCli := 1050
    Local nPosColVlr := 1350
    Local nPosColBas := 1550
    Local nPosColPer := 1850
    Local nPosColCom := 1950

    // imprimir titulos
    dbSelectArea((::cAlias))

    //cInd3 := CriaTrab(NIL,.F.)
    //IndRegua((::cAlias),cInd3,"PREFIXO+STR(PERCOMIS,6,2)+VEND+CLIENTE+LOJA",,,"Selecionando Registros...")

    (::cAlias)->(DBSetOrder(2))

    //SetRegua(RecCount())

    (::cAlias)->(DbGotop())

    //Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    
    ///::oSection1:Init()
    ::oSection2:Init()

    While !::oReport:Cancel() .And. !(::cAlias)->(EOF())

	    cPrfAnt := (::cAlias)->PREFIXO
	   
        While  !::oReport:Cancel() .And. !(::cAlias)->(EOF()) .And. (::cAlias)->PREFIXO == cPrfAnt

		    nComisAnt := (::cAlias)->PERCOMIS

            While  !::oReport:Cancel() .And. !(::cAlias)->(EOF()) .And. (::cAlias)->PREFIXO == cPrfAnt .And. (::cAlias)->PERCOMIS == nComisAnt

			    SA3->(DbSetOrder(1))
			    SA3->(DbSeek(xFilial("SA3")+(::cAlias)->VEND))

			    cVendAnt := (::cAlias)->VEND

                While  !::oReport:Cancel() .And. !(::cAlias)->(EOF()) .And. (::cAlias)->PREFIXO == cPrfAnt .And. (::cAlias)->PERCOMIS == nComisAnt .And. (::cAlias)->VEND == cVendAnt
				
                    //IncRegua()

                    If ::oReport:Cancel()
                    
                        Exit
                        
                    EndIf

                    ::oSection1:Init()

                    //ALTERACAO PARA BUSCA NOME DO CLIENTE ORIGINAL QUANDO LM - FERNANDO - 06/08/2010
                    _cCliImp	:= (::cAlias)->CLIENTE
                    _cLojImp    := (::cAlias)->LOJA

                    If (::cAlias)->CLIENTE == '010064'

				        //busca primeiro item da nota
					    SD2->(DbSetOrder(3))
                        
                        If SD2->(DbSeek(XFILIAL("SD2")+(::cAlias)->(NUMERO+PREFIXO+CLIENTE+LOJA)))

						    //busca primeiro pedido SC5 para obter o cliente original
						    SC5->(DbSetOrder(1))

                            If SC5->(DbSeek(XFilial("SC5")+SD2->D2_PEDIDO)) .And. (!Empty(SC5->C5_YCLIORI))
						 	
                                _cCliImp	:= SC5->C5_YCLIORI
						 	    _cLojImp    := SC5->C5_YLOJORI

                            EndIf

                        EndIf

                    EndIf
				
                    SA1->(DbSetOrder(1))
                    SA1->(DbSeek(xFilial("SA1")+_cCliImp+_cLojImp))

                    //@ Prow()+1,1      Psay (::cAlias)->PREFIXO + "-" + (::cAlias)->TIPO
                    //	@ Prow(),Pcol()+1 Psay Transform((::cAlias)->PERCOMIS, "@e 99.9") + "%"
                    //@ Prow(),Pcol()+1 Psay (::cAlias)->VEND
                    
                    //Define a Marca
                    If cEmpAnt == "07"
                    
                        If Alltrim((::cAlias)->PREFIXO) $ "1"
                            nMarca	:= "0101"
                        ElseIf Alltrim((::cAlias)->PREFIXO) $ "2"
                            nMarca	:= "0501"
                        ElseIf Alltrim((::cAlias)->PREFIXO) $ "3"
                            nMarca	:= "0599"
                        ElseIf Alltrim((::cAlias)->PREFIXO) $ "4"
                            nMarca	:= "1399"
                        ElseIf Alltrim((::cAlias)->PREFIXO) $ "6"
                            nMarca	:= "0199"
                        ElseIf Alltrim((::cAlias)->PREFIXO) $ "7"
                            nMarca	:= "1302"
                        EndIf

                    Else

                        nMarca	:= ""

                    EndIf
                    
                    //Busca informação na tabela de Rescisão
                    Z78->(DbSetOrder(2))

                    If Z78->(DbSeek(xFilial("Z78")+SA3->A3_COD+nMarca))
                        
                        //@ Prow(),Pcol()+1 Psay SUBSTR(SA3->A3_NOME,1,30) + Z78->Z78_MARCA + " - RESC: " + DTOC(Z78->Z78_DTRESC)

                        ::oSection1:Cell("NOME_VEND"):SetValue(SUBSTR(SA3->A3_NOME,1,30) + Z78->Z78_MARCA + " - RESC: " + DTOC(Z78->Z78_DTRESC))

                    Else

                        Z78->(DbSetOrder(1))	
                        
                        If Z78->(DbSeek(xFilial("Z78")+SA3->A3_COD))
                            
                            //@ Prow(),Pcol()+1 Psay SUBSTR(SA3->A3_NOME,1,30) + Z78->Z78_MARCA + " - RESC: " + DTOC(Z78->Z78_DTRESC)	
                            ::oSection1:Cell("NOME_VEND"):SetValue(SUBSTR(SA3->A3_NOME,1,30) + Z78->Z78_MARCA + " - RESC: " + DTOC(Z78->Z78_DTRESC))

                        Else

                            //@ Prow(),Pcol()+1 Psay SUBSTR(SA3->A3_NOME,1,30) + SPACE(21)
                            ::oSection1:Cell("NOME_VEND"):SetValue(SUBSTR(SA3->A3_NOME,1,30) + SPACE(21))

                        EndIf

                    EndIf
                    
                    //@ Prow(),Pcol()+1 Psay _cCliImp  //(::cAlias)->CLIENTE

                    ::oSection1:Cell("CLIENTE"):SetValue(_cCliImp)
                    ::oSection1:Cell("NOME"):SetValue(SUBSTR(SA1->A1_NREDUZ,1,50))
                    ::oSection1:Cell("VALOR"):SetValue((::cAlias)->VALOR - (::cAlias)->ESTORNO)

                    //@ Prow(),Pcol()+1 Psay SUBSTR(SA1->A1_NOME,1,50)
                    //@ Prow(),Pcol()+1 Psay Alltrim((::cAlias)->NUMERO)
                    //@ Prow(),Pcol()+1 Psay (::cAlias)->PARCELA //Iif((::cAlias)->E1_SALDO=0,"B","A")
                    //@ Prow(),Pcol()+2 Psay (::cAlias)->DATATIT
                    //@ Prow(),Pcol()+1 Psay Transform(((::cAlias)->VALOR - (::cAlias)->ESTORNO),"@E 999,999,999.99") 	//valor recebido
                    //@ Prow(),Pcol()+2 Psay Transform((::cAlias)->BASECALC,"@E 999,999,999.99") 							//BASE DE CALCULO DA COMISSAO
                    //@ Prow(),Pcol()+3 Psay Transform((::cAlias)->PERCOMIS, "@E 99.99") +"%" 							//PERCENTUAL COMISSAO
                    //@ Prow(),Pcol()+2 Psay Transform((::cAlias)->COMIS,"@E 999,999,999.99") 							//VALOR DA COMISSAO 

                    //::oSection1:PrintLine()
                                
                    //::oSection1:Finish()
                    
                    If (::cAlias)->CFCOM == 'S'
                        
                        //@ Prow(),Pcol()+2 Psay 'X'
                        
                        //::oSection1:Cell("CFCOM"):SetValue("X")

                    EndIf

                    ::oSection1:PrintLine()

                    ntotrec += ((::cAlias)->VALOR - (::cAlias)->ESTORNO)
                    ntotcom += (::cAlias)->COMIS

                    ntotbas += Iif(!Subst((::cAlias)->VEND,1,1)$"1_2",(::cAlias)->BASECALC,0)

                    DbSelectArea((::cAliasVend))
                    DbSetOrder(1)
                    
                    If !(::cAliasVend)->(DbSeek((::cAlias)->VEND))
                        Reclock((::cAliasVend),.t.)
                    Else
                        Reclock((::cAliasVend),.f.)
                    EndIf

                    (::cAliasVend)->CODIGO   := (::cAlias)->VEND
                    (::cAliasVend)->VALOR    += ((::cAlias)->VALOR - (::cAlias)->ESTORNO)
                    (::cAliasVend)->BASE     += Iif(!Subst((::cAlias)->VEND,1,1)$"1_2",(::cAlias)->BASECALC,0)
                    (::cAliasVend)->COMISSAO += (::cAlias)->COMIS
                    (::cAliasVend)->(MsUnlock())
                
                    //If Prow() >= 60
                    //    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                    //EndIf

                    (::cAlias)->(DbSkip())

                EndDo //vendedor

                //@ Prow()+1,70 Psay Repli("-",148)
                //@ Prow()+1,70 Psay "Total do Representante "+SUBSTR(SA3->A3_NOME,1,30)
                //@ Prow(),148  Psay Transform(ntotrec,"@E 999,999,999.99")
                //@ Prow(),164  Psay Transform(ntotbas,"@E 999,999,999.99")
                //@ Prow(),181  Psay Transform(Round((ntotcom / ntotbas * 100),1) , "@E 99.99") +"%"
                //@ Prow(),189  Psay Transform(ntotcom,"@E 999,999,999.99")
                //@ Prow()+1,0  Psay ""
                
                 
                ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
                ::oReport:SkipLine(1)
                 
                //::oSection2:Cell("TOTAL1"	):SetAlign(1)
               // ::oSection2:Cell("TOTAL2"	):SetAlign(1)
              //  ::oSection2:Cell("TOTAL3"	):SetAlign(1)
              //  ::oSection2:Cell("TOTAL4"	):SetAlign(1)
                
                //::oSection2:Cell("VAZIO"		):SetValue("")
                ::oSection2:Cell("DESCRICAO"	):SetValue("Total do Representante " + SUBSTR(SA3->A3_NOME,1,30))
                ::oSection2:Cell("TOTAL1"		):SetValue(Transform(ntotrec,"@E 999,999,999.99"))
                ::oSection2:Cell("TOTAL2"		):SetValue(Transform(ntotbas,"@E 999,999,999.99"))
                ::oSection2:Cell("TOTAL3"		):SetValue(Transform(Round((ntotcom / ntotbas * 100),1) , "@E 99.99")) /*+ "%"*/
                ::oSection2:Cell("TOTAL4"		):SetValue(Transform(ntotcom,"@E 999,999,999.99"))
                
                ::oSection2:PrintLine()
                
                If ((::cAlias)->PREFIXO == cPrfAnt .And. (::cAlias)->PERCOMIS == nComisAnt)
                	 ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
                	 ::oReport:SkipLine(1)
                EndIf
                
                //::oReport:SkipLine(1)
                //::oReport:SkipLine(1)
                
               // ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
                //::oReport:SkipLine(1)
                
		        
                /*::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
                ::oReport:SkipLine(1)

                ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), "Total do Representante " + SUBSTR(SA3->A3_NOME,1,30))

                ::oReport:Say(::oReport:Row(), nPosColCli + nPosColVlr + ::oReport:Col(), Transform(ntotrec,"@E 999,999,999.99"))
                ::oReport:Say(::oReport:Row(), nPosColCli + nPosColBas + ::oReport:Col(), Transform(ntotbas,"@E 999,999,999.99"))
                ::oReport:Say(::oReport:Row(), nPosColCli + nPosColPer + ::oReport:Col(), Transform(Round((ntotcom / ntotbas * 100),1) , "@E 99.99") + "%")
                ::oReport:Say(::oReport:Row(), nPosColCli + nPosColCom + ::oReport:Col(), Transform(ntotcom,"@E 999,999,999.99"))
                
                ::oReport:SkipLine(1)
                ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
                ::oReport:SkipLine(1)*/

                ngerrec += ntotrec
                ngercom += ntotcom
                ngerbas += ntotbas
                ntotrec1 += ntotrec
                ntotcom1 += ntotcom
                ntotbas1 += ntotbas
                ntotrec2 += ntotrec
                ntotcom2 += ntotcom
                ntotbas2 += ntotbas

                ntotrec := 0
                ntotcom := 0
                ntotbas := 0

            EndDo //comissao

            //@ Prow()+1,70 Psay Repli("-",148)
            //@ Prow()+1,70 Psay "Total da comissao "+Transform(nComisAnt,"@e 99.99")+"%"
            //@ Prow(),148  Psay Transform(ntotrec1,"@E 999,999,999.99")
            //@ Prow(),164  Psay Transform(ntotbas1,"@E 999,999,999.99")
            //@ Prow(),181  Psay Transform(Round((ntotcom1 / ntotbas1 * 100),1) , "@E 99.99") +"%"
            //@ Prow(),189  Psay Transform(ntotcom1,"@E 999,999,999.99")
            //@ Prow()+1,0  Psay ""

            ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
            ::oReport:SkipLine(1)
            
           // ::oSection2:Cell("TOTAL1"	):SetAlign(1)
          //  ::oSection2:Cell("TOTAL2"	):SetAlign(1)
           // ::oSection2:Cell("TOTAL3"	):SetAlign(1)
          //  ::oSection2:Cell("TOTAL4"	):SetAlign(1)
            
           // ::oSection2:Cell("VAZIO"		):SetValue("")
            ::oSection2:Cell("DESCRICAO"	):SetValue("Total da comissao "+Transform(nComisAnt,"@e 99.99"))
            ::oSection2:Cell("TOTAL1"		):SetValue(Transform(ntotrec1,"@E 999,999,999.99"))
            ::oSection2:Cell("TOTAL2"		):SetValue(Transform(ntotbas1,"@E 999,999,999.99"))
            ::oSection2:Cell("TOTAL3"		):SetValue(Transform(Round((ntotcom1 / ntotbas1 * 100),1) , "@E 99.99") )/*+ "%"*/
            ::oSection2:Cell("TOTAL4"		):SetValue(Transform(ntotcom1,"@E 999,999,999.99"))
            
            ::oSection2:PrintLine()
            
            //::oReport:SkipLine(1)
            ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
            ::oReport:SkipLine(1)
            
            /*::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
            ::oReport:SkipLine(1)
            ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), "Total da comissao "+Transform(nComisAnt,"@e 99.99"))
            ::oReport:Say(::oReport:Row(), nPosColCli + nPosColVlr + ::oReport:Col(), Transform(ntotrec1,"@E 999,999,999.99"))
            ::oReport:Say(::oReport:Row(), nPosColCli + nPosColBas + ::oReport:Col(), Transform(ntotbas1,"@E 999,999,999.99"))
            ::oReport:Say(::oReport:Row(), nPosColCli + nPosColPer + ::oReport:Col(), Transform(Round((ntotcom1 / ntotbas1 * 100),1) , "@E 99.99") + "%")
            ::oReport:Say(::oReport:Row(), nPosColCli + nPosColCom + ::oReport:Col(), Transform(ntotcom1,"@E 999,999,999.99") )
            
            ::oReport:SkipLine(1)
            ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
            ::oReport:SkipLine(1)
            
            */

            ntotrec1 := 0
            ntotcom1 := 0
            ntotbas1 := 0
    
        EndDo //prefixo
	
        //@ Prow()+1,70 Psay Repli("-",148)
        //@ Prow()+1,70 Psay "Total da Serie "+cPrfAnt
        //@ Prow(),162  Psay Transform(ntotrec2,"@E 999,999,999.99")
        //@ Prow(),178  Psay Transform(ntotbas2,"@E 999,999,999.99")
        //@ Prow(),195  Psay Transform(Round((ntotcom2 / ntotbas2 * 100),1) , "@E 99.99") +"%"
        //@ Prow(),204  Psay Transform(ntotcom2,"@E 999,999,999.99")
        //@ Prow()+1,0  Psay ""

        	::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
            ::oReport:SkipLine(1)
            //::oSection2:Cell("TOTAL1"	):SetAlign(1)
            //::oSection2:Cell("TOTAL2"	):SetAlign(1)
            //::oSection2:Cell("TOTAL3"	):SetAlign(1)
            //::oSection2:Cell("TOTAL4"	):SetAlign(1)
            
            //::oSection2:Cell("VAZIO"		):SetValue("")
            ::oSection2:Cell("DESCRICAO"	):SetValue("Total da Serie " + cPrfAnt)
            ::oSection2:Cell("TOTAL1"		):SetValue(Transform(ntotrec2,"@E 999,999,999.99"))
            ::oSection2:Cell("TOTAL2"		):SetValue(Transform(ntotbas2,"@E 999,999,999.99"))
            ::oSection2:Cell("TOTAL3"		):SetValue(Transform(Round((ntotcom2 / ntotbas2 * 100),1) , "@E 99.99") )/*+ "%"*/
            ::oSection2:Cell("TOTAL4"		):SetValue(Transform(ntotcom2,"@E 999,999,999.99"))
            ::oSection2:PrintLine()
            ::oReport:SkipLine(1)
            //::oReport:SkipLine(1)
            
	       /* ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
	        ::oReport:SkipLine(1)
	        ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), "Total da Serie " + cPrfAnt) 
	        ::oReport:Say(::oReport:Row(), nPosColCli + nPosColVlr + ::oReport:Col(), Transform(ntotrec2,"@E 999,999,999.99"))
	        ::oReport:Say(::oReport:Row(), nPosColCli + nPosColBas + ::oReport:Col(), Transform(ntotbas2,"@E 999,999,999.99")) 
	        ::oReport:Say(::oReport:Row(), nPosColCli + nPosColPer + ::oReport:Col(), Transform(Round((ntotcom2 / ntotbas2 * 100),1) , "@E 99.99") + "%") 
	        ::oReport:Say(::oReport:Row(), nPosColCli + nPosColCom + ::oReport:Col(), Transform(ntotcom2,"@E 999,999,999.99") )
	        ::oReport:SkipLine(1)*/

        ntotrec2 := 0
        ntotcom2 := 0
        ntotbas2 := 0

    EndDo

    //@ Prow()+1,84 Psay Repli("-",135)
    //@ Prow()+1,84 Psay "TOTAL GERAL "
    //@ Prow(),162  Psay Transform(ngerrec,"@E 999,999,999.99")
    //@ Prow(),178  Psay Transform(ngerbas,"@E 999,999,999.99")
    //@ Prow(),195  Psay Transform(Round((ngercom / ngerbas * 100),1) , "@E 99.99") +"%"
    //@ Prow(),204  Psay Transform(ngercom,"@E 999,999,999.99")
    //@ Prow()+1,84 Psay Repli("-",135)

    
    ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
    ::oReport:SkipLine(1)
    //::oSection2:Cell("TOTAL1"	):SetAlign(1)
    //::oSection2:Cell("TOTAL2"	):SetAlign(1)
    //::oSection2:Cell("TOTAL3"	):SetAlign(1)
    //::oSection2:Cell("TOTAL4"	):SetAlign(1)
    
    //::oSection2:Cell("VAZIO"		):SetValue("")
    ::oSection2:Cell("DESCRICAO"	):SetValue("TOTAL GERAL ")
    ::oSection2:Cell("TOTAL1"		):SetValue(Transform(ngerrec,"@E 999,999,999.99"))
    ::oSection2:Cell("TOTAL2"		):SetValue(Transform(ngerbas,"@E 999,999,999.99"))
    ::oSection2:Cell("TOTAL3"		):SetValue(Transform(Round((ngercom / ngerbas * 100),1) , "@E 99.99"))
    ::oSection2:Cell("TOTAL4"		):SetValue(Transform(ngercom,"@E 999,999,999.99"))
    ::oSection2:PrintLine()
    ::oReport:SkipLine(1)
    
    //::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
    //::oReport:SkipLine(1)
    
    
    /*::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
    ::oReport:SkipLine(1)    
    ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), "TOTAL GERAL ")
    ::oReport:Say(::oReport:Row(), nPosColCli + nPosColVlr + ::oReport:Col(), Transform(ngerrec,"@E 999,999,999.99"))
    ::oReport:Say(::oReport:Row(), nPosColCli + nPosColBas + ::oReport:Col(), Transform(ngerbas,"@E 999,999,999.99")) 
    ::oReport:Say(::oReport:Row(), nPosColCli + nPosColPer + ::oReport:Col(), Transform(Round((ngercom / ngerbas * 100),1) , "@E 99.99")) 
    ::oReport:Say(::oReport:Row(), nPosColCli + nPosColCom + ::oReport:Col(), Transform(ngercom,"@E 999,999,999.99"))
    
    ::oReport:SkipLine(1)
    ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
    ::oReport:SkipLine(1)
    
    */

    DbSelectArea((::cAliasVend))
    DbGotop()

    //If 60 - Prow() < RecCount((::cAliasVend))
    //    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    //EndIf

    //@ Prow()+1,1 Psay Repli("-",220)
    //@ Prow()+1,1 Psay "Representante                                                        Vr. Recebido          Vr. Base    %Comis      Valor Comissao"
    //@ Prow()+1,1 Psay Repli("-",220)

    //::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",220) )
    //::oReport:SkipLine(1)

    //::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), "Representante                                                        Vr. Recebido          Vr. Base    %Comis      Valor Comissao" )
    //::oReport:SkipLine(1)

    //::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",220) )
    //::oReport:SkipLine(1)

    Do while !(::cAliasVend)->(eof())

        SA3->(DbSetOrder(1))
        SA3->(DbSeek(xFilial("SA3")+(::cAliasVend)->CODIGO))

        //@ Prow()+1,1      Psay SUBSTR(SA3->A3_NOME,1,30)
        //@ Prow(),Pcol()+7 Psay Transform((::cAliasVend)->VALOR,"@E 999,999,999.99")
        //@ Prow(),Pcol()+4 Psay Transform((::cAliasVend)->BASE,"@E 999,999,999.99")
        //@ Prow(),Pcol()+3 Psay Transform(Round(((::cAliasVend)->COMISSAO / (::cAliasVend)->BASE * 100),1) , "@E 99.99") +"%"
        //@ Prow(),Pcol()+6 Psay Transform((::cAliasVend)->COMISSAO,"@E 999,999,999.99")

        //::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
        //::oReport:SkipLine(1)
       // ::oSection2:Cell("TOTAL1"	):SetAlign(1)
	   // ::oSection2:Cell("TOTAL2"	):SetAlign(1)
	   // ::oSection2:Cell("TOTAL3"	):SetAlign(1)
	   // ::oSection2:Cell("TOTAL4"	):SetAlign(1)
	    
	    //::oSection2:Cell("VAZIO"		):SetValue("")
	    ::oSection2:Cell("DESCRICAO"	):SetValue(SUBSTR(SA3->A3_NOME,1,30))
	    ::oSection2:Cell("TOTAL1"		):SetValue(Transform((::cAliasVend)->VALOR,"@E 999,999,999.99"))
	    ::oSection2:Cell("TOTAL2"		):SetValue(Transform((::cAliasVend)->BASE,"@E 999,999,999.99"))
	    ::oSection2:Cell("TOTAL3"		):SetValue(Transform(Round(((::cAliasVend)->COMISSAO / (::cAliasVend)->BASE * 100),1) , "@E 99.99"))
	    ::oSection2:Cell("TOTAL4"		):SetValue(Transform((::cAliasVend)->COMISSAO,"@E 999,999,999.99"))
	    ::oSection2:PrintLine()
	   // ::oReport:SkipLine(1)
	    
	    
        
        /*::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), SUBSTR(SA3->A3_NOME,1,30))
        ::oReport:Say(::oReport:Row(), nPosColCli + nPosColVlr + ::oReport:Col(), Transform((::cAliasVend)->VALOR,"@E 999,999,999.99"))
        ::oReport:Say(::oReport:Row(), nPosColCli + nPosColBas + ::oReport:Col(), Transform((::cAliasVend)->BASE,"@E 999,999,999.99"))
        ::oReport:Say(::oReport:Row(), nPosColCli + nPosColPer + ::oReport:Col(), Transform(Round(((::cAliasVend)->COMISSAO / (::cAliasVend)->BASE * 100),1) , "@E 99.99"))
        ::oReport:Say(::oReport:Row(), nPosColCli + nPosColCom + ::oReport:Col(), Transform((::cAliasVend)->COMISSAO,"@E 999,999,999.99"))
        ::oReport:SkipLine(1)
        */

        nrep1 += (::cAliasVend)->VALOR
        nrep2 += (::cAliasVend)->BASE
        nrep3 += (::cAliasVend)->COMISSAO

        (::cAliasVend)->(Dbskip())

    EndDo

    //@ Prow()+1,1 Psay Repli("-",220)
    //@ Prow()+1,1      Psay "TOTAL"
    //@ Prow(),68       Psay Transform(nrep1,"@E 999,999,999.99")
    //@ Prow(),Pcol()+4 Psay Transform(nrep2,"@E 999,999,999.99")
    //@ Prow(),Pcol()+3 Psay Transform(Round((nrep3 / nrep2 * 100),1) , "@E 99.99") +"%"
    //@ Prow(),Pcol()+6 Psay Transform(nrep3,"@E 999,999,999.99")
    //@ Prow()+1,1 Psay Repli("-",220)
    //@ Prow()+1,1 Psay "*OBS.: Os totais das colunas 'Vl. Recebido' e 'Vl Base', para os SUPERVISORES, não serão considerados nos Totais e Sub-Totais do Relatório"

    
     ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170) )
     ::oReport:SkipLine(1)
     
    //::oSection2:Cell("VAZIO"		):SetValue("")
    ::oSection2:Cell("DESCRICAO"	):SetValue("TOTAL")
    ::oSection2:Cell("TOTAL1"		):SetValue(Transform(nrep1,"@E 999,999,999.99"))
    ::oSection2:Cell("TOTAL2"		):SetValue(Transform(nrep2,"@E 999,999,999.99"))
    ::oSection2:Cell("TOTAL3"		):SetValue(Transform(Round((nrep3 / nrep2 * 100), 1) , "@E 99.99") + "%")
    ::oSection2:Cell("TOTAL4"		):SetValue(Transform(nrep3,"@E 999,999,999.99"))
    ::oSection2:PrintLine()
    ::oReport:SkipLine(1)
	    
    /*::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170))
    ::oReport:SkipLine(1)

    ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), "TOTAL")
    ::oReport:Say(::oReport:Row(), nPosColCli + nPosColVlr + ::oReport:Col(), Transform(nrep1,"@E 999,999,999.99"))
    ::oReport:Say(::oReport:Row(), nPosColCli + nPosColBas + ::oReport:Col(), Transform(nrep2,"@E 999,999,999.99"))
    ::oReport:Say(::oReport:Row(), nPosColCli + nPosColPer + ::oReport:Col(), Transform(Round((nrep3 / nrep2 * 100), 1) , "@E 99.99") + "%") 
    ::oReport:Say(::oReport:Row(), nPosColCli + nPosColCom + ::oReport:Col(), Transform(nrep3,"@E 999,999,999.99"))
    ::oReport:SkipLine(1)
    */
    ::oReport:Say(::oReport:Row(), nPosColCli + ::oReport:Col(), Repli("-",170))
    ::oReport:SkipLine(1)

    ::oReport:Say(::oReport:Row(), ::oReport:Col(), "*OBS.: Os totais das colunas 'Vl. Recebido' e 'Vl Base', para os SUPERVISORES, não serão considerados nos Totais e Sub-Totais do Relatório")
    ::oReport:SkipLine(1)
    
    (::cAlias)->(DbCloseArea())
    (::cAliasVend)->(DbCloseArea())
    
    ::oReport:SkipLine(1)
    ::oReport:SkipLine(1)
    

	
	//::oSection1:Finish()
	::oSection2:Finish()
	
Return()

User Function BIA932A()

    Local oObj := BIA932A():New()

    oObj:Relatorio()

Return()