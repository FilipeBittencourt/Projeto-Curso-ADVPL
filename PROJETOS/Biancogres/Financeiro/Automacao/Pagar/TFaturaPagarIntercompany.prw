#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFaturaPagarIntercompany
@authOR Wlysses Cerqueira (Facile)
@since 26/04/2019
@project Automação Financeira
@version 1.0
@description Classe responsavel pelo carregamento da fatura a pagar 
para replica da fatura na filial destino. 
@type class
/*/

Class TFaturaPagarIntercompany FROM LongClasName

    Data lFidc

    Method New() Constructor
    Method Processa()

EndClass

Method New() Class TFaturaPagarIntercompany

    ::lFidc     := .F.

Return()

Method Processa(cForne, cLojaForne, cNatureza) Class TFaturaPagarIntercompany

    Local oFatPagStruct		:= TFaturaPagarStruct():New()
    Local oFatPagItemStruct := TFaturaPagarItemStruct():New()
    Local oResult           := Nil
    Local aPerg             := {}
    Local cSQL              := ""
    Local cAliasTmp        	:= GetNextAlias()

    Local dDataDe			:= CTOD("01/01/2000")
    Local dDataAte          := IIf( ::lFidc, dDataBase - 1, dDataBase )
    
    Default cForne			:= ""
    Default cLojaForne		:= "" 
    Default cNatureza		:= ""
    
    cSQL := " SELECT E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, " + CRLF
    cSQL += " E2_FORNECE, E2_LOJA, E2_SALDO, E2_EMISSAO, E2_VENCREA, R_E_C_N_O_ AS RECNO " + CRLF
    cSQL += " FROM " + RetSQLName("SE2") + " A (NOLOCK) " + CRLF
    cSQL += " WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2"))  + CRLF
    cSQL += " AND E2_FORNECE  = " + ValToSQL(cForne)  + CRLF
    cSQL += " AND E2_LOJA     = " + ValToSQL(cLojaForne)  + CRLF
    cSQL += " AND E2_TIPO     = 'NF' " + CRLF
    cSQL += " AND E2_NUMBOR   = '' " + CRLF
    cSQL += " AND E2_SALDO    > 0 " + CRLF
    //cSQL += " AND E2_SALDO    = E2_VALOR " + CRLF
    cSQL += " AND E2_FATURA   = '' " + CRLF
    
    If !::lFidc

        cSQL += " AND E2_EMISSAO  BETWEEN " + ValToSQL(dDataDe) + " AND " + ValToSQL(dDataAte) + CRLF
        cSQL += " AND E2_VENCREA  BETWEEN " + ValToSQL(dDataDe) + " AND " + ValToSQL(dDataAte) + CRLF
    
    EndIf
    
    cSQL += " AND A.D_E_L_E_T_ = '' " + CRLF

    //cSQL += " AND E2_NUM      IN ('000020690', '000023137', '000023103', '000001058') " + CRLF
    
    If ::lFidc

        cSQL += "	AND exists (select 1 from SE1070 X (NOLOCK) "+CRLF

    Else

        cSQL += " AND ( "+CRLF
        cSQL += "	(E2_YCHVSE1 = '') "+CRLF
        cSQL += "	or exists (select 1 from SE1070 X (NOLOCK) "+CRLF
    
    EndIf

    cSQL += "			where X.E1_FILIAL = Substring(E2_YCHVSE1,1,2) "+CRLF
    cSQL += "			and X.E1_PREFIXO = Substring(E2_YCHVSE1,3,3) "+CRLF
    cSQL += "			and X.E1_NUM = Substring(E2_YCHVSE1,6,9) "+CRLF
    cSQL += "			and X.E1_PARCELA = Substring(E2_YCHVSE1,15,1) "+CRLF
    cSQL += "			and X.E1_TIPO = Substring(E2_YCHVSE1,16,3) "+CRLF

    If ::lFidc
        
        //|Seleciona apenas titulos FIDC |
        cSQL += "			and X.E1_YFDCPER > 0 "+CRLF
        cSQL += "           AND X.E1_DATABOR  BETWEEN " + ValToSQL(dDataDe) + " AND " + ValToSQL(dDataAte) + CRLF

        cSQL += "			and X.E1_FATURA = '' "+CRLF
        cSQL += "			and X.D_E_L_E_T_='') "+CRLF

    Else

        cSQL += "			and X.E1_BAIXA <> '' "+CRLF
        cSQL += "			and X.E1_FATURA = '' "+CRLF
        
        //|Ignora os títulos do FIDC |
        cSQL += "			and X.E1_YFDCPER = 0 "+CRLF

        cSQL += "			and X.D_E_L_E_T_='') "+CRLF
        cSQL += "	or (
        cSQL += "			exists (select 1 from SE1070 X2 (NOLOCK) "+CRLF
        cSQL += " 					where X2.E1_FILIAL = '"+XFilial("SE1")+"' "+CRLF
        cSQL += " 					and X2.E1_PREFIXO in ('FAT','01','1','2','3','4','5') "+CRLF  //unica forma que o SQL ficou rapido - avaliar!?
        cSQL += " 					and X2.E1_NUM = (select X.E1_FATURA from SE1070 X (NOLOCK) "+CRLF
        cSQL += "		 								where X.E1_FILIAL = Substring(E2_YCHVSE1,1,2) "+CRLF
        cSQL += "										and X.E1_PREFIXO = Substring(E2_YCHVSE1,3,3) "+CRLF
        cSQL += "										and X.E1_NUM = Substring(E2_YCHVSE1,6,9) "+CRLF
        cSQL += "										and X.E1_PARCELA = Substring(E2_YCHVSE1,15,1) "+CRLF
        cSQL += "										and X.E1_TIPO = Substring(E2_YCHVSE1,16,3) "+CRLF
        cSQL += "										and X.D_E_L_E_T_='') "+CRLF
        cSQL += " 					and X2.E1_TIPO = 'FT'  "+CRLF
        cSQL += "					and X2.E1_FATURA = 'NOTFAT   ' "+CRLF
        cSQL += "					and X2.E1_BAIXA <> ''  "+CRLF
        cSQL += "					and X2.D_E_L_E_T_='') "+CRLF
        cSQL += "				and "+CRLF
        cSQL += "				not exists (select 1 from SE1070 X2 (NOLOCK) "+CRLF
        cSQL += "					where X2.E1_FILIAL = '01'   "+CRLF
        cSQL += "		 			and X2.E1_PREFIXO in ('FAT','01','1','2','3','4','5') "+CRLF
        cSQL += "					and X2.E1_NUM = (select X.E1_FATURA from SE1070 X (NOLOCK)   "+CRLF
        cSQL += "			 						where X.E1_FILIAL = Substring(E2_YCHVSE1,1,2) "+CRLF
        cSQL += "									and X.E1_PREFIXO = Substring(E2_YCHVSE1,3,3)  "+CRLF
        cSQL += "									and X.E1_NUM = Substring(E2_YCHVSE1,6,9)  "+CRLF
        cSQL += "									and X.E1_PARCELA = Substring(E2_YCHVSE1,15,1)  "+CRLF
        cSQL += "									and X.E1_TIPO = Substring(E2_YCHVSE1,16,3)  "+CRLF
        cSQL += "									and X.D_E_L_E_T_='')   "+CRLF
        cSQL += "					and X2.E1_TIPO = 'FT'  "+CRLF
        cSQL += "					and X2.E1_FATURA = 'NOTFAT   ' "+CRLF
        cSQL += "					and X2.E1_VENCREA < '"+DTOS(dDataBase-1)+"'  "+CRLF
        cSQL += "					and X2.E1_SALDO > 0  "+CRLF
        cSQL += "					and X2.D_E_L_E_T_='')  "+CRLF
        cSQL += "	) "+CRLF
        cSQL += " ) "+CRLF
    
    EndIf
  
    TcQuery cSQL New Alias (cAliasTmp)

    While !(cAliasTmp)->(Eof())

        oFatPagItemStruct := TFaturaPagarItemStruct():New()
        
        oFatPagItemStruct:nId			:= (cAliasTmp)->RECNO
        oFatPagItemStruct:nValorDesc	:= 0

        oFatPagStruct:oFatPagItens:Add(oFatPagItemStruct)

        (cAliasTmp)->(DBSkip())

    EndDo
    (cAliasTmp)->(DbCloseArea())

    oFatPagStruct:dDataRecebimento := dDataBase //+ 1 // A rotina sera processada as 23:0hr, portanto sera data atual + 1
    
    oFatPagStruct:cPrefixo 			:= "1"
    oFatPagStruct:cTipo				:= "FT"
    oFatPagStruct:lLoadDados		:= .T.

    oFaturaPagar := TFaturaPagar():New(oFatPagStruct)

    SE2->(DbSetOrder(1))

    Pergunte("AFI290", .F.,,,,, @aPerg)

    MV_PAR01 := 2 // Considera Lojas ?
    MV_PAR02 := 2 // Mostra Lancto Contabil ?
    MV_PAR03 := 1 // Contabiliza Baixa on-line ?
    MV_PAR04 := 1 // Contab.Canc.da Baixa on-line ?
    MV_PAR05 := 1 // Marcar Titulos Aut. ?
    MV_PAR06 := 2 // Seleciona filiais ?

    __SaveParam("AFI290", aPerg)

    oResult := oFaturaPagar:Incluir(.F., .T., dDataDe, dDataAte, cForne, cLojaForne, cNatureza)
    
Return(oResult)
