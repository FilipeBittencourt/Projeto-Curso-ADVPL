#INCLUDE "rwmake.ch"
#INCLUDE "relato.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"

User Function BIA565A()   //não utilizado mais, feito com SetPrint. O que está sendo utilizado está abaixo, com TReport

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Luana Marin Ribeiro
Programa  := BIA565
Empresa   := Biancogres Cerâmica S/A
Data      := 10/09/2015
Uso       := Estoque - Produtos com Baixo Giro
Aplicação := Relatório Produtos com Baixo Giro
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF  

Local Enter := CHR(13)+CHR(10)

cHInicio := Time()
fPerg := "BIA565"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

//MsAguarde({|| fPrincipal()},"Aguarde","Processando")
fPrincipal()

return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									 ³
//³ Verifica Posicao do Formulario na Impressora.							 ³
//³                                          								 ³
//³ Pega os valores passados como parametro: 								 ³	
//³ MV_PAR01 -> Ate Emissao													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ LUANA MARIN RIBEIRO ¦ Data ¦ 06/10/15 ¦¦¦
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									 								³
//³ Verifica Posicao do Formulario na Impressora.							 								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Emissão Até        ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Do Produto         ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Até o Produto      ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Do Tipo		       ?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Até o Tipo         ?","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","MD                 ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Sim","","","","","Não","","","","","","","","","","","","","","","","",""})

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
¦¦¦Função ¦ fPrincipal ¦   Autor ¦ Luana Marin Ribeiro   ¦ Data ¦ 01.09.15¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

Static Function fPrincipal()   

cTempo := Alltrim(ElapTime(cHInicio, Time()))
IncProc("Atualizando.... ")

Private nEmp := ""
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Baixo Giro"
fCabec2  := " "
wnPag    := 0
nRow1    := 3000

//TABELA TEMPORARIA 
//nNomeTMP := "##BIA563TMP"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8SB := TFont():New("Lucida Console"    ,9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

nTotQuant   := 0.0
nTotValor := 0.0

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
oPrint:SetPaperSize(09)
oPrint:Setup()

//Monta arquivo temporario, resultado SP
cRelBG := "WITH SDS AS "
cRelBG += "	(SELECT DISTINCT SD1.D1_COD AS COD FROM " + RetSqlName("SD1") + " SD1 WITH(NOLOCK) WHERE SD1.D1_FILIAL='" + xFilial("SD1") + "' AND SD1.D1_DTDIGIT > '" + DTOS(MV_PAR01) + "' AND SD1.D_E_L_E_T_=' ' "
cRelBG += "	UNION "
cRelBG += "	SELECT DISTINCT SD3.D3_COD AS COD FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) WHERE SD3.D3_FILIAL='" + xFilial("SD3") + "' AND SD3.D3_EMISSAO > '" + DTOS(MV_PAR01) + "' AND SD3.D_E_L_E_T_=' ') "

cRelBG += "SELECT DISTINCT SB1.B1_COD AS CODIGO "
cRelBG += "	, SB1.B1_DESC AS DESCRICAO "
cRelBG += "	, SBZ.BZ_YLOCAL AS ENDER "
cRelBG += "	, SB1.B1_UM AS UNID "
cRelBG += "	, SB2.B2_QATU AS QUANTIDADE "
cRelBG += "	, SB2.B2_VATU1 AS VALOR "
cRelBG += " , SBZ.BZ_LE AS LOTE_ECON "
cRelBG += "FROM " + RetSqlName("SB2") + " SB2 WITH(NOLOCK) "
cRelBG += "	INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB2.B2_COD=SB1.B1_COD "
cRelBG += "		AND SB1.B1_FILIAL='" + xFilial("SB1") + "' "
cRelBG += "		AND SB1.B1_COD  BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "
cRelBG += "		AND SB1.B1_TIPO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' "
cRelBG += "		AND SB1.D_E_L_E_T_=' ' "
cRelBG += "	INNER JOIN SBZ010 SBZ WITH(NOLOCK) ON SB1.B1_COD=SBZ.BZ_COD "
cRelBG += "		AND SBZ.BZ_FILIAL='  ' "
If MV_PAR06==1
	cRelBG += "		AND SBZ.BZ_YMD='S' "
Else
	cRelBG += "		AND SBZ.BZ_YMD='N' "
EndIf
cRelBG += "		AND SBZ.D_E_L_E_T_=' ' "
cRelBG += "WHERE SB2.B2_FILIAL='" + xFilial("SB2") + "' "
cRelBG += "	AND SB2.B2_QATU > 0 "
cRelBG += "	AND SB2.B2_COD NOT IN (SELECT SDS.COD FROM SDS) "
cRelBG += "	AND SB2.D_E_L_E_T_=' ' "
cRelBG += "ORDER BY CODIGO "

If chkfile("cRelBG")
	DbSelectArea("cRelBG")
	DbCloseArea()
EndIf
TcQuery cRelBG New Alias "cRelBG"

fImpCabec()

DbSelectArea("cRelBG")
DbGoTop()
ProcRegua(RecCount())

iContBG :=0

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
		
	iContBG +=1
	
	If Mod(iContBG,80)==0
		fImpRoda()
		fImpCabec()
	EndIf
	
	//If nRow1 > 2250
	//	fImpRoda()
	//	fImpCabec()
	//EndIf 
	
	cRelBGSub := "SELECT SD3.D3_EMISSAO AS EMISSAO "
	cRelBGSub += "	, SD3.D3_YTAG AS YTAG "
	cRelBGSub += "	, SD3.D3_YMATRIC AS YMATRIC "
	cRelBGSub += "	, (CASE WHEN D3_YMATRIC='' THEN '' ELSE  ZZY.ZZY_NOME END) AS NOME "
	cRelBGSub += "FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) "
	cRelBGSub += "	INNER JOIN ZZY010 ZZY ON D3_YMATRIC = ZZY_MATRIC "
	cRelBGSub += "		AND ZZY.D_E_L_E_T_=' ' "
	cRelBGSub += "WHERE SD3.D3_FILIAL='" + xFilial("SD3") + "' AND SD3.D3_COD = '" + cRelBG->CODIGO + "' AND SD3.D_E_L_E_T_=' ' ORDER BY D3_EMISSAO DESC "
	
	If chkfile("cRelBGSub")
		DbSelectArea("cRelBGSub")
		DbCloseArea()
	EndIf
	TcQuery cRelBGSub New Alias "cRelBGSub"
	
	DbSelectArea("cRelBGSub")
	DbGoTop()
	
	
	xf_Item := ""
	xf_Item += Padl(iContBG 										  													  ,04,  " ") 	+ " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelBG->CODIGO,1,8)) + SPACE(8 - LEN(AllTrim(SUBSTR(cRelBG->CODIGO,1,8))))             ,08,  " ") 	+ " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelBG->DESCRICAO,1,100)) + SPACE(100 - LEN(AllTrim(SUBSTR(cRelBG->DESCRICAO,1,100)))) ,50, " ")		+ " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelBG->ENDER,1,10)) + SPACE(10 - LEN(AllTrim(SUBSTR(cRelBG->ENDER,1,10)))) 	  		  ,10, " ")		+ " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelBG->UNID,1,2)) + SPACE(2 - LEN(AllTrim(SUBSTR(cRelBG->UNID,1,2)))) 	  		  	  ,02, " ")		+ " | "
	xf_Item += Padl(Transform(cRelBG->QUANTIDADE,"@E 999,999,999.99")                                                     ,14,  " ")
	xf_Item += Padl(Transform(cRelBG->VALOR,"@E 999,999,999.99")                                                          ,14,  " ") 
	xf_Item += Padl(Transform(cRelBG->LOTE_ECON,"@E 999,999,999.99")                                                      ,14,  " ") 	+ " | "
	xf_Item += Padr(Iif(AllTrim(cRelBGSub->EMISSAO)=="", "",dtoc(stod(cRelBGSub->EMISSAO)))                               ,08,  " ") 	+ " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelBGSub->YTAG,1,8)) + SPACE(8 - LEN(AllTrim(SUBSTR(cRelBGSub->YTAG,1,8))))	  	  	  ,08,  " ") 	+ " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelBGSub->YMATRIC,1,9)) + SPACE(9 - LEN(AllTrim(SUBSTR(cRelBGSub->YMATRIC,1,9))))     ,09,  " ") 	+ " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelBGSub->NOME,1,30)) + SPACE(30 - LEN(AllTrim(SUBSTR(cRelBGSub->NOME,1,30))))     	  ,30,  " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8SB)
	nRow1 += 025
	
	nTotQuant   := nTotQuant   + ROUND(cRelBG->QUANTIDADE,2)
   	nTotValor := nTotValor + ROUND(cRelBG->VALOR,2)
	
	
	cRelBGSub->(dbCloseArea())
	
	DbSelectArea("cRelBG")
	DbSkip()
End

oPrint:Line (nRow1+25, 010, nRow1+25, 3550)
nRow1 += 050

//If nRow1 > 2250
//	fImpRoda()
//	fImpCabec()
//EndIf

xf_Item := +;
Padr(""             	     	                                                             ,35)+;
Padr("TOTAL GERAL"   	     	                                                             ,15)+;
Padr(""             	     	                                                             ,31)+;
Padl(Transform(nTotQuant,  "@E 999,999,999.99")                                              ,14)+;
Padl(Transform(nTotValor,  "@E 999,999,999.99")                                              ,14)+;
Padr(""             	     	                                                             ,56)+;
Padr(""                                                                                      ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8SB)
nRow1 += 050

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

Return



/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 14.09.10 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

Static Function fImpCabec()

fCabec  := '        Produtos de Baixo Giro '
fCabec2 := ''

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec,098)                        ,oFont14)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont8)
nRow1 += 075
oPrint:Say  (nRow1   , 0050 ,Padc(fCabec2,133)                       ,oFont10)

nRow1 += 065

//EST CLIENTE          NF               VALOR NF  VALOR ICMS  %ICMS   EMISSAO   LIMITE  PRZ LIM.  DT INTER  RESP.INTERNACAO  OBS.INTERNACAO

xf_Titu := Padl("CONT"                       	,04, " ") + " | "

xf_Titu += Padr("PRODUTO"                       ,08, " ") + " | "

xf_Titu += Padr("DESCRIÇÃO"                     ,50, " ") + " | "

xf_Titu += Padr("LOCAL"                     	,10, " ") + " | "

xf_Titu += Padr("UN"                     		,02, " ") + " | "

xf_Titu += Padl("QUANTIDADE"             		,14, " ")

xf_Titu += Padl("VALOR"                 		,14, " ")

xf_Titu += Padl("LT.ECON."                 		,14, " ") + " | "

xf_Titu += Padr("ÚLT.EMIS"                    	,08, " ") + " | "

xf_Titu += Padr("TAG"                       	,08, " ") + " | "

xf_Titu += Padr("MATRÍCULA"                    	,09, " ") + " | "

xf_Titu += Padr("NOME"	                    	,30, " ")

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8SB)

oPrint:Line (nRow1+40, 0010, nRow1+40, 3350)

nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Wanisay William       ¦ Data ¦ 14.09.10 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

oPrint:Line (2400, 010, 2400, 3350)
oPrint:Say  (2400+30 , 010,"Prog.: BIA565"                                        ,oFont7)
oPrint:Say  (2400+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return

//===========================================================================
//RELATÓRIO COM TREPORT, PARA GERAR EM EXCEL ================================
//===========================================================================

User Function BIA565()
Local oReport
Private nEmp
	
	cPerg := "BIA565"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValPergAco() 
		
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	Processa({||  Monta_Arq()})

	oReport := ReportDef()
	oReport:PrintDialog()
	
Return()


Static Function ReportDef()
Local oReport
Local oSecProd
Local Enter := chr(13) + Chr(10)
//Local cTrb := GetNextAlias()
Local cTitRel := "PRODUTOS DE BAIXO GIRO"
    
    If MV_PAR01==1
    	If MV_PAR08==1
			cTitRel := "PRODUTOS DE BAIXO GIRO - (MD SIM)" 
		Else
			cTitRel := "PRODUTOS DE BAIXO GIRO - (MD NÃO)" 
		EndIf
		
		oReport := TReport():New("BIA565", cTitRel, {|| pergunte(fPerg,.F.) }, {|oReport| PrintReport(oReport)}, cTitRel)	
		oReport:SetLandscape()
		
		oSecProd := TRSection():New(oReport, "Produto", {"cRelBG"})
	
		//CODIGO, DESCRICAO, ENDER, UNID, QUANTIDADE, VALOR, EMISSAO, YTAG, YMATRIC, NOME
		TRCell():New(oSecProd, "CONTADOR", , "Cont","@!",04)
		TRCell():New(oSecProd, "CODIGO", , "Cód.Prod.","@!",08)
		TRCell():New(oSecProd, "DESCRICAO", , "Produto","@!",40)
		
		TRCell():New(oSecProd, "GRUPO",, "Grupo")
		TRCell():New(oSecProd, "DESC_GRUPO",, "Descrição",, 30)
		TRCell():New(oSecProd, "NCM",, "NCM")		
		
		TRCell():New(oSecProd, "ENDER", , "Endereço","@!",15)
		TRCell():New(oSecProd, "UNID", , "UM","@!",02)
		TRCell():New(oSecProd, "QUANTIDADE", , "Quantidade","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "VALOR", , "Valor","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "LOTE_ECON", , "Lt.Econ.","@E 999,999,999.99",16,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "EMISSAO", , "Últ.Emis","@!",10)
		TRCell():New(oSecProd, "YTAG", , "Tag","@!",08)

		TRCell():New(oSecProd, "POLITICA", , "POL","@!",04)
		TRCell():New(oSecProd, "NOME", , "Nome","@!",30)
		
		oBreak := TRBreak():New(oReport,{||.T.}, "Total Geral")
		
		TRFunction():New(oSecProd:Cell("QUANTIDADE"),"fQUANTIDADE","SUM",oBreak,NIL,"@E 999,999,999.99",NIL,.F.,.F.)
		TRFunction():New(oSecProd:Cell("VALOR"),"fVALOR","SUM",oBreak,NIL,"@E 999,999,999.99",NIL,.F.,.F.)
	Else
		If MV_PAR08==1
			cTitRel := "GIRO DE PRODUTOS - (MD SIM)"
		Else
			cTitRel := "GIRO DE PRODUTOS - (MD NÃO)"
		EndIf
		
		oReport := TReport():New("BIA565", cTitRel, {|| pergunte(fPerg,.F.) }, {|oReport| PrintReport(oReport)}, cTitRel)	
		oReport:SetLandscape()
		
		oSecProd := TRSection():New(oReport, "Produto", {"cRelBG"})
		
		//CODIGO, DESCRICAO, ENDER, UNID, QUANTIDADE, VALOR, EMISSAO, YTAG, YMATRIC, NOME
		//TRCell():New(oSecProd, "CONTADOR", , "Cont","@!",04)
		TRCell():New(oSecProd, "CODIGO", , "Cód.","@!",07)
		TRCell():New(oSecProd, "DESCRICAO", , "Produto","@!",25)
		
		TRCell():New(oSecProd, "GRUPO",, "Grupo")
		TRCell():New(oSecProd, "DESC_GRUPO",, "Desc.")
		TRCell():New(oSecProd, "NCM",, "NCM.")		
		
		TRCell():New(oSecProd, "ENDER", , "Endereço","@!",08)
		TRCell():New(oSecProd, "UNID", , "UM","@!",02)
		TRCell():New(oSecProd, "QUANTIDADE", , "Quantidade","@E 999,999,999.99",14,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "VALOR", , "Valor","@E 999,999,999.99",14,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "LOTE_ECON", , "Lt.Econ.","@E 999,999,999.99",14,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "D1_YDTENT", , "Últ.Comp","@!",03,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "POLITICA", , "PO","@!",02,,,"LEFT",,"LEFT")
		TRCell():New(oSecProd, "RA_NOME", , "Solicitante","@!",13,,,"LEFT",,"LEFT")
		TRCell():New(oSecProd, "DIAS", , "Dias","@E 99,999",06,,,"RIGHT",,"RIGHT")
		
		
		TRCell():New(oSecProd, "M01", , "Mês 01","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M02", , "Mês 02","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M03", , "Mês 03","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M04", , "Mês 04","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M05", , "Mês 05","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M06", , "Mês 06","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M07", , "Mês 07","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M08", , "Mês 08","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M09", , "Mês 09","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M10", , "Mês 10","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M11", , "Mês 11","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "M12", , "Mês 12","@E 999,999",07,,,"RIGHT",,"RIGHT")
		TRCell():New(oSecProd, "MTt", , "Total","@E 9,999,999",09,,,"RIGHT",,"RIGHT")
		
		TRCell():New(oSecProd, "Mes", , "Meses Est","@E 999,999.99",10,,,"RIGHT",,"RIGHT")
		
		oBreak := TRBreak():New(oReport,{||.T.}, "Total Geral")
		
		TRFunction():New(oSecProd:Cell("QUANTIDADE"),"fQUANTIDADE","SUM",oBreak,NIL,"@E 999,999,999.99",NIL,.F.,.F.)
		TRFunction():New(oSecProd:Cell("VALOR"),"fVALOR","SUM",oBreak,NIL,"@E 999,999,999.99",NIL,.F.,.F.)
		TRFunction():New(oSecProd:Cell("LOTE_ECON"),"fLOTE_ECON","SUM",oBreak,NIL,"@E 999,999,999.99",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("DIAS"),"fDIAS","SUM",oBreak,NIL,"@E 9,999",NIL,.F.,.F.)
		
		//TRFunction():New(oSecProd:Cell("M01"),"fM01","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M02"),"fM02","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M03"),"fM03","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M04"),"fM04","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M05"),"fM05","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M06"),"fM06","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M07"),"fM07","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M08"),"fM08","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M09"),"fM09","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M10"),"fM10","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M11"),"fM11","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("M12"),"fM12","SUM",oBreak,NIL,"@E 9,999,999",NIL,.F.,.F.)
		//TRFunction():New(oSecProd:Cell("MTt"),"fMTt","SUM",oBreak,NIL,"@E 999,999,999",NIL,.F.,.F.)
	EndIf
	
Return(oReport)


Static Function PrintReport(oReport)
	Local oSecProd := oReport:Section(1)
	Local Enter := chr(13) + Chr(10) 
	Local iContBG
	Local cRelBGSub
	Local cRelBGUltC
	Local cRelBGCos
	Local sMesVig := SubStr(dtoc(dDataBase),4,2)  
	Local sAnoVig := SubStr(dtoc(dDataBase),7,2)
	Local bPrimPas := 0
      
	// Altera configuracoes da fonte do cabecalho do relatorio
	oReport:oFontHeader:Bold := .T.
	oReport:oFontHeader:nHeight := -12
	
	DbSelectArea("cRelBG")
	cRelBG->(DbGotop())
	ProcRegua(RecCount())
	
	iContBG :=0
	
	oSecProd:Init()
	
	While !Eof()
		If MV_PAR01==1			
			iContBG +=1
			
			cRelBGSub := "SELECT SD3.D3_EMISSAO AS EMISSAO "
			cRelBGSub += "	, SD3.D3_YTAG AS YTAG "
			cRelBGSub += "	, SD3.D3_YMATRIC AS YMATRIC "
			cRelBGSub += "	, (CASE WHEN D3_YMATRIC='' THEN '' ELSE  ZZY.ZZY_NOME END) AS NOME "
			cRelBGSub += "FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) "
			cRelBGSub += "	INNER JOIN " + RetSqlName("ZZY") + " ZZY ON D3_YMATRIC = ZZY_MATRIC "
			cRelBGSub += "		AND ZZY.D_E_L_E_T_=' ' "
			cRelBGSub += "WHERE SD3.D3_FILIAL='" + xFilial("SD3") + "' AND SD3.D3_COD = '" + cRelBG->CODIGO + "' AND SD3.D_E_L_E_T_=' ' ORDER BY D3_EMISSAO DESC "
			
			If chkfile("cRelBGSub")
				DbSelectArea("cRelBGSub")
				DbCloseArea()
			EndIf
			TcQuery cRelBGSub New Alias "cRelBGSub"
			
			DbSelectArea("cRelBGSub")
			DbGoTop()
			
			If SubStr(cRelBGSub->YMATRIC,3,6) >= MV_PAR09 .And. SubStr(cRelBGSub->YMATRIC,3,6) <= MV_PAR10 
			
				oSecProd:Cell('CONTADOR'):SetValue(Replace(Space(4 - Len(AllTrim(Str(iContBG)))), " ","0") + AllTrim(Str(iContBG)))
				oSecProd:Cell('CODIGO'):SetValue(cRelBG->CODIGO)
				oSecProd:Cell('DESCRICAO'):SetValue(cRelBG->DESCRICAO)
				
				cCodGrp := Posicione("SB1", 1, xFilial("SB1") + cRelBG->CODIGO, "B1_GRUPO")
				cDesGrp := Posicione("SBM", 1, xFilial("SBM") + cCodGrp, "BM_DESC")
				cNCM := Posicione("SB1", 1, xFilial("SB1") + cRelBG->CODIGO, "B1_POSIPI")
				
				oSecProd:Cell('GRUPO'):SetValue(cCodGrp)
				oSecProd:Cell('DESC_GRUPO'):SetValue(cDesGrp)
				oSecProd:Cell('NCM'):SetValue(cNCM)

				oSecProd:Cell('ENDER'):SetValue(cRelBG->ENDER)
				oSecProd:Cell('UNID'):SetValue(cRelBG->UNID)
				oSecProd:Cell('QUANTIDADE'):SetValue(cRelBG->QUANTIDADE)
				oSecProd:Cell('VALOR'):SetValue(cRelBG->VALOR)
				oSecProd:Cell('LOTE_ECON'):SetValue(cRelBG->LOTE_ECON)
				oSecProd:Cell('EMISSAO'):SetValue(DTOC(STOD(cRelBGSub->EMISSAO)))
				oSecProd:Cell('YTAG'):SetValue(cRelBGSub->YTAG)
				oSecProd:Cell('POLITICA'):SetValue(cRelBG->POLITICA)
				oSecProd:Cell('NOME'):SetValue(cRelBGSub->NOME)
				
				oSecProd:PrintLine()
			
			EndIf
					
			cRelBGSub->(dbCloseArea())
			
			DbSelectArea("cRelBG")
			DbSkip()
		Else
			//iContBG +=1
			
			//=====DADOS ÚLTIMA COMPRA===============
			//SD1 E SC7
			cRelBGUltC := "SELECT TOP 1 SD1.D1_YDTENT, SC7.C7_YMAT, SRA.RA_NOME "
			cRelBGUltC += "FROM " + RetSqlName("SD1") + " SD1 WITH(NOLOCK) "
			cRelBGUltC += "	LEFT JOIN " + RetSqlName("SC7") + " SC7 WITH(NOLOCK) ON SD1.D1_PEDIDO = SC7.C7_NUM "
			cRelBGUltC += "		AND SD1.D1_ITEM = SC7.C7_ITEM "
			cRelBGUltC += "		AND SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
			cRelBGUltC += "		AND SC7.D_E_L_E_T_ = ' ' "
			cRelBGUltC += "	LEFT JOIN " + RetSqlName("SRA") + " SRA WITH(NOLOCK) ON SC7.C7_YMAT = SRA.RA_MAT "
			cRelBGUltC += "		AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
			cRelBGUltC += "		AND SRA.D_E_L_E_T_ = ' ' "
			cRelBGUltC += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' "
			cRelBGUltC += "	AND SD1.D1_COD = '" + cRelBG->CODIGO + "' "
			cRelBGUltC += "	AND SD1.D_E_L_E_T_ = ' ' "
			cRelBGUltC += "ORDER BY SD1.D1_YDTENT DESC "
			
			If chkfile("cRelBGUltC")
				DbSelectArea("cRelBGUltC")
				DbCloseArea()
			EndIf
			TcQuery cRelBGUltC New Alias "cRelBGUltC"
			
			DbSelectArea("cRelBGUltC")
			DbGoTop() 
			
			If cRelBGUltC->C7_YMAT >= MV_PAR09 .And. cRelBGUltC->C7_YMAT <= MV_PAR10
			
				//=====DADOS CONSUMO MENSAL E TOTAL===============
				// SB3
				
				cRelBGCos := "SELECT SB3.B3_Q" + sMesVig + " AS M01 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 1 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 1 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 1), 2) + " AS M02 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 2 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 2 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 2), 2) + " AS M03 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 3 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 3 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 3), 2) + " AS M04 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 4 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 4 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 4), 2) + " AS M05 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 5 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 5 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 5), 2) + " AS M06 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 6 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 6 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 6), 2) + " AS M07 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 7 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 7 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 7), 2) + " AS M08 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 8 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 8 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 8), 2) + " AS M09 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 9 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 9 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 9), 2) + " AS M10 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 10 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 10 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 10), 2) + " AS M11 "
				cRelBGCos += "	, SB3.B3_Q" + StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 11 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 11 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 11), 2) + " AS M12 "
				cRelBGCos += "	, SB3.B3_Q01 + SB3.B3_Q02 + SB3.B3_Q03 + SB3.B3_Q04 + SB3.B3_Q05 + SB3.B3_Q06 + SB3.B3_Q07 + SB3.B3_Q08 + SB3.B3_Q09 + SB3.B3_Q10 + SB3.B3_Q11 + SB3.B3_Q12 AS MTt "
				cRelBGCos += "FROM " + RetSqlName("SB3") + " SB3 WITH(NOLOCK) "
				cRelBGCos += "WHERE SB3.B3_FILIAL = '" + xFilial("SB3") + "' "
				cRelBGCos += "	AND SB3.B3_COD = '" + cRelBG->CODIGO + "' "
				cRelBGCos += "	AND SB3.D_E_L_E_T_ = ' ' "
				
				If chkfile("cRelBGCos")
					DbSelectArea("cRelBGCos")
					DbCloseArea()
				EndIf
				TcQuery cRelBGCos New Alias "cRelBGCos"
				
				DbSelectArea("cRelBGCos")
				DbGoTop()
				
				oSecProd:Cell('CODIGO'):SetValue(cRelBG->CODIGO)
				oSecProd:Cell('DESCRICAO'):SetValue(cRelBG->DESCRICAO)

				cCodGrp := Posicione("SB1", 1, xFilial("SB1") + cRelBG->CODIGO, "B1_GRUPO")
				cDesGrp := Posicione("SBM", 1, xFilial("SBM") + cCodGrp, "BM_DESC")
				cNCM := Posicione("SB1", 1, xFilial("SB1") + cRelBG->CODIGO, "B1_POSIPI")
				
				oSecProd:Cell('GRUPO'):SetValue(cCodGrp)
				oSecProd:Cell('DESC_GRUPO'):SetValue(cDesGrp)
				oSecProd:Cell('NCM'):SetValue(cNCM)
								
				oSecProd:Cell('ENDER'):SetValue(cRelBG->ENDER)
				oSecProd:Cell('UNID'):SetValue(cRelBG->UNID)
				oSecProd:Cell('QUANTIDADE'):SetValue(cRelBG->QUANTIDADE)
				oSecProd:Cell('VALOR'):SetValue(cRelBG->VALOR)
				oSecProd:Cell('LOTE_ECON'):SetValue(cRelBG->LOTE_ECON)
				oSecProd:Cell('D1_YDTENT'):SetValue(DTOC(STOD(AllTrim(cRelBGUltC->D1_YDTENT))))
				oSecProd:Cell('POLITICA'):SetValue(AllTrim(cRelBG->POLITICA))
				oSecProd:Cell('RA_NOME'):SetValue(cRelBGUltC->RA_NOME)
				oSecProd:Cell('DIAS'):SetValue(cRelBG->DIAS)
				
				oSecProd:Cell('M01'):SetValue(cRelBGCos->M01)
				oSecProd:Cell('M02'):SetValue(cRelBGCos->M02)
				oSecProd:Cell('M03'):SetValue(cRelBGCos->M03)
				oSecProd:Cell('M04'):SetValue(cRelBGCos->M04)
				oSecProd:Cell('M05'):SetValue(cRelBGCos->M05)
				oSecProd:Cell('M06'):SetValue(cRelBGCos->M06)
				oSecProd:Cell('M07'):SetValue(cRelBGCos->M07)
				oSecProd:Cell('M08'):SetValue(cRelBGCos->M08)
				oSecProd:Cell('M09'):SetValue(cRelBGCos->M09)
				oSecProd:Cell('M10'):SetValue(cRelBGCos->M10)
				oSecProd:Cell('M11'):SetValue(cRelBGCos->M11)
				oSecProd:Cell('M12'):SetValue(cRelBGCos->M12)
				oSecProd:Cell('MTt'):SetValue(cRelBGCos->MTt)
				oSecProd:Cell('Mes'):SetValue(Iif(Round((cRelBG->QUANTIDADE/cRelBGCos->MTt) * 12, 2)< 0.0, 0.0, Round((cRelBG->QUANTIDADE/cRelBGCos->MTt) * 12, 2)))
				
				If bPrimPas == 0
					oSecProd:Cell('M01'):SetTitle(sMesVig + "/" + StrZero(Val(sAnoVig) - 1, 2))
					
					MesS01 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 1 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 1 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 1) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 1 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 1 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 1) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M02'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 1 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 1 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 1), 2) + "/" + MesS01)
					
					MesS02 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 2 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 2 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 2) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 2 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 2 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 2) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M03'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 2 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 2 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 2), 2) + "/" + MesS02)
					
					MesS03 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 3 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 3 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 3) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 3 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 3 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 3) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M04'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 3 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 3 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 3), 2) + "/" + MesS03)
					
					MesS04 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 4 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 4 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 4) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 4 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 4 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 4) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M05'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 4 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 4 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 4), 2) + "/" + MesS04)
					
					MesS05 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 5 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 5 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 5) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 5 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 5 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 5) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M06'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 5 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 5 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 5), 2) + "/" + MesS05)
					
					MesS06 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 6 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 6 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 6) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 6 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 6 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 6) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M07'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 6 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 6 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 6), 2) + "/" + MesS06)
					
					MesS07 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 7 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 7 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 7) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 7 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 7 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 7) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M08'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 7 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 7 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 7), 2) + "/" + MesS07)
					
					MesS08 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 8 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 8 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 8) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 8 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 8 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 8) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M09'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 8 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 8 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 8), 2) + "/" + MesS08)
					
					MesS09 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 9 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 9 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 9) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 9 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 9 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 9) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M10'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 9 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 9 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 9), 2) + "/" + MesS09)
					
					MesS10 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 10 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 10 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 10) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 10 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 10 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 10) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M11'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 10 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 10 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 10), 2) + "/" + MesS10)
					
					MesS11 := Iif(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 11 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 11 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 11) > Val(sMesVig) .And. Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 11 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 11 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 11) <=12, StrZero(Val(sAnoVig) - 1, 2), sAnoVig)
					oSecProd:Cell('M12'):SetTitle(StrZero(Iif(Val(Iif(sMesVig=="12","00",sMesVig)) + 11 > 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 11 - 12, Val(Iif(sMesVig=="12","00",sMesVig)) + 11), 2) + "/" + MesS11)
					
					bPrimPas := 1
				EndIf
				
				oSecProd:PrintLine()
				cRelBGCos->(dbCloseArea())
				
				
			EndIf			
				
			cRelBGUltC->(dbCloseArea())
			
			DbSelectArea("cRelBG")
			DbSkip()
		EndIf
	End
	
	oSecProd:Finish()
Return()

Static Function Monta_Arq()
	Local cRelBG
	
	cRelBG := "WITH SDS AS "
	cRelBG += "	(SELECT DISTINCT SD1.D1_COD AS COD FROM " + RetSqlName("SD1") + " SD1 WITH(NOLOCK) WHERE SD1.D1_FILIAL='" + xFilial("SD1") + "' AND SD1.D1_DTDIGIT BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' AND SD1.D1_COD  BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' AND SD1.D_E_L_E_T_=' ' "
	cRelBG += "	UNION "
	cRelBG += "	SELECT DISTINCT SD3.D3_COD AS COD FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) WHERE SD3.D3_FILIAL='" + xFilial("SD3") + "' AND SD3.D3_EMISSAO BETWEEN '" + DTOS(MV_PAR02) + "' AND '" + DTOS(MV_PAR03) + "' AND SD3.D3_COD  BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' AND SD3.D_E_L_E_T_=' ') "
	
	cRelBG += "SELECT DISTINCT SB1.B1_COD AS CODIGO "
	cRelBG += "	, SB1.B1_DESC AS DESCRICAO "
	cRelBG += "	, SBZ.BZ_YLOCAL AS ENDER "
	cRelBG += "	, SB1.B1_UM AS UNID "
	cRelBG += "	, SUM(SB2.B2_QATU) AS QUANTIDADE "
	cRelBG += "	, SUM(SB2.B2_VATU1) AS VALOR "
	cRelBG += "	, SBZ.BZ_LE AS LOTE_ECON "
	cRelBG += "	, SBZ.BZ_YPOLIT AS POLITICA "
	If MV_PAR01==2
		cRelBG += "	, DATEDIFF(day,SBZ.BZ_UCOM, GETDATE()) AS DIAS "
	EndIf
	cRelBG += "FROM " + RetSqlName("SB2") + " SB2 WITH(NOLOCK) "
	cRelBG += "	INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB2.B2_COD=SB1.B1_COD "
	cRelBG += "		AND SB1.B1_FILIAL='" + xFilial("SB1") + "' "
	cRelBG += "		AND SB1.B1_COD  BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' "
	cRelBG += "		AND SB1.B1_TIPO BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR07+"' "
	cRelBG += "		AND SB1.B1_COD <= '7' "	
	cRelBG += "		AND SB1.D_E_L_E_T_=' ' "
	cRelBG += "	INNER JOIN " + RetSqlName("SBZ") + " SBZ WITH(NOLOCK) ON SB1.B1_COD=SBZ.BZ_COD "
	cRelBG += "		AND SBZ.BZ_FILIAL='  ' "
	If MV_PAR08==1
		cRelBG += "		AND SBZ.BZ_YMD='S' "
	Else
		cRelBG += "		AND SBZ.BZ_YMD='N' "
	EndIf
	cRelBG += "		AND SBZ.D_E_L_E_T_=' ' "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
	cRelBG += "WHERE SB2.B2_FILIAL='" + xFilial("SB2") + "' "
	If MV_PAR11==1
		cRelBG += "	AND SB2.B2_QATU > 0 "
	EndIf
	If MV_PAR01==1
		cRelBG += "	AND SB2.B2_COD NOT IN (SELECT SDS.COD FROM SDS) "
	Else
		cRelBG += "	AND SB2.B2_COD IN (SELECT SDS.COD FROM SDS) "
	EndIf
	cRelBG += "	AND SB2.D_E_L_E_T_=' ' "
	cRelBG += "GROUP BY SB1.B1_COD "
	cRelBG += "	, SB1.B1_DESC "
	cRelBG += "	, SBZ.BZ_YLOCAL "
	cRelBG += "	, SB1.B1_UM "
	cRelBG += "	, SBZ.BZ_YPOLIT "
	cRelBG += "	, SBZ.BZ_LE "
	If MV_PAR01==2
		cRelBG += "	, SBZ.BZ_UCOM "
	EndIf
	cRelBG += "ORDER BY CODIGO "
	
	MemoWrite("\SQLBAIXOGIRO.TXT",cRelBG)
	
	If chkfile("cRelBG")
		DbSelectArea("cRelBG")
		DbCloseArea()
	EndIf
	TcQuery cRelBG New Alias "cRelBG" New
	
	cRelBG->(dbGoTop())
Return()

Static Function ValPergAco()
Local i,j,nX
Local aTRegs := {}
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local Enter := chr(13) + Chr(10)
              
cPerg := PADR(cPerg,10)

//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
//aAdd(aTRegs,{"Codigo Acordo:","C",6,0,0,"G","","","","","","","","Numero do acordo para analise."})
aAdd(aTRegs,{"Período","N",1,0,0,"C","","Não teve giro","Teve giro","","","","","Modelo do relatório a ser gerado"})//1
aAdd(aTRegs,{"Emissão De","D",8,0,0,"G","","","","","","","","Data de"})//2
aAdd(aTRegs,{"Emissão Até","D",8,0,0,"G","","","","","","","","Data até"})//3
aAdd(aTRegs,{"Produto De:","C",15,0,0,"G","","","","","","","","Produto de"})//4
aAdd(aTRegs,{"Produto Até:","C",15,0,0,"G","","","","","","","","Produto ate"})//5
aAdd(aTRegs,{"Tipo De:","C",2,0,0,"G","","","","","","","","Tipo de"})//6
aAdd(aTRegs,{"Tipo Até:","C",2,0,0,"G","","","","","","","","Tipo ate"})//7
aAdd(aTRegs,{"MD","N",1,0,0,"C","","Sim","Não","","","","","Material Direto"})//8
aAdd(aTRegs,{"Matricula De:","C",6,0,0,"G","","","","","","","","Cliente de"})//9
aAdd(aTRegs,{"Matricula Até:","C",6,0,0,"G","","","","","","","","Cliente ate"})//10
aAdd(aTRegs,{"Saldo maior que 0:","N",1,0,0,"C","","Sim","Não","","","","","Saldo maior que zero"})//11

//Criar aRegs na ordem do vetor Temporario
aRegs := {}
For I := 1 To Len(aTRegs)
	aAdd(aRegs,{cPerg,StrZero(I,2),aTRegs[I][1],aTRegs[I][1],aTRegs[I][1]	,"mv_ch"+Alltrim(Str(I)),aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],aTRegs[I][6],aTRegs[I][7],;
	"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","","",aTRegs[I][12],"","","",aTRegs[I][13],""})
Next I

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
	
	//HELP DAS PERGUNTAS
	aHelpPor := {}
	__aRet := STRTOKARR(AllTrim(aTRegs[I][14]),"#")
	FOR nX := 1 To Len(__aRet)
		AADD(aHelpPor,AllTrim(__aRet[nX]))
	NEXT nX
	PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)
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