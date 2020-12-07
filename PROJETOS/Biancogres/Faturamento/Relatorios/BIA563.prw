#INCLUDE "rwmake.ch"
#INCLUDE "relato.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"

User Function BIA563()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Luana Marin Ribeiro
Programa  := BIA563
Empresa   := Biancogres Cerâmica S/A
Data      := 01/09/2015
Uso       := Faturamento - NF de exportação
Aplicação := Relatório de NFs de exportação
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF  

Local Enter := CHR(13)+CHR(10)
Local xt

cHInicio := Time()
fPerg := "BIA563"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

MsAguarde({|| fPrincipal()},"Aguarde","Processando")

return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									 ³
//³ Verifica Posicao do Formulario na Impressora.							 ³
//³                                          								 ³
//³ Pega os valores passados como parametro: 								 ³	
//³ MV_PAR01 -> Do Cliente                   								 ³
//³ MV_PAR02 -> Ate Cliente                                                  ³
//³ MV_PAR03 -> Da Emissao                                                   ³
//³ MV_PAR04 -> Ate Emissao                                                  ³
//³ MV_PAR05 -> Opcao ? 1=Pendentes 2=Internadas 3=Ambas                     ³
//³ MV_PAR06 -> Ordenar por ? 1=Estado 2=Cliente 3=NF                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


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
aAdd(aRegs,{cPerg,"01","Do Cliente         ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Ate o Cliente      ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","De Emissão         ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Até Emissão        ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Opção              ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Pendentes","","","","","Finalizadas","","","","","Ambas","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Ordernar por       ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Estado","","","","","Cliente","","","","","NF","","","","","Emissão","","","","","","","","","","","","","",""})

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

Private nEmp := ""
//IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
//ELSE
//	aBitmap  := "LOGOPRI05.BMP"
//ENDIF

fCabec   := "Notas Fiscais de Exportação"
fCabec2  := " "
wnPag    := 0
nRow1    := 3000
Enter1   := CHR(13)+CHR(10)

//TABELA TEMPORARIA 
//nNomeTMP := "##BIA563TMP"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

nTotVrNf   := 0.0
nTotVrIcms := 0.0

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
oPrint:SetPaperSize(09)
oPrint:Setup()

//Monta arquivo temporario, resultado SP
cRelExp := "SELECT SF2.F2_EST, SF2.F2_CLIENTE, SF2.F2_LOJA, SA1.A1_NOME,SF2.F2_SERIE, SF2.F2_DOC, "
cRelExp += "    SF2.F2_VALMERC, SF2.F2_VALICM, (SF2.F2_VALMERC/100)*SF2.F2_VALICM  AS F2_ALIQICM, "
cRelExp += "    SF2.F2_EMISSAO, SF2.F2_YDTEXP "
cRelExp += "FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SA1") + " SA1, " + RetSqlName("SD2") + " SD2 "
cRelExp += "WHERE "
cRelExp += "	SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND "
cRelExp += "	SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND "
cRelExp += "	SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "
cRelExp += "	SF2.F2_CLIENTE = SA1.A1_COD AND "
cRelExp += "	SF2.F2_LOJA = SA1.A1_LOJA AND "
cRelExp += "	SF2.F2_DOC = SD2.D2_DOC AND "
cRelExp += "	SF2.F2_SERIE = SD2.D2_SERIE AND "
cRelExp += "	SF2.F2_CLIENTE = SD2.D2_CLIENTE AND "
cRelExp += "	SF2.F2_LOJA = SD2.D2_LOJA AND "
cRelExp += "	SD2.D2_ITEM = '01' AND "
cRelExp += "	SD2.D2_CF IN ('5501','5502','6501','6502','7101','7102') AND "
cRelExp += "	SF2.F2_TIPO = 'N' AND "
cRelExp += "	SF2.F2_CLIENTE BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
cRelExp += "	SF2.F2_EMISSAO BETWEEN '" + DTOS(MV_PAR03) + "' AND '" + DTOS(MV_PAR04) + "' AND " 

If MV_PAR05 == 1
	cRelExp += "	SF2.F2_YDTEXP = '' AND "
EndIf
If MV_PAR05 == 2
	cRelExp += "	SF2.F2_YDTEXP <> '' AND "
EndIf
If MV_PAR05 == 1
	cRelExp += "	SF2.F2_YDTEXP = '' AND "
EndIf

cRelExp += "	SF2.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SD2.D_E_L_E_T_ = '' "
 
If MV_PAR06 == 1
	cRelExp += "ORDER BY SF2.F2_EST, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_DOC "
EndIf
If MV_PAR06 == 2
	cRelExp += "ORDER BY SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_DOC"
EndIf
If MV_PAR06 == 3
	cRelExp += "ORDER BY SF2.F2_DOC, SF2.F2_EST, SF2.F2_CLIENTE, SF2.F2_LOJA"
EndIf
If MV_PAR06 == 4
	cRelExp += "ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_EST, SF2.F2_CLIENTE, SF2.F2_LOJA"
EndIf

If chkfile("cRelExp")
	DbSelectArea("cRelExp")
	DbCloseArea()
EndIf
TcQuery cRelExp New Alias "cRelExp"

fImpCabec()

DbSelectArea("cRelExp")
DbGoTop()
ProcRegua(RecCount())

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	If nRow1 > 2250
		fImpRoda()
		fImpCabec()
	EndIf
	
	
	xf_Item := ""
	xf_Item += Padr(AllTrim(SUBSTR(cRelExp->F2_EST,1,2)) + SPACE(2 - LEN(AllTrim(SUBSTR(cRelExp->F2_EST,1,2))))           ,04, " ") + " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelExp->F2_CLIENTE,1,7)) + SPACE(7 - LEN(AllTrim(SUBSTR(cRelExp->F2_CLIENTE,1,7))))   ,07, " ") + " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelExp->F2_LOJA,1,4)) + SPACE(4 - LEN(AllTrim(SUBSTR(cRelExp->F2_LOJA,1,4))))         ,04, " ") + " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelExp->A1_NOME,1,60)) + SPACE(60 - LEN(AllTrim(SUBSTR(cRelExp->A1_NOME,1,60))))	  ,60, " ") + " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelExp->F2_SERIE,1,3)) + SPACE(3 - LEN(AllTrim(SUBSTR(cRelExp->F2_SERIE,1,3))))       ,03, " ") + " | "
	xf_Item += Padr(AllTrim(SUBSTR(cRelExp->F2_DOC,1,9)) + SPACE(9 - LEN(AllTrim(SUBSTR(cRelExp->F2_DOC,1,9))))           ,09, " ") + " | "
	xf_Item += Padl(Transform(cRelExp->F2_VALMERC,"@E 999,999,999.99")                                                    ,14, " ")
	xf_Item += Padl(Transform(cRelExp->F2_VALICM,"@E 999,999,999.99")                                                     ,14, " ")
	xf_Item += Padl(Transform(cRelExp->F2_ALIQICM,"@E 999,999.99")                                                        ,10, " ") + " | "
	xf_Item += Padc(Iif(AllTrim(cRelExp->F2_EMISSAO)=="", "",dtoc(stod(cRelExp->F2_EMISSAO)))                             ,08, " ") + " | "
	xf_Item += Padc(Iif(AllTrim(cRelExp->F2_YDTEXP)=="", "",dtoc(stod(cRelExp->F2_YDTEXP)))                               ,08, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
	nRow1 += 025
	
	nTotVrNf   := nTotVrNf   + ROUND(cRelExp->F2_VALMERC,2)
	nTotVrIcms := nTotVrIcms + ROUND(cRelExp->F2_VALICM,2)
	
	DbSelectArea("cRelExp")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	fImpCabec()
EndIf

xf_Item := +;
Padc(""             	     	                                                             ,43)+"  "+;
Padc("Total Geral"   	     	                                                             ,45)+"  "+;
Padc(""             	     	                                                             ,13)+;
Padc(Transform(nTotVrNf,  "@E 999,999,999.99")                                               ,14)+;
Padc(Transform(nTotVrIcms,  "@E 999,999,999.99")                                             ,14)+;
Padc(""             	     	                                                             ,56)+;
Padc(""                                                                                      ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
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

fCabec  := '        Notas Fiscais de Exportação - Mês de Referência ' + SUBSTRING(SUBSTRING(ALLTRIM(U_MES(MV_PAR04)),3,9),1, IIF(AT(' ',SUBSTRING(ALLTRIM(U_MES(MV_PAR04)),3,9))==0, 10, AT(' ',SUBSTRING(ALLTRIM(U_MES(MV_PAR04)),3,9))) - 1) + '/' + STR(YEAR(MV_PAR04),4)
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

xf_Titu := Padr("Est."                       ,04, " ") + " | "

xf_Titu += Padr("Cliente"                    ,07, " ") + " | "

xf_Titu += Padr("Loja"                       ,04, " ") + " | "

xf_Titu += Padr("Nome" 				         ,60, " ") + " | "

xf_Titu += Padr("Sr"  		                 ,03, " ") + " | "

xf_Titu += Padr("Doc."                       ,09, " ") + " | "

xf_Titu += Padl("        Vr. NF"             ,14, " ")

xf_Titu += Padl("      Vr. ICMS"             ,14, " ")

xf_Titu += Padl("     %ICMS"                 ,10, " ") + " | "

xf_Titu += Padc("Emissão"                    ,08, " ") + " | "

xf_Titu += Padc("Dt.Exp."                    ,10, " ")

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7)

oPrint:Line (nRow1+40, 010, nRow1+40, 3350)

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

oPrint:Line (2300, 010, 2300, 3350)
oPrint:Say  (2300+30 , 010,"Prog.: BIA563"                                        ,oFont7)
oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return
