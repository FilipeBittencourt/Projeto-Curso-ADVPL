#include "rwmake.ch"
#include "ap5mail.ch"

User Function EmailFac(cAssunto, cMsg, cAPI, cInfo)
    Local cHTML := ""

    //|Inclui a informação da empresa |
    cAssunto    := "[" + AllTrim(SubStr(SM0->M0_NOME,1, At(" ",SM0->M0_NOME))) + "] " + cAssunto

    cHTML:='<HTML><HEAD><TITLE></TITLE>'
    cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
    cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
    cHTML+='<BODY>'
    cHTML+='<div style="margin:0;padding:0;background-color:#ffffff;height:100%">'
    cHTML+='    <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color:#ffffff;overflow-x:hidden">'
    cHTML+='      <tbody>'
    cHTML+='        <tr>'
    cHTML+='          <td align="left">'
    cHTML+='            <table align="center" border="0" cellpadding="0" cellspacing="0" style="border-collapse:collapse;overflow-x:hidden;font-family:&#39;proxima-nova&#39;,sans-serif;width:100%;max-width:560px">'
    cHTML+='			<tbody>'
    cHTML+='                <tr>'
    cHTML+='                  <td align="center">'
    cHTML+='                    <table align="center" border="0" cellpadding="0" cellspacing="0" style="overflow-x:hidden;margin:0px 20px 0px 20px;border:1px solid #ebebeb">'
    cHTML+='                    <tbody>'
    cHTML+='					<tr>'
    cHTML+='                        <td align="center" bgcolor="#3577B0"  style="padding:30px 30px 20px 30px; font-size:50px; color:#ffffff; font-family:&#39;proxima-nova&#39;,sans-serif">FacIN</td>'
    cHTML+='					</tr>'
    cHTML+='					<tr>'
    cHTML+='					  <td align="left" bgcolor="#ffffff" style="padding:30px 30px 0px 30px;font-family:&#39;proxima-nova&#39;,sans-serif">'
    cHTML+='						Mensagem: <h1 style="margin:0px;padding:0;font-size:20px;color:#EB493B;line-height:32px">'+cMsg+' </h1>'
    cHTML+='					  </td>'
    cHTML+='					</tr>'

    cHTML+='					<tr>'
    cHTML+='					  <td align="left" bgcolor="#ffffff" style="padding:15px 30px 10px 30px;font-family:&#39;proxima-nova&#39;,sans-serif">'
    cHTML+='						<p style="padding:0px;color:#333f4c;margin:0;font-size:18px;line-height:28px">'
    cHTML+='							<span style="font-weight:600;color:#3577B0">API: </span>'
    cHTML+='                             '+cAPI+'                                                '
    cHTML+='							<br />'
    cHTML+='						</p>'
    cHTML+='					  </td>'
    cHTML+='					</tr>'

    cHTML+='					<tr>'
    cHTML+='					  <td align="left" bgcolor="#ffffff" style="padding:15px 30px 10px 30px;font-family:&#39;proxima-nova&#39;,sans-serif">'
    cHTML+='						<p style="padding:0px;color:#333f4c;margin:0;font-size:18px;line-height:28px">'
    cHTML+='							<span style="font-weight:600;color:#3577B0">Body: </span>'
    cHTML+='                             '+cInfo+'                                                '
    cHTML+='							<br />'
    cHTML+='						</p>'
    cHTML+='					  </td>'
    cHTML+='					</tr>'
    cHTML+='                      </tbody>'
    cHTML+='                    </table>'
    cHTML+='                  </td>'
    cHTML+='                </tr>'
    cHTML+='                <tr>'
    cHTML+='                  <td align="left" bgcolor="#ffffff" style="padding:20px 20px 0px 20px;font-family:&#39;proxima-nova&#39;,sans-serif">'
    cHTML+='                    <p style="padding:0px;color:#7e8790;margin:0;font-size:14px;line-height:24px;text-align:center">'
    cHTML+='                      Enviado por <span style="font-weight:600;color:#3577B0">FacIN</span>. O jeito mais f�cil de vender.<br /> <span style="font-weight:600;color:#3577B0">FACILE SISTEMAS</span>'
    cHTML+='                    </p>'
    cHTML+='                  </td>'
    cHTML+='                </tr>'
    cHTML+='              </tbody>'
    cHTML+='            </table>'
    cHTML+='          </td>'
    cHTML+='        </tr>'
    cHTML+='      </tbody>'
    cHTML+='    </table>'
    cHTML+='	</div>'
    cHTML+='	</body>'
    cHTML+='</html>'

    // Envia o e-mail      //TO                               CC  CCo
    cAviso := SendEFa("filipe.bittencourt@facilesistemas.com.br", "", "", cAssunto, cHTML)


    conout(cAviso)

Return .T.

Static Function SendEFa(cTo,cCC,cCO,cAssunto,cMsg)

    Local lResulConn := .T.
    Local lResulSend := .T.
    Local cError     := ""
    Local cRet       := ""
    Local _cUsuario   := "suporte@facilesistemas.com.br"
    Local _cSenha     := "F@341ba8"
    Local _cFrom        := "portal@facilesistemas.com.br"

    lResulConn := MailSmtpOn( "mail.facilesistemas.com.br", _cUsuario, _cSenha)

    If !lResulConn
        cError := MailGetErr()
        cRet := "Falha na conexao "+cError
    Else

        SEND MAIL FROM _cFrom TO cTo CC cCC BCC cCO SUBJECT cAssunto BODY cMsg FORMAT TEXT RESULT lResulSend

        if !lResulSend
            cRet:= "Falha no Envio!"
        else
            cRet:= "E-mail enviado com sucesso!"
        endif
    endif

return cRet