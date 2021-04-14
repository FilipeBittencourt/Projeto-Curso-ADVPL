#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA743
@description JOB que Envia EMAIL pendentes de aprovação de descontos financeiro via limites estabelecidos.
@author Filipe Bittencourt
@since 14/04/2021
@version 1.0
@type function
/*/ 

User Function BIA743()

  Local cSQL      := ""
  Local cQry      := ""
  Local dDtIni    := ""
  Local aAuxJS    := {}
  Local oJSZL0    := JsonObject():New()

  RpcClearEnv()
  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  cQry   := GetNextAlias()

  cSQL := " SELECT " + CRLF

  cSQL += "   ZKH.ZKH_STATUS " + CRLF
  cSQL += " , ZKH.ZKH_APROV " + CRLF
  cSQL += " , ZKH.ZKH_EMAIL " + CRLF
  cSQL += " , ZL0.* " + CRLF

  cSQL += " FROM ZKH010 ZKH " + CRLF

  cSQL += " INNER JOIN ZL0010 ZL0 ON ZKH.ZKH_ID = ZL0.R_E_C_N_O_ " + CRLF
  cSQL += " AND ZL0.ZL0_CODEMP = ZKH.ZKH_EMP  " + CRLF
  cSQL += " AND ZL0.ZL0_CODFIL = ZKH.ZKH_FIL " + CRLF
  cSQL += " AND ZL0.D_E_L_E_T_ = ''   " + CRLF

  cSQL += "  WHERE ZKH.ZKH_TABELA = 'ZL0010' " + CRLF
  cSQL += "  AND ZKH.ZKH_STATUS = 'E' " + CRLF
  cSQL += "  AND ZKH.ZKH_PROCES = 'DESCONTO-FINANCEIRO' " + CRLF
  cSQL += "  AND ZKH.D_E_L_E_T_ = '' " + CRLF
  cSQL += "  ORDER BY ZKH.ZKH_EMAIL  " + CRLF

  TcQuery cSQL New Alias (cQry)

  While (cQry)->(!Eof())

    AADD(aAuxJS,   JsonObject():New())
    aAuxJS[Len(aAuxJS)]["ZL0_CODEMP"]  := AllTrim((cQry)->ZL0_CODEMP)
    aAuxJS[Len(aAuxJS)]["ZL0_CODFIL"]  := AllTrim((cQry)->ZL0_CODFIL)

    aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"]  := AllTrim((cQry)->ZL0_CLVLDB)
    aAuxJS[Len(aAuxJS)]["ZL0_DEBITO"]  := AllTrim((cQry)->ZL0_DEBITO)
    aAuxJS[Len(aAuxJS)]["ZL0_DESCON"]  := (cQry)->ZL0_DESCON
    aAuxJS[Len(aAuxJS)]["ZL0_VALOR"]   := (cQry)->ZL0_VALOR

    aAuxJS[Len(aAuxJS)]["ZL0_CLIFOR"]  := AllTrim((cQry)->ZL0_CLIFOR)
    aAuxJS[Len(aAuxJS)]["ZL0_LOJA"]    := AllTrim((cQry)->ZL0_LOJA)
    aAuxJS[Len(aAuxJS)]["ZL0_EMISSA"]  := AllTrim((cQry)->ZL0_EMISSA)
    aAuxJS[Len(aAuxJS)]["ZL0_NUM"]     := AllTrim((cQry)->ZL0_NUM)
    aAuxJS[Len(aAuxJS)]["ZL0_PREFIX"]  := AllTrim((cQry)->ZL0_PREFIX)
    aAuxJS[Len(aAuxJS)]["ZL0_PARCEL"] := AllTrim((cQry)->ZL0_PARCEL)
    aAuxJS[Len(aAuxJS)]["ZL0_TIPO"]    := AllTrim((cQry)->ZL0_TIPO)

    aAuxJS[Len(aAuxJS)]["EMAIL"] := AllTrim((cQry)->ZKH_EMAIL)

    aAuxJS[Len(aAuxJS)]["EMAIL"] := "filipe.bittencourt@facilesistemas.com.br"

    if EMPTY(aAuxJS[Len(aAuxJS)]["EMAIL"])
      aAuxJS[Len(aAuxJS)]["EMAIL"] := "filipe.bittencourt@facilesistemas.com.br"
    EndIf

    (cQry)->(DbSkip())

  EndDo

  oJSZL0["ZL0"] := aAuxJS

  (cQry)->(DbCloseArea())

  EmailSend(oJSZL0)


Return

Static Function EmailSend(oJSZL0)

  Local nI    := 1
  Local cHtmlIni :=  ""
  Local cHtmlFim :=  ""
  Local cBody :=  ""
  Local cMailAux := "x"
  ASORT(oJSZL0["ZL0"],,, { |x, y| x["EMAIL"] >  y["EMAIL"]} )

  cHtmlIni := " <html> "
  cHtmlIni += "   <body style='font-family: Courier, Arial, Helvetica, sans-serif;'> "
  cHtmlIni += "      <div style='margin:0;padding:0;background-color:#ffffff;height:100%'> "
  cHtmlIni += "         <table align='center' border='0' cellpadding='0' cellspacing='0' style='overflow-x:hidden;margin:0px 20px 0px 20px;border:1px solid #ebebeb'> "
  cHtmlIni += "            <tbody> "
  cHtmlIni += "               <tr> "
  cHtmlIni += "                  <td align='center' bgcolor='#919191'  style='font-size:20px; color:#ffffff; font-family: Courier, Arial, Helvetica, sans-serif;'> "
  cHtmlIni += "                     <h4 style='margin:0px; padding:15px;'>Liberação de descontos</h4> "
  cHtmlIni += "                  </td> "
  cHtmlIni += "               </tr> "
  cHtmlIni += "               <tr> "
  cHtmlIni += "                  <td align='left' bgcolor='#ffffff' style='padding:30px 30px 30px 30px;font-family: Courier, Arial, Helvetica, sans-serif;'> "
  cHtmlIni += "                      Olá, <b>filipe.bittencourt@facilesistemas.com.br!</b> <br> "
  cHtmlIni += "					             Existem titulos pendendes de liberação.                       "
  cHtmlIni += "                  </td> "
  cHtmlIni += "               </tr> "
  cHtmlIni += "               <tr> "
  cHtmlIni += "                  <td align='left' bgcolor='#fff' style='padding:3px;'> "
  cHtmlIni += "                     <table align='center' style='width:100%; border-collapse: collapse;  border: 1px solid #e5e5e5;'> "
  cHtmlIni += "                        <tbody> "
  cHtmlIni += "                           <tr> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Empresa/Filial</th> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Cliente/Loja</th> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Classe</th> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>C.Contabil</th> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Titulo/Prefixo/Tipo</th> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Parcela</th> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Valor</th> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Desconto</th> "
  cHtmlIni += "								                 <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Emissão</th>		 "
  cHtmlIni += "                            </tr> "



  cHtmlFim += "                        </tbody> "
  cHtmlFim += "                     </table> "
  cHtmlFim += "                  <td> "
  cHtmlFim += "               </tr> "
  cHtmlFim += "               <tr> "
  cHtmlFim += "                  <td align='center' bgcolor='#FAFAFA' style='padding:30px 30px 30px 30px;'> "
  cHtmlFim += "                     <p style='padding:0px;color:#333f4c;margin:0;font-size:11px;line-height:22px'> "
  cHtmlFim += "                        Esta notificação foi enviada por um email configurado para não receber resposta. "
  cHtmlFim += "						Por favor, não responda esta mensagem.  "
  cHtmlFim += "                     </p> "
  cHtmlFim += "                  </td> "
  cHtmlFim += "               </tr> "
  cHtmlFim += "            </tbody> "
  cHtmlFim += "         </table> "
  cHtmlFim += "      </div> "
  cHtmlFim += "   </body> "
  cHtmlFim += "</html> "

  if Len(oJSZL0["ZL0"]) > 0

    cMailAux :=  oJSZL0["ZL0"][1]["EMAIL"]

    for nI := 1 To Len(oJSZL0["ZL0"])

      if !Empty(oJSZL0["ZL0"][nI]["EMAIL"])

        cHtml := "<html><body>"

        if (AllTrim(oJSZL0["ZL0"][nI]["EMAIL"]) == AllTrim(cMailAux)) .OR. (EMPTY(cMailAux))

          cBody += "  <tr> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+oJSZL0["ZL0"][nI]["ZL0_CODEMP"]+"/"+oJSZL0["ZL0"][nI]["ZL0_CODFIL"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'> "+oJSZL0["ZL0"][nI]["ZL0_CLIFOR"]+ "/"+oJSZL0["ZL0"][nI]["ZL0_LOJA"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'> "+oJSZL0["ZL0"][nI]["ZL0_CLVLDB"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'> "+oJSZL0["ZL0"][nI]["ZL0_DEBITO"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+oJSZL0["ZL0"][nI]["ZL0_NUM"]+ "/"+oJSZL0["ZL0"][nI]["ZL0_PREFIX"]+" "+oJSZL0["ZL0"][nI]["ZL0_TIPO"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+oJSZL0["ZL0"][nI]["ZL0_PARCEL"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+TRANSFORM(oJSZL0["ZL0"][nI]["ZL0_VALOR"],PesqPict("ZL0","ZL0_VALOR"))+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+TRANSFORM(oJSZL0["ZL0"][nI]["ZL0_DESCON"], PesqPict("ZL0","ZL0_DESCON"))+"</td> "
          cBody += "    <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+SubStr(oJSZL0["ZL0"][nI]["ZL0_EMISSA"],7,2)+'/'+SubStr(oJSZL0["ZL0"][nI]["ZL0_EMISSA"],5,2)+'/'+SubStr(oJSZL0["ZL0"][nI]["ZL0_EMISSA"],1,4)+"</td> "
          cBody += "  </tr> "

        Else

          cHtmlIni := cHtmlIni+cBody+cHtmlFim
          U_BIAEnvMail(,cMailAux,'Você tem titulos à liberar descontos',cHtmlIni)
          cBody := "  <tr> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+oJSZL0["ZL0"][nI]["ZL0_CODEMP"]+"/"+oJSZL0["ZL0"][nI]["ZL0_CODFIL"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'> "+oJSZL0["ZL0"][nI]["ZL0_CLIFOR"]+ "/"+oJSZL0["ZL0"][nI]["ZL0_LOJA"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'> "+oJSZL0["ZL0"][nI]["ZL0_CLVLDB"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'> "+oJSZL0["ZL0"][nI]["ZL0_DEBITO"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+oJSZL0["ZL0"][nI]["ZL0_NUM"]+ "/"+oJSZL0["ZL0"][nI]["ZL0_PREFIX"]+" "+oJSZL0["ZL0"][nI]["ZL0_TIPO"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+oJSZL0["ZL0"][nI]["ZL0_PARCEL"]+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+TRANSFORM(oJSZL0["ZL0"][nI]["ZL0_VALOR"],PesqPict("ZL0","ZL0_VALOR"))+"</td> "
          cBody += "     <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+TRANSFORM(oJSZL0["ZL0"][nI]["ZL0_DESCON"], PesqPict("ZL0","ZL0_DESCON"))+"</td> "
          cBody += "    <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+SubStr(oJSZL0["ZL0"][nI]["ZL0_EMISSA"],7,2)+'/'+SubStr(oJSZL0["ZL0"][nI]["ZL0_EMISSA"],5,2)+'/'+SubStr(oJSZL0["ZL0"][nI]["ZL0_EMISSA"],1,4)+"</td> "
          cBody += "  </tr> "

        EndIf

      EndIf

      cMailAux := oJSZL0["ZL0"][nI]["EMAIL"]

    NEXT nI

    if !Empty(cBody)
      cHtmlIni := cHtmlIni+cBody+cHtmlFim
      U_BIAEnvMail(,cMailAux,'Você tem titulos à liberar descontos',cHtmlIni)
    EndIf

  EndIf


RETURN