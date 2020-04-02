#INCLUDE "PROTHEUS.CH"

/*
##############################################################################################################
# PROGRAMA...: FCACVA01         
# AUTOR......: Gabriel Rossi Mafioletti (FACILE SISTEMAS)
# DATA.......: 02/04/2015                      
# DESCRICAO..: Validação no Campo AB1_CODCLI que verifica se o cliente possui títulos em aberto e caso haja
				retornará falso e mostrará a tela de Posição do Cliente
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/

User Function FCACVA01()

Local _cData	:=	"" 					//Titulo Vencido há 3 Dias
Local _aArea	:=	GetArea()
Local _cAlias	:=	GetNextAlias()
Local _lRet		:=	.T.               
Local _cLojaCli	:=	Iif(Empty(M->AB1_LOJA),"01",M->AB1_LOJA)

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+ M->AB1_CODCLI+_cLojaCli))                      
    
If SA1->A1_RISCO == "A"
	RestArea(_aArea)
	Return _lRet
EndIf
                      
dbSelectArea("SX6")	

If !ExisteSx6("CAC_VNCTIT")
	CriarSX6("CAC_VNCTIT", "N", "Dias para serem considerados para vencimentos de títulos", "3")	
EndIf 
		                     
_cData :=	dtoS(dDataBase - GETMV("CAC_VNCTIT"))

BeginSql Alias _cAlias
SELECT SUM(CASE WHEN A.E1_TIPO LIKE '__-' THEN A.E1_SALDO*-1 ELSE A.E1_SALDO END) AS SLDVEN
	FROM SE1010 A 
	WHERE E1_CLIENTE = %Exp:M->AB1_CODCLI% 
		AND E1_SALDO > 0
		AND E1_VENCREA <= %Exp:_cData%
		AND A.E1_TIPO NOT IN ('NCC','RA')
		AND A.%NotDel%
EndSql

If (_cAlias)->SLDVEN > 0
	MsgInfo("Existem Títulos Atrasados Para o Cliente em Questão")
	_lRet	:=	.F.
	FShowPos()
EndIf

(_cAlias)->(DbCloseArea())

RestArea(_aArea)
Return _lRet


Static Function FShowPos()

Local _aParam	:=	{}
Local _dDatade	:=	StoD("20100101")               
Local _aAreaSA1	:=	SA1->(GetArea())

                                               
MV_PAR01	:=	_dDataDe	// Emissao De
MV_PAR01	:=	DATE()  	// Emissao Ate
MV_PAR01	:=	_dDataDe	// Vencimento De
MV_PAR01	:=	DATE()  	// Vencimento Ate
MV_PAR01	:=	1			// Considera Provisorios
MV_PAR01	:=	"   "		// Do Prefixo
MV_PAR01	:=	"ZZZ"		// Ate Prefixo
MV_PAR01	:=	1			// Considera Faturados	
MV_PAR01	:=	2			// Considera Liquidados
MV_PAR01	:=	2			// Pedidos c/Itens Bloq.
MV_PAR01	:=	1			// Titulos Gerados por Liquidacao
MV_PAR01	:=	1			// Considera Saldo ? Normal/Corrigido
MV_PAR01	:=	1			// Considera Lojas ?
MV_PAR01	:=	1			// TES gera duplicata ?
MV_PAR01	:=	2			// Considera RA ?
MV_PAR01	:=	1
MV_PAR01	:=	2

Fc010Con()

                          
SA1->(RestArea(_aAreaSA1))
Return      
