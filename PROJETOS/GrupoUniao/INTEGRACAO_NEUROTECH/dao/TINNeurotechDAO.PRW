#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TINNeurotechDAO
@description Classe para buscar grupo economico do cliente
@author Fernando Rocha / Filipe Vieira
@since 03/12/2018
@version 1.0
/*/
Class TINNeurotechDAO From LongClassName   

    Method New() Constructor
	Method FluxoNeuro(oNeurotM)
    Method GrpNeurot(cCodGrp)

EndClass


//|Metódo construtor da classe |
Method New() Class TINNeurotechDAO	 

Return Self


Method FluxoNeuro(oNeurotM) Class TINNeurotechDAO

  
  Local cSQL := ""


                                                                                                                                                                                                                                                            
// -- QRY IHORRAN PARA ENVIO DE DADOS A NEUROTECH   

cSQL +="  SELECT TOP 1           "
cSQL +="      RTRIM(SA1.A1_CGC) AS [CPF_CNPJ]       "
cSQL +="    , RTRIM(SC5.C5_NUM) AS NrPedido         "
cSQL +="    , CONVERT(VARCHAR(10), CAST(SC5.C5_EMISSAO AS DATE), 103) AS DtPedido "
cSQL +="    , RTRIM(SD2.D2_DOC) AS NrNF   "
cSQL +="    , IIF(SA1.A1_DTNASC = '', 0, DATEDIFF(YEAR, SA1.A1_DTNASC, SC5.C5_EMISSAO)) AS IdadeFundacao        "
cSQL +="    , SA1.A1_EST AS UFEmpresa     "
cSQL +="    , IIF(SA1.A1_CONTRIB = '1', 'ICMS', 'ISENTO') AS TipoContr  "
cSQL +="    , RTRIM(SA1.A1_CEP) AS CEPEntrega       "
cSQL +="    , ROUND(IIF(SA1.A1_DTCAD = '', 0, DATEDIFF(MONTH, SA1.A1_DTCAD, SC5.C5_EMISSAO))/12,0) AS TempRelac "
cSQL +="    , IIF(DATEDIFF(MONTH, SA1.A1_DTCAD, SC5.C5_EMISSAO) <= 6, 'NOVO','JA CLIENTE') TipoCliente"
cSQL +="    , COALESCE(ValorCompraAtual,(SELECT SUM(SC6.C6_VALOR) FROM "+RetSQLName('SC6')+" SC6  WITH (NOLOCK) WHERE SC6.D_E_L_E_T_ = '' "
cSQL +="         AND SC6.C6_FILIAL = SC5.C5_FILIAL  "
cSQL +="         AND SC6.C6_NUM = SC5.C5_NUM )) AS VlrCpraAt  "
cSQL +="    , MAX(IIF((SE1.E1_BAIXA = '' OR SE1.E1_BAIXA > SC5.C5_EMISSAO) AND SE1.E1_VENCREA < SC5.C5_EMISSAO  "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, SC5.C5_EMISSAO)     "
cSQL +="  , 0)        "
cSQL +="         ) AS AtrasoAtual         "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA < SC5.C5_EMISSAO         "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '' OR SE1.E1_BAIXA > SC5.C5_EMISSAO, SC5.C5_EMISSAO,SE1.E1_BAIXA))     "
cSQL +="  , 0)        "
cSQL +="         ) AS MDAHist   "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= DATEADD(MONTH, -3, SC5.C5_EMISSAO) AND SE1.E1_VENCREA < SC5.C5_EMISSAO  "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '' OR SE1.E1_BAIXA > SC5.C5_EMISSAO, SC5.C5_EMISSAO,SE1.E1_BAIXA))     "
cSQL +="  , 0)        "
cSQL +="         ) AS MDA03m    "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= DATEADD(MONTH, -12, SC5.C5_EMISSAO) AND SE1.E1_VENCREA < SC5.C5_EMISSAO "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '' OR SE1.E1_BAIXA > SC5.C5_EMISSAO, SC5.C5_EMISSAO,SE1.E1_BAIXA))     "
cSQL +="  , 0)        "
cSQL +="         ) AS MDA12m    "
cSQL +="    , SUM(IIF(SE1.E1_BAIXA = '' OR SE1.E1_BAIXA > SC5.C5_EMISSAO, SE1.E1_VALOR, 0)) AS nVlrTotVen       "
cSQL +="    , DATEDIFF(DAY, (   "
cSQL +="    SELECT    "
cSQL +="        MAX(C5_EMISSAO) "
cSQL +="    FROM      "
cSQL +="        "+RetSQLName('SC5')+" A WITH (NOLOCK)  "
cSQL +="    WHERE     "
cSQL +="        A.D_E_L_E_T_     = ''     "
cSQL +="     AND A.C5_TIPO = 'N'"
cSQL +="        AND A.C5_FILIAL  = SC5.C5_FILIAL    "
cSQL +="        AND A.C5_CLIENTE = SC5.C5_CLIENTE   "
cSQL +="        AND A.C5_LOJACLI = SC5.C5_LOJACLI   "
cSQL +="        AND A.C5_EMISSAO < SC5.C5_EMISSAO   "
cSQL +="), SC5.C5_EMISSAO       "
cSQL +="    ) AS TempUltCo      "
cSQL +="    , COUNT(DISTINCT    "
cSQL +="      IIF(    "
cSQL +="       SE1.E1_PREFIXO NOT IN ('DUP','FAT','LIQ')      "
cSQL +="       AND SE1.E1_PARCELA = ''    "
cSQL +="       AND SE1.E1_EMISSAO < SC5.C5_EMISSAO  "
cSQL +="       AND SE1.E1_EMISSAO = SE1.E1_VENCREA  "
cSQL +="     , SE1.E1_NUM       "
cSQL +="     , NULL)  "
cSQL +="         ) AS QtdCAVist "
cSQL +="    , SUM(    "
cSQL +="      IIF(    "
cSQL +="   SE1.E1_PREFIXO NOT IN ('DUP','FAT','LIQ')"
cSQL +="    AND SE1.E1_EMISSAO < SC5.C5_EMISSAO     "
cSQL +="   , SE1.E1_VALOR       "
cSQL +="   , 0)       "
cSQL +="      ) AS vlrTCReal    "
cSQL +="    , SUM(    "
cSQL +="      IIF(    "
cSQL +="         SE1.E1_PREFIXO NOT IN ('DUP','FAT','LIQ')    "
cSQL +="         AND SE1.E1_EMISSAO < SC5.C5_EMISSAO"
cSQL +="         AND SE1.E1_EMISSAO >= DATEADD(MONTH,-3, SC5.C5_EMISSAO)"
cSQL +="   , SE1.E1_VALOR       "
cSQL +="   , 0)       "
cSQL +="      ) AS vlrTC03m     "
cSQL +="    , SUM(    "
cSQL +="      IIF(    "
cSQL +="         SE1.E1_PREFIXO NOT IN ('DUP','FAT','LIQ')    "
cSQL +="         AND SE1.E1_EMISSAO < SC5.C5_EMISSAO"
cSQL +="         AND SE1.E1_EMISSAO >= DATEADD(MONTH,-12, SC5.C5_EMISSAO)         "
cSQL +="   , SE1.E1_VALOR       "
cSQL +="   , 0)       "
cSQL +="      ) AS vlrTC12m     "
cSQL +="    , COUNT( DISTINCT   "
cSQL +="      IIF(    "
cSQL +="         SE1.E1_PREFIXO NOT IN ('DUP','FAT','LIQ')    "
cSQL +="         AND SE1.E1_EMISSAO < SC5.C5_EMISSAO"
cSQL +="         AND SE1.E1_EMISSAO >= DATEADD(MONTH,-3, SC5.C5_EMISSAO)"
cSQL +="         , SE1.E1_NUM   "
cSQL +="         , NULL))  QtdTotC03      "
cSQL +="         , SUM(         "
cSQL +="      IIF(    "
cSQL +="       SE1.E1_PREFIXO NOT IN ('DUP','FAT','LIQ')      "
cSQL +="       AND (SE1.E1_PARCELA != '' OR SE1.E1_EMISSAO != SE1.E1_VENCREA)     "
cSQL +="       AND SE1.E1_EMISSAO < SC5.C5_EMISSAO  "
cSQL +="     , SE1.E1_VALOR     "
cSQL +="     , 0)     "
cSQL +="         ) vlrTCHist    "
cSQL +="         , COUNT( DISTINCT        "
cSQL +="      IIF(    "
cSQL +="       SE1.E1_PREFIXO NOT IN ('DUP','FAT','LIQ')      "
cSQL +="       AND (SE1.E1_PARCELA != '' OR SE1.E1_EMISSAO != SE1.E1_VENCREA)     "
cSQL +="       AND SE1.E1_EMISSAO < SC5.C5_EMISSAO  "
cSQL +="     , SE1.E1_NUM       "
cSQL +="     , NULL)  "
cSQL +="         ) QtdTotCPH    "
cSQL +="         , COUNT( DISTINCT        "
cSQL +="      IIF(    "
cSQL +="       SE1.E1_PREFIXO NOT IN ('DUP','FAT','LIQ')      "
cSQL +="       AND (SE1.E1_PARCELA != '' OR SE1.E1_EMISSAO != SE1.E1_VENCREA)     "
cSQL +="      AND SE1.E1_EMISSAO < SC5.C5_EMISSAO   "
cSQL +="      AND DATEDIFF(MONTH,SE1.E1_EMISSAO, SC5.C5_EMISSAO)+1 <= 12"
cSQL +="     , SE1.E1_NUM       "
cSQL +="     , NULL)  "
cSQL +="         ) QtdTotC12    "
cSQL +="    , (SELECT COUNT(*) FROM "+RetSQLName("SC5")+" A WITH (NOLOCK) WHERE A.C5_CLIENTE = SC5.C5_CLIENTE AND A.C5_LOJACLI =SC5.C5_LOJACLI AND A.C5_FILIAL = SC5.C5_FILIAL AND A.D_E_L_E_T_ = '' AND A.C5_YSTATUS = '9' AND A.C5_EMISSAO <SC5.C5_EMISSAO) AS QtdTotCan  "

cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 1, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 1     "

cSQL +="       , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 1, SC5.C5_EMISSAO)),"
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 1, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 1,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes01  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 2, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 2     "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 2, SC5.C5_EMISSAO)),     "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 2, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 2,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes02  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 3, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 3     "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 3, SC5.C5_EMISSAO)),     "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 3, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 3,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes03  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 4, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 4     "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 4, SC5.C5_EMISSAO)),     "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 4, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 4,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes04  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 5, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 5     "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 5, SC5.C5_EMISSAO)),     "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 5, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 5,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes05  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 6, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 6     "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 6, SC5.C5_EMISSAO)),     "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 6, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 6,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes06  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 7, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 7     "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 7, SC5.C5_EMISSAO)),     "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 7, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 7,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes07  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 8, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 8     "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 8, SC5.C5_EMISSAO)),     "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 8, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 8,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes08  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 9, SC5.C5_EMISSAO)) <= EOMONTH(E1_BAIXA)AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 9     "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 9, SC5.C5_EMISSAO)),     "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 9, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 9,SC5.C5_EMISSAO)), SE1.E1_BAIXA))) "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes09  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 10, SC5.C5_EMISSAO)) <=EOMONTH(E1_BAIXA) AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 10   "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 10, SC5.C5_EMISSAO)),    "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 10, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 10,SC5.C5_EMISSAO)), SE1.E1_BAIXA)))         "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes10  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 11, SC5.C5_EMISSAO)) <=EOMONTH(E1_BAIXA) AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 11   "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 11, SC5.C5_EMISSAO)),    "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 11, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 11,SC5.C5_EMISSAO)), SE1.E1_BAIXA)))         "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes11  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 12, SC5.C5_EMISSAO)) <=EOMONTH(E1_BAIXA) AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 12   "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 12, SC5.C5_EMISSAO)),    "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 12, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 12,SC5.C5_EMISSAO)), SE1.E1_BAIXA)))         "
cSQL +="  , 0)         "
cSQL +="         ) AS AtraMes12  "
cSQL +="    , MAX(IIF(SE1.E1_VENCREA >= SC5.C5_EMISSAO AND EOMONTH(DATEADD(MONTH, 12, SC5.C5_EMISSAO)) <=EOMONTH(E1_BAIXA) AND DATEDIFF(MONTH, SC5.C5_EMISSAO, SE1.E1_VENCREA) <= 12   "
cSQL +="  , DATEDIFF(DAY, SE1.E1_VENCREA, IIF(SE1.E1_BAIXA = '', EOMONTH(DATEADD(MONTH, 12, SC5.C5_EMISSAO)),    "
cSQL +="   IIF(SE1.E1_BAIXA > EOMONTH(DATEADD(MONTH, 12, SC5.C5_EMISSAO)), EOMONTH(DATEADD(MONTH, 12,SC5.C5_EMISSAO)), SE1.E1_BAIXA)))         "
cSQL +="  , 0)         "
cSQL +="         ) AS MDA12M     "
cSQL +="  FROM         "
 cSQL +="  "+RetSQLName("SC5")+" SC5 WITH (NOLOCK)   "
cSQL +="  INNER JOIN   "
cSQL +=" "+RetSQLName("SA1")+" SA1 WITH (NOLOCK)   "
cSQL +="ON ( "
cSQL +="       SA1.D_E_L_E_T_     = ''     "
cSQL +="       AND SA1.A1_COD     = SC5.C5_CLIENTE   "
cSQL +="       AND SA1.A1_LOJA    = SC5.C5_LOJACLI   "
cSQL +="       AND NOT EXISTS    "
cSQL +="         (     "
cSQL +="   SELECT '' FROM dbo.SIGAMAT SM0 WITH (NOLOCK) WHERE SM0.D_E_L_E_T_ = '' AND SM0.M0_CGC = SA1.A1_CGC    "
cSQL +="         )     "
cSQL +="   ) "
cSQL +="  LEFT JOIN    "
cSQL +="  "+RetSQLName("SE1")+" SE1 WITH (NOLOCK)  "
cSQL +="ON ( "
cSQL +="       SE1.D_E_L_E_T_     = ''     "
cSQL +="       AND SE1.E1_FILIAL  = SC5.C5_FILIAL    "
cSQL +="       AND SE1.E1_CLIENTE = SC5.C5_CLIENTE   "
cSQL +="       AND SE1.E1_LOJA    = SC5.C5_LOJACLI   "
cSQL +="       AND SE1.E1_TIPO NOT IN      "
cSQL +="     (         "
cSQL +="         'NCC', 'RA', 'AB-'        "
cSQL +="     )         "
cSQL +="   ) "
cSQL +="  LEFT JOIN    "
cSQL +="         (     "
cSQL +="      SELECT   "
cSQL +="   SD2.D2_DOC  "
cSQL +="   , SD2.D2_PEDIDO       "
cSQL +="   , SD2.D2_CLIENTE      "
cSQL +="   , SD2.D2_LOJA         "
cSQL +="   , SUM(SD2.D2_VALBRUT) AS ValorCompraAtual "
cSQL +="      FROM     "
cSQL +="  "+RetSQLName("SD2")+" SD2 WITH (NOLOCK)  "
cSQL +="      WHERE    "
cSQL +="   SD2.D_E_L_E_T_ = ''   "
cSQL +="      GROUP BY "
cSQL +="   SD2.D2_DOC  "
cSQL +="   , SD2.D2_PEDIDO       "
cSQL +="   , SD2.D2_CLIENTE      "
cSQL +="   , SD2.D2_LOJA         "
cSQL +="         ) SD2 ON SD2.D2_PEDIDO = SC5.C5_NUM AND SD2.D2_CLIENTE = SC5.C5_CLIENTE AND SD2.D2_LOJA = SC5.C5_LOJACLI  "
cSQL +="  WHERE        "
cSQL +="  C5_CLIENTE = " + ValToSql(oNeurotM:oCliente:cCodigo)

cSQL +="      AND SC5.D_E_L_E_T_ = ''      "
cSQL +="      AND SC5.C5_TIPO    = 'N'     "
cSQL +="  GROUP BY     "
cSQL +="         SA1.A1_CGC      "
cSQL +="    , RTRIM(SC5.C5_NUM)  "
cSQL +="    , RTRIM(SD2.D2_DOC)  "
cSQL +="    , ValorCompraAtual   "
cSQL +="    , CONVERT(VARCHAR(10), CAST(SC5.C5_EMISSAO AS DATE), 103)    "
cSQL +="    , IIF(SA1.A1_DTNASC = '', 0, DATEDIFF(YEAR, SA1.A1_DTNASC, SC5.C5_EMISSAO))      "
cSQL +="    , SA1.A1_EST         "
cSQL +="    , IIF(SA1.A1_CONTRIB = '1', 'ICMS', 'ISENTO')      "
cSQL +="    , SA1.A1_CEP         "
cSQL +="    , ROUND(IIF(SA1.A1_DTCAD = '', 0, DATEDIFF(MONTH, SA1.A1_DTCAD, SC5.C5_EMISSAO))/12,0)     "
cSQL +="    , IIF(DATEDIFF(MONTH, SA1.A1_DTCAD, SC5.C5_EMISSAO) <= 6, 'NOVO','JA CLIENTE')   "
cSQL +="    , SC5.C5_FILIAL      "
cSQL +="    , SC5.C5_CLIENTE     "
cSQL +="    , SC5.C5_LOJACLI     "
cSQL +="    , SC5.C5_EMISSAO         "
cSQL +=", SC5.C5_NUM "
cSQL +="  ORDER BY SC5.C5_EMISSAO DESC "
 
    TcQuery cSQL new alias "NEURO" 
    
    NEURO->(DBGotop())  
    While !NEURO->(EOF()) //Enquando não for fim de arquivo
       
        oNeurotM:cNrPedido 	:=	NEURO->NrPedido
        oNeurotM:dDtPedido 	:=	NEURO->DtPedido
        oNeurotM:cNrNF     	 :=	NEURO->NrNF
        oNeurotM:cIdadeFund	 :=	NEURO->IdadeFundacao
        oNeurotM:cUFEmpresa	:=	NEURO->UFEmpresa
        oNeurotM:cTipoContr	:=	NEURO->TipoContr //TipoContribuinte
        oNeurotM:cCEPEntreg	:=	NEURO->CEPEntrega
        oNeurotM:nTempRelac	:=	NEURO->TempRelac //TempoRelacionamento
        oNeurotM:cTipoClien	:=	NEURO->TipoCliente
        oNeurotM:nVlrCpraAt	:=	NEURO->VlrCpraAt //ValorCompraAtual
        oNeurotM:nAtrasoAtu	:=	NEURO->AtrasoAtual
        oNeurotM:nMDAHist  	:=	NEURO->MDAHist
        oNeurotM:nMDA03m   	:=	NEURO->MDA03m
        oNeurotM:nMDA12m   	:=	NEURO->MDA12m
        oNeurotM:nVlrTotVen	:=	NEURO->nVlrTotVen //ValorTotalVencer
        oNeurotM:nTempUltCo	:=	NEURO->TempUltCo //TempoUltCompra

        oNeurotM:nVlrTotCRe	:=	NEURO->vlrTCReal    //ValorTotCompraRealizadas
        oNeurotM:nVlrTotC03	:=	NEURO->vlrTC03m     //ValorTotCompra03m
        oNeurotM:nVlrTotC12	:=	NEURO->vlrTC12m     //ValorTotCompra12m 
        oNeurotM:nVlrTotCPH	:=	NEURO->vlrTCHist    //ValorTotCompraPrazoHist		
        oNeurotM:nQtdTotC03	:=	NEURO->QtdTotC03  //QtdeTotCompra03m
        oNeurotM:nQtdCAVist	:=	NEURO->QtdCAVist  //QtdeComprasFeitasVista
        oNeurotM:nQtdTotCPH	:=	NEURO->QtdTotCPH  //QtdeTotCompraPrazoHist
        oNeurotM:nQtdTotC12	:=	NEURO->QtdTotC12  //QtdeTotCompraPrazo12m
        oNeurotM:nQtdTotCan	:=	NEURO->QtdTotCan  //QtdeTotCancelamentos

      
        oNeurotM:nAtraMes01	:=	NEURO->AtraMes01
        oNeurotM:nAtraMes02	:=	NEURO->AtraMes02
        oNeurotM:nAtraMes03	:=	NEURO->AtraMes03
        oNeurotM:nAtraMes04	:=	NEURO->AtraMes04
        oNeurotM:nAtraMes05	:=	NEURO->AtraMes05
        oNeurotM:nAtraMes06	:=	NEURO->AtraMes06
        oNeurotM:nAtraMes07	:=	NEURO->AtraMes07
        oNeurotM:nAtraMes08	:=	NEURO->AtraMes08
        oNeurotM:nAtraMes09	:=	NEURO->AtraMes09
        oNeurotM:nAtraMes10	:=	NEURO->AtraMes10
        oNeurotM:nAtraMes11	:=	NEURO->AtraMes11
        oNeurotM:nAtraMes12	:=	NEURO->AtraMes12
        oNeurotM:nMDA12M  	:=	NEURO->MDA12M

        NEURO->(dbSkip())

    EndDo  

    NEURO->(dbCloseArea()) 
  


Return  oNeurotM



Method GrpNeurot(oNeurot) Class TINNeurotechDAO

     
    Local cQuery := ""     

    cQuery += " SELECT "
    cQuery += " RTRIM(SZ9.Z9_CODIGO+' - '+SZ9.Z9_DESC) AS DESC_GRUPO_ECONOMICO, "                
    cQuery += " SZ9.Z9_LCGRUPO AS ltCredGrupo, "
    cQuery += " SA1.A1_VENCLC AS VENCIMENTO_CREDITO, "
    cQuery += " (SELECT SUM (A1_SALDUP) FROM "+RetSQLName("SA1")+" SA1 WITH (NOLOCK) WHERE  A1_COD IN (SELECT Z9_CODCLI FROM "+RetSQLName("SZ9")+" SZ9 WITH (NOLOCK)  WHERE  Z9_CODIGO = "+ValToSql(oNeurot:oCliente:oGrupoEco:cCodigo)+"))  AS ltCredUtilizadoGrpEco "

    cQuery += " FROM "+RetSQLName("SZ9")+" SZ9 WITH (NOLOCK) , "+RetSQLName("SA1")+" SA1 WITH (NOLOCK) "
    cQuery += " WHERE  SZ9.Z9_CODCLI = SA1.A1_COD  "
    cQuery += " AND SZ9.Z9_LOJA = SA1.A1_LOJA  "
    cQuery += " AND SA1.A1_COD  = " + ValToSql(oNeurot:oCliente:cCodigo)  
    cQuery += " AND SA1.A1_LOJA = " + ValToSql(oNeurot:oCliente:cLoja)    
    cQuery += " AND SZ9.D_E_L_E_T_ = ' '  "
   // cQuery += " GROUP BY SZ9.Z9_CODIGO, SA1.A1_NOME, SA1.A1_CGC, SA1.A1_SALDUP, SA1.A1_LC, SZ9.Z9_LCGRUPO, SA1.A1_VENCLC, SZ9.Z9_DESC   "
    cQuery += " ORDER BY  SA1.A1_NOME   "


    TcQuery cQuery new alias "Cliente" 
    oNeuro := TINNeurotechModel():New()

    Cliente->(DBGotop())  
        While !Cliente->(EOF()) 
            oNeuro:cDescGrEco :=	RTRIM(Cliente->DESC_GRUPO_ECONOMICO)	//DESC_GRUPO_ECONOMICO
            oNeuro:nLCredGrp  :=	Cliente->ltCredGrupo				//LIMITE_CREDITO_GRUPO
            oNeuro:dVencCred  :=	Cliente->VENCIMENTO_CREDITO				//VENCIMENTO_CREDITO
            oNeuro:nLCredUGE  :=	Round(Cliente->ltCredUtilizadoGrpEco,2)	//LIMITE_CREDITO_UTILIZADO_GRUPO_ECONOMICO    
            Cliente->(dbSkip())
        EndDo  
    Cliente->(dbCloseArea()) 






    // Info grupo

    cQuery := ""
    cQuery += " SELECT "    
    cQuery += " RTRIM(SA1.A1_NOME) AS NOME_CLIENTE, "
    cQuery += " SA1.A1_CGC AS CNPJ_CLIENTE, "
    cQuery += " SA1.A1_SALDUP AS ltCredSendoUtilizado, "
    cQuery += " SA1.A1_LC AS ltCredCLIENTE"            

    cQuery += " FROM "+RetSQLName("SZ9")+" SZ9 WITH (NOLOCK) , "+RetSQLName("SA1")+" SA1 WITH (NOLOCK) "
    cQuery += " WHERE  SZ9.Z9_CODCLI = SA1.A1_COD  "
    cQuery += " AND SZ9.Z9_LOJA = SA1.A1_LOJA  "
    cQuery += " AND SZ9.Z9_CODIGO = "+ValToSql(oNeurot:oCliente:oGrupoEco:cCodigo)
    cQuery += " AND SZ9.D_E_L_E_T_ = ' '  "
    cQuery += " GROUP BY SZ9.Z9_CODIGO, SA1.A1_NOME, SA1.A1_CGC, SA1.A1_SALDUP, SA1.A1_LC, SZ9.Z9_LCGRUPO, SA1.A1_VENCLC, SZ9.Z9_DESC   "
    cQuery += " ORDER BY  SA1.A1_NOME   "

    TcQuery cQuery new alias "Grupo" 
    Grupo->(DBGotop())  

        oNeuro:cCGC       :=	"" 
        oNeuro:cNomeClie  :=	"" 
        oNeuro:nLCredCli  :=	"" 
        oNeuro:nLCredUlt  :=	"" 
         While !Grupo->(EOF()) 
            oNeuro:cCGC       +=	RTRIM(cValToChar(Grupo->CNPJ_CLIENTE))+";"	
            oNeuro:cNomeClie  +=	RTRIM(cValToChar(Grupo->NOME_CLIENTE))+";"	                    //NOME_CLIENTE
            oNeuro:nLCredCli  +=	RTRIM(cValToChar(Grupo->ltCredCLIENTE))+";"	     	//LIMITE_CREDITO_CLIENTE
            oNeuro:nLCredUlt  +=	RTRIM(cValToChar(Grupo->ltCredSendoUtilizado))+";"	//LIMITE_CREDITO_SENDO_UTILIZADO       
            Grupo->(dbSkip())
        EndDo  
    Grupo->(dbCloseArea()) 


    // INFO DOS TITULOS EM ATRASO
    cQuery := ""
    cQuery += " SELECT  "
    cQuery += " 	SE1.E1_TIPO as E1_TIPO ,  "
    cQuery += " 	SE1.E1_NUM as E1_NUM,   "
    cQuery += " 	SE1.E1_EMISSAO as E1_EMISSAO,  "
    cQuery += " 	SE1.E1_VENCREA as E1_VENCREA,  "
    cQuery += " 	SE1.E1_VALOR as E1_VALOR,   "
    cQuery += " 	SE1.E1_BAIXA as E1_BAIXA,  "
    cQuery += " 	DATEDIFF ( DAY , SE1.E1_VENCREA,   GETDATE()  ) AS diasAtraso  "    
    cQuery += " FROM "+RetSQLName("SE1")+" SE1 WITH (NOLOCK)  "
    cQuery += " WHERE SE1.E1_CLIENTE = " + ValToSql(oNeurot:oCliente:cCodigo)  
    cQuery += " AND SE1.E1_LOJA = " + ValToSql(oNeurot:oCliente:cLoja)  
    cQuery += " AND  DATEDIFF (DAY, SE1.E1_VENCREA, GETDATE()) > 0  "
    cQuery += " AND SE1.E1_BAIXA = ''   "
    cQuery += " AND SE1.D_E_L_E_T_ = ''  "

    TcQuery cQuery new alias "DAtraso" 
    DAtraso->(DBGotop())   
    
        oNeuro:cE1TIPO      :=	""
        oNeuro:cE1NUM       :=	""
        oNeuro:cE1EMISSAO   :=	""
        oNeuro:cE1VENCREA   :=	""
        oNeuro:cE1VALOR     :=	""
        oNeuro:cDiasAtra    :=	""

        While !DAtraso->(EOF()) 
            oNeuro:cE1TIPO      +=	RTRIM(cValToChar(DAtraso->E1_TIPO))+";"
            oNeuro:cE1NUM       +=	RTRIM(cValToChar(DAtraso->E1_NUM))+";"
            oNeuro:cE1EMISSAO   +=	RTRIM(cValToChar(DAtraso->E1_EMISSAO))+";"
            oNeuro:cE1VENCREA   +=	RTRIM(cValToChar(DAtraso->E1_VENCREA))+";"
            oNeuro:cE1VALOR     +=	RTRIM(cValToChar(DAtraso->E1_VALOR))+";"
            oNeuro:cDiasAtra    +=	RTRIM(cValToChar(DAtraso->diasAtraso))+";"
            DAtraso->(dbSkip())
        EndDo  
    DAtraso->(dbCloseArea()) 
    
Return oNeuro


