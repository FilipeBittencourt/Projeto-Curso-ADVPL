#include "fivewin.ch"
#include "apwebex.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "topconn.ch"
#include "fileio.ch"
#include "protheus.ch"

#TRANSLATE SetMntStat(<cStatus>) => PTINTERNAL(1,<cStatus>)

User Function solicit
	local   chtml   := ""

	private cEmp    := httpsession->emp_atu
	private cNewEmp := httpget->emp
	private cFil    := httpsession->emp_fil

	private aEmp    := httpsession->emp_menu
	private cUsr    := httppost->user_login
	private cPsw    := httppost->user_pass
	private cFilBy  := httppost->filby
	private cFilTxt := httppost->filtxt
	private cFiltro := httppost->filtro
	private cAction := httpget->action
	private cMsg    := ""

	default cAction := ""
	default cNewEmp := ""
	default aEmp    := {}
	default cEmp    := "01"
	default cFil    := "01"
	default cUsr    := ""
	default cPsw    := ""
	default cFilBy  := ""
	default cFilTxt := ""
	default cFiltro := "f01"

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"
	HttpHeadOut->Expires 		:= "Mon, 26 Jul 1997 05:00:00 GMT "
	HttpHeadOut->Last_Modified 	:= TransData()
	HttpHeadOut->Cache_Control 	:= "no-store, no-cache, must-revalidate, post-check=0, pre-check=0;"
	HttpHeadOut->pragma 		:= "no-cache"

	if cAction == "logout"
		cUsr := ""
		cPsw := ""
		cEmp := "01"
		cFil := "01"
		aEmp := {"01"}
		httpsession->user_code := ""
		httpsession->user_name := ""
		httpsession->emp_menu  := aEmp
		httpsession->emp_fil   := cFil
		httpsession->emp_atu   := cEmp
	endif

	rpcclearenv()
	rpcsettype(3)

	if !Empty(cNewEmp)
		cEmp := cNewEmp
		cUsr := httpsession->user_code
		cPsw := httpsession->user_pass
		aEmp := {}
		httpsession->emp_atu := cEmp
	endif

	WFPrepEnv(cEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)

	SetMntStat("Abrindo ambiente, Empresa "+cEmp+" Filial "+cFil)

	if type("httpsession->user_code") == "U" .and. empty(cUsr+cPsw)
		httpsession->user_code := ""
		qout("[variable {httpsession->user_code} don't exists, creating blank one.]")
	else          
		if !empty(httpsession->user_code)
			cUsr := httpsession->user_code
			cPsw := httpsession->user_pass
		endif
		if !empty(cUsr) .And. !empty(cPsw)
			cSZ0 := login(cUsr,cPsw)
			if !(cSZ0)->(eof())
				httpsession->user_code := cUsr
				httpsession->user_pass := cPsw
				httpsession->user_name := (cSZ0)->NOME
				httpsession->emp_menu  := {}
				aEmp := {}
				while !(cSZ0)->(Eof())
					aadd(aEmp, LEFT((cSZ0)->EMP,2))
					(cSZ0)->(dbskip())
				enddo
				httpsession->emp_menu  := aEmp
			else
				web extended init chtml
				cHtml := execinpage("login_screen")
				web extended end    
				return cHtml
			endif
		else
			web extended init chtml
			cHtml := execinpage("login_screen")
			web extended end    
			return cHtml
		endif			
	endif	

	if empty(httpsession->user_code)
		web extended init chtml
		cHtml := execinpage("login_screen")
		web extended end    
		return cHtml
	endif

	if len(httpsession->emp_menu) == 1 .and. httpsession->emp_menu[1] <> httpsession->emp_atu
		cNewEmp := httpsession->emp_menu[1]
		httpsession->emp_atu := cNewEmp
		rpcclearenv()
		rpcsettype(3)
		WFPrepEnv(cNewEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)
	endif

	if !empty(cNewEmp)
		rpcclearenv()
		rpcsettype(3)
		WFPrepEnv(cNewEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)
	endif

	if !empty(httpget->emp)
		httpsession->emp_atu := httpget->emp
	elseif empty(httpsession->emp_atu)
		httpsession->emp_atu := aEmp[1]
	endif

	if empty(httpsession->user_code)
		web extended init chtml
		cHtml := execinpage("login_screen")
		web extended end    
		return cHtml
	endif

	do case

		case cAction $ "aprove/reject"
		private cWF2 := getApvFilter()
		private cMsg := ""
		if cAction == "aprove"
			cOption:= "L"
		elseif cAction == "reject"
			cOption:= "R"
		endif
		cNumSc := httpsession->docto
		cMsg   := decide(cNumSc, cOption)
		private cSC1 := getRows(cUsr,,"headerapv")
		web extended init chtml
		cAction == "viewapv"
		private lIsAprov := isAprov(cUsr, cPsw)
		cHtml := execinpage("browse_apv")
		web extended end
		case cAction == "viewapv"
		private cWF2 := getApvFilter()
		private cSC1 := getRows(cUsr,,"headerapv")
		web extended init chtml
		private lIsAprov := isAprov(cUsr, cPsw)
		cWF2  := getApvFilter()
		cHtml := execinpage("browse_apv")
		web extended end
		otherwise
		private cWF2 := getFilter()
		private cSC1 := getRows(cUsr,,"header")
		web extended init chtml
		private lIsAprov := isAprov(cUsr, cPsw)
		cHtml := execinpage("browse_scs")
		web extended end
	endcase
Return chtml

User Function viewmsgs
	local   chtml   := ""
	private cEmp    := httpsession->emp_atu
	private cNewEmp := httpget->emp
	private cFil    := httpsession->emp_fil

	private aEmp    := httpsession->emp_menu
	private cUsr    := httpsession->user_code
	private cPsw    := httpsession->user_pass

	private cMsg    := ""

	default cEmp    := "01"
	default cFil    := "01"	

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"

	rpcclearenv()
	rpcsettype(3)

	WFPrepEnv(cEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)

	private cWF3 := getMessages(cUsr) 

	web extended init chtml
	private cWF2 := getFilter()
	private lIsAprov := isAprov(cUsr, cPsw)
	cHtml := execinpage("browse_msg")
	//CHTML := "hellow"
	web extended end	
Return chtml

Static Function getrows(cUsr, cNumSc, cLevel, nRegId)
	Local cSC1 := GetNextAlias()
	Local cOrdem := "%"+"a"+"%"
	// tipos de ordem:
	// numSc, Status, Prioridade, aprovador, data , classe de valor

	IF cLevel == "header"
		if cFiltro == "f01"
			beginsql alias csc1
				%noparser%
				COLUMN C1_EMISSAO AS DATE
				SELECT C1_NUM, C1_APROV, C1_YMAT, C1_YSTATUS, C1_EMISSAO, MAX(C1_YDATHOR) C1_YDATHOR, C1_CLVL, C1_WFID
				FROM %TABLE:SC1% with (nolock)
				WHERE C1_FILIAL = %XFILIAL:SC1%
				AND C1_YMAT   = %EXP:cUsr%
				AND %NOTDEL%
				GROUP BY C1_NUM, C1_APROV, C1_YMAT, C1_YSTATUS, C1_EMISSAO, C1_YDATHOR, C1_CLVL, C1_WFID
				ORDER BY C1_NUM DESC
			endsql
		else
			cSC1 := filterSCs(cFilTxt,cFilBy)
		endif
	ELSEIF cLevel == "headerapv"
		cEmpFil := cEmpAnt+cFilAnt
		if !empty(cFilBy)
			cFiltro := "AND C1_WFID = "+ValToSql(cFilBy)
			cFiltro := "%"+cFiltro+"%"
			cTop25  := "%%"			
		else
			cFiltro := "%%"
			cTop25  := "%TOP 50%"
			//cFiltro := "%AND C1_WFID = '100001'%"
		endif

		beginsql alias csc1
			%noparser%
			COLUMN C1_EMISSAO AS DATE
			SELECT %exp:cTop25% C1_NUM, C1_APROV, C1_YMAT, C1_YSTATUS, C1_EMISSAO, MAX(C1_YDATHOR) C1_YDATHOR, C1_CLVL
			FROM %TABLE:SC1% with (nolock)
			WHERE C1_FILIAL = %XFILIAL:SC1%
			AND C1_YMAT = (SELECT Z0_MAT FROM %table:SZ0% x
			WHERE Z0_FILIAL = %xfilial:SZ0%
			AND Z0_CODSUP = %exp:cusr%
			AND Z0_EMP = %exp:cempfil%
			AND Z0_MAT = C1_YMAT                                  
			AND Z0_CLVL = C1_CLVL 
			AND x.%notdel%
			UNION 
			SELECT Z0_MAT FROM %table:SZ0% y
			WHERE Z0_FILIAL = %xfilial:SZ0%
			AND Z0_EMP = %exp:cempfil%   
			AND Z0_MAT = C1_YMAT
			AND Z0_CLVL = C1_CLVL                                  
			AND Z0_CODSUP = (SELECT ZZ4_COD FROM %table:ZZ4% z
			WHERE ZZ4_CODTMP = %exp:cusr%
			AND z.%notdel%)
			AND y.%notdel%)			                       
			AND %NOTDEL%
			%exp:cFiltro%
			GROUP BY C1_NUM, C1_APROV, C1_YMAT, C1_YSTATUS, C1_EMISSAO, C1_YDATHOR, C1_CLVL
			ORDER BY C1_NUM DESC
		endsql		
	ELSEIF cLevel == "detail"
		beginsql alias csc1
			%noparser%
			column C1_DATPRF as date
			SELECT C1_FILIAL, C1_DATPRF, C1_APROV, C1_NUM, C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_UM, C1_QUANT, C1_YAPLIC, C1_YSTATUS, C1_YTAG, C1_CLVL, C1_YMELHOR, C1_YOBS, C1_ITEMCTA, C1_YCONTR, C1_YFORNEC, R_E_C_N_O_ REGID
			FROM %TABLE:SC1% with (nolock)
			WHERE C1_FILIAL = %XFILIAL:SC1%
			AND C1_YMAT   = %EXP:cUsr%
			AND C1_NUM = %EXP:cNumSc%
			AND %NOTDEL%
			ORDER BY C1_FILIAL, C1_NUM, C1_ITEM 
		endsql	
	ELSEIF cLevel == "detailapv"
		beginsql alias csc1
			%noparser%
			column C1_DATPRF as date
			SELECT C1_FILIAL, C1_DATPRF, C1_YMAT, C1_APROV, C1_NUM, C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_UM, C1_QUANT, C1_YAPLIC, C1_YSTATUS, C1_YTAG, C1_CLVL, C1_YMELHOR, C1_YOBS, C1_ITEMCTA, C1_YCONTR, C1_YFORNEC, R_E_C_N_O_ REGID
			FROM %TABLE:SC1% with (nolock)
			WHERE C1_FILIAL = %XFILIAL:SC1%
			AND C1_NUM    = %EXP:cNumSc%
			AND %NOTDEL%
			ORDER BY C1_FILIAL, C1_NUM, C1_ITEM 
		endsql	
	ELSEIF cLevel == "object"
		beginsql alias csc1
			%noparser%
			column C1_DATPRF as date
			SELECT C1_FILIAL, C1_DATPRF, C1_NUM, C1_YMAT, C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_UM, C1_QUANT, C1_YAPLIC, C1_YTAG, C1_YOBS, C1_YFORNEC, C1_CLVL, C1_YSTATUS, C1_YMELHOR, C1_YCONTR, C1_ITEMCTA, R_E_C_N_O_ REGID
			FROM %TABLE:SC1% with (nolock)
			WHERE C1_FILIAL = %XFILIAL:SC1%
			AND C1_YMAT   = %EXP:cUsr%
			AND R_E_C_N_O_= %EXP:nRegId%
			AND %NOTDEL%
			ORDER BY C1_FILIAL, C1_NUM, C1_ITEM 
		endsql
	ELSEIF cLevel == "objectapv"
		beginsql alias csc1
			%noparser%
			column C1_DATPRF as date
			SELECT C1_FILIAL, C1_DATPRF, C1_NUM, C1_YMAT, C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_UM, C1_QUANT, C1_YAPLIC, C1_YTAG, C1_YOBS, C1_YFORNEC, C1_CLVL, C1_YSTATUS, C1_YMELHOR, C1_YCONTR, C1_ITEMCTA, R_E_C_N_O_ REGID
			FROM %TABLE:SC1% with (nolock)
			WHERE C1_FILIAL = %XFILIAL:SC1%
			AND R_E_C_N_O_= %EXP:nRegId%
			AND %NOTDEL%
			ORDER BY C1_FILIAL, C1_NUM, C1_ITEM
		endsql
	ENDIF
	//cTime := StrTran(Time(),":","")
	//memowrite("\getRows_"+cLevel+"_"+cTime+".txt",getLastQuery()[2])
Return cSC1

Static Function getTags
	LOCAL cSZC := GetNextAlias()

	BEGINSQL Alias cSZC
		%noparser%
		SELECT ZC_FILIAL, ZC_NUM, ZC_AREA, ZC_DESC
		FROM %Table:SZC% with (nolock)
		WHERE ZC_FILIAL = %xFilial:SZC%
		AND ZC_SITUACA = 'ATIVO'
		AND %NotDel%
		ORDER BY ZC_NUM
	ENDSQL
Return cSZC

Static Function getFilter
	local cWF2    := GetNextAlias()
	local cSC1    := GetNextAlias()
	local cFilter := ""
	//local cEmpFil := httpsession->emp_atu+httpsession->emp_fil	

	beginsql alias cSC1
		%noparser%
		select distinct C1_WFID
		from %table:SC1%
		where C1_FILIAL = %xFilial:SC1% 
		and C1_YMAT   = %exp:cUsr%
		and %notdel%		   
	endsql

	while !(cSC1)->(eof())
		cFilter += alltrim((cSC1)->C1_WFID)+","
		(cSC1)->(dbskip())
	enddo

	cFilter := FormatIn(cFilter,",")
	cFilter := "%WF2_STATUS IN "+cFilter+"%"

	(cSC1)->(dbclosearea())

	beginsql alias cWF2
		%noparser%
		SELECT WF2_FILIAL, WF2_PROC, WF2_STATUS, WF2_YDESC WF2_DESCR
		FROM %TABLE:WF2% with (nolock)
		WHERE WF2_FILIAL = %XFILIAL:WF2% 
		AND %NOTDEL%
		AND %exp:cFilter%
	endsql
return cWF2

Static Function getApvFilter
	local cWF2    := GetNextAlias()
	local cSC1    := GetNextAlias()
	local cFilter := ""
	//local cEmpFil := httpsession->emp_atu+httpsession->emp_fil

	beginsql alias cSC1
		%noparser%
		select distinct C1_WFID
		from %table:SC1% d
		where C1_FILIAL = %xFilial:SC1%
		AND C1_YMAT IN (select distinct Z0_MAT
		from %table:sz0% a with (nolock)
		where Z0_FILIAL = %xfilial:sz0%
		and Z0_CODSUP = %exp:cusr%
		and a.%notdel%	 		   
		union	 		 
		select distinct Z0_MAT
		from %table:sz0% b with (nolock)
		where Z0_FILIAL = %xfilial:sz0%
		and Z0_CODSUP in (select distinct ZZ4_COD 
		from %table:zz4% c
		where ZZ4_FILIAL = %xfilial:zz4%
		and ZZ4_CODTMP = %exp:cusr%
		and c.%notdel%)
		and b.%notdel%)
		AND C1_CLVL IN (select distinct Z0_CLVL
		from %table:sz0% a with (nolock)
		where Z0_FILIAL = %xfilial:sz0%
		and Z0_CODSUP = %exp:cusr%
		and a.%notdel%	 		   
		union	 		 
		select distinct Z0_MAT
		from %table:sz0% b with (nolock)
		where Z0_FILIAL = %xfilial:sz0%
		and Z0_CODSUP in (select distinct ZZ4_COD 
		from %table:zz4% c
		where ZZ4_FILIAL = %xfilial:zz4%
		and ZZ4_CODTMP = %exp:cusr%
		and c.%notdel%)
		and b.%notdel%)
		and d.%notdel%		   
	endsql

	while !(cSC1)->(eof())
		cFilter += alltrim((cSC1)->C1_WFID)+","
		(cSC1)->(dbskip())
	enddo

	cFilter := FormatIn(cFilter,",")
	cFilter := "%WF2_STATUS IN "+cFilter+"%"

	(cSC1)->(dbclosearea())

	beginsql alias cWF2
		%noparser%
		SELECT WF2_FILIAL, WF2_PROC, WF2_STATUS, WF2_YDESC WF2_DESCR
		FROM %TABLE:WF2% with (nolock)
		WHERE WF2_FILIAL = %XFILIAL:WF2% 
		AND %NOTDEL%
		AND %exp:cFilter%
	endsql
return cWF2

user function getNomeFun(cUsr)
	local cNomeUser := ""
	local cSZ0 := getnextalias()

	beginsql alias csz0
		%noparser%
		select distinct Z0_NOME
		from %table:sz0% with (nolock)
		where Z0_FILIAL = %xfilial:sz0% 
		and Z0_MAT    = %exp:cUsr%
		and %notdel%
	endsql

	cNomeUser := Capital((csz0)->z0_nome)

	(csz0)->(dbclosearea())
return cNomeUser

user function getNomeUsr(cUsr)
	local cNomeUser := ""
	local cSZ0 := getnextalias()

	beginsql alias csz0
		%noparser%
		select distinct Z0_NOME
		from %table:sz0% with (nolock)
		where Z0_FILIAL = %xfilial:sz0% 
		and Z0_MAT    = %exp:cUsr%
		and Z0_SENHA  = %exp:cPsw%
		and %notdel%
		union 
		select distinct ZZ4_NOME nome
		from %table:zz4% with (nolock)
		where ZZ4_FILIAL = %xfilial:zz4%
		and ZZ4_COD    = %exp:cUsr%
		and ZZ4_SENHA  = %exp:cPsw%
		and %notdel%
	endsql

	cNomeUser := Capital((csz0)->z0_nome)

	(csz0)->(dbclosearea())
return cNomeUser

user function GetAprova(cEmpFil, cUsr, cCLVL)
	LOCAL cAprova := ""
	LOCAL cSQL    := GetNextAlias()
	LOCAL cSuper  := ""
	LOCAL cSupTmp := ""

	BEGINSQL ALIAS cSQL
		%noparser%
		SELECT Z0_CODSUP, ZZ4_CODTMP
		FROM %TABLE:SZ0% A with (nolock)
		INNER JOIN %TABLE:ZZ4% B
		ON ZZ4_FILIAL = %XFILIAL:ZZ4%
		AND ZZ4_COD    = A.Z0_CODSUP
		AND B.%NOTDEL%
		WHERE Z0_FILIAL = %XFILIAL:SZ0%
		AND Z0_EMP    = %EXP:cEmpFil%
		AND Z0_MAT    = %EXP:cUsr%
		AND Z0_CLVL   = %EXP:cCLVL%
		AND A.%NOTDEL%
	ENDSQL

	//QOUT(getLastQuery()[2])

	cSuper  := (cSQL)->Z0_CODSUP
	cSupTmp := (cSQL)->ZZ4_CODTMP

	IF !EMPTY(cSupTmp)
		cAprova := POSICIONE("ZZ4",1,XFILIAL("ZZ4")+cSupTmp,"ZZ4_NOME")
	ELSE 
		cAprova := POSICIONE("ZZ4",1,XFILIAL("ZZ4")+cSuper,"ZZ4_NOME")
	ENDIF

	cAprova := Capital(cAprova)

	IF EMPTY(cAprova)
		cAprova := "SC Inválida"
	ENDIF
Return cAprova

user function GetStatus(cCodStat)
	// melhoria - alterar para codigos do workflow
	LOCAL cAprova := ""

	DO CASE
		CASE cCodStat == "B"
		cAprova := "SC Bloqueada"
		CASE cCodStat == "L" 
		cAprova := "SC Aprovada"
		CASE cCodStat == "R"
		cAprova := "SC Rejeitada"
	ENDCASE

Return cAprova

User Function newsc
	Local cHTML := ""      

	private cEmp    := httpsession->emp_atu
	private cNewEmp := httpget->emp
	private cFil    := httpsession->emp_fil

	private aEmp    := httpsession->emp_menu
	private cUsr    := httpsession->user_code
	private cPsw    := httpsession->user_pass
	private cCodProd:= httppost->prod_cod

	private cAction := httpget->action

	default cAction := ""
	default cNewEmp := ""
	default aEmp    := {}
	default cEmp    := "01"
	default cFil    := "01"
	default cUsr    := httpsession->user_code
	default cPsw    := httpsession->user_pass
	default cCodProd:= ""

	private cNumSc  := httpget->docto
	private cSKU    := httppost->sku
	private cMsg    := ""

	default cNumSc := iif(!empty(httpsession->docto),httpsession->docto,"")
	default cSKU   := ""

	varinfo("cNumSC",cNumSC)
	varinfo("cSKU",cSKU)

	if !Empty(cNumSc)
		httpsession->docto := cNumSc
	endif

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"

	rpcclearenv()
	rpcsettype(3)

	WFPrepEnv(cEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)

	SetMntStat("Abrindo ambiente, Empresa "+cEmp+" Filial "+cFil)

	do case
		case cAction == "blank"
		cNumSc := ""
		httpsession->docto := ""
		case cAction == "add"
		cNumSc := httppost->docto
		nRegId := val(httppost->object)
		cMsg   := addItem(cNumSc)
		cAction:= "view"
		cNumSc := sc1->c1_num
		httpsession->docto := sc1->c1_num
		case cAction == "destroy"
		cNumSc := httppost->docto
		nRegId := val(httppost->object)
		cMsg   := destroyItem(nRegId)
		cAction:= "view"
		case cAction == "edit"
		cNumSc := httppost->docto
		nRegId := val(httppost->object)
		cMsg   := editItem(nRegId)
		cAction:= "view"
		case cAction == "checkout"
		cNumSc := httpsession->docto
		cMsg   := checkout(cNumSc)
		cAction:= "view"
	endcase

	PRIVATE cSC1 := getRows(cUsr,cNumSc,"detail")
	PRIVATE cCTD := getCTD()
	PRIVATE cCTH := getCTH()
	PRIVATE cSC3 := getSC3()
	PRIVATE cZZE := getZZE() 
	PRIVATE cSB1 := getSB1(cSKU)
	PRIVATE cRES := searchSC1()

	web extended init chtml
	private lIsAprov := isAprov(cUsr, cPsw)
	cHtml := execinpage("newscs")
	web extended end

	(cSC1)->(DbCloseArea())
	(cCTD)->(DbCloseArea())
	(cCTH)->(DbCloseArea())
	(cSC3)->(DbCloseArea())
	(cZZE)->(DbCloseArea())

	IF SELECT("cSB1") > 0
		cSB1->(DbCloseArea())
	ENDIF

Return chtml

User Function aprovsc
	Local cHTML := ""      

	private cEmp    := httpsession->emp_atu
	private cNewEmp := httpget->emp
	private cFil    := httpsession->emp_fil

	private aEmp    := httpsession->emp_menu
	private cUsr    := httpsession->user_code
	private cPsw    := httpsession->user_pass
	private cCodProd:= httppost->prod_cod
	private cMessage:= httppost->mensagem	
	private nRegId  := httppost->object

	private cAction := httpget->action


	default cAction := ""
	default cNewEmp := ""
	default aEmp    := {}
	default cEmp    := "01"
	default cFil    := "01"
	default cUsr    := httpsession->user_code
	default cPsw    := httpsession->user_pass
	default cCodProd:= ""
	default cMessage:= ""
	default nRegId  := 0

	private cNumSc  := httpget->docto
	private cSKU    := httppost->sku
	private cMsg    := ""

	default cNumSc := iif(!empty(httpsession->docto),httpsession->docto,"")
	default cSKU   := ""

	varinfo("cNumSC",cNumSC)
	varinfo("cSKU",cSKU)

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"
	HttpHeadOut->Expires 		:= "Mon, 26 Jul 1997 05:00:00 GMT "
	HttpHeadOut->Last_Modified 	:= TransData()
	HttpHeadOut->Cache_Control 	:= "no-store, no-cache, must-revalidate, post-check=0, pre-check=0;"
	HttpHeadOut->pragma 		:= "no-cache"

	if empty(httpsession->user_code)	
		web extended init chtml
		cHtml := execinpage("login_screen")
		web extended end    	
		return cHtml
	endif

	if !Empty(cNumSc)
		httpsession->docto := cNumSc
	endif

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"

	rpcclearenv()
	rpcsettype(3)

	WFPrepEnv(cEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)

	SetMntStat("Abrindo ambiente, Empresa "+cEmp+" Filial "+cFil)

	do case
		case cAction == "aprove"
		cNumSc := httpsession->docto
		cOption:= "L"			
		cMsg   := decide(cNumSc, cOption)
		cAction:= "viewapv"
		case cAction == "reject"
		cNumSc := httpsession->docto
		cOption:= "R"
		cMsg   := decide(cNumSc, cOption)
		cAction:= "viewapv"
		case cAction == "comment"
		sc1->(dbgoto(val(nRegId)))
		cCodStatus := "100005" // Msg Correção Aprovador
		cUserOrig  := cUsr
		cUserDest  := sc1->c1_ymat
		cChave     := sc1->(c1_filial+c1_num+c1_item)
		cMsg       := sendMessage(cCodStatus, cUserOrig, cUserDest, cMessage, cChave)
		cAction:= "viewapv"
	endcase

	PRIVATE cSC1 := getRows(cUsr,cNumSc,"detailapv")
	PRIVATE cCTD := getCTD()
	PRIVATE cCTH := getCTH()
	PRIVATE cSC3 := getSC3()
	PRIVATE cZZE := getZZE() 
	PRIVATE cSB1 := getSB1(cSKU)
	PRIVATE cRES := searchSC1()

	web extended init chtml
	private lIsAprov := isAprov(cUsr, cPsw)
	cHtml := execinpage("aprovsc")
	web extended end

	(cSC1)->(DbCloseArea())
	(cCTD)->(DbCloseArea())
	(cCTH)->(DbCloseArea())
	(cSC3)->(DbCloseArea())
	(cZZE)->(DbCloseArea())

	IF SELECT("cSB1") > 0
		cSB1->(DbCloseArea())
	ENDIF

Return chtml

Static Function login(cUsr, cPsw)
	LOCAL cSQL  := GetNextAlias()

	BEGINSQL Alias cSQL
		%noparser%
		SELECT DISTINCT Z0_NOME NOME, Z0_EMP EMP
		FROM SZ0010 with (nolock)
		WHERE Z0_FILIAL = %XFILIAL:SZ0%
		AND Z0_MAT    = %Exp:cUsr%
		AND Z0_SENHA  = %Exp:cPsw%
		AND %NotDel%           
		UNION 
		SELECT DISTINCT Z0_NOME NOME, Z0_EMP EMP
		FROM SZ0050 with (nolock)
		WHERE Z0_FILIAL = %XFILIAL:SZ0%
		AND Z0_MAT    = %Exp:cUsr%
		AND Z0_SENHA  = %Exp:cPsw%
		AND %NotDel%
		UNION 
		SELECT DISTINCT ZZ4_NOME NOME, '0101' EMP
		FROM %TABLE:ZZ4% with (nolock)
		WHERE ZZ4_FILIAL = %XFILIAL:SZ0%
		AND ZZ4_COD    = %Exp:cUsr%
		AND ZZ4_SENHA  = %Exp:cPsw%
		AND %NotDel%
		UNION 		
		SELECT DISTINCT ZZ4_NOME NOME, '0501' EMP
		FROM %TABLE:ZZ4% with (nolock)
		WHERE ZZ4_FILIAL = %XFILIAL:SZ0%
		AND ZZ4_COD    = %Exp:cUsr%
		AND ZZ4_SENHA  = %Exp:cPsw%
		AND %NotDel%  
	ENDSQL

Return cSQL

Static Function isAprov(cUsr, cPsw)
	local lIsAprov := .F.
	local cZZ4     := GetNextAlias()

	beginsql alias cZZ4	
		%noparser%
		SELECT DISTINCT ZZ4_NOME NOME, 'ZZZZ' EMP
		FROM %TABLE:ZZ4% with (nolock)
		WHERE ZZ4_FILIAL = %XFILIAL:SZ0%
		AND ZZ4_COD    = %Exp:cUsr%
		AND ZZ4_SENHA  = %Exp:cPsw%
		AND %NotDel%
	endsql

	if !(cZZ4)->(Eof())
		lIsAprov := .T.
	endif

	(cZZ4)->(DbCloseArea())	

Return lIsAprov

static function searchSC1
	local cSC1 := GetNextAlias()
	makedir("\dirdoc\"+httpsession->sessionid+"\")
	makedir("\dirdoc\"+httpsession->sessionid+"\"+httpsession->user_code+cEmpAnt)
	qout("criando diretorio em "+"\dirdoc\"+httpsession->sessionid+"\"+httpsession->user_code+cEmpAnt)
return cSC1

User Function edit_item
	Local cHTML := ""

	private cEmp    := httpsession->emp_atu
	private cNewEmp := httpget->emp
	private cFil    := httpsession->emp_fil

	private aEmp    := httpsession->emp_menu
	private cUsr    := httpsession->user_code
	private cPsw    := httpsession->user_pass

	private cAction := httpget->action

	default cAction := ""
	default cNewEmp := ""
	default aEmp    := {}
	default cEmp    := "01"
	default cFil    := "01"
	default cUsr    := httpsession->user_code
	default cPsw    := httpsession->user_pass

	private cNumSc  := httpget->docto
	private nRegid  := Val(httpget->object)

	default cNumSc  := ""
	default nRegid  := 0

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"
	HttpHeadOut->Expires 		:= "Mon, 26 Jul 1997 05:00:00 GMT "
	HttpHeadOut->Last_Modified 	:= TransData()
	HttpHeadOut->Cache_Control 	:= "no-store, no-cache, must-revalidate, post-check=0, pre-check=0;"
	HttpHeadOut->pragma 		:= "no-cache"

	if empty(httpsession->user_code)	
		web extended init chtml
		cHtml := execinpage("login_screen")
		web extended end    	
		return cHtml
	endif	

	if !empty(cNewEmp) .and. cEmp != cNewEmp
		cEmp := cNewEmp
		httpsession->cEmp     := cEmp
		httpsession->cSortKey := ""
	endif

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"

	rpcclearenv()
	rpcsettype(3)

	WFPrepEnv(cEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)

	SetMntStat("Abrindo ambiente, Empresa "+cEmp+" Filial "+cFil)	

	if cAction == "add"
		sb1->(DbGoTo(nRegid))
	endif

	PRIVATE cSC1 := getRows(cUsr,cNumSc,"object",nRegId)
	PRIVATE cSZC := getTags()
	PRIVATE cSAH := getSAH()

	web extended init chtml
	private lIsAprov := isAprov(cUsr, cPsw)
	cHtml := execinpage("edit_item")
	web extended end

	(cSC1)->(DbCloseArea())
	(cSZC)->(DbCloseArea())
	(cSAH)->(DbCloseArea())

Return chtml

User Function apv_item
	Local cHTML := ""

	private cEmp    := httpsession->emp_atu
	private cNewEmp := httpget->emp
	private cFil    := httpsession->emp_fil

	private aEmp    := httpsession->emp_menu
	private cUsr    := httpsession->user_code
	private cPsw    := httpsession->user_pass

	private cAction := httpget->action

	default cAction := ""
	default cNewEmp := ""
	default aEmp    := {}
	default cEmp    := "01"
	default cFil    := "01"
	default cUsr    := httpsession->user_code
	default cPsw    := httpsession->user_pass

	private cNumSc  := httpget->docto
	private nRegid  := Val(httpget->object)

	default cNumSc  := ""
	default nRegid  := 0

	if !empty(cNewEmp) .and. cEmp != cNewEmp
		cEmp := cNewEmp
		httpsession->cEmp     := cEmp
		httpsession->cSortKey := ""
	endif

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"
	HttpHeadOut->Expires 		:= "Mon, 26 Jul 1997 05:00:00 GMT "
	HttpHeadOut->Last_Modified 	:= TransData()
	HttpHeadOut->Cache_Control 	:= "no-store, no-cache, must-revalidate, post-check=0, pre-check=0;"
	HttpHeadOut->pragma 		:= "no-cache"

	if empty(httpsession->user_code)	
		web extended init chtml
		cHtml := execinpage("login_screen")
		web extended end    	
		return cHtml
	endif

	rpcclearenv()
	rpcsettype(3)

	WFPrepEnv(cEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)

	SetMntStat("Abrindo ambiente, Empresa "+cEmp+" Filial "+cFil)	

	if cAction == "add"
		sb1->(DbGoTo(nRegid))
	endif

	PRIVATE cSC1 := getRows(cUsr,cNumSc,"objectapv",nRegId)
	PRIVATE cSZC := getTags()
	PRIVATE cSAH := getSAH()

	web extended init chtml
	private lIsAprov := isAprov(cUsr, cPsw)
	cHtml := execinpage("apv_item")
	web extended end

	(cSC1)->(DbCloseArea())
	(cSZC)->(DbCloseArea())
	(cSAH)->(DbCloseArea())

Return chtml

Static Function getCTH
	LOCAL cCTH := GetNextAlias()

	BEGINSQL Alias cCTH
		%noparser%
		SELECT CTH_FILIAL, CTH_CLVL, CTH_DESC01, ZZ4_NOME
		FROM %Table:CTH% CTH with (nolock)
		INNER JOIN %TABLE:SZ0% SZ0
		ON Z0_FILIAL = %XFILIAL:SZ0%
		AND Z0_MAT = %EXP:cUsr% 
		AND CTH_CLVL = Z0_CLVL
		AND SZ0.%NOTDEL%
		INNER JOIN %TABLE:ZZ4% ZZ4
		ON ZZ4_FILIAL = %XFILIAL:ZZ4%
		AND ZZ4_COD = Z0_CODSUP
		AND ZZ4.%NOTDEL%
		WHERE CTH_FILIAL = %xFilial:CTH%
		AND CTH_BLOQ = '2'
		AND CTH_CLASSE = '2'
		AND CTH.%NotDel%
		ORDER BY CTH_FILIAL, CTH_CLVL
	ENDSQL

Return cCTH

Static Function getCTD
	LOCAL cCTD  := GetNextAlias()

	BEGINSQL Alias cCTD
		%noparser%
		SELECT CTD_FILIAL, CTD_ITEM, CTD_DESC01
		FROM %Table:CTD% with (nolock)
		WHERE CTD_FILIAL = %xFilial:CTD%
		AND CTD_BLOQ = '2'
		AND CTD_CLASSE = '2'
		AND %NotDel%
		ORDER BY CTD_FILIAL, CTD_ITEM
	ENDSQL

Return cCTD

Static Function getSC3
	LOCAL cSC3 := GetNextAlias()

	BEGINSQL Alias cSC3
		%noparser%
		SELECT DISTINCT C3_NUM
		FROM %Table:SC3% with (nolock)
		WHERE C3_FILIAL = %xFilial:SC3%
		AND C3_NUM > '09'
		AND C3_MSBLQL IN (' ','2')
		AND %NotDel%
		ORDER BY C3_NUM
	ENDSQL
Return cSC3

Static Function getZZE
	LOCAL cZZE := GetNextAlias()

	BEGINSQL Alias cZZE
		%noparser%
		SELECT ZZE_FILIAL, ZZE_NUM, ZZE_DESC
		FROM %Table:ZZE% with (nolock)
		WHERE ZZE_FILIAL = %xFilial:ZZE%
		AND ZZE_STATUS IN ('A','E')
		AND %NotDel%
	ENDSQL
Return cZZE

Static Function getSAH
	LOCAL cSAH := GetNextAlias()

	BEGINSQL Alias cSAH
		%noparser%
		SELECT AH_FILIAL, AH_UNIMED, AH_DESCPO
		FROM %Table:SAH% with (nolock)
		WHERE AH_FILIAL = %xFilial:SAH%
		AND %NotDel%
	ENDSQL
Return cSAH

static function destroyItem(nRegId)
	local cMsgOk  := "Item excluído com sucesso."	
	local cMsgErr := "Ocorreu um erro ao excluir o item."
	local cMsg    := ""

	sc1->(dbgoto(nRegId))

	if SC1->C1_APROV == "B"
		begin transaction

			reclock("SC1",.F.)
			//destroyObj(SC1->(C1_FILIAL+C1_NUM+C1_ITEM))
			sc1->(dbdelete())
			msunlock()
			cMsg := '<div class="flash notice" style="display:block">'
			cMsg += cMsgOk
			cMsg += "</div>"

		end transaction
	else 
		cMsg := '<div class="flash error" style="display:block">'
		cMsg += "Não foi possível excluir o item. Favor verificar se:</br>"
		cMsg += "<ol>"
		cMsg += "<li>A solicitação já foi aprovada.</li>"
		cMsg += "<li>A solicitação foi rejeitada.</li>"
		cMsg += "</ol>"
		cMsg += "</div>"	
	endif

	msunlock()
return cMsg            

static function destroyObj(cCodEnt)
	local cac9 := getnextalias()	
	local cUsrDir:= httpsession->user_code+httpsession->emp_atu

	beginsql alias cac9
		%noparser%
		select R_E_C_N_O_ regid
		from %table:ac9% with (nolock)
		where AC9_FILIAL = %xfilial:ac9% 
		and AC9_CODENT = %exp:cCodEnt%
		and %notdel%
	endsql

	while !(cac9)->(eof())
		ac9->(dbgoto((cac9)->regid))
		if posicione("ACB",1,xFilial("ACB")+AC9->AC9_CODOBJ,"FOUND()")
			reclock("acb",.F.)
			ferase("\dirdoc\"+cUsrDir+"\"+acb->acb_objeto)
			acb->(dbdelete())
			acb->(msunlock())
		endif
		reclock("ac9",.F.)		
		ac9->(dbdelete())
		ac9->(msunlock())

		(cac9)->(dbskip())
	enddo

	(cac9)->(dbclosearea())
return

static function checkout(cNumSc)
	local cMsgOk   := "Gravação do checkout foi feita com sucesso."
	local cMsgErr  := "Ocorreu um erro ao efetuar checkout de alguns itens."
	local cMsg     := ""
	local lExiste  := .T.
	local csc1     := GetNextAlias()	
	local cUsrCode := httpsession->user_code
	local cTime    := left(time(),5)

	beginsql alias csc1
		%noparser%
		select R_E_C_N_O_ regid
		from %table:sc1% with (nolock)
		where C1_FILIAL = %xfilial:sc1% 
		and C1_NUM    = %exp:cnumsc%
		and C1_YMAT   = %exp:cUsrCode%
		and %notdel% 
	endsql

	nRegId := (csc1)->regid
	sc1->(dbgoto(nRegId))	

	if SC1->C1_APROV == "B"
		begin transaction

			while !(csc1)->(eof())
				nRegId := (csc1)->regid
				sc1->(dbgoto(nRegId))

				reclock("sc1",.f.)
				sc1->c1_aprov   := "B"
				sc1->c1_ystatus := httppost->status
				sc1->c1_datprf  := ctod(httppost->necessid)
				sc1->c1_ymelhor := httppost->melhoria
				sc1->c1_itemcta := httppost->itemcta
				sc1->c1_ycontr  := httppost->contrato
				sc1->c1_clvl    := httppost->clvl
				sc1->c1_ydathor := dtos(dDatabase)+"-"+cTime
				sc1->c1_cc      := getCCusto(httppost->clvl)
				msunlock()
				(csc1)->(dbskip())
			enddo

		end transaction

		cMsg := '<div class="flash notice" style="display:block">'
		cMsg += cMsgOk
		cMsg += "</div>"
	else
		cMsg := '<div class="flash error" style="display:block">'
		cMsg += "Não foi possível completar o checkout desta solicitação. Favor verificar se:</br>"
		cMsg += "<ol>"
		cMsg += "<li>A solicitação já foi aprovada anteriormente.</li>"
		cMsg += "<li>A solicitação foi rejeitada pelo aprovador.</li>"
		cMsg += "</ol>"
		cMsg += "</div>"
	endif	
return cMsg

static function addItem(cNumSc)
	local cMsgOk  := "Item incluído com sucesso."	
	local cMsgErr := "Ocorreu um erro ao incluir o item."
	local cMsg    := ""
	local lNewPro := .F.
	local csc1    := GetNextAlias()
	local nQtde   := val(httppost->prod_qtde)

	beginsql alias csc1
		%noparser%
		column C1_EMISSAO as date
		column C1_DATPRF  as date
		select MAX(C1_CLVL)    C1_CLVL,    MAX(C1_YCONTR)  C1_YCONTR,  MAX(C1_ITEMCTA) C1_ITEMCTA,
		MAX(C1_ITEM)    C1_ITEM,    MAX(C1_EMISSAO) C1_EMISSAO, MAX(C1_YDATHOR) C1_YDATHOR,
		MAX(C1_YSTATUS) C1_YSTATUS, MAX(C1_DATPRF)  C1_DATPRF,  MAX(C1_YMELHOR) C1_YMELHOR,
		MAX(C1_APROV)   C1_APROV
		from %table:sc1% with (nolock)
		where C1_FILIAL = %xfilial:sc1% 
		and C1_NUM    = %exp:cNumSc%
		and %notdel%
	endsql

	if empty(cNumSc) .or. (csc1)->c1_aprov == "B" .or.  nQtde > 0

		sb1->(dbsetorder(1))

		lNewPro := (("NOVO:" $ cCodProd) .or. empty(cCodProd))

		begin transaction

			if empty(cNumSc)
				cNumSc := GetSxeNum("SC1","C1_NUM")
				ConfirmSX8()
			endif

			if lNewPro
				cnew := GetNextAlias()

				beginsql alias cnew
					%noparser%
					select count(C1_PRODUTO) qtde
					from %table:sc1% with (nolock)
					where C1_FILIAL = %xfilial:sc1% 
					and C1_NUM    = %exp:cNumSc%
					and left(C1_PRODUTO,5) = 'NOVO:'
					and %notdel%
				endsql

				if (cnew)->(eof())
					cCodProd := "NOVO:001"
				else
					cCodProd := "NOVO:"+StrZero((cnew)->qtde+1,3)
				endif

				(cnew)->(dbclosearea())
			endif

			posicione("SB1",1,xFilial("SB1")+cCodProd,"found()")

			reclock("SC1",.T.)
			sc1->c1_filial  := xFilial("SC1")
			sc1->c1_ymat    := httpsession->user_code
			sc1->c1_num     := cNumSc
			sc1->c1_item    := soma1((csc1)->c1_item)
			sc1->c1_produto := cCodProd
			sc1->c1_conta   := sb1->b1_conta
			sc1->c1_local   := sb1->b1_locpad
			sc1->c1_descri  := upper(httppost->prod_desc)
			sc1->c1_um      := httppost->prod_unid
			sc1->c1_segum   := httppost->prod_unid
			sc1->c1_qtsegum := val(httppost->prod_qtde)
			sc1->c1_quant   := val(httppost->prod_qtde)
			sc1->c1_qtdorig := val(httppost->prod_qtde)
			sc1->c1_yaplic  := httppost->prod_aplic
			sc1->c1_ytag    := httppost->prod_tag
			sc1->c1_yobs    := upper(httppost->prod_obs)
			sc1->c1_yfornec := upper(httppost->prod_forn)		
			sc1->c1_solicit := httpsession->user_name		
			sc1->c1_filent  := xFilial("SC1")
			sc1->c1_ydathor := (csc1)->c1_ydathor
			sc1->c1_clvl    := (csc1)->c1_clvl
			sc1->c1_itemcta := (csc1)->c1_itemcta
			sc1->c1_ymelhor := (csc1)->c1_ymelhor
			sc1->c1_datprf  := (csc1)->c1_datprf
			sc1->c1_emissao := iif(!empty((csc1)->c1_emissao),(csc1)->c1_emissao,dDatabase)
			sc1->c1_ycontr  := (csc1)->c1_ycontr
			sc1->c1_ystatus := (csc1)->c1_ystatus
			sc1->c1_conta   := sb1->b1_conta

			// a solicitação entra padrão como bloqueada
			if !lNewPro .and. sb1->b1_tipo == "PA"
				sc1->c1_aprov := "L"
				sc1->c1_wfid  := "100003" // SC Aprovada
			else
				sc1->c1_aprov := "B"
				sc1->c1_wfid  := "100001" // SC Bloqueada
			endif

			msunlock()

			cMsg := '<div class="flash notice" style="display:block">'
			cMsg += cMsgOk
			cMsg += "</div>"

			(csc1)->(dbclosearea())

		end transaction
		dbcommitall()
		addFile(cNumSc,sc1->c1_item)
	else
		cMsg := '<div class="flash error" style="display:block">'
		cMsg += "Não foi possível incluir o item. Favor verificar se:</br>"
		cMsg += "<ol>"
		cMsg += "<li>A solicitação já foi aprovada.</li>"
		cMsg += "<li>A solicitação foi rejeitada.</li>"
		cMsg += "<li>A quantidade está zerada.</li>"
		cMsg += "</ol>"
		cMsg += "</div>"
	endif
return cMsg

static function editItem(nRegId)
	local cMsgOk  := "Item alterado com sucesso."	
	local cMsgErr := "Ocorreu um erro ao alterar o item."
	local cMsg    := ""
	local nQtde   := val(httppost->prod_qtde)

	sc1->(dbgoto(nRegId))
	sc1->(msunlockall())

	if sc1->c1_aprov == "B"	.and. nQtde > 0
		posicione("SB1",1,xFilial("SB1")+sc1->c1_produto,"found()")		
		reclock("SC1",.F.)
		sc1->c1_conta   := sb1->b1_conta
		sc1->c1_aprov   := "B"
		sc1->c1_descri  := upper(httppost->prod_desc)
		sc1->c1_um      := httppost->prod_unid
		sc1->c1_quant   := val(httppost->prod_qtde)
		sc1->c1_yaplic  := httppost->prod_aplic
		sc1->c1_ytag    := httppost->prod_tag
		sc1->c1_yobs    := upper(httppost->prod_obs)
		sc1->c1_yfornec := upper(httppost->prod_forn)
		msunlock()

		cMsg := '<div class="flash notice" style="display:block">'
		cMsg += cMsgOk
		cMsg += "</div>"
	else
		cMsg := '<div class="flash error" style="display:block">'
		cMsg += "Não foi possível alterar a solicitação. Favor verificar se:</br>"
		cMsg += "<ol>"
		cMsg += "<li>A solicitação já foi aprovada anteriormente.</li>"
		cMsg += "<li>A solicitação foi rejeitada pelo aprovador.</li>"
		cMsg += "<li>A quantidade está zerada.</li>"		
		cMsg += "</ol>"
		cMsg += "</div>"	
	endif

	addFile(sc1->c1_num,sc1->c1_item)
return cMsg

static function decide(cNumSc, cOption)
	local cMsgOk  := "O documento foi "+cNumSc+iif(cOption=="L","<em>aprovado.</em>","rejeitado.")
	local cMsgErr := "Ocorreu um erro ao alterar o item."
	local cMsg    := cMsgOk
	local cDatHor := dtos(dDatabase)+"-"+left(time(),5)
	local cSC1    := GetNextAlias()

	beginsql alias csc1
		%noparser%
		select R_E_C_N_O_ regid 
		from %table:sc1% with (nolock)
		where C1_FILIAL = %xfilial:sc1% 
		and C1_NUM    = %exp:cNumSc%
		and %notdel%
		order by C1_FILIAL, C1_NUM, C1_ITEM
	endsql

	while !(csc1)->(eof())
		nRegId := (csc1)->regid
		cMsg := aprovItem(nRegId, cOption, cDatHor)
		(csc1)->(dbskip())
	enddo

return cMsg

static function aprovItem(nRegId, cOption, cDatHor)
	local cMsgOk  := "O documento foi "+iif(cOption=="L","Aprovado.","Rejeitado.")
	local cMsgErr := "Ocorreu um erro ao aprovar documento"
	local cMsg    := ""
	local cnew    := GetNextAlias()

	dbselectarea("SC1")

	default cDatHor := dtos(dDatabase)+"-"+left(time(),5)
	SC1->(msunlockall())
	SC1->(dbgoto(nRegId))  

	if sc1->c1_aprov == "B"
		reclock("SC1",.F.)
		SC1->C1_APROV   := cOption
		SC1->C1_YDATHOR := cDatHor
		if cOption == "L"
			// verifica se existem produtos novos
			// que precisam de cadastro pelo almoxarifado
			beginsql alias cnew
				select top 1 c1_produto newprod
				from %table:sc1%
				where c1_filial = %xFilial:SC1%
				and left(c1_produto,5) = 'NOVO:'
				and %notdel%
			endsql

			if !empty((cnew)->newprod)
				sc1->c1_wfid  := "100002" // Aguardando Cadastro de Produto
			else
				sc1->c1_wfid  := "100003" // SC SC Aprovada
			endif
			(cnew)->(dbclosearea())
		elseif cOption == "R"
			sc1->c1_wfid  := "100004" // SC Rejeitada
		endif
		msunlock()		

		cMsg := '<div class="flash notice" style="display:block">'
		cMsg += cMsgOk
		cMsg += "</div>"
	else
		cMsg := '<div class="flash error" style="display:block">'
		cMsg += "Não foi posível gravar a análise da solicitação. Favor verificar se:</br>"
		cMsg += "<ol>"
		cMsg += "<li>A solicitação já foi aprovada.</li>"
		cMsg += "<li>A solicitação foi rejeitada.</li>"
		cMsg += "</ol>"
		cMsg += "</div>"
	endif		
return cMsg

static function getCCusto(cCLVL)
	//local cGrupo := LEFT(cCLVL,1)
	//do case
	//	case cGrupo $ "1/4"
	//		cCLVL := "1000"
	//	case cGrupo == "2"      
	//		cCLVL := "2000"
	//	case cGrupo $ "3/8"
	//		cCLVL := "3000"
	//endcase

	// Tratamento implementado por Marcos Alberto Soprani em 08/04/16, conforme detalhado BIA478
	cCLVL := U_B478RTCC(cCLVL)[1]

return cCLVL

user function getFiles(cNumSc,cItem)
	local cACB   := getNextAlias()
	local cChave := xFilial("SC1")+cNumSC+cItem

	beginsql alias cACB
		select ACB_OBJETO, ACB_DESCRI
		from %table:ACB% ACB
		inner join %table:AC9% AC9 
		on AC9_FILIAL = %xFilial:AC9%
		and AC9_CODOBJ = ACB_CODOBJ
		and AC9_CODENT = %exp:cChave%
		and AC9.%notdel%
		where ACB_FILIAL = %xFilial:AC9%
		and ACB.%notdel%
	endsql
return cACB

static function addFile(cNumSc,cItem)
	local cdrive := ""
	local cpath  := ""
	local cnome  := ""
	local cext   := ""
	local cUsrDir:= httpsession->user_code
	local aAttach:= {}
	local aNames := {}
	local nSequen:= 1

	while type("httppost->anexo_"+cValToChar(nSequen)) <> "U"
		cNome := &("httppost->anexo_"+cValToChar(nSequen))
		cDesc := &("httppost->descr_"+cValToChar(nSequen))

		if !empty(cNome)

			splitpath(cNome, @cDrive, @cPath, @cNome, @cExt )

			cFile := MD5File("\dirdoc\"+cnome+cext)

			makedir("\dirdoc\"+cNumSc)

			CpyS2T("\dirdoc\"+cnome+cext, "\dirdoc\"+cNumSc+"\"+cFile+cext)

			ferase("\dirdoc\"+cnome+cext)

			putConhec("\dirdoc\"+cNumSc+"\"+cFile+cext, SC1->(C1_NUM+C1_ITEM), "SC1", cnome+cext, )

		endif
		nSequen++
	enddo
return .T.

User Function upAnexoSC (cNumSc, cItem, cFile)

	LOCAL cFileCrip:= ""
	LOCAL   cDrive := ""
	LOCAL    cPath := ""
	LOCAL    cNome := ""
	LOCAL     cExt := ""
	LOCAL     cDir := "\dirdoc\"
	//LOCAL     cDir := "d:\protheus11\protheus_data\P10\dirdoc\"	
	LOCAL lRetorno := .F.

	CONOUT("--------------upAnexoSC-------------------") 
	CONOUT("Iniciando cópia do arquivo de Anexo.") 

	If !empty(cFile) .And. !empty(cNumSc) .And. !empty(cItem)

		If File(cFile)
			If (Len(Directory(cDir+cNumSc, "D")) == 0)
				makedir("\dirdoc\"+cNumSc)
			EndIf

			SPLITPATH( cFile, @cDrive, @cPath, @cNome, @cExt )

			Conout("Gerando arquivo - " +cDir + cNumSc +"\"+cNome+cExt)

			If CpyS2T(cFile, cDir + cNumSc +"\"+cNome+cExt)
				CONOUT("Gerado com sucesso!!!")
				CONOUT("--------------upAnexoSC-------------------")  
				Return .T.
			Else
				CONOUT("Erro ao copiar arquivo!!!") 
			EndIf
		Else
			CONOUT("Arquivo não encontrado") 
		Endif

		//putConhec("\dirdoc\"+cNumSc+"\"+cFile+cext, SC1->(C1_NUM+C1_ITEM), "SC1", cnome+cext, )
	Endif
	CONOUT("--------------upAnexoSC-------------------") 
Return .F.


static function putConhec(cFile, cCodEnt, cAlias, cNomeOrig, cDescri)
	LOCAL   cDrive := ""
	LOCAL    cPath := ""
	LOCAL    cNome := ""
	LOCAL     cExt := ""

	default cAlias := "SC1"

	splitpath( cFile, @cDrive, @cPath, @cNome, @cExt )

	if empty(cFile)
		return .F.
	endif

	reclock("ACB",.T.)
	acb->acb_codobj := GetSXENum("ACB","ACB_CODOBJ")
	acb->acb_filial := xFilial("ACB")
	acb->acb_objeto := cNome+cExt
	acb->acb_descri := cNomeOrig+iif(!empty(cDescri),"/"+cDescri,"")
	msunlock()	
	ConfirmSX8()

	reclock("AC9",.T.)
	ac9->ac9_filial := xFilial("AC9")
	ac9->ac9_filent := xFilial(cAlias)
	ac9->ac9_entida := cAlias
	ac9->ac9_codent := xFilial(cAlias)+cCodEnt
	ac9->ac9_codobj := acb->acb_codobj
	msunlock()	
return .T.

Static Function getSB1(cParam1)
	IF !Empty(cParam1)
		Return u_catalog(cParam1)
	EndIf
Return ""

static function getACB
	local cacb := getnextalias()

	//beginsql alias cacb
	//%noparser%

	//endsql

	makedir("\dirdoc\"+httpsession->sessionid+"\"+httpsession->user_code+cEmpAnt)
return cACB

User Function catalog(cParam1)
	LOCAL lReturn := .T.
	LOCAL cSQL    := ""           
	LOCAL cHTML   := ""	 
	LOCAL cSKU    := httppost->sku
	Local i

	//private cUsr := AllTrim(GETPVPROFSTRING("PARAMETROS","Matricula","",GetADV97()))
	//private cEmp    := AllTrim(GETPVPROFSTRING("PARAMETROS","Empresa","",GetADV97()))
	//private cFil    := AllTrim(GETPVPROFSTRING("PARAMETROS","Filial","",GetADV97()))
	//private cNewEmp := httpget->emp	

	DEFAULT cSKU := httpget->sku

	IF EMPTY(cSKU)
		cSKU := cParam1
	ENDIF

	cSKU := upper(cSKU)

	HttpHeadOut->Content_Type := "text/html; charset=ISO-8859-1"

	IF TYPE("cEMPANT") == "U"
		rpcclearenv()
		rpcsettype(3)           
		WFPrepEnv(cEmp,cFil,"SessionId: ["+httpsession->sessionid+"]",)

		SetMntStat("Abrindo ambiente, Empresa "+cEmp+" Filial "+cFil)	
	ENDIF

	PRIVATE cSB1    := GetNextAlias()

	aWords := Separa(cSKU," ")

	cSQL += "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_RASTRO, R_E_C_N_O_ REGID"+CRLF
	cSQL += "  FROM "+RetSqlName("SB1")+CRLF
	cSQL += " WHERE B1_FILIAL = "+ValToSql(xFilial("SB1"))+CRLF
	For i := 1 to Len(aWords)		
		cSQL += "   AND B1_DESC LIKE "+ValToSql("%"+Alltrim(aWords[i])+"%")+CRLF
	Next i		
	cSQL += "   AND B1_TIPO IN ('GG','MC','MD','IM','PA')"+CRLF
	cSQL += "   AND B1_MSBLQL IN (' ','2') "+CRLF
	cSQL += "   AND D_E_L_E_T_ = ' '"+CRLF
	cSQL += " UNION "+CRLF
	cSQL += "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM, B1_TIPO, B1_RASTRO, R_E_C_N_O_ REGID"+CRLF
	cSQL += "  FROM "+RetSqlName("SB1")+CRLF
	cSQL += " WHERE B1_FILIAL = "+ValToSql(xFilial("SB1"))+CRLF
	cSQL += "   AND LEFT(B1_COD,7) = "+ValToSql(Alltrim(cSKU))+CRLF
	cSQL += "   AND B1_TIPO IN ('GG','MC','MD','IM','PA')"+CRLF
	cSQL += "   AND B1_MSBLQL IN (' ','2') "+CRLF	
	cSQL += "   AND D_E_L_E_T_ = ' '"+CRLF
	cSQL += " ORDER BY B1_COD"

	TCQUERY cSQL New Alias cSB1

Return cSB1

static function filterSCs(cFilTxt,FilBy)
	local lReturn := .T.
	local cSQL    := ""
	local cSC1 := GetNextAlias()
	Local i

	cFilTxt := upper(cFilTxt)

	aWords := Separa(cFilTxt," ")
	for i := 1 to len(aWords)		
		cSQL += " AND C1_DESCRI LIKE "+ValToSql("%"+Alltrim(aWords[i])+"%")+" "
	next i

	if !empty(cFilBy)
		cSQL += " AND C1_WFID = "+ValToSql(cFilBy)+" "
	endif
	cSQL := "%"+cSQL+"%"	

	beginsql alias cSC1
		%noparser%
		COLUMN C1_EMISSAO AS DATE
		SELECT C1_NUM, C1_APROV, C1_YMAT, C1_YSTATUS, C1_EMISSAO, C1_YDATHOR, C1_CLVL, C1_WFID
		FROM %TABLE:SC1% with (nolock)
		WHERE C1_FILIAL = %XFILIAL:SC1%
		AND C1_YMAT   = %EXP:cUsr%		   
		AND %NOTDEL%
		%exp:cSQL%
		GROUP BY C1_NUM, C1_APROV, C1_YMAT, C1_YSTATUS, C1_EMISSAO, C1_YDATHOR, C1_CLVL, C1_WFID

		UNION 

		SELECT C1_NUM, C1_APROV, C1_YMAT, C1_YSTATUS, C1_EMISSAO, C1_YDATHOR, C1_CLVL, C1_WFID
		FROM %TABLE:SC1% with (nolock)
		WHERE C1_FILIAL = %XFILIAL:SC1%
		AND C1_YMAT   = %EXP:cUsr%
		AND LEFT(C1_PRODUTO,7) = %exp:cFilTxt%
		AND %NOTDEL%
		GROUP BY C1_NUM, C1_APROV, C1_YMAT, C1_YSTATUS, C1_EMISSAO, C1_YDATHOR, C1_CLVL, C1_WFID

		ORDER BY C1_NUM DESC
	endsql

Return cSC1

static function sendMessage(cCodStatus, cUserOrig, cUserDest, cMessage, cChave)
	local cMsg := ""
	local cMsgOk  := "Mensagem enviada com sucesso para o solicitante."
	reclock("WF3",.T.)
	wf3->wf3_filial	:= xFilial()
	wf3->wf3_data   := Date()
	wf3->wf3_desc   := upper(cMessage)
	wf3->wf3_hora   := Time()
	wf3->wf3_id     := cChave
	wf3->wf3_status := cCodStatus
	wf3->wf3_usu    := cUserOrig+"|"+cUserDest
	wf3->wf3_resp   := "Nova Mensagem"
	msunlock()

	cMsg := '<div class="flash notice" style="display:block">'
	cMsg += cMsgOk
	cMsg += "</div>"
return cMsg

user function getMsgById(cId)
	local cWF3 := GetNextAlias()

	beginsql alias cWF3
		%noparser%
		column WF3_DATA as date

		select top 10 WF3_FILIAL, WF3_DATA, WF3_HORA, WF3_ID, WF3_DESC, LEFT(WF3_USU,6) WF3_USU, WF3_STATUS
		from %table:WF3%
		where WF3_FILIAL = %xFilial:WF3%
		and WF3_ID = %exp:cId%
		and %notdel%
		order by WF3_DATA DESC, WF3_HORA DESC
	endsql
return cWF3

static function getMessages(cCodUsr)
	local cWF3 := GetNextAlias()

	beginsql alias cwf3
		%noparser%
		column WF3_DATA as date

		select top 10 WF3_FILIAL, WF3_DATA, WF3_HORA, WF3_ID, WF3_DESC, LEFT(WF3_USU,6) WF3_USU, WF3_STATUS
		from %table:WF3%
		where WF3_FILIAL = %xFilial:WF3%
		and substring(WF3_USU,8,6) = %exp:cCodUsr%
		and %notdel%
		order by WF3_DATA DESC, WF3_HORA DESC
	endsql
return cWF3

USER FUNCTION TESTEAPV
	LOCAL cUsr    := AllTrim(GETPVPROFSTRING("PARAMETROS","Matricula"  ,"",GetADV97()))
	LOCAL cCLVL   := AllTrim(GETPVPROFSTRING("PARAMETROS","ClasseValor","",GetADV97()))
	LOCAL cEmp    := AllTrim(GETPVPROFSTRING("PARAMETROS","Empresa","",GetADV97()))
	LOCAL cFil    := AllTrim(GETPVPROFSTRING("PARAMETROS","Filial","",GetADV97()))
	LOCAL cAprov  := ""

	WFPREPENV(cEmp,cFil)

	cAprov := GetAprova(cEmp+cFil, cUsr, cCLVL)

	QOUT(cAprov)
RETURN

class BIWebUser
	data cMat
	data cEmp
	data cFil
	data aCLVL
	data cEmail

	method new()
	method getAprovadores()
	method getEmail()
	method isAprovador()
endclass

method New(cUsr, cEmp, cFil) class BIWebUser
	default cUsr	:= "000000"
	default cEmp	:= "01"
	default cFil	:= "01"
	default cEnail  := ""

	wfprepenv(cEmp,cFil)

	::cMat := cUsr
	::cEmp := cEmp
	::cFil := cFil
	::cEmail := ::getEmail(::cMat, ::c)

Return Self

method getEmail(cUsr) class BIWebUser

return cEmail

user function newproc
	if type("cEmpAnt") == "U"
		rpcsettype(3)	
		wfprepenv("01","01")

		PUTMV("MV_WFSNDAU",.F.)
	endif

	oP := TWFProcess():New("SS4095",,)
	oP:NewTask("100004", "\newproc.html")
	//oP:cSubject := "Teste de Email Substituto"
	//oP:oHTML:ValByName('data',dDataBase)
	oP:Track( "100001", "Ajustar o codigo do item",, )
	//oP:cTo := "felizago@gmail.com"
	oP:cTo := "ranisses.corona@biancogres.com.br"
	oP:UserSiga := "000000"	
	//oP:Start()
	//oP:Finish()
	//WFSendMail( { cEmpAnt, cFilAnt } )
return

user function chkNewProd(cNumSc)
	local cSC1     := getNextAlias()
	local nNewProd := 0
	local cStatus  := "100002"
	local cNewProd := "NOVO:" 
	local nRegId   := 0

	beginsql alias cSC1
		SELECT COUNT(*) QTD
		from %table:SC1%
		where C1_FILIAL = %xFilial:SC1%
		and C1_NUM    = %exp:cNumSC%
		and C1_WFID   = %exp:cStatus%
		and C1_APROV  = 'L'
		and LEFT(C1_PRODUTO,5) = %exp:cNewProd%
		and %notdel%
	endsql

	nNewProd := (cSC1)->qtd

	(cSC1)->(dbclosearea())

	if nNewProd == 0
		beginsql alias cSC1	
			select R_E_C_N_O_ regid
			from %table:SC1%
			where C1_FILIAL = %xFilial:SC1%
			and C1_NUM    = %exp:cNumSC%
			and C1_WFID   = %exp:cStatus%
			and C1_APROV  = 'L'
			and %notdel%
		endsql

		while !(cSC1)->(eof())
			nRegid := (cSC1)->regid
			sc1->(dbgoto(nRegId))
			reclock("SC1",.F.)
			sc1->c1_wfid := "100003" // SC Aprovada
			msunlock()
			(cSC1)->(dbskip())
		enddo
		(cSC1)->(dbclosearea())
	endif
return 

user function getLastMsg(cId)
	local cWF3 := GetNextAlias()
	local cRet := ""

	beginsql alias cWF3
		%noparser%
		column WF3_DATA as date

		select top 1 WF3_FILIAL, WF3_DATA, WF3_HORA, WF3_ID, WF3_DESC, LEFT(WF3_USU,6) WF3_USU, WF3_STATUS
		from %table:WF3%
		where WF3_FILIAL = %xFilial:WF3%
		and WF3_ID = %exp:cId%
		and %notdel%
		order by WF3_DATA DESC, WF3_HORA DESC
	endsql

	if !empty((cWF3)->WF3_USU)
		cApv := Alltrim(posicione("ZZ4",1,xFilial("ZZ4")+(cWF3)->WF3_USU,"ZZ4_NOME"))
		cRet := Alltrim((cWF3)->WF3_DESC)

		cRet := "Em "+dtoc((cWF3)->WF3_DATA)+", às "+(cWF3)->WF3_HORA+", "+Capital(cApv)+" escreveu:"+CRLF+cRet
	endif

	(cWF3)->(dbclosearea())
return cRet

/*
user function rateia
local nValor := 1000
local dAtiv  := STOD("20110414")
local dUlt   := LastDay(dAtiv)
local nDias  := dUlt-dAtiv     
local nDiasMes := LastDay(dAtiv)-FirstDay(dAtiv)+1

nVlrDia := nValor / 30

nValorMes := nVlrDia * nDias

alert(nValorMes)
return

user function testepost
cChave := "32110510524837000193550010000067221006511146"
cSite  := "https://www.nfe.fazenda.gov.br/portal/FormularioDePesquisa.aspx?tipoconsulta=completa&chaveacesso="+cChave

cParam := "ctl00_ContentPlaceHolder3_intercepta="+cCaptcha

cPost := HttpPOST(cSite,,cParam)

qout("Retorno POST: "+cPost)
return
*/

user function testepost
	cChave := "32110510524837000193550010000067221006511146"
	cSite  := "https://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=&chaveacesso="+cChave


	//cParam := "ctl00_ContentPlaceHolder3_intercepta="+cCaptcha

	cPost := HttpPOST(cSite,,)

	qout("Retorno POST: "+cPost)
return

Static Function TransData()

	cData := DToC( Date() )
	cHora := AllTrim( Str( Val( Substr( Time(), 1, 2 ) ) - 3 ) ) + ":" + Substr( Time(), 4, 2 ) + ":" + Substr( Time(), 7, 2 )
	nDiaSem := Dow( CToD( cData ) )
	cDiaSem := ""

	cDia := Substr( cData, 1, 2 )
	cMes := Substr( cData, 4, 2 )
	cAno := Substr( cData, 7, 4 )

	Do Case
		Case cMes == "01"
		cMes := "Jan"
		Case cMes == "02"
		cMes := "Feb"
		Case cMes == "03"
		cMes := "Mar"
		Case cMes == "04"
		cMes := "Apr"
		Case cMes == "05"
		cMes := "May"
		Case cMes == "06"
		cMes := "Jun"
		Case cMes == "07"
		cMes := "Jul"
		Case cMes == "08"
		cMes := "Aug"
		Case cMes == "09"
		cMes := "Sep"
		Case cMes == "10"
		cMes := "Oct"
		Case cMes == "11"
		cMes := "Nov"
		Case cMes == "12"
		cMes := "Dec"
	EndCase

	Do Case
		Case nDiaSem == 1
		cDiaSem := "Sun"
		Case nDiaSem == 2
		cDiaSem := "Mon"
		Case nDiaSem == 3
		cDiaSem := "Tue"
		Case nDiaSem == 4
		cDiaSem := "Wed"
		Case nDiaSem == 5
		cDiaSem := "Thu"
		Case nDiaSem == 6
		cDiaSem := "Fri"
		Case nDiaSem == 7
		cDiaSem := "Sat"
	EndCase		

	cData := cDiaSem + ", " + cDia + " " + cMes + " " + cAno + " " + cHora + " GMT"

Return cData

// parametros para apl
user function pqpabc(aCookies,aPostParms,nProcId,aProcParms,aGets,aTeste)
	a:= 0 
	httpheadout->Status_Code := "404"
	httpheadin->command
	httpheadin->cmdparms
	httpheadin->aheaders
	httpheadin->referer
return "a"

user function wslogin(aCookies,aPostParms,nProcId,aProcParms,aGets,aTeste)
	local bBlock := {|e| erroLogin(e)}

	bErro := ErrorBlock(bBlock)

	begin sequence
		cUser := aPostParms[1][2]
		cPass := aPostParms[2][2]
		recover
		cUser := "admin"
		cPass := "pqp123"	
	end sequence

	qout("usuario: "+cUser)
	qout("senha..: "+cPass)

	PswOrder(2)
	PswSeek(cUser)

	If !PswName(cPass)
		Return "Usuário/senha invalido(s)"
	Endif

	aUser := PswRet(1)
return "Bem vindo, "+Capital(Alltrim(aUser[1,4]))

static function erroLogin(e)
	cUser := "admin"
	cPass := "pqp123"
	break
return

user function wan
	c := "100/101/102/103/104"
	c := formatin(c,"/")
	Alert(c)
return

user function getVlrSc(cNumSc)
	local cSC1     := getNextAlias()
	local nValorSc := 0

	beginsql alias cSC1
		column VALOR as numeric(14,2)
		SELECT sum((b1_uprc * c1_quant)) VALOR
		FROM %table:SC1% x
		INNER JOIN %table:SB1% y
		ON B1_FILIAL = %xFilial:SB1%
		AND B1_COD    = C1_PRODUTO
		AND SUBSTRING(B1_GRUPO,1,3) <> '306'
		AND y.%NOTDEL% 
		WHERE C1_FILIAL = %xFilial:SC1%
		AND C1_NUM    = %exp:cNumSc%
		AND x.%NOTDEL%
	endsql

	nValorSc := (cSC1)->VALOR

	(cSC1)->(dbclosearea())
return nValorSc

user function viewFiles
	local cACB   := ""
	local cChave := ""
	local cHTML  := ""
	local cNumSc := httpget->attch
	local cServer:= alltrim(GetEnvHost())

	wfprepenv("01","01")

	cSC1   := getNextAlias()	
	cACB   := getNextAlias()

	beginsql alias cSC1
		select C1_FILIAL, C1_NUM, C1_ITEM, C1_DESCRI
		from %table:SC1%
		where C1_FILIAL = %xFilial:SC1%
		and C1_NUM    = %exp:cNumSc%
		and %notdel%
	endsql

	cNumSc := (cSC1)->C1_NUM

	web extended init cHTML

	cHTML += "<html>"
	cHTML += "<title>Visualizando anexos da SC "+cNumSc+"</title>"
	cHTML += "<h3 style='font-family:Monospace;'>VISUALIZANDO ANEXOS DA SC NUM: "+cNumSc+"</h3>"

	while !(cSC1)->(eof())    	
		cHTML += "<p style='font-family:Monospace;'>Item: "+(cSC1)->C1_ITEM+"<br/>"
		cHTML += "Descrição: "+alltrim((cSC1)->C1_DESCRI)+"<br/>"
		cHTML += "</p><ol>"

		cChave := (cSC1)->(C1_FILIAL+C1_NUM+C1_ITEM)
		beginsql alias cACB
			select ACB_OBJETO, ACB_DESCRI
			from %table:ACB% ACB 
			inner join %table:AC9% AC9 
			on AC9_FILIAL = %xFilial:AC9%
			and AC9_CODOBJ = ACB_CODOBJ
			and AC9_CODENT = %exp:cChave%
			and AC9.%notdel%
			where ACB_FILIAL = %xFilial:AC9%
			and ACB.%notdel%
		endsql

		while !(cACB)->(eof())		
			cHTML += '<li style="font-family:Monospace;"><a href="http://'+cServer+'/anexos/'+cNumSc+'/'+(cACB)->ACB_OBJETO+'" target=_blank>'+Alltrim((cACB)->ACB_DESCRI)+"</a></li>"
			(cACB)->(dbskip())
		enddo

		cHTML += "</ol>"
		cHTML += "</html>"

		(cACB)->(dbclosearea())
		(cSC1)->(dbskip())
	enddo   

	(cSC1)->(dbclosearea())

	web extended end    
return cHTML 

user function MT110ROT
	local aRotina  := paramixb
	local aNewOpc  := {"Abrir Anexos","u_A130WEB",0,6}

	aadd(aRotina, aNewOpc)
return aRotina

user function openAnexos
	local cComando := ""
	local cServer  := alltrim(padr(GetServerIP(),15))
	local cPorta   := Alltrim(GetPvProfString("HTTP","PORT","8686",GetADV97()))

	//cComando := "http://"+cServer+":"+cPorta+"/websc/u_viewFiles.apw?attch="+rtrim(SC1->C1_NUM)
	//cComando := "http://srv_web_protheus:6969/ws02/u_viewFiles.apw?attch="+rtrim(SC1->C1_NUM)
	If !Empty(SC1->C1_YBIZAGI)
		
		If Upper(AllTrim(GetSrvProfString("DbAlias", ""))) <> "PRODUCAO"
			cComando := "http://nice/AnexoSC/anexos.aspx?NUMSC="+SC1->C1_NUM+"&NUMITEM="+SC1->C1_ITEM+"&EMP="+cEmpAnt+"01"
		Else
			cComando := "http://ares/AnexosSC/anexos.aspx?NUMSC="+SC1->C1_NUM+"&NUMITEM="+SC1->C1_ITEM+"&EMP="+cEmpAnt+"01"
		EndIf

	Else
		cComando := "http://srv_web_protheus:6969/ws02/u_viewFiles.apw?attch="+rtrim(SC1->C1_NUM)
	EndIf


	ShellExecute("open",cComando,"","",4)
return

user function updStatus(cCodStatus)
	local cSC1   := getNextAlias()
	local nReg   := 0
	local cFil   := sc1->c1_filial
	local cNum   := sc1->c1_num
	local cItem  := sc1->c1_item

	while !(cSC1)->(eof())
		nReg := (cSC1)->regid
		(cSC1)->(dbgoto(nReg))
		reclock("SC1",.f.)
		SC1->C1_WFID := cCodStatus
		msunlock()

		//setFollow(cCodStatus, cChave, cMessage, cUserOrig, cUserDest, cResp)

		(cSC1)->(dbskip())
	enddo
return

static function setFollow(cCodStatus, cChave, cMessage, cUserOrig, cUserDest, cResp)
	default cResp := ""

	reclock("WF3",.T.)
	wf3->wf3_filial	:= xFilial()
	wf3->wf3_data   := Date()
	wf3->wf3_desc   := upper(cMessage)
	wf3->wf3_hora   := Time()
	wf3->wf3_id     := cChave
	wf3->wf3_status := cCodStatus
	wf3->wf3_usu    := cUserOrig+"|"+cUserDest
	wf3->wf3_resp   := cResp
	msunlock()
return

user function vip001
	local cVipTag := httppost->VipTag
	if empty(cVipTag)
		cHtml := "<html>"
		cHtml += '<form action="u_vip001.apw" method="post">' 
		cHtml += '<label for="viptag">Informe a VipTag:</label><br/>'
		cHtml += '<input name="viptag" id="viptag" type="text"><br/>'
		cHtml += '<label for="cliente">Informe o Cliente:</label><br/>'
		cHtml += '<input name="cliente" id="cliente" type="text"><br/>'
		cHtml += '<input name="commit" type="submit" value="Confirma"/>'
		cHtml += '<p><a href="">Novo</a></p>'
		cHtml += "</form>"
		cHtml += "</html>"
	else
		//getProduto(cVipTag)
		cHtml := "Vc digitou: "+cVipTag
	endif
return cHtml
/*
static function getProduto(cVipTag)
local cSQL := getNextAlias()

beginsql alias cSQL
select 
endsql
return cCod

// VIP REDE, CADASTRO DE BASE INSTALADA
/*
user function 
if posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_LOCALIZ") == "S"
for i := 1 to SD1->D1_QUANT
reclock("SBE",.T.)
sbe->be_filial  := xFilial("SBE")
sbe->be_local   := SD1->D1_LOCAL
sbe->be_localiz := getNextSBE(RTRIM(SB1->B1_GRUPO), SD1->D1_LOCAL)
sbe->be_descric := Alltrim(SB1->B1_DESC)+" ["+RTRIM(SD1->D1_DOC)+"/"+RTRIM(SD1->D1_SERIE)+"/"+RTRIM(SD1->D1_ITEM)+"]"
msunlock()
next i
endif
return

static function getNextSBE(cGrupo, cLocal)
local cNextNum := ""
local cSBE     := getNextAlias()

beginsql alias cSBE
%NOPARSER%
select MAX(BE_LOCALIZ) lastNum
from %table:SBE% WITH (NOLOCK)
where BE_FILIAL = %xFilial:SBE%
and BE_LOCAL  = %exp:cLocal%
and LEFT(BE_LOCALIZ,3) = %exp:cGrupo%
and %notdel%
endsql

if empty((cSBE)->lastNum)
cLastNum := alltrim(Substr((cSBE)->lastNum,4))
else 
cLastNum := Replicate("0",5)
endif
cNextNum := cGrupo+Soma1(cLastNum)
return cNextNum
*/
