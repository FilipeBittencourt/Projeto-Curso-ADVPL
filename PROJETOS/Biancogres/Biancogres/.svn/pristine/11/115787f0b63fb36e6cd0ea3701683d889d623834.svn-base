#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"
#include "vkey.ch"

User Function MOV583()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ MOV583   ¦ Autor ¦ Alberto               ¦ Data ¦ 06.07.07 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦  Demonstrativo de Pesagem                                  ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Private oMemo1
Private _oDlg
Private cString
Private xLike
cHInicio := Time()
fPerg := "MOV583"
//ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

Private wnPag := 0
Private	nRow1 := 4000
IF cEmpAnt == '01'
	aBitmap  := "LOGOPRI01.BMP"
ELSE
	aBitmap  := "LOGOPRI05.BMP"
ENDIF

// Foi retirada de uso esta opção em 06/01/14 por Marcos Alberto Soprani, pois a estrutura de dados da tabela Z12 é diferente do que está no relatório.
Aviso('Aviso','Opção indisponível!',{'Ok'})

Return

**********************************************************************************


Private CoF10n   := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
Private CoF10    := TFont():New("Lucida Console"    ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
Private CoF11    := TFont():New("Lucida Console"    ,9,11,.T.,.F.,5,.T.,5,.T.,.F.)
Private oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont9   := TFont():New("Lucida Console"    ,9,9 ,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont10  := TFont():New("Lucida Console"    ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
Private oFont26  := TFont():New("Lucida Console"    ,9,26,.T.,.T.,5,.T.,5,.T.,.F.)

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

vp_PsEnt := 0
vp_PsSai := 0
vp_PsLiq := 0
vp_PsNot := 0
vp_Difer := 0
tt_PsEnt := 0
tt_PsSai := 0
tt_PsLiq := 0
tt_PsNot := 0
tt_Difer := 0
df_Cabec := "Demonstrativo de Pesagem"
oPrint:= TMSPrinter():New( "...: "+df_Cabec+" :..." )
oPrint:SetPortrait()

cTempo := Alltrim(ElapTime(cHInicio, Time()))
IncProc("Armazenando....   Tempo: "+cTempo)

A0001 := " SELECT * "
A0001 += "   FROM "+RetSqlName("Z11")
A0001 += "  WHERE Z11_FILIAL = '"+xFilial("Z11")+"' "
A0001 += "    AND Z11_DATAIN BETWEEN '"+dtos(MV_PAR02)+"' AND '"+dtos(MV_PAR03)+"' "
A0001 += "    AND Z11_PCAVAL BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR05+"' "
If MV_PAR06 == 1
	A0001 += "    AND Z11_MERCAD = 1 "
ElseIf MV_PAR06 == 2
	A0001 += "    AND Z11_MERCAD = 2 "
EndIf
A0001 += "    AND D_E_L_E_T_ = ' ' "
A0001 += " ORDER BY Z11_MERCAD, Z11_PESAGE "
TcQuery A0001 New Alias "A001"

fImpCabec()
dbSelectArea("A001")
dbGoTop()
ProcRegua(RecCount())
While !Eof()
	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Imprimindo....    Tempo: "+cTempo)
	
	vp_PsEnt := 0
	vp_PsSai := 0
	vp_PsLiq := 0
	vp_PsNot := 0
	vp_Difer := 0
	nRow1 += 075
	oPrint:Say  (nRow1 ,0050 ,IIF(A001->Z11_MERCAD == 1, "Entrega", "Retirada")       ,oFont14)
	nRow1 += 075
	dy_Mercad := A001->Z11_MERCAD
	While !Eof() .and. dy_Mercad == A001->Z11_MERCAD
		nRow1 += 025
		If nRow1 > 3250
			fImpRoda()
			fImpCabec()
		EndIf
		xf_MotPla := A001->Z11_PCAVAL+"-"+A001->Z11_MOTORI
		xf_PesoNf := IIF(A001->Z11_PESINF <> 0, A001->Z11_PESINF, A001->Z11_PESCAL)
		xf_Difere := A001->Z11_PESLIQ - xf_PesoNf
		xf_Item := +;
		Padc(dtoc(stod(A001->Z11_DATAIN))                   ,10)+" "+;
		Padc(dtoc(stod(A001->Z11_DATASA))                   ,10)+" "+;
		Padr(xf_MotPla                                      ,50)+" "+;
		Padl(Transform(A001->Z11_PESOIN,"@E 99999,999")     ,09)+" "+;
		Padl(Transform(A001->Z11_PESOSA,"@E 99999,999")     ,09)+" "+;
		Padl(Transform(A001->Z11_PESLIQ,"@E 99999,999")     ,09)+" "+;
		Padl(Transform(xf_PesoNf       ,"@E 99999,999")     ,09)+" "+;
		Padl(Transform(xf_Difere       ,"@E 99999,999")     ,09)
		oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont8)
		nRow1 += 050
		vp_PsEnt += A001->Z11_PESOIN
		vp_PsSai += A001->Z11_PESOSA
		vp_PsLiq += A001->Z11_PESLIQ
		vp_PsNot += xf_PesoNf
		vp_Difer += xf_Difere
		tt_PsEnt += A001->Z11_PESOIN
		tt_PsSai += A001->Z11_PESOSA
		tt_PsLiq += A001->Z11_PESLIQ
		tt_PsNot += xf_PesoNf
		tt_Difer += xf_Difere
		If MV_PAR01 == 2
			lf_primeiro := .T.
			dbSelectArea("Z12")
			dbSetOrder(1)
			dbSeek(xFilial("Z12")+A001->Z11_PESAGE)
			While !Eof() .and. Z12->Z12_PESAGE == A001->Z11_PESAGE
				If lf_primeiro
					xf_TtNf := +;
					Padr(""                        ,31)+" "+;
					Padr("Sre"                     ,03)+" "+;
					Padr("Nota"                    ,06)+" "+;
					Padr("Cli/For"                 ,07)+" "+;
					Padr("Lj"                      ,02)+" "+;
					Padr("Nome"                    ,40)+" "+;
					Padr("CTR"                     ,06)+" "+;
					Padl("Peso"                    ,10)
					oPrint:Say  (nRow1 ,0050 ,xf_TtNf                               ,oFont8)
					nRow1 += 050
					lf_primeiro := .F.
				EndIf
				If nRow1 > 3250
					fImpRoda()
					fImpCabec()
				EndIf
				If A001->Z11_MERCAD == 1
					cd_CliFor := Posicione("SA2",1,xFilial("SA2")+Z12->Z12_CLIFOR+Z12->Z12_LOJA,"A2_NOME")
				Else
					cd_CliFor := Posicione("SA1",1,xFilial("SA1")+Z12->Z12_CLIFOR+Z12->Z12_LOJA,"A1_NOME")
				EndIf
				xf_ItNf := +;
				Padr(""                                              ,31)+" "+;
				Padr(Z12->Z12_SERIE                                  ,03)+" "+;
				Padr(Z12->Z12_NFISC                                  ,06)+" "+;
				Padr(Z12->Z12_CLIFOR                                 ,07)+" "+;
				Padr(Z12->Z12_LOJA                                   ,02)+" "+;
				Padr(cd_CliFor                                       ,40)+" "+;
				Padr(Z12->Z12_NUMCTR                                 ,06)+" "+;
				Padl(Transform(Z12->Z12_PESLIQ,"@E 999,999.99")      ,10)
				oPrint:Say  (nRow1 ,0050 ,xf_ItNf                               ,oFont8)
				nRow1 += 050
				dbSelectArea("Z12")
				dbSkip()
			End
			oPrint:Line (nRow1-10, 050, nRow1-10, 2350)
		EndIf
		dbSelectArea("A001")
		dbSkip()
	End
	If nRow1 > 3250
		fImpRoda()
		fImpCabec()
	EndIf
	xf_Moda := +;
	Padc("Total"                                       ,10)+" "+;
	Padc(""                                            ,10)+" "+;
	Padr(""                                            ,50)+" "+;
	Padl(Transform(vp_PsEnt       ,"@E 99999,999")     ,09)+" "+;
	Padl(Transform(vp_PsSai       ,"@E 99999,999")     ,09)+" "+;
	Padl(Transform(vp_PsLiq       ,"@E 99999,999")     ,09)+" "+;
	Padl(Transform(vp_PsNot       ,"@E 99999,999")     ,09)+" "+;
	Padl(Transform(vp_Difer       ,"@E 99999,999")     ,09)
	oPrint:Say  (nRow1 ,0050 ,xf_Moda                               ,oFont8)
	nRow1 += 050
End
nRow1 += 050
If nRow1 > 3250
	fImpRoda()
	fImpCabec()
EndIf
xf_Fina := +;
Padc("Total"                                       ,10)+" "+;
Padc("Geral"                                       ,10)+" "+;
Padr(""                                            ,50)+" "+;
Padl(Transform(tt_PsEnt       ,"@E 99999,999")     ,09)+" "+;
Padl(Transform(tt_PsSai       ,"@E 99999,999")     ,09)+" "+;
Padl(Transform(tt_PsLiq       ,"@E 99999,999")     ,09)+" "+;
Padl(Transform(tt_PsNot       ,"@E 99999,999")     ,09)+" "+;
Padl(Transform(tt_Difer       ,"@E 99999,999")     ,09)
oPrint:Say  (nRow1 ,0050 ,xf_Fina                               ,oFont8)
nRow1 += 050
dbSelectArea("A001")
dbCloseArea()

fImpRoda()

oPrint:EndPage()
oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 26.05.06 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

oPrint:StartPage()
wnPag ++
nRow1 := 050
If File(aBitmap)
	oPrint:SayBitmap( nRow1,0050,aBitmap,0600,0100 )
EndIf
nRow1 += 025
oPrint:Say  (nRow1  ,0750 ,df_Cabec                                  ,oFont14)
oPrint:Say  (nRow1+10 ,1950 ,"Página:"                               ,oFont7)
oPrint:Say  (nRow1+05 ,2100 ,Transform(wnPag,"@E 9999")              ,oFont8)
oPrint:Say  (nRow1+60 ,1950 ,"Emissão:"                              ,oFont7)
oPrint:Say  (nRow1+65 ,2140 ,dtoc(dDataBase)                         ,oFont8)
nRow1 += 150
xf_Titu := +;
Padc("Dt.Entrada"              ,10)+" "+;
Padc("Dt.Saida"                ,10)+" "+;
Padr("Motorista"               ,50)+" "+;
Padl("Peso.Ent."               ,09)+" "+;
Padl("Peso.Saí."               ,09)+" "+;
Padl("Peso.Liq."               ,09)+" "+;
Padl("Peso.Nota"               ,09)+" "+;
Padl("Diferença"               ,09)
oPrint:Say  (nRow1 ,0050 ,xf_Titu                               ,oFont8)
oPrint:Line (nRow1+40, 050, nRow1+40, 2350)
nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 26.05.06 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

oPrint:Line (3300, 050, 3300, 2350)
oPrint:Say  (3300+30 , 050,"Prog.: MOV583"                                        ,oFont7)
oPrint:Say  (3300+30 ,1800,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
oPrint:EndPage()
nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.05.06 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local j,i
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,6)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Formato            ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","Sintético","","","","","Analítico","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Da Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Ate Data           ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Da Placa           ?","","","mv_ch4","C",07,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Ate Placa          ?","","","mv_ch5","C",07,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Quanto a Mercadoria?","","","mv_ch1","N",01,0,0,"C","","mv_par06","Entrega","","","","","Retirada","","","","","Ambas","","","","","","","","","","","","","",""})

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
