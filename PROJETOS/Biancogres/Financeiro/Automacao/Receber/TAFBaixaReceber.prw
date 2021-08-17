#include "totvs.ch"
#include "totvs.ch"
#include "topconn.ch"
#include "dbstruct.ch"

static __aIDProc	as array

/*/{Protheus.doc} TAFBaixaReceber
@author Tiago Rossini Coradini
@since 03/12/2018
@project Automação Financeira
@version 1.0
@description Classe para efetuar baixa automatica de recebimentos
@type class
/*/

Class TAFBaixaReceber From TAFAbstractClass
	
	DATA lErro		as logical

	Method New() Constructor
	Method Process()
	Method Analyze()
	Method Validate(oObj)
	Method VldBankRate(oObj)
	Method VldOfficeExpenses(oObj)
	Method VldBankReceipt(oObj)
	Method Confirm(oObj)
	Method Exist(oObj)
	Method AddBankRate(oObj)
	Method BankReceipt(oObj)
	Method GetDescOc(oObj)
	Method UpdStatus(nID, cStatus, cErro)
	Method GetErrorLog(aError)
	Method AjusteCliSE5(oObj)
	Method ExecBaixaCR(oObj, cMotBx)
	Method ExecMovFin(oObj, nValor, cNat, cHist)

	Method Extend(oObj,cStatus)

EndClass

Method New() Class TAFBaixaReceber

	_Super:New()

	::lErro := .F.

	DEFAULT __aIDProc:=array(0)
	
	aSize(__aIDProc,0)

Return()


Method Process() Class TAFBaixaReceber

	::oPro:Start()

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_BAI_TIT"

	::oLog:Insert()

	::Analyze()

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_BAI_TIT"

	::oLog:Insert()

	::oPro:Finish()

Return()


Method Analyze() Class TAFBaixaReceber
	
	local aArea			as array
	local aFile         as array
	local aFiles 		as array
	local aFields		as array
	local aErroProc		as array

	local bEvalBlock	as block

	local cTo			as character
	local cSQL			as character
	local cCRLF			as character

	local cRetMen		as character

	local cBanco		as character
	local cConta		as character	
	local cAgencia		as character

	local cZK4File		as character
	local cZK4TmpDir	as character
	local cZK4TmpExt	as character
	local cZK4TmpTrim	as character
	local cZK4TmpFile	as character
	
	local cTmpAlias		as character
	local cTmpAliasA	as character
	local cTmpTableA	as character

	local dDtIni		as date

	local lTo			as logical
	local lEof			as logical
	local lBCoIsFIDC	as logical
	local lZK4TmpDir	as logical 
	local lTmpAliasA	as logical
	local lExecBaixaCR	as logical

	local nErro			as numeric
	local nErros		as numeric
	local nAttemps		as numeric

	local nFile			as numeric
	local nSE1RecNo 	as numeric
	local nZK4RecNo		as numeric

	local oFWTTable		as object

	Private lMsErroAuto:=.F.
	Private lMsHelpAuto:=.T.
	Private lAutoErrNoFile:=.T.

	aArea:=getArea()

	aErroProc:=array(0)

    //TODO: Incluir na rotina de Workflow de e-mail BIA191 para recuperação via u_emailWF
    //ex.: u_emailWF("TAFBAIXARECEBERXML",&("cEmpAnt"))
	cTo:=u_emailWF("TAFBAIXARECEBERXML",&("cEmpAnt"))
	lTo:=(!empty(cTo))

	cCRLF:=CRLF

	aFile:=array(5)
	aFill(aFile,array(0))

	aFiles:=array(0)

	aFields:=array(0)
	aAdd(aFields,{"SE1RECNO","N",16,0})
	aAdd(aFields,{"ZK4RECNO","N",16,0})
	aAdd(aFields,{"ERROPROC","N",1,0})
	aAdd(aFields,{"RETMEN","C",100,0})

	cZK4TmpDir:="\zk4\tmp\"
	lZK4TmpDir:=dirtools():MakeDir(cZK4TmpDir)

	dDtIni:=GetNewPar("MV_YULMES", FirstDate(dDatabase))

	cSQL:="SELECT ZK4.R_E_C_N_O_ AS ZK4RECNO"+cCRLF
	cSQL+="  FROM "+RetSQLName("ZK4")+" ZK4"+cCRLF
	cSQL+=" WHERE ZK4.ZK4_FILIAL="+ValToSQL(xFilial("ZK4"))+cCRLF
	cSQL+="   AND ZK4.ZK4_EMP="+ValToSQL(cEmpAnt)+cCRLF
	//TICKET 23719 - comentado para cada empresa processar todas as filiais  (LM SP), os nossos numeros devem ser unicos
	//TICKET 26749 - Descomentado, pois agora a ZK4_FIL esta sendo gravado com a filial correta.
	cSQL+="   AND ZK4.ZK4_FIL="+ValToSQL(cFilAnt)+cCRLF
	cSQL+="   AND ZK4.ZK4_TIPO='R'"+cCRLF
	cSQL+="   AND ZK4.ZK4_DTLIQ BETWEEN "+ValToSQL(dDtIni)+" AND "+ValToSQL(dDatabase)+cCRLF
	cSQL+="   AND ZK4.ZK4_STATUS='1'"+cCRLF // Integrado
	cSQL+="   AND ZK4.D_E_L_E_T_=''"+cCRLF
	cSQL+=" ORDER BY ZK4.ZK4_DATA,ZK4.ZK4_NOSNUM,ZK4.ZK4_CODOCO,ZK4.ZK4_FILE,ZK4.ZK4_IDPROC"+cCRLF

	cTmpAlias:=GetNextAlias()

	TCQUERY (cSQL) ALIAS (cTmpAlias) NEW

	While (cTmpAlias)->(!(lEof:=eof()))

		nZK4RecNo:=(cTmpAlias)->(ZK4RECNO)
		
		ZK4->(MsGoTo(nZK4RecNo))

		cZK4File:=ZK4->ZK4_FILE

		cBanco:=ZK4->ZK4_BANCO
		cConta:=ZK4->ZK4_AGENCI
		cAgencia:=ZK4->ZK4_CONTA

		FIDC():setFIDCVar("cBanco",cBanco)
		FIDC():setFIDCVar("cAgencia",cConta)
		FIDC():setFIDCVar("cConta",cAgencia)
		
		lBCoIsFIDC:=FIDC():BCOIsFIDC()

		cZK4TmpTrim:=allTrim(cZK4File)
		SplitPath(cZK4TmpTrim,/*[ @cDrive]*/,/*[ @cDiretorio]*/,@cZK4TmpFile/* [ @cNome]*/,@cZK4TmpExt/*[ @cExtensao]*/) 
		cZK4TmpFile+=cZK4TmpExt
		cZK4TmpFile:=(cZK4TmpDir+cZK4TmpFile)
		if (lZK4TmpDir)
			if (__CopyFile(cZK4TmpTrim,cZK4TmpFile))
				nFile:=aDir(cZK4TmpFile,@aFile[1],@aFile[2],@aFile[3],@aFile[4],@aFile[5],.T.)
				if (nFile>0)
					aAdd(aFiles,aClone(aFile))
				endif
				fErase(cZK4TmpFile)
			endif
		endif

		nAttemps:=0
		bEvalBlock:={||cTmpAliasA:=getNextAlias(),oFWTTable:=FWTemporaryTable():New(cTmpAliasA,aFields),oFWTTable:Create()}
		while (!evalBlock():evalBlock(bEvalBlock,nil,.F.))
			nAttemps++
			if (nAttemps>10)
				exit
			endif
			sleep(100)
		end while
		lTmpAliasA:=((!empty(cTmpAliasA)).and.(select(cTmpAliasA)>0))

		while (cTmpAlias)->((!(lEof:=eof()).and.(cZK4File==ZK4->ZK4_FILE)))

			lMsErroAuto:=.F.
			lMsHelpAuto:=.T.
			lAutoErrNoFile:=.T.

			begin sequence

				// --If para Não deixar realizar a baixa de tarifa diaria quando for banco do brasil - Ticket 28034
				// As baixas do BB serão realizadas pelo JOB BIAF167
				if ((ZK4->ZK4_BANCO=='001') .AND. (ZK4->ZK4_VLTAR>0))
					break
				endif

				oObj:=TIAFRetornoBancario():New()

				oObj:dData:=ZK4->ZK4_DATA
				oObj:cTipo:=ZK4->ZK4_TIPO
				oObj:cBanco:=ZK4->ZK4_BANCO
				oObj:cAgencia:=ZK4->ZK4_AGENCI
				oObj:cConta:=ZK4->ZK4_CONTA
				oObj:cNosNum:=ZK4->ZK4_NOSNUM
				oObj:nVlOri:=ZK4->ZK4_VLORI
				oObj:nVlRec:=ZK4->ZK4_VLREC
				oObj:nVlDesp:=ZK4->ZK4_VLDESP
				oObj:nVlDesc:=ZK4->ZK4_VLDESC
				oObj:nVlAbat:=ZK4->ZK4_VLABAT
				oObj:nVlJuro:=ZK4->ZK4_VLJURO
				oObj:nVlMult:=ZK4->ZK4_VLMULT
				oObj:nVlTar:=ZK4->ZK4_VLTAR
				oObj:nVlIOF:=ZK4->ZK4_VLIOF
				oObj:nVlOCre:=ZK4->ZK4_VLOCRE
				oObj:dDtLiq:=ZK4->ZK4_DTLIQ
				oObj:dDtCred:=ZK4->ZK4_DTCRED
				oObj:cCodOco:=ZK4->ZK4_CODOCO
				oObj:cStatus:=ZK4->ZK4_STATUS
				oObj:cFile:=ZK4->ZK4_FILE
				oObj:cIDProcAPI:=ZK4->ZK4_IDPROC
				oObj:nID:=nZK4RecNo

				::lErro := .F.

				cacheData():set("ExecBaixaCR","nSE1RecNo",0)

				If (::Validate(oObj).and.((aScan(aErroProc,{|e|(e[1]==oObj:cNosNum)}))==0))

					nSE1RecNo:=SE1->(recNo())

					Begin Transaction

						if ((lBCoIsFIDC).and.(oObj:cCodOco=="14"))
							::Extend(oObj,"F:P")
						else
							::Confirm(oObj)
						endif

						If (::lErro)

							cRetMen:=cacheData():get(oObj:cNosNum,"cRetMen","")

							cacheData():delSection(oObj:cNosNum)
							
							if (empty(cRetMen))
								cRetMen:="Ocorreram Erros/Inconsistencias no Processamento deste item."
							endif

							aAdd(aErroProc,{oObj:cNosNum,nSE1RecNo,nZK4RecNo,cRetMen})

							cRetMen:=""

							if (InTransact())
								DisarmTransaction()
							endif

						elseif ((lTmpAliasA).and.(ZK4->ZK4_STATUS=="2"))

							if (lBCoIsFIDC)
								//Habilitar abaixo para Baixar Tambem ZKC e ZK8
								if (.F.)
									::Extend(oObj,"P:B")
								endif
							endif

							lExecBaixaCR:=(cacheData():get("ExecBaixaCR","nSE1RecNo",0)==nSE1RecNo)
							if (lExecBaixaCR)
								if (cTmpAliasA)->(recLock(cTmpAliasA,.T.))
									(cTmpAliasA)->SE1RECNO:=nSE1RecNo
									(cTmpAliasA)->ZK4RECNO:=nZK4RecNo
									(cTmpAliasA)->ERROPROC:=0
									(cTmpAliasA)->RETMEN:="ExecBaixaCR OK"
									(cTmpAliasA)->(MsUnLock())
								endif
							endif

						EndIf

					End Transaction

				EndIf

			end sequence

			(cTmpAlias)->(DbSkip())

			lEof:=(cTmpAlias)->(eof())

			if (lEof)
				exit
			endif
			
			nZK4RecNo:=(cTmpAlias)->(ZK4RECNO)
			ZK4->(dbGoTo(nZK4RecNo))

		end while

		cacheData():delSection("ExecBaixaCR")

		if (lTmpAliasA)
			nErros:=len(aErroProc)
			for nErro:=1 to nErros
				if (cTmpAliasA)->(recLock(cTmpAliasA,.T.))
					(cTmpAliasA)->SE1RECNO:=aErroProc[nErro][2]
					(cTmpAliasA)->ZK4RECNO:=aErroProc[nErro][3]
					(cTmpAliasA)->ERROPROC:=1
					(cTmpAliasA)->RETMEN:=("Nosso Numero: "+aErroProc[nErro][1]+" :: ["+aErroProc[nErro][4])+"]"
					(cTmpAliasA)->(MsUnLock())
				endif
			next nErro
		endif

		aSize(aErroProc,0)

		if (lTmpAliasA)
			cTmpTableA:=oFWTTable:getRealName()
			bEvalBlock:={||addWFProc(@cTmpTableA,@cZK4TmpTrim)}
			evalBlock():evalBlock(bEvalBlock,nil,.F.)
		endif

		::oPro:Finish()
		::oPro:Start()

		if ((lTo).and.(lTmpAliasA))

			bEvalBlock:={||AnalyzeToExcelFile(@cZK4TmpTrim,@cTmpTableA,@lBCoIsFIDC)}
			evalBlock():evalBlock(bEvalBlock,nil,.F.)

		endif

		oFWTTable:Delete()

	EndDo

	(cTmpAlias)->(dbCloseArea())

	if ((lTo).and.(lZK4TmpDir).and.(!empty(aFiles)))
		if (len(aFiles)>0)
			bEvalBlock:={||read2Excel(@aFiles)}
			evalBlock():evalBlock(bEvalBlock,nil,.F.)
		endif
	endif

	restArea(aArea)

Return()

static function addWFProc(cTmpTableA as character,cZK4File as character) as logical

    local aArea			as array
	local aFields       as array

    local cSQLPath      as character
    local cSQLFile      as character
    local cSQLQuery     as character
    local cSQLInsert    as character

    local cTmpAlias     as character
    local cTmpTable     as character
	local cTableTmp		as character

	local cFil			as character
	local cIDProc		as character
	local cTabela		as character
	local cMetodo		as character

    local cField        as character
	local cRetMen		as character
	local cSQLFields	as character
	local cGBYFields	as character

	local cZK4FileExt	as character
	local cZK4FileFile	as character

	local lRet			as logical

	local nIDTab		as numeric

    local nField        as numeric
    local nFields       as numeric

	local oSuperWFP		as object
	local oFWTTable		as object

	aArea:=getArea()

	SplitPath(cZK4File,/*[ @cDrive]*/,/*[ @cDiretorio]*/,@cZK4FileFile/* [ @cNome]*/,@cZK4FileExt/*[ @cExtensao]*/) 

	cZK4File:=cZK4FileFile
	cZK4File+=cZK4FileExt

	begin sequence

		cSQLFields:=""
		cSQLFields+="ZK4.ZK4_FILIAL"
		cSQLFields+=",ZK4.ZK4_DATA"
		cSQLFields+=",ZK4.ZK4_EMP"
		cSQLFields+=",ZK4.ZK4_FIL"
		cSQLFields+=",ZK4.ZK4_BANCO"
		cSQLFields+=",ZK4.ZK4_AGENCI"
		cSQLFields+=",ZK4.ZK4_CONTA"
		cSQLFields+=",SUM(ZK4.ZK4_VLORI) ZK4_VLORI"
		cSQLFields+=",SUM(ZK4.ZK4_VLREC) ZK4_VLREC"
		cSQLFields+=",COUNT(1) QUANTIDADE"
		cSQLFields+=",ZK4.ZK4_FILE"
		cSQLFields+=",ZK4.ZK4_IDPROC"
		cSQLFields+=",tmp.ERROPROC"
		cSQLFields+=",tmp.RETMEN"

		cSQLFields:=("%"+cSQLFields+"%")
		
		cGBYFields:=cSQLFields
		cGBYFields:=strTran(cGBYFields,",SUM(ZK4.ZK4_VLORI) ZK4_VLORI","")
		cGBYFields:=strTran(cGBYFields,",SUM(ZK4.ZK4_VLREC) ZK4_VLREC","")
		cGBYFields:=strTran(cGBYFields,",COUNT(1) QUANTIDADE","")

		cTableTmp:=("%"+cTmpTableA+"%")

		cTmpAlias:=getNextAlias()
		beginSQL alias cTmpAlias

			%noparser%

			COLUMN ZK4_DATA  AS DATE

			SELECT %exp:cSQLFields%
			  FROM %table:SE1% SE1 (NOLOCK)
			  JOIN %exp:cTableTmp% tmp (NOLOCK)
			    ON (SE1.R_E_C_N_O_=tmp.SE1RECNO)
			  JOIN %table:ZK4% ZK4 (NOLOCK)
			    ON (ZK4.R_E_C_N_O_=tmp.ZK4RECNO)
			 WHERE (1=2)
			   AND SE1.%notDel%
			   AND ZK4.%notDel%
		  GROUP BY %exp:cGBYFields%
		ORDER BY %exp:cGBYFields%

		endSQL    

		if (IsBlind())
			cSQLPath:="\tmp\"
		else
			cSQLPath:=getTempPath()
			if (!right(cSQLPath,1)=="\")
				cSQLPath+="\"
			endif
		endif
		cSQLPath+="TAFBaixaReceber\SQL\"

		cSQLQuery:=getLastQuery()[2]
		cSQLQuery:=strTran(cSQLQuery,"(1=2)","(1=1)")
		
		cSQLFile:=""
		A35():writeSQLFile(@cSQLQuery,&("cEmpAnt"),&("cFilAnt"),"TAFBAIXARECEBER","00","qry_final",@cSQLPath,@cSQLFile)

		aFields:=(cTmpAlias)->(dbStruct())
		nFields:=len(aFields)

		(cTmpAlias)->(dbCloseArea())

		oFWTTable:=FWTemporaryTable():New(cTmpAlias,aFields)
		oFWTTable:Create()

		cTmpTable:=oFWTTable:getRealName()
		
		cSQLInsert:="INSERT INTO"
		cSQLInsert+=" "
		cSQLInsert+=cTmpTable
		cSQLInsert+=" "
		cSQLInsert+="("
		for nField:=1 to nFields
			cField:=aFields[nField][DBS_NAME]
			cSQLInsert+=cField
			cSQLInsert+=","
		next nField
		cSQLInsert:=subStr(cSQLInsert,1,(Len(cSQLInsert)-1))
		cSQLInsert+=")"
		cSQLInsert+=" "
		cSQLInsert+=cSQLQuery

		begin transaction
			if (TCSQLExec(cSQLInsert)<0)
				if (InTransact())
					DisarmTransaction()
				endif
				FWLogMsg("WARNIG",NIL,"TAFBaixaReceber","ERROR","1","4",TCSQlError(),1,0,{})
			endif
		end transaction

		(cTmpAlias)->(dbGoTop())		

		oSuperWFP:=TAFAbstractClass():New()
		oSuperWFP:oPro:Start()

		cIDProc:=oSuperWFP:oPro:cIDProc
		while (aScan(__aIDProc,{|cID|(cID==cIDProc)})>0)
			cIDProc:=__Soma1(cIDProc)
		end while
		aAdd(__aIDProc,cIDProc)
		oSuperWFP:oPro:cIDProc:=cIDProc

		oSuperWFP:oLog:cIDProc:=cIDProc
		oSuperWFP:oLog:cOperac:="R"
		oSuperWFP:oLog:cMetodo:="I_BAI_TIT"

		oSuperWFP:oLog:Insert()

		cFil:=oSuperWFP:oLog:cFil
		cTabela:=retSQLName("ZK4")
		cMetodo:="CR_BAI_TIT"

		while (cTmpAlias)->(!eof())

			nIDTab:=(cTmpAlias)->(recNo())

			oSuperWFP:oLog:cIDProc:=cIDProc
			oSuperWFP:oLog:cTabela:=cTabela
			oSuperWFP:oLog:nIDTab:=nIDTab
			oSuperWFP:oLog:cHrFin:=Time()
			cRetMen:=(cTmpAlias)->RETMEN
			if (empty(cRetMen))
				oSuperWFP:oLog:cRetMen:="Título(s) baixado(s) arquivo ["+cZK4File+"]"
			else
				oSuperWFP:oLog:cRetMen:=cRetMen
			endif
			oSuperWFP:oLog:cMetodo:=cMetodo
			oSuperWFP:oLog:cOperac:="R"
			oSuperWFP:oLog:cEnvWF:="S"

			oSuperWFP:oPro:oWFP:setTable(cTmpTable,cTabela,cMetodo,cFil,cIDProc)

			oSuperWFP:oLog:Insert()

			(cTmpAlias)->(dbSkip())

		end while

		oSuperWFP:oLog:cIDProc:=cIDProc
		oSuperWFP:oLog:cOperac:="R"
		oSuperWFP:oLog:cMetodo:="F_BAI_TIT"

		oSuperWFP:oLog:Insert()

		oSuperWFP:oPro:oWFP:bSX2Alias:={||"ZK4"}
		oSuperWFP:oPro:oWFP:bFieldFil:={||"ZK4_FILIAL"}
		oSuperWFP:oPro:oWFP:bSetField:={|cTab,cFil,cID|WFPSetField(@oSuperWFP,@aFields,@cTab,@cFil,@cID)}
		
		oSuperWFP:oPro:Finish()

	end sequence

	oSuperWFP:oPro:oWFP:oLst:Clear()

	if (valType(oFWTTable)=="O")
		oFWTTable:Delete()
	endif

	restArea(aArea)

    return(lRet)

static function WFPSetField(oSuperWFP as object,aFields as array,cTab as character,cFil as character,cID as character) as logical

	local aFieldD	as caracter
	
	local cType		as character
	local cField	as character
	local cFieldD	as character
	local cFieldP	as character

	local lUsrField	as logical

	local nLen		as numeric
	local nDec		as numeric
	local nWidth	as numeric
	local nField	as numeric
	local nFields	as numeric
	local nFieldD	as numeric

	DEFAULT aFields:=array(0)
	DEFAULT cTab:=cTab
	DEFAULT cFil:=cFil
	DEFAULT cID:=cID

	oSuperWFP:oPro:oWFP:oLst:Clear()

	aFieldD:=array(0)
	aAdd(aFieldD,{"QUANTIDADE","Qtde.Proc.","999999",.F.})
    aAdd(aFieldD,{"ERROPROC","Erro Proc.","9",.F.})
	aAdd(aFieldD,{"RETMEN","Mensagem","@!",.T.})

	nFields:=len(aFields)
	for nField:=1 to nFields
		cField:=aFields[nField][DBS_NAME]
		if ("ZK4_FILIAL"$cField)
			loop
		endif
		if (empty(getSX3Cache(cField,"X3_TIPO")))
			nLen:=aFields[nField][DBS_LEN]
			nDec:=aFields[nField][DBS_DEC]
			cType:=aFields[nField][DBS_TYPE]
			nFieldD:=aScan(aFieldD,{|e|(e[1]==cField)})
			if (nFieldD>0)
				cFieldD:=aFieldD[nFieldD][2]
				cFieldP:=aFieldD[nFieldD][3]
				lUsrField:=aFieldD[nFieldD][4]
			else
				cFieldD:=cField
				cFieldP:=""
				lUsrField:=.T.
			endif
			nWidth:=CalcFieldSize(cType,nLen,nDec,cFieldP,cFieldD)
			oSuperWFP:oPro:oWFP:AddUserField(cField,cFieldD,cType,cFieldP,nWidth,lUsrField)
		else
			oSuperWFP:oPro:oWFP:AddField(cField)
		endif
	next nField

	return(nFields>0)

static function AnalyzeToExcelFile(cZK4File as character,cTmpTableA as character,lBCoIsFIDC as logical) as logical

    local aArea			as array
	local aFields       as array

	local cTo			as character

	local cBody     	as character
    local cSubject  	as character
	local cFWLogMsg 	as character

    local cSQLPath      as character
    local cSQLFile      as character
    local cSQLQuery     as character
    local cSQLInsert    as character

    local cTmpAlias     as character
    local cTmpTable     as character
	local cTableTmp		as character

	local cZK4FileExt 	as character
	local cZK4FileFile 	as character

	local cExcelFile	as character
	local cExcelTitle	as character

    local cField        as character
	local cSQLFields	as character

	local lRet			as logical

	local lPicture		as logical
	local lX3Titulo		as logical
	local ltxtEditMemo	as logical		

    local nField        as numeric
    local nFields       as numeric

	local oFWTTable		as object

	aArea:=getArea()

	begin sequence

		cSQLFields:=""
		cSQLFields+="SA1.A1_COD"
		cSQLFields+=",SA1.A1_NOME"
		cSQLFields+=",SE1.E1_DATABOR"
		cSQLFields+=",SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_PARCELA AS P_NUM_PARC"
		cSQLFields+=",SE1.E1_EMISSAO"
		cSQLFields+=",SE1.E1_VENCTO"
		if (lBCoIsFIDC)
			cSQLFields+=",0  AS DIAS_ANTEC"
			cSQLFields+=",'' AS E1_VENCREA"
		endif
		cSQLFields+=",SE1.E1_VALOR"
		cSQLFields+=",ZK4.ZK4_VLORI"
		cSQLFields+=",ZK4.ZK4_VLREC"
		if (lBCoIsFIDC)
			cSQLFields+=",SE1.E1_YFDCVAL"
		endif
		cSQLFields+=",LTRIM(RTRIM(ZK4.ZK4_NOSNUM)) AS ZK4_NOSNUM"
		cSQLFields+=",tmp.ERROPROC"
		cSQLFields+=",tmp.RETMEN"

		cSQLFields:=("%"+cSQLFields+"%")

		cTableTmp:=("%"+cTmpTableA+"%")

		cTmpAlias:=getNextAlias()
		beginSQL alias cTmpAlias

			%noparser%

			COLUMN E1_DATABOR  AS DATE
			COLUMN E1_EMISSAO  AS DATE
			COLUMN E1_VENCTO   AS DATE
			COLUMN E1_VENCREA  AS DATE
			COLUMN ZK4_DATA    AS DATE

			SELECT %exp:cSQLFields%
			  FROM %table:SE1% SE1 (NOLOCK)
			  JOIN %exp:cTableTmp% tmp (NOLOCK)
			    ON (SE1.R_E_C_N_O_=tmp.SE1RECNO)
			  JOIN %table:ZK4% ZK4 (NOLOCK)
			    ON (ZK4.R_E_C_N_O_=tmp.ZK4RECNO)
			  JOIN %table:SA1% SA1 (NOLOCK) ON (
					SA1.%notDel%
				AND SA1.A1_FILIAL=%xFilial:SA1%
				AND SE1.E1_CLIENTE=SA1.A1_COD
				AND SE1.E1_LOJA=SA1.A1_LOJA
			)
			WHERE (1=2)
			  AND SE1.%notDel%
			  AND SA1.%notDel%
			  AND ZK4.%notDel%
			  AND SE1.E1_FILIAL=%xFilial:SE1%
			  AND ZK4.ZK4_FILIAL=%xFilial:ZK4%
			  AND SA1.A1_FILIAL=%xFilial:SA1%
			  AND SE1.E1_CLIENTE=SA1.A1_COD
			  AND SE1.E1_LOJA=SA1.A1_LOJA
		ORDER BY SE1.E1_FILIAL
				,SE1.E1_DATABOR
				,SA1.A1_FILIAL
				,SA1.A1_COD
				,SE1.E1_PREFIXO
				,SE1.E1_NUM
				,SE1.E1_PARCELA

		endSQL    

		if (IsBlind())
			cSQLPath:="\tmp\"
		else
			cSQLPath:=getTempPath()
			if (!right(cSQLPath,1)=="\")
				cSQLPath+="\"
			endif
		endif
		cSQLPath+="TAFBaixaReceber\SQL\"

		cSQLQuery:=getLastQuery()[2]
		cSQLQuery:=strTran(cSQLQuery,"(1=2)","(1=1)")
		
		cSQLFile:=""
		A35():writeSQLFile(@cSQLQuery,&("cEmpAnt"),&("cFilAnt"),"TAFBAIXARECEBER","00","qry_final",@cSQLPath,@cSQLFile)

		aFields:=(cTmpAlias)->(dbStruct())
		nFields:=len(aFields)

		(cTmpAlias)->(dbCloseArea())

		oFWTTable:=FWTemporaryTable():New(cTmpAlias,aFields)
		oFWTTable:Create()

		cTmpTable:=oFWTTable:getRealName()
		
		cSQLInsert:="INSERT INTO"
		cSQLInsert+=" "
		cSQLInsert+=cTmpTable
		cSQLInsert+=" "
		cSQLInsert+="("
		for nField:=1 to nFields
			cField:=aFields[nField][DBS_NAME]
			cSQLInsert+=cField
			cSQLInsert+=","
		next nField
		cSQLInsert:=subStr(cSQLInsert,1,(Len(cSQLInsert)-1))
		cSQLInsert+=")"
		cSQLInsert+=" "
		cSQLInsert+=cSQLQuery

		begin transaction
			if (TCSQLExec(cSQLInsert)<0)
				if (InTransact())
					DisarmTransaction()
				endif
				FWLogMsg("WARNIG",NIL,"TAFBaixaReceber","ERROR","1","4",TCSQlError(),1,0,{})
			endif
		end transaction

		(cTmpAlias)->(dbGoTop())

		if (lBCoIsFIDC)
			while ((cTmpAlias)->(!eof()))
				if (cTmpAlias)->(recLock(cTmpAlias,.F.))
					(cTmpAlias)->(FIDC():calculaDesconto(E1_VALOR,E1_VENCTO,E1_DATABOR))
					(cTmpAlias)->(DIAS_ANTEC:=FIDC():getFIDCVar("nDiasCalculo",0))
					(cTmpAlias)->(E1_VENCREA:=FIDC():getFIDCVar("dDataValida",E1_DATABOR))
					(cTmpAlias)->(MsUnLock())
				endif
				(cTmpAlias)->(dbSkip())
			end while
			(cTmpAlias)->(dbGoTop())
		endif

		utoXML():setSX3Fields((cTmpAlias)->(dbStruct()))

		uToXML():setXMLVar("A1_COD","X3_TITULO","CODIGO")
		uToXML():setXMLVar("A1_NOME","X3_TITULO","RAZAO SOCIAL")
		uToXML():setXMLVar("E1_DATABOR","X3_TITULO","DATA REMESSA")
		uToXML():setXMLVar("P_NUM_PARC","X3_TITULO","PREFIXO+NUMERO+PARCELA")
		uToXML():setXMLVar("E1_EMISSAO","X3_TITULO","EMISSAO")
		uToXML():setXMLVar("E1_VENCTO","X3_TITULO","VENCIMENTO")
		uToXML():setXMLVar("DIAS_ANTEC","X3_TITULO","DIAS ANTECIPADOS")
		uToXML():setXMLVar("E1_VENCREA","X3_TITULO","VENC.AJUSTADO")
		uToXML():setXMLVar("E1_VALOR","X3_TITULO","VALOR")
		uToXML():setXMLVar("ZK4_VLORI","X3_TITULO","VALOR ORIGINAL")
		uToXML():setXMLVar("ZK4_VLREC","X3_TITULO","VALOR RECEBIDO")
		uToXML():setXMLVar("E1_YFDCVAL","X3_TITULO","DESAGIO")
		uToXML():setXMLVar("ZK4_NOSNUM","X3_TITULO","NOSSO NUMERO")
		uToXML():setXMLVar("ERROPROC","X3_TITULO","ERRO PROC.")
		uToXML():setXMLVar("RETMEN","X3_TITULO","MSG PROC.")

		uToXML():setXMLVar("A1_COD","X3_PICTURE","@!")
		uToXML():setXMLVar("A1_NOME","X3_PICTURE","@!")
		uToXML():setXMLVar("E1_DATABOR","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("P_NUM_PARC","X3_PICTURE","@!")
		uToXML():setXMLVar("E1_EMISSAO","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("E1_VENCTO","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("DIAS_ANTEC","X3_PICTURE","@R 9999")
		uToXML():setXMLVar("E1_VENCREA","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("E1_VALOR","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("ZK4_VLORI","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("ZK4_VLREC","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("E1_YFDCVAL","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("ERROPROC","X3_PICTURE","__NOTRANSFORM__")

		uToXML():setXMLVar("E1_VALOR","TOTAL",.T.)
		uToXML():setXMLVar("ZK4_VLORI","TOTAL",.T.)
		uToXML():setXMLVar("ZK4_VLREC","TOTAL",.T.)
		uToXML():setXMLVar("E1_YFDCVAL","TOTAL",.T.)

		lPicture:=.T.
		lX3Titulo:=.T.
		ltxtEditMemo:=.F.

		SplitPath(cZK4File,/*[ @cDrive]*/,/*[ @cDiretorio]*/,@cZK4FileFile/* [ @cNome]*/,@cZK4FileExt/*[ @cExtensao]*/) 

		cZK4File:=cZK4FileFile
		cZK4File+=cZK4FileExt

		cExcelTitle:="TAFBaixaReceber"
		cExcelTitle+=" :: "
		cExcelTitle+=cZK4File
		cExcelTitle+=" :: "
		cExcelTitle+="Empresa: "+&("cEmpAnt")
		cExcelTitle+=" :: "
		cExcelTitle+="Filial: "+&("cFilAnt")
		cExcelTitle+=" :: "
		cExcelTitle+="Data: "+DToC(Date())
		cExcelTitle+=" :: "
		cExcelTitle+="Hora: "+Time()

		cExcelFile:="\TAFBaixaReceber\"
		cExcelFile+="TAFBaixaReceber"
		cExcelFile+="_"
		cExcelFile+=DtoS(Date())
		cExcelFile+="_"
		cExcelFile+=StrTran(Time(),":","_")
		cExcelFile+="_"
		cExcelFile+=cValtoChar(Seconds())
		cExcelFile+=".xml"

		dirtools():MakeFileDir(cExcelFile)

		uToXML():setXMLVar("GENERAL","lIsBlind",.T.)

		lRet:=uToXML():QryToXML(@cTmpAlias,@cExcelFile,@cExcelTitle,@lPicture,@lX3Titulo,@ltxtEditMemo)

		uToXML():clearXMLVar()

		if (!lRet)
			break
		endif
		
		lRet:=file(cExcelFile)

		//TODO: Incluir na rotina de Workflow de e-mail BIA191 para recuperação via u_emailWF
		//ex.: u_emailWF("TAFBAIXARECEBERXML",&("cEmpAnt"))
		cTo:=u_emailWF("TAFBAIXARECEBERXML",&("cEmpAnt"))

		if (empty(cTo))
			break
		endif

		if (!lRet)
			break
		endif

		cSubject:="TAFBaixaReceber :: "
		cSubject+="Processamento Retorno "
		cSubject+=" :: Emissao: "
		cSubject+=DtoC(msDate())
		cSubject+=" :: "+Time()
		cSubject+=" :: Arquivo: ["+cZK4File+"]"
		
		cBody:="Segue, anexo, arquivo referente ao processamento automatico dos recebimentos referentes a:"
		cBody+=" "
		cBody+=cSubject

		cFWLogMsg:="TAFBaixaReceber Enviando e-mail para: "
		cFWLogMsg+=cTo
		FWLogMsg("MSG",NIL,"TAFBaixaReceber","INFO","1","1",cFWLogMsg,1,0,{})
		cFWLogMsg:=cSubject
		FWLogMsg("MSG",NIL,"TAFBaixaReceber","INFO","1","2",cFWLogMsg,1,0,{})
		lRet:=u_BIAEnvMail(nil,cTo,cSubject,cBody,nil,cExcelFile)
		if (lRet)
			if (file(cExcelFile))
				fErase(cExcelFile)
			endif
			cFWLogMsg:="TAFBaixaReceber e-mail enviado com sucesso para: "
			cFWLogMsg+=cTo
			FWLogMsg("MSG",NIL,"TAFBaixaReceber","INFO","1","3",cFWLogMsg,1,0,{})
		else
			cFWLogMsg:="TAFBaixaReceber problemas no envio de e-mail para: "
			cFWLogMsg+=cTo
			FWLogMsg("WARNIG",NIL,"TAFBaixaReceber","ERROR","1","4",cFWLogMsg,1,0,{})
		endif

	end sequence

	if (valType(oFWTTable)=="O")
		oFWTTable:Delete()
	endif

	restArea(aArea)

    return(lRet)

static function read2Excel(aFiles as array) as logical

	local aArea			as array
	local aFields		as array
	
	local cTo			as character	
	local cBody     	as character
	local cSubject  	as character
	local cFWLogMsg 	as character

	local cASQLite		as character
	local cTSQLite		as character

	local cExcelFile	as character
	local cExcelTitle	as character

	local lRet			as logical

	local lPicture		as logical
	local lX3Titulo		as logical
	local ltxtEditMemo  as logical

	local nFile			as numeric
	local nFiles		as numeric

	aArea:=getArea()

	begin sequence

		aFields:=array(0)
		
		aAdd(aFields,{"FILE_NAME","C",254,0})
		aAdd(aFields,{"FILE_SIZE","N",16,9})
		aAdd(aFields,{"FILE_DATE","D",8,0})
		aAdd(aFields,{"FILE_TIME","C",8,0}) 

		cTSQLite:=criaTrab(nil,.F.)
		dbCreate(cTSQLite,aFields,"SQLITE_MEM")
		cASQLite:=getNextAlias()
		dbUseArea(.T.,"SQLITE_MEM",cTSQLite,cASQLite,.F.,.F.)

		nFiles:=Len(aFiles)
		for nFile:=1 to nFiles 
			if (cASQLite)->(recLock(cASQLite,.T.))
				(cASQLite)->FILE_NAME:=aFiles[nFile][1][1]
				(cASQLite)->FILE_SIZE:=aFiles[nFile][2][1]
				(cASQLite)->FILE_DATE:=aFiles[nFile][3][1]
				(cASQLite)->FILE_TIME:=aFiles[nFile][4][1]
				(cASQLite)->(msUnLock())
			endif
		next nFile

		uToXML():setXMLVar("FILE_NAME","X3_TITULO","ARQUIVO")
		uToXML():setXMLVar("FILE_SIZE","X3_TITULO","TAMANHO")
		uToXML():setXMLVar("FILE_DATE","X3_TITULO","DATA")
		uToXML():setXMLVar("FILE_TIME","X3_TITULO","HORA")

		uToXML():setXMLVar("FILE_NAME","X3_PICTURE","@!")
		uToXML():setXMLVar("FILE_SIZE","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("FILE_DATE","X3_PICTURE","__NOTRANSFORM__")
		uToXML():setXMLVar("FILE_TIME","X3_PICTURE","@!")

		cExcelTitle:="TAFBaixaReceber"
		cExcelTitle+=" :: "
		cExcelTitle+="Arquivos"
		cExcelTitle+=" :: "
		cExcelTitle+="Empresa: "+&("cEmpAnt")
		cExcelTitle+=" :: "
		cExcelTitle+="Filial: "+&("cFilAnt")
		cExcelTitle+=" :: "
		cExcelTitle+="Data: "+DToC(Date())
		cExcelTitle+=" :: "
		cExcelTitle+="Hora: "+Time()

		cExcelFile:="\TAFBaixaReceber\"
		cExcelFile+="TAFBaixaReceber"
		cExcelFile+="_"
		cExcelFile+=DtoS(Date())
		cExcelFile+="_"
		cExcelFile+=StrTran(Time(),":","_")
		cExcelFile+="_"
		cExcelFile+=cValtoChar(Seconds())
		cExcelFile+=".xml"

		dirtools():MakeFileDir(cExcelFile)

		lPicture:=.T.
		lX3Titulo:=.T.
		ltxtEditMemo:=.F.

		(cASQLite)->(dbGoTop())

		lRet:=uToXML():QryToXML(@cASQLite,@cExcelFile,@cExcelTitle,@lPicture,@lX3Titulo,@ltxtEditMemo)

		(cASQLite)->(dbCloseArea())

		uToXML():clearXMLVar()

		lRet:=file(cExcelFile)

		//TODO: Incluir na rotina de Workflow de e-mail BIA191 para recuperação via u_emailWF
		//ex.: u_emailWF("TAFBAIXARECEBERXML",&("cEmpAnt"))
		cTo:=u_emailWF("TAFBAIXARECEBERXML",&("cEmpAnt"))
		
		if (empty(cTo))
			break
		endif

		if (!lRet)
			break
		endif

		cSubject:="TAFBaixaReceber :: "
		cSubject+="Processamento Retorno "
		cSubject+=" :: Emissao: "
		cSubject+=DtoC(msDate())
		cSubject+=" :: "+Time()
		cSubject+=" :: Arquivos Processados"
		
		cBody:="Segue, anexo, dados dos arquivos processados:"
		cBody+=" "
		cBody+=cSubject

		cFWLogMsg:="TAFBaixaReceber Enviando e-mail para: "
		cFWLogMsg+=cTo
		FWLogMsg("MSG",NIL,"TAFBaixaReceber","INFO","1","1",cFWLogMsg,1,0,{})
		cFWLogMsg:=cSubject
		FWLogMsg("MSG",NIL,"TAFBaixaReceber","INFO","1","2",cFWLogMsg,1,0,{})
		lRet:=u_BIAEnvMail(nil,cTo,cSubject,cBody,nil,cExcelFile)
		if (lRet)
			if (file(cExcelFile))
				fErase(cExcelFile)
			endif
			cFWLogMsg:="TAFBaixaReceber e-mail enviado com sucesso para: "
			cFWLogMsg+=cTo
			FWLogMsg("MSG",NIL,"TAFBaixaReceber","INFO","1","3",cFWLogMsg,1,0,{})
		else
			cFWLogMsg:="TAFBaixaReceber problemas no envio de e-mail para: "
			cFWLogMsg+=cTo
			FWLogMsg("WARNIG",NIL,"TAFBaixaReceber","ERROR","1","4",cFWLogMsg,1,0,{})
		endif

	end sequence

	restArea(aArea)

	DEFAULT lRet:=.F.

	return(lRet)

Method Validate(oObj) Class TAFBaixaReceber
	
	Local lRet := .F.

	If ::Exist(oObj)

		If ::VldBankRate(oObj)

			lRet := .T.

		ElseIf ::VldOfficeExpenses(oObj)

			lRet := .T.

		ElseIf ::VldBankReceipt(oObj)

			lRet := .T.

		Else

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := ::GetDescOc(oObj)
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_BAI_TIT"
			::oLog:cEnvWF := "S"

			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

			::oLog:Insert()

		EndIf

	EndIf

Return(lRet)


Method VldBankRate(oObj) Class TAFBaixaReceber
	Local lRet := .F.

	If oObj:cBanco == "001"

		// 02=ENTRADA CONFIRMADA

		If oObj:cCodOco == "02"

			lRet := .T.

		EndIf

	ElseIf oObj:cBanco == "237"

		// 02=ENTRADA CONFIRMADA

		If oObj:cCodOco == "02"

			lRet := .T.

		EndIf
	ElseIf oObj:cBanco == "021"

		// 02=ENTRADA CONFIRMADA

		If oObj:cCodOco == "02"

			lRet := .T.

		EndIf

	EndIf

Return(lRet)


Method VldOfficeExpenses(oObj) Class TAFBaixaReceber
	Local lRet := .F.

	If oObj:cBanco == "001"

		// 23=TITULO ENCAMINHADO AO CARTORIO
		// 96=DESPESA DE PROTESTO
		// 98=DEBITO DE CUSTAS ANTECIPADAS
		// 28=TITULO DESPESAS CARTORIO

		If oObj:cCodOco $ "23/96/98/28"

			lRet := .T.

		EndIf

	ElseIf oObj:cBanco == "237"

		// 28=DEBITO TARIFAS/CUSTAS

		If oObj:cCodOco == "28"

			lRet := .T.

		EndIf

	ElseIf oObj:cBanco == "021"

		// 28=DEBITO TARIFAS/CUSTAS

		If oObj:cCodOco == "23/28"

			lRet := .T.

		EndIf

	EndIf

Return(lRet)


Method VldBankReceipt(oObj) Class TAFBaixaReceber
	
	Local lRet := .F.

	If oObj:cBanco == "001"

		// 05=LIQUIDACAO SEM REGISTRO
		// 06=LIQUIDACAO NORMA
		// 08=LIQUIDACAO POR SALDO
		// 15=LIQUIDACAO EM CARTORIO

		If oObj:cCodOco $ "05/06/08/15"

			lRet := .T.

		EndIf

	ElseIf oObj:cBanco == "237"

		// 06=LIQUIDACAO NORMAL
		// 14=VENCIMENTO ALTERADO
		// 15=LIQUIDACAO EM CARTORIO

		If oObj:cCodOco $ "06/14/15"

			lRet := .T.

		EndIf
	ElseIf oObj:cBanco == "021"

		// 06=LIQUIDACAO NORMAL
		// 15=LIQUIDACAO EM CARTORIO

		If oObj:cCodOco $ "06/15"

			lRet := .T.

		EndIf

	EndIf

Return(lRet)


Method Exist(oObj) Class TAFBaixaReceber
	
	static oFWPSExist

	Local lRet := .T.

	Local nSE1RecNo
	
	Local cSQL
	Local cQry

	if (!valType(oFWPSExist)=="O")

		beginContent var cSQL
			SELECT TOP 1 SE1.E1_SALDO
						,SE1.R_E_C_N_O_ AS SE1RECNO
						,SE1.E1_YTXCOBR
			FROM [?] SE1
		   WHERE SE1.E1_FILIAL<>'  '
			 AND (
					(
						SE1.E1_NUMBCO=? OR (SE1.E1_NUMBCO=LEFT(?,LEN(?)-1))
				    	OR 
				    	(SE1.E1_YNUMBCO=? AND SUBSTRING(SE1.E1_PREFIXO,1,2) IN ('PR','CT'))
			 		)
			 )		
			 AND SE1.D_E_L_E_T_=' '
		   ORDER BY SE1RECNO DESC
		endContent

		oFWPSExist:=FWPreparedStatement():New(cSQL)

	endif

    oFWPSExist:setString(1,retSQLName("SE1"))
    
    oFWPSExist:setString(2,oObj:cNosNum)
	oFWPSExist:setString(3,oObj:cNosNum)
	oFWPSExist:setString(4,oObj:cNosNum)
	oFWPSExist:setString(5,oObj:cNosNum)

    cSQL:=oFWPSExist:GetFixQuery()
    
    cSQL:=strTran(cSQL,"['","[")
    cSQL:=strTran(cSQL,"']","]")

	cQry:=MpSysOpenQuery(cSQL)

	nSE1RecNo:=(cQry)->SE1RECNO
	
	If (lRet:=(nSE1RecNo>0))

		SE1->(MsGoTo(nSE1RecNo))

		// Caso o valor recebido seja maior que o saldo do titulo, envia workflow para analise
		If (cQry)->E1_SALDO > 0 .And. (oObj:nVlRec > Round((cQry)->E1_SALDO + (cQry)->E1_YTXCOBR, 2) .And. oObj:nVlJuro == 0 .And. oObj:nVlOCre == 0);
		 		.Or. (oObj:nVlRec - oObj:nVlJuro > Round((cQry)->E1_SALDO + (cQry)->E1_YTXCOBR, 2))

			lRet := .F.

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Valor Recebido MAIOR que o SALDO do titulo"
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_BAI_TIT"
			::oLog:cEnvWF := "S"

			::oLog:Insert()

			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

		ElseIf (lRet := (cQry)->E1_SALDO > 0)

			DbSelectArea("SE1")
			SE1->(MsGoTo(nSE1RecNo))

		ElseIf (lRet := ::VldOfficeExpenses(oObj))

			DbSelectArea("SE1")
			SE1->(MsGoTo(nSE1RecNo))

			//TICKET 23719 - apenas registro de tarifa de cobranca que ficaram pendentes
		ElseIf (lRet := (::VldBankRate(oObj) .And. oObj:nVlTar > 0 .And. oObj:nVlRec == 0))

			DbSelectArea("SE1")
			SE1->(MsGoTo(nSE1RecNo))

		Else

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "Título baixado anteriormente"
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_BAI_TIT"
			::oLog:cEnvWF := "S"

			::oLog:Insert()

			::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

		EndIf

	Else

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID
		::oLog:cHrFin := Time()
		::oLog:cRetMen := "Titulo nao encontrado"
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_BAI_TIT"
		::oLog:cEnvWF := "S"

		::oLog:Insert()

		::UpdStatus(oObj:nID, "2", ::oLog:cRetMen)

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)


Method Confirm(oObj) Class TAFBaixaReceber

	local dAuxAux := &("dDataBase")

	&("dDataBase"):=if(empty(oObj:dDtCred),oObj:dDtLiq,oObj:dDtCred)

	::AddBankRate(oObj)

	::BankReceipt(oObj)

	&("dDataBase"):=dAuxAux

Return()


Method AddBankRate(oObj) Class TAFBaixaReceber
	Local cNat := ""
	Local cHist := ""
	Local nValor := 0

	If ::VldBankRate(oObj)

		cNat := "2915"
		cHist := "TAR. ENVIO COBRANCA " + Alltrim(SE1->E1_NUM) + Space(1) + Alltrim(SE1->E1_PARCELA)
		nValor := oObj:nVlTar

	ElseIf ::VldOfficeExpenses(oObj)

		cNat := "2938"
		cHist := "DESP. CART. COBRANCA " + Alltrim(SE1->E1_NUM) + Space(1) + Alltrim(SE1->E1_PARCELA)
		nValor := oObj:nVlTar + oObj:nVlDesp

	EndIf

	If !Empty(cNat) .And. !Empty(cHist) .And. nValor > 0

		::ExecMovFin(oObj, nValor, cNat, cHist)

	Else

		::UpdStatus(oObj:nID, "2")

	EndIf

Return()


Method BankReceipt(oObj) Class TAFBaixaReceber
	
	Local aVar
	Local oRecAnt
	Local lRA := .F.
	Local cMotBx := "NOR"
	Local nAuxTxCart := 0
	Local nAuxVlRec := 0
	Local nAuxTarGnr := 0
	Local nAuxTxCob := 0
	Local lRet := .T.

	Local dsvDataBase:=&("dDataBase")

	If ( (::VldBankReceipt(oObj)) .and. (oObj:cCodOco<>"14") )

		// Variaveis utilizadas para lancamento contabil na classe de recebimento antecipado
		Private nHdlPrv 	:= 0
		Private cLote		:= "008850"
		Private aFlagCTB	:= {}
		Private cArquivo := ""

		oRecAnt:=TRecebimentoAntecipado():New()
		oRecAnt:lJob := .T.

		aVar := Array(1, 14)		
		aVar[1] := {,,,SE1->E1_NUMBCO, oObj:nVlTar, 0,, oObj:nVlRec,,,,,oObj:dDtCred, oObj:cCodOco}

		//Verificando se eh recebimento antecipado
		lRA := oRecAnt:TituloRecBan(aVar)

		ConOut("TAFBaixaReceber >>> INICIANDO BAIXA AUTOMATICA - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)+" VLREC =  "+AllTrim(Str(oObj:nVlRec))+", VLJUROS = "+AllTrim(Str(oObj:nVlJuro))+", VLMULTA = "+AllTrim(Str(oObj:nVlMult)))

		//Desconto previamente baixado
		If ((oObj:nVlRec + oObj:nVlDesc) > SE1->E1_SALDO)

			oObj:nVlDesc := 0

		EndIf

		If oObj:nVlRec > SE1->E1_VALOR .And. Alltrim(SE1->E1_NATUREZ) == "1230" .And. (oObj:cBanco $ "001|237|021" .Or. oObj:cCodOco $ "05")

			nAuxTarGnr := Round(oObj:nVlRec - SE1->E1_VALOR - oObj:nVlJuro - oObj:nVlOCre - oObj:nVlMult, 2)

			nAuxTxCob := Round(SE1->E1_YTXCOBR, 2)

			If nAuxTarGnr > 0 .And. (nAuxTarGnr == nAuxTxCob .Or. nAuxTxCob == 0)

				lRet := .T.

				oObj:nVlMult := oObj:nVlMult + nAuxTarGnr

				// Entende-se que veio do processo antigo
				If nAuxTxCob == 0

					RecLock("SE1", .F.)

					// Atualizo pois utiliza na contabilizacao
					SE1->E1_YTXCOBR := nAuxTarGnr

					SE1->(MSUnlock())

				EndIf

			ElseIf nAuxTarGnr > 0 .And. nAuxTxCob > 0

				lRet := .F.

				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_BAI_TIT"
				::oLog:cHrFin := Time()
				::oLog:cRetMen := "Titulo ST com falha no calculo"
				::oLog:cEnvWF := "S"
				::oLog:cTabela := RetSQLName("ZK4")
				::oLog:nIDTab := oObj:nID

				::oLog:Insert()

			EndIf

		EndIf

		If lRet

			// Baixa Cartorio
			If oObj:cCodOco == "15" .And. ( oObj:nVlOCre > 0 .Or. oObj:nVlJuro > 0 )

				nAuxVlRec := oObj:nVlRec

				If oObj:nVlOCre > 0 .And. oObj:nVlJuro == 0

					nAuxTxCart := oObj:nVlOCre

					oObj:nVlRec := oObj:nVlOCre

					oObj:nVlJuro := oObj:nVlOCre

					oObj:nVlOCre := 0

				ElseIf oObj:nVlOCre == 0 .And. oObj:nVlJuro > 0

					nAuxTxCart := oObj:nVlJuro

					oObj:nVlRec := oObj:nVlJuro

					oObj:nVlOCre := 0

				ElseIf oObj:nVlOCre > 0 .And. oObj:nVlJuro > 0

					lRet := .F. // Verificar como veio no arquivo para ser tratado

					::oLog:cIDProc := ::oPro:cIDProc
					::oLog:cOperac := "R"
					::oLog:cMetodo := "CR_BAI_TIT"
					::oLog:cHrFin := Time()
					::oLog:cRetMen := "Titulo com despesa de cartorio com falha no calculo"
					::oLog:cEnvWF := "S"
					::oLog:cTabela := RetSQLName("ZK4")
					::oLog:nIDTab := oObj:nID

					::oLog:Insert()

				EndIf

				If lRet

					// Baixa Cartorio
					cMotBx := "DESP.CART."

					lRet := ::ExecBaixaCR(oObj, cMotBx)

					If lRet

						// Baixa Titulo
						cMotBx := "NOR"

						oObj:nVlRec := nAuxVlRec - nAuxTxCart

						oObj:nVlJuro := 0

						If !lRA

							lRet := ::ExecBaixaCR(oObj, cMotBx)

						EndIf

					EndIf

				EndIf

				//Tratamento feito para os casos que o retorno vem com codigo 15
				//porem nao trata-se especificamente de desp de cartorio
				//e sim do recebimento, pois a despesa foi cobrada no cartorio,
				//recebido o valor do titulo e repassado para a empresa.
			ElseIf ( oObj:cCodOco <> "15" ) .Or. ( oObj:cCodOco == "15" .And. ( oObj:nVlOCre == 0 .And. oObj:nVlJuro == 0 ) )

				cMotBx := "NOR"

				If lRet .And. !lRA

					lRet := ::ExecBaixaCR(oObj, cMotBx)

				EndIf

			EndIf

		EndIf

		If lRA .And. lRet

			ConOut("TAFBaixaReceber >>> BAIXA AUTOMATICA (RECEBIMENTO ANTECIPADO) NN - "+oObj:cNosNum+" - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)+" VLREC =  "+AllTrim(Str(oObj:nVlRec))+", VLJUROS = "+AllTrim(Str(oObj:nVlJuro))+", VLMULTA = "+AllTrim(Str(oObj:nVlMult)))

			oRecAnt:cNossoNum := oObj:cNosNum
			oRecAnt:nVlJuros := oObj:nVlJuro

			If oRecAnt:BaixarPr()

				ConOut("TAFBaixaReceber >>> BAIXA AUTOMATICA - SUCESSO - (RECEBIMENTO ANTECIPADO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

				::UpdStatus(oObj:nID, "2")

			Else

				ConOut("TAFBaixaReceber >>> BAIXA AUTOMATICA - ERRO - (RECEBIMENTO ANTECIPADO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO) + CRLF + CRLF + oRecAnt:cErro)

				::oLog:cIDProc := ::oPro:cIDProc
				::oLog:cTabela := RetSQLName("ZK4")
				::oLog:nIDTab := oObj:nID
				::oLog:cHrFin := Time()
				::oLog:cRetMen := oRecAnt:cErro
				::oLog:cOperac := "R"
				::oLog:cMetodo := "CR_BAI_TIT"
				::oLog:cEnvWF := "S"

				::oLog:Insert()

				::lErro := .T.

				::UpdStatus(oObj:nID, "1", oRecAnt:cErro)

				cacheData():set(oObj:cNosNum,"cRetMen",oRecAnt:cErro)

			EndIf

		EndIf

	EndIf

	&("dDataBase"):=dsvDataBase

Return()


Method ExecMovFin(oObj, nValor, cNat, cHist) Class TAFBaixaReceber
	
	local aPerg := {}
	Local aMovBan := {}
	Local aAutoErro := {}
	Local cLogTxt := ""
	Local dDataDisp := If(oObj:cBanco $ "237", If(Empty(oObj:dDtCred), DataValida(oObj:dDtLiq + 1), oObj:dDtCred), oObj:dDtLiq)
	Local _cFilBkp := cFilAnt

	Local cPadrao
	Local nSE1RecNo

	Local cSA1IdxKey

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	If ( cFilAnt <> SE1->E1_FILIAL )
		cFilAnt := SE1->E1_FILIAL
	EndIf

	FIDC():resetFIDCVars()

	aAdd(aMovBan, {"E5_FILIAL", xFilial("SE5"), Nil})
	aAdd(aMovBan, {"E5_DATA", oObj:dDtLiq, Nil})
	aAdd(aMovBan, {"E5_DTDIGIT", oObj:dDtLiq, Nil})
	aAdd(aMovBan, {"E5_DTDISPO", dDataDisp, Nil})
	aAdd(aMovBan, {"E5_VALOR", nValor, Nil})
	aAdd(aMovBan, {"E5_NATUREZ", cNat, Nil})
	aAdd(aMovBan, {"E5_HISTOR", cHist, Nil})
	aAdd(aMovBan, {"E5_RECPAG", "P", Nil})
	aAdd(aMovBan, {"E5_MOEDA", "M1", Nil})
	aAdd(aMovBan, {"E5_TXMOEDA", 0, Nil})
	aAdd(aMovBan, {"E5_BANCO", oObj:cBanco, Nil})
	aAdd(aMovBan, {"E5_AGENCIA", oObj:cAgencia, Nil})
	aAdd(aMovBan, {"E5_CONTA", oObj:cConta, Nil})
	aAdd(aMovBan, {"E5_CNABOC", oObj:cCodOco, Nil})
	aAdd(aMovBan, {"E5_TIPODOC", "DB", Nil})
	aAdd(aMovBan, {"E5_MOTBX", "NOR", Nil})
	aAdd(aMovBan, {"E5_PREFIXO", SE1->E1_PREFIXO, Nil})
	aAdd(aMovBan, {"E5_NUMERO", SE1->E1_NUM, Nil})
	aAdd(aMovBan, {"E5_PARCELA", SE1->E1_PARCELA, Nil})
	aAdd(aMovBan, {"E5_TIPO", SE1->E1_TIPO, Nil})
	//aAdd(aMovBan, {"E5_CLVLDB", If (cEmpAnt == "01", "1215", If (cEmpAnt == "05", "1003", If (cEmpAnt == "06", "1055", If (cEmpAnt == "07", "1219", If (cEmpAnt == "12", "1090", If (cEmpAnt == "13", "1080", If (cEmpAnt == "14", "1500", "0"))))))), Nil})
	aAdd(aMovBan, {"E5_CLVLDB", U_BIA478G("ZJ0_CLVLDB", cNat, "P"), Nil})

	aAdd(aMovBan, {"E5_CCD", "1000", Nil})
	aAdd(aMovBan, {"E5_FILORIG", cFilAnt, Nil})

	aMovBan := FWVetByDic(aMovBan, "SE5", .F., 1)

	Pergunte("AFI100", .F.,,,,, @aPerg)
		MV_PAR02 := 2
	__SaveParam("AFI100", aPerg)

	MsExecAuto({|x,y,z| FINA100(x,y,z)}, 0, aMovBan, 3)

	If !lMsErroAuto

		// Ticket: 25060
		RecLock("SE5", .F.)
		SE5->E5_TIPODOC := "DB"
		SE5->(MSUnlock())

		//Gravar campos adicionais SE5
		::AjusteCliSE5(oObj)

		ConOut("BAIXA RECEBER AUTOMATICA (TARIFA - SUCESSO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

		//Atualizar Status ZK4
		::UpdStatus(oObj:nID, "2")

		FIDC():resetFIDCVars()
		if (FIDC():isFIDCEnabled().and.FIDC():getBiaPar("FIDC_CTB_LP_MOVFIN_ONLINE",.F.))
			cSA1IdxKey:="A1_FILIAL+A1_COD+A1_LOJA"
			SA1->(dbSetOrder(retOrder("SA1",cSA1IdxKey)))
			if (SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)))
				//Contabilizacao FIDC
				cPadrao:=FIDC():getBiaPar("FIDC_LP_MOVFIN",""/*FMF*/)
				if (!empty(cPadrao))
					nSE1RecNo:=SE1->(recNo())
					FIDC():setFIDCVar("lCTBFIDC",.T.)
					FIDC():setFIDCVar("cCTBStack","ExecMovFin")
					FIDC():setFIDCVar("cPadrao",cPadrao)
					FIDC():setFIDCVar("nSE1RecNo",nSE1RecNo)
					FIDC():setFIDCVar("nSA1RecNo",SA1->(recNo()))
					FIDC():setFIDCVar("cBanco",SE1->E1_PORTADO)
					FIDC():setFIDCVar("cAgencia",SE1->E1_AGEDEP)
					FIDC():setFIDCVar("cConta",SE1->E1_CONTA)
					FIDC():setFIDCVar("cCodOco",oObj:cCodOco)
					FIDC():setFIDCVar("lUsaFlag",SuperGetMV("MV_CTBFLAG",.F./*lHelp*/,.F./*cPadrao*/))
					if (FIDC():getFIDCVar("lUsaFlag",.F.))
						FIDC():setFIDCVar("aFlagCTB",{"E1_LA","S","SE1",nSE1RecNo,0,0,0})
					endif
					FIDC():setFIDCVar("lDiario",(FindFunction("UsaSeqCor").and.UsaSeqCor()))
					if (FIDC():getFIDCVar("lDiario",.F.))
						FIDC():setFIDCVar("aDiario",{"SE1",nSE1RecNo,SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"})
					endif
					SE1->(FIDC():ctbFIDC(1))
					FIDC():resetFIDCVars()
				endif
			endif
		endif

	Else

		::lErro := .T.

		::UpdStatus(oObj:nID, "1", cLogTxt)

		//DisarmTransaction()

		//Grava log de erro para consulta posterior
		aAutoErro := GETAUTOGRLOG()

		cLogTxt += ::GetErrorLog(aAutoErro)

		ConOut("ERRO BAIXA RECEBER AUTOMATICA (TARIFA - ERRO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)+": ERRO: "+cLogTxt)

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_BAI_TIT"
		::oLog:cHrFin := Time()
		::oLog:cRetMen := cLogTxt
		::oLog:cEnvWF := "S"
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID

		::oLog:Insert()

		cacheData():set(oObj:cNosNum,"cRetMen",cLogTxt)

	EndIf

	If ( cFilAnt <> _cFilBkp )
		cFilAnt := _cFilBkp
	EndIf

Return(!lMsErroAuto)


Method ExecBaixaCR(oObj, cMotBx) Class TAFBaixaReceber
	
	Local aTit := {}
	Local aAutoErro := {}
	Local cLogTxt := ""
	Local aPerg := {}
	Local _cFilBkp := cFilAnt

	Local cPadrao
	Local cSA1IdxKey
	Local nSE1RecNo
	Local dsvDataBase

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private lAutoErrNoFile := .T.

	dsvDataBase:=&("dDataBase")

	&("dDataBase"):=if(empty(oObj:dDtCred),oObj:dDtLiq,oObj:dDtCred)

	If ( cFilAnt <> SE1->E1_FILIAL )
		cFilAnt := SE1->E1_FILIAL
	EndIf

	FIDC():resetFIDCVars()

	aAdd(aTit, {"E1_PREFIXO", SE1->E1_PREFIXO, Nil})
	aAdd(aTit, {"E1_NUM", SE1->E1_NUM, Nil})
	aAdd(aTit, {"E1_PARCELA", SE1->E1_PARCELA, Nil})
	aAdd(aTit, {"E1_TIPO", SE1->E1_TIPO, Nil})
	aAdd(aTit, {"AUTMOTBX", cMotBx, Nil})
	aAdd(aTit, {"AUTBANCO", oObj:cBanco, Nil})
	aAdd(aTit, {"AUTAGENCIA", oObj:cAgencia, Nil})
	aAdd(aTit, {"AUTCONTA", oObj:cConta, Nil})
	aAdd(aTit, {"AUTDTBAIXA", oObj:dDtLiq, Nil})
	aAdd(aTit, {"AUTDTCREDITO", oObj:dDtCred, Nil})
	aAdd(aTit, {"AUTDESCONT", oObj:nVlDesc, Nil,.T.})
	aAdd(aTit, {"AUTJUROS", oObj:nVlJuro, Nil,.T.})
	aAdd(aTit, {"AUTMULTA", oObj:nVlMult, Nil,.T.})
	aAdd(aTit, {"AUTACRESC", oObj:nVlOCre, Nil})
	aAdd(aTit, {"AUTVALREC", oObj:nVlRec, Nil})

	Pergunte("FIN070", .F.,,,,, @aPerg)
		MV_PAR01 := 2
		MV_PAR03 := 1
		MV_PAR05 := 1
	__SaveParam("FIN070", aPerg)

	MsExecAuto({|x,y| FINA070(x,y)}, aTit, 3)

	If (!lMsErroAuto)

		ConOut("TAFBaixaReceber >>> BAIXA AUTOMATICA (BAIXA - SUCESSO) - (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

		::UpdStatus(oObj:nID, "2")
		
		nSE1RecNo:=SE1->(recNo())
		cacheData():set("ExecBaixaCR","nSE1RecNo",nSE1RecNo)

		FIDC():resetFIDCVars()
		if (FIDC():isFIDCEnabled().and.FIDC():getBiaPar("FIDC_CTB_LP_BAIXA_ONLINE",.T.))
			cSA1IdxKey:="A1_FILIAL+A1_COD+A1_LOJA"
			SA1->(dbSetOrder(retOrder("SA1",cSA1IdxKey)))
			if (SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)))
				//Contabilizacao FIDC
				cPadrao:=FIDC():getBiaPar("FIDC_LP_BAIXA","FBX")
				if (!empty(cPadrao))
					FIDC():setFIDCVar("cPadrao",cPadrao)
					FIDC():setFIDCVar("nSE1RecNo",nSE1RecNo)
					FIDC():setFIDCVar("nSA1RecNo",SA1->(recNo()))
					FIDC():setFIDCVar("cBanco",SE1->E1_PORTADO)
					FIDC():setFIDCVar("cAgencia",SE1->E1_AGEDEP)
					FIDC():setFIDCVar("cConta",SE1->E1_CONTA)
					FIDC():setFIDCVar("cCodOco",oObj:cCodOco)
					FIDC():setFIDCVar("lUsaFlag",SuperGetMV("MV_CTBFLAG",.F./*lHelp*/,.F./*cPadrao*/))
					if (FIDC():getFIDCVar("lUsaFlag",.F.))
						FIDC():setFIDCVar("aFlagCTB",{"E1_LA","S","SE1",nSE1RecNo,0,0,0})
					endif
					FIDC():setFIDCVar("lDiario",(FindFunction("UsaSeqCor").and.UsaSeqCor()))
					if (FIDC():getFIDCVar("lDiario",.F.))
						FIDC():setFIDCVar("aDiario",{"SE1",nSE1RecNo,SE1->E1_DIACTB,"E1_NODIA","E1_DIACTB"})
					endif
					SE1->(FIDC():ctbFIDC())
					FIDC():resetFIDCVars()
				endif
			endif
		endif

	Else

		::lErro := .T.

		//Grava log de erro para consulta posterior
		aAutoErro := GETAUTOGRLOG()

		cLogTxt += ::GetErrorLog(aAutoErro)

		::UpdStatus(oObj:nID, "1", cLogTxt)

		ConOut("TAFBaixaReceber >>> ERRO BAIXA AUTOMATICA (BAIXA - ERRO)- (PREF+NUM+PARC+TIPO) = "+(SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO)+": ERRO: "+cLogTxt)

		::oLog:cIDProc := ::oPro:cIDProc
		::oLog:cOperac := "R"
		::oLog:cMetodo := "CR_BAI_TIT"
		::oLog:cHrFin := Time()
		::oLog:cRetMen := cLogTxt
		::oLog:cEnvWF := "S"
		::oLog:cTabela := RetSQLName("ZK4")
		::oLog:nIDTab := oObj:nID

		::oLog:Insert()

		cacheData():set(oObj:cNosNum,"cRetMen",cLogTxt)

	EndIf

	If ( cFilAnt <> _cFilBkp )
		cFilAnt := _cFilBkp
	EndIf

	&("dDataBase"):=dsvDataBase

Return(!lMsErroAuto)


Method AjusteCliSE5(oObj) Class TAFBaixaReceber
	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT TOP 1 REC = R_E_C_N_O_ "
	cSQL += " FROM " + RetSqlName("SE5")
	cSQL += " WHERE E5_FILIAL	= " + ValToSQL(xFilial("SE5"))
	cSQL += " AND E5_PREFIXO	= " + ValToSQL(SE1->E1_PREFIXO)
	cSQL += " AND E5_NUMERO	= " + ValToSQL(SE1->E1_NUM)
	cSQL += " AND E5_PARCELA	= " + ValToSQL(SE1->E1_PARCELA)
	cSQL += " AND E5_TIPO 	  	= " + ValToSQL(SE1->E1_TIPO)
	cSQL += " AND E5_TIPODOC	= 'DB' "
	cSQL += " AND E5_MOTBX 	= 'NOR' "
	cSQL += " AND E5_RECPAG	= 'P' "
	cSQL += " AND E5_DATA 	  	= " + ValToSQL(DTOS(oObj:dDtLiq))
	cSQL += " AND D_E_L_E_T_	= '' "
	cSQL += " ORDER BY R_E_C_N_O_ DESC "

	TcQuery cSQL New Alias (cQry)

	(cQry)->(DbGoTop())

	If !(cQry)->(Eof())

		SE5->(DbSetOrder(0))
		SE5->(DbGoTo((cQry)->REC))

		If !SE5->(EOF())

			lRet := .T.

			RecLock("SE5", .F.)

			SE5->E5_CLIFOR	:= SE1->E1_CLIENTE
			SE5->E5_LOJA	:= SE1->E1_LOJA

			SE5->(MSUnlock())

		EndIf

	EndIf

	(cQry)->(DBCloseArea())

Return(lRet)


Method GetDescOc(oObj) Class TAFBaixaReceber
	Local cRet := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT EB_DESCRI "
	cSQL += " FROM " + RetSQLName("SEB")
	cSQL += " WHERE EB_FILIAL = " + ValToSQL(xFilial("SEB"))
	cSQL += " AND EB_BANCO = " + ValToSQL(oObj:cBanco)
	cSQL += " AND EB_REFBAN = " + ValToSQL(SubStr(oObj:cCodOco, 1, 2))
	cSQL += " AND EB_TIPO = 'R' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->EB_DESCRI)

		cRet := SubStr(oObj:cCodOco, 1, 2) + "-" + Capital(AllTrim((cQry)->EB_DESCRI))

	Else

		cRet := SubStr(oObj:cCodOco, 1, 2) + "-Ocorrência não identificada"

	EndIf

	(cQry)->(DbCloseArea())

Return(cRet)


Method UpdStatus(nID, cStatus, cErro) Class TAFBaixaReceber

	Default cStatus := ""
	Default cErro := ""

	DbSelectArea("ZK4")
	ZK4->(DbGoTo(nID))

	RecLock("ZK4", .F.)

	ZK4->ZK4_STATUS := cStatus
	ZK4->ZK4_ERRO := If(Empty(ZK4->ZK4_ERRO), cErro, " - " + cErro)

	ZK4->(MsUnLock())

Return()


Method GetErrorLog(aError) Class TAFBaixaReceber

	Local cRet := ""
	Local nX := 1

	Default aError := GETAUTOGRLOG()

	For nX := 1 To Len(aError)

		cRet += aError[nX] + CRLF

	Next nX

Return(cRet)

Method Extend(oObj,cStatus) Class TAFBaixaReceber
	
	local cMsg			as character
	
	local cSStatus		as character
	local cTStatus		as character
	
	local cZK8Order		as character
	local cZK8KeySeek	as character

	local cZKCOrder		as character
	local cZKCKeySeek	as character

	local dExtend		as date
	
	local lExtend		as logical
	local lSE1Lock		as logical
	local lZK8Lock		as logical
	local lZKCLock		as logical
	local lZKCFound		as logical
	local lZKCStatus	as logical

	local nZK8RecNo		as numeric
	local nZKCRecNo		as numeric

	local nZK8Order		as numeric
	local nZKCOrder		as numeric

	cSStatus:=left(cStatus,1)
	cTStatus:=right(cStatus,1)

	cZKCOrder:="ZKC_FILIAL+ZKC_NUM+ZKC_PREFIX+ZKC_PARCEL+ZKC_TIPO+ZKC_CLIFOR+ZKC_LOJA"
	nZKCOrder:=retOrder("ZKC",cZKCOrder)
	ZKC->(dbSetOrder(nZKCOrder))

	cZKCKeySeek:=xFilial("ZKC")
	cZKCKeySeek+=SE1->E1_NUM
	cZKCKeySeek+=SE1->E1_PREFIXO
	cZKCKeySeek+=SE1->E1_PARCELA
	cZKCKeySeek+=SE1->E1_TIPO
	cZKCKeySeek+=SE1->E1_CLIENTE
	cZKCKeySeek+=SE1->E1_LOJA

	lZKCFound:=(ZKC->(dbSeek(cZKCKeySeek,.F.)))
	
	lExtend:=(lZKCFound)

	if (lExtend)

		while ZKC->(!eof().and.(&(cZKCOrder)==cZKCKeySeek))
			lExtend:=(ZKC->ZKC_STATUS==cSStatus)
			if (lExtend)
				nZKCRecNo:=ZKC->(recNo())
				exit
			endif
			ZKC->(dbSkip())
		end while

	endif

	if (lExtend)
		ZKC->(MsGoTo(nZKCRecNo))
		lZKCLock:=ZKC->(recLock("ZKC",.F.))
		lSE1Lock:=SE1->(recLock("SE1",.F.))
		lExtend:=((lZKCLock).and.(lSE1Lock))
		dExtend:=ZKC->ZKC_VENCCA
		if ((lExtend).and.(cTStatus=="P"))
			SE1->E1_VENCTO:=dExtend
			SE1->E1_VENCREA:=dExtend
			SE1->E1_PORCJUR:=ZKC->(ROUND((((ZKC_TXJUR/30/100)*ZKC_DIAS)*1),2))
			SE1->E1_JUROS:=ZKC->ZKC_JUROS
			SE1->(MsUnLock())
		endif
	endif

	if (!lExtend)
	
		if (!cTStatus=="B")

			if (!lZKCFound)
				cMsg:="PRORROGACAO NAO ENCONTRADA"
			elseif (ZK8->ZK8_STATUS=="P")
				cMsg:="TITULO PRORROGADO ANTERIORMENTE"
			elseif (ZK8->ZK8_STATUS=="B")
				cMsg:="TITULO PRORROGADO BAIXADO ANTERIORMENTE"
			else
				cMsg:="REGISTRO EM USO"
			endif

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "NAO FOI POSSIVEL ALTERAR O VENCIMENTO DO TITULO : "+cMsg
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_BAI_TIT"
			::oLog:cEnvWF := "S"

			::UpdStatus(oObj:nID, "1", ::oLog:cRetMen)

			::oLog:Insert()

		endif

	else

		ZKC->(MsGoTo(nZKCRecNo))

		DEFAULT lZKCLock:=ZKC->(recLock("ZKC",.F.))

		if (lZKCLock)

			ZKC->ZKC_STATUS:=cTStatus
			ZKC->(MsUnLock())

			cZK8Order:="ZK8_FILIAL+ZK8_NUMERO"
			nZK8Order:=retOrder("ZK8",cZK8Order)
			ZK8->(dbSetOrder(nZK8Order))
			
			cZK8KeySeek:=xFilial("ZK8",ZKC->ZKC_FILIAL)
			cZK8KeySeek+=ZKC->ZKC_NUMERO

			lZK8Found:=(ZK8->(dbSeek(cZK8KeySeek,.F.)))
	
			if (lZK8Found)
				
				while ZK8->(!eof().and.(cZK8KeySeek==ZK8_FILIAL+ZK8_NUMERO))
					if (ZK8->ZK8_CODCLI==ZKC->ZKC_CLIFOR)
						nZK8RecNo:=ZK8->(recNo())
						exit
					endif
					ZK8->(dbSkip())
				end while

				if (!empty(nZK8RecNo))

					ZK8->(MsGoTo(nZK8RecNo))

					cZKCOrder:="ZKC_FILIAL+ZKC_NUMERO"
					nZKCOrder:=retOrder("ZKC",cZKCOrder)
					ZKC->(dbSetOrder(nZKCOrder))
					cZKCKeySeek:=xFIlial("ZKC")
					cZKCKeySeek+=ZK8->ZK8_NUMERO
					lZKCFound:=ZKC->(dbSeek(cZKCKeySeek,.F.))

					if (lZKCFound)

						while ZKC->(!eof().and.(ZKC_FILIAL+ZKC_NUMERO)==cZKCKeySeek)
							lZKCStatus:=(ZKC->ZKC_STATUS==cTStatus)
							if (!lZKCStatus)
								exit
							endif
							ZKC->(dbSkip())
						end while

						if (lZKCStatus)
							lZK8Lock:=ZK8->(recLock("ZK8",.F.))
							if (lZK8Lock)
								ZK8->ZK8_STATUS:=cTStatus
								ZK8->(MsUnLock())
							endif
						endif

					endif

				endif
			
			endif
		
		endif

		if (cTStatus=="P")
		
			cMsg:="NOVO VENCIMENTO"
			cMsg+=" : [ "
			cMsg+=DToC(dExtend)
			cMsg+=" ]"

			::oLog:cIDProc := ::oPro:cIDProc
			::oLog:cTabela := RetSQLName("ZK4")
			::oLog:nIDTab := oObj:nID
			::oLog:cHrFin := Time()
			::oLog:cRetMen := "TITULO PRORROGADO : "+cMsg
			::oLog:cOperac := "R"
			::oLog:cMetodo := "CR_BAI_TIT"
			::oLog:cEnvWF := "S"

			::UpdStatus(oObj:nID, "1", ::oLog:cRetMen)

			::oLog:Insert()

		endif

	endif

	return(lExtend)
