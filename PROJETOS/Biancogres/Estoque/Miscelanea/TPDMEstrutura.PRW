#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


Class TPDMEstrutura From LongClassName

Data cArquivo
Data aRegistros
Data cPDM

//Posicoes arquivo de estrutura de grupos
Data nP1_Grupo
Data nP1_DescGrupo
Data nP1_Subgrupo
Data nP1_DescSubgrupo
Data nP1_Familia
Data nP1_DescFamilia

//Posicoes arquivo de PDM
Data nP2_Codigo
Data nP2_Grupo
Data nP2_Subgrupo
Data nP2_Familia
Data nP2_C_Ordem
Data nP2_C_Nome
Data nP2_C_Obrig
Data nP2_C_ReqAbr
Data nP2_C_Ncpdes
Data nP2_V_Descr
Data nP2_V_Abrev

//Posicoes arquivo de PRODUTO
Data nP3_Tipo
Data nP3_CodAnt
Data nP3_Descricao
Data nP3_Grupo
Data nP3_NCM
Data nP3_UM
Data nP3_MarcaRefer
Data nP3_InfAdicional
Data nP3_Carac01

Data aLstErros

Method New() Constructor

Method ImpArqPadrao()
Method fPergunte(nOpc)

Method ImpEstGrupos()
Method PrcImpEGrupos()

Method ImpEstPDM()
Method PrcImpEPDM()

Method ImpProdutos()
Method ImpProdProc()
Method PrdAddErro()

EndClass


Method New() Class TPDMEstrutura	

	::cArquivo 		:= ""
	::aRegistros 	:= {}
	::cPDM			:= ""
	::aLstErros		:= {}

	//Posicoes arquivo de grupos
	::nP1_Grupo			:= 01
	::nP1_DescGrupo		:= 02
	::nP1_Subgrupo		:= 03
	::nP1_DescSubgrupo	:= 04
	::nP1_Familia		:= 05
	::nP1_DescFamilia	:= 06

	//Posicoes arquivo de PDM
	::nP2_Codigo		:= 01
	//::nP2_Tipo			:= 02
	::nP2_Grupo			:= 03
	::nP2_Subgrupo		:= 04
	::nP2_Familia		:= 05
	::nP2_C_Ordem		:= 06
	::nP2_C_Nome		:= 07
	::nP2_C_Obrig		:= 08
	::nP2_C_ReqAbr		:= 09
	::nP2_C_Ncpdes		:= 10
	::nP2_V_Descr		:= 11
	::nP2_V_Abrev		:= 12

	//Posicoes arquivo de PRODUTO
	::nP3_Tipo			:= 01
	::nP3_CodAnt		:= 02
	::nP3_Descricao		:= 03
	::nP3_Grupo			:= 04
	::nP3_NCM			:= 05
	::nP3_UM			:= 06
	::nP3_MarcaRefer	:= 07
	::nP3_InfAdicional	:= 08
	::nP3_Carac01		:= 09

Return(Self)


/*/{Protheus.doc} ImpArqPadrao
@description Metodo para ler arquivo Excel e importar os dados para vetor padronizado
@author Fernando Rocha
@since 03/08/2018
@version 1.0
@type function
/*/
Method ImpArqPadrao() Class TPDMEstrutura

	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local nImport			:= 0
	Local nErros			:= 0
	Local nBrancos			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local nx, ny

	::aRegistros := {}

	ProcRegua(0) 

	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(::cArquivo)

	If Len(aArquivo) > 0 

		aWorksheet 	:= aArquivo[1]	
		nTotLin		:= len(aWorksheet)

		ProcRegua(nTotLin)

		For nx := 1 to len(aWorksheet) 

			IncProc("Processando: " + StrZero(nx,6) + "/" + StrZero(nTotLin,6))	

			If nx == 1  //LINHA DOS NOMES DE CAMPOS

				aCampos := aWorksheet[nx]
				For ny := 1 to len(aCampos)
					aCampos[ny] := AllTrim(Upper(aCampos[ny]))
				Next ny

			ElseIf nx == 2  //Titulos dos campos
			Else

				aLinha    := aWorksheet[nx]
				aItem     := {}
				cConteudo := ''

				SX3->(DbSetOrder(2))

				For ny := 1 to Len(aLinha)

					If Len(aCampos) >= ny 

						cConteudo := aLinha[ny]

						If !Empty(aCampos[ny]) .And. SX3->(DbSeek(Padr(aCampos[ny],10),.T.))

							Do Case

								case SX3->X3_TIPO == "D"
								cConteudo := SubStr(cConteudo,1,10)
								cConteudo := stod(StrTran(cConteudo, "-", ""))

								case SX3->X3_TIPO == "N"
								cConteudo := Val(cConteudo)

								case SX3->X3_TIPO == "C"
								cConteudo := Padr(cConteudo,TamSX3(aCampos[ny])[1])

							EndCase

							AADD(aItem,{ aCampos[ny] , cConteudo , nil })

						Else

							AADD(aItem,{ aCampos[ny] , AllTrim(cConteudo) , nil })  //se nao achar o campo adiciona o conteudo da coluna como texto

						EndIf

					EndIf

				Next ny	

				If len(aItem) <= 0
					nErros++
				ElseIf Empty(aItem[1][2])  //se conteudo da primeira celula vazio ignorar
					nBrancos++
				Else
					AAdd(::aRegistros,aItem)
				EndIf

				nImport++

			EndIf

		Next nx

	EndIf

	MsgInfo(Alltrim(Str(nImport))+" linhas lidas."+CRLF+;
	IIF(nErros>0,CRLF+Alltrim(Str(nErros))+" linhas com ERRO de estrutura.","")+CRLF+;
	IIF(nBrancos>0,CRLF+Alltrim(Str(nBrancos))+" linhas VAZIAS.",""))

Return()


//Parametros
Method fPergunte(nOpc) Class TPDMEstrutura

	Local aPergs 	:= {}
	Local cLoad	    := 'PDM' + AllTrim(FunName())
	Local cFileName := cLoad
	Local aRet		:= {""}

	Default nOpc	:= 0

	::cArquivo := Space(100)

	aAdd( aPergs ,{6,"Arquivo para Importação: " 	,::cArquivo,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )		

	//Importacao de Produtos
	If nOpc == 1

		aRet		:= {"",""}

		aAdd( aPergs ,{1,"PDM: ",Space(9),"@!","","ZD0","",20,.F.})
		aAdd( aPergs ,{1,"Revisão: ",Space(3),"@!","","","",20,.F.})

	EndIf

	If ParamBox(aPergs ,"Importar Arquivo",aRet,,,,,,,cFileName,.T.,.T.)      
		::cArquivo  := aRet[1]

		If nOpc == 1

			::cPDM := aRet[2]+aRet[3]

		EndIf

	Endif

Return 


/*/{Protheus.doc} ImpEstGrupos
@description Metodo para ler arquivo Excel para as tabelas da estrutura de grupos do PDM
@author Fernando Rocha
@since 03/08/2018
@version 1.0
@type function
/*/
Method ImpEstGrupos() Class TPDMEstrutura

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 

	::fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Planilha da Estrutura de Grupos do PDM."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros."))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| ::fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de Estrutura de Grupos'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(::cArquivo ) .and. File(::cArquivo )

			Processa({ || ::ImpArqPadrao() },"Aguarde...","Carregando Arquivo...",.F.)

			If Len(::aRegistros) > 0
				Processa({ || ::PrcImpEGrupos() },"Aguarde...","Importando Dados...",.F.)
			EndIf

		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

Method PrcImpEGrupos() Class TPDMEstrutura

	Local nx, ny
	Local oGrupo
	Local oSubgrupo
	Local _cGrupo	
	Local nTot := len(::aRegistros)

	ProcRegua(nTot)			

	For nx := 1 To len(::aRegistros)

		IncProc("Processando: " + StrZero(nx,6) + "/" + StrZero(nTot,6))

		_cGrupo := ::aRegistros[nx][::nP1_Grupo][2]

		If ( oGrupo <> Nil .And. oGrupo:Grupo <> _cGrupo )

			oGrupo:Save()
			oGrupo := Nil

		EndIf

		If ( oGrupo == Nil )

			oGrupo := TPDMGrupo():Get(_cGrupo)
			if Empty(oGrupo:Grupo)

				oGrupo := TPDMGrupo():New()				
				oGrupo:Grupo 		:= _cGrupo
				oGrupo:Descricao 	:= ::aRegistros[nx][::nP1_DescGrupo][2]

			else

				oGrupo:Descricao 	:= ::aRegistros[nx][::nP1_DescGrupo][2]

			endif

		EndIf

		oSubgrupo := oGrupo:AddSubgrupo(::aRegistros[nx][::nP1_Subgrupo][2], ::aRegistros[nx][::nP1_DescSubgrupo][2])

		oSubgrupo:AddFamilia(::aRegistros[nx][::nP1_Familia][2], ::aRegistros[nx][::nP1_DescFamilia][2]) 

	Next nx

	If ( oGrupo <> Nil )

		oGrupo:Save()
		oGrupo := Nil

	EndIf

Return


/*/{Protheus.doc} ImpEstPDM
@description Metodo para ler arquivo Excel para as tabelas do PDM
@author Fernando Rocha
@since 06/08/2018
@version 1.0
@type function
/*/
Method ImpEstPDM() Class TPDMEstrutura

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 

	::fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de Planilha de carga do PDM."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros."))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| ::fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação do PDM'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(::cArquivo ) .and. File(::cArquivo )

			Processa({ || ::ImpArqPadrao() },"Aguarde...","Carregando Arquivo...",.F.)

			If Len(::aRegistros) > 0
				Processa({ || ::PrcImpEPDM() },"Aguarde...","Importando Dados...",.F.)
			EndIf

		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

Method PrcImpEPDM() Class TPDMEstrutura

	Local nx, ny
	Local oPDM
	Local oCarac
	Local _cCodigo	
	Local nTot := len(::aRegistros)
	Local nCont

	ProcRegua(nTot)		

	nCont := 0	

	For nx := 1 To len(::aRegistros)

		nCont++

		IncProc("Processando: " + StrZero(nx,6) + "/" + StrZero(nTot,6))

		_cCodigo := ::aRegistros[nx][::nP2_Codigo][2]

		If ( oPDM <> Nil .And. (oPDM:Codigo <> _cCodigo) )
			oPDM:Save()
			oPDM := Nil
			nCont := 0
		EndIf

		If ( oPDM == Nil )

			oPDM := TPDMModelo():Get(_cCodigo)

			if Empty(oPDM:Codigo)

				oPDM := TPDMModelo():New()				
				oPDM:Codigo 		:= _cCodigo
				oPDM:Revisao	 	:= "001"
				oPDM:Grupo			:= ::aRegistros[nx][::nP2_Grupo][2]
				oPDM:Subgrupo		:= ::aRegistros[nx][::nP2_Subgrupo][2]
				oPDM:Familia		:= ::aRegistros[nx][::nP2_Familia][2]

			endif

		EndIf

		oCarac := oPDM:AddCaracteristica(::aRegistros[nx][::nP2_C_Ordem][2], ::aRegistros[nx][::nP2_C_Nome][2], ::aRegistros[nx][::nP2_C_Obrig][2], ::aRegistros[nx][::nP2_C_ReqAbr][2], ::aRegistros[nx][::nP2_C_Ncpdes][2])

		oCarac:AddValor(::aRegistros[nx][::nP2_V_Descr][2], ::aRegistros[nx][::nP2_V_Abrev][2]) 

	Next nx

	If ( oPDM <> Nil )
		oPDM:Save()
		oPDM := Nil
		nCont := 0
	EndIf

Return


/*/{Protheus.doc} ImpProdutos
@description Metodo para ler arquivo Excel para criar produtos vinculados ao PDM
@author Fernando Rocha
@since 21/08/2018
@version 1.0
@type function
/*/
Method ImpProdutos() Class TPDMEstrutura

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Local cMsgRet
	Local nx

	::fPergunte(1)

	AADD(aSays, OemToAnsi("Rotina para importação de Planilha de PRODUTOS do PDM."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros."))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| ::fPergunte(1) } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação de PRODUTOS'), aSays, aButtons ,,,500)

	If lConfirm

		If Empty(::cPDM)
			MsgStop('Obrigatorio informar o codigo do PDM!')
			Return
		EndIf

		If !empty(::cArquivo ) .and. File(::cArquivo )

			Processa({ || ::ImpArqPadrao() },"Aguarde...","Carregando Arquivo...",.F.)

			If Len(::aRegistros) > 0
				Processa({ || ::ImpProdProc() },"Aguarde...","Importando Dados...",.F.)
			EndIf

			If Len(::aLstErros) > 0

				cMsgRet := ""
				For nx := 1 to Len(::aLstErros)

					If ::aLstErros[nx][1] > 0

						__nLin := ::aLstErros[nx][3]
						If __nLin > 0
							__nLin += 2
						EndIf

						cMsgRet += "LINHA: "+AllTrim(Str(__nLin))+" ERRO => Codigo: "+AllTrim(Str(::aLstErros[nx][1])) + CRLF + ::aLstErros[nx][2] + CRLF

					EndIf

				Next nx

				U_FROPMSG("TPDMEstrutura:ImpProdutos()","Importação Finalizada, alguns problemas foram encontrados: "+CRLF+CRLF+cMsgRet)

			Else

				U_FROPMSG("TPDMEstrutura:ImpProdutos()","Importação Finalizada, nenhum problema encontrado.")

			EndIf

		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf	

Return

Method ImpProdProc() Class TPDMEstrutura

	Local nx, ny
	Local oPDM
	Local nTot := len(::aRegistros)
	Local nCont
	Local cAliasTmp
	Local _oPDMProduto
	Local oValor
	Local nPVal	
	Local _aRet
	Local _aLstRetAux := {}

	Local _cTipo		
	Local _cCodAnt 	
	Local _Grupo		
	Local _NCM		
	Local _UM			
	Local _MarcaRefer	
	Local _InfAdicional

	ZD0->(DbSetOrder(1))		
	If !ZD0->(DbSeek(XFilial("ZD0")+::cPDM))

		_aRet := {10, "PDM/Revisao informado não encontrado.", 0}
		AAdd(_aLstRetAux, _aRet)
		::PrdAddErro(_aLstRetAux)

		Return()
	EndIf

	_oPDMProduto := TPDMProduto():New()
	_oPDMProduto:oPDM:Grupo 	:= ZD0->ZD0_GRUPO
	_oPDMProduto:oPDM:Subgrupo	:= ZD0->ZD0_SUBGRU
	_oPDMProduto:oPDM:Familia 	:= ZD0->ZD0_FAMILI

	If !( _oPDMProduto:SetPDM() )

		_aRet := {11, "Erro ao carregar dados do PDM.", 0}
		AAdd(_aLstRetAux, _aRet)
		::PrdAddErro(_aLstRetAux)

		Return()
	EndIf

	ProcRegua(nTot)		

	nCont := 0	

	For nx := 1 To len(::aRegistros)

		_aLstRetAux := {}

		nCont++

		IncProc("Processando: " + StrZero(nx,6) + "/" + StrZero(nTot,6))

		_cTipo			:= ::aRegistros[nx][::nP3_Tipo][2]
		_cCodAnt 		:= ::aRegistros[nx][::nP3_CodAnt][2]
		_Grupo			:= ::aRegistros[nx][::nP3_Grupo][2]		
		_NCM			:= ::aRegistros[nx][::nP3_NCM][2]		
		_UM				:= ::aRegistros[nx][::nP3_UM][2]		
		_MarcaRefer		:= ::aRegistros[nx][::nP3_MarcaRefer][2]
		_InfAdicional	:= ::aRegistros[nx][::nP3_InfAdicional][2]

		_oPDMProduto:Tipo		:= _cTipo
		_oPDMProduto:cNCM		:= STRTRAN(_NCM,".","")
		_oPDMProduto:cGrupoSBM	:= _Grupo
		_oPDMProduto:cUM 		:= _UM

		_cCodAnt := PADR(AllTrim(_cCodAnt),TamSX3("B1_COD")[1])
		_oPDMProduto:cCodAnt	:= _cCodAnt

		SB1->(DbSetOrder(1))
		If !SB1->(DbSeek(XFilial("SB1")+_cCodAnt))

			_aRet := {1, "Produto antigo codigo '"+AllTrim(_cCodAnt)+"' nao existe.", nx}
			AAdd(_aLstRetAux, _aRet)
			::PrdAddErro(_aLstRetAux)

			loop
		EndIf

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp

			select top 1 B1_COD from %Table:SB1% where B1_FILIAL = %XFilial:SB1% and B1_CODANT = %Exp:_cCodAnt% and %NotDel%

		EndSql

		If !(cAliasTmp)->(Eof())

			_aRet := {2, "Produto antigo '"+AllTrim(_cCodAnt)+"' ja substituido.", nx}
			AAdd(_aLstRetAux, _aRet)
			::PrdAddErro(_aLstRetAux)

			(cAliasTmp)->(DbCloseArea())		
			loop
		EndIf
		(cAliasTmp)->(DbCloseArea())


		If Len(::aRegistros[nx]) < ( ::nP3_Carac01 + Len(_oPDMProduto:oPDM:aCaracteristicas) - 1)

			_aRet := {3, "Colunas da planilha não correspodem a todas as características do PDM.", nx}
			AAdd(_aLstRetAux, _aRet)
			::PrdAddErro(_aLstRetAux)

			loop
		EndIf		

		//Adicionando Caracteristicas
		_oPDMProduto:aLstValCar := {}

		For ny := 1 To Len(_oPDMProduto:oPDM:aCaracteristicas)		

			_cValorCarac := AllTrim(::aRegistros[nx][::nP3_Carac01 - 1 + ny][2])

			If !_oPDMProduto:oPDM:aCaracteristicas[ny]:IsBloqueado()

				If !Empty(_cValorCarac)

					oValor	:= Nil
					nPVal 	:= AScan(_oPDMProduto:oPDM:aCaracteristicas[ny]:aValores, {|o| AllTrim(o:Descricao) == _cValorCarac})

					If ( nPVal > 0 )

						oValor := _oPDMProduto:oPDM:aCaracteristicas[ny]:aValores[nPVal]

						aAux := {}
						aAdd(aAux, oValor:Sequencia)
						aAdd(aAux, oValor:Item)

						aAdd(_oPDMProduto:aLstValCar, aAux)					

					Else

						_aRet := {4, "Valor "+_cValorCarac+" da Característica "+AllTrim(Str(nPVal))+"-"+_oPDMProduto:oPDM:aCaracteristicas[ny]:Nome+" não encontrado no PDM.", nx}
						AAdd(_aLstRetAux, _aRet)

						loop			

					EndIf

				EndIf				

			EndIf

		Next ny

		//Adicionando Marcas
		_oPDMProduto:aLstMarcas := {}

		If !Empty(_MarcaRefer)

			_aMarcas 	:= StrToKArr(AllTrim(_MarcaRefer),"|") 
			_aInfAdic 	:= StrToKArr(AllTrim(_InfAdicional),"|")

			For ny := 1 To Len(_aMarcas)

				_nSepar := At("=",_aMarcas[ny])

				_cMarca 	:= IIF( _nSepar > 0 , SubStr(_aMarcas[ny],1,_nSepar-1), AllTrim(_aMarcas[ny]))
				_cRefer 	:= IIF( _nSepar > 0 , SubStr(_aMarcas[ny],_nSepar+1), "")
				_cInfAdic 	:= ""

				If Len(_aInfAdic) >= ny

					_cInfAdic := AllTrim(_aInfAdic[ny])

				EndIf

				aAux := {}
				aAdd(aAux, "")			//Codigo
				aAdd(aAux, _cMarca)		//Descricao
				aAdd(aAux, _cRefer)		//Referencia
				aAdd(aAux, _cInfAdic)	//InfAd

				aAdd(_oPDMProduto:aLstMarcas, aAux)	

			Next ny	

		EndIf	


		If (Len(_aLstRetAux) <= 0)

			If !( _oPDMProduto:Valid()[1] )

				_aRet := {5, _oPDMProduto:cErro, nx}
				AAdd(_aLstRetAux, _aRet)

			EndIf

			If (Len(_aLstRetAux) <= 0)

				_aRet := _oPDMProduto:NovoCodigo()

				SB1->(DbSetOrder(1))
				If (_aRet[1] == 0 .And. SB1->(DbSeek(XFilial("SB1")+_oPDMProduto:cNewCod)))

					_oPDMProduto:Salvar()
					_oPDMProduto:IncluiZD7(_oPDMProduto:cNewCod)
					_oPDMProduto:SalvarMarcas(_oPDMProduto:cNewCod)

				Else

					AAdd(_aLstRetAux, {_aRet[1], _aRet[2], nx})

				EndIf

			EndIf

		EndIf

		::PrdAddErro(_aLstRetAux)

	Next nx

Return()


Method PrdAddErro(_aLstRetAux) Class TPDMEstrutura

	Local nx

	For nx := 1 To Len(_aLstRetAux)

		AAdd(::aLstErros, _aLstRetAux[nx])

	Next nx

Return