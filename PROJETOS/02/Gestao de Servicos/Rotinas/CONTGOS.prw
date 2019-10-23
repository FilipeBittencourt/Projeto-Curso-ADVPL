#include "PROTHEUS.CH"

User Function CONTGOS()
Local cNumOS := ""
Local aCabec :={}
Local aItens := {}
Local aPergs := {}

Local oDlgBXS
Local cMarca := GetMark()
Local aCpoBrw
Local lInverte := .F.

Local cCodTec 	:= Space(6)
Local dDataAt 	:= CTOD(" ")
Local cOcorr	:= Space(6)
Local cSolicit	:= Space(15)
Local cProcurar	:= Space(15)
Local cServico	:= Space(40)

Local aRet 		:= {cCodTec,dDataAt,cOcorr,cSolicit,cProcurar,cServico}

IF !ALTERA
	MsgAlert("Executar esta rotina no modo ALTERAR","Aten玢o!")
	Return
ENDIF

Private lMsErroAuto

aAdd( aPergs ,{1,"T閏nico: ",cCodTec,"@!",'ExistCpo("AA1")',"AA1",'.T.',30,.T.})
aAdd( aPergs ,{1,"Data Atendimento: ",dDataAt,"",'',"",'.T.',60,.T.})
aAdd( aPergs ,{1,"Ocorrencia: ",cOcorr,"@!",'ExistCpo("AAG")',"AAG",'.T.',60,.T.})
aAdd( aPergs ,{1,"Solicitado Por: ",cSolicit,"@!",'',"",'.T.',100,.F.})
aAdd( aPergs ,{1,"Procurar Sr.: ",cProcurar,"@!",'',"",'.T.',100,.F.})  
aAdd( aPergs ,{1,"Desc. do Servico.: ",cServico,"@!",'',"",'.T.',254,.T.})

If ParamBox(aPergs ,"Gerar OS de Contrato",aRet)
	
	//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
	//MONTA ARQUIVO DE TRABALHO E TELA PARA GRID DE MARCACAO DOS PRODUTOS
	//北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
	IF Select("TRBBXS") > 0
		TRBBXS->(DbCloseArea())
	ENDIF
	
	_struCd:={}
	AADD(_struCd,{"OK"       	    ,"C", 2,0})
	AADD(_struCd,{"PRODUTO"       	,"C", 15,0})
	AADD(_struCd,{"REF"			   	,"C", 20,0})
	AADD(_struCd,{"DESCR"	     	,"C", 30,0})
	AADD(_struCd,{"TAG"          	,"C", 20,0})
	AADD(_struCd,{"ID"		        ,"C", 20,0})
	
	cArq:=	Criatrab(_struCd,.T.)
	DBUSEAREA(.t.,,carq,"TRBBXS")
	cIndex   := CriaTrab(nil,.F.)
	cChave   := "PRODUTO"
	TRBBXS->(DbCreateIndex( cIndex, cChave, {|| &cChave}, .F. ))
	TRBBXS->(DbCommit())
	
	__AAREAAA3 := AA3->(GetArea())
	
	AA3->(DbSetOrder(2))
	If AA3->(DbSeek(XFilial("AA3")+M->(AAH_CONTRT+AAH_CODCLI+AAH_LOJA)))
		
		While !AA3->(Eof()) .And. AA3->(AA3_FILIAL+AA3_CONTRT+AA3_CODCLI+AA3_LOJA) == (XFilial("AA3")+M->(AAH_CONTRT+AAH_CODCLI+AAH_LOJA))
			
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(XFilial("SB1")+AA3->AA3_CODPRO))
			
			RecLock("TRBBXS",.T.)
			TRBBXS->OK 			:= ""
			TRBBXS->PRODUTO 	:= AA3->AA3_CODPRO
			TRBBXS->REF 		:= SB1->B1_YREF
			TRBBXS->DESCR 		:= SB1->B1_DESC
			TRBBXS->TAG 		:= AA3->AA3_YTAG
			TRBBXS->ID			:= AA3->AA3_NUMSER
			TRBBXS->(MsUnlock())
			
			AA3->(DbSkip())
		EndDo
		
	EndIf
	
	TRBBXS->(DbGoTop())
	DEFINE MSDIALOG oDlgBXS TITLE "Escolher equipamento para o Gerar a OS" FROM C(178),C(181) TO C(499),C(783) PIXEL
	
	// Cria Componentes Padroes do Sistema
	@ C(149),C(264) Button "OK" Size C(037),C(012) PIXEL OF oDlgBXS ACTION (lGBxs := .T.,oDlgBXS:End())
	
	aCpoBrw := {	{ "OK"		  	,,""			    ,"@!"},;
	{ "PRODUTO"  	,,"Produto"			,"@!"},;
	{ "REF"  		,,"Ref.Atlas"		,"@!"},;
	{ "DESCR" 		,,"Descri玢o"	 	,"@!"},;
	{ "TAG"			,,"Tag"			    ,"@!"},;
	{ "ID" 			,,"Id.Unico"		,"@!"} }
	
	oGetDados1 := MsSelect():New("TRBBXS","OK","",aCpoBrw,@lInverte,@cMarca,{C(000),C(000),C(147),C(301)},,,oDlgBXS)
	
	ACTIVATE MSDIALOG oDlgBXS CENTERED
	
	RestArea(__AAREAAA3)
	
	If MsgNoYes("Tem certeza que deseja gerar OS para o contrato/item selecionado?")
		
		aAdd(aCabec,{"AB6_CODCLI",M->AAH_CODCLI,Nil})
		aAdd(aCabec,{"AB6_LOJA"  ,M->AAH_LOJA,Nil})
		aAdd(aCabec,{"AB6_EMISSA",dDataBase,Nil})
		aAdd(aCabec,{"AB6_ATEND" ,cUserName,Nil})
		aAdd(aCabec,{"AB6_CONPAG","101",Nil})
		aAdd(aCabec,{"AB6_HORA"  ,Time(),Nil})
		aAdd(aCabec,{"AB6_YCODTE",aRet[1],Nil})
		aAdd(aCabec,{"AB6_YSOLIC",aRet[4],Nil})
		aAdd(aCabec,{"AB6_YPROCU",aRet[5],Nil})
		aAdd(aCabec,{"AB6_YCONTR",M->AAH_CONTRT,Nil})
		
		__NSEQ := 0
		TRBBXS->(DbGoTop())
		While .Not. TRBBXS->(Eof())
			IF TRBBXS->OK == cMarca
				
				__NSEQ++
				
				aItem := {}
				aAdd(aItem,{"AB7_ITEM"  ,StrZero(__NSEQ,2),Nil})
				aAdd(aItem,{"AB7_TIPO"  ,"1",Nil})
				aAdd(aItem,{"AB7_CODPRO",TRBBXS->PRODUTO,Nil})
				aAdd(aItem,{"AB7_NUMSER",TRBBXS->ID,Nil})
				aAdd(aItem,{"AB7_CODPRB",aRet[3],Nil})
				aAdd(aItem,{"AB7_YDTATE",aRet[2],Nil})
				aAdd(aItem,{"AB7_MEMO2",aRet[6],Nil})
				aAdd(aItens,aItem)
				
			ENDIF
			TRBBXS->(DbSkip())
		EndDo
		TRBBXS->(DbCloseArea())
		
		TECA450(,aCabec,aItens,,3)
		If !lMsErroAuto
		
			__cAliasTmp := GetNextAlias()
			BeginSql Alias __cAliasTmp
			SELECT TOP 1 AB6_NUMOS FROM %TABLE:AB6% WHERE AB6_FILIAL = %XFILIAL:AB6% AND AB6_YCONTR = %EXP:M->AAH_CONTRT% AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC
			EndSql
			(__cAliasTmp)->(DbGoTop())
			If !(__cAliasTmp)->(Eof())    
		    	__cOS := (__cAliasTmp)->AB6_NUMOS  
		 	Else	
		 		__cOS := ""
		    EndIf 
		    (__cAliasTmp)->(DbCloseArea())
			MsgInfo("Inclusao com sucesso! "+CRLF+"OS No.: "+__cOS)
		Else
			DisarmTransaction()
			MostraErro()
		EndIf
		
	EndIf
	
EndIf

Return
