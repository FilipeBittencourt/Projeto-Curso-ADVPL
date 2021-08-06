#include "totvs.ch" 
#include "tbiconn.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "vkey.ch"

/*/{Protheus.doc} TBiaAutoBordero
@author Artur Antunes
@since 26/04/2017
@version 1.0
@description Classe para manutenção de Borderô via coletor (Processos e validações)
@obs OS 0104-17
@type class
/*/

Class TBiaBordero From LongClassName

	Data cEtiqueta
	Data cLote
	Data cProduto
	Data nNumBor
	Data cErroBd
	Data oColetor
	Data cBaseDados
	
	Method New() Constructor
	Method LoadEtiq(cEtiqueta)
	Method ExistEtiqProc(cEtiqueta)
	Method LoadBordero(cEtiqueta)
	Method CriaBordero(cEtiqueta)
	Method CriaItemBordero(cEtiqueta,nNumBor) 
	Method UpdBordero()

EndClass    


//Construtor da Classe
Method New(oColetor) Class TBiaBordero 
	Default oColetor := Nil
	::oColetor   := oColetor
	::cEtiqueta  := ''
	::cLote		 := ''
	::cProduto	 := ''
	::nNumBor	 := 0
	::cErroBd	 := ''
	::cBaseDados := ''
	
	If cEmpAnt == "01"
		::cBaseDados := "DADOSEOS"
	ElseIf cEmpAnt == "05"
		::cBaseDados := "DADOS_05_EOS"
	ElseIf cEmpAnt == "14"
		::cBaseDados := "DADOS_14_EOS"
	endif
Return                              


//Carregar etiqueta
Method LoadEtiq(cEtiqueta) Class TBiaBordero

Local cAliasAux  := GetNextAlias()
Local lOk 		 := .F.
local cQuery	 := ''

if !empty(cEtiqueta)
	cQuery	:= " SELECT cod_produto PRODUT, etiq_lote LOTECTL " + CRLF 
	cQuery	+= " FROM "+::cBaseDados+"..cep_etiqueta_pallet (NOLOCK) " + CRLF 
	cQuery	+= " WHERE cod_etiqueta = "+cEtiqueta+" " + CRLF 
	cQuery	+= "  AND etiq_cancelada <> '1' " + CRLF 
	cQuery	+= "  AND nf_numero =  '' " + CRLF 
	TcQuery cQuery Alias (cAliasAux) New
	(cAliasAux)->(DbGoTop())  

	If !(cAliasAux)->(Eof()) 

		::cEtiqueta := Alltrim(cEtiqueta)
		::cLote		:= (cAliasAux)->LOTECTL
		::cProduto	:= (cAliasAux)->PRODUT
		lOk := .T.
	EndIf                    
	(cAliasAux)->(DbCloseArea())
endif	
Return( lOk )


//verifica se etiqueta já foi processada
Method ExistEtiqProc(cEtiqueta) Class TBiaBordero

Local cAliasAux  := GetNextAlias()
Local lOk 		 := .F.
local cQuery	 := ''

if !empty(cEtiqueta)
	cQuery	:= " SELECT COUNT(*) EXISTETQ FROM "+::cBaseDados+"..cep_etiqueta_processa_itens (NOLOCK) WHERE cod_etiqueta = "+cEtiqueta+"  " + CRLF 
	TcQuery cQuery Alias (cAliasAux) New
	(cAliasAux)->(DbGoTop())  
	lOk :=  (cAliasAux)->EXISTETQ > 0
	(cAliasAux)->(DbCloseArea())
endif	
return lOk


//Carregar Bordero
Method LoadBordero(cEtiqueta) Class TBiaBordero

Local cAliasAux := GetNextAlias()
Local lOk 		:= .F.
local cQuery	:= ''

if !empty(cEtiqueta)
	cQuery	:= " WITH CTRLETIQ AS ( SELECT cod_produto PRODUT,etiq_lote LOTECTL " + CRLF 
	cQuery	+= "				    FROM "+::cBaseDados+"..cep_etiqueta_pallet (NOLOCK) " + CRLF 
	cQuery	+= "					WHERE cod_etiqueta = "+cEtiqueta+" " + CRLF 
	cQuery	+= "					 AND etiq_cancelada <> '1' " + CRLF 
	cQuery	+= "					 AND nf_numero =  '') " + CRLF 
	cQuery	+= " SELECT ISNULL(MIN(id_bordero), 0) NUMBOR " + CRLF 
	cQuery	+= " FROM CTRLETIQ A " + CRLF 
	cQuery	+= " INNER JOIN "+::cBaseDados+"..cep_etiqueta_processa (NOLOCK) B " + CRLF  
	cQuery	+= "  ON B.cod_produto  = A.PRODUT " + CRLF 
	cQuery	+= "  AND B.brd_lote  = A.LOTECTL " + CRLF 
	cQuery	+= "  AND brd_transferido = 0 " + CRLF 
	
	TcQuery cQuery Alias (cAliasAux) New
	(cAliasAux)->(DbGoTop())  
	
	If (cAliasAux)->NUMBOR > 0
		::nNumBor := (cAliasAux)->NUMBOR
		lOk := .T.
	EndIf                    
	(cAliasAux)->(DbCloseArea())
endif	
Return( lOk )


//Cria novo bordero
Method CriaBordero(cEtiqueta) Class TBiaBordero

Local lOk 	  := .F.
local cQuery  := ''
local nResult := 0
::cErroBd 	  := ''

if !empty(cEtiqueta)

	cQuery	:= " WITH CTRLETIQ AS (SELECT cod_produto PRODUT, " + CRLF 
	cQuery	+= "                         etiq_lote LOTECTL " + CRLF 
	cQuery	+= "                   FROM "+::cBaseDados+"..cep_etiqueta_pallet (NOLOCK) " + CRLF 
	cQuery	+= "                   WHERE cod_etiqueta = "+cEtiqueta+" " + CRLF 
	cQuery	+= "                    AND etiq_cancelada <> '1' " + CRLF 
	cQuery	+= "                    AND nf_numero =  '') " + CRLF 
	
	cQuery	+= " INSERT INTO "+::cBaseDados+"..cep_etiqueta_processa " + CRLF 
	cQuery	+= " (id_bordero, " + CRLF 
	cQuery	+= " id_cia, " + CRLF 
	cQuery	+= " brd_data, " + CRLF 
	cQuery	+= " brd_usuario, " + CRLF 
	cQuery	+= " brd_transferido, " + CRLF 
	cQuery	+= " cod_produto, " + CRLF 
	cQuery	+= " brd_lote) " + CRLF 
	
	cQuery	+= " SELECT (SELECT MAX(id_bordero) + 1 FROM "+::cBaseDados+"..cep_etiqueta_processa ) NUMBOR, " + CRLF 
	cQuery	+= "        '1' id_cia, " + CRLF 
	cQuery	+= "        convert(smalldatetime, SYSDATETIME()) brd_data, " + CRLF 
	cQuery	+= "        '"+Alltrim(::oColetor:cUsuERP)+"' brd_usuario, " + CRLF 
	cQuery	+= "        '0' brd_transferido, " + CRLF 
	cQuery	+= "        PRODUT cod_produto, " + CRLF 
	cQuery	+= "        LOTECTL brd_lote " + CRLF 
	cQuery	+= " FROM CTRLETIQ A " + CRLF 

	nResult := TCSQLEXEC(cQuery)
	If nResult < 0 
		::cErroBd := TCSQLError()
	elseif ::LoadBordero(cEtiqueta) 
		lOk := .T.
	endif
endif	
return lOk


//Cria novo item no bordero
Method CriaItemBordero(cEtiqueta,nNumBor) Class TBiaBordero

Local lOk 	  	:= .F.
local cQuery  	:= ''
local nResult 	:= 0
Default nNumBor := 0
::cErroBd 		:= ''

if !empty(cEtiqueta) .and. nNumBor > 0

	cQuery	:= " INSERT INTO "+::cBaseDados+"..cep_etiqueta_processa_itens " + CRLF 
	cQuery	+= " (id_bordero, " + CRLF 
	cQuery	+= " id_cia, " + CRLF 
	cQuery	+= " cod_etiqueta, " + CRLF 
	cQuery	+= " bri_modo) " + CRLF 
	cQuery	+= " SELECT "+ Alltrim(str(nNumBor))+" id_bordero, " + CRLF 
	cQuery	+= "        '1' id_cia, " + CRLF 
	cQuery	+= "        "+cEtiqueta+" cod_etiqueta, " + CRLF 
	cQuery	+= "        'O' bri_modo " + CRLF 

	nResult := TCSQLEXEC(cQuery)
	If nResult < 0
		::cErroBd := TCSQLError()
	else
		lOk := .T.
	endif
endif	
return lOk


//Realiza a manutenção de Borderô
Method UpdBordero() Class TBiaBordero

If !::LoadEtiq(::cEtiqueta) 
	Return { .F. , "Etiqueta não encontrada" }
EndIf

If !::LoadBordero(::cEtiqueta) 
	if !::CriaBordero(::cEtiqueta)
		Return { .F. , "Falha na criação do borderô, Erro: "+::cErroBd }
	endif	
endif

If !::CriaItemBordero(::cEtiqueta,::nNumBor) 
	Return { .F. , "Não foi possivel incluir o Item no borderô, Erro: "+::cErroBd }
endif	

Return {.T.,''}
