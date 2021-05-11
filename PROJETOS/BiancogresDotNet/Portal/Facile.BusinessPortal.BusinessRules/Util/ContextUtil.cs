using Facile.BusinessPortal.Model;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;

namespace Facile.BusinessPortal.BusinessRules.Util
{
    public static class ContextUtil
    {
        public static bool CheckPermissao(FBContext _context, Usuario Usuario, string acao, long MenuID = 0)
        {
            if (Usuario != null)
            {
                var ResultPermissao = _context.Permissao.Where(
                        x => x.GrupoUsuarioID == Usuario.GrupoUsuarioID &&
                        x.MenuID == MenuID
                    );
                return ResultPermissao.Any(x => x.Acao.Nome.Equals(acao));
            }
            return false;
        }

        public static object GetParametroPorChave(FBContext _context, string Chave, long EmpresaID)
        {
            var Result =  _context.Parametro.FirstOrDefault(x => x.Chave.Equals(Chave) && x.EmpresaID == EmpresaID);
            if (Result != null)
            {
                return Result.Valor;
            }
            return null;
        }
       
    }
}
