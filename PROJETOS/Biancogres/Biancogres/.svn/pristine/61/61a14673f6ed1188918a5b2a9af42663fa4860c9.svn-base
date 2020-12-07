#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA907
@author Wlysses Cerqueira (Facile)
@since 01/09/2020  
@Ticket: 23939 - Digitacao do codigo de barras de GNR-e pelo setor do faturamento.
@version 1.0
@description 
@type function
/*/

User Function BIA907()

    Local cFiltro       := ""
    Local aCores        := {}

    Private cCadastro   := "Contas a Pagar - GNR-e"
    Private aRotina     := {}

    aAdd(aRotina, { "Pesquisar"  , "AxPesqui"           , 0, 1})
    aAdd(aRotina, { "Visualizar" , 'AxVisual'           , 0, 2})
    aAdd(aRotina, { "Alterar"    , 'U_BIA907ALT'        , 0, 4})
    aAdd(aRotina, { "Legenda"    , 'U_BIA907LEG'        , 0, 3})

    aAdd(aCores, {  "( Empty(E2_CODBAR) .AND. Empty(E2_LINDIG) .AND. Empty(E2_YLINDIG) ) "  , 'BR_VERDE'    })
    aAdd(aCores, {  "( !Empty(E2_CODBAR) .OR. !Empty(E2_LINDIG) .OR. !Empty(E2_YLINDIG) )"  , 'BR_VERMELHO' })

    cFiltro += " E2_EMISSAO >= '" + DTOS(dDataBase) + "' AND E2_FORNECE LIKE 'GNR%' AND E2_SALDO > 0 AND E2_ORIGEM <> 'MATA953' AND E2_NUMBOR = '' "

    mBrowse(6,1,22,75,"SE2",,,,,,aCores,,,,,,,,cFiltro)

Return()

User Function BIA907ALT()

    Local aCpo := {}
    Local aCpoAlt := {}

    aAdd(aCpo, "E2_FILIAL")
    aAdd(aCpo, "E2_PREFIXO")
    aAdd(aCpo, "E2_NUM")
    aAdd(aCpo, "E2_PARCELA")
    aAdd(aCpo, "E2_TIPO")
    aAdd(aCpo, "E2_NATUREZ")
    aAdd(aCpo, "E2_FORNECE")
    aAdd(aCpo, "E2_LOJA")
    aAdd(aCpo, "E2_NOMFOR")
    aAdd(aCpo, "E2_VENCTO")
    aAdd(aCpo, "E2_VENCREA")
    aAdd(aCpo, "E2_EMISSAO")
    aAdd(aCpo, "E2_VALOR")
    aAdd(aCpo, "E2_BAIXA")
    aAdd(aCpo, "E2_HIST")
    aAdd(aCpo, "E2_CODBAR")
    aAdd(aCpo, "E2_LINDIG")
    aAdd(aCpo, "E2_YLINDIG")
    aAdd(aCpo, "E2_NUMBOR")
    aAdd(aCpo, "E2_ORIGEM")
    aAdd(aCpo, "E2_IDCNAB")
    aAdd(aCpo, "E2_YNFGUIA")
    aAdd(aCpo, "NOUSER")

    aCpoAlt := {"E2_CODBAR", "E2_LINDIG", "E2_YLINDIG"}

    AxAltera("SE2", SE2->(RecNo()), 4, aCpo, aCpoAlt)

Return()

User Function BIA907LEG()

    Local aLegenda := { { "BR_VERDE",	"Sem código de barras" },;
        { "BR_VERMELHO"	,   "Com código de barras"  } }

    BRWLEGENDA( cCadastro, "Legenda", aLegenda )

Return()
