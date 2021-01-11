#include "totvs.ch"
function u_BIA27673(aSchedParameter) as logical
    
    local bError        as block
    local bErrorBlock   as block
    
    local cEmp          as character
    local cFil          as character
    local cFWLogMsg     as character

    local dDate         as date
    local dRefe         as date
    
    local lRet          as logical
    local lIsBlind      as logical
    local lCentury      as logical
    
    lIsBlind:=isBlind()
    lCentury:=__SetCentury("ON")
    If (lIsBlind)
        RpcSetType(3)
        if (valtype(aSchedParameter)=="A")
            cEmp:=aSchedParameter[1]
            cFil:=aSchedParameter[2]
        else
            cEmp:="01"
            cFil:="01"
        endif    
        cFWLogMsg:="INICIO: "+cEmp+"/"+cFil+" :: "+DToC(date())+" :: "+Time()
        FWLogMsg("MSG",NIL,"BIA27673","SCHEDULE","0","1",cFWLogMsg,1,0,{})
        RpcSetEnv(cEmp,cFil)
    endif
    private cCadastro:="RELATORIO DE BALANCA"
    begin sequence
        if (!Pergunte("UBIA27673",(!lIsBlind)))
            if (!lIsBlind)
                lRet:=.F.
                break
            endif
        endif
        dDate:=date()
        dRefe:=(dDate-1)
        if (lIsBlind)
            bError:={|e|Break(e)}
            bErrorBlock:=ErrorBlock(bError)
            begin sequence
                &("MV_PAR01"):=Formula("RCI")
                dDate:=&("MV_PAR01")
            recover
                &("MV_PAR01"):=FirstDate(dRefe)
                dDate:=&("MV_PAR01")
            end sequence
            ErrorBlock(bErrorBlock)
            if (empty(&("MV_PAR01")))
                &("MV_PAR01"):=FirstDate(dRefe)
                &("MV_PAR02"):=dRefe
            else
                bErrorBlock:=ErrorBlock(bError)
                begin sequence
                    &("MV_PAR02"):=Formula("RCF")
                    dRefe:=&("MV_PAR02")
                recover
                    &("MV_PAR02"):=dRefe
                end sequence
                ErrorBlock(bErrorBlock)
                if (empty(&("MV_PAR02")))
                    &("MV_PAR02"):=dRefe
                endif
            endif
        else
            dRefe:=&("MV_PAR02")
        endif
        if (!(valType(dDate)=="D"))
            dDate:=FirstDate(Date())
            &("MV_PAR01"):=dDate
        endif
        if (!(valType(dRefe)=="D"))
            dRefe:=(Date()-1)
            &("MV_PAR02"):=dRefe
        endif
        private c_pExcelTitle as character
        c_pExcelTitle:=" :: Emissao: "
        c_pExcelTitle+=strTran(DtoC(Date()),"/","-")
        c_pExcelTitle+=" :: "
        c_pExcelTitle+=Time()
        c_pExcelTitle+=" :: "
        c_pExcelTitle+="Ref: "
        c_pExcelTitle+=strTran(DtoC(dRefe),"/","-")
        If (lIsBlind)
            cFWLogMsg:="PROCESSANDO: "+cEmp+"/"+cFil+" :: "+DToC(date())+" :: "+Time()
            FWLogMsg("MSG",NIL,"BIA27673","SCHEDULE","0","2",cFWLogMsg,1,0,{})
        endif
        MsAguarde({||lRet:=BIA27673()},"Aguarde...",cCadastro)
    end sequence
    __SetCentury(if(lCentury,"ON","OFF"))
    If (lIsBlind)
        RpcClearEnv()
        cFWLogMsg:="FINAL: "+cEmp+"/"+cFil+" :: "+DToC(date())+" :: "+Time()
        FWLogMsg("MSG",NIL,"BIA27673","SCHEDULE","0","3",cFWLogMsg,1,0,{})
    endif
    return(lRet)

static function BIA27673() as logical

    local cFile         as character
    local cQuery        as character
    local cServerIP     as character
    local cFWLogMsg     as character
    local cEnvServer    as character
    local cExcelTitle   as character
    
    local lRet          as logical
    local lDev          as logical
    local lPicture      as logical
    local lX3Titulo     as logical
    local leecView      as logical

    local nAttempts     as numeric

    begin sequence

        nAttempts:=0
        while (!(lRet:=lIsDir("\tmp\")))
            if ((nAttempts++)>10)
                exit
            endif
            makeDir("\tmp\")
        end while

        if (!lRet)
            cFWLogMsg:="Unable to Create \tmp\ path in server"
            FWLogMsg("ERROR",NIL,"BIA27673","ERROR","0","0",cFWLogMsg,1,0,{})
            Break
        endif

        cFile:="\tmp\"
        cFile+=ProcName()
        cFile+="_"
        cFile+=DtoS(Date())
        cFile+="_"
        cFile+=StrTran(Time(),":","_")
        cFile+="_"
        cFile+=cValtoChar(Seconds())
        cFile+=".xml"
        cExcelTitle:=&("cCadastro")
        cServerIP:=getServerIP()
        cEnvServer:=upper(getEnvServer())
        lDev:=((cServerIP=="192.168.20.18").or.("DEV"$cEnvServer))
        if (lDev)
            cExcelTitle+=" :: EMITIDO EM AMBIENTE DE DESENVOLVIMENTO ::"    
        endif

        lPicture:=.F.
        lX3Titulo:=.T.
        leecView:=.F.

        cQuery:=getQuery(if(lDev,15,2))

        lRet:=u_QryToXML(@cQuery,@cFile,@cExcelTitle,@lPicture,@lX3Titulo,@leecView)
        
        if (!lRet)
            break
        endif
        
        lRet:=file(cFile)
        
        if (!lRet)
            break
        endif

        if ((lDev).or.isBlind())
            lRet:=sendMail(cFile,lDev)
            if (file(cFile))
                fErase(cFile)
            endif
        endif

    end squence

    return(lRet)

static function getQuery(nDays as numeric) as character

    local cDays     as character
    local cAlias    as character
    local cQuery    as character
    local cDataIni  as character
    local cDataFim  as character
    local cDataSub  as character
    local cQryPath  as character
    local cQryFile  as character

    local nAttempts as numeric

    cDataIni:=&("MV_PAR01")
    cDataFim:=&("MV_PAR02")
    cDataSub:=DtoS(Date()-nDays)

    cDays:=lTrim(str(nDays))
    cDays:="%"+cDays+"%"

    cAlias:=getNextAlias()
    beginsql alias cAlias
        %noparser%
        SELECT 1 FROM (
                        SELECT DISTINCT
                             ZZV.ZZV_CARGA
                            ,OCORRENCIA_ECOSIS=FAT.FORD_NUMERO
                            ,F2_DOC
                            ,SF2.F2_EMISSAO
                            ,SB1.B1_COD
                            ,SB1.B1_DESC
                            ,OPERADORES=(
                                        SELECT CAST(
                                            STUFF(
                                                        (   SELECT CHAR(59)+CONVERT(
                                                                                    NVARCHAR(20),
                                                                                    Lower(ISNULL(
                                                                                        (
                                                                                        SELECT TOP 1 W.NOME FROM COLETOR_USUARIOS (NOLOCK) W
                                                                                                WHERE W.CODIGO COLLATE LATIN1_GENERAL_BIN=A.CTM_USUARIO
                                                                                        ),A.CTM_USUARIO))
                                                                                    )
                                                            FROM (SELECT DISTINCT Y.CTM_USUARIO  FROM DADOSEOS.DBO.CEP_TRANSA_MOVTO (NOLOCK) Y
                                                                                        WHERE Y.CTM_NUM_DOCTO IN (
                                                                            SELECT X.FORD_NUMERO
                                                                                FROM DADOSEOS.DBO.FAT_ORDEM_FATURAMENTO X (NOLOCK)
                                                                                WHERE X.FORD_NUMERO=FAT.FORD_NUMERO
                                                                                        )
                                                                                        AND Y.CTM_USUARIO IS NOT NULL
                                                                                        /*--ORDER BY Y.CTM_NUM_DOCTO,Y.ID_TRANSA_MOVTO*/
                                                                                    ) A
                                                            FOR XML PATH('')
                                                        )
                                                        ,1
                                                        ,1
                                                        ,''
                                                    )
                                                AS VARCHAR(8000))
                                            )
                        FROM %table:ZZV% ZZV (NOLOCK)
                        INNER JOIN %table:SF2% SF2 (NOLOCK)
                            ON SF2.F2_FILIAL=%xFilial:SF2%
                           AND ZZV.ZZV_CARGA=SUBSTRING(SF2.F2_YAGREG,5,4)
                           AND SF2.%NotDel%
                        INNER JOIN %table:SD2% SD2 (NOLOCK)
                                ON SF2.F2_FILIAL=SD2.D2_FILIAL
                               AND SF2.F2_DOC=SD2.D2_DOC
                               AND SF2.F2_SERIE=SD2.D2_SERIE
                               AND SF2.F2_CLIENTE=SD2.D2_CLIENTE
                               AND SF2.F2_LOJA=SD2.D2_LOJA
                               AND SF2.%NotDel%
                               AND SD2.%NotDel%
                        INNER JOIN %table:SB1% SB1 (NOLOCK)
                                 ON SB1.B1_FILIAL=%xFilial:SB1%
                                AND SD2.D2_COD=SB1.B1_COD
                                AND SD2.%NotDel%
                                AND SB1.%NotDel%
                        INNER JOIN DADOSEOS.DBO.FAT_ORDEM_FATURAMENTO FAT (NOLOCK)
                            ON ZZV.ZZV_CARGA COLLATE LATIN1_GENERAL_BIN=FAT.FORD_NUM_CARGA
                           AND FAT.FORD_CANCELADA=0
                           AND ((CASE WHEN FORD_DATA_FINALIZADO IS NOT NULL THEN 1 ELSE 0 END)=0)
                        INNER JOIN DADOSEOS.DBO.FAT_ITENS_ORDEM FATITEMS (NOLOCK)
                            ON FATITEMS.FORD_NUMERO=FAT.FORD_NUMERO
                           AND (
                                    (ISNULL(FATITEMS.IORD_CX_PALLET,0)=0)
                                    OR (
                                            (ISNULL(FATITEMS.IORD_QTDADE_BAIXADA,0)<>ISNULL(FATITEMS.IORD_QTDADE,0))
                                        AND ((ISNULL(FATITEMS.IORD_QTDADE_BAIXADA,0)+ISNULL(FATITEMS.IORD_QTDADE_CANCELADA,0))<>ISNULL(FATITEMS.IORD_QTDADE,0))
                                    )
                           )                                                
                        WHERE (1=2) 
                          AND ZZV.%NotDel%
                          AND ZZV.ZZV_FILIAL=%xFilial:ZZV%
                          AND SD2.D2_COD COLLATE LATIN1_GENERAL_BIN=FATITEMS.COD_PRODUTO
                          AND ((SF2.F2_EMISSAO BETWEEN %exp:cDataIni% AND %exp:cDataFim%) OR (SF2.F2_EMISSAO>=%exp:cDataSub%) OR (CONVERT(DATE,SF2.F2_EMISSAO)>=CONVERT(DATE,GETDATE()-%exp:cDays%)))
        ) t
    endsql

    (cAlias)->(dbCloseArea())

    cQuery:=GetLastQuery()[2]
    cQuery:=strTran(cQuery,"SELECT 1","SELECT *")
    cQuery:=strTran(cQuery,"1=2","1=1")

    if (IsBlind())
        cQryPath:="\tmp\"
        nAttempts:=0
        while (!lIsDir(cQryPath))
            if ((nAttempts++)>10)
                exit
            endif
            makeDir(cQryPath)
        end while
    else
        cQryPath:=getTempPath()
    endif

    if (lIsDir(cQryPath))
        cQryFile:="BIA27673-"
        cQryFile+=DToS(Date())
        cQryFile+="-"
        cQryFile+=StrTran(Time(),":","-")
        cQryFile+="-"
        cQryFile+=cValToChar(Seconds())
        cQryFile+=".sql"
        memoWrite((cQryPath+cQryFile),cQuery)
    endif

    return(cQuery)

static function sendMail(cFile as character,lDev as logical) as logical

    local cTo       as character
	local cBody     as character
    local cSubject  as character
	local cFWLogMsg as character

	local lRet      as logical

	cSubject:="BIA27673 :: "
    cSubject+="RELATORIO DE BALANCA"
    cSubject+=" :: Emissao: "
    cSubject+=DtoC(msDate())
    cSubject+=" :: "+Time()
    cSubject+=" :: Referencia: "
    cSubject+=DtoC(msDate()-1)

    cBody:="Segue, anexo,"
    cBody+=" "
    cBody+=cSubject
	
	if (lDev)
        cTo:="marinaldo.jesus@facilesistemas.com.br"
	else
        cTo:=u_emailWF("BIA27673",&("cEmpAnt"))
    endif

	cFWLogMsg:="BIA27673 Enviando e-mail para: "
    cFWLogMsg+=cTo
    FWLogMsg("MSG",NIL,"BIA27673","INFO","1","1",cFWLogMsg,1,0,{})
    cFWLogMsg:=cSubject
    FWLogMsg("MSG",NIL,"BIA27673","INFO","1","2",cFWLogMsg,1,0,{})
    lRet:=u_BIAEnvMail(nil,cTo,cSubject,cBody,nil,cFile)
    if (lRet)
        cFWLogMsg:="BIA27673 e-mail enviado com sucesso para: "
        cFWLogMsg+=cTo
        FWLogMsg("MSG",NIL,"BIA27673","INFO","1","3",cFWLogMsg,1,0,{})
    else
        cFWLogMsg:="BIA27673 problemas no envio de e-mail para: "
        cFWLogMsg+=cTo
        FWLogMsg("WARNIG",NIL,"BIA27673","ERROR","1","4",cFWLogMsg,1,0,{})
    endif

    return(lRet)
