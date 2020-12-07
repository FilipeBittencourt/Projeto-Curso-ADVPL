#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} FiltroF3
@description Funcao Generica para criacao de telas de pesquisa F3
@author Fernando Rocha
@since 01/01/2016
@param cTitulo, characters, Titulo da janela da consulta  
@param cQuery, characters, A consulta SQL que vem do parametro cQuery não pode retornar um outro nome para o campo pesquisado, pois a rotina valida o nome do campo real 
@param nTamCpo, numeric, Tamanho do campo de pesquisar,se não informado assume 30 caracteres
@param cAlias, characters, Alias da tabela, ex: SA1    
@param cCodigo, characters, Conteudo do campo que chama o filtro  
@param cCpoChave, characters, Nome do campo que será utilizado para pesquisa, ex: A1_CODIGO 
@param cTitCampo, characters, Titulo do label do campo
@param cMascara, characters, Mascara do campo, ex: "@!"
@param cRetCpo, characters, Campo que receberá o retorno do filtro
@param nColuna, numeric, Coluna que será retornada na pesquisa, padrão coluna 1
@type function
/*/
User Function FiltroF3(cTitulo,cQuery,nTamCpo,cAlias,cCodigo,cCpoChave,cTitCampo,cMascara,cRetCpo,nColuna,aColsPesq)

	Local nLista  
	Local cCampos 	:= ""
	Local bCampo		:= {}
	Local nCont		:= 0
	Local bTitulos	:= {}
	Local aCampos 	:= {}
	Local cTabela 
	Local cCSSGet		:= "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
	Local cCSSButton 	:= "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"
	Local cCSSButF3	:= "QPushButton {background-color: #ffffff;margin: 2px;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 3px; border-color: #C0C0C0;font: Normal 10px Arial;padding: 3px;} QPushButton:pressed {background-color: #e6e6f9;border-style: inset;}"
	Local nX

	Private _oLista	:= nil
	Private _oDlg 	:= nil
	Private _oCodigo
	Private _cCodigo 	
	Private _aDados 	:= {}
	Private _nColuna	:= 0
	Private _lMultPesq	:= .F.
	Private _aColsPesq	:= aColsPesq

	Default cTitulo 	:= ""
	Default cCodigo 	:= ""
	Default nTamCpo 	:= 30
	Default _nColuna 	:= 1
	Default cTitCampo	:= RetTitle(cCpoChave)
	Default cMascara	:= PesqPict('"'+cAlias+'"',cCpoChave)
	Default aColsPesq	:= {}

	_nColuna	:= nColuna

	If Len(aColsPesq) > 0
		_lMultPesq := .T.
	EndIf

	If Empty(cAlias) .OR. Empty(cCpoChave) .OR. Empty(cRetCpo) .OR. Empty(cQuery)
		MsgStop("Os parametro cQuery, cCpoChave, cRetCpo e cAlias são obrigatórios!","Erro")
		Return
	Endif

	_cCodigo := Space(nTamCpo)

	If !Empty(cCodigo) 
		_cCodigo := PADR(cCodigo,nTamCpo)
	EndiF

	cTabela:= CriaTrab(Nil,.F.)
	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)

	(cTabela)->(DbGoTop())
	If (cTabela)->(Eof())
		MsgStop("Não há registros para serem exibidos!","Atenção")
		Return
	Endif

	Do While (cTabela)->(!Eof())
		/*Cria o array conforme a quantidade de campos existentes na consulta SQL*/
		cCampos	:= ""
		aCampos 	:= {}
		For nX := 1 TO FCount()
			bCampo := {|nX| Field(nX) }
			If ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "M" .OR. ValType((cTabela)->&(EVAL(bCampo,nX)) ) <> "U"
				if ValType((cTabela)->&(EVAL(bCampo,nX)) )=="C"
					cCampos += "'" + (cTabela)->&(EVAL(bCampo,nX)) + "',"
				ElseIf ValType((cTabela)->&(EVAL(bCampo,nX)) )=="D"
					cCampos +=  DTOC((cTabela)->&(EVAL(bCampo,nX))) + ","
				Else
					cCampos +=  (cTabela)->&(EVAL(bCampo,nX)) + ","
				Endif

				aadd(aCampos,{EVAL(bCampo,nX),Alltrim(RetTitle(EVAL(bCampo,nX))),"LEFT",30})
			Endif
		Next

		If !Empty(cCampos) 
			cCampos 	:= Substr(cCampos,1,len(cCampos)-1)
			aAdd( _aDados,&("{"+cCampos+"}"))
		Endif

		(cTabela)->(DbSkip())     
	Enddo

	DbCloseArea(cTabela)

	If Len(_aDados) == 0
		MsgInfo("Não há dados para exibir!","Aviso")
		Return
	Endif

	nLista := aScan(_aDados, {|x| alltrim(x[_nColuna]) == alltrim(_cCodigo)})

	iif(nLista = 0,nLista := 1,nLista)

	Define MsDialog _oDlg Title "Consulta Padrão" + IIF(!Empty(cTitulo)," - " + cTitulo,"") From 0,0 To 280, 500 Of oMainWnd Pixel

	oCodigo:= TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,{|| },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
	oCodigo:SetCss(cCSSGet)	
	oButton1 := TButton():New(010, 212," &Pesquisar ",_oDlg,{|| Processa({|| FiltroF3P(M->_cCodigo) },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cCSSButton)	

	_oLista:= TCBrowse():New(26,05,245,90,,,,_oDlg,,,,,{|| _oLista:Refresh()},,,,,,,.F.,,.T.,,.F.,,,.f.)
	nCont := 1
	//Para ficar dinâmico a criação das colunas, eu uso macro substituição "&"
	For nX := 1 to len(aCampos)
		cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDados[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
		nCont++
	Next
	_oLista:SetArray(_aDados)
	_oLista:bWhen 		 := { || Len(_aDados) > 0 }
	_oLista:bLDblClick  := { || FiltroF3R(_oLista:nAt, _aDados, cRetCpo)  }
	_oLista:GoPosition(nLista)
	_oLista:Refresh()

	oButton2 := TButton():New(122, 005," OK "			,_oDlg,{|| Processa({|| FiltroF3R(_oLista:nAt, _aDados, cRetCpo) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cCSSButton)	
	oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cCSSButton)	

	Activate MSDialog _oDlg Centered	
Return(bRet)


Static Function FiltroF3P(cBusca)
	Local i
	Local j
	Local lFind := .F.

	if !Empty(cBusca)
		For i := 1 to len(_aDados)

			If !_lMultPesq

				//Aqui busco o texto exato, mas pode utilizar a função AT() para pegar parte do texto
				if UPPER(Alltrim(_aDados[i,_nColuna]))==UPPER(Alltrim(cBusca))
					//Se encontrar me posiciono no grid e saio do "For"			
					_oLista:GoPosition(i)
					_oLista:Setfocus()
					lFind := .T.
					exit
				Endif

			Else

				//Pesquisa multipla qualquer parte dos campos passados no array _nColuna
				For j := 1 To len(_aColsPesq)

					If UPPER(Alltrim(cBusca)) $ UPPER(Alltrim(_aDados[i,j])) 
						_oLista:GoPosition(i)
						_oLista:Setfocus()
						lFind := .T.
						exit
					EndIf

				Next j

			EndIf

			If lFind
				exit
			Endif

		Next i
	Endif
Return


Static Function FiltroF3R(nLinha,aDados,cRetCpo)

	cCodigo := aDados[nLinha,_nColuna]
	&(cRetCpo) := cCodigo //Uso desta forma para campos como tGet por exemplo.
	//aCpoRet[1] := cCodigo //Não esquecer de alimentar essa variável quando for f3 pois ela e o retorno
	bRet := .T.
	_oDlg:End()  

Return