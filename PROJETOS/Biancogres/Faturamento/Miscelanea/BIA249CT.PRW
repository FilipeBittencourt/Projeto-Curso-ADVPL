#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "tbiconn.ch"

/*/{Protheus.doc} function_method_class_name
//TODO Descrição auto-gerada.
@author author
@since 04/12/2019
@version version
@example
(examples)
@see (links_or_references)
/*/

User Function BIA249CT()

	RPCSetType(3)
	WfPrepEnv('01', '01') 
	
		ProcDados() 

	RpcClearEnv()
	
Return                 


Static Function ProcDados()
	
	Local cQuery	:= ""
	
	Conout("BIA249CT => Cancelamento de ticket")
	
	cQuery += " update " + RETSQLNAME("Z11") + " 																	"
	cQuery += " set                                                                                                 "
	cQuery += " Z11_OBSER = 'Cancelado automaticamente',                                                             "
	cQuery += " Z11_SITUAC = 'C'                                                                                    "
	cQuery += " where                                                                                               "
	cQuery += " Z11_PESAGE IN                                                                                       "
	cQuery += " (                                                                                                   "
	cQuery += " 	select                                                                                          "
	cQuery += " 	TICKET = Z11_PESAGE                                                                             "
	cQuery += " 	from " + RETSQLNAME("Z11") + " Z11                                                              "
	cQuery += " 	where D_E_L_E_T_=''                                                                             "
	cQuery += " 	and Z11_PESOIN <> 0.01                                                                          "
	cQuery += " 	and Z11_PESOSA <> 0.01                                                                          "
	cQuery += " 	and Z11_DATASA = ''                                                                             "
	cQuery += " 	and Z11_SITUAC <> 'C'                                                                           "
	cQuery += " 	and Z11_MERCAD = '2'                                                                            "
	cQuery += " 	and DATEDIFF(day, Convert(Date, Z11_DATAIN), Convert(Date,GETDATE())) > 5                       "
	cQuery += " 	and not exists (																				"
	cQuery += " 		select NULL from " + RETSQLNAME("ZZV") + " ZZV												"
	cQuery += " 			JOIN " + RETSQLNAME("SC9") + "  SC9 ON  ZZV_CARGA = C9_AGREG  AND C9_NFISCAL = '' AND SC9.D_E_L_E_T_ = '' 	"
	cQuery += " 			where ZZV.D_E_L_E_T_=''                                 									"
	cQuery += " 			and ZZV_TICKET = Z11_PESAGE                         									"
	cQuery += " 	)																								"		
	cQuery += " )                                                                                                   "
	

	Conout(cQuery)
	
	TCSqlExec(cQuery)
		
Return
