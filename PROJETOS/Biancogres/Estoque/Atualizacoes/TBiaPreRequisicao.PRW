*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#include "totvs.ch" 
#include "tbiconn.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "vkey.ch"
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

User Function FCLA0016; Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TBiaPreRequisicao	ºAutor  ³Fernando Rocha      º Data ³ 17/09/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Classe para opercaoes da baixa de Pre Requisicao					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  	      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Class TBiaPreRequisicao From LongClassName

Data nRecNo
Data cDoc
Data cTipo
Data dEmissao
Data cCusto
Data cNome
Data cCLVL
Data cEmpresa  
Data aProdutos 
Data oEntEPI // Tiago Rossini Coradini - 23/05/16 - OS: 1130-16 - Carlos Junqueira - Objeto para tratamento de geração automatica de entrega de EPI

Method New(oColetor) Constructor
Method LoadReq(cDoc)
Method AddProduto(cDoc, cProduto, nQtde)
Method ChkConfOk()
Method BaixarReq()

EndClass    

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Construtor da Classe
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß      
Method New(oColetor) Class TBiaPreRequisicao 

	Default oColetor := Nil

	::oEntEPI := TEntregaEPI():New(oColetor)

	::aProdutos := {}	

Return                              

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Carregar a requisicao a ser baixada
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß      
Method LoadReq(cDoc) Class TBiaPreRequisicao

	Local cAliasAux
	Local lOk := .F.

	cAliasAux := GetNextAlias()

	BeginSql Alias cAliasAux

		select * from SZI010 where ZI_FILIAL = '01' and ZI_DOC = %Exp:cDoc% and ZI_BAIXA = 'N' and D_E_L_E_T_ = ''

	EndSql

	(cAliasAux)->(DbGoTop())

	If !(cAliasAux)->(Eof()) 

		::nRecNo	:= (cAliasAux)->R_E_C_N_O_
		::cDoc 		:= (cAliasAux)->ZI_DOC
		::cTipo 	:= (cAliasAux)->ZI_TIPO
		::dEmissao 	:= STOD((cAliasAux)->ZI_EMISSAO)
		::cCusto 	:= (cAliasAux)->ZI_CC
		::cNome		:= (cAliasAux)->ZI_NOME
		::cCLVL		:= (cAliasAux)->ZI_CLVL
		::cEmpresa	:= (cAliasAux)->ZI_EMPRESA

		lOk := .T.

	EndIf                    

	(cAliasAux)->(DbCloseArea())

Return( lOk )

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Adicionar produtos no vetor para baixa
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß      
Method AddProduto(cProduto, nQtde) Class TBiaPreRequisicao

	Local cAliasAux
	Local lOk := .T.  
	Local cErro := ""
	Local _nPos     
	Local _nQuant 
	Local _cDoc := ::cDoc 
	Local _aAreaB1 := SB1->(GetArea())
	Local _aAreaBZ := SBZ->(GetArea())

	cAliasAux := GetNextAlias()

	BeginSql Alias cAliasAux

		select ZJ_COD, B1_DESC, ZJ_QUANT, B1_CONV
		from SZJ010 SZJ
		join SB1010 SB1 on B1_COD = ZJ_COD
		where ZJ_DOC = %EXP:_cDoc% and ZJ_COD = %EXP:cProduto% 
		and SZJ.D_E_L_E_T_ ='' and SB1.D_E_L_E_T_=''

	EndSql  

	If !(cAliasAux)->(Eof())

		//Fernando/Facile em 30/03/2016 - validacao da quantidade da embalagem - OS 4467-15
		If lOk
			SBZ->(DbSetOrder(1))
			If SBZ->(FieldPos("BZ_YINTEGR")) > 0 .And. SBZ->(DbSeek(XFilial("SBZ")+cProduto)) .And. SBZ->BZ_YINTEGR == "S"

				_nMod := nQtde % (cAliasAux)->B1_CONV

				If ( nQtde < (cAliasAux)->B1_CONV ) .Or. ( _nMod <> 0 )

					cErro := "Fator da Embalagem: Quantidade requisitada precisa ser múltipla de "+AllTrim(Str((cAliasAux)->B1_CONV))+"."  
					lOk := .F.

				EndIf

			EndIf 
		EndIf

		If lOk

			_nPos := aScan(::aProdutos,{|x|  x[1] == cProduto})
			If ( _nPos > 0 )

				_nQuant := ::aProdutos[_nPos][3]      

				If ( _nQuant + nQtde ) > (cAliasAux)->ZJ_QUANT

					cErro := "Quantidade acima da Requisição!"
					lOk := .F.

				Else      

					::aProdutos[_nPos][3] += nQtde 
					lOk := .T.		

				EndIf

			Else   

				If ( nQtde ) > (cAliasAux)->ZJ_QUANT

					cErro := "Quantidade acima da Requisição!"
					lOk := .F.

				Else      

					aAdd( ::aProdutos,  { cProduto, (cAliasAux)->B1_DESC, nQtde } )
					lOk := .T.		

				EndIf

			EndIf 

		EndIf     

	Else
		cErro := "Produto inválido/Não existe na Requisição!"
		lOk := .F.
	EndIf             

	RestArea(_aAreaBZ)
	RestArea(_aAreaB1)
	(cAliasAux)->(DbCloseArea())

Return { lOk, cErro }

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Checkar se toda a requesicao ja foi digitada na tela para a baixa. 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß      
Method ChkConfOk() Class TBiaPreRequisicao

	Local cAliasAux
	Local lOk := .T.  
	Local _nPos
	Local _cDoc := ::cDoc

	cAliasAux := GetNextAlias()

	BeginSql Alias cAliasAux

		select ZJ_COD, B1_DESC, ZJ_QUANT
		from SZJ010 SZJ
		join SB1010 SB1 on B1_COD = ZJ_COD
		where ZJ_DOC = %EXP:_cDoc%
		and SZJ.D_E_L_E_T_ ='' and SB1.D_E_L_E_T_=''

	EndSql  

	While !(cAliasAux)->(Eof())

		_nPos := aScan(::aProdutos,{|x|  x[1] == (cAliasAux)->ZJ_COD })
		If ( _nPos <= 0 ) .Or. ( ::aProdutos[_nPos][3] <> (cAliasAux)->ZJ_QUANT )

			lOk := .F.

		EndIf

		(cAliasAux)->(DbSkip())
	EndDo

	(cAliasAux)->(DbCloseArea())

Return ( lOk )


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Baixar a pre-requisicao - copiado/baseado no BIA902 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß      
Method BaixarReq(_cUsuERP) Class TBiaPreRequisicao

	Local cErro
	Local nTM  
	Local _aCab1 		:=	{}
	Local _aItem 		:= 	{}
	Local _atotitem		:=	{}      
	Local cAliasTmp
	Local cAliasTmp2    
	Local _lTransfEmp

	If ::ChkConfOk() 

		SZI->(DbSetOrder(1))
		If !SZI->(DbSeek(XFilial("SZI")+::cDoc))
			Return { .F. , "Requesição não encontrada" }
		EndIf


		If Alltrim(SZI->ZI_TIPO) = "RE"
			nTM := "502"
		Else
			If Alltrim(SZI->ZI_TIPO) == "DN"
				nTM := "005"
			Else
				nTM := "006"
			EndIf
		EndIf

		//Preenche Cabecalho
		_aCab1 :=	{	{"D3_DOC"     ,SZI->ZI_DOC		, NIL},;
		{"D3_TM"      ,nTM				, NIL},;
		{"D3_CC"      ,SZI->ZI_CC		, NIL},;
		{"D3_CLVL"    ,SZI->ZI_CLVL 	, NIL},;
		{"D3_YSI"     ,SZI->ZI_YSI 		, NIL},;
		{"D3_EMISSAO" ,Date()			, NIL}}

		//Agrupa os itens por Empresa Destino
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			SELECT ZJ_EMPDEST
			FROM  %Table:SZJ% (NOLOCK)
			WHERE ZJ_DOC = %Exp:SZI->ZI_DOC% AND ZJ_EMPRESA = %Exp:SZI->ZI_EMPRESA% AND %NOTDEL%
			GROUP BY ZJ_EMPDEST
		EndSql

		//Monta Array com os produtos por Empresa Destino
		While  !(cAliasTmp)->(EOF())

			cAliasTmp2 := GetNextAlias()
			BeginSql Alias cAliasTmp2
				SELECT *
				FROM  %Table:SZJ% (NOLOCK)
				WHERE ZJ_DOC = %Exp:SZI->ZI_DOC% AND ZJ_EMPRESA = %Exp:SZI->ZI_EMPRESA% AND ZJ_EMPDEST = %Exp:(cAliasTmp)->ZJ_EMPDEST% AND %NOTDEL%
				ORDER BY ZJ_EMPRESA, ZJ_EMPDEST
			EndSql

			_atotitem		:=	{}
			While  !(cAliasTmp2)->(EOF())

				//Se a classe de valor de consumo nao pertence a empresa do estoque faz transferencia para temporario
				_lTransfEmp := .F.
				//CTH->(DbSetOrder(1))
				//If (CTH->(DbSeek(XFilial("CTH")+SZI->ZI_CLVL)) .And. !Empty(CTH->CTH_YEMPFL) .And. !Empty((cAliasTmp)->ZJ_EMPDEST) .And. Substr(CTH->CTH_YEMPFL,1,2) <> (cAliasTmp)->ZJ_EMPDEST)
				//	_lTransfEmp := .T.
				//EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula Saldo do Produto, para nao deixar negativo             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(SZI->ZI_TIPO) == "RE"
					_cLocSal := (cAliasTmp2)->ZJ_LOCAL
				ElseIf _lTransfEmp
					_cLocSal := "6T"
				Else
					_cLocSal := ""
				EndIf

				If !Empty(_cLocSal)
					If cEmpAnt == (cAliasTmp)->ZJ_EMPDEST
						//Funcao para calcular o saldo do produto
						aSaldos := CalcEst((cAliasTmp2)->ZJ_COD,_cLocSal,ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente
					Else
						//Armazena a Empresa Original
						cEmpOri := cEmpAnt
						//Altera a "Empresa Original" para "Empresa Destino" - CUIDADO
						cEmpAnt := (cAliasTmp)->ZJ_EMPDEST
						//Funcao para calcular o saldo do produto
						aSaldos := CalcEst((cAliasTmp2)->ZJ_COD,_cLocSal,ddatabase+1) //Somado +1 na database, para dar o saldo do dia corrente
						//Volta a "Empresa Original" - CUIDADO
						cEmpAnt := cEmpOri
					EndIf

					wSALDO := aSaldos[1] - (cAliasTmp2)->ZJ_QUANT

					If wSALDO < 0    

						cErro := "Este produto "+(cAliasTmp2)->ZJ_COD+" não possui saldo suficiente no Armazem: "+_cLocSal+" para atender está Pré-Requisição. Favor verificar!" 
						Return { .F., cErro }

					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Localiza produto no SB1                 					             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+(cAliasTmp2)->ZJ_COD,.F.)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Define a Conta Contabil                 					             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nConta	:= "" 
				If U_B478RTCC(SZI->ZI_CLVL)[2] == "D"
					nConta	:= SB1->B1_YCTRADM

				ElseIf U_B478RTCC(SZI->ZI_CLVL)[2] == "C"
					nConta  := SB1->B1_YCTRIND

				ElseIf U_B478RTCC(SZI->ZI_CLVL)[2] $ "A/I"
					nConta  := "16503" + Substr(SZI->ZI_CLVL,2,8)

				EndIf

				// Em 22/02/17, retirado de USO por Marcos Alberto Soprani, para adequar o sistema a nova regra aplicação de custo e despesa.
				//If Subs(SZI->ZI_CLVL,1,1) $ "1,2,4,5,8"
				//	nConta	:= SB1->B1_YCTRADM
				//ElseIf Subs(SZI->ZI_CLVL,1,1) == "3"
				//	nConta  := SB1->B1_YCTRIND
				//EndIf

				//Valida Unidade de Medida
				If !ExistCpo("SAH",SB1->B1_UM) .Or. !ExistCpo("SAH",SB1->B1_SEGUM)
					cErro := "Favor corrigir a Unidade de Medida do Produto "+Alltrim(SB1->B1_COD)+" pois está incorreta!"
					Return { .F., cErro }
				EndIf

				//Verifica se a Conta Contabil no Cadastro de Produto esta correta
				DbSelectArea("CT1")
				DbSetOrder(1)
				If !DbSeek(xFilial("CT1")+nConta,.T.)
					cErro := "A Conta Contabil "+nConta+" não está correta. Favor verificar o cadastro do produto "+(cAliasTmp2)->ZJ_COD+"."
					Return { .F., cErro }
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Define a Custo                 					               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Alltrim(SZI->ZI_TIPO) == "DU"
					nCusto := 0.01
				EndIF

				IF (cAliasTmp2)->ZJ_APLIC == '4' .AND. !EMPTY((cAliasTmp2)->ZJ_YMELHOR) .AND. Subs(SZI->ZI_CLVL,1,1) == "3"
					nConta := '61301010'
				ENDIF

				/*
				// Em 22/02/17... Por Marcos Alberto Soprani... implementado tratamento para atender a OS effettivo 3351-16 e OS 1546-17 
				If Alltrim((cAliasTmp2)->ZJ_COD) $ "1070007/1070385/1070008" .and. Alltrim(SZI->ZI_CLVL) == "3117" 
				nConta := '61110006'
				EndIf
				*/

				If SB1->B1_GRUPO == '107A' .Or. SB1->B1_GRUPO == '107E' 
					If Alltrim(SZI->ZI_CLVL) == "3117" .Or. Alltrim(SZI->ZI_CLVL) == "3135" .Or. Alltrim(SZI->ZI_CLVL) == "3217
						nConta :=	"61110006" 
					ElseIf Alltrim(SZI->ZI_CLVL) == "3136" 
						nConta	:=	"61110001"
					EndIf
				EndIf

				// Em 06/04/17... Por Marcos Alberto Soprani... implementado tratamento para atender a OS effettivo 1245-17 
				If Substr((cAliasTmp2)->ZJ_COD,1,3) == "107" .and. cEmpAnt == "05" .and. Substr(nConta,1,5) == "6110" 
					nConta := '61108003'
				EndIf

				//Novo metodo de baixa por transferencia - Fernando/Facile em 24/10/2014 - projeto req. de produto comum

				//Se a classe de valor de consumo nao pertence a empresa do estoque faz transferencia para temporario
				IF !_lTransfEmp

					//Preenche os Itens
					_aItem := {}
					aAdd(_aItem,{"D3_COD"	  	,(cAliasTmp2)->ZJ_COD			,NIL})
					aAdd(_aItem,{"D3_UM"	  	,SB1->B1_UM		     			,NIL})
					aAdd(_aItem,{"D3_QUANT"  	,(cAliasTmp2)->ZJ_QUANT    		,NIL})
					aAdd(_aItem,{"D3_LOCAL"  	,(cAliasTmp2)->ZJ_LOCAL		    ,NIL})
					aAdd(_aItem,{"D3_EMISSAO"  	,Date()						    ,NIL})

					If Alltrim(SZI->ZI_TIPO) == "DU"
						aAdd(_aItem,{"D3_CUSTO1" 	,nCusto						,NIL})
					EndIf

					aAdd(_aItem,{"D3_CONTA" 	,nConta							,NIL})
					aAdd(_aItem,{"D3_CC"		,SZI->ZI_CC  				   	,NIL})
					aAdd(_aItem,{"D3_CLVL"		,SZI->ZI_CLVL					,NIL})
					aAdd(_aItem,{"D3_YSI"		,SZI->ZI_YSI					,NIL})
					aAdd(_aItem,{"D3_YMATRIC"	,SZI->ZI_MATRIC					,NIL})
					aAdd(_aItem,{"D3_ITEMCTA"	,SZI->ZI_ITEMCTA		    	,NIL})
					aAdd(_aItem,{"D3_SEGUM"  	,SB1->B1_SEGUM		    		,NIL})
					aAdd(_aItem,{"D3_YTAG"  	,(cAliasTmp2)->ZJ_TAG			,NIL})
					aAdd(_aItem,{"D3_YMELHOR"	,(cAliasTmp2)->ZJ_YMELHOR	    ,NIL})
					aAdd(_aItem,{"D3_YAPLIC" 	,(cAliasTmp2)->ZJ_APLIC		    ,NIL})
					aAdd(_aItem,{"D3_YDRIVER" 	,(cAliasTmp2)->ZJ_YDRIVER		    ,NIL})
					aAdd(_aItem,{"D3_YROM"  	,"N"							,NIL})
					aAdd(_aItem,{"D3_YCHAVE"	,""								,NIL})
					aAdd(_aItem,{"D3_YPARADA"	,(cAliasTmp2)->ZJ_YPARADA 		,NIL})

					aAdd(_atotitem,_aitem)


					// Se for requisição e o produto for do grupo de EPI, adiciona ao objeto para tratamento de entrega automatica
					If Alltrim(SZI->ZI_TIPO) == "RE" .And. (cAliasTmp2)->ZJ_APLIC == "4"

						::oEntEPI:Add(SZI->ZI_MATRIC, (cAliasTmp2)->ZJ_COD, (cAliasTmp2)->ZJ_QUANT, (cAliasTmp2)->ZJ_LOCAL)

					EndIf				

					//Retira a Reserva
					If Alltrim(SZI->ZI_TIPO) == "RE"

						If (cAliasTmp)->ZJ_EMPDEST == "01"
							cSql := "UPDATE SB2010 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QUANT))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
							TcSQLExec(cSQL)
						ElseIf (cAliasTmp)->ZJ_EMPDEST == "14"
							cSql := "UPDATE SB2140 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QUANT))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
							TcSQLExec(cSQL)
						Else
							cSql := "UPDATE SB2050 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QUANT))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
							TcSQLExec(cSQL)
						EndIf

					EndIf

				ELSE

					//Metodo de transferencia para armazem temporario - Fernando/Facile
					_aCustSD3 := {}
					aAdd(_aCustSD3,{"D3_CONTA"		,nConta})
					aAdd(_aCustSD3,{"D3_CC"			,SZI->ZI_CC})
					aAdd(_aCustSD3,{"D3_CLVL"		,SZI->ZI_CLVL})
					aAdd(_aCustSD3,{"D3_ITEMCTA"	,SZI->ZI_ITEMCTA})

					aAdd(_aCustSD3,{"D3_YSI"		,SZI->ZI_YSI})
					aAdd(_aCustSD3,{"D3_YMATRIC"	,SZI->ZI_MATRIC})
					aAdd(_aCustSD3,{"D3_YTAG"		,(cAliasTmp2)->ZJ_TAG})
					aAdd(_aCustSD3,{"D3_YMELHOR"	,(cAliasTmp2)->ZJ_YMELHOR})
					aAdd(_aCustSD3,{"D3_YAPLIC"		,(cAliasTmp2)->ZJ_APLIC})
					aAdd(_aCustSD3,{"D3_YDRIVER"		,(cAliasTmp2)->ZJ_YDRIVER})
					aAdd(_aCustSD3,{"D3_YROM"		,"N"})
					aAdd(_aCustSD3,{"D3_YCHAVE"		,""})
					aAdd(_aCustSD3,{"D3_YPARADA"	,(cAliasTmp2)->ZJ_YPARADA})

					//Retira a Reserva
					If Alltrim(SZI->ZI_TIPO) == "RE"

						If (cAliasTmp)->ZJ_EMPDEST == "01"
							cSql := "UPDATE SB2010 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QUANT))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
							TcSQLExec(cSQL)
						ElseIf (cAliasTmp)->ZJ_EMPDEST == "14"
							cSql := "UPDATE SB2140 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QUANT))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
							TcSQLExec(cSQL)
						Else
							cSql := "UPDATE SB2050 SET B2_RESERVA = B2_RESERVA - "+Alltrim(Str((cAliasTmp2)->ZJ_QUANT))+" WHERE B2_COD = '"+(cAliasTmp2)->ZJ_COD+"' AND B2_LOCAL = '"+(cAliasTmp2)->ZJ_LOCAL+"' AND D_E_L_E_T_ = '' "
							TcSQLExec(cSQL)
						EndIf

					EndIf

					//Baixa Requisicao conforme empresa
					nEmp := (cAliasTmp)->ZJ_EMPDEST
					_lRetTr := .F.

					If Alltrim(SZI->ZI_TIPO) == "RE"

						If AllTrim(CEMPANT) == nEmp
							_lRetTr := U_FRQCRT01(SZI->ZI_EMPRESA, SZI->ZI_DOC,(cAliasTmp2)->ZJ_COD,(cAliasTmp2)->ZJ_QUANT,(cAliasTmp2)->ZJ_LOCAL,"6T",_aCustSD3,Alltrim(SZI->ZI_TIPO) == "RE")
						Else
							_lRetTr := U_FROPCPRO(nEmp,"01","U_FRQCRT01",SZI->ZI_EMPRESA, SZI->ZI_DOC,(cAliasTmp2)->ZJ_COD,(cAliasTmp2)->ZJ_QUANT,(cAliasTmp2)->ZJ_LOCAL,"6T",_aCustSD3,Alltrim(SZI->ZI_TIPO) == "RE")
						EndIf

					Else

						If AllTrim(CEMPANT) == nEmp
							_lRetTr := U_FRQCRT01(SZI->ZI_EMPRESA, SZI->ZI_DOC,(cAliasTmp2)->ZJ_COD,(cAliasTmp2)->ZJ_QUANT,"6T",(cAliasTmp2)->ZJ_LOCAL,_aCustSD3,Alltrim(SZI->ZI_TIPO) == "RE")
						Else
							_lRetTr := U_FROPCPRO(nEmp,"01","U_FRQCRT01",SZI->ZI_EMPRESA, SZI->ZI_DOC,(cAliasTmp2)->ZJ_COD,(cAliasTmp2)->ZJ_QUANT,"6T",(cAliasTmp2)->ZJ_LOCAL,_aCustSD3,Alltrim(SZI->ZI_TIPO) == "RE")
						EndIf

					EndIf

					//Atualizando cabecalho da Requisicao
					If _lRetTr
						SZI->(DbSetOrder(1))
						If SZI->(DbSeek(XFilial("SZI")+SZI->ZI_DOC+SZI->ZI_EMPRESA))
							RecLock("SZI",.F.)
							SZI->ZI_BAIXA := "S"
							SZI->(MsUnlock())
						EndIf
					EndIf

				ENDIF

				(cAliasTmp2)->(DBSKIP())
			End

			//Baixa de consumo interno na mesma empresa
			If Len(_atotitem) > 0				

				// Validação para produtos EPI
				If !::oEntEPI:Validate()

					cErro := "Baixa não efetuada, as informações do EPI não foram lançadas corretamente."
					Return{.F., cErro}

				EndIf				

				//Baixa Requisicao conforme empresa
				nEmp := (cAliasTmp)->ZJ_EMPDEST
				U_FROPCPRO(nEmp,"01","U_GravaSD3",_aCab1,_atotitem)

			EndIf

			(cAliasTmp)->(dbSkip())
		End

		//Posiciona novamente no Cabecalho da PreRequisicao
		cAliasTmp3 := GetNextAlias()
		BeginSql Alias cAliasTmp3
			SELECT * FROM  %Table:SZI% (NOLOCK)	WHERE ZI_DOC = %Exp:SZI->ZI_DOC% AND ZI_EMPRESA = %Exp:SZI->ZI_EMPRESA%  AND %NOTDEL%
		EndSql

		If (cAliasTmp3)->ZI_BAIXA == "S"

			// Salva informacoes da entrega do EPI
			::oEntEPI:Save(SZI->ZI_DOC)

			//Grava usuario no SD3 - nao funciona no execauto
			SD3->(dbSetOrder(2))
			IF SD3->( dbSeek(xfilial("SD3")+PADL(SZI->ZI_DOC,TamSX3("D3_DOC")[1])) )   
				While !SD3->(Eof()) .And. SD3->(D3_FILIAL+D3_DOC) == (xfilial("SD3")+PADL(SZI->ZI_DOC,TamSX3("D3_DOC")[1]))

					RecLock("SD3",.F.)
					SD3->D3_USUARIO := _cUsuERP
					SD3->(MsUnLock())

					SD3->(DbSkip())
				EndDo      
			ENDIF

			Return { .T. , "Pre Requisicao baixada com sucesso." }
		Else
			cErro := "Ocorreu um problema na baixa da Pre Requisicao. Favor verificar com o setor de TI"
			Return { .F. , cErro }
		EndIf

		(cAliasTmp)->(dbCloseArea())
		(cAliasTmp2)->(dbCloseArea())
		(cAliasTmp3)->(dbCloseArea())

	EndIf

Return