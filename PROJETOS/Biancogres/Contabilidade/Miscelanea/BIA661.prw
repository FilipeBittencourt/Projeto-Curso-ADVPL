#include "totvs.ch"
#include "dbStruct.ch"

/*/{Protheus.doc} BIA661
@author Marinaldo de Jesus (Facile)
@since 28/12/2020
@version 1.0
@Projet A-35
@description BP Consolidado - Previsão de contas a receber.
@type function
/*/

function u_BIA661() as logical
	
	local aArea		as array
	local aAreaSM0	as array

	local cEmp		as character
	local cFil		as character

	local lRet  	as logical
	local lMesAno	as logical
	local lDataFech	as logical
	local lTipoRef	as logical
	local lShowXML	as logical

	local oEmp		as object
	local oPerg		as object

	cEmp:=&("cEmpAnt")
	cFil:=&("cFilAnt")

	private cCadastro as character
	
	cCadastro:="Consolidado - Previsão de contas a receber"
	
	aArea:=getArea()
	aAreaSM0:=SM0->(getArea())

	begin sequence

		oEmp:=TLoadEmpresa():New()
		oPerg:=TWPCOFiltroPeriodo():New()

		lMesAno:=.F.
		lDataFech:=.F.
		lTipoRef:=.T.

		lRet:=oPerg:Pergunte(@lMesAno,@lDataFech,@lTipoRef)
		
		if (!lRet)
			break
		endif

		lShowXML:=ApMsgNoYes("Deseja consultar os dados gerados ao final de cada processo?",cCadastro)

		oEmp:GetSelEmp()

		lRet:=Processa({|lEnd|BIA661(@cEmp,@cFil,@oEmp,@oPerg,@lEnd,@lShowXML)},cCadastro,nil,.T.)

	end sequence

	RPCTools():RpcSetEnv(cEmp,cFil)

	restArea(aAreaSM0)
	restArea(aArea)

	return(lRet)

static function BIA661(cEmpDef as character,cFilDef as character,oEmp as object,oPerg as object,lEnd as logical,lShowXML as logical) as logical

	local aMsg			as array
	local aSM0RecNo		as array

	local bExec			as block
	local bError		as block
	local bErrorBlock	as block

	local cMsg  		as character
	local cCRLF			as character
	local cMsgPrc		as character

	local cEmp			as character
	local cFil			as character
	local cVersao   	as character
	local cRevisa   	as character
	local cAnoRef   	as character
	local cTipoRef		as character

	local lRet			as logical

	local nD 			as numeric
	local nJ			as numeric

	local nSM0AT		as numeric
	local nSM0RecNo		as numeric

	local nKeepResponse	as numeric

	lRet:=.T.
	nKeepResponse:=(-1)

	begin sequence

		nJ:=Len(oEmp:aEmpSel)
		lRet:=(nJ>0)
		if (!lRet)
			ApMsgAlert("Nenhuma empresa foi selecionada!")
			break
		endif

		aMsg:=array(0)
		bExec:={||lRet:=BIA661Proc(@cEmp,@cFil,@cVersao,@cRevisa,@cAnoRef,@cTipoRef,@cMsg,@lShowXML,@nKeepResponse)}

		ProcRegua(SM0->(recCount()))

		aSM0RecNo:=array(0)
		SM0->(dbSetOrder(1))
		SM0->(dbGoTop())
		while SM0->(!eof())
			IncProc()
			SM0->(aAdd(aSM0RecNo,{fieldGet(fieldPos("M0_CODIGO")),fieldGet(fieldPos("M0_CODFIL")),recNo()}))
			SM0->(dbSkip())
		end while

		ProcRegua(if(nJ<=1,0,nJ))

		bError:={|oError|__break(@oError,@cMsg,@cEmp,@cFil)}

		for nD:=1 to nJ

			cEmp:=oEmp:aEmpSel[nD][1]
			
			nSM0AT:=aScan(aSM0RecNo,{|e|e[1]==cEmp})
			if (nSM0AT==0)
				loop
			endif
			
			cFil:=rTrim(aSM0RecNo[nSM0AT][2])
			
			nSM0RecNo:=aSM0RecNo[nSM0AT][3]

			SM0->(dbGoTo(nSM0RecNo))

			cVersao:=left(oPerg:cVersao,getSX3Cache("ZOF_VERSAO","X3_TAMANHO"))
			cRevisa:=left(oPerg:cRevisa,getSX3Cache("ZOF_REVISA","X3_TAMANHO"))
			cAnoRef:=left(oPerg:cAnoRef,getSX3Cache("ZOF_ANOREF","X3_TAMANHO"))
			cTipoRef:=left(oPerg:cTipoRef,getSX3Cache("ZOF_TIPO","X3_TAMANHO"))
			if (empty(cTipoRef))
				cTipoRef:="2"
			endif

			cMsgPrc:="Processando...Empresa:["+cEmp+"] :: Filial:["+cFil+"]"
			IncProc(cMsgPrc)
		
			if (lEnd)
				cMsg:="Operação Cancelada pelo usuário"
				aAdd(aMsg,{cEmp,cFil,cVersao,cRevisa,cAnoRef,cTipoRef,cMsg})
				break
			endif

			bErrorBlock:=ErrorBlock(bError)
			begin sequence

				MsAguarde({||RPCTools():RpcSetEnv(cEmp,cFil),&("cCadastro"),StrTran(cMsgPrc,"Processando","Preparando Ambiente")})

				SM0->(dbGoTo(nSM0RecNo))

				MsAguarde(bExec,&("cCadastro"),cMsgPrc)

			recover
				
				MsgRun(cMsg,"Aguarde...",{||sleep(100)})
			
			end sequence
			ErrorBlock(bErrorBlock)

			if (!empty(cMsg))
				aAdd(aMsg,{cEmp,cFil,cVersao,cRevisa,cAnoRef,cTipoRef,cMsg})
				cMsg:=""
			endif

		next nD

	end sequence

	RPCTools():RpcSetEnv(cEmp,cFil)

	if (!empty(aMsg))

		cMsg:=""
		cCRLF:=CRLF
		nJ:=len(aMsg)
		for nD:=1 to nJ
			cMsg+="Empresa:"
			cMsg+=" "
			cMsg+=aMsg[nD][1]
			cMsg+=cCRLF
			cMsg+="Filial:"
			cMsg+=" "
			cMsg+=aMsg[nD][2]
			cMsg+=cCRLF
			cMsg+="Versao:"
			cMsg+=" "
			cMsg+=aMsg[nD][3]
			cMsg+=cCRLF
			cMsg+="Revisao:"
			cMsg+=" "
			cMsg+=aMsg[nD][4]
			cMsg+=cCRLF
			cMsg+="Referecia:"
			cMsg+=" "
			cMsg+=aMsg[nD][5]
			cMsg+=cCRLF
			cMsg+="Tipo:"
			cMsg+=" "
			cMsg+=aMsg[nD][6]
			cMsg+=cCRLF
			cMsg+="Mensagem:"
			cMsg+=" "
			cMsg+=aMsg[nD][7]
			cMsg+=cCRLF
		next nD
		
		eecView(cMsg,&("cCadastro")+" :: Log de Processamento :: ATENÇÃO")

	endif

	return(lRet)

static function BIA661Proc(cEmp as character,cFil as character,cVersao as character, cRevisa as character, cAnoRef as character, cTipoRef as character,cMsg as character,lShowXML as logical,nKeepResponse as numeric) as logical

    local aFieldPos		as array
	local aTmpStruct	as array
	
	local cCRLF			as character
	local cXMLFile      as character
	local cXMLPath		as character
	local cMsgNoYes		as character
	local cTmpAlias		as character
    local cServerIP     as character
    local cEnvServer    as character
    local cExcelTitle   as character

	local cSQLQuery		as character

	local cZOFOrder		as character
	local cZOFINDICA	as character
	local cZOFFilial	as character
	local cZOFKeySeek	as character

	local cFldZOFINDICA as character

	local cTmp_Resumo	as character

    local lRet          as logical
    local lDev          as logical
    local lPicture      as logical
    local lX3Titulo     as logical
    local leecView      as logical
	
	local lZOFFound		as logical

    local nField		as numeric
	local nFields		as numeric
	local nFieldSrc		as numeric
	local nFieldTrg   	as numeric
	local nZOFOrder		as numeric
	local nFldZOFINDICA	as numeric

	local uSrc

	DEFAULT cEmp:=&("cEmpAnt")
	DEFAULT cFil:=&("cFilAnt")
	DEFAULT lRet:=.T.

	cCRLF:=CRLF

	cZOFOrder:="ZOF_FILIAL+ZOF_VERSAO+ZOF_REVISA+ZOF_ANOREF+ZOF_TIPO+ZOF_INDICA"
	nZOFOrder:=retOrder("ZOF",cZOFOrder)

	ZOF->(dbSetOrder(nZOFOrder))
	
	cZOFFilial:=xFilial("ZOF")
	
	cZOFKeySeek:=cZOFFilial
	cZOFKeySeek+=cVersao
	cZOFKeySeek+=cRevisa
	cZOFKeySeek+=cAnoRef
	cZOFKeySeek+=cTipoRef

	lZOFFound:=ZOF->(dbSeek(cZOFKeySeek,.F.))

	cFldZOFINDICA:="ZOF_INDICA"

	if (lZOFFound)
		if (nKeepResponse==(-1))
			cMsgNoYes:="Já Existem dados para este Orçamento."
			cMsgNoYes+=cCRLF
			cMsgNoYes+=cCRLF
			cMsgNoYes+=" Empresa:["+cEmp+"] :: Filial:["+cFil+"]"
			cMsgNoYes+=" :: "
			cMsgNoYes+="["
			cMsgNoYes+=cVersao
			cMsgNoYes+="]"
			cMsgNoYes+="["
			cMsgNoYes+=cRevisa
			cMsgNoYes+="]"
			cMsgNoYes+="["
			cMsgNoYes+=cAnoRef
			cMsgNoYes+="]"
			cMsgNoYes+="["
			cMsgNoYes+=cTipoRef
			cMsgNoYes+="]"
			cMsgNoYes+=cCRLF
			cMsgNoYes+=cCRLF
			cMsgNoYes+=" Deseja Reprocessar?"
			lZOFFound:=ApMsgNoYes(cMsgNoYes,&("cCadastro"))
			nKeepResponse:=if(lZOFFound,1,0)
		else
			lZOFFound:=(nKeepResponse==1)
		endif
		if (!lZOFFound)
			if (lShowXML)
				lZOFFound:=.T.
				cFldZOFINDICA:="ZOF_INDICA"
				MsAguarde({||cTmpAlias:=getQueryEx(@cVersao,@cRevisa,@cAnoRef,@cTipoRef)},&("cCadastro"),"Obtendo dados no SGBD...Empresa:["+cEmp+"] :: Filial:["+cFil+"]")
			else
				cTmpAlias:=""
			endif
		else
			lZOFFound:=.F.
			MsAguarde({||cTmpAlias:=getQueryNW(@cVersao,@cRevisa,@cAnoRef,@cTipoRef,@cTmp_Resumo)},&("cCadastro"),"Obtendo dados no SGBD...Empresa:["+cEmp+"] :: Filial:["+cFil+"]")
		endif
	else
		MsAguarde({||cTmpAlias:=getQueryNW(@cVersao,@cRevisa,@cAnoRef,@cTipoRef,@cTmp_Resumo)},&("cCadastro"),"Obtendo dados no SGBD...Empresa:["+cEmp+"] :: Filial:["+cFil+"]")
	endif

	lRet:=((!empty(cTmpAlias)).and.(select(cTmpAlias)>0))

	begin sequence

		if (!lRet)
			break
		endif

		nFldZOFINDICA:=(cTmpAlias)->(fieldPos(cFldZOFINDICA))

		lRet:=(cTmpAlias)->(!(eof().and.bof()))

		if (!lRet)
			break
		endif

		if (!lZOFFound)

			aFieldPos:=array(0)
			aTmpStruct:=(cTmpAlias)->(dbStruct())

			nFields:=len(aTmpStruct)
			for nField:=1 to nFields
				nFieldTrg:=ZOF->(fieldPos(aTmpStruct[nField][DBS_NAME]))
				if (nFieldTrg>0)
					aAdd(aFieldPos,{nField,nFieldTrg})
				endif
			next nField

			nFields:=len(aFieldPos)

			begin transaction

				while (cTmpAlias)->(!eof())
					cZOFINDICA:=left((cTmpAlias)->(FieldGet(nFldZOFINDICA)),2)
					lZOFFound:=ZOF->(dbSeek(cZOFKeySeek+cZOFINDICA,.F.))
					lAddNew:=(!lZOFFound)
					if ZOF->(recLock("ZOF",lAddNew))
						ZOF->ZOF_FILIAL:=cZOFFilial
						ZOF->ZOF_VERSAO:=cVersao
						ZOF->ZOF_REVISA:=cRevisa
						ZOF->ZOF_ANOREF:=cAnoRef
						ZOF->ZOF_TIPO:=cTipoRef
						ZOF->ZOF_INDICA:=cZOFINDICA
						for nField:=1 to nFields
							nFieldSrc:=aFieldPos[nField][1]
							nFieldTrg:=aFieldPos[nField][2]
							uSrc:=(cTmpAlias)->(fieldGet(nFieldSrc))
							ZOF->(fieldPut(nFieldTrg,uSrc))
						next nField
						ZOF->(msUnLock())
					endif
					(cTmpAlias)->(dbSkip())
				end while

			end transaction

		endif

		if (lShowXML)

			cXMLPath:="\tmp\BIA661\XML\"
			if (dirtools():MakeDir(cXMLPath))

				cXMLFile:=cXMLPath
				cXMLFile+=ProcName()
				cXMLFile+="_"
				cXMLFile+=DtoS(Date())
				cXMLFile+="_"
				cXMLFile+=StrTran(Time(),":","")
				cXMLFile+="_"
				cXMLFile+=StrTran(cValtoChar(Seconds()),".","")
				cXMLFile+=".xml"
				
				if (type("cCadastro")=="C")
					cExcelTitle:=&("cCadastro")
					cExcelTitle+=" :: "
				else
					cExcelTitle:=""
				endif

				cExcelTitle+="Empresa: "+cEmp
				cExcelTitle+=" :: "
				cExcelTitle+="Filial:  "+cFil
				cExcelTitle+=" :: "
				cExcelTitle+="Ver.: "+cVersao
				cExcelTitle+=" :: "
				cExcelTitle+="Rev.: "+cRevisa
				cExcelTitle+=" :: "
				cExcelTitle+="Ref.: "+cAnoRef
				cExcelTitle+=" :: "
				cExcelTitle+="Tip.: "+cTipoRef
				
				cServerIP:=getServerIP()
				cEnvServer:=upper(getEnvServer())

				lDev:=((cServerIP=="192.168.20.18").or.("DEV"$cEnvServer))
				if (lDev)
					cExcelTitle+=" :: EMITIDO EM AMBIENTE DE DESENVOLVIMENTO ::"    
				endif

				lPicture:=.T.
				lX3Titulo:=.T.
				leecView:=.F.

				(cTmpAlias)->(dbGoTop())

				u_QryToXML(@cTmpAlias,@cXMLFile,@cExcelTitle,@lPicture,@lX3Titulo,@leecView)

			endif

		endif

		if (select(cTmpAlias)>0)
			(cTmpAlias)->(dbCloseArea())
			dbSelectArea("ZOF")
		endif

	end sequence

	if (!empty(cTmp_Resumo))
		cTmp_Resumo:=StrTran(cTmp_Resumo,"%","")
		cSQLQuery:="IF OBJECT_ID('"+cTmp_Resumo+"') IS NOT NULL"
		cSQLQuery+=CRLF
		cSQLQuery+="DROP TABLE "+cTmp_Resumo
		TCSQLExec(cSQLQuery)
	endif

	return(lRet)

static function getQueryEx(cVersao as character,cRevisa as character,cAnoRef as character,cTipoRef as character) as character
	
	local aZOFFields	as array
	
	local cAlias		as character
	local cFields		as character

	local cSQLFile		as character
	local cSQLPath		as character
	local cSQLQuery		as character

	local nField 		as numeric
	local nFields		as numeric

	if (IsBlind())
		cSQLPath:="\tmp\"
	else
		cSQLPath:=getTempPath()
		if (!right(cSQLPath,1)=="\")
			cSQLPath+="\"
		endif
	endif
	cSQLPath+="BIA661\SQL\"

	cAlias:=getNextAlias()
	cFields:=""
	aZOFFields:=ZOF->(dbStruct())
	nFields:=len(aZOFFields)
	for nField:=1 to nFields 
		cFields+=aZOFFields[nField][DBS_NAME]
		cFields+=","
	next nField

	cFields:=subStr(cFields,1,len(cFields)-1)
	cFields:="%"+cFields+"%"

	beginSQL alias cAlias
		SELECT %exp:cFields% 
		  FROM %table:ZOF% ZOF
		 WHERE ZOF.%notDel%
		   AND ZOF.ZOF_FILIAL=%xFilial:ZOF%
		   AND ZOF.ZOF_VERSAO=%exp:cVersao%
		   AND ZOF.ZOF_REVISA=%exp:cRevisa%
		   AND ZOF.ZOF_ANOREF=%exp:cAnoRef%
		   AND ZOF.ZOF_TIPO=%exp:cTipoRef%
		ORDER BY ZOF.ZOF_FILIAL
		        ,ZOF.ZOF_REVISA
				,ZOF.ZOF_ANOREF
				,ZOF.ZOF_TIPO
				,ZOF.ZOF_INDICA
	endSQL

	cSQLQuery:=getLastQuery()[2]

	if (dirtools():MakeDir(cSQLPath))
		cSQLFile:=cSQLPath
		cSQLFile+=ProcName()
		cSQLFile+="_"
		cSQLFile+=DtoS(Date())
		cSQLFile+="_"
		cSQLFile+=StrTran(Time(),":","")
		cSQLFile+="_"
		cSQLFile+=StrTran(cValtoChar(Seconds()),".","")
		cSQLFile+=".sql"
		memoWrite(cSQLFile,cSQLQuery)
	endif

	return(cAlias)

static function getQueryNW(cVersao as character, cRevisa as character, cAnoRef as character,cTipoRef as character,cTmp_Resumo as character) as character
	
	local bError		as block
	local bErrorBlock	as block
	
	local cAlias		as character

	local cSQLFile		as character
	local cSQLPath		as character
	local cSQLQuery		as character

	if (IsBlind())
		cSQLPath:="\tmp\"
	else
		cSQLPath:=getTempPath()
		if (!right(cSQLPath,1)=="\")
			cSQLPath+="\"
		endif
	endif
	cSQLPath+="BIA661\SQL\"

	cAlias:=getNextAlias()

	cTmp_Resumo:="tmp_resumo"
	cTmp_Resumo+="_"
	cTmp_Resumo+=DtoS(Date())
	cTmp_Resumo+="_"
	cTmp_Resumo+=StrTran(Time(),":","")
	cTmp_Resumo+="_"
	cTmp_Resumo+=StrTran(cValtoChar(Seconds()),".","")
	cTmp_Resumo+="_"
	cTmp_Resumo+=cValtoChar(Randomize(1,999))
	cTmp_Resumo:="%"+cTmp_Resumo+"%"

	bError:={|oError|break(oError)}
	bErrorBlock:=ErrorBlock(bError)
	begin sequence

		beginSQL Alias cAlias

			%noparser%

			WITH RECEITA AS
				(
						SELECT
								LEFT(ZBZ.ZBZ_DATA,6)      PERIODO
								,SUM(ZBZ.ZBZ_VALOR) * (-1) VALOR
						FROM
									%table:ZBZ% ZBZ
						WHERE
									ZBZ.ZBZ_VERSAO            = %exp:cVersao%
									AND ZBZ.ZBZ_REVISA        = %exp:cRevisa%
									AND ZBZ.ZBZ_ANOREF        = %exp:cAnoRef%
									AND ZBZ.ZBZ_ORIPRC        ='RECEITA'
									AND LEFT(ZBZ.ZBZ_DEBITO,3)='411'
									AND ZBZ.%notDel%
						GROUP BY
									LEFT(ZBZ.ZBZ_DATA,6)
						UNION ALL
						SELECT
								LEFT(ZBZ.ZBZ_DATA,6) PERIODO
								, SUM(ZBZ.ZBZ_VALOR)   VALOR
						FROM
									%table:ZBZ% ZBZ
						WHERE
									ZBZ.ZBZ_VERSAO            = %exp:cVersao%
									AND ZBZ.ZBZ_REVISA        = %exp:cRevisa%
									AND ZBZ.ZBZ_ANOREF        = %exp:cAnoRef%
									AND ZBZ.ZBZ_ORIPRC        ='RECEITA'
									AND LEFT(ZBZ.ZBZ_CREDIT,3)='411'
									AND ZBZ.%notDel%
						GROUP BY
									LEFT(ZBZ.ZBZ_DATA,6)
				)
				, SALDOANTERIOR AS
				(
						SELECT
								'SALDO ANT' as Descricao
								,( SUM(ZOD_SALCTA)+ISNULL(
									(
										SELECT
												ZB3.ZB3_VCHEIO
										FROM
												%table:ZB3% ZB3
										WHERE
												ZB3.%notDel%
												AND ZB3.ZB3_FILIAL BETWEEN '  ' AND 'ZZ'
												AND ZB3.ZB3_CODVAR='ySomaSaldoAntRec'
												AND ZB3.ZB3_VERSAO= %exp:cVersao%
												AND ZB3.ZB3_REVISA= %exp:cRevisa%
												AND ZB3.ZB3_ANOREF= %exp:cAnoRef%
									)
									,0) ) AS Valores
						FROM
									%table:ZOD% ZOD
						WHERE
									ZOD.%notDel%
									AND ZOD.ZOD_FILIAL BETWEEN '  ' AND 'ZZ'
									AND ZOD.ZOD_VERSAO= %exp:cVersao%
									AND ZOD.ZOD_REVISA= %exp:cRevisa%
									AND ZOD.ZOD_ANOREF= %exp:cAnoRef%
									AND ZOD.ZOD_TIPO  = %exp:cTipoRef% /*1=Real;2=Orçado;3=Projetado*/
									AND ZOD.ZOD_CONTA BETWEEN '11201' AND '11201ZZZZZZ'
						GROUP BY
								ZOD.ZOD_VERSAO
								, ZOD.ZOD_REVISA
								, ZOD.ZOD_ANOREF
				)
				, TOTAL AS
				(
						SELECT
							'SALDO INICIAL' AS TIPO
							,'SALDO ANT'      as Descricao
							, SA.Valores
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES01
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES01
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES02
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES02
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES03
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES03
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES04
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES04
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES05
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES05
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES06
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES06
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES07
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES07
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES08
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES08
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES09
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES09
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES10
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES10
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES11
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES11
							,( SA.Valores*ISNULL(
								(
									SELECT
											ZOE.ZOE_MES12
									FROM
											%table:ZOE% ZOE
									WHERE
											ZOE.%notDel%
											AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
											AND ZOE.ZOE_VARIAV='yPercRecSaldoAnterior'
											AND ZOE.ZOE_VERSAO= %exp:cVersao%
											AND ZOE.ZOE_REVISA= %exp:cRevisa%
											AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
								)
								,0) ) AS ZOF_MES12
						FROM
								SALDOANTERIOR SA
						UNION ALL
						SELECT
								'RECEBIMENTOS' AS TIPO
								,
								(
										CASE RIGHT(PERIODO,2)
													WHEN '01'
															THEN 'ZOF_MES01'
													WHEN '02'
															THEN 'ZOF_MES02'
													WHEN '03'
															THEN 'ZOF_MES03'
													WHEN '04'
															THEN 'ZOF_MES04'
													WHEN '05'
															THEN 'ZOF_MES05'
													WHEN '06'
															THEN 'ZOF_MES06'
													WHEN '07'
															THEN 'ZOF_MES07'
													WHEN '08'
															THEN 'ZOF_MES08'
													WHEN '09'
															THEN 'ZOF_MES09'
													WHEN '10'
															THEN 'ZOF_MES10'
													WHEN '11'
															THEN 'ZOF_MES11'
													WHEN '12'
															THEN 'ZOF_MES12'
										END
								)
											AS Descricao
								, SUM(VALOR)    VALOR
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='01'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES01
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES01
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='02'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES02
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES02
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='03'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES03
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES03
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='04'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES04
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES04
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='05'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES05
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES05
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='06'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES06
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES06
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='07'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES07
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES07
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='08'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES08
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES08
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='09'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES09
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES09
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='10'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES10
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES10
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='11'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES11
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES11
								, SUM(VALOR)*
										(
													CASE
															WHEN RIGHT(PERIODO,2)>='12'
																	THEN 0
																	ELSE ISNULL(
																	(
																			SELECT
																					ZOE.ZOE_MES12
																			FROM
																					%table:ZOE% ZOE
																			WHERE
																					ZOE.%notDel%
																					AND ZOE.ZOE_FILIAL BETWEEN '  ' AND 'ZZ'
																					AND ZOE.ZOE_VARIAV='yPercAplcMesesOrca'
																					AND ZOE.ZOE_VERSAO= %exp:cVersao%
																					AND ZOE.ZOE_REVISA= %exp:cRevisa%
																					AND ZOE.ZOE_ANOREF= %exp:cAnoRef%
																	)
																	,0)
													END
										)
								AS ZOF_MES12
						FROM
								RECEITA
						GROUP BY
								PERIODO
				)
				, RESUMO AS
				(
						SELECT
								'01' ZOF_INDICA /*SALDO INICIAL*/
							, (
									SELECT
											t.Valores
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES01'
							, (
									SELECT
											t.ZOF_MES01
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES02'
							, (
									SELECT
											t.ZOF_MES02
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES03'
							, (
									SELECT
											t.ZOF_MES03
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES04'
							, (
									SELECT
											t.ZOF_MES04
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES05'
							, (
									SELECT
											t.ZOF_MES05
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES06'
							, (
									SELECT
											t.ZOF_MES06
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES07'
							, (
									SELECT
											t.ZOF_MES07
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES08'
							, (
									SELECT
											t.ZOF_MES08
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES09'
							, (
									SELECT
											t.ZOF_MES09
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES10'
							, (
									SELECT
											t.ZOF_MES10
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES11'
							, (
									SELECT
											t.ZOF_MES11
									FROM
											TOTAL t
									WHERE
											t.TIPO='SALDO INICIAL'
								)
								AS 'ZOF_MES12'
						UNION ALL
						SELECT
								'02' ZOF_INDICA /*RECEBIMENTOS*/
							, (
									SELECT
											SUM(t.ZOF_MES01)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES01'
							, (
									SELECT
											SUM(t.ZOF_MES02)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES02'
							, (
									SELECT
											SUM(t.ZOF_MES03)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES03'
							, (
									SELECT
											SUM(t.ZOF_MES04)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES04'
							, (
									SELECT
											SUM(t.ZOF_MES05)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES05'
							, (
									SELECT
											SUM(t.ZOF_MES06)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES06'
							, (
									SELECT
											SUM(t.ZOF_MES07)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES07'
							, (
									SELECT
											SUM(t.ZOF_MES08)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES08'
							, (
									SELECT
											SUM(t.ZOF_MES09)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES09'
							, (
									SELECT
											SUM(t.ZOF_MES10)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES10'
							, (
									SELECT
											SUM(t.ZOF_MES11)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES11'
							, (
									SELECT
											SUM(t.ZOF_MES12)
									FROM
											TOTAL t
									WHERE
											t.TIPO='RECEBIMENTOS'
								)
								AS 'ZOF_MES12'
						UNION ALL
						SELECT
								'03' ZOF_INDICA /*VENDAS*/
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES01'
								)
								AS 'ZOF_MES01'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES02'
								)
								AS 'ZOF_MES02'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES03'
								)
								AS 'ZOF_MES03'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES04'
								)
								AS 'ZOF_MES04'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES05'
								)
								AS 'ZOF_MES05'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES06'
								)
								AS 'ZOF_MES06'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES07'
								)
								AS 'ZOF_MES07'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES08'
								)
								AS 'ZOF_MES08'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES09'
								)
								AS 'ZOF_MES09'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES10'
								)
								AS 'ZOF_MES10'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES11'
								)
								AS 'ZOF_MES11'
							, (
									SELECT
											(t.Valores)
									FROM
											TOTAL t
									WHERE
											t.TIPO         ='RECEBIMENTOS'
											AND t.Descricao='ZOF_MES12'
								)
								AS 'ZOF_MES12'
				)
			SELECT * INTO %exp:cTmp_Resumo% FROM RESUMO

		endsql

	end sequence
	ErrorBlock(bErrorBlock)

	cSQLQuery:=getLastQuery()[2]

	if (dirtools():MakeDir(cSQLPath))
		cSQLFile:=cSQLPath
		cSQLFile+=ProcName()
		cSQLFile+="_"
		cSQLFile+=DtoS(Date())
		cSQLFile+="_"
		cSQLFile+=StrTran(Time(),":","")
		cSQLFile+="_"
		cSQLFile+=StrTran(cValtoChar(Seconds()),".","")
		cSQLFile+=".sql"
		memoWrite(cSQLFile,cSQLQuery)
	endif

	TCSQLExec(cSQLQuery)

	if (select(cAlias)>0)
		(cAlias)->(dbCloseArea)
	endif

	beginSQL Alias cAlias

		%noparser%

		WITH ZOF_MES01 AS (
					(SELECT SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES01]) ELSE r.[ZOF_MES01] END)) AS 'ZOF_MES01' FROM %exp:cTmp_Resumo% r) 
				)  
			,ZOF_MES02 AS (
					(SELECT (SELECT ZOF_MES01 FROM ZOF_MES01)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES02]) WHEN '01' THEN 0 ELSE r.[ZOF_MES02] END)) AS 'ZOF_MES02' FROM %exp:cTmp_Resumo% r)
			)
			,ZOF_MES03 AS (
					(SELECT (SELECT ZOF_MES02 FROM ZOF_MES02)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES03]) WHEN '01' THEN 0 ELSE r.[ZOF_MES03] END)) AS 'ZOF_MES03' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES04 AS (
					(SELECT (SELECT ZOF_MES03 FROM ZOF_MES03)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES04]) WHEN '01' THEN 0 ELSE r.[ZOF_MES04] END)) AS 'ZOF_MES04' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES05 AS (
					(SELECT (SELECT ZOF_MES04 FROM ZOF_MES04)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES05]) WHEN '01' THEN 0 ELSE r.[ZOF_MES05] END)) AS 'ZOF_MES05' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES06 AS (
					(SELECT (SELECT ZOF_MES05 FROM ZOF_MES05)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES06]) WHEN '01' THEN 0 ELSE r.[ZOF_MES06] END)) AS 'ZOF_MES06' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES07 AS (
					(SELECT (SELECT ZOF_MES06 FROM ZOF_MES06)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES07]) WHEN '01' THEN 0 ELSE r.[ZOF_MES07] END)) AS 'ZOF_MES07' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES08 AS (
					(SELECT (SELECT ZOF_MES07 FROM ZOF_MES07)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES08]) WHEN '01' THEN 0 ELSE r.[ZOF_MES08] END)) AS 'ZOF_MES08' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES09 AS (
					(SELECT (SELECT ZOF_MES08 FROM ZOF_MES08)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES09]) WHEN '01' THEN 0 ELSE r.[ZOF_MES09] END)) AS 'ZOF_MES09' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES10 AS (
					(SELECT (SELECT ZOF_MES09 FROM ZOF_MES09)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES10]) WHEN '01' THEN 0 ELSE r.[ZOF_MES10] END)) AS 'ZOF_MES10' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES11 AS (
					(SELECT (SELECT ZOF_MES10 FROM ZOF_MES10)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES11]) WHEN '01' THEN 0 ELSE r.[ZOF_MES11] END)) AS 'ZOF_MES11' FROM %exp:cTmp_Resumo% r) 
			)
			,ZOF_MES12 AS (
					(SELECT (SELECT ZOF_MES11 FROM ZOF_MES11)+SUM((CASE r.ZOF_INDICA WHEN '03' THEN -(r.[ZOF_MES12]) WHEN '01' THEN 0 ELSE r.[ZOF_MES12] END)) AS 'ZOF_MES12' FROM %exp:cTmp_Resumo% r) 
			)
		SELECT '01' ZOF_INDICA /*SALDO INICIAL*/
				,(SELECT r.ZOF_MES01 FROM %exp:cTmp_Resumo% r WHERE r.ZOF_INDICA='01') ZOF_MES01
				,(SELECT ZOF_MES01 FROM ZOF_MES01) ZOF_MES02
				,(SELECT ZOF_MES02 FROM ZOF_MES02) ZOF_MES03
				,(SELECT ZOF_MES03 FROM ZOF_MES03) ZOF_MES04
				,(SELECT ZOF_MES04 FROM ZOF_MES04) ZOF_MES05
				,(SELECT ZOF_MES05 FROM ZOF_MES05) ZOF_MES06
				,(SELECT ZOF_MES06 FROM ZOF_MES06) ZOF_MES07
				,(SELECT ZOF_MES07 FROM ZOF_MES07) ZOF_MES08
				,(SELECT ZOF_MES08 FROM ZOF_MES08) ZOF_MES09
				,(SELECT ZOF_MES09 FROM ZOF_MES09) ZOF_MES10
				,(SELECT ZOF_MES10 FROM ZOF_MES10) ZOF_MES11
				,(SELECT ZOF_MES11 FROM ZOF_MES11) ZOF_MES12
		UNION ALL
		SELECT * FROM %exp:cTmp_Resumo% r WHERE r.ZOF_INDICA<>'01'
		UNION ALL
		SELECT '04' ZOF_INDICA /*SALDO FINAL*/
			,(SELECT ZOF_MES01 FROM ZOF_MES01) ZOF_MES01
			,(SELECT ZOF_MES02 FROM ZOF_MES02) ZOF_MES02
			,(SELECT ZOF_MES03 FROM ZOF_MES03) ZOF_MES03
			,(SELECT ZOF_MES04 FROM ZOF_MES04) ZOF_MES04
			,(SELECT ZOF_MES05 FROM ZOF_MES05) ZOF_MES05
			,(SELECT ZOF_MES06 FROM ZOF_MES06) ZOF_MES06
			,(SELECT ZOF_MES07 FROM ZOF_MES07) ZOF_MES07
			,(SELECT ZOF_MES08 FROM ZOF_MES08) ZOF_MES08
			,(SELECT ZOF_MES09 FROM ZOF_MES09) ZOF_MES09
			,(SELECT ZOF_MES10 FROM ZOF_MES10) ZOF_MES10
			,(SELECT ZOF_MES11 FROM ZOF_MES11) ZOF_MES11
			,(SELECT ZOF_MES12 FROM ZOF_MES12) ZOF_MES12
		ORDER BY ZOF_INDICA

	endsql

	cSQLQuery:=getLastQuery()[2]

	if (dirtools():MakeDir(cSQLPath))
		cSQLFile:=cSQLPath
		cSQLFile+=ProcName()
		cSQLFile+="_"
		cSQLFile+=DtoS(Date())
		cSQLFile+="_"
		cSQLFile+=StrTran(Time(),":","")
		cSQLFile+="_"
		cSQLFile+=StrTran(cValtoChar(Seconds()),".","")
		cSQLFile+=".sql"
		memoWrite(cSQLFile,cSQLQuery)
	endif

	return(cAlias)

static procedure __break(oError as object,cMsg as character,cEmp as character,cFil as character)

	local cCRLF as character

	cCRLF:=CRLF

	if (valtype(oError)=="O")
		cMsg:="Problemas no processamento. Empresa:["+cEmp+"] :: Filial:["+cFil+"]"
		cMsg+=cCRLF
		cMsg+=oError:Description
		cMsg+=cCRLF
		cMsg+=oError:ErrorStack
		cMsg+=cCRLF
		cMsg+=oError:ErrorEnv
	endif

	break

	return
