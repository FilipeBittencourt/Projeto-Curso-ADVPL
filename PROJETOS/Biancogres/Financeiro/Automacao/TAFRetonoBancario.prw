#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFRetornoBancario
@author Tiago Rossini Coradini
@since 29/01/2019
@project Automação Financeira
@version 1.0
@description Classe para processamento de retornos bancarios
@type class
/*/

Class TAFRetornoBancario From TAFAbstractClass

	Data cIDProc // Identificar do processo
	Data oDDA // Objeto de DDA

	Method New() Constructor
	Method Process()
	Method Insert(nPos)
	Method Update(nPos)
	Method Exist(nPos)
	Method Validate(nPos)

	Method GetEmpFil( nNossoNumero )

EndClass


Method New() Class TAFRetornoBancario

	_Super:New()

	::cIDProc := ""
	::oDDA := TAFDDA():New()

Return()


Method Process() Class TAFRetornoBancario
Local nCount := 1

	If ::oLst:GetCount() > 0

		While nCount <= ::oLst:GetCount()

			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := ::oLst:GetItem(nCount):cTipo
			::oLog:cMetodo := "I_RET_BAN"

			::oLog:Insert()

			// DDA
			If ::oLst:GetItem(nCount):cTipo == "P" .And. ::oLst:GetItem(nCount):cCodSeg == "G" .And. Empty(::oLst:GetItem(nCount):cIDGUIA)

				::oDDA:cEmp := ::oLst:GetItem(nCount):cEmp
				::oDDA:cFil := ::oLst:GetItem(nCount):cFil
				::oDDA:cNumero := ::oLst:GetItem(nCount):cNumFor
				::oDDA:cEspecie := ::oLst:GetItem(nCount):cEspecie
				::oDDA:dVencto := ::oLst:GetItem(nCount):dDtVenc
				::oDDA:nValor := ::oLst:GetItem(nCount):nVlOri
				::oDDA:cCnpj := ::oLst:GetItem(nCount):cCnpjFor
				::oDDA:cCodBar := ::oLst:GetItem(nCount):cCodBar
				::oDDA:cIDProc := ::cIDProc

				::oDDA:Insert()

			Else
				
				If ::Validate(nCount)

					If !::Exist(nCount)
											
						::Insert(nCount)

					EndIf

				EndIf

			EndIf

			::oLog:cIDProc := ::cIDProc
			::oLog:cOperac := ::oLst:GetItem(nCount):cTipo
			::oLog:cMetodo := "F_RET_BAN"

			::oLog:Insert()

			nCount++

		EndDo()

	EndIf

Return()


Method Insert(nPos) Class TAFRetornoBancario

	Local nVlOCre         := 0
	
	Local _cCodigoCedente := ""
	Local _cEmp           := ""
	Local _cFil           := ""
	Local _cRecno         := ""
	Local _aRetEmp        := {}
	Local _aRetorno       := {}
	
	_aRetorno := ::GetEmpFil( ::oLst:GetItem(nPos):cNosNum )

	If !Empty( _aRetorno[1] )
		::oLst:GetItem(nPos):cEmp	:= _aRetorno[1]
		::oLst:GetItem(nPos):cFil	:= _aRetorno[2]
	EndIf
	
	RecLock("ZK4", .T.)

	ZK4->ZK4_FILIAL := xFilial("ZK4")
	ZK4->ZK4_DATA := ::oLst:GetItem(nPos):dData
	ZK4->ZK4_EMP := ::oLst:GetItem(nPos):cEmp
	ZK4->ZK4_FIL := ::oLst:GetItem(nPos):cFil
	

	ZK4->ZK4_TIPO := ::oLst:GetItem(nPos):cTipo
	ZK4->ZK4_BANCO := ::oLst:GetItem(nPos):cBanco
	ZK4->ZK4_AGENCI := ::oLst:GetItem(nPos):cAgencia
	ZK4->ZK4_CONTA := ::oLst:GetItem(nPos):cConta
	
	
	ZK4->ZK4_CODSEG	:= ::oLst:GetItem(nPos):cCodSeg
	ZK4->ZK4_NUMERO := ::oLst:GetItem(nPos):cNumero
	ZK4->ZK4_ESPECI := ::oLst:GetItem(nPos):cEspecie
	ZK4->ZK4_NOSNUM := ::oLst:GetItem(nPos):cNosNum
	ZK4->ZK4_CODBAR := ::oLst:GetItem(nPos):cCodBar
	ZK4->ZK4_IDCNAB := ::oLst:GetItem(nPos):cIdCnab

	ZK4->ZK4_VLORI := ::oLst:GetItem(nPos):nVlOri
	ZK4->ZK4_VLREC := ::oLst:GetItem(nPos):nVlRec
	ZK4->ZK4_VLPAG := ::oLst:GetItem(nPos):nVlPag
	ZK4->ZK4_VLDESP := ::oLst:GetItem(nPos):nVlDesp
	ZK4->ZK4_VLDESC := ::oLst:GetItem(nPos):nVlDesc
	ZK4->ZK4_VLABAT := ::oLst:GetItem(nPos):nVlAbat
	ZK4->ZK4_VLJURO := ::oLst:GetItem(nPos):nVlJuro
	ZK4->ZK4_VLMULT := ::oLst:GetItem(nPos):nVlMult
	ZK4->ZK4_VLTAR := ::oLst:GetItem(nPos):nVlTar
	ZK4->ZK4_VLIOF := ::oLst:GetItem(nPos):nVlIOF
	
	// Tratamento especifico para situacoes em que ocorre alteracao do valor de juros (diarios) em boletos registrados
	// Nestes casos, o primeito caracter do campo outros creditos vem com o valor "1" e sera desconsiderado no retorno
	If ::oLst:GetItem(nPos):cTipo == "R" .And. ::oLst:GetItem(nPos):cCodOco == "16" .And. SubStr(cValToChar(::oLst:GetItem(nPos):nVlOCre), 1, 1) == "1"
	
		ZK4->ZK4_VLOCRE := Val(SubStr(cValToChar(::oLst:GetItem(nPos):nVlOCre), 2, Len(cValToChar(::oLst:GetItem(nPos):nVlOCre))-1))
		
	Else
	
		ZK4->ZK4_VLOCRE := ::oLst:GetItem(nPos):nVlOCre
	
	EndIf

	ZK4->ZK4_DTCRED := ::oLst:GetItem(nPos):dDtCred
	ZK4->ZK4_DTLIQ := ::oLst:GetItem(nPos):dDtLiq
	ZK4->ZK4_DTDEB := ::oLst:GetItem(nPos):dDtDeb
	ZK4->ZK4_DTVENC := ::oLst:GetItem(nPos):dDtVenc

	ZK4->ZK4_CODOCO := ::oLst:GetItem(nPos):cCodOco
	ZK4->ZK4_CODREJ := ::oLst:GetItem(nPos):cCodRej

	ZK4->ZK4_STATUS := ::oLst:GetItem(nPos):cStatus

	ZK4->ZK4_FILE := ::oLst:GetItem(nPos):cFile
	ZK4->ZK4_IDPROC := ::oLst:GetItem(nPos):cIDProcAPI
	ZK4->ZK4_RECORD := ::oLst:GetItem(nPos):cRecord

	ZK4->ZK4_FBANCO := ::oLst:GetItem(nPos):cFBanco
	ZK4->ZK4_FAGENC	:= ::oLst:GetItem(nPos):cFAge
	ZK4->ZK4_FDVAGE := ::oLst:GetItem(nPos):cFDAge
	ZK4->ZK4_FCONTA := ::oLst:GetItem(nPos):cFConta
	ZK4->ZK4_FDVCTA := ::oLst:GetItem(nPos):cFDConta
	ZK4->ZK4_FDV2CT := ::oLst:GetItem(nPos):cFDSegCta
	ZK4->ZK4_OCORET := ::oLst:GetItem(nPos):cOcoRet
	ZK4->ZK4_CAMERA := ::oLst:GetItem(nPos):cCamara
	ZK4->ZK4_FDOC := ::oLst:GetItem(nPos):cFDoc
	ZK4->ZK4_FNOME := ::oLst:GetItem(nPos):cFNome
	ZK4->ZK4_CHVAUT := ::oLst:GetItem(nPos):cChvAut

	ZK4->ZK4_VLATUL := ::oLst:GetItem(nPos):nVLATUL
	ZK4->ZK4_VLTOT := ::oLst:GetItem(nPos):nVlTot
	ZK4->ZK4_DTAGEN := ::oLst:GetItem(nPos):dDTAGEN
	ZK4->ZK4_CODUF := ::oLst:GetItem(nPos):cCODUF
	ZK4->ZK4_IDGUIA := ::oLst:GetItem(nPos):cIDGUIA
	ZK4->ZK4_CODREC := ::oLst:GetItem(nPos):cCODREC
	ZK4->ZK4_PERREF := ::oLst:GetItem(nPos):cPERREF
	ZK4->ZK4_AUTDEB := ::oLst:GetItem(nPos):cAUTDEB
	ZK4->ZK4_NUMAGE	:= ::oLst:GetItem(nPos):cNUMAGE
	
	ZK4->ZK4_NUMSEQ := ::oLst:GetItem(nPos):cNumSeq
	ZK4->ZK4_CODNAT := ::oLst:GetItem(nPos):cCodNat
	ZK4->ZK4_TPCOMP := ::oLst:GetItem(nPos):cTpComp
	ZK4->ZK4_COMPLE := ::oLst:GetItem(nPos):cComple
	ZK4->ZK4_DTCONT := ::oLst:GetItem(nPos):dDtCont
	ZK4->ZK4_DTLANC := ::oLst:GetItem(nPos):dDtLanc 
	ZK4->ZK4_TPLANC	:= ::oLst:GetItem(nPos):cTpLanc
	ZK4->ZK4_CATEGO := ::oLst:GetItem(nPos):cCatego 
	ZK4->ZK4_CDHIST := ::oLst:GetItem(nPos):cCdHist 
	ZK4->ZK4_DSHIST := ::oLst:GetItem(nPos):cDsHist
	ZK4->ZK4_DATAIN	:= dDataBase
	ZK4->ZK4_HORAIN	:= Time()

	
	//MV_YCCANT = codigo cedente anteicipacao
	_cCodigoCedente := SUPERGETMV("MV_YCCANT", .F., "23735111422002")
	
	If (AllTrim(::oLst:GetItem(nPos):cCodigoCedente) == AllTrim(_cCodigoCedente))//FIDC pagar para tratar retorno de antecipação
		/**
			FIDC pagar : usado para descobrir de qual empresa e o titulo enviado
		*/
		
		_aRetEmp	:= U_FIDC0002(::oLst:GetItem(nPos):cCnpjFor, ::oLst:GetItem(nPos):cNumero, ::oLst:GetItem(nPos):nVlPag)
		_cEmp		:= _aRetEmp[1]
		_cFil		:= _aRetEmp[2]
		_cRecno		:= _aRetEmp[3]
		
		If (!Empty(_cEmp) .And. !Empty(_cFil) .And. !Empty(_cRecno))
			ZK4->ZK4_TIPO		:= 'F'	//Antecipação FIDC
			ZK4->ZK4_EMP 		:= _cEmp //empresa no campo numero controle cliente
			ZK4->ZK4_FIL 		:= _cFil //filial indo no campo nnumero controle cliente
			ZK4->ZK4_IDCNAB 	:= cvaltochar(_cRecno)//recno do titulo
		Else
			ZK4->ZK4_TIPO		:= 'E'	//TODO Erro Antecipação FIDC - verificar o que fazer 
		EndIf
		 
	EndIf

	ZK4->(MsUnLock())

Return()


Method Update(nPos) Class TAFRetornoBancario

	RecLock("ZK4", .F.)

	ZK4->ZK4_VLREC := ::oLst:GetItem(nPos):nVlRec
	ZK4->ZK4_VLPAG := ::oLst:GetItem(nPos):nVlPag
	ZK4->ZK4_VLDESP := ::oLst:GetItem(nPos):nVlDesp
	ZK4->ZK4_VLDESC := ::oLst:GetItem(nPos):nVlDesc
	ZK4->ZK4_VLABAT := ::oLst:GetItem(nPos):nVlAbat
	ZK4->ZK4_VLJURO := ::oLst:GetItem(nPos):nVlJuro
	ZK4->ZK4_VLMULT := ::oLst:GetItem(nPos):nVlMult
	ZK4->ZK4_VLIOF := ::oLst:GetItem(nPos):nVlIOF
	ZK4->ZK4_VLOCRE := ::oLst:GetItem(nPos):nVlOCre

	ZK4->ZK4_DTLIQ := ::oLst:GetItem(nPos):dDtLiq
	ZK4->ZK4_DTCRED := ::oLst:GetItem(nPos):dDtCred
	ZK4->ZK4_DTDEB := ::oLst:GetItem(nPos):dDtDeb
	ZK4->ZK4_DTVENC := ::oLst:GetItem(nPos):dDtVenc

	ZK4->ZK4_CODOCO := ::oLst:GetItem(nPos):cCodOco
	ZK4->ZK4_CODREJ := ::oLst:GetItem(nPos):cCodRej

	ZK4->(MsUnLock())

Return()


Method Exist(nPos) Class TAFRetornoBancario
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	// Fernando em 25/02 - Retorno a pagar nem sempre vem IDCNAB - revisar/pensar como vai ficar essa parte
	If (::oLst:GetItem(nPos):cTipo == "P" .And. Empty(::oLst:GetItem(nPos):cIdCnab))

		Return(.F.)
		
	EndIf

	cSQL := " SELECT R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("ZK4")
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(::oLst:GetItem(nPos):cEmp)
	cSQL += " AND ZK4_FIL = " + ValToSQL(::oLst:GetItem(nPos):cFil)
	cSQL += " AND ZK4_TIPO = " + ValToSQL(::oLst:GetItem(nPos):cTipo)

	If ::oLst:GetItem(nPos):cTipo == "P"
		
		If Empty(::oLst:GetItem(nPos):cIDGUIA)
		
			cSQL += " AND ZK4_OCORET = " + ValToSQL(::oLst:GetItem(nPos):cOcoRet)
			
		EndIf
		
		cSQL += " AND ZK4_CHVAUT NOT LIKE " + ValToSQL("%REJEITADO%")
		cSQL += " AND ZK4_IDCNAB = " + ValToSQL(::oLst:GetItem(nPos):cIdCnab)

	ElseIf ::oLst:GetItem(nPos):cTipo == "R"

		cSQL += " AND ZK4_CODOCO = " + ValToSQL(::oLst:GetItem(nPos):cCodOco)
		cSQL += " AND ZK4_NOSNUM = " + ValToSQL(::oLst:GetItem(nPos):cNosNum)
		
		// Foi identificado que pode existir mais de uma despesa de cartorio
		// para um mesmo titulo, sendo assim colocamos mais um filtro que
		// valida a data da baixa. Porem caso aconteca um pior cenario em que
		// exista em um mesmo dia 2 taxas de cartorio e com mesmo valor
		// devera ser reavalidado um melhor tratamento.
		cSQL += " AND ZK4_DTLIQ = " + ValToSQL(::oLst:GetItem(nPos):dDtLiq)
		
	ElseIf ::oLst:GetItem(nPos):cTipo == "C"

		cSQL += " AND ZK4_BANCO = " + ValToSQL(::oLst:GetItem(nPos):cBanco)
		cSQL += " AND ZK4_AGENCI = " + ValToSQL(::oLst:GetItem(nPos):cAgencia)
		cSQL += " AND ZK4_CONTA = " + ValToSQL(::oLst:GetItem(nPos):cConta)
		cSQL += " AND ZK4_DTLANC = " + ValToSQL(::oLst:GetItem(nPos):dDtLanc)
		cSQL += " AND ZK4_VLTOT = " + ValToSQL(::oLst:GetItem(nPos):nVlTot)
		cSQL += " AND ZK4_CATEGO = " + ValToSQL(::oLst:GetItem(nPos):cCatego)
		cSQL += " AND ZK4_CDHIST = " + ValToSQL(::oLst:GetItem(nPos):cCdHist)
		cSQL += " AND ZK4_NUMERO = " + ValToSQL(::oLst:GetItem(nPos):cNumero)
		cSQL += " AND (ZK4_NUMSEQ = " + ValToSQL(::oLst:GetItem(nPos):cNumSeq) + " OR ZK4_NUMSEQ = '') "
		
	EndIf

	cSQL += " AND	D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->RECNO > 0
	
	(cQry)->(DbCloseArea())

Return(lRet)


Method Validate(nPos) Class TAFRetornoBancario
Local lRet := .T.

Return(lRet)


Method GetEmpFil( cNossoNumero ) Class TAFRetornoBancario

	Local aRetorno		:= {}
	Local cEmpBoleto	:= ""
	Local cFilBoleto	:= ""

	If ValType(cNossoNumero) == "C"

		//|Boleto da Biancogres |
		If SubStr( cNossoNumero, 1, 2 ) == "61"	

			cEmpBoleto	:= "01"
			cFilBoleto	:= "01"

		EndIf

		//|Boleto da LM |
		If SubStr( cNossoNumero, 1, 2 ) == "81"	

			cEmpBoleto	:= "07"
			cFilBoleto	:= "01"

		EndIf

	EndIf

	//|retorno default |
	aAdd( aRetorno, cEmpBoleto )
	aAdd( aRetorno, cFilBoleto )

Return aRetorno
