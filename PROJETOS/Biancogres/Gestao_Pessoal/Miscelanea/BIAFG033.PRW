#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG033
@author Gabriel Rossi Mafioletti
@since 21/02/2018
@version 1.0
@description Função Para Geração de Senhas do Portal RH
@type function
/*/

User Function BIAFG033(_lGera)


	Default _lGera	:= .F.

	If _lGera
		U_BIAMsgRun("Aguarde... Gerando Senhas",,{|| fGeraSenha() })
	EndIf

	Processa({|| fGeraRel()})

Return

Static Function fGeraSenha()

	Local _lVezes	
	Local _cSenha
	Local _nI

	fCriaTab()

	DbSelectArea("RD0")
	RD0->(DbGoTop())

	While RD0->(!EOF())

		_cSenha	:=	Val(Embaralha(Right(Dtos(RD0->RD0_DTNASC),2 )+right(Dtos(RD0->RD0_DTADMI),2)+right(Alltrim(RD0->RD0_CIC),2),0))

		_cSenha	:= nToc(_cSenha,16,6)

		For _nI	:=	1 to 2

			_cSenha	:=	Embaralha(_cSenha,0)

		Next


		fInsTab(_cSenha)

		Reclock("RD0",.F.)
		RD0->RD0_SENHA = _cSenha
		RD0->(MsUnlock())

		RD0->(DbSkip())

	EndDO

Return

Static Function fCriaTab()

	Local _cSql	:=	"CREATE TABLE ##SENHASPORT(CGC VARCHAR(14),EMAIL VARCHAR(60), SENHA VARCHAR(6) )"

	TcSqlExec(_cSql)

Return

Static Function fInsTab(_cSenha)

	Local _cSql	:=	"Insert Into ##SENHASPORT SELECT " + ValtoSql(RD0->RD0_CIC) + "," + ValtoSql(RD0->RD0_EMAIL) + ',' + ValtoSql(Embaralha(_cSenha,1))

	TcSqlExec(_cSql)

Return

Static Function fGeraRel()

	fQryDados()

Return

Static Function fQryDados()

	Local _cAlias	:=	GetNextAlias()
	Local nTotReg	:=	0
	local nRegAtu   := 0
	Local _cBaia	:=	""

	local cCab1Fon	:= 'Calibri' 
	local cCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIAFG033_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	Local msEnter     := Chr(13) + Chr(10)

	BeginSql Alias _cAlias
	SELECT RD0_NOME,RD0_SENHA
	FROM %TABLE:RD0% RD0
	JOIN %TABLE:SRA% SRA
	ON RD0.RD0_CIC = SRA.RA_CIC
	AND SRA.RA_DEMISSA = ''
	AND SRA.RA_CLVL IN('2115','2215')
	AND SRA.%NOTDEL%
	WHERE RD0.RD0_FILIAL = %XFILIAL:RD0%
	AND RD0.RD0_MSBLQL <> '1'
	AND RD0.%NOTDEL%
	ORDER BY RD0_NOME
	EndSql 	

	(_cAlias)->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif
	(_cAlias)->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio",{20,210,60},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,1) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,1) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Senhas do Portal RH ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,1)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()

	oExcel:AddCelula("Nome"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Senha"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula( (_cAlias)->RD0_NOME		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( Embaralha((_cAlias)->RD0_SENHA,1)		,0		 		,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)


		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo

	oExcel:SaveXml(Alltrim(GetTempPath()),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	(_cAlias)->(dbCloseArea())

Return