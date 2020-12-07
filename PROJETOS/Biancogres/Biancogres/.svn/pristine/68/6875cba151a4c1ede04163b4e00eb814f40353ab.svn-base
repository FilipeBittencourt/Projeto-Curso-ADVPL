#include "rwmake.ch"
#include "topconn.ch"

User Function BIA498()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ BIA498     ³ Autor ³ Biancogres           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatório de Comissões - Resumo mensal                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄLÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/

Private _ni
Private wnPag
Private nRow1

cHInicio := Time()
fPerg := "BIA498"
If !Pergunte(fPerg,.T.)
	Return
EndIf

aCampos := {}
AADD(aCampos,{"CNPJ"    , "C", 18, 0})
AADD(aCampos,{"NOME"    , "C", 45, 0})
AADD(aCampos,{"VLRBRUT" , "N", 14, 2})
AADD(aCampos,{"COMISVAR", "N", 12, 2})
AADD(aCampos,{"VLRTOT"  , "N", 14, 2})
AADD(aCampos,{"IR"      , "N", 14, 2})
AADD(aCampos,{"VLRLIQ"  , "N", 14, 2})
AADD(aCampos,{"DESCTEL" , "N", 12, 2})
AADD(aCampos,{"DESCOUT" , "N", 12, 2})
AADD(aCampos,{"VLRPAG"  , "N", 14, 2})
AADD(aCampos,{"BANCO"   , "C", 05, 0})
AADD(aCampos,{"SIMPNAC" , "C", 01, 0})
AADD(aCampos,{"OBS"     , "C", 100, 0})

cArqTrab := CriaTrab(aCampos, .T.)
DbUseArea(.T.,,cArqTrab,"_TRAB")

//O primeiro indice é o segundo para DbSetOrder
cIndex   := CriaTrab(nil,.F.)
cChave   := "NOME"
_TRAB->(DbCreateIndex( cIndex, cChave, {|| &cChave}, .F. ))
_TRAB->(DbCommit())

cIndex2   := CriaTrab(nil,.F.)
cChave   := "CNPJ"
_TRAB->(DbCreateIndex(cIndex2, cChave, {|| &cChave}, .F. ))
_TRAB->(DbCommit())

_TRAB->(DbSetIndex( cIndex ))

MsAguarde({|| fComis()},"Realizando a impressão do Resumo da Comissão Mensal","Atualizando")

RETURN

Static Function fComis()
Local nEmp := ""
DO CASE
	CASE cEmpAnt == '01'
		aBitmap  := "LOGOPRI01.BMP"
	CASE cEmpAnt == '05'
		aBitmap  := "LOGOPRI05.BMP"
	CASE cEmpAnt == '07'
		aBitmap  := "LGRL07.BMP"
	CASE cEmpAnt == '14'
		aBitmap  := "LGRL14.BMP"
	OTHERWISE
		aBitmap  := "LOGOPRI01.BMP"
ENDCASE

dDataRef := CTOD("01/"+SUBSTR(MV_PAR01,5,2)+'/'+SUBSTR(MV_PAR01,1,4))
dDataTit := dDataRef - 15
Enter1   := CHR(13)+CHR(10)

fCabec   := '          Comissões dos Títulos Recebidos no mês: '+SUBSTR(ALLTRIM(U_MES(dDataTit)),3,8)+'/'+STR(YEAR(dDataTit),4)//+'          Pagas em: '+ DToC(dDataRef)
fCabec2  := '          Pagas em: ' + SUBSTR(ALLTRIM(U_MES(dDataRef)),3,8)+'/'+STR(YEAR(dDataRef),4)

wnPag    := 0
nRow1    := 3000
Enter1   := CHR(13)+CHR(10)

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont6   := TFont():New("Lucida Console"    ,9,6 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
oPrint:SetPaperSize(09)
oPrint:Setup()

//Busca informações com base no GMR
A00 := "  SELECT * "	+ Enter1
A00 += "  FROM "+	RetSqlName("ZZX") +" AS ZZX "	+ Enter1
A00 += "  WHERE ZZX_FILIAL = '" + xFilial("ZZX") + "' AND " 	+ Enter1
A00 += "        SUBSTRING(ZZX_DATA,1,6) = '" + SUBSTR(DTOS(dDataRef),1,6) + "' AND "	+ Enter1
A00 += "        ZZX_EMP = '" + cEmpAnt+cFilAnt+"N" + "' AND "	+ Enter1
A00 += "        ZZX.D_E_L_E_T_ = ' ' "	+ Enter1
A00 += "  ORDER BY  ZZX_DTRESC, ZZX_CLVL, ZZX_NOME "	+ Enter1

If chkfile("A00")
	DbSelectArea("A00")
	DbCloseArea()
EndIf
TcQuery A00 New Alias "A00"

dDataRef :=  StoD(A00->ZZX_DATA)

fImpCabec()

DbSelectArea("A00")
DbGoTop()
ProcRegua(RecCount())

cClvlAnt   := ''
nComisTot  := 0
nComisVTot := 0
nComTot    := 0
nIrTot     := 0
nDescTot   := 0
nDescT2    := 0

nComisTT  := 0
nComisVTT := 0
nComVTT   := 0
nIrTT     := 0
nDescTT   := 0
nDescTT2  := 0

nComisTP  := 0
nComisVTP := 0
nComVTP   := 0

nTotal    := 0

lPassei   := .T.
lResumo   := .F.

While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Atualizando....    Tempo: "+cTempo)
	
	IF !EMPTY(A00->ZZX_DTRESC) .AND. lPassei
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		xf_Item := +;
		Padr(SPACE(45)                                                                   				            ,45)+"  "+;
		Padr("TOTAL"              	                                                              				    ,18)+"  "+;
		Padl(Transform(nComisTot,"@E 999,999,999.99")                                       			       		,14)+"  "+;
		Padl(Transform(nComisVTot,   "@E 999,999.99")                                       			       		,12)+"  "+;
		Padl(Transform(nComTot,  "@E 999,999,999.99")                                          			       		,14)+"  "+;
		Padl(Transform(nIrTot,        "@E 99,999.99")            					                                ,14)+"  "+;
		Padl(Transform((nComisTot + nComisVTot) - nIrTot,  "@E 999,999,999.99")                                     ,14)+"  "+;
		Padl(Transform(nDescTot,  "@E 999,999.99")                       							                ,12)+"  "+;
		Padl(Transform(nDescT2,   "@E 999,999.99")                       							                ,12)+"  "+;
		Padl(Transform((nComisTot + nComisVTot) - nIrTot - nDescTot - nDescT2,  "@E 999,999,999.99")                ,14)+"  "+;
		Padr(SPACE(45)                                                                   				            ,45)+"  "+;
		Padl(SPACE(100) 																						    ,100)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
		nRow1 += 025
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		If nRow1 > 2100
			fImpRoda()
			fImpCabec()
		EndIf
		
		nComisTot  := 0
		nComisVTot := 0
		nComTot    := 0
		nIrTot     := 0
		nDescTot   := 0
		nDescT2    := 0
		lPassei    := .F.
		cClvlAnt   := ''
		
		nRow1 += 050
		oPrint:Say  (nRow1 , 0010,"NÃO PAGAR COMISSÃO DOS VALORES ABAIXO:" ,oFont12)
		nRow1 += 100
		
		If nRow1 > 2100
			fImpRoda()
			fImpCabec()
		EndIf
	ENDIF
	
	IF cClvlAnt <> A00->ZZX_CLVL .AND. lPassei
		IF cClvlAnt <> ''
			oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
			nRow1 += 050
		ENDIF
		IF cClvlAnt == ''
			nRow1 -= 025
		ENDIF
		
		oPrint:Say  (nRow1 , 0010,"CLASSE DE VALOR - "+A00->ZZX_CLVL ,oFont12)
		nRow1 += 050
		oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
		nRow1 += 050
		
		If nRow1 > 2100
			fImpRoda()
			fImpCabec()
		EndIf
	ENDIF
	
	//Verifica se existe mais de um representante com mesmo CGC/CNPJ/CPF
	DbSelectArea("SA3")
	DbSetOrder(1)
	DbSeek(xFilial("SA3")+A00->ZZX_VEND)
	
	DbSelectArea("SA3")
	DbSetOrder(3)
	DbSeek(xFilial("SA3")+SA3->A3_CGC)
	cCgc := SA3->A3_CGC
	DbSkip()
	IF ALLTRIM(SA3->A3_CGC) == ALLTRIM(cCgc)
		cMarca := '*'
	ELSE
		cMarca := ' '
	ENDIF
	
	A01 := "  SELECT A3_CGC, SUM((ZZX_COMIS+ZZX_COMISV)*ZZX_IR/100) AS VAL_IR"	+ Enter1
	A01 += "  FROM "+	RetSqlName("ZZX") +" AS ZZX, "+	RetSqlName("SA3") +" AS SA3 "	+ Enter1
	A01 += "  WHERE ZZX_FILIAL = '" + xFilial("ZZX") + "' AND "	+ Enter1
	A01 += "        SUBSTRING(ZZX_DATA,1,6) = '" + SUBSTR(DTOS(dDataRef),1,6) + "' AND "	+ Enter1
	A01 += "        A3_CGC = '" + cCgc + "' AND "	+ Enter1
	A01 += "        ZZX_VEND = A3_COD AND 	 "	+ Enter1
	A01 += "        ZZX_EMP = '" + cEmpAnt+cFilAnt+"N" +"' AND "	+ Enter1
	A01 += "        ZZX.D_E_L_E_T_ = ' '   AND "	+ Enter1
	A01 += "        SA3.D_E_L_E_T_ = ' '   "	+ Enter1
	A01 += "  GROUP BY A3_CGC "	+ Enter1
	A01 += "  ORDER BY A3_CGC "	+ Enter1
	
	If chkfile("A01")
		DbSelectArea("A01")
		DbCloseArea()
	EndIf
	TcQuery A01 New Alias "A01"
	
	IF A01->VAL_IR < 10.00
		nValIR := 0
	ELSE
		nValIR := ((A00->ZZX_COMIS + A00->ZZX_COMISV)*A00->ZZX_IR/100)
	ENDIF

	DbSelectArea("SA2")
	DbSetOrder(3)
	DbSeek(xFilial("SA2")+cCgc)
	
	IF lPassei
		xf_Item := +;
		Padr(A00->ZZX_NOME                                                        				                                     ,45)+"  "+;
		Padr(cMarca+A00->ZZX_VEND  	                                                                        				         ,18)+"  "+;
		Padl(Transform(A00->ZZX_COMIS,"@E 999,999.99")                                                              				 ,14)+"  "+;
		Padl(Transform(A00->ZZX_COMISV,"@E 999,999.99")                                                              				 ,12)+"  "+;
		Padl(Transform(A00->ZZX_COMIS+ A00->ZZX_COMISV,"@E 999,999.99")                                                				 ,14)+"  "+;
		Padl(Transform(nValIR,"@E 99,999.99")                                   					                                 ,14)+"  "+;
		Padl(Transform((A00->ZZX_COMIS + A00->ZZX_COMISV) - If (SA2->A2_SIMPNAC == "1", 0, nValIR),  "@E 999,999.99")                                                ,14)+"  "+;
		Padl(Transform(A00->ZZX_DESCON,  "@E 999,999.99")                       							                         ,12)+"  "+;
		Padl(Transform(A00->ZZX_DESC2 ,  "@E 999,999.99")                       					                    		     ,12)+"  "+;
		Padl(Transform((A00->ZZX_COMIS + A00->ZZX_COMISV) - If (SA2->A2_SIMPNAC == "1", 0, nValIR) - A00->ZZX_DESCON - A00->ZZX_DESC2,  "@E 999,999.99")             ,14)+"  "+;		
		Padr(fGetBanco(cCgc)                                                                                                         ,05)+"  "+;
		Padr(SA2->A2_SIMPNAC                                                                                                         ,07)+"  "+;		
		Padl(A00->ZZX_OBS																						                     ,87)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
		nRow1 += 050
	ELSE
		xf_Item := +;
		Padr(A00->ZZX_NOME                                                               				         ,45)+"  "+;
		Padr(A00->ZZX_VEND         	                                                              				 ,18)+"  "+;
		Padl(Transform(A00->ZZX_COMIS,"@E 999,999.99")                                          				 ,14)+"  "+;
		Padl(Transform(A00->ZZX_COMISV,"@E 999,999.99")                                          				 ,12)+"  "+;
		Padl(Transform(A00->ZZX_COMIS+A00->ZZX_COMISV,"@E 999,999.99")                             				 ,14)
		oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
		nRow1 += 050
	ENDIF 
	
	IF EMPTY(A00->ZZX_DTRESC)
		DbSelectArea("_TRAB")
		_TRAB->(DBSetOrder(1))
		IF !DbSeek(cCgc)
			
			DbSelectArea("_TRAB")
			Reclock("_TRAB",.T.)
			_TRAB->CNPJ     := cCgc
			_TRAB->NOME     := A00->ZZX_NOME
			_TRAB->BANCO    := fGetBanco(cCgc)
			_TRAB->SIMPNAC  := SA2->A2_SIMPNAC
			_TRAB->VLRBRUT  := A00->ZZX_COMIS
			_TRAB->COMISVAR := A00->ZZX_COMISV
			_TRAB->VLRTOT   := A00->ZZX_COMIS+ A00->ZZX_COMISV
			_TRAB->IR       := nValIR
			_TRAB->VLRLIQ   := (A00->ZZX_COMIS + A00->ZZX_COMISV) - If (SA2->A2_SIMPNAC == "1", 0, nValIR)			
			_TRAB->DESCTEL  := A00->ZZX_DESCON
			_TRAB->DESCOUT  := A00->ZZX_DESC2			
			_TRAB->VLRPAG   := (A00->ZZX_COMIS + A00->ZZX_COMISV) - If (SA2->A2_SIMPNAC == "1", 0, nValIR) - A00->ZZX_DESCON - A00->ZZX_DESC2
			_TRAB->OBS		:= A00->ZZX_OBS				
			MsUnLock()
		ELSE
			DbSelectArea("_TRAB")
			Reclock("_TRAB",.F.)
			_TRAB->VLRBRUT  := _TRAB->VLRBRUT + A00->ZZX_COMIS
			_TRAB->COMISVAR := _TRAB->COMISVAR + A00->ZZX_COMISV
			_TRAB->VLRTOT   := _TRAB->VLRTOT + A00->ZZX_COMIS+ A00->ZZX_COMISV
			_TRAB->IR       := _TRAB->IR + nValIR
			_TRAB->VLRLIQ   := _TRAB->VLRLIQ + (A00->ZZX_COMIS + A00->ZZX_COMISV) - If (SA2->A2_SIMPNAC == "1", 0, nValIR)
			_TRAB->DESCTEL  := _TRAB->DESCTEL + A00->ZZX_DESCON
			_TRAB->DESCOUT  := _TRAB->DESCOUT+ A00->ZZX_DESC2
			_TRAB->VLRPAG   := _TRAB->VLRPAG + (A00->ZZX_COMIS + A00->ZZX_COMISV) - If (SA2->A2_SIMPNAC == "1", 0, nValIR) - A00->ZZX_DESCON - A00->ZZX_DESC2
			//_TRAB->OBS		:= A00->ZZX_OBS		
			MsUnLock()
		ENDIF
		nComisTT  := nComisTT    + A00->ZZX_COMIS
		nComisVTT := nComisVTT   + A00->ZZX_COMISV
		nComVTT   := nComVTT     + (A00->ZZX_COMISV + A00->ZZX_COMIS)
		nIrTT     := nIrTT       + nValIR
		nDescTT   := nDescTT     + A00->ZZX_DESCON
		nDescTT2  := nDescTT2    + A00->ZZX_DESC2
	ENDIF
	
	cClvlAnt   := A00->ZZX_CLVL
	nComisTot  := nComisTot  + A00->ZZX_COMIS
	nComisVTot := nComisVTot + A00->ZZX_COMISV
	nComTot    := nComTot    + (A00->ZZX_COMISV	+ A00->ZZX_COMIS)
	nIrTot     := nIrTot     + nValIR
	nDescTot   := nDescTot   + A00->ZZX_DESCON
	nDescT2    := nDescT2    + A00->ZZX_DESC2
	
	nComisTP   := nComisTP   + A00->ZZX_COMIS
	nComisVTP  := nComisVTP  + A00->ZZX_COMISV
	nComVTP    := nComVTP    + (A00->ZZX_COMISV + A00->ZZX_COMIS)

	nTotal     := nTotal + A00->ZZX_COMIS + A00->ZZX_COMISV
	
	If nRow1 > 2100
		fImpRoda()
		fImpCabec()
	EndIf
	
	DbSelectArea("A00")
	DbSkip()
End

//( Thiago Dantas - 03/03/15) -> Não estava imprimindo totais quando não tinha recisão.
fImpTotais()

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2100
	fImpRoda()
	fImpCabec()
EndIf

nRow1 += 075

If nRow1 > 2100
	fImpRoda()
	fImpCabec()
EndIf

xf_Item := +;
Padr(SPACE(45)                                                                 				              ,52)+"  "+;
Padr("TOTAL PARCIAL"       	                                                            				  ,13)+"  "+;
Padl(Transform(nComisTP ,"@E 999,999,999.99")                                      			       		  ,14)+"  "+;
Padl(Transform(nComisVTP,"@E 999,999.99")                                      			       		  	  ,12)+"  "+;
Padl(Transform(nComVTP,	 "@E 999,999,999.99")                                      			       		  ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
nRow1 += 100

If nRow1 > 2100
	fImpRoda()
	fImpCabec()
EndIf

xf_Item := +;
Padr(SPACE(45)                                                                 				              ,52)+"  "+;
Padr("TOTAL GERAL"       	                                                            				  ,13)+"  "+;
Padl(Transform(nTotal ,"@E 999,999,999.99")                                      			       		  ,14)
oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
nRow1 += 150

If nRow1 > 2100
	fImpRoda()
	fImpCabec()
EndIf

oPrint:Say  (nRow1 , 1200,"AUTORIZAÇÃO DE PAGAMENTO:" ,oFont12)
nRow1 += 150
oPrint:Say  (nRow1 , 1200,"_________________________" ,oFont12)
nRow1 += 050

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

//Inserido por Wanisay para imprimir o resumo de pagamento por representnate para o contas a pagar.
fImpResumo()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Wanisay William       ¦ Data ¦ 14.09.10 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()
Enter1   := CHR(13)+CHR(10)
fCabec   := '          Comissões dos Títulos Recebidos no mês: '+SUBSTR(ALLTRIM(U_MES(dDataTit)),3,8)+'/'+STR(YEAR(dDataTit),4) //+ '          Pagas em: '+ DToC(dDataRef)
fCabec2  := '          Pagas em: '+ DToC(dDataRef)   //Alltrim(SUBSTR(ALLTRIM(U_MES(dDataRef)),3,8))+'/'+STR(YEAR(dDataRef),4)

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0500,0150 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1   , 0030 ,Padc(fCabec,120)                        ,oFont10)
oPrint:Say  (nRow1+20 ,2950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+15 ,3100 ,StrZero(wnPag,4)                        ,oFont7)
nRow1 += 075
oPrint:Say  (nRow1   , 0030 ,Padc(fCabec2,133)                       ,oFont10)
nRow1 += 150

xf_Titu := +;
Padr("Nome Representante"         ,45)+"  "+;
Padr(" Código ou CNPJ"            ,14)+"      "+;
Padl("Valor Bruto"                ,14)+"  "+;
Padl("Comis Var"                  ,12)+"  "+;
Padl("Valor Total"                ,14)+"  "+;
Padl("IR Recolher"             	  ,14)+"  "+;
Padl("Valor Líq NF"           	  ,14)+"  "+;
Padl("Desc.Tel"                   ,12)+"  "+;
Padl("Out.Desc"                   ,12)+"  "+;
Padl("Total à Pagar"              ,14)+"  "+;
Padl("Banco"					  ,05)+"  "+;
Padl("Simples"					  ,07)+"  "+;
Padl("Observações"                ,87)

oPrint:Say  (nRow1 ,0010 ,xf_Titu   ,oFont7)
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
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
oPrint:Say  (2300+30 , 010,"Prog.: BIA498"                                        ,oFont7)
oPrint:Say  (2300+30 ,2500,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return

Static Function fGetBanco(cCgc)
Local aArea := GetArea()
Local cRet := ""

DbSelectArea("SA2")
DbSetOrder(3)
If SA2->(DbSeek(xFilial("SA2") + cCgc))
	
	If !Empty(SA2->A2_BANCO)
		cRet := SA2->A2_BANCO
	Else
		cRet := "---"
	EndIf
	
EndIf

RestArea(aArea)

Return(cRet)
//---------------------------------------------------------------------------------
Static Function fImpTotais()

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

IF !lResumo
	xf_Item := +;
	Padr(SPACE(45)                                                                   				            ,45)+"  "+;
	Padr("TOTAL"              	                                                              				    ,18)+"  "+;
	Padl(Transform(nComisTot,"@E 999,999,999.99")                                       			       		,14)+"  "+;
	Padl(Transform(nComisVTot,   "@E 999,999.99")                                       			       		,12)+"  "+;
	Padl(Transform(nComTot,  "@E 999,999,999.99")                                          			       		,14)+"  "+;
	Padl(Transform(nIrTot,        "@E 99,999.99")            					                                ,14)+"  "+;
	Padl(Transform((nComisTot + nComisVTot) - nIrTot,  "@E 999,999,999.99")                                     ,14)+"  "+;
	Padl(Transform(nDescTot,  "@E 999,999.99")                       							                ,12)+"  "+;
	Padl(Transform(nDescT2,   "@E 999,999.99")                       							                ,12)+"  "+;
	Padl(Transform((nComisTot + nComisVTot) - nIrTot - nDescTot - nDescT2,  "@E 999,999,999.99")                ,14)+"  "+;
	Padr(SPACE(45)                                                                   				            ,45)+"  "+;
	Padl(SPACE(100) 																						    ,100)
ELSE
	xf_Item := +;
	Padr(SPACE(45)                                                                   				            ,45)+"  "+;
	Padr("TOTAL"              	                                                              				    ,18)+"  "+;
	Padl(Transform(nComisTT ,"@E 999,999,999.99")                                       			       		,14)+"  "+;
	Padl(Transform(nComisVTT,"@E 999,999.99")                                       			       		    ,12)+"  "+;
	Padl(Transform(nComVTT,  "@E 999,999,999.99")                                          			       		,14)+"  "+;
	Padl(Transform(nIrTT,    "@E 99,999.99")            					                                    ,14)+"  "+;
	Padl(Transform((nComisTT + nComisVTT) - nIrTT,  "@E 999,999,999.99")                                        ,14)+"  "+;
	Padl(Transform(nDescTT,  "@E 999,999.99")                       							                ,12)+"  "+;
	Padl(Transform(nDescTT2, "@E 999,999.99")                       							                ,12)+"  "+;
	Padl(Transform((nComisTT + nComisVTT) - nIrTT - nDescTT - nDescTT2,  "@E 999,999,999.99")                   ,14)+"  "+;
	Padr(SPACE(45)                                                                   				            ,45)+"  "+;
	Padl(SPACE(100) 																						    ,100)
ENDIF

oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
nRow1 += 025
oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

nComisTot  := 0
nComisVTot := 0
nComTot    := 0
nIrTot     := 0
nDescTot   := 0
nDescT2    := 0
lPassei    := .F.
cClvlAnt   := ''

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpResumo ¦ Autor ¦ Wanisay William     ¦ Data ¦ 01.03.16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpResumo()

fCabec   := '          Comissões dos Títulos Recebidos no mês: '+SUBSTR(ALLTRIM(U_MES(dDataTit)),3,8)+'/'+STR(YEAR(dDataTit),4)//+'          Pagas em: '+ DToC(dDataRef)
fCabec2  := '          Pagas em: ' + SUBSTR(ALLTRIM(U_MES(dDataRef)),3,8)+'/'+STR(YEAR(dDataRef),4)
wnPag    := 0
nRow1    := 3000
Enter1   := CHR(13)+CHR(10)

CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont6   := TFont():New("Lucida Console"    ,9,6 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont12  := TFont():New("Lucida Console"    ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16  := TFont():New("Lucida Console"    ,9,16,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
oPrint:SetLandscape()
oPrint:SetPaperSize(09)
oPrint:Setup()

fImpCabec()
lResumo := .T.

DbSelectArea("_TRAB")
_TRAB->(DBSetOrder(2))
DbGotop()

While !Eof()
	
	If nRow1 > 2100
		fImpRoda()
		fImpCabec()
	EndIf
	
	xf_Item := +;
	Padr(_TRAB->NOME                                                        				                                     ,45)+"  "+;
	Padr(Transform(_TRAB->CNPJ,"@R 99.999.999/9999-99")                                                   				         ,18)+"  "+;
	Padl(Transform(_TRAB->VLRBRUT,"@E 999,999,999.99")                                                             				 ,14)+"  "+;
	Padl(Transform(_TRAB->COMISVAR,"@E 999,999.99")                                                              				 ,12)+"  "+;
	Padl(Transform(_TRAB->VLRTOT,"@E 999,999.99")                                                               				 ,14)+"  "+;
	Padl(Transform(_TRAB->IR,"@E 99,999.99")                                   					                                 ,14)+"  "+;
	Padl(Transform(_TRAB->VLRLIQ,  "@E 999,999.99")       						                                                 ,14)+"  "+;
	Padl(Transform(_TRAB->DESCTEL,  "@E 999,999.99")                       							                             ,12)+"  "+;
	Padl(Transform(_TRAB->DESCOUT ,  "@E 999,999.99")                       					                    		     ,12)+"  "+;
	Padl(Transform(_TRAB->VLRPAG,  "@E 999,999.99") 																             ,14)+"  "+;
	Padl(_TRAB->BANCO								                                                               				 ,05)+"  "+;
	Padl(_TRAB->SIMPNAC								                                                               				 ,07)+"  "+;	
	Padl(_TRAB->OBS																							                     ,87)
	
	//
	//Padl(SPACE(100) 																						                     ,87)
	oPrint:Say  (nRow1 ,0010 ,xf_Item ,oFont7)
	nRow1 += 050
	
	DbSelectArea("_TRAB")
	dBskip()
END

oPrint:Line (nRow1+40, 010, nRow1+40, 3550)
nRow1 += 050

If nRow1 > 2100
	fImpRoda()
	fImpCabec()
EndIf

fImpTotais()

oPrint:EndPage()
oPrint:Preview()

fApagaTemp()

Return

/*/
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fApagaTemp ³ Autor ³ Wanisay                			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apaga as tabelas temporarias.    					      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
/*/
Static Function fApagaTemp()
_TRAB->(DbCloseArea())
Ferase(cArqTrab+".DBF")
Ferase(cArqTrab+".001")
Ferase(cArqTrab+".002")
Return