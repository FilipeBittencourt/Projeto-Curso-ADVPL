#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//U_A53TST00
User Function A53TST00()

	Local  oObjMain := nIL

	If Select("SX6") == 0
		RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
	EndIf

	oObjMain := TClassA53TST00():New()
	oObjMain:Start()


RETURN


	Class TClassA53TST00 From LongClassName

		Public  Method New() Constructor
		Public  Method Start()
		Public  Method PegaInformacoesUserCLVL()
		Public  Method Insert(oJSON)

	EndClass

Method New() Class TClassA53TST00
Return(Self)

Method Start() Class TClassA53TST00

	Local nI       := 1
	Local cSql     := ""
	Local cMsg     := ""
	Local oObjMain := Nil
	Local aCLVL    := {}
	Local aAPROV   := {}
	Local cQry     := GetNextAlias()
	Local cTime     := DTOS(Date())
	Local oJSCLVL  := Nil

	//Local cTime2    := FwTimeStamp()
	//cTime2  := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s

	cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)

	cSql += " select top 100 " +CRLF
	cSql += "   SUBSTRING ( CTH_YEMPFL ,1 , 2) AS EMPRESA " +CRLF
	cSql += " , SUBSTRING ( CTH_YEMPFL ,3 , 4) AS FILIAL " +CRLF
	cSql += " , CTH_CLVL    AS CLVL            " +CRLF
	cSql += " , CTH_CLASSE  AS CLASSE_TIPO     " +CRLF
	cSql += " , CTH_DESC01  AS DESCRCLVL       " +CRLF
	cSql += " , CTH_YCAPPR  AS CATEGORIAPPR    " +CRLF // -- Analisar valor default
	cSql += " , CTH_YCRIT   AS CRITERIOCUSTO   " +CRLF // -- Analisar valor default
	cSql += " , CTH_YQUADR  AS QUADRORH        " +CRLF // -- Analisar valor default
	cSql += " , CTH_YUN     AS UN              " +CRLF
	cSql += " , CTH_YCC	    AS CC              " +CRLF
	cSql += " , CTH_YAPLCT  AS APLICACUSTO     " +CRLF
	cSql += " , CTH_YCTRTG  AS CONTROLATAG     " +CRLF
	cSql += " , CTH_YATRIB  AS ATRIBUICONTA    " +CRLF
	cSql += " , CTH_YCLVLG  AS CLVLGMCD        " +CRLF
	cSql += " , CTH_YENTID  AS ENTIDADEGMCD    " +CRLF
	cSql += " , CTH_YSETOR  AS SETORGMCD       " +CRLF
	cSql += " , R_E_C_N_O_  AS RECNO           " +CRLF

	cSql += " FROM CTH010
	cSql += "  where CTH_YEMPFL <> ''          " +CRLF
	cSql += " and D_E_L_E_T_ = ''              " +CRLF

	cSql += " ORDER BY CTH_CLVL, R_E_C_N_O_ DESC "


	TcQuery cSql New Alias (cQry)

	While (cQry)->(!EOF())

		AADD(aCLVL,   JsonObject():New())
		aCLVL[Len(aCLVL)]["EMPRESA"]       :=  (cQry)->EMPRESA
		aCLVL[Len(aCLVL)]["FILIAL"]        :=  (cQry)->FILIAL
		aCLVL[Len(aCLVL)]["CLVL"]          :=  (cQry)->CLVL
		aCLVL[Len(aCLVL)]["CLASSE_TIPO"]   :=  (cQry)->CLASSE_TIPO
		aCLVL[Len(aCLVL)]["DESCRCLVL"]     :=  (cQry)->DESCRCLVL
		aCLVL[Len(aCLVL)]["CATEGORIAPPR"]  :=  (cQry)->CATEGORIAPPR
		aCLVL[Len(aCLVL)]["CRITERIOCUSTO"] :=  (cQry)->CRITERIOCUSTO
		aCLVL[Len(aCLVL)]["QUADRORH"]      :=  (cQry)->QUADRORH
		aCLVL[Len(aCLVL)]["UN"]            :=  (cQry)->UN
		aCLVL[Len(aCLVL)]["CC"]            :=  (cQry)->CC
		aCLVL[Len(aCLVL)]["APLICACUSTO"]   :=  (cQry)->APLICACUSTO
		aCLVL[Len(aCLVL)]["CONTROLATAG"]   :=  (cQry)->CONTROLATAG
		aCLVL[Len(aCLVL)]["ATRIBUICONTA"]  :=  (cQry)->ATRIBUICONTA
		aCLVL[Len(aCLVL)]["CLVLGMCD"]      :=  (cQry)->CLVLGMCD
		aCLVL[Len(aCLVL)]["ENTIDADEGMCD"]  :=  (cQry)->ENTIDADEGMCD
		aCLVL[Len(aCLVL)]["SETORGMCD"]     :=  (cQry)->SETORGMCD

		aCLVL[Len(aCLVL)]["DRIVER"]         := "DRIVER"
		aCLVL[Len(aCLVL)]["VALMIN"]         := 100
		aCLVL[Len(aCLVL)]["VALMAX"]         := 1000

		//
		oJSCLVL  :=    JsonObject():New()
		oJSCLVL  :=  ::PegaInformacoesUserCLVL((cQry)->CLVL)
		aCLVL[Len(aCLVL)]["CODIGOAPROVADOR"]      := oJSCLVL["CODIGOAPROVADOR"]
		aCLVL[Len(aCLVL)]["IDUSERAPROVADOR"]      := oJSCLVL["IDUSERAPROVADOR"]
		aCLVL[Len(aCLVL)]["APROVADORTEMP"]        := oJSCLVL["APROVADORTEMP"]
		aCLVL[Len(aCLVL)]["IDUSERAPROVADORTEMP"]  := oJSCLVL["IDUSERAPROVADORTEMP"]
		aCLVL[Len(aCLVL)]["LOGINAPROVADOR"]       := oJSCLVL["LOGINAPROVADOR"]
		aCLVL[Len(aCLVL)]["CODIGOPERFIL"]         := oJSCLVL["CODIGOPERFIL"]




		//CONTROLE
		aCLVL[Len(aCLVL)]["BZNUMPROC"]       :=  "ALC-"+PADL(cValToChar((cQry)->RECNO),6,"0")
		aCLVL[Len(aCLVL)]["BZGUID"]          :=  FWUUIDV1()
		aCLVL[Len(aCLVL)]["STATUS"]          :=  'A'
		aCLVL[Len(aCLVL)]["BZDTINTEGRACAO"]  :=  cTime+" "+Time()
		aCLVL[Len(aCLVL)]["LOG"]             :=  ''
		aCLVL[Len(aCLVL)]["DTINTEGRA"]       :=  ''
		aCLVL[Len(aCLVL)]["HRINTEGRA"]       :=  ''

		(cQry)->(DbSkip())

	EndDo

	oObjMain := JsonObject():New()
	oObjMain["CLASSE"] := aCLVL
	::Insert(oObjMain)

Return


Method PegaInformacoesUserCLVL(cCLVL) Class TClassA53TST00

	Local cSQL      := ""
	Local cQryII    := GetNextAlias()
	Local oObjCLVL  := JsonObject():New()

	cSQL += "  SELECT TOP 1 "+CRLF
	cSQL += "    SAL.AL_APROV    AS CODIGOAPROVADOR "+CRLF
	cSQL += "  , SAL.AL_USER     AS IDUSERAPROVADOR "+CRLF
	cSQL += "  , SAL.AL_APROSUP  AS APROVADORTEMP "+CRLF
	cSQL += "  , SAL.AL_USERSUP  AS IDUSERAPROVADORTEMP --ADD NA TABELA "+CRLF
	cSQL += "  , SAK.AK_LOGIN    AS LOGINAPROVADOR "+CRLF
	cSQL += "  , SAL.AL_PERFIL   AS CODIGOPERFIL "+CRLF

	cSQL += "  FROM SAL010 SAL "+CRLF

	cSQL += " INNER JOIN SAK010 SAK ON SAL.AL_APROV = SAK.AK_COD "+CRLF

	cSQL += " WHERE SAL.D_E_L_E_T_ =  ''

	cSQL += " AND   SAL.AL_YCLVL = '"+cCLVL+"' ORDER BY SAL.R_E_C_N_O_ DESC "+CRLF

	TcQuery cSql New Alias (cQryII)

	If (cQryII)->(!EOF())

		oObjCLVL["CODIGOAPROVADOR"]     := IIF( EMPTY( (cQryII)->CODIGOAPROVADOR ),"", (cQryII)->CODIGOAPROVADOR )
		oObjCLVL["IDUSERAPROVADOR"]     := IIF( EMPTY( (cQryII)->IDUSERAPROVADOR ),"", (cQryII)->IDUSERAPROVADOR )
		oObjCLVL["APROVADORTEMP"]       := IIF( EMPTY( (cQryII)->APROVADORTEMP ),"", (cQryII)->APROVADORTEMP )
		oObjCLVL["IDUSERAPROVADORTEMP"] := IIF( EMPTY( (cQryII)->IDUSERAPROVADORTEMP ),"", (cQryII)->IDUSERAPROVADORTEMP )
		oObjCLVL["LOGINAPROVADOR"]      := IIF( EMPTY( (cQryII)->LOGINAPROVADOR ),"", (cQryII)->LOGINAPROVADOR )
		oObjCLVL["CODIGOPERFIL"]        := IIF( EMPTY( (cQryII)->CODIGOPERFIL ),"", (cQryII)->CODIGOPERFIL )
	Else
		oObjCLVL["CODIGOAPROVADOR"]     := ""
		oObjCLVL["IDUSERAPROVADOR"]     := ""
		oObjCLVL["APROVADORTEMP"]       := ""
		oObjCLVL["IDUSERAPROVADORTEMP"] := ""
		oObjCLVL["LOGINAPROVADOR"]      := ""
		oObjCLVL["CODIGOPERFIL"]        := ""

	EndIf

Return oObjCLVL


Method Insert(oJSON) Class TClassA53TST00

	Local _cSql := ""
	Local nI := 1
	Local nK := 1
	Local aItens := {}

	For nK := 1 To Len(oJSON["CLASSE"])


		_cSql += " INSERT INTO  [BZINTEGRACAO_CLASSEVALOR] ( "

		_cSql += "   [CV_EMPRESA]          "  + CRLF
		_cSql += "  ,[CV_FILIAL]           "  + CRLF
		_cSql += "  ,[CV_CLVL]             "  + CRLF
		_cSql += "  ,[CV_CLASSE]           "  + CRLF
		_cSql += "  ,[CV_DESCRCLVL]        "  + CRLF
		_cSql += "  ,[CV_CATEGORIAPPR]     "  + CRLF
		_cSql += "  ,[CV_CRITERIOCUSTO]    "  + CRLF
		_cSql += "  ,[CV_QUADRORH]         "  + CRLF
		_cSql += "  ,[CV_UN]               "  + CRLF
		_cSql += "  ,[CV_CC]               "  + CRLF
		_cSql += "  ,[CV_APLICACUSTO]      "  + CRLF
		_cSql += "  ,[CV_CONTROLATAG]      "  + CRLF
		_cSql += "  ,[CV_ATRIBUICONTA]     "  + CRLF
		_cSql += "  ,[CV_CLVLGMCD]         "  + CRLF
		_cSql += "  ,[CV_ENTIDADEGMCD]     "  + CRLF
		_cSql += "  ,[CV_SETORGMCD]        "  + CRLF

		_cSql += "  ,[CV_CODIGOAPROVADOR]  "  + CRLF
		_cSql += "  ,[CV_IDUSERAPROVADOR]  "  + CRLF
		_cSql += "  ,[CV_APROVADORTEMP]    "  + CRLF
		_cSql += "  ,[CV_LOGINAPROVADOR]   "  + CRLF
		_cSql += "  ,[CV_CODIGOPERFIL]     "  + CRLF

		_cSql += "  ,[CV_VALMIN]           "  + CRLF
		_cSql += "  ,[CV_VALMAX]           "  + CRLF

		_cSql += "  ,[CV_DRIVER]       "  + CRLF

		//padrao
		_cSql += "  ,[BZNUMPROC]       "  + CRLF
		_cSql += "  ,[BZGUID]          "  + CRLF
		_cSql += "  ,[STATUS]          "  + CRLF
		_cSql += "  ,[BZDTINTEGRACAO]  "  + CRLF
		_cSql += "  ,[DTINTEGRA]       "  + CRLF
		_cSql += "  ,[HRINTEGRA]       "  + CRLF
		_cSql += "  ,[LOG]             "  + CRLF



		_cSql += ")VALUES( "  + CRLF

		_cSql += "  '"+oJSON["CLASSE"][nK]["EMPRESA"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["FILIAL"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["CLVL"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["CLASSE_TIPO"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["DESCRCLVL"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["CATEGORIAPPR"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["CRITERIOCUSTO"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["QUADRORH"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["UN"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["CC"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["APLICACUSTO"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["CONTROLATAG"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["ATRIBUICONTA"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["CLVLGMCD"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["ENTIDADEGMCD"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["SETORGMCD"]+"'"+ CRLF

		_cSql += " ,'"+oJSON["CLASSE"][nK]["CODIGOAPROVADOR"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["IDUSERAPROVADOR"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["APROVADORTEMP"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["LOGINAPROVADOR"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["CODIGOPERFIL"]+"'"+ CRLF

		_cSql += " , "+cValToChar(oJSON["CLASSE"][nK]["VALMIN"])+""+ CRLF
		_cSql += " , "+cValToChar(oJSON["CLASSE"][nK]["VALMAX"])+""+ CRLF

		_cSql += " ,'"+oJSON["CLASSE"][nK]["DRIVER"]+"'"+ CRLF


		//padrao
		_cSql += " ,'"+oJSON["CLASSE"][nK]["BZNUMPROC"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["BZGUID"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["STATUS"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["BZDTINTEGRACAO"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["DTINTEGRA"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["HRINTEGRA"]+"'"+ CRLF
		_cSql += " ,'"+oJSON["CLASSE"][nK]["LOG"]+"'"+ CRLF



		_cSql += ");" + CRLF

	Next nK

	TcSQLExec(_cSql)

Return




/*
SELECT ID, STATUS, LOG, BZNUMPROC, *  FROM BZINTEGRACAO_CLASSEVALOR  
--WHERE  BZNUMPROC  IN (	'CV-20211145','ALC-000167','ALC-000177') 
 
-- DELETE FROM  SAL010 WHERE AL_DESC  = 'GRUPO 1504'  
-- DELETE FROM  CTH010 WHERE CTH_CLVL = '1504'
-- update BZINTEGRACAO_CLASSEVALOR set STATUS = 'A', LOG = ''

SELECT CTH_CLVL 
 FROM CTH010 (NOLOCK) 
 WHERE CTH_BLOQ != '1' AND D_E_L_E_T_ = '' 
 AND CTH_CLVL = '1504'
 
 SELECT AL_YCLVL 
 FROM SAL010 (NOLOCK) 
 WHERE D_E_L_E_T_ = '' 
 AND AL_YCLVL = '1504' AND AL_MSBLQL <> '1' 

  SELECT  AK_COD, AK_USER 
 FROM SAK010 (NOLOCK) 
 WHERE D_E_L_E_T_ = '' 
 AND AK_COD = '000007' AND AK_USER = '000093' 


 SELECT  DHL_COD 
 FROM DHL010 (NOLOCK) 
 WHERE D_E_L_E_T_ = '' 
 AND   0.01  =   DHL_LIMMIN  
 AND   200000  =   DHL_LIMMAX 
 AND DHL_COD = '000004'

*/






/*






select top 100 
  SUBSTRING ( CTH_YEMPFL ,1 , 2) AS EMPRESA
, SUBSTRING ( CTH_YEMPFL ,3 , 4) AS FILIAL
, CTH_CLVL    AS CLVL
, CTH_CLASSE  AS CLASSE_TIPO
, CTH_DESC01  AS DESCRCLVL
, CTH_YCAPPR  AS CATEGORIAPPR  -- Analisar valor default
, CTH_YCRIT   AS CRITERIOCUSTO -- Analisar valor default
, CTH_YQUADR  AS QUADRORH      -- Analisar valor default
, CTH_YUN     AS UN
, CTH_YCC	  AS CC
, CTH_YAPLCT  AS APLICACUSTO
, CTH_YCTRTG  AS CONTROLATAG
, CTH_YATRIB  AS ATRIBUICONTA
, CTH_YCLVLG  AS CLVLGMCD
, CTH_YENTID  AS ENTIDADEGMCD
, CTH_YSETOR  AS SETORGMCD
, *
from CTH010 ORDER BY R_E_C_N_O_ DESC
 -- VERIFICAR SE EXISTE A CLASSE NA TABELA CTH
 -- SE NÃO EXISTIR NA CTH , GRAVA NA MESMA
 --



SELECT TOP  100  AK_COD AS AL_APROV , AK_USER AS AL_USER , AK_LOGIN AS LOGINAPROVADOR , * FROM SAK010  WHERE D_E_L_E_T_ =  ''

SELECT TOP  100
  AL_APROV    AS CODIGOAPROVADOR
, AL_USER     AS IDUSERAPROVADOR
, AL_APROSUP  AS APROVADORTEMP
, AL_USERSUP  AS IDUSERAPROVADORTEMP --ADD NA TABELA
, 'NOME_USER' AS LOGINAPROVADOR
, AL_PERFIL   AS CODIGOPERFIL
,*
FROM SAL010

/* 

SELECT  * from BZINTEGRACAO_CLASSEVALOR

CREATE TABLE [dbo].[BZINTEGRACAO_CLASSEVALOR](



[ID][int] IDENTITY(1,1) NOT NULL,
[CV_EMPRESA] [varchar](2) NOT NULL,
[CV_FILIAL] [varchar](2) NOT NULL,

[CV_CLVL][varchar](9) NOT NULL,
[CV_CLASSE][varchar](1) NOT NULL,
[CV_DESCRCLVL][varchar](40) NOT NULL,

[CV_CATEGORIAPPR][varchar](1) NOT NULL, --* Analisar valor default
[CV_CRITERIOCUSTO][varchar](3) NOT NULL, --* Analisar valor default
[CV_QUADRORH][varchar](15) NOT NULL, --* Analisar valor default

[CV_UN][varchar](2) NOT NULL, --* Analisar valor default
[CV_CC][varchar](9) NOT NULL,
[CV_APLICACUSTO][varchar](1) NOT NULL,
[CV_CONTROLATAG][varchar](1) NOT NULL,


[CV_ATRIBUICONTA][varchar](1) NOT NULL,
[CV_CLVLGMCD][varchar](4) NOT NULL,
[CV_ENTIDADEGMCD][varchar](4) NOT NULL,
[CV_SETORGMCD][varchar](4) NOT NULL,

[CV_CODIGOAPROVADOR][varchar](6) NOT NULL,
[CV_IDUSERAPROVADOR][varchar](6) NOT NULL,
[CV_APROVADORTEMP][varchar](6) NOT NULL,
[CV_LOGINAPROVADOR][varchar](50) NOT NULL,
[CV_CODIGOPERFIL][varchar](6) NOT NULL,


[CV_VALMIN][float] NOT NULL,
[CV_VALMAX][float] NOT NULL,



--VALIDAR PRIMEIRO ESSE CAMPO A INFORMAÇÃO VINDA DO BIZAGI DRIVER+CLASSE_VALOR SE EXISTEM NA ZBZ NOS SEGUINTES CAMPOS ZBZ_DRVDB+ZBZ_CLVLBD. SE SIM CONTINUA, SE NÃO ERRO DE DRIVE
[CV_DRIVER][varchar](9) NULL,



[BZNUMPROC] [varchar](15) NOT NULL,
[BZGUID] [varchar](50) NOT NULL,
[STATUS] [varchar](1) NOT NULL,
[BZDTINTEGRACAO] [varchar](30) NULL,
[DTINTEGRA] [varchar](8) NULL,
[HRINTEGRA] [varchar](8) NULL,
[LOG] [varchar](max) NULL,



)



ALTER TABLE [dbo].[BZINTEGRACAO_CLASSEVALOR] ADD CONSTRAINT [DF_BZINTEGRACAO_CLASSEVALOR] DEFAULT ('') FOR [BZGUID]




select * from BZINTEGRACAO_CLASSEVALOR
select top 1 CTH_YEMPFL, * from CTH010 ORDER BY R_E_C_N_O_ DESC
select top 1 * from SAL010
select top 1 * from SAK010
select top 1 * from DHL010
select top 1 * from ZBZ010

*/




/*
Method GetNewCodigo() Class TBizagiIntegracaoAlcadaAprovacao

  Local _msDocSZI := ""

  _msDocSZI := GetSxENum("SZI","ZI_DOC")
  SZI->(dbSetOrder(1))
  If SZI->(dbSeek(xFilial("SZI") + _msDocSZI))
    While .T.
      _msDocSZI := GetSxENum("SZI","ZI_DOC")
      SZI->(dbSetOrder(1))
      If !SZI->(dbSeek(xFilial("SZI") + _msDocSZI))
        Exit
      EndIf
    End
  EndIf

Return _msDocSZI

ALTER TABLE BZINTEGRACAO_CLASSEVALOR ALTER COLUMN CV_CLVL [varchar](4)

CREATE TABLE [dbo].[BZINTEGRACAO_CLASSEVALOR](

[ID][int] IDENTITY(1,1) NOT NULL,
[CV_EMPRESA] [varchar](2) NOT NULL,
[CV_FILIAL] [varchar](2) NOT NULL,

[CV_CLVL][varchar](9) NOT NULL,
[CV_CLASSE][varchar](1) NOT NULL,
[CV_DESCRCLVL][varchar](40) NOT NULL,

[CV_CATEGORIAPPR][varchar](1) NOT NULL, --* Analisar valor default
[CV_CRITERIOCUSTO][varchar](3) NOT NULL, --* Analisar valor default
[CV_QUADRORH][varchar](15) NOT NULL, --* Analisar valor default

[CV_UN][varchar](2) NOT NULL, --* Analisar valor default
[CV_CC][varchar](9) NOT NULL,
[CV_APLICACUSTO][varchar](1) NOT NULL,
[CV_CONTROLATAG][varchar](1) NOT NULL,


[CV_ATRIBUICONTA][varchar](1) NOT NULL,
[CV_CLVLGMCD][varchar](4) NOT NULL,
[CV_ENTIDADEGMCD][varchar](4) NOT NULL,
[CV_SETORGMCD][varchar](4) NOT NULL,

[CV_CODIGOAPROVADOR][varchar](6) NOT NULL,
[CV_IDUSERAPROVADOR][varchar](6) NOT NULL,
[CV_APROVADORTEMP][varchar](6) NOT NULL,
[CV_LOGINAPROVADOR][varchar](50) NOT NULL,
[CV_CODIGOPERFIL][varchar](6) NOT NULL,


[CV_VALMIN][float] NOT NULL,
[CV_VALMAX][float] NOT NULL,



--VALIDAR PRIMEIRO ESSE CAMPO A INFORMAÇÃO VINDA DO BIZAGI DRIVER+CLASSE_VALOR SE EXISTEM NA ZBZ NOS SEGUINTES CAMPOS ZBZ_DRVDB+ZBZ_CLVLBD. SE SIM CONTINUA, SE NÃO ERRO DE DRIVE
[CV_DRIVER][varchar](9) NULL,



[BZNUMPROC] [varchar](15) NOT NULL,
[BZGUID] [varchar](50) NOT NULL,
[STATUS] [varchar](1) NOT NULL,
[BZDTINTEGRACAO] [varchar](30) NULL,



[DTINTEGRA] [varchar](8) NULL,
[HRINTEGRA] [varchar](8) NULL,
[LOG] [varchar](max) NULL,



)



ALTER TABLE [dbo].[BZINTEGRACAO_CLASSEVALOR] ADD CONSTRAINT [DF_BZINTEGRACAO_CLASSEVALOR] DEFAULT ('') FOR [BZGUID]




select * from BZINTEGRACAO_CLASSEVALOR
select top 1 CTH_YEMPFL, * from CTH010 ORDER BY R_E_C_N_O_ DESC
select top 1 * from SAL010
select top 1 * from SAK010  - aprovadores
select top 1 * from DHL010  - perfil
select top 1 * from ZBZ010


  EXTRA       -> GRAVAR NO CAMPO 'AL_DESC' := "GRUPO "+CLASSE_VALOR


delete from BZINTEGRACAO_CLASSEVALOR where CV_CODIGOAPROVADOR = ''

 UPDATE BZINTEGRACAO_CLASSEVALOR  
SET
  CV_DRIVER = ZBZ.ZBZ_DRVDB
  
FROM
  BZINTEGRACAO_CLASSEVALOR BZ
  INNER JOIN ZBZ010 ZBZ  ON BZ.CV_CLVL = ZBZ_CLVLDB  and ZBZ_DRVDB <> '' 


  UPDATE BZINTEGRACAO_CLASSEVALOR SET CV_DRIVER = '000003130' WHERE CV_DRIVER = 'DRIVER'
  */



/* 

ARA CADASTAR A CLASSE DE VALOR CTH010

 SELECT   top 10                         
										  
  --CV_EMPRESA         AS EMPRESA           
  CV_FILIAL          AS FILIAL            
 ,CV_CLVL            AS CLASSE            
 ,CV_CLASSE          AS TPCLASSE          
 ,CV_DESCRCLVL       AS DESCRCLVL         
 ,CV_CATEGORIAPPR    AS CATEGORIAPPR      
 ,CV_CRITERIOCUSTO   AS CRITERIOCUSTO     
 ,CV_QUADRORH        AS QUADRORH          
 ,CV_UN			       	 AS UN            
 ,CV_CC			       	 AS CC            
 ,CV_APLICACUSTO		 AS APLICACUSTO   
 ,CV_CONTROLATAG		 AS CONTROLATAG   
 ,CV_ATRIBUICONTA    AS ATRIBUICONTA      
 ,CV_CLVLGMCD        AS CLVLGMCD          
 ,CV_ENTIDADEGMCD    AS ENTIDADEGMCD      
 ,CV_SETORGMCD       AS SETORGMCD  
 ,CV_EMPRESA         AS CTH_YEMPGR
 ,CV_EMPRESA+CV_FILIAL         AS CTH_YEMPFL
 from  BZINTEGRACAO_CLASSEVALOR   where BZNUMPROC =  'ALC-000143' 

  SELECT CTH_FILIAL, CTH_CLVL, CTH_CLASSE, CTH_DESC01 , CTH_YCAPPR, CTH_YCRIT, CTH_YQUADR, CTH_YUN, CTH_YCC, CTH_YAPLCT,  CTH_YCTRTG, CTH_YATRIB,
   CTH_YCLVLG, CTH_YENTID, CTH_YSETOR,   CTH_YEMPGR , CTH_YEMPFL FROM CTH010 WHERE CTH_CLVL = '1100'


	 	CTH_FILIAL  AS FILIAL, 
	CTH_CLVL    AS CLASSE , 
	CTH_CLASSE  AS TPCLASSE , 
	CTH_DESC01  AS DESCRCLVL     , 
	CTH_YCAPPR  AS CATEGORIAPPR     , 
	CTH_YCRIT   AS  CRITERIOCUSTO    , 
	CTH_YQUADR  AS  QUADRORH    , 
	CTH_YUN     AS  UN    , 
	CTH_YCC     AS  CC    , 
	CTH_YAPLCT  AS APLICACUSTO     ,
	CTH_YCTRTG  AS  CONTROLATAG    ,
	CTH_YATRIB  AS  ATRIBUICONTA    ,
	CTH_YCLVLG  AS CLVLGMCD     ,
	CTH_YENTID  AS  ENTIDADEGMCD    ,
	CTH_YSETOR  AS SETORGMCD     ,
	CTH_YEMPGR  AS  CV_EMPRESA    
	--CTH_YEMPFL  AS CV_EMPRESA+CV_FILIAL 
   

	 */ 

