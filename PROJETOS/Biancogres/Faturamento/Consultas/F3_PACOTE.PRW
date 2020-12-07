#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³F3PACOTE  ³ Autor ³ Artur Antunes         ³ Data ³ 27.07.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³Consulta Especifica							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³BIANCOGRES                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

static cSX5_ZHRet := "" 
static aLinSX5_ZH := {}

user Function F3PACOTE()     

	local aArea     := GetArea()
	local oDlg		:= nil 
	local oCombo	:= nil 
	local oButPesq  := nil 
	local oGet		:= nil
	local oButOK	:= nil 
	local oButCan 	:= nil 
	local nLargBot	:= 30  
	local nAltBot	:= 11
	local nInterv   := 3 
	local nTempInt  := 0  
	local nVertBot  := 250
	Local nd
	private lCheck  := .f.
	private nPos    := 1  
	private cPesq	:= space(100)
	private aCombo	:= {"Codigo","Descricao"}
	private cCombo	:= ""
	private oBrowse := nil  
	private oboOK   := LoadBitmap(GetResources(),'LBTICK')    
	private oboNO   := LoadBitmap(GetResources(),'LBNO')   
	private aCamLab := {''," Codigo"," Descricao"}
	private aCamTam := {15,35,300}

	cSX5_ZHRet := ""
	if empty(aLinSX5_ZH)
		Processa( {|| CarregaPar() },"Aguarde...","Carregando Parametros...")
	else
		for nd:=1 to len(aLinSX5_ZH)
			aLinSX5_ZH[nd,1] := 'NO'
		next nd
	endif

	oDlg:=MSDialog():New(0,0,530,700,"Pacotes de Produtos",,,,,CLR_BLACK,,,,.T.) 

	oCombo   := tComboBox():New(3,3,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCombo,200,10,oDlg,,{|| OrdBrowse() },,,,.T.,,,,,,,,,'cCombo')
	oGet     := TGet():New(17,3,{|u| if(PCount()>0,cPesq:=u,cPesq)},oDlg,200,10,,,,,,,,.T.,,,,,,,,,,'cPesq')
	oButPesq := TButton():New(3,205,'Pesquisar',oDlg,{|| pesqBrow()},40,11,,,,.T.)

	// Marca / Desmarca - todos
	oCheck1 := TCheckBox():New(41,04,'',{|| lCheck},oDlg,15,15,,{|| ( lCheck:=!lCheck,MarDesAll(lCheck) )},,,,,,.T.,,,)
	oSay1   := tSay():new(41 ,12,{|| "Marcar/Desmarcar Todos"},oDlg,,,,,,.T.,,,100,10)  

	oBrowse := TWBrowse():New( 50,03,350,190,,aCamLab,aCamTam, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse:SetArray(aLinSX5_ZH) 
	oBrowse:bLine:={||{  Iif(aLinSX5_ZH[oBrowse:nAt,01]=='OK',oboOK,oboNO), aLinSX5_ZH[oBrowse:nAt,02],aLinSX5_ZH[oBrowse:nAt,03] }}      
	oBrowse:bLDblClick := {|| Iif(aLinSX5_ZH[oBrowse:nAt,01]=='OK',aLinSX5_ZH[oBrowse:nAt,01]:='NO',aLinSX5_ZH[oBrowse:nAt,01]:='OK') }

	nTempInt += nInterv
	oButOK   := TButton():New(nVertBot,nTempInt,'OK',oDlg,{|| fRetPacote(),oDlg:End() },nLargBot,nAltBot,,,,.T.) 
	nTempInt += nInterv + nLargBot
	oButCan  := TButton():New(nVertBot,nTempInt,'Cancelar',oDlg,{|| cSX5_ZHRet:="",oDlg:End() },nLargBot,nAltBot,,,,.T.)

	oDlg:activate(,,,.T.)

	RestArea(aArea) 
Return .T.


user Function F3RETPAC() //Retorno da Consulta
return cSX5_ZHRet


static function CarregaPar()

	Local aAreax   := GetArea()
	local cQuery   := ''
	local nTotReg  := 0  
	local nContReg := 0 
	local cTab     := GetNextAlias() 

	BeginSql alias cTab
		%noparser%    
		SELECT X5.X5_CHAVE,X5.X5_DESCRI
		FROM %table:SX5% (NOLOCK) X5
		WHERE X5.D_E_L_E_T_ = ''
		AND X5.X5_TABELA = 'ZH' 
	EndSql
	dbselectarea(cTab)
	Count To nTotReg 
	ProcRegua(nTotReg)
	(cTab)->(dbgotop()) 

	While !(cTab)->(EOF())
		nContReg++
		IncProc("Carregando - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	
		AADD( aLinSX5_ZH, { "", Alltrim((cTab)->X5_CHAVE), alltrim((cTab)->X5_DESCRI) } )  
		(cTab)->(dbskip())
	enddo
	RestArea(aAreax)
return    


static function OrdBrowse() // ordena Browse--------------------------------------------------------
	if cCombo == aCombo[2]  
		aSort( aLinSX5_ZH,,,{ |x,y| ( x[3]+x[2] ) < ( y[3]+y[2] ) } ) 
		oBrowse:GoBottom()
		oBrowse:GoTop() 
	else
		aSort( aLinSX5_ZH,,,{ |x,y| ( x[2]+x[3] ) < ( y[2]+y[3] ) } ) 
		oBrowse:GoBottom()
		oBrowse:GoTop() 
	endif	
return       


static function pesqBrow() // realiza a busca da pesquisa no array e posiciona o ponteiro -------------------   
	if cCombo == aCombo[2] 
		nPos:= ASCANX(aLinSX5_ZH,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		if nPos == 0
			oBrowse:SetFocus() 
			oBrowse:GoPosition(1) 
			nPos:= ASCANX(aLinSX5_ZH,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		endif   
		oBrowse:SetFocus()
		if nPos > 0
			oBrowse:GoPosition(nPos) 
		endif	
	else
		nPos:= ASCANX(aLinSX5_ZH,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)  
		if nPos == 0
			oBrowse:SetFocus() 
			oBrowse:GoPosition(1) 
			nPos:= ASCANX(aLinSX5_ZH,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)  
		endif   
		oBrowse:SetFocus() 
		if nPos > 0
			oBrowse:GoPosition(nPos)
		endif
	endif	
return 


static function fContMark()
	local ntotmark := 0
	Local nh
	for nh:=1 to len(aLinSX5_ZH)
		if aLinSX5_ZH[nh,1] == 'OK'
			ntotmark ++
		endif
	next nh	
return ntotmark    


static function fRetPacote()

	Local nk

	cSX5_ZHRet := ""
	for nk:=1 to len(aLinSX5_ZH)
		if aLinSX5_ZH[nk,1] <> 'OK'
			loop
		endif
		cSX5_ZHRet += aLinSX5_ZH[nk,2]+";"
	next nk 
return	


static function MarDesAll(pCheck)
	local nTempLin := oBrowse:nAt 
	Local nx
	for nx := 1 to len(aLinSX5_ZH)
		aLinSX5_ZH[nx,1]:= iif(pCheck,'OK','NO')
	next nx 
	oBrowse:GoPosition(len(aLinSX5_ZH))
	oBrowse:GoPosition(nTempLin)
return  
