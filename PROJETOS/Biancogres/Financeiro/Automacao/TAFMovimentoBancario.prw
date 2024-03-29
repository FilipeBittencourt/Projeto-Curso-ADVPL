#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFMovimentoBancario
@author Tiago Rossini Coradini
@since 16/07/2019
@project Automa��o Financeira
@version 1.0
@description Classe para tratar movimentos bancarios
@type class
/*/

Class TAFMovimentoBancario From LongClassName
			
	Data cFil // Filial da empresa
	Data cRecPag // P=Pagar; R=Receber
	Data dData // Data do movimento
	Data dDigit // Data de digitacao
	Data dDispo // Data de disponibilidade	
	Data cMoeda // Numerario
	Data nTxMoeda // Taxa da moeda
	Data nValor // Valor
	Data cNatureza // Natureza financeira
	Data cBanco // Numero do banco
	Data cAgencia // Agencia
	Data cConta // Conta corrente
	Data cNumChe // Numero do cheque
	Data cNumDoc // Numero do documento
	Data cBenef // Beneficiario
	Data cHistorico // Historico
	Data cCentroCusto // Centro de custo
	Data cClasseValor // ClassE de valor
	Data cTipDoc // Tipo de documento
	Data cMotBx // Motivo da baixa
	Data cPrefixo // Prefixo do titulo
	Data cNumero // Numero do titulo
	Data cParcela // Parcela do titulo
	Data cTipo // Tipo do titulo
	Data cCliFor // Codigo do cliente ou fornecedor
	Data cLoja // Loja do cliente ou fornecedor
	Data cCodOco // Codigo da ocorrencia bancaria - Cnab
	Data nIdApi // Identificador integracao API Financeira

	// Propriedades utilizadas em transferencias bancarias
	Data cBcoOri
	Data cAgOri
	Data cCcOri
	Data cNatOri	
	Data cBcoDes
	Data cAgDes
	Data cCcDes
	Data cNatDes
	Data cTipTra

	Method New() Constructor
	Method Insert()
	Method Transfer()
	Method Exists()

EndClass


Method New() Class TAFMovimentoBancario

	::cFil := xFilial("SE5")
	::cRecPag := "P"
	::dData := dDataBase
	::dDigit := dDataBase
	::dDispo := dDataBase
	::cMoeda := "M1"
	::nTxMoeda := 0
	::nValor := 0
	::cNatureza := ""
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""
	::cNumChe := ""
	::cNumDoc := ""
	::cBenef := ""
	::cHistorico := ""
	::cCentroCusto := ""
	::cClasseValor := ""
	::cTipDoc := ""
	::cMotBx := ""
	::cPrefixo := ""
	::cNumero := ""
	::cParcela := ""
	::cTipo := ""
	::cCliFor := ""
	::cLoja := ""
	::cCodOco := ""	
	::nIdApi := 0
	
	::cBcoOri := ""
	::cAgOri := ""
	::cCcOri := ""
	::cNatOri	:= ""
	::cBcoDes := ""
	::cAgDes := ""
	::cCcDes := ""
	::cNatDes := ""
	::cTipTra := ""
		
Return()


Method Insert() Class TAFMovimentoBancario
Local dAuxAux := dDataBase
Local aFields := {}
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .F.

	dDataBase := ::dData
	
	// Posiciona no banco da baixa para o identificacao no lancamento contabil
	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	SA6->(DbSeek(xFilial("SA6") + ::cBanco + ::cAgencia + ::cConta))	

	aAdd(aFields, {"E5_FILIAL", ::cFil, Nil})
	aAdd(aFields, {"E5_RECPAG", ::cRecPag, Nil})	
	aAdd(aFields, {"E5_DATA", ::dData, Nil})
	aAdd(aFields, {"E5_DTDIGIT", ::dDigit, Nil})
	aAdd(aFields, {"E5_DTDISPO", ::dDispo, Nil})
	aAdd(aFields, {"E5_MOEDA", ::cMoeda, Nil})
	aAdd(aFields, {"E5_TXMOEDA", ::nTxMoeda, Nil})
	aAdd(aFields, {"E5_VALOR", ::nValor, Nil})
	aAdd(aFields, {"E5_NATUREZ", ::cNatureza, Nil})
	aAdd(aFields, {"E5_BANCO", ::cBanco, Nil})
	aAdd(aFields, {"E5_AGENCIA", ::cAgencia, Nil})
	aAdd(aFields, {"E5_CONTA", ::cConta, Nil})	
	aAdd(aFields, {"E5_NUMCHEQ", ::cNumChe, Nil})
	aAdd(aFields, {"E5_DOCUMEN", ::cNumDoc, Nil})
	aAdd(aFields, {"E5_BENEF", ::cBenef, Nil})	
	aAdd(aFields, {"E5_HISTOR", ::cHistorico, Nil})	

	If ::cRecPag == "P"

		aAdd(aFields, {"E5_CCD", ::cCentroCusto, Nil})
		aAdd(aFields, {"E5_CLVLDB", ::cClasseValor, Nil})
						
	Else

		aAdd(aFields, {"E5_CCC", ::cCentroCusto, Nil})
		aAdd(aFields, {"E5_CLVLCR", ::cClasseValor, Nil})
	
	EndIf	
	
	aAdd(aFields, {"E5_TIPODOC", ::cTipDoc, Nil})
	aAdd(aFields, {"E5_MOTBX", ::cMotBx, Nil})
	aAdd(aFields, {"E5_PREFIXO", ::cPrefixo, Nil})
	aAdd(aFields, {"E5_NUMERO", ::cNumero, Nil})
	aAdd(aFields, {"E5_PARCELA", ::cParcela, Nil})
	aAdd(aFields, {"E5_TIPO", ::cTipo, Nil})
	aAdd(aFields, {"E5_CLIFOR", ::cCliFor, Nil})
	aAdd(aFields, {"E5_LOJA", ::cLoja, Nil})
	aAdd(aFields, {"E5_FILORIG", ::cFil, Nil})
	aAdd(aFields, {"E5_CNABOC", ::cCodOco, Nil})	
	aAdd(aFields, {"E5_YIDAPIF", ::nIdApi, Nil})
	
	aFields := FWVetByDic(aFields, "SE5", .F., 1)
	
	Begin Transaction
		
		MsExecAuto({|aFields, nOpc| FINA100(, aFields, nOpc)}, aFields, If (::cRecPag == "P", 3, 4))
		
		If lMsErroAuto
			
			DisarmTransaction()
			
			MostraErro()
	
		EndIf
		
	End Transaction
		
	dDataBase := dAuxAux
	
Return(!lMsErroAuto)


Method Transfer() Class TAFMovimentoBancario
Local aFields := {}
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .F.
Private Inclui := .T.
	
	aAdd(aFields, {"CBCOORIG", ::cBcoOri, Nil})
	aAdd(aFields, {"CAGENORIG", ::cAgOri, Nil})	
	aAdd(aFields, {"CCTAORIG", ::cCcOri, Nil})
	aAdd(aFields, {"CNATURORI", ::cNatOri, Nil})
	aAdd(aFields, {"CBCODEST", ::cBcoDes, Nil})
	aAdd(aFields, {"CAGENDEST", ::cAgDes, Nil})
	aAdd(aFields, {"CCTADEST", ::cCcDes, Nil})	
	aAdd(aFields, {"CNATURDES", ::cNatDes, Nil})
	aAdd(aFields, {"CTIPOTRAN", ::cTipTra, Nil})
	aAdd(aFields, {"CDOCTRAN", ::cNumChe, Nil})
	aAdd(aFields, {"NVALORTRAN", ::nValor, Nil})
	aAdd(aFields, {"CHIST100", ::cHistorico, Nil})	
	aAdd(aFields, {"CBENEF100", ::cBenef, Nil})
	
	Begin Transaction
		
		MsExecAuto({|aFields, nOpc| FINA100(, aFields, nOpc)}, aFields, 7)
		
		If lMsErroAuto
			
			DisarmTransaction()
			
			MostraErro()
	
		EndIf
		
	End Transaction
	
Return(!lMsErroAuto)

Method Exists() Class TAFMovimentoBancario

    static oExistsPS as object

    local aArea     as array

    local cSQL      as character
    local cTblTmp   as character

    local lExists   as logical

    aArea:=getArea()

    if (!(valtype(oExistsPS)=="O"))
        BeginContent var cSQL
            SELECT ISNULL(x.nEXISTS,0) nEXISTS 
            FROM(
                    SELECT  1 AS nEXISTS                                                                              
                    FROM [?] SE5                                                                
                    WHERE SE5.E5_FILIAL=?                           
                      AND SE5.E5_RECPAG=?                                     
                      AND SE5.E5_DATA=?                                    
                      AND SE5.E5_BANCO=?                                                
                      AND SE5.E5_AGENCIA=?
                      AND SE5.E5_CONTA=?
                      AND SE5.E5_CLVLCR=?
                      AND SE5.E5_CCC=?
                      AND SE5.E5_NATUREZ=?
                      AND SE5.E5_VALOR=?
                      AND SE5.E5_HISTOR=?
                      AND SE5.D_E_L_E_T_=''          
                ) x
        EndContent 
        oExistsPS:=FWPreparedStatement():New(cSQL)
    EndIf

    oExistsPS:setString(1,retSQLName("SE5"))
    
    oExistsPS:setString(2,xFilial('SE5'))
    oExistsPS:setString(3,self:cRecPag)

    oExistsPS:setDate(4,self:dData)
    oExistsPS:setString(5,self:cBanco)

    oExistsPS:setString(6,self:cAgencia)
    oExistsPS:setString(7,self:cConta)

    oExistsPS:setString(8,self:cClasseValor)
    oExistsPS:setString(9,self:cCentroCusto)
   
    oExistsPS:setString(10,self:cNatureza)
    oExistsPS:setNumeric(11,self:nValor)

    oExistsPS:setString(12,self:cHistorico)

    cSQL:=oExistsPS:GetFixQuery()
    
    cSQL:=strTran(cSQL,"['","[")
    cSQL:=strTran(cSQL,"']","]")

    if (self:cRecPag=="P")
        cSQL:=strTran(cSQL,"E5_CCC","E5_CCD")
        cSQL:=strTran(cSQL,"E5_CLVLCR","E5_CLVLDB")
	endif

    cTblTmp:=MpSysOpenQuery(cSQL)

    if (lExists:=Select(cTblTmp)>0)
        lExists:=((cTblTmp)->nEXISTS==1)
        (cTblTmp)->(dbCloseArea())
    endif

    restArea(aArea)

    Return(lExists)
