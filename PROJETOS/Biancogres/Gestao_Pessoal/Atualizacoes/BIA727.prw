#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030
#DEFINE MAXITEM   010                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2 044                                                // Máximo de produtos para a pagina 2 (caso nao utilize a opção de impressao em verso)
#DEFINE MAXITEMP3 015                                                // Máximo de produtos para a pagina 2 (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMP4 022                                                // Máximo de produtos para a pagina 2 (caso contenha main info cpl que suporta a primeira pagina)
#DEFINE MAXITEMC  012                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN 110                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG    006                                                // Máximo de dados adicionais na primeira página
#DEFINE MAXMSG2   019                                                // Máximo de dados adicionais na segunda página
#DEFINE MAXBOXH   800                                                // Tamanho maximo do box Horizontal
#DEFINE MAXBOXV   600
#DEFINE INIBOXH   -10
#DEFINE MAXMENL   080                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXVALORC 008                                                // Máximo de caracteres por linha de valores numéricos

User Function BIA727()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA727
Empresa   := Biancogres Cerâmica S/A
Data      := 18/06/13
Uso       := Gestão de Pessoal
Aplicação := Browser para cadastro Calendário de Feriádos Administrativos
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

cHInicio := Time()
fPerg := "BIA727"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
ValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

cCadastro := "Calendário de Feriados - ADM"
aRotina   := { {"Pesquisar"     ,"AxPesqui"	  ,0,1},;
{               "Visualizar"    ,"AxVisual"	  ,0,2},;
{               "Incluir"       ,"AxInclui"	  ,0,3},;
{               "Alterar"       ,"AxAltera"	  ,0,4},;
{               "Excluir"       ,"AxDeleta"	  ,0,5},;
{               "Imprimir"      ,"U_BIA727A"  ,0,6},;
{               "Compensar"     ,"U_BIA727B"  ,0,6} }

dbSelectArea("Z27")
Set Filter to dtos(Z27_DATREF) >= MV_PAR01+"0101" .and. dtos(Z27_DATREF) <= MV_PAR01+"1231"
dbSetOrder(1)
dbGoTop()

mBrowse(06,01,22,75,"Z27")

dbSelectArea("Z27")
Set filter to

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA727A   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 20/06/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Imprimir calendário                                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA727A()

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

Private aArea           := GetArea()
Private lAdjustToLegacy := .T.  // Usado para montar o Objeto Printer
Private lDisableSetup   := .T.  // Usado para montar o Objeto Printer
Private lzServer        := .F.
Private lzViewPDF       := .T.

Private zpDirLocal      := "c:\temp\"

Private nHPage
Private nVPage
Private nLine
Private nBaseTxt
Private nBaseCol

Private oCaledFr
Private PixelX
Private PixelY
Private oSetup
Private nConsNeg      := 0.40 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
Private nConsTex      := 0.38 // Constante para concertar o cálculo retornado pelo GetTextWidth.
Private oBrush        := TBrush():New( , CLR_BLACK )

Private fNmRel := "calendferiado"

If !lIsDir( zpDirLocal )
	MakeDir( zpDirLocal )
EndIf

oCaledFr := FWMsPrinter():New( fNmRel+".rel", IMP_PDF, lAdjustToLegacy, , lDisableSetup, , , , lzServer, , , lzViewPDF)
PixelX   := oCaledFr:nLogPixelX()
PixelY   := oCaledFr:nLogPixelY()

oFont20n   := TFontEx():New(oCaledFr,"Arial",20,20,.T.,.T.,.F.)
oFont20    := TFontEx():New(oCaledFr,"Arial",20,20,.F.,.T.,.F.)
oFont18n   := TFontEx():New(oCaledFr,"Arial",18,18,.T.,.T.,.F.)
oFont18    := TFontEx():New(oCaledFr,"Arial",18,18,.F.,.T.,.F.)
oFont15n   := TFontEx():New(oCaledFr,"Lucida Console",15,15,.T.,.T.,.F.)
oFont15    := TFontEx():New(oCaledFr,"Arial",15,15,.F.,.T.,.F.)
oFont10n   := TFontEx():New(oCaledFr,"Arial",10,10,.T.,.T.,.F.)
oFont10    := TFontEx():New(oCaledFr,"Arial",10,10,.F.,.T.,.F.)
oFont12n   := TFontEx():New(oCaledFr,"Arial",12,12,.T.,.T.,.F.)
oFont12    := TFontEx():New(oCaledFr,"Arial",12,12,.F.,.T.,.F.)
oFntEx12   := TFontEx():New(oCaledFr,"Lucida Console",12,12,.T.,.T.,.F.)
oFont09n   := TFontEx():New(oCaledFr,"Arial",09,09,.T.,.T.,.F.)
oFont09    := TFontEx():New(oCaledFr,"Arial",09,09,.F.,.T.,.F.)
oFont08n   := TFontEx():New(oCaledFr,"Arial",08,08,.T.,.T.,.F.)
oFont08    := TFontEx():New(oCaledFr,"Arial",08,08,.F.,.T.,.F.)

// Ordem obrigátoria de configuração do relatório
oCaledFr:SetResolution(72)
oCaledFr:SetPortrait()
oCaledFr:SetPaperSize(DMPAPER_A4)
oCaledFr:SetMargin(60,60,60,60)       // nEsquerda, nSuperior, nDireita, nInferior
oCaledFr:cPathPDF := zpDirLocal       // Caso seja utilizada impressão em IMP_PDF, define diretório de gravação

xPrntPdf := .T.
If Alltrim(oCaledFr:cPrinter) <> "PDF" .or. Len(Alltrim(oCaledFr:cPrinter)) > 3
	xPrntPdf := .F.
EndIf

xQdPag := 1
xLnhOld := 0

HY001 := " SELECT Z27_DATREF,
HY001 += "        Z27_FERIAD,
HY001 += "        Z27_EXPEDI,
HY001 += "        Z27_CREDIT,
HY001 += "        Z27_DEBITO,
HY001 += "        Z27_DESCRI
HY001 += "   FROM " + RetSqlName("Z27")
HY001 += "  WHERE Z27_FILIAL = '"+xFilial("Z27")+"'
HY001 += "    AND SUBSTRING(Z27_DATREF,1,4) = '"+MV_PAR01+"'
HY001 += "    AND D_E_L_E_T_ = ' '
HYcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,HY001),'HY01',.T.,.T.)
dbSelectArea("HY01")
dbGoTop()
While !Eof()
	
	If xQdPag == 1
		
		oCaledFr:StartPage()
		nHPage := oCaledFr:nHorzRes()
		nHPage *= (300/PixelX)
		nHPage -= HMARGEM
		nVPage := oCaledFr:nVertRes()
		nVPage *= (300/PixelY)
		nVPage -= VBOX
		nBaseTxt := 50
		nBaseCol := 50
		
	EndIf
	
	nLine  := xLnhOld
	nLine  += IIF(xPrntPdf, 150, 150)
	
	// O limite da Margem é nHPage - 270
	/*
	oCaledFr:Box(nLine+000, nBaseCol, nLine+070, nHPage - 770, "-4")
	oCaledFr:Say(nLine+055, nBaseTxt+050, Padc("LISTA DE PRESENÇA / EFICÁCIA DE TREINAMENTO",050) , oFont20n:oFont)
	
	oCaledFr:Box(nLine+067, nBaseCol     , nLine+0102, nHPage - 1830, "-4")
	oCaledFr:Say(nLine+095, nBaseTxt     , Padc("Revisão Anterior: 10/12/2010",080)     , oFont08n:oFont)
	oCaledFr:Box(nLine+067, nHPage - 1830, nLine+0102, nHPage - 1260, "-4")
	oCaledFr:Say(nLine+095, nHPage - 1830, Padc("Revisão Atual: 05/10/2012",095)        , oFont08n:oFont)
	oCaledFr:Box(nLine+067, nHPage - 1260, nLine+0102, nHPage - 0770, "-4")
	oCaledFr:Say(nLine+095, nHPage - 1260, Padc("Revisão: 05",090)                      , oFont08n:oFont)
	oCaledFr:Box(nLine+000, nHPage - 0770, nLine+104, nHPage - 267, "-4")
	oCaledFr:Say(nLine+067, nHPage - 0770, Padc("UN-FO-REH-??",025)                     , oFont15n:oFont)
	*/
	
	nLine += 150
	oCaledFr:Say(nLine    , nBaseTxt     , Padc("CALENDÁRIO DE FERIADOS - "+MV_PAR01,135)    , oFont18n:oFont)
	nLine += 100
	
	xf_Titu := +;
	Padc("Dia"                                                                      ,20)+" "+;
	Padc("Feriado"                                                                  ,20)+" "+;
	Padc("Expediente"                                                               ,15)+" "+;
	Padl("Crédito"                                                                  ,07)+" "+;
	Padl("Débito"                                                                   ,07)+" "+;
	Padr("Descrição"                                                                ,50)
	nLine += 100
	oCaledFr:Box(nLine-050, nBaseCol, nLine+020, nHPage - 270, "-4")
	oCaledFr:Say(nLine, nBaseTxt, xf_Titu         , oFntEx12:oFont)
	oCaledFr:Line(nLine-050, 0360, nLine+017, 0360)
	oCaledFr:Line(nLine-050, 0720, nLine+017, 0720)
	oCaledFr:Line(nLine-050, 0970, nLine+017, 0970)
	oCaledFr:Line(nLine-050, 1125, nLine+017, 1125)
	oCaledFr:Line(nLine-050, 1250, nLine+017, 1250)
	
	xhCred := 0
	xhDebt := 0
	dbSelectArea("HY01")
	While !Eof()
		
		xyDia := StrZero(Day(stod(HY01->Z27_DATREF)),2) +"/"+ Substr(MesExtenso(stod(HY01->Z27_DATREF)),1,3) + "   " + DiaSemana(stod(HY01->Z27_DATREF))
		
		xf_Item := +;
		Padc(xyDia                                                                      ,20)+" "+;
		Padc(Alltrim(HY01->Z27_FERIAD)                                                  ,20)+" "+;
		Padc(IIf(HY01->Z27_EXPEDI == "S", "Sim", "Não")                                 ,15)+" "+;
		Padl(Transform(HY01->Z27_CREDIT, "@E 999.99")                                   ,07)+" "+;
		Padl(Transform(HY01->Z27_DEBITO, "@E 999.99")                                   ,07)+" "+;
		Padr(HY01->Z27_DESCRI                                                           ,50)
		nLine += 069
		oCaledFr:Box(nLine-050, nBaseCol, nLine+020, nHPage - 270, "-4")
		oCaledFr:Say(nLine, nBaseTxt, xf_Item         , oFntEx12:oFont)
		oCaledFr:Line(nLine-050, 0360, nLine+017, 0360)
		oCaledFr:Line(nLine-050, 0720, nLine+017, 0720)
		oCaledFr:Line(nLine-050, 0970, nLine+017, 0970)
		oCaledFr:Line(nLine-050, 1125, nLine+017, 1125)
		oCaledFr:Line(nLine-050, 1250, nLine+017, 1250)
		
		xhCred += HY01->Z27_CREDIT
		xhDebt += HY01->Z27_DEBITO
		
		dbSelectArea("HY01")
		dbSkip()
		
	End
	
	xf_Tot := +;
	Padc(""                                                                                   ,20)+" "+;
	Padc(""                                                                                   ,20)+" "+;
	Padc(""                                                                                   ,15)+" "+;
	Padl(Transform(xhCred, "@E 9999.99")                                                      ,07)+" "+;
	Padl(Transform(xhDebt, "@E 9999.99")                                                      ,07)+" "+;
	Padr("( Credito - Debito ) --->>>      " + Transform(xhCred - xhDebt, "@E 99,999.99")     ,50)
	nLine += 069
	oCaledFr:Box(nLine-050, nBaseCol, nLine+020, nHPage - 270, "-4")
	oCaledFr:Say(nLine, nBaseTxt, xf_Tot         , oFntEx12:oFont)
	oCaledFr:Line(nLine-050, 0360, nLine+017, 0360)
	oCaledFr:Line(nLine-050, 0720, nLine+017, 0720)
	oCaledFr:Line(nLine-050, 0970, nLine+017, 0970)
	oCaledFr:Line(nLine-050, 1125, nLine+017, 1125)
	oCaledFr:Line(nLine-050, 1250, nLine+017, 1250)
	
	nLine += 200
	oCaledFr:Say(nLine    , nBaseTxt+0020, "COMPENSAÇÃO:"                       , oFont15n:oFont)
	nLine += 050
	sfDescr := "A partir do dia 02/01/2013 até 11/03/2013, expediente de 07:30 às 18:00. Na sexta 07:30 às 17:00."
	oCaledFr:Say(nLine    , nBaseTxt+0020, sfDescr                              , oFont12:oFont)
	
	nLine += 200
	oCaledFr:Say(nLine    , nBaseTxt+0020, "APROVAÇÕES:"                        , oFont15n:oFont)
	
	nLine += 150
	oCaledFr:Line (nLine, nBaseCol, nLine, 1000)
	nLine += 050
	oCaledFr:Say(nLine  , nBaseCol, Padc("Diretor Presidente (Biancogres)",110)                , oFont12n:oFont)
	nLine -= 050
	oCaledFr:Line (nLine, nBaseCol+1100, nLine, nHPage - 267)
	nLine += 050
	oCaledFr:Say(nLine  , nBaseCol+1100, Padc("Diretor Presidente (Incesa)",110)               , oFont12n:oFont)
	
	nLine += 150
	oCaledFr:Line (nLine, nBaseCol, nLine, 1000)
	nLine += 050
	oCaledFr:Say(nLine  , nBaseCol, Padc("Diretor Comercial (Biancogres)",110)                 , oFont12n:oFont)
	nLine -= 050
	oCaledFr:Line (nLine, nBaseCol+1100, nLine, nHPage - 267)
	nLine += 050
	oCaledFr:Say(nLine  , nBaseCol+1100, Padc("Diretor Administrativo/Financeiro",110)         , oFont12n:oFont)
	
	xQdPag := 1
	xLnhOld := 0
	oCaledFr:EndPage()
	
End

oCaledFr:Preview()

FreeObj(oCaledFr)
oCaledFr := Nil
RestArea(aArea)

Ferase(HYcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(HYcIndex+OrdBagExt())          //indice gerado
HY01->(dbCloseArea())

Return


/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA727B   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 20/06/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Gravar compensação                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA727B()

Private oDlgCompF
Private oButton1
Private oGet1
Private cGet1 := "A partir do dia 02/01/2013 até 11/03/2013, expediente de 07:30 às 18:00. Na sexta 07:30 às 17:00."
Private oSay1
Private vConfGrv := .F.

cGet1 := cGet1+Space( 250 - Len(cGet1) )

DEFINE MSDIALOG oDlgCompF TITLE "Compensação de Feriados" FROM 000, 000  TO 100, 500 COLORS 0, 16777215 PIXEL

@ 009, 008 SAY oSay1 PROMPT "Compensação:" SIZE 043, 007 OF oDlgCompF COLORS 0, 16777215 PIXEL
@ 028, 009 MSGET oGet1 VAR cGet1 SIZE 230, 010 OF oDlgCompF COLORS 0, 16777215 PIXEL
@ 008, 202 BUTTON oButton1 PROMPT "Gravar" SIZE 037, 012 OF oDlgCompF ACTION (vConfGrv := .T. , oDlgCompF:End()) PIXEL

ACTIVATE MSDIALOG oDlgCompF CENTERED

If vConfGrv
	// Inserir aqui tratamento para gravação no banco de dados. Em 20/06/12: ainda não existia o campo criado
EndIf

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
aAdd(aRegs,{cPerg,"01","Filtra Ano          ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
