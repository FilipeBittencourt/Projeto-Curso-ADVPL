#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*
##############################################################################################################
# CLASSE.....: BIAF029
# AUTOR......: WLYSSES CERQUEIRA (FACILE)
# DATA.......: 22/10/2019
# DESCRICAO..: CLASSE COM TODOS PROCESSOS A SEREM EXECUTADOS DENTO DO PE M460FIM.
#			   M460FIM -> CHAMADO APOS A GRAVACAO DA NF DE SAIDA, E FORA DA TRANSAÇÃO.
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/

Class BIAF029 From LongClassName

Method New(lJob) Constructor // Metodo construtor
Method Processa()
Method SetMsgCarga() // Coloca msg complementar informada na carga
Method GetMsgCarga() // Busca a msg complementar informada na carga

EndClass

Method New() Class BIAF029

Return(Self)

Method Processa() Class BIAF029

	::SetMsgCarga()

Return()

Method SetMsgCarga() Class BIAF029

	Local cMsg := ""

	conout('entrei em SetMsgCarga')
	cMsg := ::GetMsgCarga()

	//Tratado questao que a Mensagem da Nota quando o faturamento e MANUAL estava sendo substituida por este programa
	ConOut("BIAF029 ==> NF:"+SF2->(F2_SERIE + F2_DOC)+" - Gravando Mensagem:"+cMsg+" Time:" + Time())
	If !Empty(cMsg)

		RecLock("SF2", .F.)
		SF2->F2_YMENNOT	:= cMsg
		SF2->(MsUnLock())

	EndIf

Return()

Method GetMsgCarga() Class BIAF029

	Local cMsg		:= ""
	Local cAliasTmp	:= ""
	Local cSQL		:= ""
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC9	:= SC9->(GetArea())
	Local aAreaZZV	:= ZZV->(GetArea())
	Local oObjEmp	:= TLoadEmpresa():New()
	Local wMSGLiv1	:= ""
	Local wMSGLiv2	:= ""	

	DBSelectArea("SC9")
	SC9->(DBSetOrder(6)) // C9_FILIAL, C9_SERIENF, C9_NFISCAL, C9_CARGA, C9_SEQCAR, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SC5")
	SC5->(DBSetOrder(1)) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_

	conout('entrei em GetMsgCarga')
	If SC9->(DBSeek(xFilial("SC9") + SF2->(F2_SERIE + F2_DOC)))

		If !Empty(SC9->C9_AGREG)

			If SC5->(DBSeek(xFilial("SC5") + SC9->C9_PEDIDO))

				wMSGLiv1  := Subs(SC5->C5_MENNOTA, 1, 100)
				wMSGLiv2  := Subs(SC5->C5_MENNOTA, 101, 100)

				If !Empty(AllTrim(wMSGLiv1))				
					cMsg += AllTrim(wMSGLiv1)	
				EndIf

				If !Empty(AllTrim(wMSGLiv2))				
					cMsg += AllTrim(wMSGLiv2)	
				EndIf 	

				ConOut("BIAF029 ==> NF:"+SF2->(F2_SERIE + F2_DOC)+" - Mensagem pedido:"+cMsg+" Time:" + Time())

				If !( oObjEmp:SeekCli(SC5->C5_CLIENTE, SC5->C5_LOJACLI) ) // Se cliente eh filial

					If Empty(SC5->C5_YPEDORI)

						DBSelectArea("ZZV")
						ZZV->(DBSetOrder(1)) //ZZV_FILIAL, ZZV_CARGA, R_E_C_N_O_, D_E_L_E_T_

						If ZZV->(DBSeek(xFilial("ZZV") + SC9->C9_AGREG))

							If !Empty(cMsg)
								cMsg := AllTrim(cMsg) + " "
							EndIf

							cMsg += AllTrim(Upper(ZZV->ZZV_OBSNF1)) + " "

							If !Empty(ZZV->ZZV_PLACA)								

								cMsg += "Placa: "+ZZV->ZZV_PLACA

							EndIf

							ConOut("BIAF029 ==> NF:"+SF2->(F2_SERIE + F2_DOC)+" - Mensagem carga:"+cMsg+" Time:" + Time())

						EndIf

					Else

						If !Empty(SC5->C5_YEMPPED)

							cAliasTmp := GetNextAlias()

							cSQL := " SELECT ZZV_OBSNF1, ZZV_PLACA "
							cSQL += " FROM " + RetFullName("ZZV", SC5->C5_YEMPPED) + " ZZV (NOLOCK) "
							cSQL += " WHERE ZZV_FILIAL	 = '01' "
							cSQL += " AND ZZV_CARGA	 = " + ValToSql(SC9->C9_AGREG)
							cSQL += " AND ZZV.D_E_L_E_T_ = '' "

							ConOut("BIAF029 ==> NF:"+SF2->(F2_SERIE + F2_DOC)+" SQL LM: "+cSQL)

							TcQuery cSQL New Alias (cAliasTmp)

							If (cAliasTmp)->(!EOF())

								If !Empty(cMsg)
									cMsg := AllTrim(cMsg) + " "
								EndIf
								
								cMsg += AllTrim(Upper((cAliasTmp)->ZZV_OBSNF1)) + " "

								If !Empty((cAliasTmp)->ZZV_PLACA)								

									cMsg += "Placa: "+(cAliasTmp)->ZZV_PLACA

								EndIf

								ConOut("BIAF029 ==> NF:"+SF2->(F2_SERIE + F2_DOC)+" - Mensagem carga LM:"+cMsg+" Time:" + Time())

							EndIf

							(cAliasTmp)->(DbCloseArea())

						EndIf

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aAreaZZV)
	RestArea(aAreaSC5)
	RestArea(aAreaSC9)

Return(cMsg)