#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPOSEST          บAutor  ณBRUNO MADALENO      บ Data ณ  15/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRelatorio em Crystal PARA CHECAR A POSICAO DO ESTOQUE             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function POSEST(lOpc)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
Private cSQL
Private Enter := CHR(13)+CHR(10) 
lEnd       := .F.
cString    := ""
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "de acordo com os parametros informados pelo usuario."
cDesc3     := "Posi็ใo de Estoque"
cTamanho   := ""
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "POSEST" 

If lOpc
	cPerg      := "POSEST2"   //IMPRESSAO DE LOGINS QUE EMPENHARAM  LOTE
Else
	cPerg      := "POSEST"
EndIf                    

aLinha     := {}
nLastKey   := 0
cTitulo	   := "POSIวรO DE ESTOQUE"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "POSEST"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT.								     ณ
//ณ Verifica Posicao do Formulario na Impressora.				             ณ
//ณ Solicita os parametros para a emissao do relatorio			             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 

pergunte(cPerg,.F.)
wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
//Cancela a impressao
If nLastKey == 27
	Return
Endif

cProd	  	:= ""
i 				:= 1
cPontEst	:= MV_PAR01
cClasse		:= MV_PAR02
cFiltra		:= MV_PAR03
//Monta a string para passar para a query
If cFiltra = 1
	do while i <= len(ALLTRIM(MV_PAR04))
		cProd += "'" + SUBS(MV_PAR04,i,2) + "'" + ","
		i++
		//i++
	end do
	cProd := SUBS(cProd,1, LEN(cProd)-1 )
end if   

If !lOpc
	cImpri		:= MV_PAR05
EndIf


If Alltrim(cEmpAnt) == "01"
		nTabela	:= Tabela("ZF","1E")
ElseIf Alltrim(cEmpAnt) == "05"
	If MV_PAR06 == 1
		nTabela	:= Tabela("ZF","2E")
	Else
		nTabela	:= Tabela("ZF","3E")
	EndIf
EndIf
    
//*************************************************************************
//*************************************************************************
//View para trazer as informacoes doS LIMITES DE CREDITO
//*************************************************************************
//*************************************************************************
cSQL := "" 
cSQL := "ALTER VIEW PONTA_EST AS " + Enter
cSQL += "SELECT BF_PRODUTO, 
cSQL += "				BF_LOTECTL = CASE WHEN ZZ9.ZZ9_RESTRI = '*' THEN RTRIM(SBF.BF_LOTECTL)+ZZ9.ZZ9_RESTRI ELSE SBF.BF_LOTECTL END,	" + Enter
cSQL += "				BF_LOCAL, BF_LOCALIZ,B1_DESC, B1_GRUPO, B1_TIPO, SUM(BF_QUANT) BF_QUANT, SUM(BF_EMPENHO) BF_EMPENHO, ISNULL((SELECT AVG(DA1_PRCVEN) " + Enter
cSQL += "FROM " + RetSqlName("DA0") + " DA0, " + RetSqlName("DA1") + " DA1 " + Enter
cSQL += "WHERE	DA0.DA0_FILIAL	= '" + xFilial("DA0") + "'	AND " + Enter
cSQL += "		DA1.DA1_FILIAL	= '" + xFilial("DA1") + "'	AND " + Enter
cSQL += "		DA0.DA0_CODTAB	= DA1.DA1_CODTAB AND  " + Enter
cSQL += "		DA0.DA0_CODTAB	= '"+nTabela+"' AND  " + Enter
cSQL += "		DA0.DA0_ATIVO	= '1'	AND " + Enter
cSQL += "		DA1.DA1_CODPRO	= SBF.BF_PRODUTO AND " + Enter
cSQL += "		((DA1.DA1_ESTADO	= '' AND DA1.DA1_TPOPER = '1') OR DA1.DA1_ESTADO = 'ES') AND " + Enter
cSQL += "		CONVERT(VARCHAR(10), GETDATE(), 112) >= DA0.DA0_DATDE	AND " + Enter
cSQL += "		CONVERT(VARCHAR(10), GETDATE(), 112) <= DA0.DA0_DATATE	AND  " + Enter
cSQL += "		DA0.D_E_L_E_T_	= ''	AND " + Enter
cSQL += "		DA1.D_E_L_E_T_	= ''),0) VALOR_ES, " + Enter
cSQL += "ISNULL((SELECT AVG(DA1_PRCVEN) " + Enter
cSQL += "FROM " + RetSqlName("DA0") + " DA0, " + RetSqlName("DA1") + " DA1 " + Enter
cSQL += "WHERE	DA0.DA0_FILIAL	= '" + xFilial("DA0") + "'	AND " + Enter
cSQL += "		DA1.DA1_FILIAL	= '" + xFilial("DA1") + "'	AND " + Enter
cSQL += "		DA0.DA0_CODTAB	= DA1.DA1_CODTAB AND  " + Enter
cSQL += "		DA0.DA0_CODTAB	= '"+nTabela+"' AND  " + Enter
cSQL += "		DA0.DA0_ATIVO	= '1'	AND " + Enter
cSQL += "		DA1.DA1_CODPRO	= SBF.BF_PRODUTO AND " + Enter
cSQL += "		((DA1.DA1_ESTADO	= '' AND DA1.DA1_TPOPER = '2') OR DA1.DA1_ESTADO = 'OU') AND " + Enter
cSQL += "		CONVERT(VARCHAR(10), GETDATE(), 112) >= DA0.DA0_DATDE	AND " + Enter
cSQL += "		CONVERT(VARCHAR(10), GETDATE(), 112) <= DA0.DA0_DATATE	AND " + Enter
cSQL += "		DA0.D_E_L_E_T_	= ''	AND " + Enter
cSQL += "		DA1.D_E_L_E_T_	= ''),0) VALOR_FORA " + Enter
cSQL += "FROM "+RetSqlName("SB1")+" SB1, "+RetSqlName("SBF")+" SBF, "+RetSqlName("ZZ9")+" ZZ9 " + Enter
cSQL += "WHERE	SB1.B1_COD		= SBF.BF_PRODUTO	AND " + Enter
cSQL += "		SBF.BF_PRODUTO  = ZZ9.ZZ9_PRODUT	AND " + Enter
cSQL += "		SBF.BF_LOTECTL  = ZZ9.ZZ9_LOTE		AND " + Enter
cSQL += "		SB1.B1_GRUPO	= 'PA'				AND " + Enter
cSQL += "		SB1.B1_TIPO		= 'PA'				AND " + Enter
cSQL += "		SBF.BF_QUANT	<> 0 				AND " + Enter
If MV_PAR02 <> 4
	cSQL += "		SB1.B1_YCLASSE  = '"+ ALLTRIM(STR(cClasse)) +"'	AND  " + Enter // Classe
EndIf
If cFiltra == 1 .And. !Empty(cProd)
	cSQL += "		SB1.B1_YFORMAT IN ("+ cProd +")	AND " + Enter // Produto
EndIf	
cSQL += "		SB1.D_E_L_E_T_ = ''	AND " + Enter
cSQL += "		SBF.D_E_L_E_T_ = '' AND " + Enter
cSQL += "		ZZ9.D_E_L_E_T_ = ''     " + Enter  
cSQL += "GROUP BY BF_PRODUTO, BF_LOTECTL, ZZ9_RESTRI, BF_LOCAL, BF_LOCALIZ, B1_DESC, B1_GRUPO, B1_TIPO " + Enter 
cSQL += "HAVING SUM(SBF.BF_QUANT) <= '"+ cPontEst +"'	" + Enter // Ponta de Estoque
TcSQLExec(cSQL)    

If lOpc
	U_POSEST2()
Else
	If aReturn[5]==1
		//Parametros Crystal Em Disco
		cOpcao:="1;0;1;Apuracao"
	Else
		//Direto Impressora
		cOpcao:="3;0;1;Apuracao"
	Endif   
	callcrys("Ponest4",ALLTRIM(Str(cImpri))+";"+cEmpant,cOpcao)
EndIf

Return         

/*
##############################################################################################################
# PROGRAMA...: POSEST2         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 25/11/2013                      
# DESCRICAO..: Relatorio de Impressao de Usuarios que empenhou lotes utilizando a view da funcao anterior
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function POSEST2()

Local oReport

oReport:= ReportDef()
oReport:PrintDialog()

Return NIL   

/*
##############################################################################################################
# PROGRAMA...: ReportDef         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 25/11/2013                      
# DESCRICAO..: Montagem do relatorio
##############################################################################################################
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local cTitle    := "Login x Empenho"
Local cQryRel   := ""
//Private cPerg   :="POSEST"
//#IFDEF TOP
//	cQryRel := GetNextAlias()
//#ENDIF

oReport:= TReport():New("POSEST",cTitle,, {|oReport| ReportPrint(oReport,cQryRel)},"Login x Empenho") 
//oReport:= TReport():New("POSEST2",cTitle,cPerg, {|oReport| ReportPrint(oReport,cQryRel)},"Login x Empenho") 
oReport:SetLandscape() //Define a orientacao de pagina do relatorio como paisagem.
Pergunte(oReport:GetParam(),.F.)


//DEFINICAO DE FONTES
Private oFont1	 := TFont():New( "Arial"/*<cName>*/, 8 /*<nWidth>*/, -8/*<nHeight>*/, /*<.from.>*/, .T./*[<.bold.>]*/, /*<nEscapement>*/, , /*<nWeight>*/, /*[<.italic.>]*/, /*[<.underline.>]*/,,,,,, /*[<oDevice>]*/ )
Private oFont2	 := TFont():New( "Arial"/*<cName>*/, /*<nWidth>*/, -11/*<nHeight>*/, /*<.from.>*/, /*[<.bold.>]*/, /*<nEscapement>*/, , /*<nWeight>*/, /*[<.italic.>]*/, /*[<.underline.>]*/,,,,,, /*[<oDevice>]*/ )
Private oFont3	 := TFont():New( "Arial"/*<cName>*/, /*<nWidth>*/, -12/*<nHeight>*/, /*<.from.>*/, /*[<.bold.>]*/, /*<nEscapement>*/, , /*<nWeight>*/, /*[<.italic.>]*/, /*[<.underline.>]*/,,,,,, /*[<oDevice>]*/ )


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ oSection1 							                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oSection1 := TRSection():New(oReport,"Login x Empenho",{"SBF","SB1"},/*Ordem*/) 
//oSection1:SetLineStyle()
oSection1:SetHeaderPage()

TRCell():New(oSection1,'BF_PRODUTO'   	,'SBF',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'BF_LOTECTL'		,'SBF',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_DESC' 		,'SB1',/*Titulo*/,/*Picture*/,130/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_GRUPO'	   	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'B1_TIPO'	   	,'SB1',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'BF_QUANT'	   	,'SBF',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'BF_EMPENHO'	 	,'SBF',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'USERLGI'   		,,'Login Inclusao'/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'DT_INCLUSAO'	,,'Dt. Inclusao'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)     
TRCell():New(oSection1,'USERLGA'   		,,'Login Alteracao'/*Titulo*/,/*Picture*/,50/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,'DT_ALTERACAO'   ,,'Dt. Alteracao'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
 
oSection1:Cell('BF_PRODUTO'    	):oFontBody := oFont1
oSection1:Cell('BF_LOTECTL'   	):oFontBody := oFont1
oSection1:Cell('B1_DESC'  		):oFontBody := oFont1
oSection1:Cell('B1_GRUPO'   	):oFontBody := oFont1
oSection1:Cell('B1_TIPO'    	):oFontBody := oFont1
oSection1:Cell('BF_QUANT'  		):oFontBody := oFont1
oSection1:Cell('BF_EMPENHO' 	):oFontBody := oFont1
oSection1:Cell('USERLGI' 		):oFontBody := oFont1
oSection1:Cell('USERLGA'    	):oFontBody := oFont1
oSection1:Cell('DT_INCLUSAO'   	):oFontBody := oFont1
oSection1:Cell('DT_ALTERACAO'  	):oFontBody := oFont1

Return(oReport)                                      

/*
##############################################################################################################
# PROGRAMA...: ReportPrint         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 25/11/2013                      
# DESCRICAO..: Montagem do Fluxo de Impressao do relatorio
##############################################################################################################
*/
Static Function ReportPrint(oReport, cQryRel)
Local oSection1   := oReport:Section(1)                 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณQuery do relatorio                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQryRel := "SELECT * FROM PONTA_EST "

TCQUERY cQryRel ALIAS QRY NEW   

dbSelectArea("QRY")

oReport:SetMeter( QRY->(LastRec()) )
oSection1:Init()
While !oReport:Cancel() .And. !QRY->(Eof())  

	oSection1:Cell('BF_PRODUTO'    	):SetValue(QRY->BF_PRODUTO)
	oSection1:Cell('BF_LOTECTL'   	):SetValue(QRY->BF_LOTECTL)
	oSection1:Cell('B1_DESC'  		):SetValue(QRY->B1_DESC)
	oSection1:Cell('B1_GRUPO'   	):SetValue(QRY->B1_GRUPO)
	oSection1:Cell('B1_TIPO'    	):SetValue(QRY->BF_PRODUTO)
	oSection1:Cell('BF_QUANT'  		):SetValue(QRY->BF_QUANT)
	oSection1:Cell('BF_EMPENHO' 	):SetValue(QRY->BF_EMPENHO)  
	BuscaLogin(oReport)

	oSection1:PrintLine() //-- Impressao da secao 1
	QRY->(dbSkip())
EndDo     

oSection1:Finish()
QRY->(DbCloseArea())

Return Nil        

/*
##############################################################################################################
# PROGRAMA...: BuscaLogin         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 25/11/2013                      
# DESCRICAO..: Query de consulta do login nos campos DC_USERLGI, DC_USERLGA
##############################################################################################################
*/
Static Function BuscaLogin(oReport)
Local oSection1   := oReport:Section(1) 
Local cQry

	cQry := "SELECT TOP (1) * FROM " + RetSqlName("SDC") + " SDC " +enter
	cQry += " WHERE DC_PRODUTO = '"+QRY->BF_PRODUTO+"' AND DC_LOCAL = '"+QRY->BF_LOCAL+"' AND DC_LOCALIZ = '"+QRY->BF_LOCALIZ+"' "+enter                                            
    cQry += " AND DC_LOTECTL = '"+STRTRAN(QRY->BF_LOTECTL,'*')+"' "    
	cQry +=" AND SDC.D_E_L_E_T_='' "   +enter
	cQry += " ORDER BY R_E_C_N_O_ DESC "
	
	TCQUERY cQry ALIAS QRYLOGIN NEW   
	
	dbSelectArea("QRYLOGIN")   
	
	While !QRYLOGIN->(Eof())   

		oSection1:Cell('USERLGI' 		):SetValue(Alltrim(FWLeUserlg("QRYLOGIN->DC_USERLGI")))
		oSection1:Cell('DT_INCLUSAO'   	):SetValue(FWLeUserlg("QRYLOGIN->DC_USERLGI",2))
		oSection1:Cell('USERLGA'    	):SetValue(Alltrim(FWLeUserlg("QRYLOGIN->DC_USERLGA")))
		oSection1:Cell('DT_ALTERACAO'  	):SetValue(FWLeUserlg("QRYLOGIN->DC_USERLGA",2))  

		QRYLOGIN->(DbSkip())
	EndDo	
	QRYLOGIN->(DbCloseArea())                                                          
	
Return