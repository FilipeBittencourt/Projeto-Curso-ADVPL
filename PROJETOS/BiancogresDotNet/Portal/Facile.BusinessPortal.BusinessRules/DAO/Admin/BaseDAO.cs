using Facile.BusinessPortal.BusinessRules.Security;
using Facile.BusinessPortal.Model;
using System;

namespace Facile.BusinessPortal.BusinessRules.DAO
{
    public class BaseDAO<T> where T : Base
    {
        public T Novo(ContextParams Params, bool IsEmpShared = false)
        {
            long? unidadeId;
            if (IsEmpShared)
                unidadeId = null;
            else
                unidadeId = Params.Unidade.ID;

            var newModel = (T)Activator.CreateInstance(typeof(T), new object[] { });
            newModel.EmpresaID = Params.Unidade.Empresa.ID;
            newModel.UnidadeID = unidadeId;
            newModel.InsertDate = DateTime.Now;
            newModel.Habilitado = true;
            return newModel;
        }

        public T Novo(Empresa empresa, Unidade unidade = null)
        {
            long? unidadeId;
            if (unidade == null)
                unidadeId = null;
            else
                unidadeId = unidade.ID;

            var newModel = (T)Activator.CreateInstance(typeof(T), new object[] { });
            newModel.EmpresaID = empresa.ID;
            newModel.UnidadeID = unidadeId;
            newModel.InsertDate = DateTime.Now;
            newModel.Habilitado = true;
            return newModel;
        }
    }
}
