#INCLUDE "Protheus.CH"
#INCLUDE "IMPRESH.CH"
#INCLUDE "MSOLE.CH"
#DEFINE   nColMax	2400
#DEFINE   nLinMax  2900


// VARIAVEIS UTILIZADAS PARA ARMAZENAR AS INFORMACOES DAS PERGUNTES:
//VARIAVEL					   ORDEM
//nTipo				MV_PAR01  01	//	ZEBRADO/GRAFICO/PRE-IMPR/GRFC ZEBRADO/GRFC GRAFICA
//cFilialDe			MV_PAR02  02	//	FILIAL DE
//cFilialAte		MV_PAR03  03	//	FILIAL ATE
//cMatDe			MV_PAR04  04	//	MATRICULA DE
//cMatAte			MV_PAR05  05	//	MATRICULA ATE
//cCCDe				MV_PAR06  06	//	CENTRO DE CUSTO DE
//cCCAte			MV_PAR07  07	//	CENTRO DE CUSTO ATE
//cTipoRes			MV_PAR08  08	//	NORMAL OU COMPLEMENTAR
//cImprCGC			MV_PAR09  09	//	IMPRIME CGC  SIM OU NAO
//dDtDemDe			MV_PAR10  10	//	DATA DEMISSAO DE
//dDtDemAte			MV_PAR11  11	//	DATA DEMISSAO ATE
//dDtGerDe			MV_PAR12  12	//	DATA GERACAO DE
//dDtGerAte			MV_PAR13  13	//	DATA GERACAO ATE
//nImprDtHom		MV_PAR14  14	//	IMPRIME DATA DE HOMOLOGACAO
//nNumVias			MV_PAR15  15	//	N∫ DE VIAS
//cImprFerias		MV_PAR16  16	//	IMP. FERIAS    		 AVOS OU DIAS
//dDtHomDe			MV_PAR17  17	//	DATA DE HOMOLOGAáCAO DE
//dDtHomAte			MV_PAR18  18	//	DATA DE HOMOLOGAáCAO AT
//cContato			MV_PAR19  19	//	NOME PARA CONTATO
//					MV_PAR20  20	//	RODAPE DO RECIBO
//					MV_PAR21  21	//	COMP. VERB 50
//					MV_PAR22  22	//	RG
//					MV_PAR23  23	//	NOME DO EMPREGADOR
//					MV_PAR24  24	//	TIPO DO ORGAO HOMOLOGADOR
//					MV_PAR25  25	// CODIGO DO MINISTERIO
//dDtDissidio		MV_PAR26  26	//	DT PUBLIC.DISS/ACOR
//nTipSal			MV_PAR27  27	//	TIPO DO SALARIO?
//					MV_PAR28  28	//	IMPRIMIR INF. EXTRA?
//					MV_PAR29  29	//	GRUPO DE VERBAS QUE COMPOEM A REMUNERACAO
//					MV_PAR30  30	//	IMPRIME CABECALHO EM OUTRA PAGINA?
//					MV_PAR31  31	//	AJUSTA LINHAS EM BRANCO?
//cImpr13Sal		MV_PAR32  32	//	IMP. 13∫ SAL¡RIO
//cTelefone			MV_PAR33  33	//	DDD/TELEFONE
//nSimples			MV_PAR34  34	//	OPTANTE DO SIMPLES
//dEntregaGRFC		MV_PAR35  35	//	DT. ENTREGA GRFC
//					MV_PAR36  36	//	TODAS RESCISOES COMPL?
//					MV_PAR37  37	//	Nome do Preposto
//					MV_PAR38  38	//	Doc. do Preposto

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥IMPRESH   ∫Autor  ≥Wagner Montenegro            ∫ Data ≥  15/12/2010 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Impressao da Rescisao em modo Grafico Homolognet                     ∫±±
±±∫          ≥                                                                     ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±≥                ATUALIZACOES SOFRIDAS DESDE A CONSTRUÄAO INICIAL.               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Programador ≥ Data     ≥CHAMADO/REQ≥  Motivo da Alteracao                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±|Mohanad     |07/02/2014|M12RH01    |Unificacao da Folha V12                     |±±
±±|            |          |     197401|                                            |±±
±±|Christiane V|09/06/2014|197401     |CorreÁıes na impress„o                      |±±
±±|Mariana M.  |19/09/2014|     TQJTRC|Ajuste na impress„o do Termo de Rescisao de ≥±±
±±|            |          |           |Contrato referente a impress„o de verbas na ≥±±
±±|            |          |           |parte dos descontos e ajuste na segunda     ≥±±
±±|            |          |           |pagina para que n„o corte mensagem no final ≥±±
±±|            |          |           |da impress„o                                ≥±±
±±|Renan Borges|22/09/2014|     TQJW89|Ajuste para imprimir o TRCT corretamente    ≥±±
±±|            |          |           |quando n„o houver a informaÁ„o de codigo sin≥±±
±±|            |          |           |dical.                                      ≥±±
±±|Renan Borges|20/10/2014|     TQRBOI|Ajuste para imprimir o TRCT corretamente    ≥±±
±±|            |          |           |quando de acordo com os parametros corretos ≥±±
±±|            |          |           |exigidos pela portaria N∫ 1.057.            ≥±±
±±|Vitor Pires |10/12/2014|     TQZUNO|Ajuste para imprimir o TRCT corretamente    ≥±±
±±|            |          |           |Conforme quantidade de verbas do calculo-   ≥±±
±±|            |          |           |AlteraÁ„o no controle dos incrementos de    ≥±±
±±|            |          |           |linha-RÈplica do chamado P11 TQXWCP         ≥±±
±±|Renan Borges|18/12/2014|     TRBTUU|Ajuste para contagem dos dias trabalhados   ≥±±
±±|            |          |           |corretamente, pois nestes casos o ultimo dia≥±±
±±|            |          |           |deve ser considerado como trabalhado.       ≥±±
±±|Henrique V. |02/03/15  |     TRBBVQ|Ajuste para imprimir corretamente Causa do  ≥±±
±±|            |          |           |Afast. no TRCT. RÈplica do Chamado TQVMH7   ≥±±
±±|Renan Borges|05/05/2015|     TSCNIN|Ajuste para imprimir o TRCT com o saldo de  ≥±±
±±|            |          |           |sal·rio correto, quando houver descontos,   ≥±±
±±|            |          |           |por exemplo de falta, que somandos sejam    ≥±±
±±|            |          |           |maiores que o valor do sal·rio.             ≥±±
±±|Gabriel A.  |11/11/2015|     TTOLKB|Ajuste para imprimir o conte˙do dos campos  ≥±±
±±|            |          |           |em PDF sem que os mesmo sejam estourados    ≥±±
±±|Allyson M.  |02/12/2015|     TTRFSO|Ajuste p/ campo 59 verificar aglutinacao.   ≥±±
±±|Raquel Hager|28/06/2016|     TVMQHH|Ajuste fSindic p/ imprimir os campos 31 e 32≥±±
±±|            |          |           |corretamente quando for trabalhador rural.  ≥±±
±±|Raquel Hager|28/06/2016|     TUZYQK|Retirada do limite de tamanho 40 do campo 20≥±±
±±|Gabriel A.  |04/07/2016|     TVIRJ2|Ajuste para imprimir corretamente os valores≥±±
±±|            |          |           |de horas extras a partir da 2™ via.         ≥±±
±±|Raquel Hager|28/06/2016|     TUZYQK|Ajustes na impress„o do TRCT.               ≥±±
±±|P. Pompeu...|06/07/2016|     TVOBKA|DiscriminaÁ„o das hrs normais e hrs DSR.    ≥±±
±±|Gabriel A.  |19/07/2016|     TVPWW3|Ajuste para imprimir corretamente os valores≥±±
±±|            |          |           |de horas extras a partir da 2™ via e n„o    ≥±±
±±|            |          |           |duplicar verbas.                            ≥±±
±±|Leandro Dr. |16/08/2016|     TUZZBH|Inclus„o de perguntas para identificar nome ≥±±
±±|            |          |           |e documento do empregador ou preposto.      ≥±±
±±|Raquel Hager|17/11/2016|     TWEYLV|Inclus„o do pergunte MV_PAR39 para separaÁ„o≥±±
±±|            |          |           |das verbas de MÈdias.                       ≥±±
±±|Raquel Hager|20/12/2016|TWEYLV     |RemoÁ„o dos ajustes do ch.TWEYLV para in-   ≥±±
±±|            |          |           |clus„o na branch correta.                   ≥±±
±±|Gustavo M.  |21/12/2016|MRH-897    |Ajuste na impressao de varias vias.		   ≥±±
±±|Paulo       |10/02/2017|MRH-208    |Inclus„o do tipo e o valor das verbas de    |±±
±±|Inzonha     |          |           |rubrica 95(outros) para apresentar o        |±±
±±|            |          |           |valor e o tipo quando dia ou horas   	   |±±
±±|Joao Balbino|21/03/2017|MPRIMESP666|Ajuste nas deduÁıes para que sejam exibidas ≥±±
±±|            |          |           |corretamente com pergunte de ln em branco   ≥±±
±±|Paulo       |31/07/17  |DRHPAG-3771|Ajuste para reconhecer o periodo            ≥±±
±±|Inzonha     |          |           |aquisitivo de verbas com id de calculo      ≥±±
±±|            |          |           |0086 lanÁadas manualmente.                  ≥±±
±±|Rafael R.   |20/10/17  |DRHPAG-6864|Ajuste de margens e alinhamento		       ≥±±
±±|Isabel N.   |07/11/17  |DRHPAG-7498|Ajuste na exibiÁ„o do n∫ de dias do campo 69≥±±
±¿ƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
User Function IMPRESH()

Private nPos		:= 0	//LINHA DE IMPRESSAO DO RELATORIO GRAFICO
Private nTot		:= 0
Private nNumMax		:= 18			//Numero maximo de verbas impressas no Detalhe da rescisao 
Private nImprime	:= 1 	//Variavel Auxiliar 
Private nImpre		:= 1 
Private CONTFL		:= 1				//CONTA PAGINA
Private nCausaPos 	:= 0
Private lSepCausa 	:= fSepCausa(cCausa, @nCausaPos)

//OBJETOS PARA IMPRESSAO GRAFICA - DECLARACAO DAS FONTES UTILIZADAS
Private oFont08, oFont09, oFont10, oFont10n, oFont12, oFont14n, oFont15n

oFont08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.,)
oFont09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.,)
oFont09n	:= TFont():New("Arial",09,09,,.T.,,,,.T.,.F.,)
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10n	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
oFont12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
oFont14n	:= TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
oFont15n	:= TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)

nEpoca:= SET(5,1910)
SET CENTURY ON 

fHomolog()

Set(5,nEpoca)
If nTdata > 8
	SET CENTURY ON
Else
	SET CENTURY OFF
EndIf
Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥fHomolog≥ Autor ≥ Wagner Montenegro       ≥ Data ≥ 15.12.10 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Impressao Formulario Homolonet                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ RdMake                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fHomolog()
Local aString		:= {} 
Local aAreaRCE		:= {} 
Local aHomDAux		:= {} 
Local aHomVAux		:= {}
Local nBloco1		:=360
Local nX	
Local aAreaSRD
Local aAreaSRV
Local nDescAux		:= 0
Local nDescRes		:= 0
Local nFalta		:= 0
Local nOrderSRD
Local nY,nW
Local nCkHomV		:=0
Local n_XX 
Local n_X
Local n_Y
Local n_XX1           
Local n_X1
Local n_X2
Local nXLin
Local n_Y1,nFor,nT
Local aPreSelect	:={}
Local cPreSelect	:=MV_PAR21
Local cDescPrep		:= ""
Local nAchou		:=0
Local cD1			:=""
Local cD2			:=""
Local aPer			:=	{}
Local cOrgao		:=""  
Local nCont   
Local nPosFixa		:= 0
Local cVrbFixa 		:= ""
Local cString      
Local cCompet 		:= GetMv( "MV_FOLMES",,Space(06) ) 
Local cDSRSalV		:= LoadCodDSR(.F.,SRA->RA_FILIAL)    
Local lTemVerba 	:= .F.
Local lHomolog		:= .F.
Local aTab25  		:= {}
Local nPenunSal 	:= 0.00
Local cItem			:= ''
Local cTpFalta		:= ""
Local lTrabRural	:= .F.
Local cVal69		:= ""
Local nVal69		:= 0
Local nPos115		:= 0 
Local nValLin		:= 0 
Local nHomD			:= 0 
Local lTotal  		:= .F.  
Local lTotal2  		:= .F.
Local lMudaLinha 	:= .T.
Local cDescr		:= ""
Local aVbAux		:= {}
Local i
Local cLAux			:= ""
Local cDescRub		:= "" 
Local cAuxRImp		:= ""
Local nVia			:= 1
Local cTipoVerb     :=""
Local cRotFech		:= ""
Local nRef			:= 0
Local cAuxTot		:= ""

Private aCpoForm	:={}
Private aCpoFor1	:={}
Private aCpoFormD	:={}
Private cCateg		:= fCateg(0)
Private cPercSRV	:=""
Private aCpoExtra	:={}
Private lQuebraD	:=.F.
Private lQuebraP	:=.F.
Private oBrush1
Private oBrush2		
Private nBoxIni	  	:=0
Private nLinLivre 	:=0
Private nCl01a		:=150
Private nCl01b		:=850
Private nCl02a		:=864
Private nCl02b		:=1563
Private nCl03a		:=1578
Private nCl03b		:=2280
Private nL			:=0 
Private nPD 		:=40
Private nPT 		:=05
Private nTamL		:=10
Private nAddL		:=85 
Private nTit		:=60 
Private nSubT		:=42
Private nTip		:=151
Private nXCol 
Private nRubric 	:=0
Private cCodAfa 	:= ""
Private nPagina 	:= 1 
Private cDescCateg	:= "EMPREGADO"
Private cCodSind 	:= ''
Private cNomeSind	:= ''
Static aCodFol		:={}  
Default lAjustaLin	:= .F.

If !fp_CodFol( @aCodFol , xFilial("SRV"), .F. )
	Return
Endif 

oPrint:StartPage()	//INICIA UMA NOVA PAGINA

Aadd(aCpoForm,{"72",2,STR0165,"006","",""}) // "Percentagem"
Aadd(aCpoForm,{"73",2,STR0166,"008","",""}) // "PrÍmios"
Aadd(aCpoForm,{"74",2,STR0167,"010","",""}) // "Viagens"
Aadd(aCpoForm,{"75",2,STR0168,"015","",""}) // "Sobreaviso"
Aadd(aCpoForm,{"76",2,STR0169,"016","",""}) // "Prontid„o"
Aadd(aCpoForm,{"77",2,STR0170,"018","",""}) // "Adicional por tempo de serviÁo"
Aadd(aCpoForm,{"78",2,STR0171,"019","",""}) // "Adicional por TransferÍncia de Localidade de Trabalho"
Aadd(aCpoForm,{"79",2,STR0172,"020","",""}) // "Sal·rio FamÌlia excedente ao Valor Legal"
Aadd(aCpoForm,{"80",2,STR0173,"021","",""}) // "Abono/GratificaÁ„o de FÈrias Excedente 20 dias de sal·rio"
Aadd(aCpoForm,{"81",2,STR0174,"022","",""}) // "Valor global di·rias para viagem Excedente 50% sal·rio"
Aadd(aCpoForm,{"82",2,STR0175,"023","",""}) // "Ajuda de Custo art. 470/CLT"
Aadd(aCpoForm,{"83",2,STR0176,"024","",""}) // "Etapas marÌtimos"
Aadd(aCpoForm,{"84",2,STR0177,"025","",""}) // "LicenÁa PrÍmio indenizada"
Aadd(aCpoForm,{"85",2,STR0178,"026","",""}) // "Quebra de Caixa"
Aadd(aCpoForm,{"86",2,STR0179,"027","",""}) // "PLR"
Aadd(aCpoForm,{"87",2,STR0180,"028","",""}) // "IndenizaÁ„o a TÌtulo de Incentivo ‡ demiss„o"
Aadd(aCpoForm,{"88",2,STR0181,"029","",""}) // "Bolsa Aprendizagem"
Aadd(aCpoForm,{"89",2,STR0182,"030","",""}) // "Abonos Desvinculados do Sal·rio"
Aadd(aCpoForm,{"90",2,STR0183,"031","",""}) // "Ganhos Eventuais Desvinculados do Sal·rio"
Aadd(aCpoForm,{"91",2,STR0184,"032","",""}) // "Reembolso Creche"
Aadd(aCpoForm,{"92",2,STR0185,"033","",""}) // "Reembolso Bab·"
Aadd(aCpoForm,{"93",2,STR0186,"034","",""}) // "GratificaÁ„o Semestral"

Aadd(aCpoFor1,{"96",1,STR0187,"178","",""}) // "IndenizaÁ„o art 9∫ Lei 7238/84"
Aadd(aCpoFor1,{"98",2,STR0188,"036","",""}) // "Multa art. 476-A & 5∫ da CLT"

Aadd(aCpoFormD,{"115",1,STR0189,"","",""})  // "Outros descontos n„o previstos acima"

If !Empty(mv_par37) .or. !Empty(mv_par38)
	cDescPrep := " ( "
	If !Empty(mv_par37) .and. !Empty(mv_par38)
		cDescPrep += AllTrim(mv_par37) + " - " + AllTrim(mv_par38)
	ElseIf !Empty(mv_par37)
		cDescPrep += AllTrim(mv_par37)
	Else
		cDescPrep += AllTrim(mv_par38)
	EndIf
	cDescPrep += " )"
EndIf

GPER140Sum(1,,,.T.)
GPER140Sum(2,,,.T.)
For nY:=1 to Len(aCpoForm)
	If Val(Strtran(StrTran(aCpoForm[nY,5],".",""),",","."))>0 
		nCkHomV++
	Endif
Next
For nY:=1 to Len(aCpoFor1)
	If Val(Strtran(StrTran(aCpoFor1[nY,5],".",""),",","."))>0 
		nCkHomV++
	Endif
Next

For nW:= 1 to Len(aHomV)
	If aHomV[nW,7]==0
	   nCkHomV++
	Endif
Next	   
If nCkHomV>=3
	nTamL:=nTamL+Int(nCkHomV/3)	
Endif                 

fRetTab(@aTab25,"S025",,,,,.T.)

//IMPRIME O CABECALHO DA RESCISAO (CAMPOS 01 A 32)
fCabec()

oPrint:say (nL+nSubT,nCl01a+30,STR0036, oFont10n) //"VERBAS RESCIS”RIAS"

nL:=nL+nSubT
nBoxIni:=nL      

//CABECALHO DE VERBAS RESCISORIAS
oPrint:say (nL+02+nSubT,nCl01a+30		,STR0037	, oFont10n) //"RUBRICAS"
oPrint:say (nL+02+nSubT,nCl01b-120		,STR0038	, oFont10n) //"VALOR"
oPrint:say (nL+02+nSubT,nCl02a+30		,STR0037	, oFont10n) //"RUBRICAS"
oPrint:say (nL+02+nSubT,nCl02b-120		,STR0038	, oFont10n) //"VALOR"
oPrint:say (nL+02+nSubT,nCl03a+30		,STR0037	, oFont10n) //"RUBRICAS"
oPrint:say (nL+02+nSubT,nCl03b-120		,STR0038	, oFont10n) //"VALOR" 
nL+=nSubT	
oPrint:line(nL,165,nL,nColMax )

//  |50| SALDO DE DIAS TRABALHADOS
n_Y:=0
n_Y1:=0
n_X:= GPER140Sum(1,1,"048/112",,,1) //CONSIDERAR AVISO PREVIO TRABALHADO NO MES COMO SALDO DE SALARIO
n_X1:=GPER140Sum(1,1,"048/112",,2,1)                     
n_X2:=GPER140Sum(2,1,"113",,2,1)

If n_X1 == Nil .or. empty(n_X1)
	n_X1 := 0
EndIf

If n_X2 == Nil .or. empty(n_X2)
	n_X2 := 0
EndIf

If !(Empty(Alltrim(cPreSelect)))
   	For nFor := 1 To Len( Alltrim(cPreSelect) ) Step 3
		aAdd( aPreSelect , SubStr( cPreSelect , nFor , 3 ) )
	Next nFor
	For nY:= 1 to Len(aPreSelect)
		For nT:= 1 to Len(aHomD)
			If aHomD[nT,4]==aPreSelect[nY]
				//VERIFICA SE O TIPO DE LANCAMENTO DA VERBA E EM HORAS OU EM DIAS
				cTpFalta := PosSrv(aHomD[nT,4],xFilial("SRV", SRA->RA_FILIAL),"RV_TIPO")
				//SE VERBA E EM HORAS, CONVERTE AS HORAS DE FALTA EM DIAS DE ACORDO COM AS HORAS/MES DO CADASTRO DO FUNCIONARIO
				If cTpFalta == "H"
					nFalta := Int(aHomD[nT,2]/Round(SRA->RA_HRSMES/30,2))
					//SE A FALTA FOR MENOR DO QUE UM DIA, NAO SERA DESCONTADA DO CAMPO 50
					If nFalta >= 1
						n_Y	+= aHomD[nT,3]
						n_Y1+= nFalta
						aHomD[nT,7]	:= 2
					EndIf
			   	//SE VERBA E EM DIAS, UTILIZA OS VALORES DIRETAMENTE
			   	ElseIf cTpFalta == "D"
					n_Y	+= aHomD[nT,3]
					n_Y1+= aHomD[nT,2]
					aHomD[nT,7]	:= 2
			   	EndIf
			Endif
		Next
	Next
Else
   n_Y:=0
   n_Y1:=0
Endif	
n_XX := n_X - n_Y   //VALOR
n_XX1:= n_X1 - n_Y1 //DIAS
nL+=37
If n_X >= n_Y .and. n_X1 >= n_Y1 
    //RETIRA O VALOR ANTERIORMENTE SOMADO AO PROVENTO
    nProv-= n_X
    //RECOMPOE O VALOR DE PROVENTO ATRAV…S DO VALOR LIQUIDO DO SALDO DE SALARIO
    nProv+= n_XX

    //RECOMPOE O VALOR DO DESCONTO, DEDUZINDO AS FALTAS (OU DEMAIS VERBAS CORRESPONDENTES) UTILIZADAS NO CALCULO DO SALDO DE SALARIO LIQUIDO
    nDesc-= n_Y
Else
    //RETIRA O VALOR ANTERIORMENTE SOMADO AO PROVENTO
    nProv -= n_X
    //RECOMPOE O VALOR DO DESCONTO, DEDUZINDO AS FALTAS (OU DEMAIS VERBAS CORRESPONDENTES) UTILIZADAS NO CALCULO DO SALDO DE SALARIO LIQUIDO
    nDesc 		-= n_X
	//-- Guarda o valor maximo do desconto do saldo
    nDescRes 	:= n_X
	//GUARDA A DIFERENCA ENTRE OS DESCONTOS E SALDO DE SALARIO
	nDescAux	:= Abs(n_XX)
	For nY := 1 To Len(aPreSelect)
		For nT := 1 To Len(aHomD)
			If nDescAux > 0 .And. aHomD[nT,4] == aPreSelect[nY]
				//HABILITA A EXIBICAO DA VERBA EM DEDUCOES
				aHomD[nT,7] := 0
				//VERIFICA SE HA VALOR A DESCONTAR E SE O VALOR DE DESCONTO DA VERBA EH MAIOR AO DESCONTO
				If aHomD[nT,3] >= nDescRes
					//DESCONTA O VALOR DA VERBA
					aHomD[nT,3] -= nDescRes
					//DESCONTA O VALOR DESCONTADO DO TOTAL A SER DESCONTADO
					nDescAux	-= nDescRes
					//ZERA O VALOR A DESCONTAR
					nDescRes 	:= 0
				ElseIf nDescRes > 0 
					//GUARDA O VALOR QUE NECESSITA SER DESCONTADO
					nDescRes := ( nDescRes - aHomD[nT,3] )
					//ZERA O VALOR A DESCONTAR
					aHomD[nT,3] -= aHomD[nT,3]
					//DESABILITA A EXIBICAO DA VERBA EM DEDUCOES
					aHomD[nT,7] := 2
					//DESCONTA O VALOR DESCONTADO DO TOTAL A SER DESCONTADO
					nDescAux	-= nDescRes
				EndIf
			EndIf
		Next nT
	Next nY
EndIf
oPrint:say (nL+nPT+10,nCl01a+30		,STR0039 + If(n_XX1<0,"00",StrZero(n_XX1,2)) + STR0040, oFont08) // 50 SALDO DE 00/DIAS SALARIO 
oPrint:say (nL+nPD+10,nCl01a+30		,STR0154 + StrZero(n_Y1,2)+STR0041, oFont08)                
oPrint:say (nL+nPD+10,nCl01b+10	,If(n_XX<0,TransForm(0,"@E 99,999,999.99"),TransForm(n_XX,"@E 99,999,999.99")), oFont10, , , , 1)
nRubric ++ 

//  |51| COMISSOES
oPrint:say (nL+nPT+10,nCl02a+30	,STR0045, oFont08)  //"51 COMISSOES"
oPrint:say (nL+nPD+10,nCl02b+10	,GPER140Sum(1,2,"007"), oFont10, , , , 1) 
nRubric ++

//  |52| GRATIFICACOES
oPrint:say (nL+nPT+10,nCl03a+30	,STR0046, oFont08)  //"52 GRATIFICACAO"
oPrint:say (nL+nPD+10,nCl03b+10	,GPER140Sum(1,2,"017"), oFont10, , , , 1) 
nRubric ++

nL+=nAddL+10
oPrint:line(nL,165,nL,nColMax )

// -------------------------------------------------------------------------------------------------------
//  |53| Insalubridade
// -------------------------------------------------------------------------------------------------------
cPercSRV:="" 
aVbAux := {}
cLAux := "1"
cAuxRImp := GPER140Sum(1,2,"013",,,,,,@aVbAux)
IF Alltrim(cAuxRImp) == '0,00' .AND. Len(aVbAux) > 0 

	For i:=1 to Len(aVbAux)
		IF i == 1
			oPrint:say (nL+nPT,&("nCl01a" )+30, STR0047 +  TransForm(GPER140Sum(1,2,"013",,2,1),"@E 999.99"), oFont08) //"53 Adicional de Insalubridade"  
		ELSE
	 		cDescRub := STR0047 +  TransForm(GPER140Sum(1,2,"013",,2,1),"@E 999.99")
	 		oPrint:say (nL+nPT,&("nCl01a" )+30, Substr(cDescRub,1,2)+"."+cLAux+" "+Substr(cDescRub,4), oFont08)  //"53 Adicional de Insalubridade"  
 			cLAux := Soma1(cLAux) 
 		ENDIF
 		oPrint:say (nL+nPD,&("nCl01a" )+30	,cPercSRV+" %", oFont08)
 		oPrint:say (nL+nPD,&("nCl01b")+10, aVbAux[i][2], oFont10, , , , 1) 
 		nRubric ++
 		fNewLine()
	Next i

ELSE
	oPrint:say (nL+nPT,&("nCl01a" )+30, STR0047 +  TransForm(GPER140Sum(1,2,"013",,2,1),"@E 999.99"), oFont08) //"53 Adicional de Insalubridade"   
	oPrint:say (nL+nPD,&("nCl01a" )+30	,cPercSRV+" %", oFont08) 
	oPrint:say (nL+nPD,&("nCl01b")+10,cAuxRImp, oFont10, , , , 1) 
	nRubric ++
	fNewLine()
	
	For i:=1 to Len(aVbAux)
 		cDescRub := STR0047 +  TransForm(GPER140Sum(1,2,"013",,2,1),"@E 999.99")
 		oPrint:say (nL+nPT,&("nCl01a" )+30, Substr(cDescRub,1,2)+"."+cLAux+" "+Substr(cDescRub,4), oFont08)  //"53 Adicional de Insalubridade"  
 		oPrint:say (nL+nPD,&("nCl01a" )+30	,cPercSRV+" %", oFont08)
 		oPrint:say (nL+nPD,&("nCl01b")+10, aVbAux[i][2], oFont10, , , , 1) 
 		nRubric ++
 		fNewLine()
 		cLAux := Soma1(cLAux) 
	Next i
ENDIF


// -------------------------------------------------------------------------------------------------------
//  |54| Periculosidade
// -------------------------------------------------------------------------------------------------------

cPercSRV:="" 
aVbAux := {}
cLAux := "1"
cAuxRImp := GPER140Sum(1,2,"014",,,,,,@aVbAux)
IF Alltrim(cAuxRImp) == '0,00' .AND. Len(aVbAux) > 0 

	For i:=1 to Len(aVbAux)
		IF i == 1
			oPrint:say (nL+nPT,&("nCl02a" )+30,STR0048 +  TransForm(GPER140Sum(1,2,"014",,2,1),"@E 999.99"), oFont08) //"54 Adicional de Periculosidade"
		ELSE
	 		cDescRub := STR0048 +  TransForm(GPER140Sum(1,2,"014",,2,1),"@E 999.99")
	 		oPrint:say (nL+nPT,&("nCl02a" )+30, Substr(cDescRub,1,2)+"."+cLAux+" "+Substr(cDescRub,4), oFont08)  //"54 Adicional de Periculosidade"
 			cLAux := Soma1(cLAux) 
 		ENDIF
 		oPrint:say (nL+nPD,&("nCl02a" )+30	,cPercSRV+" %", oFont08)
 		oPrint:say (nL+nPD,&("nCl02b")+10, aVbAux[i][2], oFont10, , , , 1) 
 		nRubric ++
 		fNewLine()
	Next i

ELSE 
	oPrint:say (nL+nPT,&("nCl02a" )+30, STR0048 +  TransForm(GPER140Sum(1,2,"014",,2,1),"@E 999.99"), oFont08)  //"54 Adicional de Periculosidade"
	oPrint:say (nL+nPD,&("nCl02a" )+30	,cPercSRV+" %", oFont08) 
	oPrint:say (nL+nPD,&("nCl02b")+10, cAuxRImp, oFont10, , , , 1) 
	nRubric ++
	fNewLine()
	
	For i:=1 to Len(aVbAux)
 		cDescRub := STR0048 +  TransForm(GPER140Sum(1,2,"014",,2,1),"@E 999.99")
 		oPrint:say (nL+nPT,&("nCl02a" )+30, Substr(cDescRub,1,2)+"."+cLAux+" "+Substr(cDescRub,4), oFont08)  //"54 Adicional de Periculosidade"
 		oPrint:say (nL+nPD,&("nCl02a" )+30	,cPercSRV+" %", oFont08)
 		oPrint:say (nL+nPD,&("nCl02b")+10, aVbAux[i][2], oFont10, , , , 1) 
 		nRubric ++
 		fNewLine()
 		cLAux := Soma1(cLAux) 
	Next i
ENDIF

//  |55| ADICIONAL NOTURNO
cPercSRV:="" 
oPrint:say (nL+nPT,nCl03a+30	,STR0049 + TransForm(GPER140Sum(1,2,"012",,2,1),"@E 999.99") + STR0050, oFont08) // "55 ADICIONAL NOTURNO XX HORAS"
oPrint:say (nL+nPD,nCl03a+30	,cPercSRV+" %", oFont08) 
oPrint:say (nL+nPD,nCl03b+10	,GPER140Sum(1,2,"012"), oFont10, , , , 1) 
nRubric ++

nL+=nAddL+05
oPrint:line(nL,165,nL,nColMax)

//  |56| HORAS EXTRAS
aAreaSRV:=GetArea()
SRV->(DbSetOrder(RETORDER("SRV","RV_FILIAL+RV_HOMOLOG+STR(RV_PERC,7,3)+RV_COD")))
SRV->(DbSeek(xFilial("SRV")+"004")) //004 = COD.HOMOLOGNET P/ H.EXTRA
While !SRV->(EOF()) .and. SRV->RV_HOMOLOG=="004"
	Aadd(aCpoExtra,{"56.",2,SRV->RV_DESC,(SRV->RV_PERC-100),0,0,SRV->RV_COD,""})
	SRV->(DbSkip())
Enddo 
RestArea(aAreaSRV)
aSort(aCpoExtra,,,{|x,y| x[7] < y[7]}) //ORDENADO POR CODIGO DA VERBA

nCont := 1
For nY := 1 to Len(aCpoExtra)
	For nx := 1 To Len(aHomV)
		nAchou := 0
		If ( nAchou := Ascan(aHomV,{|x| x[4]==aCpoExtra[nY,7] .AND. X[7] == 0 }) ) > 0	.AND. aHomV[nAchou,3] > 0
			aCpoExtra[nY,5] += aHomV[nAchou,2]
			aCpoExtra[nY,6] += aHomV[nAchou,3]						
			aHomV[nAchou,7] := 1
		ElseIf aCpoExtra[nY,5] == 0 .AND. aCpoExtra[nY,6] == 0 
			aCpoExtra[nY,8] := "D" //DELETADO
		Endif
	Next nx
Next nY

aSort(aCpoExtra,,, {|x,y| x[8]+Str(x[4])+x[7] < y[8]+Str(y[4])+y[7]})
nXCol := 1
If ( Len(aCpoExtra) = 0 ) .or. ( Len(aCpoExtra) > 0 .and. !Empty(aCpoExtra[1,8]) )
	oPrint:say (nL+nPT,nCl01a+30		,"56.1 " + STR0051 + " 0,00" + STR0050, oFont08) 
	oPrint:say (nL+nPD,nCl01a+30		,"   0,00%"	, oFont08) 
	oPrint:say (nL+nPD,nCl01b+10	,TransForm(0,"@E 99,999,999.99"), oFont10, , , , 1)
	nRubric ++
	fNewLine()    				
Else
	nCont	:=	1			
	For nY := 1 to Len(aCpoExtra)
		If !Empty(aCpoExtra[nY,8])
			Exit
		Endif
		aCpoExtra[nY,1] += cValToChar(nCont++)
		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30+If(nXCol>1,30,0),aCpoExtra[nY,1] + STR0051 + TransForm(aCpoExtra[nY,5],"@E 999.99") + STR0050, oFont08)
		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30+If(nXCol>1,80,40),TransForm(aCpoExtra[nY,4],"@E 999.99") + "%", oFont08)
		oPrint:say (nL+nPD,	&("nCl0" + cValToChar(nXCol) + "b")+10,TransForm(aCpoExtra[nY,6],"@E 99,999,999.99"), oFont10, , , , 1)
		nRubric ++
		fNewLine()
	Next nY
Endif
           
//  |57| GORJETAS
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0052, oFont08) 
oPrint:say (nL+nPD,	&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,2,"011"), oFont10, , , , 1) 
nRubric ++
fNewLine()

//  |58| DSR
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0053, oFont08)
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0054, oFont08)
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"033/430/1399"), oFont10, , , , 1) 
nRubric ++
fNewLine()

//  |59| REFLEXO DO DSR
aVbAux := {}
cLAux := "1"
cAuxRImp := GPER140Sum(1, 1, cDSRSalV,/*lCampo*/,/*nRef*/,/*nType*/,.T.,,@aVbAux)
If Alltrim(cAuxRImp) == '0,00' .And. Len(aVbAux) > 0 

	For i := 1 To Len(aVbAux)
		If i == 1
			oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0057, oFont08) //"59 Reflexo do DSR sobre o "
			oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0058, oFont08) //"59 Reflexo do DSR sobre o "
		Else
	 		cDescRub := STR0057
	 		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30, Substr(cDescRub,1,2)+"."+cLAux+" "+Substr(cDescRub,4), oFont08)  //"59 Reflexo do DSR sobre o "
	 		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0058, oFont08) //"Sal·rio Vari·vel"
 			cLAux := Soma1(cLAux) 
 		EndIf
 		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, aVbAux[i][2], oFont10, , , , 1) 
 		nRubric ++
 		fNewLine()
	Next i

Else
	oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0057, oFont08)  //"59 Reflexo do DSR sobre o "
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0058, oFont08) //"Sal·rio Vari·vel"
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, cAuxRImp, oFont10, , , , 1) 
	nRubric ++
	fNewLine()
	
	For i := 1 To Len(aVbAux)
 		cDescRub := STR0057
 		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30, Substr(cDescRub,1,2)+"."+cLAux+" "+Substr(cDescRub,4), oFont08)  //"59 Reflexo do DSR sobre o "
 		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30, STR0058, oFont08) //"Sal·rio Vari·vel"
 		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, aVbAux[i][2], oFont10, , , , 1) 
 		nRubric ++
 		fNewLine()
 		cLAux := Soma1(cLAux) 
	Next i
EndIf

//  |60| MULTA ART. 477
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0059, oFont08)  
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,2,"009"), oFont10, , , , 1) 
nRubric ++
fNewLine()

If Alltrim(GPER140Sum(1,1,"176")) <> "0,00"
	//  |61| MULTA ART. 479
	oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,STR0060, oFont08) 
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"176"), oFont10, , , , 1) 
	nRubric ++
	fNewLine()
Endif
//  |62| SALARIO FAMILIA
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0055, oFont08) 
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"034"), oFont10, , , , 1) 
nRubric ++
fNewLine()

//  |63| 13∫ SALARIO PROPORCIONAL
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0061, oFont08) 
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , If(aScan(aHomV, {|aHomV| aHomV[5] == "114"}) == 0, GPER140Sum(1,1,"251",,2), GPER140Sum(1,1,"114",,2) )+"/12 avos"	, oFont08) 

If MV_PAR01 == 4 .AND. !Empty(MV_PAR39) .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2 
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"114"), oFont10, , , , 1) // 13O     
Else
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"114/251"), oFont10, , , , 1) // 13O + Medias
EndIf
nRubric ++
fNewLine()
//Separacao das medias
If MV_PAR01 == 4 .AND. MV_PAR39 == 2
	cDesVMed := Capital(Alltrim(Posicione("SRV",2,xFilial("SRV")+"0251","RV_DESC"))) 
	If !Empty(cDesVMed)
		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "63.1 "+cDesVMed, oFont08) 
		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"251"), oFont10, , , , 1) // 13O     
	
		nRubric ++
		fNewLine()
	EndIf
EndIf


//  |64| 13∫ SALARIO VENCIDO
If Len(aTab25) > 0 .and. (nAchou := aScan(aTab25, {|x| x[5] = '64'})) > 0
	cVrbFixa := aTab25[nAchou,6]
	nPosFixa := aScan(aHomV, {|x| x[4] = cVrbFixa})
Endif

If nPosFixa > 0
	oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0062 + " " + SubStr(aHomV[nPosFixa,9],3,4), oFont08)
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , SubStr(aHomV[nPosFixa,9],1,2) + "/12 " + STR0064, oFont08)  
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b" )+10, TransForm(aHomV[nPosFixa,3],"@E 99,999,999.99"), oFont10, , , , 1)  
	aHomV[nPosFixa,7] := 1
Else
	oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0062, oFont08)
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , " __/12 " + STR0064, oFont08)
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, TransForm(0,"@E 99,999,999.99"), oFont10, , , , 1)  
Endif
nRubric ++
fNewLine()

//  |65| FERIAS PROPORCIONAIS
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0065, oFont08) 
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , If(aScan(aHomV, {|aHomV| aHomV[5] == "087"}) == 0, GPER140Sum(1,1,"249",,2), GPER140Sum(1,1,"087",,2) )+"/12 " + STR0064, oFont08)  

If MV_PAR01 == 4 .AND. MV_PAR39 == 2 
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"087"), oFont10, , , , 1) // Ferias Proporcionais     
Else
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"087/249"), oFont10, , , , 1) // Ferias Proporcionais + Medias
EndIf
nRubric ++
fNewLine()

//Separacao das medias
If MV_PAR01 == 4 .AND. !Empty(MV_PAR39) .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
	cDesVMed := Capital(Alltrim(Posicione("SRV",2,xFilial("SRV")+"0249","RV_DESC"))) 
	If !Empty(cDesVMed) 
		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "65.1 "+cDesVMed, oFont08) 
   		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"249"), oFont10, , , , 1) 

  		nRubric ++
 		fNewLine() 
	EndIf
EndIf

//  |66| FERIAS VENCIDAS
cRotFech := fPerFech( SRA->RA_PROCES, fGetCalcRot('1'), xFilial("RCH",SRA->RA_FILIAL))
If cRotFech  < AnoMes(SRG->RG_DATADEM) 
	aPer := fPerAquisitivo()
Else
	aVbAux := {}
	GPER140Sum(1,1,"086",,,,,,@aVbAux)
	For i := 1 to Len(aVbAux)
		nRef := aVbAux[i][4]
		If (aVbAux[i][4] - Int(aVbAux[i][4])) = 0.12
			nRef := Int(aVbAux[i][4]) * 2.5
		EndIf
		aadd(aPer,{Stod(Substr(aVbAux[i][3],1,8)),Stod(Substr(aVbAux[i][3],12,8)) ,nRef,nRef})
	Next
EndIf
If Len(aPer) = 0 .or. (Len(aPer) == 1 .and. aPer[1,4] < 30)
	oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "66.1 " + STR0066, oFont08) 
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , '  /  /  '+" a "+'  /  /  ', oFont08)
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, TransForm(0,"@E 99,999,999.99"), oFont10, , , , 1)
	nRubric ++  
	fNewLine()
Else
	nCont 	:= 1    
	nTotal	:= 0
	nA	  	:= 0
	lTotAux := .F.
	 
	For nY := 1 to Len(aPer)
		If aPer[nY,3] == 30
			cAuxTot := GPER140Sum(1, 1, "086", Nil, 2, Nil, Nil, DTOS(aPer[nY,1]) + " - " + DTOS(aPer[nY,2])) 
			//Se retornar mais do que 12 avos, significa que foi gerado o valor referente a 2 ou mais periodos vencidos
			If Val(cAuxTot) > 12
				lTotAux := .T.
			Endif
			nA ++
		Endif
	Next

	If lTotAux
		aEval(aHomV, {|aHomV| If( aHomV[5] $ "086/248", nTotal += aHomV[3], Nil) } )
	Endif
	
	For nY := 1 to Len(aPer)
		           
		If aPer[nY,3] > 0
			oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "66." + cValToChar(nCont) + " " + STR0066, oFont08) 
			oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,DTOC(aPer[nY,1])+" a "+DTOC(aPer[nY,2]), oFont08) 
			If ( Len(aPer) > 1 .And. DTOS(dDemSabDom) < DTOS(aPer[nY,2]) .And. DTOS(dDemSabDom) > DTOS(aPer[nY,1]) ) .Or. ( Len(aPer) == 1 .And. Val(cAuxTot) == 0 )  
				If MV_PAR01 == 4 .And. !Empty(MV_PAR39) .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
					oPrint:say (nL+nPD,	&("nCl0" + cValToChar(nXCol) + "b")+10,GPER140Sum(1,1,"086",,,,,DTOS(aPer[nY,1]) + " - " + DTOS(dDemSabDom)), oFont10, , , , 1)    
				Else
					oPrint:say (nL+nPD,	&("nCl0" + cValToChar(nXCol) + "b")+10,GPER140Sum(1,1,"086/248",,,,,DTOS(aPer[nY,1]) + " - " + DTOS(dDemSabDom)), oFont10, , , , 1)
				EndIf
				nRubric ++
			Else
				If MV_PAR01 == 4 .And. !Empty(MV_PAR39) .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
					oPrint:say (nL+nPD,	&("nCl0" + cValToChar(nXCol) + "b")+10,If(lTotAux,Transform(nTotal/nA,"@E 99,999,999.99"),GPER140Sum(1,1,"086",,,,,DTOS(aPer[nY,1]) + " - " + DTOS(aPer[nY,2]))), oFont10, , , , 1)    
				Else
					oPrint:say (nL+nPD,	&("nCl0" + cValToChar(nXCol) + "b")+10,If(lTotAux,Transform(nTotal/nA,"@E 99,999,999.99"),GPER140Sum(1,1,"086/248",,,,,DTOS(aPer[nY,1]) + " - " + DTOS(aPer[nY,2]))), oFont10, , , , 1) 
				EndIf
				
				nRubric ++
			Endif	
			fNewLine()
			nCont++
			
			//Separacao das medias
			IF MV_PAR01 == 4 .And. !Empty(MV_PAR39) .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
				aVbAux := {}
				cDesVMed := Capital(Alltrim(Posicione("SRV",2,xFilial("SRV")+"0248","RV_DESC")))
				GPER140Sum(1,1,"248",,,,,,@aVbAux)
				For i:=1 to Len(aVbAux)
			 		dtAuxI := Stod(Substr(aVbAux[i][3],1,8))
			 		dtAuxF := Stod(Substr(aVbAux[i][3],12,8)) 
	 				If !Empty(cDesVMed) .and. aPer[nY][1] == dtAuxI .and. aPer[nY][2] == dtAuxF  
				 		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "66." + cValToChar(nCont) +" "+cDesVMed, oFont08)
				 		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , iif( !Empty(aVbAux[i][3]), Dtoc(stod(Substr(aVbAux[i][3],1,8))) + " a " + Dtoc(stod(Substr(aVbAux[i][3],12,8))) ,'  /  /  '+" a "+'  /  /  '), oFont08) 
						oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, aVbAux[i][2], oFont10, , , , 1) 
						nCont++
						nRubric ++ 
						fNewLine() 
					EndIf
				Next i
			EndIf
			
		Endif
	Next nY
Endif

//  |67| FERIAS EM DOBRO
aPerDobra := {}
If aCodFol[224,1] # Space(3)
	If ( nAchou := Ascan(aHomV,{|x| x[4]==aCodFol[224,1]}) ) > 0
		While nAchou <= Len(aHomV) .and. aHomV[nAchou,4]==aCodFol[224,1]
			cString := aHomV[nAchou,9]
			aAdd(aPerDobra,{STOD(SubStr(cString,1,At("-",cString)-1)),STOD(SubStr(cString,At("-",cString)+2,Len(cString))),aHomV[nAchou,3]})
			aHomV[nAchou,7]:=1
			nAchou++
		Enddo
	Endif
Endif
If aCodFol[925,1] # Space(3)
	If ( nAchou := Ascan(aHomV,{|x| x[4]==aCodFol[925,1]}) ) > 0
		While nAchou <= Len(aHomV) .and. aHomV[nAchou,4]==aCodFol[925,1]
			cString := aHomV[nAchou,9]
			aAdd(aPerDobra,{STOD(SubStr(cString,1,At("-",cString)-1)),STOD(SubStr(cString,At("-",cString)+2,Len(cString))),aHomV[nAchou,3]})
			aHomV[nAchou,7]:=1
			nAchou++
		Enddo
	Endif
Endif

IF Len(aPerDobra) > 0
	aSort(aPerDobra,,,{|x,y| x[1] < y[1]})
	For nY := 1 to Len(aPerDobra)
		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "67." + cValToChar(nY) + " " + STR0063, oFont08) 
		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,DTOC(aPerDobra[nY,1])+STR0067+DTOC(aPerDobra[nY,2]), oFont08)
		oPrint:say (nL+nPD,	&("nCl0" + cValToChar(nXCol) + "b")+10,TransForm(aPerDobra[nY,3],"@E 99,999,999.99"), oFont10, , , , 1)
		nRubric ++
		fNewLine()
	Next nY
Endif

//  |68| 1/3 DE FERIAS 
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0068, oFont08) 
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10	,GPER140Sum(1,1,"125/226/231/926"), oFont10, , , , 1) 
nRubric ++
fNewLine()

//  |69| AVISO PREVIO INDENIZADO
If MV_PAR01 == 4 .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
	cVal69	:= GPER140Sum(1,1,"111")
Else
	cVal69	:= GPER140Sum(1,1,"111/250")
EndIf
If ( nAchou := Ascan(aHomV,{|x| x[5] == "111"}) ) > 0
	nVal69 := aHomV[nAchou,2]
EndIf
If ( Val(cVal69) > 0 )
	oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0069, oFont08)
	oPrint:say(nL+nPT+28,&("nCl0" + cValToChar(nXCol) + "a" )+30 , Space(1) + Str(nVal69,5,1) + STR0151, oFont08)
Else
	oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0069 , oFont08)
EndIf

oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, cVal69 , oFont10, , , , 1) 
nRubric ++
fNewLine()

//Separacao das medias
IF MV_PAR01 == 4 .AND. MV_PAR39 == 2 
	cDesVMed := Capital(Alltrim(Posicione("SRV",2,xFilial("SRV")+"0250","RV_DESC"))) 
 	IF !Empty(cDesVMed)
		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "69.1 "+cDesVMed, oFont08) 
		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"250"), oFont10, , , , 1) 

 		nRubric ++ 
 		fNewLine()
	ENDIF
ENDIF

//  |70| 13∫ SALARIO S/ AVISO PREVIO
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0070, oFont08) 
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0071, oFont08) 		
IF MV_PAR01 == 4 .AND. !Empty(MV_PAR39) .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"115"), oFont10, , , , 1)
ELSE
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"115/253"), oFont10, , , , 1)
ENDIF
nRubric ++
fNewLine() 

//Separacao das medias
If MV_PAR01 == 4 .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
	cDesVMed := Capital(Alltrim(Posicione("SRV",2,xFilial("SRV")+"0253","RV_DESC"))) 
 	If !Empty(cDesVMed)
  		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "70.1 "+cDesVMed, oFont08) 
 		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"253"), oFont10, , , , 1) 

 		nRubric ++ 
  		fNewLine()
  	EndIf
EndIf

//  |71| FERIAS S/ AVISO PREVIO
oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0119, oFont08)
oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0071, oFont08) 		
If MV_PAR01 == 4 .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"230"), oFont10, , , , 1)
Else
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"230/252"), oFont10, , , , 1)
EndIf
nRubric ++
fNewLine()  

//Separacao das medias
If MV_PAR01 == 4 .And. !Empty(MV_PAR39) .And. MV_PAR39 == 2
	cDesVMed := Capital(Alltrim(Posicione("SRV",2,xFilial("SRV")+"0252","RV_DESC"))) 
 	If !Empty(cDesVMed) 
 		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , "71.1 "+cDesVMed, oFont08) 
  		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, GPER140Sum(1,1,"252"), oFont10, , , , 1) 

 		nRubric ++ 
  		fNewLine()
  	EndIf
EndIf

//  |72| PERCENTAGEM - A - |93| GRATIFICACAO SEMESTRAL
For nY := 1 to Len(aCpoForm)
   	If Val(Strtran(StrTran(aCpoForm[nY,5],".",""),",","."))>0 
		oPrint:line(nL,165,nL,nColMax )
		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,aCpoForm[nY,1]+" "+Substr(aCpoForm[nY,3],1,31), oFont08) 
		If Len(aCpoForm[nY,3])>31
			oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,Substr(aCpoForm[nY,3],32,34), oFont08) 
		Endif
		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10,aCpoForm[nY,5], oFont10, , , , 1) 
		nRubric ++
		fNewLine()
	Endif
Next

//  |94| SALARIO DO MES ANTERIOR A RESCISAO
nPosFixa := 0
If Len(aTab25) > 0 .and. (nAchou := aScan(aTab25, {|x| x[5] = '94'})) > 0
	cVrbFixa := aTab25[nAchou,6]
	nPosFixa := aScan(aHomV, {|x| x[4] = cVrbFixa})
Endif

If nPosFixa > 0
	oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 , STR0120, oFont08) 
	oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10, TransForm(aHomV[nPosFixa,3],"@E 99,999,999.99"), oFont10, , , , 1) 
	aHomV[nPosFixa,7] := 1
	nRubric ++
	fNewLine()
Endif

//  |95| OUTROS
nCont := 1
//Aglutina as verbas que serao geradas no campo 95
For nY:= 1 to Len(aHomV)
	If aHomV[nY,7] != 0 .Or. ( ( nPos95 := aScan( aHomVAux, { |aHomVAux| aHomVAux[4] == aHomV[nY,4] } ) ) == 0 )
		Aadd(aHomVAux,{aHomV[nY,1],aHomV[nY,2],aHomV[nY,3],aHomV[nY,4],aHomV[nY,5],aHomV[nY,6],aHomV[nY,7],aHomV[nY,8],aHomV[nY,9],aHomV[nY,10] })
	Else
		aHomVAux[nPos95,3] += aHomV[nY,3]
	EndIf
Next
aHomV := aClone( aHomVAux )
For nY:= 1 to Len(aHomV)
	If aHomV[nY,7]==0
		oPrint:line(nL,165,nL,nColMax )
		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,"95."+AllTrim(Str(nCont))+" "+Capital(Substr(aHomV[nY,1],1,20)), oFont08) 
		
			DO CASE
				CASE aHomV[nY,10] = "D"
				cTipoVerb := "	(" +  CValToChar(aHomV[nY,2]) + " Dia(s))"
				CASE aHomV[nY,10] = "H"
				cTipoVerb := "	(" +  CValToChar(aHomV[nY,2]) + " Horas(s))"
			END CASE		
		
		If Len(aHomV[nY,1])>33
				if ((Len(aHomV[nY,1]) - 20) + Len(cTipoVerb) ) < 23
				oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,Substr(aHomV[nY,1],21) +' '+ cTipoVerb, oFont08) 
				else
					oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,Substr(aHomV[nY,1],21,23), oFont08) 
				endif
			else
				oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 , cTipoVerb , oFont08)
			Endif
			
		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10,TransForm(aHomV[nY,3],"@E 99,999,999.99"), oFont10, , , , 1) 
		nRubric ++
		nCont++
		fNewLine()
	ElseIf nY > 1 .And. nxCol == 3
		If aHomV[nY -1 ,7]==0
			lMudaLinha := .F.
		Endif
	Endif
Next  

//  |96| INDENIZACAO ART. 9∫, LEI N∫ 7.238/1984 - A - |98| MULTA ART. 476-A & 5∫ DA CLT"
For nY := 1 to Len(aCpoFor1)
	If Val(Strtran(StrTran(aCpoFor1[nY,5],".",""),",","."))>0 
		oPrint:line(nL,165,nL,nColMax )
		oPrint:say (nL+nPT,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,aCpoFor1[nY,1]+" "+Substr(aCpoFor1[nY,3],1,33), oFont08) 
		If Len(aCpoFor1[nY,3])>33
			oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "a" )+30 ,aCpoFor1[nY,1]+" "+Substr(aCpoFor1[nY,3],34,33), oFont08) 
		Endif
		oPrint:say (nL+nPD,&("nCl0" + cValToChar(nXCol) + "b")+10,aCpoFor1[nY,5], oFont10, , , , 1) 
		lMudaLinha := .T.
		nRubric ++
		If nxCol == 2
			nxCol:=3
		EndIf
		fNewLine()
	Endif
Next

If !lAjustaLin
	IF nL <= 2500
		While nL <= 2500
	   		fNewLine()
		Enddo
	Endif                     
Else
	fAjustaLin(nRubric)
	For nXlin := 1 to nLinLivre
		nL+=nAddL+05
		oPrint:line(nL,165,nL,nColMax )		
	Next
Endif 
If lMudaLinha
	If nxCol == 3 
		fNewLine()
	EndIf
	nxCol:= 2
Endif

if nxCol>=2
   fNewLine()
Endif	

//  |99| AJUSTE DO SALDO DEVEDOR fixo na coluna 2
oPrint:say (nL+nPT,&("nCl02a" )+30 , STR0153, oFont08) 
oPrint:say (nL+nPD,	&("nCl02b")+10, GPER140Sum(1,1,"045"), oFont10, , , , 1) 

if nxCol = 1 
   fNewLine()
Endif   

oPrint:FillRect( {nL+05, nCl03a+02, nL+nAddL+05, nColMax}, oBrush1 )  

oPrint:say (nL+nPT+20,nCl03a+30,STR0072, oFont09n) //"TOTAL BRUTO" 
oPrint:say (nL+nPD,nCl03b,Transform(nProv,"@E 999,999,999.99"), oFont10, , , , 1)

nL+=nAddL+05

//FECHA O BOX E CRIA AS LINHAS VERTICAIS
oPrint:Box( nBoxIni, 165 ,nL,nColMax )
oPrint:line(nBoxIni,nCl01b+20-200,nL,nCl01b+20-200 )
oPrint:line(nBoxIni,nCl02a,nL,nCl02a )
oPrint:line(nBoxIni,nCl02b+20-200,nL,nCl02b+20-200 )
oPrint:line(nBoxIni,nCl03a,nL,nCl03a )
oPrint:line(nBoxIni,nCl03b+20-200,nL,nCl03b+20-200 )

nTamL:=5

fVerQuebra(2, .F., .T.)

oPrint:Box(nL, 165,nL+nSubT, nColMax ) 									
oPrint:say (nL+05,nCl01a+30,STR0073, oFont10n)	//"DEDU«’ES"
nL+=nSubT

fVerQuebra(2, .F.)

nCkHomV:=0
For nY:=1 to Len(aCpoFormD)
	If Val(Strtran(StrTran(aCpoFormD[nY,5],".",""),",","."))>0 
		nCkHomV++
	Endif
Next		
nBoxIni:=nL	
For nX:=1 to nTamL
	If nX==1
		oPrint:say (nL+02,nCl01a+30   	,STR0074, oFont10n)	 	 //"DESCONTO"
		oPrint:say (nL+02,nCl01b-120	,STR0038, oFont10n) 	 //"VALOR"
		oPrint:say (nL+02,nCl02a+30		,STR0074, oFont10n) 	 //"DESCONTO"
		oPrint:say (nL+02,nCl02b-120	,STR0038, oFont10n) 	 //"VALOR"
		oPrint:say (nL+02,nCl03a+30		,STR0074, oFont10n) 	 //"DESCONTO"
		oPrint:say (nL+02,nCl03b-120	,STR0038, oFont10n) 	 //"VALOR"
	Elseif nX==2
		oPrint:say (nL+nPT,nCl01a+30	,STR0075, oFont08)  //"100 PENSAO ALIMENTICIA"
		oPrint:say (nL+nPD,nCl01b+10	,GPER140Sum(2,3,"172/170/128/058/056"), oFont10, , , , 1) // DENTRO DA ROTINA OS IDENTIFICADORES SERAO IGNORADOS
		oPrint:say (nL+nPT,nCl02a+30	,STR0076, oFont08)  //"101 ADIANTAMENTO SALARIAL"
		oPrint:say (nL+nPD,nCl02b+10	,GPER140Sum(2,2,"A01"), oFont10, , , , 1) 
		oPrint:say (nL+nPT,nCl03a+30	,STR0077, oFont08)  //"102 ADIANTAMENTO DE 13∫ SALARIO"
		oPrint:say (nL+nPD,nCl03b+10	,GPER140Sum(2,2,"A02"), oFont10, , , , 1) 
	Elseif nX==3
		oPrint:say (nL+nPT,nCl01a+30	,STR0078+" ", oFont08)  //"103 AVISO-PREVIO INDENIZADO" 
		oPrint:say (nL+nPT+28,nCl01a+30	, StrZero(n_X2,2)+STR0151, oFont08)  //"103 AVISO-PREVIO INDENIZADO"
		oPrint:say (nL+nPD,nCl01b+10	,GPER140Sum(2,1,"113"), oFont10, , , , 1) 

	    nValLin:=2

	   	If Alltrim(GPER140Sum(2,2,"A09") ) <> "0,00" 
	   		oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a") +30	,STR0079, oFont08)  //"104 MULTA ART. 480/CLT"
	   		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A09"), oFont10, , , , 1)
	   		nValLin++
	   	Endif
		IF Alltrim(GPER140Sum(2,2,"A08")) <> "0,00" 
	   		oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0080, oFont08)  //"105 EMPRESTIMO EM CONSIGNACAO"
	   		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A08"), oFont10, , , , 1)
	   		fDesconto(@nValLin)
		Endif
		IF Alltrim(GPER140Sum(2,2,"A04")) <> "0,00" 
			oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0081, oFont08)  //"106 VALE-TRANSPORTE"
			oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A04"), oFont10, , , , 1)
		    fDesconto(@nValLin)
	   	Endif
	   	IF Alltrim(GPER140Sum(2,2,"A06")) <> "0,00" 
	   		oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0082, oFont08)  //"107 REEMBOLSO DO VALE-TRANSPORTE"
	   		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A06"), oFont10, , , , 1)
	   		fDesconto(@nValLin)
	   	Endif
	   	IF Alltrim(GPER140Sum(2,2,"A05")) <> "0,00" 
	   		oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0083, oFont08)  //"108 VALE-ALIMENTACAO"
			oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A05"), oFont10, , , , 1)
		    fDesconto(@nValLin)
	   	Endif
	   	IF Alltrim(GPER140Sum(2,2,"A07")) <> "0,00" 	 
			oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30  		,STR0084, oFont08)  //"109 REEMBOLSO VALE-ALIMENTACAO"
	   		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A07"), oFont10, , , , 1)
	   		fDesconto(@nValLin)
		Endif
		IF Alltrim(GPER140Sum(2,2,"A11")) <> "0,00" 
			oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0085, oFont08)  //"110 CONTIBUICAO PARA O FAPI"
			oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A11"), oFont10, , , , 1)
			fDesconto(@nValLin)
		Endif
		IF Alltrim(GPER140Sum(2,2,"A13")) <> "0,00" 
			oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0086, oFont08)  //"111 CONTRIBUICAO SINDICAL LABORAL"
			oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A13"), oFont10, , , , 1)
			fDesconto(@nValLin)
		Endif
		oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30  	,STR0087, oFont08)  //"112.1 PREVIDENCIA SOCIAL"
   		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,1,"064/065"), oFont10, , , , 1)
   		fDesconto(@nValLin)
   		
  		oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0088, oFont08)  //"112.2 PREVIDENCIA SOCIAL 13∫ SALARIO"
   		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,1,"070"), oFont10, , , , 1)
   		fDesconto(@nValLin)
	   		 
        If Alltrim(GPER140Sum(2,2,"A10")) <> "0,00" 
        	oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0089, oFont08)  //"113 CONTRIBUICAO PREVIDENCIA "
			oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0090, oFont08)  //"COMPLEMENTAR"
	   		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,2,"A10"), oFont10, , , , 1)
	   		fDesconto(@nValLin)
	   	Endif  
	   	
   		oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30  	,STR0091, oFont08)  //"114.1 IRRF"
		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,1,"066/067"), oFont10, , , , 1)
		fDesconto(@nValLin)
     
		oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0092, oFont08)  //"114.2 IRRF SOBRE 13∫ SALARIO"
		oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,1,"071"), oFont10, , , , 1)
		fDesconto(@nValLin)

		IF Alltrim(GPER140Sum(2,1,"152")) <> "0,00" 
			oPrint:say (nL+nPT,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0093, oFont08)  //"114.3 IRRF SOBRE PARTICIPACAO NOS "
		  	oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"a")+30	,STR0094, oFont08)  //"LUCROS OU RESULTADOS"
			oPrint:say (nL+nPD,&("nCl0"+STR(nValLIn,1)+"b")+10	,GPER140Sum(2,1,"152"), oFont10, , , , 1)
		  	fDesconto(@nValLin)
		Endif
	Elseif nX=4 
        //AGLUTINA AS VERBAS QUE SERAO GERADAS NO CAMPO 115
   		For nY:= 1 to Len(aHomD)
			If aHomD[nY,7] != 0 .Or. ( ( nPos115 := aScan( aHomDAux, { |aHomDAux| aHomDAux[4] == aHomD[nY,4] } ) ) == 0 )
				Aadd(aHomDAux,{aHomD[nY,1],aHomD[nY,2],aHomD[nY,3],aHomD[nY,4],aHomD[nY,5],aHomD[nY,6],aHomD[nY,7],aHomD[nY,8],aHomD[nY,9] })
			Else
				aHomDAux[nPos115,3] += aHomD[nY,3]
			EndIf
		Next
		aHomD := aClone( aHomDAux )
   		For nY:= 1 to Len(aHomD)
			If aHomD[nY,7]==0 .Or. aHomD[nY,7]==1
			   nCkHomV++
			Endif
		Next
		If nCkHomV>=4
			nTamL:=nTamL+Int((nCkHomV-4)/3)	
		Endif  
			
		If nCkHomV<4
			nW:=nValLin-1
			For nY := 1 to Len(aCpoFormD)
				If Val(Strtran(StrTran(aCpoFormD[nY,5],".",""),",","."))>0 
					nW++
					If nW==1
						oPrint:say (nL+nPT,nCl01a+30,aCpoFormD[nY,1]+" "+Capital(Substr(aCpoFormD[nY,3],1,33)), oFont08) 
						If Len(aCpoFormD[nY,3])>33
							oPrint:say (nL+nPD,nCl01a+30,aCpoFormD[nY,1]+" "+Substr(aCpoFormD[nY,3],34,33), oFont08) 
						Endif
						oPrint:say (nL+nPD,nCl01b+10,aCpoFormD[nY,5], oFont10) 
					Elseif nW==2
						oPrint:say (nL+nPT,nCl02a+30,aCpoFormD[nY,1]+" "+Capital(Substr(aCpoFormD[nY,3],1,33)), oFont08) 
						If Len(aCpoFormD[nY,3])>33
							oPrint:say (nL+nPD,nCl02a+30,aCpoFormD[nY,1]+" "+Substr(aCpoFormD[nY,3],34,33), oFont08) 
						Endif
						oPrint:say (nL+nPD,nCl02b+10,aCpoFormD[nY,5], oFont10) 
					Elseif nW==3
						nW:=0
						oPrint:say (nL+nPT,nCl03a+30,aCpoFormD[nY,1]+" "+Capital(Substr(aCpoFormD[nY,3],1,33)), oFont08) 
						If Len(aCpoFormD[nY,3])>33
							oPrint:say (nL+nPD,nCl03a+30,aCpoFormD[nY,1]+" "+Substr(aCpoFormD[nY,3],34,33), oFont08, , , , 1) 
						Endif
						oPrint:say (nL+nPD,nCl03b+10,aCpoFormD[nY,5], oFont10, , , , 1) 
						nL+=nAddL+10
						oPrint:line(nL,165,nL,nColMax )	
						fVerQuebra(2)
					Endif
				Endif
			Next
			nT:=0	
			aEval( aHomD, { |x| nHomD += If ( X[7] == 0 ,1,0) })	
			For nY:= 1 to Len(aHomD)
				If aHomD[nY,7]==0
					nW++
					nT++
					If nW == 2 .And. nL >= 3194	
						lTotal2:= .T.
					Endif
					cItem:= "115."+AllTrim(Str(nT))
					If nW==1
						oPrint:say (nL+nPT,nCl01a+30,cItem+" "+Capital(Substr(aHomD[nY,1],1,33)), oFont08) 
						If Len(aHomD[nY,1])>33
							oPrint:say (nL+nPD,nCl01a+30,Substr(aHomD[nY,1],34,33), oFont08) 
						Endif
						oPrint:say (nL+nPD,nCl01b+10,TransForm(aHomD[nY,3],"@E 99,999,999.99"), oFont10, , , , 1) 
					Elseif nW==2
						oPrint:say (nL+nPT,nCl02a+30,cItem+" "+Capital(Substr(aHomD[nY,1],1,33)), oFont08) 
						If Len(aHomD[nY,1])>33
							oPrint:say (nL+nPD,nCl02a+30,Substr(aHomD[nY,1],34,33), oFont08) 
						Endif
						oPrint:say (nL+nPD,nCl02b+10,TransForm(aHomD[nY,3],"@E 99,999,999.99"), oFont10, , , , 1) 
					Elseif nW==3
						nW:=0
						oPrint:say (nL+nPT,nCl03a+30,cItem+" "+Capital(Substr(aHomD[nY,1],1,33)), oFont08) 
						If Len(aHomD[nY,1])>33
							oPrint:say (nL+nPD,nCl03a+30,Substr(aHomD[nY,1],34,33), oFont08) 
						Endif
						oPrint:say (nL+nPD,nCl03b+10,TransForm(aHomD[nY,3],"@E 99,999,999.99"), oFont10, , , , 1)   
						nL+=nAddL+10
						oPrint:line(nL,165,nL,nColMax )	
						fVerQuebra(2)
					Endif
				Endif
			Next
			Exit 
		Else
			Loop                                                                                                        
		Endif
	Elseif nX > 4
		nW:=nValLin-1
  		For nY := 1 to Len(aCpoFormD)
			If Val(Strtran(StrTran(aCpoFormD[nY,5],".",""),",","."))>0   		
				nW++
				cDescr:=Capital(Substr(aCpoFormD[nY,3],1,33)) //aCpoFormD[nY,1]=Verba 
				If nW==1 
					oPrint:say (nL+nPT,nCl01a+30,aCpoFormD[nY,1]+" "+cDescr, oFont08)
					If Len(aCpoFormD[nY,3]) >33
						oPrint:say (nL+nPD,nCl01a+30,aCpoFormD[nY,1]+" "+Substr(aCpoFormD[nY,3],34,33), oFont08)
					Endif
					oPrint:say (nL+nPD,nCl01b+10,aCpoFormD[nY,5], oFont10) 
				Elseif nW==2
					oPrint:say (nL+nPT,nCl02a+30,aCpoFormD[nY,1]+" "+cDescr, oFont08) 
					If Len(aCpoFormD[nY,3]) >33
						oPrint:say (nL+nPD,nCl02a+30,aCpoFormD[nY,1]+" "+Substr(aCpoFormD[nY,3],34,33), oFont08)
					Endif					
					oPrint:say (nL+nPD,nCl02b+10,aCpoFormD[nY,5], oFont10) 
				Elseif nW==3 
					nW:=0
					oPrint:say (nL+nPT,nCl03a+30,aCpoFormD[nY,1]+" "+cDescr, oFont08) 
					If Len(aCpoFormD[nY,3]) >33
						oPrint:say (nL+nPD,nCl03a+30,aCpoFormD[nY,1]+" "+Substr(aCpoFormD[nY,3],34,33), oFont08)
					Endif					
					oPrint:say (nL+nPD,nCl03b+10,aCpoFormD[nY,5], oFont10, , , , 1) 				
					nL+=nAddL+05
					oPrint:line(nL,165,nL,nColMax )
					fVerQuebra(2)
				Endif
			Endif
		Next	
	   	nT:=0	      
        //AGLUTINA AS VERBAS QUE SERAO GERADAS NO CAMPO 115
   		For nY:= 1 to Len(aHomD)
			If aHomD[nY,7] != 0 .Or. ( ( nPos115 := aScan( aHomDAux, { |aHomDAux| aHomDAux[4] == aHomD[nY,4] } ) ) == 0 )
				Aadd(aHomDAux,{aHomD[nY,1],aHomD[nY,2],aHomD[nY,3],aHomD[nY,4],aHomD[nY,5],aHomD[nY,6],aHomD[nY,7],aHomD[nY,8],aHomD[nY,9] })
			Else
				aHomDAux[nPos115,3] += aHomD[nY,3]
			EndIf
		Next	         
	   	aEval( aHomD, { |x| nHomD += If ( X[7] == 0 ,1,0) })
		For nY:= 1 to Len(aHomD)
			If aHomD[nY,7]==0
				nW++
				nT++
				cItem:= "115."+AllTrim(Str(nT))
				If nW == 3 
					If (nL > 3100 .And. nL < 3194 .OR. nPagina <> 1) .And. (nHomD - nT) <= 1
				 		lTotal:= .T.
						nW:=1
						nL+=nAddL+05
						oPrint:line(nL,165,nL,nColMax )	
					ElseIf nL >= 3194
						fVerQuebra(2)
					Endif
				Endif
				If nW == 2 .And. nL >= 3194	
					lTotal2:= .T.
				Endif
				cDescr:=Capital(Substr(aHomD[nY,1],1,33)) //aHomD[nY,4] 4=Verba
				If nW==1
					oPrint:say (nL+nPT,nCl01a+30,cItem+" "+cDescr, oFont08) 
					If Len(aHomD[nY,1])>33
						oPrint:say (nL+nPD,nCl01a+30,cItem+" "+Substr(aHomD[nY,1],34,33), oFont08) 					
					Endif
					oPrint:say (nL+nPD,nCl01b+10,TransForm(aHomD[nY,3],"@E 99,999,999.99"), oFont10, , , , 1) 
				Elseif nW==2
					oPrint:say (nL+nPT,nCl02a+30,cItem+" "+cDescr, oFont08) 
					If Len(aHomD[nY,1])>33
						oPrint:say (nL+nPD,nCl02a+30,cItem+" "+Substr(aHomD[nY,1],34,33), oFont08) 					
					Endif
					oPrint:say (nL+nPD,nCl02b+10,TransForm(aHomD[nY,3],"@E 99,999,999.99"), oFont10, , , , 1) 
				Elseif nW==3
					nW:=0
					oPrint:say (nL+nPT,nCl03a+30,cItem+" "+cDescr, oFont08) 
					If Len(aHomD[nY,1])>33
						oPrint:say (nL+nPD,nCl03a+30,cItem+" "+Substr(aHomD[nY,1],34,33), oFont08) 					
					Endif
					oPrint:say (nL+nPD,nCl03b+10,TransForm(aHomD[nY,3],"@E 99,999,999.99"), oFont10, , , , 1)   
					nL+=nAddL+05
					oPrint:line(nL,165,nL,nColMax )						
					fVerQuebra(2)
				Endif
			Endif
		Next
		Exit 
	Endif
	If (nX < 4 .And. nValLin == 0) .or. (nX<5 .and. nCkHomV>3 )
		nL+=If(nX==1,(nAddL-42),nAddL+05)
		oPrint:line(nL,165,nL,nColMax )
		fVerQuebra(2)
	Endif
Next

While nL <= 3104 .And. nPagina==1
	nL+=nAddL+05
	oPrint:line(nL,165,nL,nColMax )
EndDo

if nW<>0
	nL += nAddL+05
Endif
	
If (nW < 2 .Or. (nW <= 2 .And. nHomD <> 0)).And. (nL > 3190 .Or. (lTotal .And. nPagina <> 1))
	nL -= nAddL+05
Endif   

If lTotal .And. !lTotal2 .And. nL > 3104
	nL-=(nAddL+05)
Endif

If nL == 3104 .Or. nL == 3109 .And. lTotal2 .And. !lTotal
	nL+=(nAddL+05)
Endif
if nW <= 2 .And. nHomD > 0 .And. nL > 3190
	if !lAjustaLin
		nL += nAddL+05
	endif
EndIF
if nW <= 2 .And. nHomD == 0 .And. nL > 3190 
	lTemVerba := .T.
	if lAjustaLin
		nL -= nAddL+05
	endif
endif
If lTemVerba
	oPrint:FillRect( {nL+05-90, nCl03a, nL+nAddL-90, nColMax}, oBrush1 )
	oPrint:say (nL+nPT-70,nCl03a+30,STR0097, oFont09n)   //"TOTAL DEDU«’ES"
	oPrint:say (nL+nPD-90,nCl03b,Transform(nDesc,"@E 999,999,999.99"), oFont10, , , , 1)
	oPrint:FillRect( {nL+5, nCl03a+01, nL+nAddL+05, nColMax}, oBrush1 ) 
	oPrint:say (nL+nPT,nCl02a+30	,"            ", oFont08) 
	oPrint:say (nL+nPD,nCl02b+10	,"            ", oFont08) 
	oPrint:say (nL+nPT+20,nCl03a+30	,STR0099, oFont09n)  //"VALOR LÕQUIDO"
	oPrint:say (nL+nPD,nCl03b,Transform(nProv - nDesc,"@E 999,999,999.99"), oFont10, , , , 1)  	
Else
	nL-=nAddL+05
	oPrint:FillRect( {nL+05, nCl03a, nL+nAddL, nColMax}, oBrush1 )
	oPrint:say (nL+nPT+20,nCl03a+30,STR0097, oFont09n)   //"TOTAL DEDU«’ES"
	oPrint:say (nL+nPD,nCl03b,Transform(nDesc,"@E 999,999,999.99"), oFont10, , , , 1)
	nL+=nAddL+05
	oPrint:FillRect( {nL+5, nCl03a+01, nL+nAddL+05, nColMax}, oBrush1 )
	oPrint:line(nL,165,nL,nColMax )
	oPrint:say (nL+nPT,nCl01a+30,"        "	   , oFont08)
	oPrint:say (nL+nPD,nCl01b+10,"            ", oFont08) 
	oPrint:say (nL+nPT,nCl02a+30,"            ", oFont08) 
	oPrint:say (nL+nPD,nCl02b+10,"            ", oFont08) 
	oPrint:say (nL+nPT+20,nCl03a+30,STR0099, oFont09n)  //"VALOR LÕQUIDO"
	oPrint:say (nL+nPD,nCl03b,Transform(nProv - nDesc,"@E 999,999,999.99"), oFont10, , , , 1) 	
Endif	

nL+=nAddL+05 

//Fecha o box e cria as linhas verticais
oPrint:Box( nBoxIni,  165,nL,nColMax )
oPrint:line(nBoxIni,nCl01b+20-200,nL,nCl01b+20-200 )
oPrint:line(nBoxIni,nCl02a,nL,nCl02a )
oPrint:line(nBoxIni,nCl02b+20-200,nL,nCl02b+20-200 )
oPrint:line(nBoxIni,nCl03a,nL,nCl03a )
oPrint:line(nBoxIni,nCl03b+20-200,nL,nCl03b+20-200 )          

oPrint:EndPage()

//SE TEVE MAIS DE UM ANO TRABALHADO DEVE SER IMPRESSO O TERMO DE HOMOLOGACAO (ANEXO VII) AO INVES DO TERMO DE QUITACAO (ANEXO VI)
//SE POSSUIR AVISO PREVIO INDENIZADO, DEVE-SE CONSIDERAR OS DIAS DE AVISO NA VALIDACAO DO ANO TRABALHADO
lHomolog := .F. //Inserido para nunca homologar//( ( DaySub( YearSum( SRA->RA_ADMISSA, 1 ), 1) <= SRG->RG_DATADEM ) .Or. ( nVal69 > 0 .And. DaySub(YearSum( SRA->RA_ADMISSA, 1 ), 1) <= DaySum( SRG->RG_DATADEM, nVal69 - 1 ) ) )

//INICIO DA IMPRESSAO DO TERMO DE QUITACAO/HOMOLOGACAO DE RESCISAO DE CONTRATO DE TRABALHO - ANEXO VI/VII - PORTARIA MTE N. 2.685 - 26/12/2011 - DOU 27/12/2011
oPrint:StartPage() 			//INICIA UMA NOVA PAGINA
 
nL:=077

If lHomolog   
	oPrint:FillRect( {nL, 165, nL+nTit, nColMax}, oBrush1 )
	oPrint:Box(nL, 165,nL+(nAddL+50)+(nPT*5)+nAddL+(nAddL*9)+(nPT*5)-125+nSubT , nColMax ) 		//Box   -155
	oPrint:say (nL+05,318,STR0138, oFont15n) //"TERMO DE HOMOLOGA«√O DE RESCIS√O DE CONTRATO DE TRABALHO"	
Else   
	oPrint:FillRect( {nL, 165, nL+nTit, nColMax}, oBrush1 )
	oPrint:Box(nL, 165,nL+(nAddL+50)+(nPT*2)+nAddL+(nAddL*8)+(nPT*3)-100+nSubT , nColMax ) 		//Box
	oPrint:say (nL+05,384,STR0121, oFont15n) //"TERMO DE QUITA«√O DE RESCIS√O DE CONTRATO DE TRABALHO"	
EndIf

oPrint:FillRect( {nL+nTit, 067, nL+nTit+nSubT-05, nColMax+10}, oBrush2 )

nL:=nL+nTit
oPrint:line(nL,165 ,nL,nColMax)

nL+=nSubT

oPrint:FillRect( {nL, 167, nL+nSubT, nColMax}, oBrush1 )
oPrint:line(nL,165 ,nL,nColMax) 			//Linha Horizontal

nL:=nL+nPT

//IDENTIFICACAO DO EMPREGADOR
oPrint:say (nL,190,STR0122, oFont10n) 	//"EMPREGADOR"

nL:=nL+nSubT-05

oPrint:line(nL,165 ,nL,nColMax) 										//LINHA HORIZONTAL
oPrint:line(nL,565 ,nL+nAddL+10,565 )									//LINHA VERTICAL MEIO
oPrint:say (nL+05,185,STR0056, oFont08) 		 						//"01- CNPJ/CEI: 	
oPrint:say (nl+05,580,STR0001, oFont08)								//"02- RAZ√O SOCIAL / NOME:"
oPrint:say (nL+nPD,205 ,SUBSTR(If( Len(aInfo) >= 27 .And. !Empty( aInfo[27] ), Capital(aInfo[27]), Capital(aInfo[8]) )+Space(20),1,20), oFont10 ) //"|01- CNPJ: 
oPrint:say (nL+nPD,595 ,Capital(aInfo[3]), oFont10 )							//"02- RAZAO SOCIAL / NOME:"

oPrint:FillRect( {nL+nAddL+10, 167, nL+nPT+nSubT+nAddL+05, nColMax}, oBrush1 )
oPrint:line(nL+nAddL+10,165 ,nL+nAddL+10,nColMax)					//LINHA HORIZONTAL
//IDENTIFICACAO DO EMPREGADOR
nL:=nL+nPT
nL:=nL+nAddL+10

oPrint:say (nL,190,STR0123, oFont10n)   								//"TRABALHADOR"
oPrint:line(nL+nSubT-05,165 ,nL+nSubT-05,nColMax) 					//LINHA HORIZONTAL

nL:=nL+nSubT-05

oPrint:say (nL+nPT,190 ,STR0025, oFont08)								//"10 PIS/PASEP:" 
oPrint:say (nL+nPT,580 ,STR0023, oFont08)								//"11 NOME:"
oPrint:line(nL+nAddL+10,165 ,nL+nAddL+10,nColMax)					//LINHA HORIZONTAL
oPrint:line(nL,565 ,nL+nAddL+10,565 )			

oPrint:say (nL+nPD,205 ,SRA->RA_PIS,oFont10)							//PIS
If !Empty(SRA->RA_NOMECMP)
	oPrint:say (nL+nPD,595 ,Subs(Capital(SRA->RA_NOMECMP)+Space(60),1,60),oFont10) //NOME
Else
	oPrint:say (nL+nPD,595 ,Subs(Capital(SRA->RA_NOME)+Space(30),1,30),oFont10) //NOME
EndIf	

oPrint:say (nL+nAddL+nPT+10,190 ,"17 "+STR0024, oFont08) 	//17 CARTEIRA DE TRABALHO
oPrint:say (nL+nAddL+nPT+10,575 , STR0012, oFont08)		//18 CPF:"
oPrint:say (nL+nAddL+nPT+10,865 , STR0027, oFont08)		//19 NASC.:"
oPrint:say (nL+nAddL+nPT+10,1225, STR0007, oFont08)		//20 NOME DA MAE"

oPrint:say (nL+nAddL+nPD+10,190 , SRA->RA_NUMCP+"- "+SRA->RA_SERCP+"/"+SRA->RA_UFCP, oFont10)	//17 CNAE
oPrint:say (nL+nAddL+nPD+10,585 , SRA->RA_CIC, oFont10)												//18 CPF:"
oPrint:say (nL+nAddL+nPD+10,885 , DtoC(SRA->RA_NASC), oFont10)									//19 NASC.:"
oPrint:say (nL+nAddL+nPD+10,1225, SUBSTR(Capital(SRA->RA_MAE)+Space(30),1,40), oFont10)					//20 NOME DA MAE"

nL := nL + nAddL + 10

oPrint:line(nL,565 ,nL+nAddL+10,565 )	//LINHA VERTICAL MEIO
oPrint:line(nL,860,nL+nAddL+10,860)		//LINHA VERTICAL MEIO
oPrint:line(nL,1210,nL+nAddL+10,1210)	//LINHA VERTICAL MEIO

//DADOS DO CONTRATO

nL:=nL+nAddL+10

oPrint:FillRect( {nL, 167, nL+nSubT, nColMax}, oBrush1 )
oPrint:Line(nL,165,nL,nColMax) //LINHA HORIZONTAL
oPrint:say (nL+05,190,STR0124, oFont10n) //"CONTRATO"
nL:=nL+nSubT
oPrint:Box(nL,165,nL,nColMax) //LINHA HORIZONTAL
oPrint:say (nL+nPT,190,STR0019, oFont08) 							//22 CAUSA DO AFASTAMENTO
If lSepCausa
	oPrint:say (nL+nPD,205,SubStr( Alltrim(cCausa),1,nCausaPos ), oFont10)
	oPrint:say (nL+nPD+50,205,SubStr( Alltrim(cCausa),nCausaPos + 1 ), oFont10)
Else
	oPrint:say (nL+nPD,205,Alltrim(cCausa), oFont10)
EndIf

oPrint:say (nL+nTip+nPT,190,STR0021	, oFont08) 					//24 DATA DE ADMISSAO
oPrint:say (nL+nTip+nPD,205,DtoC(SRA->RA_ADMISSA), oFont10) 
oPrint:say (nL+nTip+nPT,680,STR0022, oFont08) 					//25 DATA DO AVISO PREVIO
oPrint:say (nL+nTip+nPD,695,DtoC(SRG->RG_DTAVISO), oFont10) 
oPrint:say (nL+nTip+nPT,1075,STR0026, oFont08) 					//26 DATA DE AFASTAMENTO
oPrint:say (nL+nTip+nPD,1090,DtoC(SRG->RG_DATADEM), oFont10) 
oPrint:say (nL+nTip+nPT,1470	,STR0028	, oFont08)	 			//27 COD. AFAST.
oPrint:say (nL+nTip+nPD,1485	,cCodAfa, oFont10) 
oPrint:say (nL+nTip+nPT,1765,STR0136	, oFont08) 					//29 PENSAO ALIMENTICIA (FGTS)
oPrint:say (nL+nTip+nPD,1780,Transform(nPerFGTS,"@E 999.99"), oFont10)

nL := nL + nTip + nPT - 05

oPrint:line(nL,165 ,nL,nColMax)				//LINHA HORIZONTAL
oPrint:line(nL,665,nL+nAddL+10,665)		//LINHA VERTICAL MEIO
oPrint:line(nL,1060,nL+nAddL+10,1060)		//LINHA VERTICAL MEIO
oPrint:line(nL,1455,nL+nAddL+10,1455)		//LINHA VERTICAL MEIO
oPrint:line(nL,1750,nL+nAddL+10,1750)		//LINHA VERTICAL MEIO

nL := nL + nAddL + 10

oPrint:line(nL,165 ,nL,nColMax) 			//LINHA HORIZONTAL

oPrint:say (nL+nPT,190,STR0031	, oFont08) //30 CATEGORIA DO TRABALHADOR

/*CATEGORIAS FUNCIONARIOS CONSIDERADOS NO TRCT ATRAV…S DA PORTARIA 1057/2012 	
01 - EMPREGADO
03 - TRABALHADOR N√O VINCULADO AO RGPS, MAS COM DIREITO AO FGTS
04 - EMPREGADO - CONTRATO DE TRAB. POR PRAZO DETERM. (LEI N∫ 9.601/98)
06 - EMPREGADO DOM…STICO
07 - MENOR APRENDIZ (LEI 10.097/2000)*/
     
If SRA->RA_CATEG $ "03/04/06/07"
	If SRA->RA_CATEG == "03"
		cDescCateg := STR0159
	ElseIf SRA->RA_CATEG == "04"
		cDescCateg := STR0160
	ElseIf SRA->RA_CATEG == "06"
		cDescCateg := STR0161
	ElseIf SRA->RA_CATEG == "07"
		cDescCateg := STR0162
	EndIf
EndIf

oPrint:say (nL+nPD,180,cCateg+' - '+cDescCateg, oFont10)

If lHomolog
	nL := nL + nPT

	nL := nL + nAddL + 05	
	oPrint:say (nL+nPT,190,STR0139	, oFont08)	//31 CODIGO SINDICAL                                      
	oPrint:say (nL+nPD,190,cCodSind, oFont10)	
	oPrint:say (nL+nPT,680,STR0140, oFont08)	//32 CNPJ E NOME DA ENTIDADE SINDICAL LABORAL
	oPrint:say (nL+nPD,695,cNomeSind, oFont10)

	oPrint:line(nL,165 ,nL,nColMax)				//LINHA HORIZONTAL
	oPrint:line(nL,665,nL+nAddL+nPT+05,665)	//LINHA VERTICAL MEIO

EndIf	

nL := nL + (nAddl*2) + nPT

If lHomolog
	nL -= 20
	oPrint:say (nL+nPT,170		,STR0141, oFont08)  //"FOI PRESTADA, GRATUITAMENTE, ASSISTENCIA NA RESCISAO DO CONTRATO DE TRABALHO, NOS TERMOS DO ARTIGO N.∫ 477, 1∫, DA CONSOLIDA«AO DAS LEIS DO TRABALHO "                                                                                                                                                                                                                                                                                                                                                           
	nL += 35
	oPrint:say (nL+nPT,170		,STR0142 , oFont08)  //"(CLT), SENDO COMPROVADO NESTE ATO O EFETIVO PAGAMENTO DAS VERBAS RESCISORIAS ESPECIFICADAS NO CORPO DO TRCT, NO VALOR LIQUIDO DE R$ "
	nL += 35
	oPrint:say (nL+nPT,170		,STR0157 + Transform(nProv - nDesc,"@E 999,999,999.99") + "," + STR0143, oFont08)  //"O QUAL, DEVIDAMENTE RUBRICADO PELAS PARTES, E PARTE INTEGRANTE DO PRESENTE TERMO DE HOMOLOGACAO"    
	nL += 35

	nL += 35
	oPrint:say (nL+nPT,170		,STR0144, oFont08)  //"AS PARTES ASSISTIDAS NO PRESENTE ATO DE RESCISAO CONTRATUAL FORAM IDENTIFICADAS COMO LEGITIMAS CONFORME PREVISTO NA INSTRUCAO NORMATIVA/SRT"
	nL += 35	
	oPrint:say (nL+nPT,170		,STR0145, oFont08)  //"N∫ 15/2010."

	nL += 70
	oPrint:say (nL+nPT,170		,STR0146, oFont08)  //ìFICA RESSALVADO O DIREITO DE O TRABALHADOR PLEITEAR JUDICIALMENTE OS DIREITOS INFORMADOS NO CAMPO 155, ABAIXO."
Else
	nL += 35
	oPrint:say (nL+nPT,170		,STR0125, oFont08)  //"FOI REALIZADA A RESCISAO DO CONTRATO DE TRABALHO DO TRABALHADOR ACIMA QUALIFICADO, NOS TERMOS DO ARTIGO N∫ 477 DA CONSOLIDACAO DAS LEIS DO TRABALHO (CLT)."                                                                                                                                                                                                                                                                                                                                                       
	nL += 35
	oPrint:say (nL+nPT,170		,STR0126, oFont08)  //"A ASSISTENCIA A RESCISAO PREVISTA NO 1∫ DO ART. N∫ 477 DA CLT NAO E DEVIDA, TENDO EM VISTA A DURACAO DO CONTRATO DE TRABALHO NAO SER SUPERIOR A UM ANO"                                                                                                                                                                                                                                                                                                                                                         
	nL += 35
	oPrint:say (nL+nPT,170		,STR0127, oFont08)  //"DE SERVICO E NAO EXISTIR PREVISAO DE ASSISTENCIA A RESCISAO CONTRATUAL EM ACORDO OU CONVENCAO COLETIVA DE TRABALHO DA CATEGORIA A QUAL PERTENCE O "                                                                                                                                                                                                                                                                                                                                                                
	nL += 35
	oPrint:say (nL+nPT,170		,STR0128, oFont08)  //"TRABALHADOR."

	nL += 70
	oPrint:say (nL+nPT,170		,STR0130 + Space(1)+ " ___/___/______ " + STR0131, oFont08) //"NO DIA __/__/____  FOI REALIZADO, NOS TERMOS DO ART. 23 DA INSTRUCAO NORMATIVA/SRT N∫ 15/2010, O EFETIVO PAGAMENTO DAS VERBAS RESCISORIAS ESPECIFICADAS" 
	nL += 35
	oPrint:say (nL+nPT,170		,STR0132 + Space(2)+ Transform(nProv - nDesc,"@E 999,999,999.99") + STR0152, oFont08)  //"NO CORPO DO TRCT, NO VALOR LIQUIDO DE R$ "##//", O QUAL, DEVIDAMENTE RUBRICADO PELAS PARTES, E PARTE INTEGRANTE DO PRESENTE TERMO DE QUITACAO."
	nL += 35
	oPrint:say (nL+nPT,170		,STR0158, oFont08)
EndIf

nL += If( !lHomolog, 210, 105 )

oPrint:say (nL+nPT,170		," __________________________/___, ____ de __________________________ de ________ " , oFont10) 

nL := nL + nAddl
nL += If( !lHomolog, 210, 140 )

oPrint:say (nL+nPT,170		," ___________________________________________________________ " , oFont08) 

oPrint:say (nL+nPT+35,170		,STR0129 + cDescPrep, oFont10) //150 ASSINATURA DO EMPREGADOR OU PREPOSTO

nL := nL + nAddl
nL += 50

oPrint:say (nL+nAddL,170,"_________________________________________________________", oFont08) 
oPrint:say (nL+nAddL+nPT+30,180,STR0133, oFont10)//151 ASSINATURA DO TRABALHADOR

oPrint:say (nL+nAddL,1230,"_________________________________________________________", oFont08) 
oPrint:say (nL+nAddL+nPT+30,1245,STR0134, oFont10)//152 ASSINATURA DO RESPONSAVEL LEGAL DO TRABALHADOR

If lHomolog
	nL += 140
	nL := nL + nAddl
	oPrint:say (nL+nAddL,170,"_________________________________________________________", oFont08) 
	oPrint:say (nL+nAddL+nPT+40,180,STR0148, oFont10)//"153 CARIMBO E ASSINATURA DO ASSISTENTE"

	oPrint:say (nL+nAddL,1230,"_________________________________________________________", oFont08) 
	oPrint:say (nL+nAddL+nPT+40,1245,STR0149, oFont10)//"154 NOME DO ORGAO HOMOLOGADOR"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     

	nL:=nL+(nAddL*2)+(nPT)+50

	oPrint:Box(nL,165,nL+((nAddL+nPT)*5.3) + 540,nColMax) //BOX
	oPrint:say (nL+nPT+5,190,STR0150, oFont10)//-- "155 Ressalvas"

	nL := nL + ( ( nAddl + nPT + nPD ) * 2 ) + 540
Else
	nL := nL + nAddl * 2
	nL:=nL+(nAddL*2)+(nPT)+15	
	nL := nL + ( nAddl + nPT + nPD ) - 60
EndIf

nL:=nL+20+nPT

If !lHomolog
	nL+=200
	oPrint:Box((nL+(nAddL+nPT)),165,(nL+(nAddL+nPT))+55,nColMax) //BOX
Endif

If !lHomolog
	oPrint:say (nL+(nAddL+nPT)+nPT,190,STR0165, oFont10)//"156 INFORMACOES A CAIXA:"
Else
	oPrint:say (nL+((nAddL+nPT)*1.2)+25+nPT,190,STR0165, oFont10)//"156 INFORMACOES A CAIXA:"
EndIf

nL:=nL+20

If lHomolog                                                                             
	oPrint:line((nL+((nAddL+nPT)*1.2)),165 ,(nL+((nAddL+nPT))*1.2),nColMax) 		//LINHA HORIZONTAL
Endif


nL:=(nL+((nAddL+nPT)*2.0)) + If(!lHomolog, 0, 35)

oPrint:FillRect( {nL, 165, nL+nPD+nPD+nPD+35, nColMax+01}, oBrush1 )
oPrint:line(nL,165 ,nL,nColMax) 		//LINHA HORIZONTAL 
oPrint:say (nL,510			,STR0115, oFont14n) //"A ASSISTENCIA NO ATO DA RESCISAO CONTRATUAL E GRATUITA."
oPrint:say (nL+nPD+10,210		,STR0116, oFont10n) //"PODE O TRABALHADOR INICIAR ACAO JUDICIAL QUANTO AOS CREDITOS RESULTANTES DAS RELACOES DE TRABALHO ATE O LIMITE DE DOIS ANOS APOS A EXTINCAO DO CONTRATO DE TRABALHO"
oPrint:say (nL+nPD+nPD+10,430	,STR0117, oFont10n) //"(INC. XXIX, ART.7∫ DA CONSTITUICAO FEDERAL/1988)."


oPrint:EndPage()

//FIM DA IMPRESSAO DO TEMRO DE QUITACAO DE RESCISAO

Return Nil

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥fNewLine  ≥ Autor ≥ Kelly Soares          ≥ Data ≥ 20.01.11 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Inicia nova linha na impressao das verbas rescisorias.     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ RdMake                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fNewLine()

If nXCol = 3
	nXCol := 0
	nL+=nAddL+05
	oPrint:line(nL,165,nL,nColMax )		
Endif
nXCol++

//VERIFICA SE ATINGIU O LIMITE DE LINHAS E EFETUA A QUEBRA DA PAGINA
fVerQuebra(1)

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥PenunSal  ≥ Autor ≥ Mauricio MR		    ≥ Data ≥ 16.02.11    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Obtem o penultimo salario do funcionario antes da demissao.≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ IMPRESH                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function PenunSal(dAdmissao, dDemissao, cVerbas, cVerbSal)
Local nEpoch		:= Set(_SET_EPOCH)	//OBTEM A CONFIGURACAO DE SECULO CORRENTE
Local aArea			:= GetArea()
Local aSRCArea		:= SRC->(GetArea())
Local aPerAtual		:= {}
//DATA DO PENULTIMO SALARIO
Local dDTPenSal 
Local dDataDe
Local dDataAte
Local nValPenSal
Local cFilMat		:= SRA->(RA_FILIAL+RA_MAT)

DEFAULT dAdmissao	:= SRA->RA_ADMISSA	
DEFAULT dDemissao	:= SRG->RG_DATADEM  
DEFAULT cVerbas		:= ''  
DEFAULT cVerbSal	:= acodfol[318, 1]

If cVerbSal == acodfol[318, 1]
	// A verba ID: 318, base sal·rio mÍs, j· contÈm o sal·rio incorporado
	cVerbas := ""
EndIf

fGetPerAtual(@aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, fGetCalcRot('1'))
If ! Empty(aPerAtual)
	dDataDe  := aPerAtual[1, 6]
	dDataAte := aPerAtual[1, 7]
EndIf

Set(_SET_EPOCH, 1920)	//ALTERA O SET EPOCH PARA 1920

dDTPenSal := If(Month(dDemissao) - 1 != 0, CtoD( '01/' + StrZero(Month(dDemissao) - 1, 2) + '/' + Right(StrZero(Year(dDemissao), 4), 2)), CtoD('01/12/' + Right(StrZero(Year(dDemissao) - 1, 4), 2)) )

If MesAno(dDtPenSal) < MesAno(dAdmissao)
	dDTPenSal 	:= CTOD("  /  /  ")
	nValPenSal 	:= 0.00
Endif
//PENULTIMO
If ! Empty(dDTPenSal)
	nValPenSal := fBuscaAcm(cVerbas + cVerbSal, , dDTPenSal, dDTPenSal, "V")	//SALARIO DO MES + VERBAS QUE INCORPORARAM  AO SALARIO
	//PESQUISA NO MOVIMENTO MENSAL QUANDO O MES CORRENTE ESTIVER ABERTO
	//E NAO ENCONTRAR SALARIO NOS ACUMULADOS ANUAIS
	If nValPenSal == 0 .AND. MesAno(dDTPenSal) == MesAno(dDataDe)
		If SRC->(Dbseek(cFilMat))
			While ! SRC->(Eof()) .And. cFilMat == SRC->(RC_FILIAL + RC_MAT)
				If SRC->RC_PD $ cVerbas + cVerbSal
					nValPenSal += SRC->RC_VALOR
				Endif
				SRC->(dbskip())
			Enddo
		Endif
	Endif
Endif

//RESTAURA O SET EPOCH PADRAO
Set(_SET_EPOCH, nEpoch)

RestArea(aSRCArea)
RestArea(aArea)

Return(nValPenSal)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥fVerQuebra≥ Autor ≥ Allyson M             ≥ Data ≥ 25.03.13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Verifica se quebra linha e finaliza os box e ilinhas.      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ RdMake                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fVerQuebra( nTipo, lLinhas, lPrimDed )
Default lLinhas	 := .T.
Default lPrimDed := .F.

If nL > 3280
	//QUEBRA NOS PROVENTOS
	If nTipo == 1
		lQuebraP := .T.
	//QUEBRA NOS DESCONTOS
	Else
		lQuebraD := .T.
	EndIf
	//FECHA O BOX E CRIA AS LINHAS VERTICAIS
	oPrint:Box(nBoxIni,165,nL,nColMax)
	If lLinhas
		oPrint:line(nBoxIni,nCl01b+20-200,nL,nCl01b+20-200 )
		oPrint:line(nBoxIni,nCl02a,nL,nCl02a )
		oPrint:line(nBoxIni,nCl02b+20-200,nL,nCl02b+20-200 )
		oPrint:line(nBoxIni,nCl03a,nL,nCl03a )
		oPrint:line(nBoxIni,nCl03b+20-200,nL,nCl03b+20-200 )  
	EndIf

	oPrint:EndPage()  //TERMINA A PAGINA
	oPrint:StartPage()//INICIA UMA NOVA PAGINA

	//SE IMPRIME CABECALHO NOVAMENTE
	If lImpCabec
		//IMPRIME O CABECALHO DA RESCISAO NOVAMENTE (CAMPOS 01 A 32)
		fCabec()
		//QUEBRA NOS PROVENTOS
		If nTipo == 1
			oPrint:say (nL+nSubT,nCl01a+30,STR0036, oFont10n) //"VERBAS RESCISORIAS"
			nL := nL+nSubT
			nBoxIni := nL      
			oPrint:say (nL+02+nSubT,nCl01a+30		,STR0037	, oFont10n) //"RUBRICAS"
			oPrint:say (nL+02+nSubT,nCl01b-120		,STR0038	, oFont10n) //"VALOR"
			oPrint:say (nL+02+nSubT,nCl02a+30		,STR0037	, oFont10n) //"RUBRICAS"
			oPrint:say (nL+02+nSubT,nCl02b-120		,STR0038	, oFont10n) //"VALOR"
			oPrint:say (nL+02+nSubT,nCl03a+30		,STR0037	, oFont10n) //"RUBRICAS"
			oPrint:say (nL+02+nSubT,nCl03b-120		,STR0038	, oFont10n) //"VALOR" 
		//QUEBRA NOS DESCONTOS
		Else
			If !lPrimDed //Quando for a primeira impress„o das deduÁıes, n„o precisa imprimir as informaÁıes abaixo, pois s„o impressas na funÁ„o fHomolog()
				oPrint:say (nL+nSubT,nCl01a+30,STR0073, oFont10n)	//"DEDUCOES"
				nL := nL+nSubT
				nBoxIni := nL
				oPrint:say (nL+02+nSubT,nCl01a+30   ,STR0074, oFont10n)	 	 //"DESCONTO"
				oPrint:say (nL+02+nSubT,nCl01b-120	,STR0038, oFont10n) 	 //"VALOR"
				oPrint:say (nL+02+nSubT,nCl02a+30	,STR0074, oFont10n) 	 //"DESCONTO"
				oPrint:say (nL+02+nSubT,nCl02b-120	,STR0038, oFont10n) 	 //"VALOR"
				oPrint:say (nL+02+nSubT,nCl03a+30	,STR0074, oFont10n) 	 //"DESCONTO"
				oPrint:say (nL+02+nSubT,nCl03b-120	,STR0038, oFont10n) 	 //"VALOR" 
			Endif
		EndIf
		nL += nSubT	
		oPrint:line(nL,165,nL,nColMax )
		nL += nSubT + 1
	Else
		nL := nBoxIni := 077
	EndIf  
	nPagina+= 1
EndIf

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥fCabec	≥ Autor ≥ Allyson M                ≥ Data ≥ 06.05.13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Imprime o cabecalho da Rescisoa                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ RdMake                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fCabec(nTipo, lLinhas)
Local nPos		:= 0
Local cTabRes	:= If(cPaisLoc $ "MEX", "S025", If((cPaisLoc $ "BOL"), "S013", "S043"))

nL:=078

oBrush1 := TBrush():New( ,  RGB(197,197,197))  
oBrush2	:=  TBrush():New( ,  CLR_WHITE)  
oPrint:FillRect({nL, 165, nL+(nTit-60)+nTit, nColMax}, oBrush1)

oPrint:Box(nL, 165,nL+(nTit-50)+(nTit+10)+nPT+10+nTit+nTit+(nTit*3)+20+nPT+nTit+(nTit*4)+nTit+(nTit*3)+540   , nColMax ) 		//BOX P/ TIT. "TERMO DE RESCISAO DO CONTRATO DE TRABALHO"

nL:=nL+nTit-60
oPrint:say (nL,537,STR0003, oFont15n) //"TERMO DE RESCISAO DO CONTRATO DE TRABALHO"
                                              
oPrint:FillRect( {nL+nTit, 067, nL+nTit+nSubT-15, nColMax+10}, oBrush2 )
oPrint:line(nL+nTit,165 ,nL+nTit,nColMax) 			//LINHA HORIZONTAL
nL:=nL+nTit

oPrint:FillRect( {nL+nSubT-15, 167, nL+nSubT+nSubT-15, nColMax}, oBrush1 )
oPrint:line(nL+nSubT-15,165 ,nL+nSubT-15,nColMax)
nL:=nL+nSubT+nPT-15
oPrint:say (nL-05,920,STR0002, oFont10n) 	//"IDENTIFICACAO DO EMPREGADOR"

//IDENTIFICACAO DO EMPREGADOR
nL:=nL+nSubT+05

//EFETUA A IMPRESSAO DO TEXTO NA VERTICAL
oPrint:line(nL-10,165 ,nL-10,nColMax) 									//LINHA HORIZONTAL
oPrint:line(nL-10,665 ,nL+nAddL,665 )									//LINHA VERTICAL MEIO
oPrint:say (nL+05,185,STR0056, oFont08) 		 						//"01- CNPJ/CEI: 	
oPrint:say (nl+05,680,STR0001, oFont08)								//"02- RAZAO SOCIAL / NOME:"  
oPrint:say (nL+nPD,205 ,SUBSTR(If( Len(aInfo) >= 27 .And. !Empty( aInfo[27] ), Capital(aInfo[27]), Capital(aInfo[8]) )+Space(20),1,20), oFont10 ) 	//"|01- CNPJ: 
oPrint:say (nL+nPD,695 ,Capital(aInfo[3]), oFont10 )							//"02- RAZAO SOCIAL / NOME:"

oPrint:line(nL+nAddL,165 ,nL+nAddL,nColMax) 							//LINHA HORIZONTAL	
oPrint:line(nL+nAddL,1610,nL+(nAddL*2)+10,1610)						//LINHA VERTICAL MEIO	BAIRRO
oPrint:say (nL+nAddL+05,185 ,"03 "+STR0005, oFont08)      			//"ENDERECO (LOGRADOURO, N∫, ANDAR, APARTAMENTO)"
oPrint:say (nL+nAddL+05,1650,"04 "+STR0014, oFont08)					//04 BAIRRO : "
oPrint:say (nL+nAddL+nPD,200 ,Capital(aInfo[4]) , oFont10)					//03 ENDERECO   : "
oPrint:say (nL+nAddL+nPD,1200,"- "+Capital(aInfo[14]), oFont10)				//03 COMPLEMENTO
oPrint:say (nL+nAddL+nPD,1665,Capital(aInfo[13]), oFont10)					//04 BAIRRO : "
	
oPrint:line(nL+(nAddL*2)+10,930 ,nL+(nAddL*3)+20,930 )				//LINHA VERTICAL MEIO
oPrint:line(nL+(nAddL*2)+10,1110,nL+(nAddL*3)+20,1110)				//LINHA VERTICAL MEIO
oPrint:line(nL+(nAddL*2)+10,1330,nL+(nAddL*3)+20,1330)				//LINHA VERTICAL MEIO	
oPrint:line(nL+(nAddL*2)+10,1610,nL+(nAddL*3)+20,1610)				//LINHA VERTICAL MEIO
oPrint:line(nL+(nAddL*2)+10,0165,nL+(nAddL*2)+10,nColMax)			//LINHA HORIZONTAL
oPrint:say (nL+(nAddL*2)+15,185 ,"05 "+STR0015, oFont08)			//"|05 MUNIC.: "
oPrint:say (nL+(nAddL*2)+15,950 ,"06 "+STR0016, oFont08)			//"|06 UF : "
oPrint:say (nL+(nAddL*2)+15,1130,"07 "+STR0013, oFont08)			//"|07 CEP: "
oPrint:say (nL+(nAddL*2)+15,1350,"08 "+STR0017, oFont08)			//"|08 CNAE " 
oPrint:say (nL+(nAddL*2)+15,1630,"09 "+STR0004, oFont08)			//"|09 CNPJ/CEI TOMADOR/OBRA: "

oPrint:say (nL+(nAddL*2)+10+nPD,205 ,Capital(aInfo[5]) , oFont10)			//"|05 MUNIC.: "
oPrint:say (nL+(nAddL*2)+10+nPD,950 ,aInfo[6] , oFont10)			//"|06 UF : "
oPrint:say (nL+(nAddL*2)+10+nPD,1130,aInfo[7] , oFont10)			//"|07 CEP: "
oPrint:say (nL+(nAddL*2)+10+nPD,1340,aInfo[16], oFont10)			//"|08 CNAE"
oPrint:say (nL+(nAddL*2)+10+nPD,1630,Substr(fDesc("CTT",SRA->RA_CC,"CTT_CEI")+Space(5),1,15), oFont10)//"|09 CNPJ/CEI TOMADOR/OBRA: "

//IDENTIFICACAO DO TRABALHADOR
nL:=nL+(nAddL*3)+20 

oPrint:FillRect( {nL, 167, nL+nSubT, nColMax}, oBrush1 )
oPrint:line(nL,165 ,nL,nColMax)											//LINHA HORIZONTAL	
oPrint:say (nL+05,910,STR0006, oFont10n)								//"IDENTIFICACAO DO TRABALHADOR"  
oPrint:line(nL+nSubT,165 ,nL+nSubT,nColMax) 							//Linha Horizontal	// IDENTIFICACAO DO TRABALHADOR 
nL:=nL+nSubT																//IDENTIFICACAO DO TRABALHADOR
nL:=nL+nPT

oPrint:say (nL+nPT,185 ,STR0025, oFont08)								//"10 PIS/PASEP:" 
oPrint:say (nL+nPT,555 ,STR0023, oFont08)								//"11 NOME:"
oPrint:line(nL+nAddL+10,165 ,nL+nAddL+10,nColMax)					//LINHA HORIZONTAL
oPrint:line(nL,535 ,nL+nAddL+nPT,535 )									//LINHA VERTICAL MEIO

oPrint:say (nL+nPD,205 ,SRA->RA_PIS,oFont10) //PIS
If !Empty(SRA->RA_NOMECMP)
	oPrint:say (nL+nPD,570 ,Subs(Capital(SRA->RA_NOMECMP)+Space(60),1,60),oFont10) //NOME
Else
	oPrint:say (nL+nPD,570 ,Subs(Capital(SRA->RA_NOME)+Space(30),1,30),oFont10) //NOME
EndIf	
	
oPrint:say (nL+nAddL+nPT+15,185 ,"12 "+STR0005, oFont08)  	//"ENDERECO (LOGRADOURO, N∫, ANDAR, APARTAMENTO)"
oPrint:say (nL+nAddL+nPT+15,1855,"13 "+STR0014, oFont08)	  	//"|04 BAIRRO : "
If SRA->(FieldPos("RA_NUMENDE")) # 0 .And. !Empty(SRA->RA_NUMENDE) 
	oPrint:say (nL+nAddL+nPD+15,205 ,Subs(Capital(SRA->RA_ENDEREC)+', '+SRA->RA_NUMENDE+Space(40),1,40),oFont10) // "|03 ENDERECO + NUMERO DE ENDERECO
Else
	oPrint:say (nL+nAddL+nPD+15,205 ,Subs(Capital(SRA->RA_ENDEREC)+Space(30),1,30),oFont10)	//"|03 ENDERECO   : "
EndIf
oPrint:say (nL+nAddL+nPD+15,965 ,Capital(SRA->RA_COMPLEM), oFont10)	//"|03 COMPLEMENTO
oPrint:say (nL+nAddL+nPD+15,1870,Capital(SRA->RA_BAIRRO), oFont10)		//"|04 BAIRRO : "
oPrint:line(nL+(nAddL*2)+20,165 ,nL+(nAddL*2)+20,nColMax) 		//LINHA HORIZONTAL
oPrint:line(nL+nAddL+10,1835,nL+(nAddL*2)+20,1835)				//LINHA VERTICAL MEIO	

oPrint:say (nL+(nAddL*2)+nPT+20,185 ,"14 "+STR0015, oFont08)	//"|MUNIC.: "
oPrint:say (nL+(nAddL*2)+nPT+20,750 ,"15 "+STR0016, oFont08)	//"|UF : "
oPrint:say (nL+(nAddL*2)+nPT+20,1050,"16 "+STR0013, oFont08)	//"|CEP: "
oPrint:say (nL+(nAddL*2)+nPT+20,1400,"17 "+STR0024, oFont08)	//"|CTPS"
oPrint:say (nL+(nAddL*2)+nPT+20,1855, STR0012, oFont08)		//18 CPF:"

oPrint:say (nL+(nAddL*2)+nPD+20,205 ,Capital(SRA->RA_MUNICIP), oFont10)	//"|MUNIC.: " 
oPrint:say (nL+(nAddL*2)+nPD+20,770 ,SRA->RA_ESTADO , oFont10)	//"|UF : "
oPrint:say (nL+(nAddL*2)+nPD+20,1065,SRA->RA_CEP , oFont10)		//"|CEP: "
oPrint:say (nL+(nAddL*2)+nPD+20,1415,SRA->RA_NUMCP+"- "+SRA->RA_SERCP+"/"+SRA->RA_UFCP, oFont10)	//"|CTPS"
oPrint:say (nL+(nAddL*2)+nPD+20,1870,SRA->RA_CIC, oFont10)		//18 CPF:"

oPrint:line(nL+(nAddL*3)+30,165 ,nL+(nAddL*3)+30,nColMax) 	//LINHA HORIZONTAL
oPrint:line(nL+(nAddL*2)+20,730 ,nL+(nAddL*3)+30,730 )		//LINHA VERTICAL MEIO
oPrint:line(nL+(nAddL*2)+20,1030,nL+(nAddL*3)+30,1030)		//LINHA VERTICAL MEIO
oPrint:line(nL+(nAddL*2)+20,1650,nL+(nAddL*3)+30,1650)		//LINHA VERTICAL MEIO
oPrint:line(nL+(nAddL*2)+20,1835,nL+(nAddL*3)+30,1835)		//LINHA VERTICAL MEIO

oPrint:say (nL+(nAddL*3)+nPT+30,185 , STR0027, oFont08)		//19 NASC.:"
oPrint:say (nL+(nAddL*3)+nPT+30,540, STR0007, oFont08)		//20 NOME DA MAE"
oPrint:say (nL+(nAddL*3)+nPD+30,210 , DtoC(SRA->RA_NASC), oFont10)	//19 NASC.:"
oPrint:say (nL+(nAddL*3)+nPD+30,550, SUBSTR(Capital(SRA->RA_MAE)+Space(30),1,40), oFont10)	//20 NOME DA MAE"
oPrint:line(nL+(nAddL*3)+30,0530,nL+(nAddL*4)+40,0530)		//LINHA VERTICAL MEIO

nL:=nL+(nAddL*4)+40
//DADOS DO CONTRATO
oPrint:FillRect( {nL, 167, nL+nSubT, nColMax}, oBrush1 )

oPrint:Line(nL,165,nL,nColMax)				//LINHA HORIZONTAL
oPrint:say (nL+05,1027,STR0008, oFont10n)	//"DADOS DO CONTRATO"

nL:=nL+nSubT
oPrint:Box(nL+nTip,165,nL,nColMax)			//LINHA HORIZONTAL

oPrint:say (nL+nPT,185	,STR0009	  , oFont08)	//"21 TIPO DE CONTRATO"
oPrint:say (nL+nPD,210	,If( ( ( SRA->RA_TPCONTR=="1" ) .or. Empty(SRA->RA_TPCONTR)),;
								STR0010 ,;//"1. CONTRATO DE TRABALHO POR PRAZO INDETERMINADO"
								If(SRA->RA_CLAURES=="1", STR0011, STR0018)), oFont10)  //"2. CONTRATO DE TRABALHO POR PRAZO DETERMINADO COM CLAUSULA ASSECURATORIA DE DIREITO RECIPROCO DE RESCISAO ANTECIPADA."##"3. CONTRATO DE TRABALHO POR PRAZO DETERMINADO SEM CLAUSULA ASSECURATORIA DE DIREITO RECIPROCO DE RESCISAO ANTECIPADA."

nL:=nL+nTip-5
oPrint:say (nL+nPT,185,STR0019, oFont08) //"22 CAUSA DO AFASTAMENTO" 
If lSepCausa
	oPrint:say (nL+nPD,205,Alltrim( SubStr(cCausa,1,nCausaPos) ), oFont10)
	oPrint:say (nL+nPD+50,205,Alltrim( SubStr(cCausa,nCausaPos+1) ), oFont10)
Else
	oPrint:say (nL+nPD,205,Alltrim(cCausa), oFont10)
EndIf

oPrint:say (nL+nTip+nPT+10,185	,STR0020	, oFont08) //"23 REMUNERACAO MES ANT."
aAreaSRD:=GetArea()
nOrderSRD:=SRD->(DbSetOrder())

If nTipSal == 1 // Sal·rio incorporado
	nPenunSal := PenunSal(SRA->RA_ADMISSA, SRG->RG_DATADEM, cVerbas_Aux, acodfol[318, 1])
	nPenunSal := If(Empty(nPenunSal), SRG->RG_SALMES, nPenunSal)
Else
	nPenunSal := SRG->RG_SALMES
EndIF

oPrint:say (nL + nTip + nPD + 10, 180, Transform(nPenunSal, "@E 999,999,999.99"), oFont10)

DbSelectArea(aAreaSRD)

nPos		:= fPosTab(cTabRes, SRG->RG_TIPORES, "==", 04)
cCodAfa		:= fTabela(cTabRes,nPos,25)

oPrint:say (nL+nTip+nPT+10,616+15,STR0021	, oFont08) //"24 DATA DE ADMISSAO"
oPrint:say (nL+nTip+nPD+10,616+30,DtoC(SRA->RA_ADMISSA), oFont10) 
oPrint:say (nL+nTip+nPT+10,1002+15,STR0022, oFont08) //"25 DATA DO AVISO PREVIO"
oPrint:say (nL+nTip+nPD+10,1002+30,DtoC(SRG->RG_DTAVISO), oFont10) 
oPrint:say (nL+nTip+nPT+10,1388+15,STR0026, oFont08)//"26 DATA DE AFASTAMENTO" 
oPrint:say (nL+nTip+nPD+10,1388+30,DtoC(SRG->RG_DATADEM), oFont10) 
oPrint:say (nL+nTip+nPT+10,1788+15,STR0155	, oFont08) //"27 COD. AFASTAMENTO"
oPrint:say (nL+nTip+nPD+10,1788+30,cCodAfa, oFont10) 

oPrint:line(nL+nTip,606,nL+nTip+nAddL+10,606)	//LINHA VERTICAL MEIO
oPrint:line(nL+nTip,992,nL+nTip+nAddL+10,992)	//LINHA VERTICAL MEIO
oPrint:line(nL+nTip,1378,nL+nTip+nAddL+10,1378)	//LINHA VERTICAL MEIO
oPrint:line(nL+nTip,1778,nL+nTip+nAddL+10,1778)	//LINHA VERTICAL MEIO
oPrint:line(nL+nTip,165 ,nL+nTip,nColMax) 	//LINHA HORIZONTAL

oPrint:say (nL+nTip+nAddL+nPT+10,185,STR0029	, oFont08) //"28 PENSAO ALIM. (%) (TRCT)"
oPrint:say (nL+nTip+nAddL+nPD+10,210,Transform(nPerPensa,"@E 999.99"), oFont10) 
oPrint:say (nL+nTip+nAddL+nPT+10,602+15,STR0030	, oFont08) //"29 PENSAO ALIM. (%) (FGTS)"
oPrint:say (nL+nTip+nAddL+nPD+10,602+30,Transform(nPerFGTS,"@E 999.99"), oFont10) 
oPrint:say (nL+nTip+nAddL+nPT+10,1188+15,STR0031	, oFont08)//"30 CATEGORIA DO TRABALHADOR" 

/*CATEGORIAS FUNCIONARIOS CONSIDERADOS NO TRCT ATRAVES DA PORTARIA 1057/2012 	
01 - EMPREGADO
03 - TRABALHADOR NAO VINCULADO AO RGPS, MAS COM DIREITO AO FGTS
04 - EMPREGADO - CONTRATO DE TRAB. POR PRAZO DETERM. (LEI N∫ 9.601/98)
06 - EMPREGADO DOMESTICO
07 - MENOR APRENDIZ (LEI 10.097/2000)*/

If SRA->RA_CATEG $ "03/04/06/07"
	If SRA->RA_CATEG == "03"
		cDescCateg := STR0163
	ElseIf SRA->RA_CATEG == "04"
		cDescCateg := STR0164
	ElseIf SRA->RA_CATEG == "06"
		cDescCateg := STR0161
	ElseIf SRA->RA_CATEG == "07"
		cDescCateg := STR0162
	EndIf
EndIf

oPrint:say (nL+nTip+nAddL+nPD+10,1188+30,cCateg+' - '+cDescCateg, oFont10) 

oPrint:line(nL+nTip+nAddL+10,0592,nL+nTip+(nAddL*2)+20,0592 )									//LINHA VERTICAL MEIO	
oPrint:line(nL+nTip+nAddL+10,1178,nL+nTip+(nAddL*2)+20,1178)									//LINHA VERTICAL MEIO	
oPrint:line(nL+nTip+nAddL+10,165 ,nL+nTip+nAddL+10,nColMax)										//LINHA HORIZONTAL

If MV_PAR24 == 1
	cOrgao	:=	fGetOrgao(SRA->RA_SINDICA,xFilial("RCE"))
ElseIf MV_PAR24 == 2
	cOrgao	:=	fGetOrgao(MV_PAR25,xFilial("RCE"))
Else                                            
	cOrgao	:=	""
EndIf

oPrint:say (nL+nTip+(nAddL*2)+nPT+30,185	,STR0033	, oFont08) //"31 CODIGO SINDICAL"
oPrint:say (nL+nTip+(nAddL*2)+nPT+30,606+15 ,STR0140	, oFont08) //"32 CNPJ E NOME DA ENTIDADE SINDICAL LABORAL"
If MV_PAR24 <> 3     
	fSindic(@cCodSind,@cNomeSind)                 
	If ( SRA->RA_VIEMRAI <> "20" .AND. SRA->RA_VIEMRAI <> "25" )
		oPrint:say (nL+nTip+(nAddL*2)+30+nPD,185	,cCodSind, oFont10) 
	Endif
	oPrint:say (nL+nTip+(nAddL*2)+nPD+30,606+30,cNomeSind, oFont10)  
Endif	

oPrint:line(nL+nTip+(nAddL*2)+20,606,nL+nTip+(nAddL*3)+30,606 )											//LINHA VERTICAL MEIO	
oPrint:line(nL+nTip+(nAddL*2)+20,165 ,nL+nTip+(nAddL*2)+20,nColMax) 										//LINHA HORIZONTAL

nL:=nL+nTip+(nAddL*3)+30

oPrint:FillRect( {nL, 165, nL+nSubT, nColMax}, oBrush1 )
oPrint:Box(nL, 165,nL+(nSubT*3), nColMax )	//BOX P/ TIT. "DISCRIMINACAO DAS VERBAS RESCISORIAS"
oPrint:say (nL+05,835,STR0035, oFont10n)		//"DISCRIMINACAO DAS VERBAS RESCISORIAS"

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥fDesconto ≥ Autor ≥ Gustavo M             ≥ Data ≥ 20/06/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Quebra de linha para os descontos                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ IMPRESH                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fDesconto(nValLin)

nValLin++
If nValLin > 3
	nL+=nAddL+05
 	oPrint:line(nL,165,nL,nColMax )
   	fVerQuebra(2)
   	nValLin := 1
EndIf

Return   

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥fAjustaLin≥ Autor ≥ Claudinei Soares      ≥ Data ≥ 27/11/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥Ajusta a impressao,caso existam linhas em branco disponiveis≥±±
±±≥          ≥no quadro de Verbas Rescisorias ou Deducoes, utilizando uma ≥±±
±±≥          ≥unica pagina, se possivel. Verbas(3 linhas) Deduc(2 linhas).≥±±
±±≥          ≥nRubric = numero de rubricas da secao verbas                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ IMPRESH                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fAjustaLin(nRubric)
Local nRubDeduc	:= 8
Local nY		:= 0
Local nUsaLinha	:= 0
Local nLDisponi	:= 0

//CONTA AS RUBRICAS DE DEDUCOES

GPER140Sum(2,3,"172/170/128/058/056") 	//"100 Pens„o AlimentÌcia"
GPER140Sum(2,2,"A01") 					//"101 Adiantamento Salarial"
GPER140Sum(2,2,"A02") 					//"102 Adiantamento de 13∫ Sal·rio"
GPER140Sum(2,1,"113") 					//"103 Aviso-PrÈvio Indenizado"
GPER140Sum(2,1,"064/065")	 			//"112.1 PrevidÍncia Social"
GPER140Sum(2,1,"070") 					//"112.2 PrevidÍncia Social 13∫ Salario"
GPER140Sum(2,1,"066/067") 				//"114.1 IRRF"
GPER140Sum(2,1,"071")	 				//"114.2 IRRF sobre 13∫ Sal·rio"	
if Val(Alltrim(GPER140Sum(2,2,"A09") )) <> 0					//"104 MULTA ART. 480/CLT"
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,2,"A08"))) <> 0					//"105 EMPRESTIMO EM CONSIGNACAO"
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,2,"A04"))) <> 0					//"106 VALE-TRANSPORTE"
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,2,"A06"))) <> 0					//"107 REEMBOLSO DO VALE-TRANSPORTE"
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,2,"A05"))) <> 0					//"108 VALE-ALIMENTACAO"
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,2,"A07"))) <> 0					//"109 REEMBOLSO VALE-ALIMENTACAO"
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,2,"A11"))) <> 0					//"110 CONTIBUICAO PARA O FAPI"
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,2,"A13"))) <> 0					//"111 CONTRIBUICAO SINDICAL LABORAL"
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,2,"A10"))) <> 0					//"113 CONTRIBUICAO PREVIDENCIA "
	nRubDeduc ++
Endif
if Val(Alltrim(GPER140Sum(2,1,"152"))) <> 0					//"114.3 IRRF SOBRE PARTICIPACAO NOS "
	nRubDeduc ++	
Endif

//CAMPOS 115
For nY:= 1 to Len(aHomD)
	If aHomD[nY,7] == 0
		nRubDeduc ++
	EndIf
Next

// OBTEM A QUANTIDADE DE LINHAS NECESSARIAS PARA O GRUPO DE DEDUCAO.
If nRubDeduc > 19 .and. nRubDeduc < 23
	nUsaLinha := 2
ElseIf nRubDeduc > 16 .and. nRubDeduc < 20
	nUsaLinha := 1
ElseIf nRubDeduc > 22
	nUsaLinha := 3
EndIf

// OBTEM A QUANTIDADE DE LINHAS DISPONIVEIS NO GRUPO DE VERBAS RESCISORIAS.
If nRubric < 23
	nLDisponi := 3
ElseIf nRubric < 26 .and. nRubric > 22
	nLDisponi := 2
ElseIf nRubric < 29 .and. nRubric > 25
	nLDisponi := 1
Endif

nLinLivre := nLDisponi - nUsaLinha

Return (nLinLivre)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥fSindic≥ Autor ≥ Renan Borges    	        ≥ Data ≥ 21/08/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Preenchimento do cÛdigo de sindicato.					  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ IMPRESH                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fSindic(cCodSind,cNomeSind)
Local lTrabRural
Local aAreaRCE

cCodSind := SRA->RA_SINDICA

If MV_PAR24 == 2
	cCodSind := MV_PAR25
EndIf

	lTrabRural := ( SRA->RA_VIEMRAI == "20" .Or. SRA->RA_VIEMRAI == "25" )
	
	If !Empty(cCodSind)
		aAreaRCE := GetArea()
		
		DbSelectArea("RCE")
		If DbSeek(xFilial('RCE',SRA->RA_FILIAL)+cCodSind)                           
			if !lTrabRural  .Or. (lTrabRural .and. !Empty(cCodSind) .and. MV_PAR24 == 1)
				If ( ALLTRIM(STR(VAL(RCE->RCE_ENTSIN))) == ALLTRIM(RCE->RCE_ENTSIN) )
					cCodSind  := Transform(RCE->RCE_ENTSIN,"@R 999.999.999.99999-9")
				Else
					cCodSind  := ALLTRIM(RCE->RCE_ENTSIN)					
				EndIf
		    Endif
			cNomeSind := Transform( RCE->RCE_CGC , "@R 99.999.999/9999-99") + " - " + RCE->RCE_DESCRI
		EndIf
		
		RestArea(aAreaRCE)
	EndIf
	
	//Se nao existir entidade representativa da categoria, deve ser usado os dados do MTE
	If !lTrabRural .And. Empty(cCodSind)
		cCodSind  := '999.000.000.00000-3'
		cNomeSind := '37.115.367/0035-00 - MinistÈrio do Trabalho e Emprego - MTE'
	ElseIf lTrabRural .and. !(!Empty(cCodSind) .and. MV_PAR24 == 1)
        cCodSind  := ''
        cNomeSind := '37.115.367/0035-00 - MinistÈrio do Trabalho e Emprego - MTE'  	
	EndIf
	
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥fSepCausa≥ Autor ≥ Renan Borges           ≥ Data ≥ 17/11/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Quebra do conteudo da Causa de Afastamento                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ IMPRESH                                                    ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fSepCausa(cCausa, nCausaPos)
Local nCont	// Verificar a partir deste caracter pois ele j· pode ser um ESPA«O
Local lRet		:= .F.	// Ir· definir se separa ou n„o.

If Len(AllTrim(cCausa)) > 77 // Tamanho m·ximo de caracteres que n„o ultrapassam a margem 
	For nCont := 78 To 0 Step -1
		If Asc(Substr(Alltrim(cCausa),nCont,1)) == 32
			lRet	:= .T.
			Exit
		EndIf
	Next
EndIf

nCausaPos	:= nCont

Return lRet

