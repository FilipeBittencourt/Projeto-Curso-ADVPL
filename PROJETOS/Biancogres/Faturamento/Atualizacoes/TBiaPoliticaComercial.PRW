#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

User Function FCLA0051; Return()

/*/{Protheus.doc} TBiaPolitica
@description Classe para controle da Tela de Cadastro da Politica Comercial
@author Fernando Rocha
@since 21/07/2015
@version 1.5
@type class
/*/
Class TBiaPolitica

Data RECNO 		as Integer
Data FILIAL 	as String
Data TIPO 		as String
Data MARCA 		as String
Data CAT 		as String
Data TPSEG 		as String 
Data GCLI 		as String
Data CODCLI 	as String
Data LOJCLI 	as String
Data REDE		as String
Data VEND 		as String
Data PACOTE 	as String
Data FORMAT		as String
Data CODPRO		as String
Data CLASSE		as String
Data PDESC 		as Float
Data PVERBA		as Float
Data VIGINI		as Date
Data VIGFIM		as Date
Data STATUS		as String
Data CADUSU		as String
Data CADDAT		as Date
Data CADHOR		as String
Data APRUSU		as String
Data APRDAT 	as Date
Data APRHOR		as String
Data ESTCLI		as String
Data LOTE		as String
Data ZONAFR		as String

Data cmp_FILIAL
Data cmp_TIPO  
Data cmp_MARCA 
Data cmp_CAT   
Data cmp_TPSEG 
Data cmp_GCLI  
Data cmp_CODCLI
Data cmp_LOJCLI
Data cmp_REDE
Data cmp_VEND  
Data cmp_PACOTE
Data cmp_FORMAT
Data cmp_CODPRO
Data cmp_CLASSE
Data cmp_PDESC 
Data cmp_PVERBA
Data cmp_VIGINI
Data cmp_VIGFIM
Data cmp_ESTCLI
Data cmp_LOTE
Data cmp_ZONAFR

Data aEspFields //campos com tratamento especial
Data aValueFields //campos de dados - alteraveis quando nao aprovado

Data aDPAL_Fields
Data aDCAT_Fields
Data aDREG_Fields
Data aDGER_Fields
Data aDNV_Fields
Data aDESP_Fields
Data aDVER_Fields

Method New(_cFilial) //Construtor da Classe                      
Method CanActivate(_nOpc, _nRecNo) //Antes de ativar a tela - qualquer operacao

Method LoadFromModel(_oModel) //Carregar as propriedade do Model da tela
Method LoadFromRecno(_nRecno) //Carregar as propriedade pelo R_E_C_N_O-

Method ValidInsert()
Method ValidAlter()
Method AfterInsert() 
Method FieldWhen(_cCampo, _oModel) //Verificar se o campo esta ativo para digitacao conforme regras
Method IsActiveByTipo(_cCampo, _cTipo) //Verificar se o campo esta ativo para determinado tipo de desconto
Method ClearFields(_oModel, _oComponente) //limpar campos

Method Aprovar() //limpar campos
Method AltDataVirgencia()

EndClass


//Construtor da Classe
Method New(_cFilial) Class TBiaPolitica

	::RECNO 		:= 0
	::FILIAL 		:= cFilial
	::aEspFields 	:= {"ZA0_FILIAL","ZA0_CADUSU","ZA0_CADDAT","ZA0_CADHOR","ZA0_OK","ZA0_STATUS","ZA0_APRUSU","ZA0_APRDAT","ZA0_APRHOR"}
	::aValueFields	:= {"ZA0_PDESC","ZA0_PVERBA","ZA0_VIGINI","ZA0_VIGFIM"}

	::aDPAL_Fields	:= {}
	::aDCAT_Fields	:= {"ZA0_CAT"}
	::aDREG_Fields	:= {"ZA0_CAT","ZA0_TPSEG","ZA0_VEND","ZA0_ESTCLI","ZA0_PACOTE","ZA0_FORMAT","ZA0_CLASSE","ZA0_ZONAFR", "ZA0_CODPRO", "ZA0_LOTE"}
	::aDGER_Fields	:= {"ZA0_CAT","ZA0_TPSEG","ZA0_VEND","ZA0_GCLI","ZA0_CODCLI","ZA0_LOJCLI","ZA0_REDE","ZA0_PACOTE","ZA0_FORMAT","ZA0_CODPRO","ZA0_CLASSE","ZA0_ESTCLI","ZA0_ZONAFR","ZA0_LOTE"}
	::aDNV_Fields	:= {"ZA0_CAT","ZA0_TPSEG","ZA0_VEND","ZA0_GCLI","ZA0_CODCLI","ZA0_LOJCLI","ZA0_REDE","ZA0_PACOTE","ZA0_FORMAT","ZA0_CODPRO","ZA0_CLASSE","ZA0_ESTCLI","ZA0_LOTE"}
	::aDESP_Fields	:= {"ZA0_CAT","ZA0_TPSEG","ZA0_GCLI","ZA0_CODCLI","ZA0_LOJCLI","ZA0_REDE","ZA0_VEND","ZA0_PACOTE","ZA0_FORMAT","ZA0_CODPRO","ZA0_CLASSE","ZA0_ESTCLI","ZA0_LOTE"}
	::aDVER_Fields	:= {"ZA0_CAT","ZA0_TPSEG","ZA0_VEND","ZA0_GCLI","ZA0_CODCLI","ZA0_LOJCLI","ZA0_REDE","ZA0_PACOTE","ZA0_FORMAT","ZA0_CODPRO","ZA0_CLASSE","ZA0_ESTCLI","ZA0_LOTE"}

	//carregar nomes dos campos da tabela para uso diverso
	::cmp_FILIAL := "ZA0_FILIAL"
	::cmp_TIPO   := "ZA0_TIPO"
	::cmp_MARCA  := "ZA0_MARCA"
	::cmp_CAT    := "ZA0_CAT"
	::cmp_TPSEG  := "ZA0_TPSEG"
	::cmp_GCLI   := "ZA0_GCLI"
	::cmp_CODCLI := "ZA0_CODCLI"
	::cmp_LOJCLI := "ZA0_LOJCLI"
	::cmp_REDE	 := "ZA0_REDE"
	::cmp_VEND   := "ZA0_VEND"
	::cmp_PACOTE := "ZA0_PACOTE"
	::cmp_FORMAT := "ZA0_FORMAT"
	::cmp_CODPRO := "ZA0_CODPRO"
	::cmp_CLASSE := "ZA0_CLASSE"
	::cmp_PDESC  := "ZA0_PDESC"
	::cmp_PVERBA := "ZA0_PVERBA"
	::cmp_VIGINI := "ZA0_VIGINI"
	::cmp_VIGFIM := "ZA0_VIGFIM"
	::cmp_ESTCLI := "ZA0_ESTCLI"
	::cmp_LOTE	 := "ZA0_LOTE"
	::cmp_ZONAFR := "ZA0_ZONAFR"

Return Self

//Antes de ativar a tela - qualquer operacao - validar
Method CanActivate(_nOpc, _nRecNo) Class TBiaPolitica
	Local lRet := .T. 

	//Comentado/TEmporario para implantacao - permitir excluir qualquer coisa
	//If (ZA0->ZA0_STATUS == "A" .And. _nOpc == 5)     
	//	Help(,,"TBiaPolitica:CanActivate",, "Política Aprovada. Não é possível excluir.", 1, 0)
	//	lRet := .F.
	//EndIf

Return(lRet)

//Carregar Dados das variaveis de memoria - quando usando em tela enchoice
Method LoadFromModel(_oModel) Class TBiaPolitica

	Self:STATUS	:=_oModel:GetValue("ZA0_STATUS")
	Self:TIPO	:=_oModel:GetValue("ZA0_TIPO")
	Self:MARCA	:=_oModel:GetValue("ZA0_MARCA")
	Self:CAT	:=_oModel:GetValue("ZA0_CAT")
	Self:TPSEG	:=_oModel:GetValue("ZA0_TPSEG")
	Self:GCLI	:=_oModel:GetValue("ZA0_GCLI")
	Self:CODCLI	:=_oModel:GetValue("ZA0_CODCLI")
	Self:LOJCLI	:=_oModel:GetValue("ZA0_LOJCLI")
	Self:REDE	:=_oModel:GetValue("ZA0_REDE") 
	Self:VEND	:=_oModel:GetValue("ZA0_VEND")
	Self:PACOTE	:=_oModel:GetValue("ZA0_PACOTE")
	Self:FORMAT	:=_oModel:GetValue("ZA0_FORMAT")
	Self:CODPRO	:=_oModel:GetValue("ZA0_CODPRO")
	Self:CLASSE	:=_oModel:GetValue("ZA0_CLASSE")
	Self:PDESC	:=_oModel:GetValue("ZA0_PDESC")
	Self:PVERBA	:=_oModel:GetValue("ZA0_PVERBA")
	Self:VIGINI	:=_oModel:GetValue("ZA0_VIGINI")
	Self:VIGFIM :=_oModel:GetValue("ZA0_VIGFIM")
	Self:ESTCLI :=_oModel:GetValue("ZA0_ESTCLI")
	Self:LOTE	:=_oModel:GetValue("ZA0_LOTE")
	Self:ZONAFR	:=_oModel:GetValue("ZA0_ZONAFR")

Return

//Bloco de codigo para Edicao de Campo
Method FieldWhen(_cCampo, _oModel) Class TBiaPolitica

	Local lRet 		:= .F.
	Local nOpc 		:= _oModel:GetOperation()
	Local cStatus 	:= _oModel:GetValue("ZA0_STATUS")
	Local cTipo		:= _oModel:GetValue("ZA0_TIPO")

	If ( nOpc == 4 ) //se alterar

		if ( cStatus == "A" )
			if ( _cCampo == "ZA0_VIGFIM" )
				lRet := .T.
			endif
		else
			if ( ::IsActiveByTipo(_cCampo, cTipo) .Or. aScan(::aValueFields,{|x| AllTrim(_cCampo) == AllTrim(x)}) > 0 )
				lRet := .T.
			endif
		endif

	ElseIf ( nOpc == 3 ) //se incluir

		if ( AllTrim(_cCampo) == "ZA0_TIPO" .Or. AllTrim(_cCampo) == "ZA0_MARCA" .Or. aScan(::aValueFields,{|x| AllTrim(_cCampo) == AllTrim(x)}) > 0 .Or. ::IsActiveByTipo(_cCampo, cTipo) )
			lRet := .T.
		endif

	EndIf

Return lRet

//Verifica campos chave habilitados de acorodo com o tipo de desconto
Method IsActiveByTipo(_cCampo, _cTipo) Class TBiaPolitica

	Local lRet := .F.

	Do Case

		Case AllTrim(_cTipo) == "DPAL";	lRet := aScan(::aDPAL_Fields, {|x| AllTrim(_cCampo) == x }) > 0  
		Case AllTrim(_cTipo) == "DCAT";	lRet := aScan(::aDCAT_Fields, {|x| AllTrim(_cCampo) == x }) > 0 
		Case AllTrim(_cTipo) == "DREG";	lRet := aScan(::aDREG_Fields, {|x| AllTrim(_cCampo) == x }) > 0 
		Case AllTrim(_cTipo) == "DGER";	lRet := aScan(::aDGER_Fields, {|x| AllTrim(_cCampo) == x }) > 0 
		Case AllTrim(_cTipo) == "DNV";	lRet := aScan(::aDNV_Fields, {|x| AllTrim(_cCampo) == x }) > 0 
		Case AllTrim(_cTipo) == "DESP";	lRet := aScan(::aDESP_Fields, {|x| AllTrim(_cCampo) == x }) > 0
		Case AllTrim(_cTipo) == "DVER";	lRet := aScan(::aDVER_Fields, {|x| AllTrim(_cCampo) == x }) > 0 

	EndCase

Return lRet 

//Validar se pode inserir o registro - nao existe nenhuma condicao conflitante
Method ValidInsert() Class TBiaPolitica

	Local cAliasAux
	Local lRet := .F.

	//procurar registro com chave duplicada
	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux
	%NOPARSER%

	select *
	from ZA0010 ZA0
	where
	ZA0_FILIAL 		= %EXP:Self:FILIAL%
	and ZA0_TIPO 	= %EXP:Self:TIPO%
	and ZA0_MARCA 	= %EXP:Self:MARCA%
	and ZA0_CAT 	= %EXP:Self:CAT%
	and ZA0_TPSEG 	= %EXP:Self:TPSEG%
	and ZA0_GCLI 	= %EXP:Self:GCLI%
	and ZA0_CODCLI 	= %EXP:Self:CODCLI%
	and ZA0_LOJCLI 	= %EXP:Self:LOJCLI%
	and ZA0_REDE	= %EXP:Self:REDE%
	and ZA0_VEND 	= %EXP:Self:VEND%
	and ZA0_PACOTE 	= %EXP:Self:PACOTE%
	and ZA0_FORMAT 	= %EXP:Self:FORMAT%
	and ZA0_CODPRO 	= %EXP:Self:CODPRO% 
	and ZA0_CLASSE 	= %EXP:Self:CLASSE%
	and ZA0_ESTCLI	= %EXP:Self:ESTCLI%
	and ZA0_LOTE 	= %EXP:Self:LOTE%
	and ZA0_ZONAFR	= %EXP:Self:ZONAFR%
	
	and ZA0.D_E_L_E_T_=''
	ORDER BY ZA0_VIGFIM DESC

	EndSql

	(cAliasAux)->(DbGoTop())

	If (cAliasAux)->(Eof())
		lRet := .T.
	Else

		If (cAliasAux)->ZA0_STATUS == "A" .And. STOD((cAliasAux)->ZA0_VIGFIM) < Self:VIGINI
			lRet := .T.
		Else

			Help(,,"TBiaPolitica:ValidInsert",, "Não é possível inserir registro. Chave duplicada com vigência em conflito OU não aprovada.", 1, 0)

		EndIf

	EndIf
	(cAliasAux)->(DbCloseArea())  

	//Datas
	If lRet .And. (Self:VIGFIM < Self:VIGINI)
		Help(,,"TBiaPolitica:ValidInsert",, "Data fim da vigência não pode ser menor que o inicio.", 1, 0)
		lRet := .F.
	EndIf    

	//Codigo do Cliente
	If lRet .And. !Empty(Self:CODCLI) .And.  Empty(Self:LOJCLI) 
		Help(,,"TBiaPolitica:ValidInsert",, "Cliente informado sem o campo LOJA. Favor preencher.", 1, 0)
		lRet := .F.
	EndIf

	//Validacao do Campo Lote
	If lRet .And. !Empty(Self:LOTE)

		If Empty(Self:CODPRO)
			Help(,,"TBiaPolitica:ValidInsert",, "Política por LOTE - obrigatório informar o Produto.", 1, 0)
			lRet := .F.
		EndIf

		If lRet
			ZZ9->(dbSetOrder(1))	
			If !ZZ9->(dbSeek(xFilial("ZZ9")+Self:LOTE+Self:CODPRO))
				Help(,,"TBiaPolitica:ValidInsert",, "Este Lote: "+ALLTRIM(Self:LOTE)+" nao esta amarrado ao Produto: "+ALLTRIM(Self:CODPRO), 1, 0)
				lRet := .F.	
			EndIf
		EndIf

	EndIf

Return(lRet)

//Validar se pode inserir o registro - nao existe nenhuma condicao conflitante
Method ValidAlter() Class TBiaPolitica

	Local lRet := .T.

	If lRet .And. Self:STATUS == "A" .And. (Self:VIGFIM < dDataBase)
		Help(,,"TBiaPolitica:ValidAlter",, "Não é possível alterar registro. O Campo Vigência Final não pode ser menor que HOJE.", 1, 0)
		lRet := .F.	
	EndIf

	//Validacao do Campo Lote
	If lRet .And. !Empty(Self:LOTE)

		If Empty(Self:CODPRO)
			Help(,,"TBiaPolitica:ValidAlter",, "Política por LOTE - obrigatório informar o Produto.", 1, 0)
			lRet := .F.
		EndIf

		If lRet
			ZZ9->(dbSetOrder(1))	
			If !ZZ9->(dbSeek(xFilial("ZZ9")+Self:LOTE+Self:CODPRO))
				Help(,,"TBiaPolitica:ValidAlter",, "Este Lote: "+ALLTRIM(Self:LOTE)+" nao esta amarrado ao Produto: "+ALLTRIM(Self:CODPRO), 1, 0)
				lRet := .F.	
			EndIf
		EndIf

	EndIf

Return(lRet)

//Dados adicionais apos inserir novo registro
Method AfterInsert(_nRecNo) Class TBiaPolitica

	If (_nRecNo > 0)

		ZA0->(DbSetOrder(0))
		ZA0->(DbGoTo(_nRecNo))
		If !ZA0->(Eof()) .And. Empty(ZA0->ZA0_CADUSU)

			RecLock("ZA0",.F.)
			ZA0->ZA0_STATUS := "N"
			ZA0->ZA0_CADUSU := CUSERNAME
			ZA0->ZA0_CADDAT := dDataBase
			ZA0->ZA0_CADHOR := SubStr(Time(),1,5)
			ZA0->(MsUnlock())

		EndIf

	EndIf

Return

//Carregar propriedade do objeto pelo Recno
Method LoadFromRecno(_nRecno) Class TBiaPolitica

	If (_nRecNo > 0)

		ZA0->(DbSetOrder(0))
		ZA0->(DbGoTo(_nRecNo))
		If !ZA0->(Eof())

			Self:RECNO 	:= ZA0->(RecNo())
			Self:FILIAL := ZA0->ZA0_FILIAL

			Self:TIPO	:= ZA0->ZA0_TIPO
			Self:MARCA	:= ZA0->ZA0_MARCA
			Self:CAT	:= ZA0->ZA0_CAT
			Self:TPSEG	:= ZA0->ZA0_TPSEG
			Self:GCLI	:= ZA0->ZA0_GCLI
			Self:CODCLI	:= ZA0->ZA0_CODCLI
			Self:LOJCLI	:= ZA0->ZA0_LOJCLI
			Self:REDE	:= ZA0->ZA0_REDE
			Self:VEND	:= ZA0->ZA0_VEND
			Self:PACOTE	:= ZA0->ZA0_PACOTE
			Self:FORMAT	:= ZA0->ZA0_FORMAT
			Self:CODPRO	:= ZA0->ZA0_CODPRO
			Self:CLASSE	:= ZA0->ZA0_CLASSE
			Self:PDESC	:= ZA0->ZA0_PDESC
			Self:PVERBA	:= ZA0->ZA0_PVERBA
			Self:VIGINI	:= ZA0->ZA0_VIGINI
			Self:VIGFIM := ZA0->ZA0_VIGFIM 
			Self:STATUS := ZA0->ZA0_STATUS
			Self:CADUSU := ZA0->ZA0_CADUSU
			Self:CADDAT := ZA0->ZA0_CADDAT
			Self:CADHOR := ZA0->ZA0_CADHOR
			Self:APRUSU := ZA0->ZA0_APRUSU
			Self:APRDAT := ZA0->ZA0_APRDAT
			Self:APRHOR := ZA0->ZA0_APRHOR
			Self:ESTCLI := ZA0->ZA0_ESTCLI
			Self:LOTE 	:= ZA0->ZA0_LOTE
			Self:ZONAFR	:= ZA0->ZA0_ZONAFR

		EndIf

	EndIf

Return

//Aprovar a politica
Method Aprovar() Class TBiaPolitica

	If Self:RECNO > 0 .And. Self:STATUS == "N"

		ZA0->(DbSetOrder(0))
		ZA0->(DbGoTo(Self:RECNO))
		If !ZA0->(Eof())

			RecLock("ZA0",.F.)
			ZA0->ZA0_STATUS := "A"
			ZA0->ZA0_APRUSU := CUSERNAME
			ZA0->ZA0_APRDAT := dDataBase
			ZA0->ZA0_APRHOR := SubStr(Time(),1,5)
			ZA0->(MsUnlock())

		EndIf

	EndIf

Return


Method AltDataVirgencia(dDtFim) Class TBiaPolitica

	If Self:RECNO > 0

		ZA0->(DbSetOrder(0))
		ZA0->(DbGoTo(Self:RECNO))
		If !ZA0->(Eof())

			RecLock("ZA0",.F.)
			ZA0->ZA0_VIGFIM := dDtFim
			ZA0->(MsUnlock())

		EndIf

	EndIf

Return
