#INCLUDE "rwmake.ch"
#INCLUDE "relato.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"

User Function BIA564()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Luana Marin Ribeiro
Programa  := BIA564
Empresa   := Biancogres Cerâmica S/A
Data      := 04/09/2015
Uso       := Faturamento - Obras
Aplicação := Relatório de Obras
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF  

Local Enter := CHR(13)+CHR(10)
Local xt

cHInicio := Time()
fPerg := "BIA564"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()

If AllTrim(FunName()) == "BIA229"
	Pergunte(fPerg,.F.)	
	MV_PAR01 := ZZO->ZZO_FILIAL
	MV_PAR02 := ZZO->ZZO_NUM
Else
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
EndIf

MsAguarde({|| fPrincipal()},"Aguarde","Processando")

return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									 ³
//³ Verifica Posicao do Formulario na Impressora.							 ³
//³                                          								 ³
//³ Pega os valores passados como parametro: 								 ³	
//³ MV_PAR01 -> Filial                   								 	 ³
//³ MV_PAR02 -> Obra														 ³
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
aAdd(aRegs,{cPerg,"01","Filial ?","","","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Obra   ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

fCabec   := "Obra nº: "
fCabec2  := " "
wnPag    := 0
nRow1    := 3000
Enter1   := CHR(13)+CHR(10)

//TABELA TEMPORARIA 
//nNomeTMP := "##BIA563TMP"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7b  := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8SB := TFont():New("Lucida Console"    ,9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
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
cRelObra := "SELECT Z55_PROD, Z55_QUANT "
cRelObra += "FROM "+RetSqlName("Z55")+" "
cRelObra += "WHERE Z55_FILIAL = '"+MV_PAR01+"' AND Z55_OBRA = '"+MV_PAR02+"' "
If chkfile("cRelObra")
	DbSelectArea("cRelObra")
	DbCloseArea()
EndIf
TcQuery cRelObra New Alias "cRelObra"

fImpCabec()

DbSelectArea("cRelObra")
DbGoTop()
ProcRegua(RecCount())

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)

	If nRow1 > 2250
		fImpRoda()
	//fImpCabec()
	EndIf
	
	
	xf_Item := ""
	xf_Item += Padr(AllTrim(SUBSTR(cRelObra->Z55_PROD,1,15)) + SPACE(15 - LEN(AllTrim(SUBSTR(cRelObra->Z55_PROD,1,15))))            ,15, " ")
	xf_Item += Padl(Transform(cRelObra->Z55_QUANT,"@E 999,999,999.99")                                                    			,20, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont8sb)
	nRow1 += 025
	
	//nTotVrNf   := nTotVrNf   + ROUND(cRelExp->F2_VALMERC,2)
	//nTotVrIcms := nTotVrIcms + ROUND(cRelExp->F2_VALICM,2)
	
	DbSelectArea("cRelObra")
	DbSkip()
End

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2250
	fImpRoda()
	//fImpCabec()
EndIf

//xf_Item := +;
//Padc(""             	     	                                                             ,43)+"  "+;
//Padc("Total Geral"   	     	                                                             ,45)+"  "+;
//Padc(""             	     	                                                             ,13)+;
//Padc(Transform(nTotVrNf,  "@E 999,999,999.99")                                               ,14)+;
//Padc(Transform(nTotVrIcms,  "@E 999,999,999.99")                                             ,14)+;
//Padc(""             	     	                                                             ,56)+;
//Padc(""                                                                                      ,14)
//oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
//nRow1 += 050

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

fCabec  := '        Obra nº: ' + MV_PAR02
fCabec2 := ''


cSQLObras := "SELECT ZZO_FILIAL, ZZO_NUM, ZZO_EMIS, ZZO_VEND, ZZO_NOMEV, ZZO_ESTV, ZZO_NOMCAP "
cSQLObras += "	,ZZO_ESTC, ZZO_OBRA, ZZO_ENDOBR, ZZO_NUMOBR, ZZO_BAIRRO, ZZO_CODMUN, ZZO_MUN "
cSQLObras += "	,ZZO_EST, ZZO_PADRAO, ZZO_FASE, ZZO_TPEMP, ZZO_TPOBR, ZZO_DTPREV, ZZO_NROTOR "
cSQLObras += "	,ZZO_NROAPT, ZZO_QTDPIS, ZZO_QTDREV, ZZO_QTDPOR, ZZO_QTDACE, ZZO_QTDTOT "
cSQLObras += "	,ZZO_NOMCLI, ZZO_ENDCLI, ZZO_COMPLC, ZZO_BAIRRC, ZZO_CODMC, ZZO_MUNC, ZZO_ESTCLI "
cSQLObras += "	,ZZO_CNPJ, ZZO_TEL, ZZO_CONT1, ZZO_TIPOC1, ZZO_TELC1, ZZO_CONT2, ZZO_TIPOC2 "
cSQLObras += "	,ZZO_TELC2, ZZO_CONT3, ZZO_TIPO3, ZZO_STATUS, ZZO_OBS, ZZO_TELC3, ZZO_PERD "
cSQLObras += "	,ZZO_DTFECH, ZZO_REDEOB, ZZO_ALTSTA, ZZO_PEDIDO, ZZO_YMOTIV "
cSQLObras += "FROM "+RetSqlName("ZZO")+" "
cSQLObras += "WHERE ZZO_FILIAL = '" + MV_PAR01+"' AND ZZO_NUM = '"+MV_PAR02+"' "
TCQUERY cSQLObras New Alias "cSQLObras"
dbSelectArea("cSQLObras")
dbGoTop()

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

	xf_Titu := Padr("Número"                     								,06, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_NUM           								,06, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Emissão"                    								,08, " ")
	xf_Titu2+= Padr(dtoc(stod(cSQLObras->ZZO_EMIS))          					,08, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Vendedor"  		     	 								,08, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_VEND          								,08, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padr("Nome Vend."             	 								,60, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_NOMEV         								,60, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padr("UF Vend."             		 								,08, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_ESTV          								,08, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padr("Capitador"             	 								,30, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_NOMCAP        								,30, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padr("UF Cap."             		 								,07, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_ESTC          								,07, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8SB)
	nRow1 += 065
	
	
	xf_Titu := Padr("Obra",200, " ")
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
	oPrint:Line (nRow1+25, 010, nRow1+25, 3350)
	nRow1 += 035
	

	xf_Titu := Padr("Nome"                  									,50, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_OBRA          								,50, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Endereço"                   								,50, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_ENDOBR        								,50, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Compl."                   									,15, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_NUMOBR        								,15, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)
	nRow1 += 045
	

	xf_Titu := Padr("Bairro"                     								,30, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_BAIRRO           							,30, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Cód.Mun."                    								,08, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_CODMUN          								,08, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Município"  		     	 								,50, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_MUN          								,50, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padr("UF"             	 										,02, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_EST         									,02, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)	
	oPrint:Line (nRow1+40, 010, nRow1+40, 3350)
	nRow1 += 065
	

	xf_Titu := Padr("Padrão"                     								,07, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_PADRAO           							,07, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Fase"                    									,10, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_FASE          								,10, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Tipo Empr."  		     	 								,13, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_TPEMP          								,13, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padr("Tipo Obra"             	 								,10, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_TPOBR         								,10, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padr("Prev.Compra"             	 								,08, " ")
	xf_Titu2+= Padr(dtoc(stod(cSQLObras->ZZO_DTPREV))         					,08, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padl("  Torres/BL"  		     									,11, " ")
	xf_Titu2+= Padl(cSQLObras->ZZO_NROTOR             							,11, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padl("  Nº Aptos."             									,11, " ")
	xf_Titu2+= Padl(cSQLObras->ZZO_NROAPT             							,11, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padl("   Qtd.Pisos M2"             								,15, " ")
	xf_Titu2+= Padl(cSQLObras->ZZO_QTDPIS             							,15, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padl("  Qtd.Parede M2"             								,15, " ")
	xf_Titu2+= Padl(cSQLObras->ZZO_QTDREV             							,15, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padl("  Qtd.Porcel.M2"             								,15, " ")
	xf_Titu2+= Padl(cSQLObras->ZZO_QTDPOR             							,15, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padl("   Qtd.Aces.Pç."             								,15, " ")
	xf_Titu2+= Padl(cSQLObras->ZZO_QTDACE             							,15, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padl("   Qtd.Total M2"             								,15, " ")
	xf_Titu2+= Padl(cSQLObras->ZZO_QTDTOT             							,15, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)
	nRow1 += 065
	
	
	xf_Titu := Padr("Cliente",200, " ")
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
	oPrint:Line (nRow1+25, 010, nRow1+25, 3350)
	nRow1 += 035
	

	xf_Titu := Padr("Nome"                  									,50, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_NOMCLI          								,50, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("CNPJ"                   									,14, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_CNPJ        									,14, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Telefone"                   								,10, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_TEL        									,10, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Endereço"                   								,50, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_ENDCLI        								,50, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Compl."                   									,15, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_COMPLC        								,15, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)
	nRow1 += 045
	

	xf_Titu := Padr("Bairro"                     								,30, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_BAIRRC           							,30, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Cód.Mun."                    								,08, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_CODMC          								,08, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Município"  		     	 								,50, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_MUNC          								,50, " ")
	
	xf_Titu += Padr(""             				 								,05, " ")
	xf_Titu2+= Padr(""             				 								,05, " ")
	
	xf_Titu += Padr("UF"             	 										,02, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_ESTCLI        								,02, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)	
	oPrint:Line (nRow1+40, 010, nRow1+40, 3350)
	nRow1 += 065
	
	
	xf_Titu := Padr("Contatos",200, " ")
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont8)
	oPrint:Line (nRow1+25, 010, nRow1+25, 3350)
	nRow1 += 035
	

	xf_Titu := Padr("Quem Decide?"                  							,50, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_TIPOC1          								,50, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Nome Decide"                   							,80, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_CONT1        								,80, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Telefone"                   								,10, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_TELC1        								,10, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)
	nRow1 += 045
	

	xf_Titu := Padr("Tipo 2"                     								,50, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_TIPOC2           							,50, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Nome 2"                    								,80, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_CONT2          								,80, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Telefone 2"  		     	 								,10, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_TELC2          								,10, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)
	nRow1 += 045
	

	xf_Titu := Padr("Tipo 3"                     								,50, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_TIPO3           								,50, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Nome 3"                    								,80, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_CONT3          								,80, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Telefone 3"  		     	 								,10, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_TELC3          								,10, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)
	oPrint:Line (nRow1+40, 010, nRow1+40, 3350)
	nRow1 += 045
	

	xf_Titu := Padr("Alter.Status"                     							,12, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_ALTSTA           							,12, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Status"                    								,20, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_STATUS          								,20, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Perdido P/"  		     	 								,50, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_PERD          								,50, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Fechamento"                     							,10, " ")
	xf_Titu2+= Padr(dtoc(stod(cSQLObras->ZZO_DTFECH))           				,10, " ")
	
	xf_Titu += Padr(""                       	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Rede Obra"                    								,09, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_REDEOB          								,09, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Pedido"  		     	 									,06, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_PEDIDO          								,06, " ")
	
	xf_Titu += Padr("" 				         	 								,05, " ")
	xf_Titu2+= Padr(""                           								,05, " ")
	
	xf_Titu += Padr("Motivo Perda"  		     	 							,25, " ")
	xf_Titu2+= Padr(cSQLObras->ZZO_YMOTIV          								,25, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)
	nRow1 += 045
	
	                                                                                               

	xf_Titu := Padr("Obs."                     									,300, " ")
	xf_Titu2:= Padr(cSQLObras->ZZO_OBS           								,300, " ")
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	nRow1 += 025
	oPrint:Say  (nRow1 ,0010 ,xf_Titu2   ,oFont8sb)
	oPrint:Line (nRow1+40, 010, nRow1+40, 3350)
	nRow1 += 085
	
	
	xf_Titu := Padr("Produto"                     								,15, " ")
	
	xf_Titu += Padl("Quantidade"                    							,20, " ")
		
	
	oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7b)
	//nRow1 += 025
	oPrint:Line (nRow1+30, 010, nRow1+30, 3350)
	
	

nRow1 += 075

cSQLObras->(dbCloseArea())

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
oPrint:Say  (2300+30 , 010,"Prog.: BIA564"                                        ,oFont7)
oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return